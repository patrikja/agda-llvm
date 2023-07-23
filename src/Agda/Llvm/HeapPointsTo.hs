{-# LANGUAGE DuplicateRecordFields    #-}
{-# LANGUAGE NondecreasingIndentation #-}
{-# LANGUAGE OverloadedRecordDot      #-}
{-# LANGUAGE OverloadedStrings        #-}
{-# OPTIONS_GHC -Wno-name-shadowing #-}

-----------------------------------------------------------------------
-- | * GRIN heap points-to analysis
-----------------------------------------------------------------------

-- • "determine for each call to eval, a safe approximation to what different node
--   values (or rather tags) that eval might find when it fetches a node from the
--   heap via its argument pointer." (s. 67)
--
-- • The abstract heap (also called store) maps locations to a set of nodes.
--   Locations are defined as {1, 2, ...,maxloc} where maxloc is total number
--   of store operations. Additionally, locations with F-tags also contain the
--   possible return types of the function. This is due to the eval function
--   which will be generated later, but has the ability to @update@ the node with
--   the evaluated value.
--
-- • The Abstract enviroment maps variables to a set of values.
--
-- • The heap points-to analysis also incorporates a sharing analysis,
--   which determines for each abstract location if it is shared or unique.
--   An abstract location is shared if a concrete instance of the abstract
--   location is subject to @fetch@ more than once. In practice, this is
--   evident if the location is a possible value of a variable which is used
--   more than once.

module Agda.Llvm.HeapPointsTo
  ( heapPointsTo
  , AbstractContext(..)
  , Value(..)
  , AbsHeap(..)
  , AbsEnv(..)
  ) where

import           Control.Monad.Reader  (MonadReader (ask, local), Reader, asks,
                                        runReader)
import           Control.Monad.State   (State, evalState, gets, modify)
import           Data.Function         (on)
import           Data.List             (find, insert, intercalate, intersectBy,
                                        nub, partition, sortOn, (\\))
import           Data.List.Extra       (firstJust)
import           Data.Map              (Map)
import qualified Data.Map              as Map
import           Data.Set              (Set)
import qualified Data.Set              as Set
import           Prelude               hiding ((!!))

import           Agda.Utils.Function   (applyWhen)
import           Agda.Utils.Functor
import           Agda.Utils.Impossible
import           Agda.Utils.List
import           Agda.Utils.List1      (List1, pattern (:|))
import qualified Agda.Utils.List1      as List1
import           Agda.Utils.Maybe
import           Agda.Utils.Pretty

import           Agda.Llvm.Grin
import           Agda.Llvm.Utils

-- TODO
-- • Refactor H', HCxt, HRet

heapPointsTo :: [GrinDefinition] -> (AbstractContext, Set Gid)
heapPointsTo defs = (absCxt', shared) where
  shared = equations.shared'
  absCxt' = sortAbsCxt $ solveEquations defs absCxt
  absCxt = sortAbsCxt $ AbstractContext equations.absHeap' equations.absEnv'
  equations =
    foldl1 (<>) $ for defs $ \def ->
      runReader (deriveEquations def.gTerm) $
      initHCxt defs def

newtype Multiplicities = Multiplicities{unMultiplicities :: Map Abs Int}

instance Semigroup Multiplicities where
  (<>) x = Multiplicities . on (Map.unionWith (+)) unMultiplicities x

instance Monoid Multiplicities where
  mempty = Multiplicities mempty

instance Pretty Multiplicities where
  pretty (Multiplicities ms) =
      vcat $ map prettyEntry $ Map.toList ms
    where
      prettyEntry (x, n) =
        text (prettyShow x ++ ":") <+> pretty n

countMultiplicities :: GrinDefinition -> Multiplicities
countMultiplicities def = evalState (go def.gTerm) def.gArgs where
  go :: Term -> State [Abs] Multiplicities
  go (Case i t alts) =
    goVal (Var i) <> (foldl (<>) mempty <$> mapM goAlt alts) <> go t
  go (Bind t alt) = go t <> goAlt alt
  go (Store _ v) = goVal v
  go (Unit v) = goVal v
  go (App v vs) = goVal v <> (foldl (<>) mempty <$> mapM goVal vs)
  go (Fetch v) = goVal v
  go (Update v1 v2) = on (<>) goVal v1 v2
  go (Error _) = pure mempty

  goAlt :: Alt -> State [Abs] Multiplicities
  goAlt (AltVar abs t)     = modify (abs:) *> go t
  goAlt (AltNode _ abss t) = modify (reverse abss ++) *> go t
  goAlt (AltLit _ t)       = go t
  goAlt (AltEmpty t)       = go t

  goVal :: Val -> State [Abs] Multiplicities
  goVal (Var n) = gets $ (!! n) <&> \abs -> Multiplicities $ Map.singleton abs 1
  goVal (Lit _) = pure mempty
  goVal (Node _ vs) = foldl (<>) mempty <$> mapM goVal vs
  goVal (Def _) = pure mempty
  goVal (Prim _) = pure mempty
  goVal Empty = pure mempty

sortAbsCxt :: AbstractContext -> AbstractContext
sortAbsCxt cxt = cxt{fHeap = sortAbsHeap cxt.fHeap, fEnv = sortAbsEnv cxt.fEnv}

sortAbsHeap :: AbsHeap -> AbsHeap
sortAbsHeap (AbsHeap heap) = AbsHeap $ sortOn fst heap

sortAbsEnv :: AbsEnv -> AbsEnv
sortAbsEnv (AbsEnv env) = AbsEnv $ sortOn fst env

data Value = VNode Tag [Value]
           | Bas
           | Pick Value Tag Int
           | EVAL Value
           | FETCH Value
           | Union Value Value
           | Loc Loc
           | Abs Abs
             deriving (Eq, Ord)

instance Pretty Value where
  pretty (VNode tag vs) =
    pretty tag <+> text ("[" ++ intercalate ", " (map prettyShow vs) ++ "]")
  pretty Bas            = text "BAS"
  pretty (Pick v tag i) = pretty v <+> text "↓" <+> pretty tag <+> text "↓" <+> pretty i
  pretty (EVAL v) = text "EVAL(" <> pretty v <> text ")"
  pretty (FETCH v) = text "FETCH(" <> pretty v <> ")"
  pretty (Union v1 v2) = pretty v1 <+> text "∪" <+> pretty v2
  pretty (Abs abs) = pretty abs
  pretty (Loc loc) = pretty loc

vnodeView :: Value -> Maybe (Tag, [Value])
vnodeView (VNode tag vs) = Just (tag, vs)
vnodeView _              = Nothing

mkUnion :: Value -> Value -> Value
mkUnion a b
  | a == b = a
  | otherwise = Union a b

newtype AbsHeap = AbsHeap{unAbsHeap :: [(Loc, Value)]} deriving Eq

instance Semigroup AbsHeap where
  (<>) = composeAbsHeap

composeAbsHeap :: AbsHeap -> AbsHeap -> AbsHeap
composeAbsHeap (AbsHeap h1) (AbsHeap h2) =
    AbsHeap $ (h1 \\ common) ++ common' ++ (h2 \\ common)
  where
    common = let insec = intersectBy (on (==) fst) in insec h1 h2 ++ insec h2 h1
    locs = nub $ map fst common
    common'
      | null common = []
      | otherwise =
        for locs $ \loc ->
          let vs = mapMaybe (\(loc', v) -> boolToMaybe (loc'==loc) v) common in
          (loc, foldl1 mkUnion vs)

instance Semigroup AbsEnv where
  (<>) = composeAbsEnv

composeAbsEnv :: AbsEnv -> AbsEnv -> AbsEnv
composeAbsEnv (AbsEnv e1) (AbsEnv e2) =
    AbsEnv $ (e1 \\ common) ++ common' ++ (e2 \\ common)
  where
    common = let insec = intersectBy (on (==) fst) in insec e1 e2 ++ insec e2 e1
    abss = nub $ map fst common
    common'
      | null common = []
      | otherwise =
        for abss $ \abs ->
          let vs = mapMaybe (\(abs', v) -> boolToMaybe (abs'==abs) v) common in
          (abs, foldl1 mkUnion vs)

newtype AbsEnv = AbsEnv{unAbsEnv :: [(Abs, Value)]}deriving Eq

instance Pretty AbsHeap where
  pretty (AbsHeap heap) =
      vcat $ map prettyEntry heap
    where
      prettyEntry :: (Loc, Value) -> Doc
      prettyEntry (x, v) =
            pretty x
        <+> text "→"
        <+> pretty v

instance Pretty AbsEnv where
  pretty (AbsEnv env) =
      vcat $ map prettyEntry env
    where
      prettyEntry :: (Abs, Value) -> Doc
      prettyEntry (x, v) =
            pretty x
        <+> text "→"
        <+> pretty v

type H' = Reader HCxt

data HCxt = HCxt
  { absHeap    :: AbsHeap
  , absEnv     :: AbsEnv
  , defs       :: [GrinDefinition]
  , abss       :: [Abs]
  , locs       :: [Loc]
  , shared     :: Set Gid
  , currentDef :: GrinDefinition
  }

initHCxt :: [GrinDefinition] -> GrinDefinition -> HCxt
initHCxt defs currentDef =
    HCxt
      { absHeap = AbsHeap []
      , absEnv = AbsEnv []
      , defs = defs
      , abss = currentDef.gArgs
      , locs = []
      , shared = shared
      , currentDef = currentDef
      }
  where
    shared =
      Set.fromList $
      mapMaybe (\(MkAbs gid, n) -> boolToMaybe (n > 1) gid) $
      Map.toList $
      unMultiplicities $
      foldl (\ms def -> ms <> countMultiplicities def) mempty defs


instance Semigroup HRet where
  h1 <> h2 =
    let heap = on (<>) absHeap' h1 h2
        env = on (<>) absEnv' h1 h2 in
    HRet
      { absHeap' = heap
      , absEnv'  = env
      , shared' = on (composeShared heap env) shared' h1 h2
      }

data HRet = HRet
  { absHeap' :: AbsHeap
  , absEnv'  :: AbsEnv
  , shared'  :: Set Gid
  }

composeShared :: AbsHeap -> AbsEnv -> Set Gid -> Set Gid -> Set Gid
composeShared heap env = updateShared heap env .: Set.union

updateShared :: AbsHeap -> AbsEnv -> Set Gid -> Set Gid
updateShared absHeap absEnv shared
  | shared' == shared = shared
  | otherwise = updateShared absHeap absEnv shared'
  where
    shared' = foldl addGids shared vs
    vs =
      nub $
      mapMaybe (\(MkLoc gid, v) -> boolToMaybe (Set.member gid shared) v) (unAbsHeap absHeap) ++
      mapMaybe (\(MkAbs gid, v) -> boolToMaybe (Set.member gid shared) v) (unAbsEnv absEnv)

makeShared :: AbsHeap -> AbsEnv -> Set Gid -> Value -> Set Gid
makeShared heap env = updateShared heap env .: addGids

addGids :: Set Gid -> Value -> Set Gid
addGids s (Loc (MkLoc gid)) = Set.insert gid s
addGids s (Abs (MkAbs gid)) = Set.insert gid s
addGids s (VNode _ vs)      = foldl addGids s vs
addGids s Bas               = s
addGids s (Union v1 v2)     = addGids (addGids s v1) v2
addGids s (Pick v _ _)      = addGids s v
addGids s (EVAL v)          = addGids s v
addGids s (FETCH v)         = addGids s v

localAbs :: MonadReader HCxt m => Abs -> m a -> m a
localAbs abs = local $ \cxt -> cxt{abss = abs : cxt.abss}

localAbss :: MonadReader HCxt m => [Abs] -> m a -> m a
localAbss = foldl (.: localAbs) id


localLoc :: MonadReader HCxt m => Loc -> m a -> m a
localLoc loc = local $ \cxt -> cxt{locs = loc : cxt.locs}

-- TODO use lenses?
-- | Adds l → v to the abstract heap and makes v shared if x is shared
localAbsHeap :: MonadReader HCxt m => (Loc, Value) -> m a -> m a
localAbsHeap (loc, v) = local $ \cxt ->
  let heap = unAbsHeap cxt.absHeap
      heap'
        | any ((==loc) . fst) heap =
          for heap $ \(loc', v') ->
            if loc == loc' then (loc', mkUnion v' v ) else (loc', v')
        | otherwise = insert (loc, v) $ unAbsHeap cxt.absHeap
      absHeap = AbsHeap heap' in

  applyWhen
    (Set.member (unLoc loc) cxt.shared)
    (\cxt -> cxt{shared = makeShared absHeap cxt.absEnv cxt.shared v})
    cxt{absHeap = absHeap}

-- | Adds x → v to the abstract enviroment and makes v shared if x is shared
localAbsEnv :: MonadReader HCxt m => (Abs, Value) -> m a -> m a
localAbsEnv (abs, v) = local $ \cxt ->
  let env = unAbsEnv cxt.absEnv
      env'
        | any ((==abs) . fst) env =
          for env $ \(abs', v') ->
            if abs == abs' then (abs', mkUnion v' v ) else (abs', v')
        | otherwise = insert (abs, v) env
      absEnv' = AbsEnv env' in

  applyWhen
    (Set.member (unAbs abs) cxt.shared)
    (\cxt -> cxt{shared = makeShared cxt.absHeap absEnv' cxt.shared v})
    cxt{absEnv = absEnv'}

localAbssEnv :: MonadReader HCxt m => [(Abs, Value)] -> m a -> m a
localAbssEnv = foldl (.: localAbsEnv) id

deriveEquations :: Term -> H' HRet
deriveEquations term = case term of

    Bind (Store loc (Node tag vs)) (AltVar abs t) -> do
        vs' <- mapM valToValue vs
        defs <- asks defs
        case findName defs tag of
          Nothing ->
            localLoc loc $
            localAbs abs $
            localAbsEnv (abs, Loc loc) $
            localAbsHeap (loc, VNode tag vs') $
            deriveEquations t

          -- non-primitve F-tag or P-tag
          Just def -> do
            h <- localLoc loc $
                 localAbs abs $
                 localAbsEnv (abs, Loc loc) $
                 localAbsHeap (loc, VNode tag vs'  ) $
                 localAbssEnv (zip def.gArgs vs') $
                 deriveEquations t

            if Set.member (unLoc loc) h.shared' then
              localLoc loc $
              localAbs abs $
              localAbsEnv (abs, Loc loc) $
              localAbsHeap (loc, VNode tag vs' `mkUnion` Abs (fromMaybe __IMPOSSIBLE__ def.gReturn)) $
              localAbssEnv (zip def.gArgs vs') $
              deriveEquations t
            else
              pure h
      where
        findName defs FTag{tDef} = find ((==tDef) . gName) defs
        findName defs PTag{tDef} = find ((==tDef) . gName) defs
        findName _ _             = Nothing

        valToValue :: MonadReader HCxt m => Val -> m Value
        valToValue (Var n) = Abs . fromMaybe __IMPOSSIBLE__ <$> deBruijnLookup n
        valToValue (Lit _) = pure Bas
        valToValue  _      = __IMPOSSIBLE__

    Bind (App (Def "eval") [Var n]) (AltVar abs (Case 0 t alts)) ->
      deBruijnLookup n <&> EVAL . FETCH . Abs . fromMaybe __IMPOSSIBLE__ >>= \v ->
        localAbs abs $
        localAbsEnv (abs, v) $ do
          hs <- mapM (deriveEquationsAlt abs) alts
          h <- deriveEquations t
          pure $ foldl (<>) h hs
      where
        deriveEquationsAlt :: Abs -> Alt -> H' HRet
        deriveEquationsAlt abs (AltNode tag abss t) =
          localAbss abss $
          localAbssEnv (zip abss $ map (Pick (Abs abs) tag) [0 ..]) $
          deriveEquations t
        deriveEquationsAlt _ (AltEmpty t) = deriveEquations t
        deriveEquationsAlt _ AltVar{}     = __IMPOSSIBLE__ -- TODO investigate if this is possible (thesis indicate it is not)
        deriveEquationsAlt _ AltLit{}     = __IMPOSSIBLE__

    Bind (App (Def "eval") [Var _]) (AltNode tag [abs] (Case 0 t alts)) | tag == natTag ->
        localAbs abs $
        localAbsEnv (abs, Bas) $ do
          hs <- mapM deriveEquationsAlt alts
          h <- deriveEquations t
          pure $ foldl (<>) h hs
      where
        deriveEquationsAlt (AltLit _ t) = deriveEquations t
        deriveEquationsAlt (AltEmpty t) = deriveEquations t
        deriveEquationsAlt AltVar{}     = __IMPOSSIBLE__ -- TODO investigate if this is possible (thesis indicate it is not)
        deriveEquationsAlt AltNode{}    = __IMPOSSIBLE__

    Bind (App (Def "eval") [Var n]) (AltVar abs t) ->
      deBruijnLookup n <&> EVAL . FETCH . Abs . fromMaybe __IMPOSSIBLE__  >>= \v ->
        localAbs abs $
        localAbsEnv (abs, v) $
        deriveEquations t

    Bind (App (Def "eval") [Var _]) (AltNode tag [abs] t) | tag == natTag ->
      localAbs abs $
      localAbsEnv (abs, Bas) $
      deriveEquations t

    Bind (App (Def defName) vs) (AltVar abs t) -> do
      def <- asks $ fromMaybe __IMPOSSIBLE__ . find ((defName==) . gName) . defs
      mapM valToValue vs >>= \vs' ->
        localAbs abs $
        localAbsEnv (abs, maybe __IMPOSSIBLE__ Abs def.gReturn) $
        localAbssEnv (zip def.gArgs vs') $
        deriveEquations t
      where
        valToValue :: MonadReader HCxt m => Val -> m Value
        valToValue (Var n) = Abs . fromMaybe __IMPOSSIBLE__ <$> deBruijnLookup n
        valToValue (Lit _) = pure Bas
        valToValue  _      = __IMPOSSIBLE__

    Bind (App (Def defName) vs) (AltNode tag abss t) -> do
      def <- asks $ fromMaybe __IMPOSSIBLE__ . find ((defName==) . gName) . defs
      let gReturn = maybe __IMPOSSIBLE__ Abs def.gReturn
      mapM valToValue vs >>= \vs' ->
        localAbss abss $
        localAbssEnv (zip abss $ map (Pick gReturn tag) [0 ..]) $
        localAbssEnv (zip def.gArgs vs') $
        deriveEquations t
      where
        valToValue :: MonadReader HCxt m => Val -> m Value
        valToValue (Var n) = Abs . fromMaybe __IMPOSSIBLE__ <$> deBruijnLookup n
        valToValue (Lit _) = pure Bas
        valToValue  _      = __IMPOSSIBLE__


    Bind (App (Prim _) _) (AltVar abs t)  ->
      localAbs abs $
      localAbsEnv (abs, cnat) $
      deriveEquations t

    Bind (App (Prim _) _) (AltNode tag [abs] t) | tag == natTag ->
      localAbs abs $
      localAbsEnv (abs, Bas) $
      deriveEquations t

    Unit v -> do
        abs <- asks $ fromMaybe __IMPOSSIBLE__ . gReturn . currentDef
        v' <- valToValue v
        localAbs abs $ localAbsEnv (abs, v') retHCxt
      where
        valToValue :: MonadReader HCxt m => Val -> m Value
        valToValue (Var n) = Abs . fromMaybe __IMPOSSIBLE__ <$> deBruijnLookup n
        valToValue (Node tag vs) = VNode tag <$> mapM valToValue vs
        valToValue (Lit _) = pure Bas
        valToValue _ = __IMPOSSIBLE__

    App (Def "printf") _ -> retHCxt
    Error _ -> retHCxt

    t -> error $ "NOT IMPLEMENTED " ++ show t

retHCxt :: MonadReader HCxt m => m HRet
retHCxt =
  ask <&> \cxt ->
    HRet {absHeap' = cxt.absHeap, absEnv' = cxt.absEnv, shared' = cxt.shared}

deBruijnLookup :: MonadReader HCxt m => Int -> m (Maybe Abs)
deBruijnLookup n = asks $ (!!! n) . abss

data AbstractContext = AbstractContext
  { fHeap :: AbsHeap
  , fEnv  :: AbsEnv
  } deriving Eq

instance Pretty AbstractContext where
  pretty (AbstractContext {fHeap, fEnv}) =
    vcat
      [ text "Abstract heap:"
      , pretty fHeap
      , text "Abstract enviroment:"
      , pretty fEnv
      ]

instance Semigroup AbstractContext where
  cxt1 <> cxt2 = AbstractContext
    { fHeap = AbsHeap $ on unionNub (unAbsHeap . fHeap) cxt1 cxt2
    , fEnv = AbsEnv $ on unionNub (unAbsEnv . fEnv) cxt1 cxt2
    }

instance Monoid AbstractContext where
  mempty = AbstractContext{fHeap = AbsHeap [], fEnv = AbsEnv []}

solveEquations :: [GrinDefinition] -> AbstractContext -> AbstractContext
solveEquations defs AbstractContext{fHeap = AbsHeap heapEqs, fEnv = AbsEnv envEqs} =
    fix initAbstractContext
  where
    initAbstractContext :: AbstractContext
    initAbstractContext =
      let env =
            AbsEnv $ for (mapMaybe gReturn defs) $ \abs ->
              (abs, fromMaybe __IMPOSSIBLE__ $ envEqsLookup abs) in
      mempty{fEnv = env }

    envEqsLookup :: Abs -> Maybe Value
    envEqsLookup abs = lookup abs envEqs

    fix :: AbstractContext -> AbstractContext
    fix cxt
      | cxt == cxt' = cxt'
      | otherwise   = fix cxt'
      where
        cxt' =
          caseMaybe (nextEnvEq cxt) cxt $
            \entry -> fixCurrent $ addMissingEqs $ envInsert entry cxt

        fixCurrent :: AbstractContext -> AbstractContext
        fixCurrent cxt
          | cxt == cxt' = cxt'
          | otherwise = fixCurrent cxt'
          where
            -- Simplify and update each entry in abstract heap and enviroment
            cxt' =
              let cxt' =
                    foldl
                      (\cxt (l, v) -> absHeapUpdate l (simplify defs cxt v) cxt)
                      cxt
                      (unAbsHeap cxt.fHeap) in
              foldl
                (\cxt (x, v) -> absEnvUpdate x (simplify defs cxt v) cxt)
                cxt'
                (unAbsEnv cxt'.fEnv)

    -- | Returns the next missing abstract heap equation (e.g. `x21 → l4 ∪ l24`).
    nextEnvEq :: AbstractContext -> Maybe (Abs, Value)
    nextEnvEq =
      listToMaybe . differenceBy (on (==) fst) envEqs . unAbsEnv . fEnv

    -- | Adds missing equations that are referenced in the current equations.
    addMissingEqs :: AbstractContext -> AbstractContext
    addMissingEqs cxt
      | cxt == cxt' = cxt'
      | otherwise = addMissingEqs cxt'
      where
        cxt' =
          foldr (<>) cxt $
            mapMaybe (collectEqs cxt) $
              map snd (unAbsHeap cxt.fHeap) ++ map snd (unAbsEnv cxt.fEnv)

    -- | Collect all equations refererenced equations.
    collectEqs :: AbstractContext -> Value -> Maybe AbstractContext
    collectEqs cxt (Union v1 v2) = on (<>) (collectEqs cxt) v1 v2
    collectEqs cxt (Abs abs)
      | Just _ <- lookup abs (unAbsEnv cxt.fEnv) = Nothing
      | otherwise = Just $ AbstractContext {fHeap=AbsHeap [], fEnv = AbsEnv [(abs, v)]}
      where
        v = fromMaybe __IMPOSSIBLE__ $ lookup abs envEqs

    collectEqs cxt (Loc loc)
      | Just _ <- lookup loc (unAbsHeap cxt.fHeap) = Nothing
      | otherwise = Just $ AbstractContext {fHeap = AbsHeap [(loc, v)], fEnv = AbsEnv []}
      where
        v = fromMaybe __IMPOSSIBLE__ $ lookup loc heapEqs

    collectEqs cxt (FETCH v) = collectEqs cxt v
    collectEqs cxt (EVAL v1) =  collectEqs cxt v1
    collectEqs cxt (VNode _ vs) = foldl (<>) Nothing $ map (collectEqs cxt) vs
    collectEqs cxt (Pick v _ _) = collectEqs cxt v
    collectEqs _ Bas = Nothing

gatherEntriesBy1 :: Ord a => (b -> b -> b) -> List1 (a, b) -> List1 (a, b) -> List1 (a, b)
gatherEntriesBy1 f xs ys =
    List1.map (foldr1 (\(a, b1) (_, b2) -> (a, f b1 b2))) $
      List1.groupAllWith1 fst $ xs <> ys

simplify :: [GrinDefinition] -> AbstractContext -> Value -> Value
simplify defs AbstractContext{fHeap, fEnv} = go where

  envLookup :: Abs -> Maybe Value
  envLookup abs = lookup abs $ unAbsEnv fEnv

  heapLookup :: Loc -> Maybe Value
  heapLookup loc = lookup loc $ unAbsHeap fHeap

  defReturnLookup :: String -> Maybe Abs
  defReturnLookup name =
    firstJust (\def -> boolToMaybe (def.gName == name) $ fromMaybe __IMPOSSIBLE__ def.gReturn) defs

  go :: Value -> Value
  go (Loc loc) = Loc loc
  go Bas = Bas
  go (VNode tag vs) = VNode tag $ map go vs

  -- Replace with pointee
  go (Abs abs) = fromMaybe __IMPOSSIBLE__ $ envLookup abs

  go (Union v1 v2)
    -- Filter duplicates
    | v1 == v2 = v1

    -- Filter self references
    | (_:_:_, _) <- partition isSelfReference [v1, v2] = __IMPOSSIBLE__
    | (_:_, v3:v3s) <- partition isSelfReference [v1, v2] = listToValue (v3 :| v3s)

    -- Gather node values of same tag
    -- {... tag [v₁,...,vᵢ,...],...} ∪ {... tag [w₁,...,wᵢ,...],...} =
    -- {... tag [v₁ ∪ w₁,...,vᵢ ∪ wᵢ,...],...}
    | (n1:n1s, v1s) <- mapMaybeAndRest vnodeView $ valueToList v1
    , (n2:n2s, v2s) <- mapMaybeAndRest vnodeView $ valueToList v2
    , _:_ <- intersectBy (on (==) fst) (n1 : n1s) (n2 : n2s) =
      let nodes = gatherEntriesBy1 (zipWith mkUnion) (n1 :| n1s) (n2 :| n2s)
          nodes' = List1.map (uncurry VNode) nodes in
      listToValue $ v1s `List1.prependList` nodes' `List1.appendList` v2s

    -- Recurse
    | otherwise = on mkUnion go v1 v2

    where
      isSelfReference v1
        | Abs abs <- v1
        , Just v2 <- envLookup abs = v2 == Union v1 v2
        | otherwise = False

  go (Pick v1 tag1 i)
    | VNode tag2 vs <- v1
    , tag1 == tag2 = fromMaybe __IMPOSSIBLE__ $ vs !!! i
    | VNode{} <- v1 = __IMPOSSIBLE__

    -- Recurse
    | EVAL{} <- v1 = Pick (go v1) tag1 i
    | FETCH{} <- v1 = Pick (go v1) tag1 i
    | Pick{} <- v1 = Pick (go v1) tag1 i
    | Abs{} <- v1 = Pick (go v1) tag1 i

    -- Filter everything which is confirmed wrong
    | Union{} <- v1
    , (_:_, v2 : v2s) <- partition isWrong $ valueToList v1 =
      Pick (listToValue $ v2 :| v2s) tag1 i

    -- Solve correct tags
    | Union{} <- v1
    , (v2 : v2s, v3s) <- mapMaybeAndRest isCorrect $ valueToList v1 =
      caseList v3s
        (listToValue $ v2 :| v2s)
        (\v3 v3s ->
          listToValue (v2 :| v2s) `mkUnion` Pick (listToValue $ v3 :| v3s) tag1 i)

    -- Recurse (do not distribute!)
    -- {..., tag[v₁,...,vᵢ,...],...} ↓ tag ↓ i =  vᵢ
    | Union v2 v3 <- v1 = Pick (on mkUnion go v2 v3) tag1 i

    | Bas <- v1 = __IMPOSSIBLE__
    | Loc{} <- v1 = __IMPOSSIBLE__

    where
      isWrong (VNode tag2 _) = tag1 /= tag2
      isWrong Bas            = True
      isWrong Loc{}          = True
      isWrong EVAL{}         = False
      isWrong FETCH{}        = False
      isWrong Pick{}         = False
      isWrong Abs{}          = False
      isWrong Union{}        = False

      isCorrect (VNode tag2 vs) | tag1 == tag2 =
        Just $ fromMaybe __IMPOSSIBLE__ $ vs !!! i
      isCorrect _ = Nothing

  go (FETCH v1)
    | Loc loc <- v1 = fromMaybe __IMPOSSIBLE__ $ heapLookup loc

    -- Solve locations
    | Union{} <- v1
    , (loc : locs, v2s) <- mapMaybeAndRest isLocation $ valueToList v1 =
      let v3s = List1.map (fromMaybe __IMPOSSIBLE__ . heapLookup) $ loc :| locs in
      caseList v2s
        (listToValue v3s)
        (\v2 v2s -> listToValue v3s `mkUnion` FETCH (listToValue $ v2 :| v2s))

    -- Distribute FETCH
    | Union v2 v3 <- v1 = on mkUnion FETCH v2 v3

    -- Recurse
    | EVAL{} <- v1 = FETCH $ go v1
    | FETCH{} <- v1 = FETCH $ go v1
    | Pick{} <- v1 = FETCH $ go v1
    | Abs{} <- v1 = FETCH $ go v1

    | Bas <- v1 = __IMPOSSIBLE__
    | VNode{} <- v1 = __IMPOSSIBLE__

    where
      isLocation :: Value -> Maybe Loc
      isLocation (Loc loc) = Just loc
      isLocation _         = Nothing

  go (EVAL v1)
    | VNode CTag{} _ <- v1 = v1

    -- Solve with return variable for known functions, and Cnat for primitives
    | VNode FTag{tDef} _ <- v1 =
      maybe cnat Abs $ defReturnLookup tDef
    | VNode PTag{tDef} _ <- v1 =
      maybe cnat Abs $ defReturnLookup tDef

    -- Solve C nodes
    | Union{} <- v1
    , (v2:v2s, v3s) <- mapMaybeAndRest isCNode $ valueToList v1 =
      caseList v3s
        (listToValue $ v2 :| v2s)
        (\v3 v3s -> listToValue (v2 :| v2s) `mkUnion` EVAL (listToValue $ v3 :| v3s))

    -- Solve F and P nodes
    | Union{} <- v1
    , (v2 : v2s, v3s) <- mapMaybeAndRest hasDefName $ valueToList v1 =
      let v2s' = List1.map (maybe cnat Abs . defReturnLookup) (v2 :| v2s) in
      caseList v3s
        (listToValue v2s')
        (\v3 v3s -> listToValue v2s' `mkUnion` EVAL (listToValue $ v3 :| v3s))

    -- Distribute
    | Union v2 v3 <- v1 = on mkUnion EVAL v2 v3

    -- Recurse
    | EVAL{} <- v1 = EVAL $ go v1
    | FETCH{} <- v1 = EVAL $ go v1
    | Pick{} <- v1 = EVAL $ go v1
    | Abs{} <- v1 = EVAL $ go v1


    | Bas <- v1 = __IMPOSSIBLE__
    | Loc{} <- v1 = __IMPOSSIBLE__

    where
      isCNode (VNode tag@CTag{} vs) = Just $ VNode tag vs
      isCNode _                     = Nothing

      hasDefName (VNode PTag{tDef} _) = Just tDef
      hasDefName (VNode FTag{tDef} _) = Just tDef
      hasDefName _                    = Nothing

absHeapUpdate :: Loc -> Value -> AbstractContext -> AbstractContext
absHeapUpdate loc v cxt =
    cxt{fHeap = AbsHeap heap}
  where
    heap = for (unAbsHeap cxt.fHeap) $
      \(loc', v') -> if loc == loc' then (loc', v) else (loc', v')

absEnvUpdate :: Abs -> Value -> AbstractContext -> AbstractContext
absEnvUpdate abs v cxt =
    cxt{fEnv = AbsEnv env}
  where
    env = for (unAbsEnv cxt.fEnv) $
      \(abs', v') -> if abs == abs' then (abs', v) else (abs', v')

envInsert :: (Abs, Value) -> AbstractContext -> AbstractContext
envInsert entry cxt = cxt{fEnv = AbsEnv $ insert entry $ unAbsEnv cxt.fEnv}

valueToList :: Value -> [Value]
valueToList (Union a b) = on (++) valueToList a b
valueToList a           = [a]

listToValue :: List1 Value -> Value
listToValue = foldr1 mkUnion

cnat :: Value
cnat = VNode natTag [Bas]

natTag :: Tag
natTag = CTag{tTag = 0, tCon = "nat" , tArity = 1}