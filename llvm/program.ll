target triple = "x86_64-unknown-linux-gnu"
declare void @printf(ptr, ...)
declare ptr @malloc(i64)
declare void @free(ptr)
%Node = type [4 x i64]
@"%d" = private constant [4 x i8] c"%d\0A\00", align 1
@"HERE" = private constant [9 x i8] c"HERE %d\0A\00", align  1
@"sum" = private constant [9 x i8] c"sum: %d\0A\00", align  1
@"downFrom" = private constant [14 x i8] c"downFrom: %d\0A\00", align 1
@"_-_" = private constant [9 x i8] c"_-_: %d\0A\00", align 1
@"_+_" = private constant [9 x i8] c"_+_: %d\0A\00", align 1
@"rc: %d" = private constant [9 x i8] c"rc: %d A ", align 1
@"tag: %d" = private constant [10 x i8] c"tag: %d A ", align 1


; Tag numbering table:
; 0 Cnat
; 1 FAgda.Builtin.Nat._-_
; 2 CUpTo.List._∷_
; 3 CUpTo.List.[]
; 4 FUpTo.upTo
; 5 FAgda.Builtin.Nat._+_

define fastcc %Node
@"UpTo.upTo"(i64 %x7, i64 %x8){
    %1 = inttoptr i64 %x8 to ptr
    %2 = getelementptr inbounds %Node, ptr %1, i32 0, i64 1
    %x88 = load i64, ptr %2
    switch i64 %x88, label %"L1-default" [i64 0, label %"L2-Cnat"
                                          i64 1, label %"L3-FAgda.Builtin.Nat._-_"]
        "L1-default":
            unreachable
        "L2-Cnat":
            %3 = inttoptr i64 %x8 to ptr
            %4 = getelementptr inbounds %Node, ptr %3, i32 0, i64 2
            %x122 = load i64, ptr %4
            %5 = insertvalue %Node undef, i64 0, 1
            %"L2-result-Cnat" = insertvalue %Node %5, i64 %x122, 2
            br label %"L0-continue"
        "L3-FAgda.Builtin.Nat._-_":
            %6 = inttoptr i64 %x8 to ptr
            %7 = getelementptr inbounds %Node, ptr %6, i32 0, i64 2
            %x124 = load i64, ptr %7
            %8 = inttoptr i64 %x8 to ptr
            %9 = getelementptr inbounds %Node, ptr %8, i32 0, i64 3
            %x123 = load i64, ptr %9
            %10 = call fastcc %Node @"Agda.Builtin.Nat._-_"(i64 %x124, i64 %x123)
            %x84 = extractvalue %Node %10, 2
            %11 = inttoptr i64 %x8 to ptr
            %12 = getelementptr inbounds %Node, ptr %11, i32 0, i64 0
            %13 = load i64, ptr %12
            %14 = insertvalue %Node undef, i64 0, 1
            %15 = insertvalue %Node %14, i64 %x84, 2
            %16 = insertvalue %Node %15, i64 %13, 0
            store %Node %16, ptr %11
            %17 = insertvalue %Node undef, i64 0, 1
            %"L3-result-FAgda.Builtin.Nat._-_" = insertvalue %Node %17, i64 %x84, 2
            br label %"L0-continue"
    "L0-continue":
    %18 = phi %Node  [%"L2-result-Cnat", %"L2-Cnat"]
                   , [%"L3-result-FAgda.Builtin.Nat._-_", %"L3-FAgda.Builtin.Nat._-_"]
    %x6 = extractvalue %Node %18, 2
    switch i64 %x6, label %"L5-default" [i64 0, label %"L6-0"]
        "L5-default":
            %19 = insertvalue %Node undef, i64 0, 1
            %20 = insertvalue %Node %19, i64 1, 2
            %21 = insertvalue %Node %20, i64 1, 0
            %22 = call fastcc ptr @malloc(i64 32)
            store %Node %21, ptr %22
            %x5 = ptrtoint ptr %22 to i64
            %23 = insertvalue %Node undef, i64 1, 1
            %24 = insertvalue %Node %23, i64 %x8, 2
            %25 = insertvalue %Node %24, i64 %x5, 3
            %26 = insertvalue %Node %25, i64 1, 0
            %27 = call fastcc ptr @malloc(i64 32)
            store %Node %26, ptr %27
            %x4 = ptrtoint ptr %27 to i64
            %28 = inttoptr i64 %x4 to ptr
            %29 = getelementptr inbounds %Node, ptr %28, i32 0, i64 0
            %30 = load i64, ptr %29
            %31 = add i64 %30, 1
            store i64 %31, ptr %29
            %32 = insertvalue %Node undef, i64 2, 1
            %33 = insertvalue %Node %32, i64 %x4, 2
            %34 = insertvalue %Node %33, i64 %x7, 3
            %35 = insertvalue %Node %34, i64 1, 0
            %36 = call fastcc ptr @malloc(i64 32)
            store %Node %35, ptr %36
            %x3 = ptrtoint ptr %36 to i64
            %"L5-result-default" = call fastcc %Node @"UpTo.upTo"(i64 %x3, i64 %x4)
            br label %"L4-continue"
        "L6-0":
            call fastcc void @"drop"(i64 %x8)
            %37 = inttoptr i64 %x7 to ptr
            %38 = getelementptr inbounds %Node, ptr %37, i32 0, i64 1
            %x85 = load i64, ptr %38
            switch i64 %x85, label %"L8-default" [i64 3, label %"L9-CUpTo.List.[]"
                                                  i64 2, label %"L10-CUpTo.List._∷_"]
                "L8-default":
                    unreachable
                "L9-CUpTo.List.[]":
                    call fastcc void @"drop"(i64 %x7)
                    %"L9-result-CUpTo.List.[]" = insertvalue %Node undef, i64 3, 1
                    br label %"L7-continue"
                "L10-CUpTo.List._∷_":
                    %39 = inttoptr i64 %x7 to ptr
                    %40 = getelementptr inbounds %Node, ptr %39, i32 0, i64 2
                    %x126 = load i64, ptr %40
                    %41 = inttoptr i64 %x7 to ptr
                    %42 = getelementptr inbounds %Node, ptr %41, i32 0, i64 3
                    %x125 = load i64, ptr %42
                    %43 = inttoptr i64 %x126 to ptr
                    %44 = getelementptr inbounds %Node, ptr %43, i32 0, i64 0
                    %45 = load i64, ptr %44
                    %46 = add i64 %45, 1
                    store i64 %46, ptr %44
                    %47 = inttoptr i64 %x125 to ptr
                    %48 = getelementptr inbounds %Node, ptr %47, i32 0, i64 0
                    %49 = load i64, ptr %48
                    %50 = add i64 %49, 1
                    store i64 %50, ptr %48
                    call fastcc void @"drop"(i64 %x7)
                    %51 = insertvalue %Node undef, i64 2, 1
                    %52 = insertvalue %Node %51, i64 %x126, 2
                    %"L10-result-CUpTo.List._∷_" = insertvalue %Node %52, i64 %x125, 3
                    br label %"L7-continue"
            "L7-continue":
            %"L6-result-0" = phi %Node  [%"L9-result-CUpTo.List.[]", %"L9-CUpTo.List.[]"]
                                      , [%"L10-result-CUpTo.List._∷_", %"L10-CUpTo.List._∷_"]
            br label %"L4-continue"
    "L4-continue":
    %x168 = phi %Node  [%"L5-result-default", %"L5-default"]
                     , [%"L6-result-0", %"L7-continue"]
    ret %Node %x168
}

define fastcc %Node
@"UpTo.sum"(i64 %x15, i64 %x16){
    %1 = inttoptr i64 %x16 to ptr
    %2 = getelementptr inbounds %Node, ptr %1, i32 0, i64 1
    %x102 = load i64, ptr %2
    switch i64 %x102, label %"L1-default" [i64 3, label %"L2-CUpTo.List.[]"
                                           i64 2, label %"L3-CUpTo.List._∷_"
                                           i64 4, label %"L4-FUpTo.upTo"]
        "L1-default":
            unreachable
        "L2-CUpTo.List.[]":
            %"L2-result-CUpTo.List.[]" = insertvalue %Node undef, i64 3, 1
            br label %"L0-continue"
        "L3-CUpTo.List._∷_":
            %3 = inttoptr i64 %x16 to ptr
            %4 = getelementptr inbounds %Node, ptr %3, i32 0, i64 2
            %x128 = load i64, ptr %4
            %5 = inttoptr i64 %x16 to ptr
            %6 = getelementptr inbounds %Node, ptr %5, i32 0, i64 3
            %x127 = load i64, ptr %6
            %7 = inttoptr i64 %x128 to ptr
            %8 = getelementptr inbounds %Node, ptr %7, i32 0, i64 0
            %9 = load i64, ptr %8
            %10 = add i64 %9, 1
            store i64 %10, ptr %8
            %11 = inttoptr i64 %x127 to ptr
            %12 = getelementptr inbounds %Node, ptr %11, i32 0, i64 0
            %13 = load i64, ptr %12
            %14 = add i64 %13, 1
            store i64 %14, ptr %12
            %15 = insertvalue %Node undef, i64 2, 1
            %16 = insertvalue %Node %15, i64 %x128, 2
            %"L3-result-CUpTo.List._∷_" = insertvalue %Node %16, i64 %x127, 3
            br label %"L0-continue"
        "L4-FUpTo.upTo":
            %17 = inttoptr i64 %x16 to ptr
            %18 = getelementptr inbounds %Node, ptr %17, i32 0, i64 2
            %x130 = load i64, ptr %18
            %19 = inttoptr i64 %x16 to ptr
            %20 = getelementptr inbounds %Node, ptr %19, i32 0, i64 3
            %x129 = load i64, ptr %20
            %21 = call fastcc %Node @"UpTo.upTo"(i64 %x130, i64 %x129)
            %x91 = extractvalue %Node %21, 1
            %x92 = extractvalue %Node %21, 2
            %x93 = extractvalue %Node %21, 3
            switch i64 %x91, label %"L6-default" [i64 3, label %"L7-CUpTo.List.[]"
                                                  i64 2, label %"L8-CUpTo.List._∷_"]
                "L6-default":
                    unreachable
                "L7-CUpTo.List.[]":
                    %22 = inttoptr i64 %x16 to ptr
                    %23 = getelementptr inbounds %Node, ptr %22, i32 0, i64 0
                    %24 = load i64, ptr %23
                    %25 = insertvalue %Node undef, i64 3, 1
                    %26 = insertvalue %Node %25, i64 %24, 0
                    store %Node %26, ptr %22
                    br label %"L5-continue"
                "L8-CUpTo.List._∷_":
                    %27 = inttoptr i64 %x92 to ptr
                    %28 = getelementptr inbounds %Node, ptr %27, i32 0, i64 0
                    %29 = load i64, ptr %28
                    %30 = add i64 %29, 1
                    store i64 %30, ptr %28
                    %31 = inttoptr i64 %x93 to ptr
                    %32 = getelementptr inbounds %Node, ptr %31, i32 0, i64 0
                    %33 = load i64, ptr %32
                    %34 = add i64 %33, 1
                    store i64 %34, ptr %32
                    %35 = inttoptr i64 %x16 to ptr
                    %36 = getelementptr inbounds %Node, ptr %35, i32 0, i64 0
                    %37 = load i64, ptr %36
                    %38 = insertvalue %Node undef, i64 2, 1
                    %39 = insertvalue %Node %38, i64 %x92, 2
                    %40 = insertvalue %Node %39, i64 %x93, 3
                    %41 = insertvalue %Node %40, i64 %37, 0
                    store %Node %41, ptr %35
                    br label %"L5-continue"
            "L5-continue":
            %42 = insertvalue %Node undef, i64 %x91, 1
            %43 = insertvalue %Node %42, i64 %x92, 2
            %"L4-result-FUpTo.upTo" = insertvalue %Node %43, i64 %x93, 3
            br label %"L0-continue"
    "L0-continue":
    %44 = phi %Node  [%"L2-result-CUpTo.List.[]", %"L2-CUpTo.List.[]"]
                   , [%"L3-result-CUpTo.List._∷_", %"L3-CUpTo.List._∷_"]
                   , [%"L4-result-FUpTo.upTo", %"L5-continue"]
    %x99 = extractvalue %Node %44, 1
    %x100 = extractvalue %Node %44, 2
    %x101 = extractvalue %Node %44, 3
    call fastcc void @"drop"(i64 %x16)
    switch i64 %x99, label %"L10-default" [i64 3, label %"L11-CUpTo.List.[]"
                                           i64 2, label %"L16-CUpTo.List._∷_"]
        "L10-default":
            unreachable
        "L11-CUpTo.List.[]":
            %45 = inttoptr i64 %x15 to ptr
            %46 = getelementptr inbounds %Node, ptr %45, i32 0, i64 1
            %x96 = load i64, ptr %46
            switch i64 %x96, label %"L13-default" [i64 0, label %"L14-Cnat"
                                                   i64 5, label %"L15-FAgda.Builtin.Nat._+_"]
                "L13-default":
                    unreachable
                "L14-Cnat":
                    %47 = inttoptr i64 %x15 to ptr
                    %48 = getelementptr inbounds %Node, ptr %47, i32 0, i64 2
                    %x131 = load i64, ptr %48
                    call fastcc void @"drop"(i64 %x15)
                    %49 = insertvalue %Node undef, i64 0, 1
                    %"L14-result-Cnat" = insertvalue %Node %49, i64 %x131, 2
                    br label %"L12-continue"
                "L15-FAgda.Builtin.Nat._+_":
                    %50 = inttoptr i64 %x15 to ptr
                    %51 = getelementptr inbounds %Node, ptr %50, i32 0, i64 2
                    %x133 = load i64, ptr %51
                    %52 = inttoptr i64 %x15 to ptr
                    %53 = getelementptr inbounds %Node, ptr %52, i32 0, i64 3
                    %x132 = load i64, ptr %53
                    %54 = call fastcc %Node @"Agda.Builtin.Nat._+_"(i64 %x133, i64 %x132)
                    %x95 = extractvalue %Node %54, 2
                    %55 = inttoptr i64 %x15 to ptr
                    %56 = getelementptr inbounds %Node, ptr %55, i32 0, i64 0
                    %57 = load i64, ptr %56
                    %58 = insertvalue %Node undef, i64 0, 1
                    %59 = insertvalue %Node %58, i64 %x95, 2
                    %60 = insertvalue %Node %59, i64 %57, 0
                    store %Node %60, ptr %55
                    call fastcc void @"drop"(i64 %x15)
                    %61 = insertvalue %Node undef, i64 0, 1
                    %"L15-result-FAgda.Builtin.Nat._+_" = insertvalue %Node %61, i64 %x95, 2
                    br label %"L12-continue"
            "L12-continue":
            %"L11-result-CUpTo.List.[]" = phi %Node  [%"L14-result-Cnat", %"L14-Cnat"]
                                                   , [%"L15-result-FAgda.Builtin.Nat._+_", %"L15-FAgda.Builtin.Nat._+_"]
            br label %"L9-continue"
        "L16-CUpTo.List._∷_":
            %62 = insertvalue %Node undef, i64 5, 1
            %63 = insertvalue %Node %62, i64 %x15, 2
            %64 = insertvalue %Node %63, i64 %x100, 3
            %65 = insertvalue %Node %64, i64 1, 0
            %66 = call fastcc ptr @malloc(i64 32)
            store %Node %65, ptr %66
            %x11 = ptrtoint ptr %66 to i64
            %"L16-result-CUpTo.List._∷_" = call fastcc %Node @"UpTo.sum"(i64 %x11, i64 %x101)
            br label %"L9-continue"
    "L9-continue":
    %x169 = phi %Node  [%"L11-result-CUpTo.List.[]", %"L12-continue"]
                     , [%"L16-result-CUpTo.List._∷_", %"L16-CUpTo.List._∷_"]
    ret %Node %x169
}

define fastcc void
@main(){
    %1 = insertvalue %Node undef, i64 0, 1
    %2 = insertvalue %Node %1, i64 0, 2
    %3 = insertvalue %Node %2, i64 1, 0
    %4 = call fastcc ptr @malloc(i64 32)
    store %Node %3, ptr %4
    %x26 = ptrtoint ptr %4 to i64
    %5 = insertvalue %Node undef, i64 3, 1
    %6 = insertvalue %Node %5, i64 1, 0
    %7 = call fastcc ptr @malloc(i64 32)
    store %Node %6, ptr %7
    %x25 = ptrtoint ptr %7 to i64
    %8 = insertvalue %Node undef, i64 0, 1
    %9 = insertvalue %Node %8, i64 101, 2
    %10 = insertvalue %Node %9, i64 1, 0
    %11 = call fastcc ptr @malloc(i64 32)
    store %Node %10, ptr %11
    %x24 = ptrtoint ptr %11 to i64
    %12 = insertvalue %Node undef, i64 4, 1
    %13 = insertvalue %Node %12, i64 %x25, 2
    %14 = insertvalue %Node %13, i64 %x24, 3
    %15 = insertvalue %Node %14, i64 1, 0
    %16 = call fastcc ptr @malloc(i64 32)
    store %Node %15, ptr %16
    %x23 = ptrtoint ptr %16 to i64
    %17 = call fastcc %Node @"UpTo.sum"(i64 %x26, i64 %x23)
    %x22 = extractvalue %Node %17, 2
    call fastcc void @printf(ptr @"%d", i64 %x22)
    ret void
}

define fastcc %Node
@"Agda.Builtin.Nat._+_"(i64 %x31, i64 %x32){
    %1 = inttoptr i64 %x31 to ptr
    %2 = getelementptr inbounds %Node, ptr %1, i32 0, i64 1
    %x112 = load i64, ptr %2
    switch i64 %x112, label %"L1-default" [i64 0, label %"L2-Cnat"
                                           i64 5, label %"L3-FAgda.Builtin.Nat._+_"]
        "L1-default":
            unreachable
        "L2-Cnat":
            %3 = inttoptr i64 %x31 to ptr
            %4 = getelementptr inbounds %Node, ptr %3, i32 0, i64 2
            %x134 = load i64, ptr %4
            %5 = insertvalue %Node undef, i64 0, 1
            %"L2-result-Cnat" = insertvalue %Node %5, i64 %x134, 2
            br label %"L0-continue"
        "L3-FAgda.Builtin.Nat._+_":
            %6 = inttoptr i64 %x31 to ptr
            %7 = getelementptr inbounds %Node, ptr %6, i32 0, i64 2
            %x136 = load i64, ptr %7
            %8 = inttoptr i64 %x31 to ptr
            %9 = getelementptr inbounds %Node, ptr %8, i32 0, i64 3
            %x135 = load i64, ptr %9
            %10 = call fastcc %Node @"Agda.Builtin.Nat._+_"(i64 %x136, i64 %x135)
            %x106 = extractvalue %Node %10, 2
            %11 = inttoptr i64 %x31 to ptr
            %12 = getelementptr inbounds %Node, ptr %11, i32 0, i64 0
            %13 = load i64, ptr %12
            %14 = insertvalue %Node undef, i64 0, 1
            %15 = insertvalue %Node %14, i64 %x106, 2
            %16 = insertvalue %Node %15, i64 %13, 0
            store %Node %16, ptr %11
            %17 = insertvalue %Node undef, i64 0, 1
            %"L3-result-FAgda.Builtin.Nat._+_" = insertvalue %Node %17, i64 %x106, 2
            br label %"L0-continue"
    "L0-continue":
    %18 = phi %Node  [%"L2-result-Cnat", %"L2-Cnat"]
                   , [%"L3-result-FAgda.Builtin.Nat._+_", %"L3-FAgda.Builtin.Nat._+_"]
    %x28 = extractvalue %Node %18, 2
    call fastcc void @"drop"(i64 %x31)
    %19 = inttoptr i64 %x32 to ptr
    %20 = getelementptr inbounds %Node, ptr %19, i32 0, i64 1
    %x109 = load i64, ptr %20
    switch i64 %x109, label %"L5-default" [i64 0, label %"L6-Cnat"
                                           i64 1, label %"L7-FAgda.Builtin.Nat._-_"]
        "L5-default":
            unreachable
        "L6-Cnat":
            %21 = inttoptr i64 %x32 to ptr
            %22 = getelementptr inbounds %Node, ptr %21, i32 0, i64 2
            %x137 = load i64, ptr %22
            %23 = insertvalue %Node undef, i64 0, 1
            %"L6-result-Cnat" = insertvalue %Node %23, i64 %x137, 2
            br label %"L4-continue"
        "L7-FAgda.Builtin.Nat._-_":
            %24 = inttoptr i64 %x32 to ptr
            %25 = getelementptr inbounds %Node, ptr %24, i32 0, i64 2
            %x139 = load i64, ptr %25
            %26 = inttoptr i64 %x32 to ptr
            %27 = getelementptr inbounds %Node, ptr %26, i32 0, i64 3
            %x138 = load i64, ptr %27
            %28 = call fastcc %Node @"Agda.Builtin.Nat._-_"(i64 %x139, i64 %x138)
            %x108 = extractvalue %Node %28, 2
            %29 = inttoptr i64 %x32 to ptr
            %30 = getelementptr inbounds %Node, ptr %29, i32 0, i64 0
            %31 = load i64, ptr %30
            %32 = insertvalue %Node undef, i64 0, 1
            %33 = insertvalue %Node %32, i64 %x108, 2
            %34 = insertvalue %Node %33, i64 %31, 0
            store %Node %34, ptr %29
            %35 = insertvalue %Node undef, i64 0, 1
            %"L7-result-FAgda.Builtin.Nat._-_" = insertvalue %Node %35, i64 %x108, 2
            br label %"L4-continue"
    "L4-continue":
    %36 = phi %Node  [%"L6-result-Cnat", %"L6-Cnat"]
                   , [%"L7-result-FAgda.Builtin.Nat._-_", %"L7-FAgda.Builtin.Nat._-_"]
    %x29 = extractvalue %Node %36, 2
    call fastcc void @"drop"(i64 %x32)
    %x30 = add i64 %x28, %x29
    %37 = insertvalue %Node undef, i64 0, 1
    %38 = insertvalue %Node %37, i64 %x30, 2
    ret %Node %38
}

define fastcc %Node
@"Agda.Builtin.Nat._-_"(i64 %x37, i64 %x38){
    %1 = inttoptr i64 %x37 to ptr
    %2 = getelementptr inbounds %Node, ptr %1, i32 0, i64 1
    %x119 = load i64, ptr %2
    switch i64 %x119, label %"L1-default" [i64 0, label %"L2-Cnat"
                                           i64 1, label %"L3-FAgda.Builtin.Nat._-_"]
        "L1-default":
            unreachable
        "L2-Cnat":
            %3 = inttoptr i64 %x37 to ptr
            %4 = getelementptr inbounds %Node, ptr %3, i32 0, i64 2
            %x140 = load i64, ptr %4
            %5 = insertvalue %Node undef, i64 0, 1
            %"L2-result-Cnat" = insertvalue %Node %5, i64 %x140, 2
            br label %"L0-continue"
        "L3-FAgda.Builtin.Nat._-_":
            %6 = inttoptr i64 %x37 to ptr
            %7 = getelementptr inbounds %Node, ptr %6, i32 0, i64 2
            %x142 = load i64, ptr %7
            %8 = inttoptr i64 %x37 to ptr
            %9 = getelementptr inbounds %Node, ptr %8, i32 0, i64 3
            %x141 = load i64, ptr %9
            %10 = call fastcc %Node @"Agda.Builtin.Nat._-_"(i64 %x142, i64 %x141)
            %x116 = extractvalue %Node %10, 2
            %11 = inttoptr i64 %x37 to ptr
            %12 = getelementptr inbounds %Node, ptr %11, i32 0, i64 0
            %13 = load i64, ptr %12
            %14 = insertvalue %Node undef, i64 0, 1
            %15 = insertvalue %Node %14, i64 %x116, 2
            %16 = insertvalue %Node %15, i64 %13, 0
            store %Node %16, ptr %11
            %17 = insertvalue %Node undef, i64 0, 1
            %"L3-result-FAgda.Builtin.Nat._-_" = insertvalue %Node %17, i64 %x116, 2
            br label %"L0-continue"
    "L0-continue":
    %18 = phi %Node  [%"L2-result-Cnat", %"L2-Cnat"]
                   , [%"L3-result-FAgda.Builtin.Nat._-_", %"L3-FAgda.Builtin.Nat._-_"]
    %x34 = extractvalue %Node %18, 2
    call fastcc void @"drop"(i64 %x37)
    %19 = inttoptr i64 %x38 to ptr
    %20 = getelementptr inbounds %Node, ptr %19, i32 0, i64 2
    %x118 = load i64, ptr %20
    call fastcc void @"drop"(i64 %x38)
    %x36 = sub i64 %x34, %x118
    %21 = insertvalue %Node undef, i64 0, 1
    %22 = insertvalue %Node %21, i64 %x36, 2
    ret %Node %22
}

define fastcc void
@"drop"(i64 %x153){
    %1 = inttoptr i64 %x153 to ptr
    %2 = getelementptr inbounds %Node, ptr %1, i32 0, i64 0
    %x152 = load i64, ptr %2
    switch i64 %x152, label %"L1-default" [i64 1, label %"L2-1"]
        "L1-default":
            %3 = inttoptr i64 %x153 to ptr
            %4 = getelementptr inbounds %Node, ptr %3, i32 0, i64 0
            %5 = load i64, ptr %4
            %6 = sub i64 %5, 1
            store i64 %6, ptr %4
            br label %"L0-continue"
        "L2-1":
            %7 = inttoptr i64 %x153 to ptr
            %8 = getelementptr inbounds %Node, ptr %7, i32 0, i64 1
            %x151 = load i64, ptr %8
            switch i64 %x151, label %"L3-default" [i64 3, label %"L4-CUpTo.List.[]"
                                                   i64 2, label %"L5-CUpTo.List._∷_"
                                                   i64 0, label %"L6-Cnat"
                                                   i64 5, label %"L7-FAgda.Builtin.Nat._+_"
                                                   i64 1, label %"L8-FAgda.Builtin.Nat._-_"
                                                   i64 4, label %"L9-FUpTo.upTo"]
                "L3-default":
                    unreachable
                "L4-CUpTo.List.[]":
                    %9 = inttoptr i64 %x153 to ptr
                    call fastcc void @free(ptr %9)
                    br label %"L0-continue"
                "L5-CUpTo.List._∷_":
                    %10 = inttoptr i64 %x153 to ptr
                    %11 = getelementptr inbounds %Node, ptr %10, i32 0, i64 2
                    %x144 = load i64, ptr %11
                    call fastcc void @"drop"(i64 %x144)
                    %12 = inttoptr i64 %x153 to ptr
                    %13 = getelementptr inbounds %Node, ptr %12, i32 0, i64 3
                    %x143 = load i64, ptr %13
                    call fastcc void @"drop"(i64 %x143)
                    %14 = inttoptr i64 %x153 to ptr
                    call fastcc void @free(ptr %14)
                    br label %"L0-continue"
                "L6-Cnat":
                    %15 = inttoptr i64 %x153 to ptr
                    call fastcc void @free(ptr %15)
                    br label %"L0-continue"
                "L7-FAgda.Builtin.Nat._+_":
                    %16 = inttoptr i64 %x153 to ptr
                    %17 = getelementptr inbounds %Node, ptr %16, i32 0, i64 2
                    %x146 = load i64, ptr %17
                    call fastcc void @"drop"(i64 %x146)
                    %18 = inttoptr i64 %x153 to ptr
                    %19 = getelementptr inbounds %Node, ptr %18, i32 0, i64 3
                    %x145 = load i64, ptr %19
                    call fastcc void @"drop"(i64 %x145)
                    %20 = inttoptr i64 %x153 to ptr
                    call fastcc void @free(ptr %20)
                    br label %"L0-continue"
                "L8-FAgda.Builtin.Nat._-_":
                    %21 = inttoptr i64 %x153 to ptr
                    %22 = getelementptr inbounds %Node, ptr %21, i32 0, i64 2
                    %x148 = load i64, ptr %22
                    call fastcc void @"drop"(i64 %x148)
                    %23 = inttoptr i64 %x153 to ptr
                    %24 = getelementptr inbounds %Node, ptr %23, i32 0, i64 3
                    %x147 = load i64, ptr %24
                    call fastcc void @"drop"(i64 %x147)
                    %25 = inttoptr i64 %x153 to ptr
                    call fastcc void @free(ptr %25)
                    br label %"L0-continue"
                "L9-FUpTo.upTo":
                    %26 = inttoptr i64 %x153 to ptr
                    %27 = getelementptr inbounds %Node, ptr %26, i32 0, i64 2
                    %x150 = load i64, ptr %27
                    call fastcc void @"drop"(i64 %x150)
                    %28 = inttoptr i64 %x153 to ptr
                    %29 = getelementptr inbounds %Node, ptr %28, i32 0, i64 3
                    %x149 = load i64, ptr %29
                    call fastcc void @"drop"(i64 %x149)
                    %30 = inttoptr i64 %x153 to ptr
                    call fastcc void @free(ptr %30)
                    br label %"L0-continue"
    "L0-continue":
    ret void
}