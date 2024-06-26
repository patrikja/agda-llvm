{-# LANGUAGE ViewPatterns #-}
{-# LANGUAGE OverloadedRecordDot #-}
{-# LANGUAGE BlockArguments #-}

module Compiler.Treeless.TreelessTransform
  ( definitionToTreeless
  , TreelessDefinition(..)
  ) where

import           Control.Monad                         (when, zipWithM, (<=<), (>=>))
import           Control.Monad.IO.Class                (MonadIO (liftIO))
import           Data.Function                         (on)

import           Agda.Compiler.Backend                 hiding (Prim, initEnv)
import           Agda.Compiler.MAlonzo.HaskellTypes    (hsTelApproximation)
import           Agda.Compiler.Treeless.Builtin        (translateBuiltins)
import           Agda.Compiler.Treeless.NormalizeNames (normalizeNames)
import           Agda.Syntax.Common.Pretty
import           Agda.Syntax.Internal                  (Type, arity)
import qualified Agda.Syntax.Internal                  as I
import           Agda.Syntax.Parser.Parser             (splitOnDots)
import           Agda.TypeChecking.Substitute
import           Agda.Utils.Functor
import           Agda.Utils.Impossible
import           Agda.Utils.List1             (List1, pattern (:|), (<|))
import qualified Agda.Utils.List1             as List1
import           Agda.Utils.List                       (downFrom, lastMaybe,
                                                        snoc)
import           Agda.Utils.Maybe
import           Agda.Utils.Monad                      (mapMM)
import           Data.Bitraversable                    (bimapM)
import           Data.List                             (mapAccumR)
import           Data.Tuple.Extra                      (first, firstM, second)
import Agda.Compiler.ToTreeless (closedTermToTreeless)
import Control.Applicative (Applicative(liftA2))
import Debug.Trace
import Agda.Utils.Function (applyWhen)

import           Compiler.Grin.Grin                        (getShortName)
import           Utils.Utils

data TreelessDefinition = TreelessDefinition
  { tl_name      :: String
  , tl_isMain    :: Bool
  , tl_arity     :: Int
  , tl_type      :: Type
  , tl_term      :: TTerm
  , tl_primitive :: Maybe TPrim
  }

instance Pretty TreelessDefinition where
  pretty TreelessDefinition{tl_name, tl_arity, tl_type, tl_term} =
    vcat
      [ pretty tl_name <+> text ":" <+> pretty tl_type
      , pretty tl_name <+> prettyList_ (take tl_arity ['a' ..]) <+>
        text "=" <+> pretty tl_term
      ]

-- | Rewrap primitives so they can be used lazily
wrapPrimitives :: TTerm -> TCM TTerm
wrapPrimitives (TPrim PAdd) = primNatPlus >>= closedTermToTreeless LazyEvaluation 
wrapPrimitives (TPrim PSub) = primNatMinus >>= closedTermToTreeless LazyEvaluation 
wrapPrimitives (TPrim PMul) = primNatTimes >>= closedTermToTreeless LazyEvaluation 
wrapPrimitives (TLet t1 t2) = liftA2 TLet (wrapPrimitives t1) (wrapPrimitives t2)
wrapPrimitives (TApp t ts) = liftA2 TApp (wrapPrimitives t) (mapM wrapPrimitives ts)
wrapPrimitives (TLam t) = TLam <$> wrapPrimitives t
wrapPrimitives (TCase n info t alts) = liftA2 (TCase n info) (wrapPrimitives t) (mapM step alts)
  where
  step :: TAlt -> TCM TAlt
  step (TACon q n t) = TACon q n <$> wrapPrimitives t
  step (TALit lit t) = TALit lit <$> wrapPrimitives t
  step (TAGuard t1 t2) = liftA2 TAGuard (wrapPrimitives t1) (wrapPrimitives t2)
wrapPrimitives t = pure t

definitionToTreeless :: IsMain -> Definition -> TCM (Maybe TreelessDefinition)
definitionToTreeless isMainModule Defn{defName, defType, theDef=theDef@Function{funCompiled = Just cc}} = 
  caseMaybeM (toTreeless LazyEvaluation defName) (pure Nothing) \t ->  do 
    -- traceM ("\n" ++ prettyShow defName ++ " theDef:\n" ++ prettyShow theDef)
    -- traceM ("\n" ++ prettyShow defName ++ " info:\n\n" ++ show theDef)
    -- traceM ("\n" ++ prettyShow defName ++ " to treeless:\n" ++ prettyShow t)
    -- traceM ("toTreeless: \n" ++ prettyShow t) 
    -- TODO turn back simplify in /agda (And only modify for seq) so it removes let a = b in...
    t' <- wrapPrimitives =<< normalizeNames t
    -- traceM ("insert: \n" ++ prettyShow t') 
    let ta = insertLets $ skipLambdas t'
    let t'' = normalizeLets'' ta
    --traceM ("\n\nnormalizeLets: \n" ++ prettyShow t'') 
    pure $ Just $ TreelessDefinition
      { tl_name      = prettyShow defName
      , tl_isMain    = isMain
      , tl_arity     = arity defType
      , tl_type      = defType
      , tl_term      = t''
      , tl_primitive = Nothing
      }
  where
  isMain = isMainModule == IsMain && "main" == (prettyShow . nameConcrete . qnameName) defName

-- Create definitions for builtin functions so they can be used lazily.
definitionToTreeless _ Defn{defName, defType, theDef=Primitive{}} = do
    builtins <- mapM (firstM getBuiltin)
      [ (builtinNatPlus,  PAdd)
      , (builtinNatMinus, PSub)
      ]
    pure $ lookup (I.Def defName []) builtins <&> mkTreelessDef <*> skipLambdas . mkPrimApp
  where
    mkPrimApp prim =
      mkTLam defArity $ mkTApp (TPrim prim) $ map TVar $ downFrom defArity

    mkTreelessDef prim term = TreelessDefinition
      { tl_name      = prettyShow defName
      , tl_isMain    = False
      , tl_arity     = defArity
      , tl_type      = defType
      , tl_term      = term
      , tl_primitive = Just prim
      }

    defArity = arity defType

definitionToTreeless _ _ = pure Nothing

-- | Skip initial lambdas
skipLambdas :: TTerm -> TTerm
skipLambdas (TLam t) = skipLambdas t
skipLambdas t        = t

data LetSplit = LetSplit 
  { left    :: [TTerm]
  , letLhss :: List1 TTerm
  , letRhs  :: TTerm
  , right   :: [TTerm] }
  deriving Show

splitOnLet :: [TTerm] -> Maybe LetSplit
splitOnLet (t : ts)  
  | (l : ls, r) <- tLetView t = 
    Just LetSplit 
      { left = []
      , letLhss = l :| ls 
      , letRhs = r
      , right = ts }
  | otherwise = splitOnLet ts <&> \x -> x{left = t : x.left}
splitOnLet [] = Nothing

mkSplit :: [TTerm] -> Maybe LetSplit
mkSplit = splitOnLet . map normalizeLets 



-- f a 
--   (let b'' = g (let b' = i b in b') in b'') 
--   (let c' = h c in c')
-- >>>
-- let b' = i b 
--     b'' = g b' 
--     c' = h c in 
-- f a b'' c'
normalizeLets :: TTerm -> TTerm
normalizeLets (TLet (TLet t1 t2) t3) = 
  normalizeLets $ TLet t1 $ TLet t2 $ raiseFrom 1 1 t3
normalizeLets (TLet t1 t2) = on TLet normalizeLets t1 t2
normalizeLets (TApp t (mkSplit -> Just split)) = 
  normalizeLets $ foldr TLet (TApp t' ts') split.letLhss
  where
  raiseN :: Subst a => a -> a
  raiseN = raise (length split.letLhss)
  t' = raiseN $ normalizeLets t
  ts' = raiseN split.left ++ [split.letRhs] ++ raiseN split.right
normalizeLets (TApp (TLet t1 t2) ts) = TLet t1 (TApp t2 $ raise 1 ts)
normalizeLets (TCase n info t alts) = 
  TCase n info (normalizeLets t) (map step alts)
  where
  step (TACon q a t) = TACon q a (normalizeLets t)
  step (TALit l t) = TALit l (normalizeLets t)
  step (TAGuard t1 t2) = on TAGuard normalizeLets t1 t2
                                               -- ^ not sure about this

normalizeLets (TLam t) = TLam (normalizeLets t)
normalizeLets t = t

normalizeLets'' t 
  | t == t' = t'
  | otherwise = normalizeLets'' t'
  where 
  t' = normalizeLets t


-- p = TPrim PLt
-- f x y z = TApp (TPrim PAdd) [x , y , z]
-- g x = TApp p [x]
-- h = g
-- i = g
--
-- a = TVar 10
-- b = TVar 11
-- c = TVar 12
--
-- ex1 = f (TLet (g a) $ TVar 0) b c
-- ex2 = f (TLet (g a) $ TLet (h $ TVar 0) $ TVar 0) b c



-- | Simplify complicated applications
--
-- f a (g b) (h c)
-- >>>
-- let b' = g b in
-- let c' = h c in
-- f a b' c'
--
-- The only exception is PSeq which is not simplified.


--
-- f a (g (i b)) (h c)
-- >>>
-- f a 
--   (let b'' = g (let b' = i b in b') in b'') 
--   (let c' = h c in c')
--
-- let b' = i b 
--     b'' = g b' 
--     c' = h c in 
-- f a b'' c'


-- insertLets' :: Bool -> TTerm -> TTerm
-- insertLets' True (TApp (TPrim PSeq) (TVar n : TApp f [TVar n'] : xs)) = 
--   -- TLet (TApp (TPrim PSeq) (TVar n : TApp


-- The x in @seq x f x y z@ are always equal and a variable


letWrap :: TTerm -> TTerm
letWrap t = TLet t $ TVar 0

insertLets' p (TApp (TPrim PSeq) (x : f : xs)) = 
  applyWhen p letWrap $ TApp (TPrim PSeq) $ x : f' : xs'
  where
  f' = insertLets' False f
  xs' = map (insertLets' True) xs
insertLets' p (TApp t ts) = applyWhen p letWrap $ TApp t $ map (insertLets' True) ts
insertLets' p (TCon q) = applyWhen p letWrap $ TCon q
insertLets' p (TLit lit) = applyWhen p letWrap $ TLit lit
insertLets' _ (TVar n) = TVar n
insertLets' _ (TDef q) = TDef q
insertLets' _ (TLam _) = __IMPOSSIBLE__
insertLets' _ (TError e) = TError e
insertLets' _ TErased = TErased 
insertLets' _ (TPrim p) = TPrim p
insertLets' p (TLet t1 t2) = TLet (insertLets' False t1) (insertLets' p t2)
insertLets' p (TCase n info t alts) = 
  applyWhen p letWrap $ TCase n info t' $ map step alts 
  where 
  t' = insertLets' False t
  step :: TAlt -> TAlt
  step (TACon q n t) = TACon q n $ insertLets' False t
  step (TALit lit t) = TALit lit $ insertLets' False t
  -- Guards are always strict 
  -- TODO fix when nested applications
  step (TAGuard t1 t2) = TAGuard t1 $ insertLets' False t2
                                       -- ^ not sure about this
insertLets' _ t = error $ "insertLets': " ++ prettyShow t

insertLets :: TTerm -> TTerm
insertLets = insertLets' False

