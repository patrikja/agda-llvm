target triple = "x86_64-unknown-linux-gnu"
declare void @printf(ptr, ...)
declare ptr @malloc(i64)
declare void @free(ptr)
%Node = type [4 x i64]
@"%d" = private constant [4 x i8] c"%d\0A\00", align 1

; Tag numbering table:
; 0 Cnat
; 1 FAgda.Builtin.Nat._+_
; 2 FAgda.Builtin.Nat._-_
; 3 CDownFromTail.List.[]
; 4 CDownFromTail.List._∷_
; 5 FDownFromTail.downFrom

define fastcc %Node
@"Agda.Builtin.Nat._+_"(i64 %x3, i64 %x4){
  %1 = inttoptr i64 %x3 to ptr
  %2 = getelementptr inbounds %Node, ptr %1, i32 0, i64 1
  %x214 = load i64, ptr %2
  switch i64 %x214, label %default_0 [i64 0, label %"Cnat_0"
                                      i64 1, label %"FAgda.Builtin.Nat._+__0"]
"Cnat_0":
  %3 = inttoptr i64 %x3 to ptr
  %4 = getelementptr inbounds %Node, ptr %3, i32 0, i64 2
  %x550 = load i64, ptr %4
  %5 = insertvalue %Node undef, i64 0, 1
  %"Cnat_0_res" = insertvalue %Node %5, i64 %x550, 2
  br label %continue_0
"FAgda.Builtin.Nat._+__0":
  %6 = inttoptr i64 %x3 to ptr
  %7 = getelementptr inbounds %Node, ptr %6, i32 0, i64 2
  %x551 = load i64, ptr %7
  %8 = inttoptr i64 %x3 to ptr
  %9 = getelementptr inbounds %Node, ptr %8, i32 0, i64 3
  %x552 = load i64, ptr %9
  %"FAgda.Builtin.Nat._+__0_res" = call
                                   fastcc
                                   %Node
                                   @"Agda.Builtin.Nat._+_"(i64 %x551, i64 %x552)
  br label %continue_0
default_0:
  unreachable
continue_0:
  %10 = phi %Node  [%"Cnat_0_res", %"Cnat_0"]
                 , [%"FAgda.Builtin.Nat._+__0_res", %"FAgda.Builtin.Nat._+__0"]
  %x213 = extractvalue %Node %10, 2
  %11 = insertvalue %Node undef, i64 0, 1
  %12 = insertvalue %Node %11, i64 %x213, 2
  %13 = inttoptr i64 %x3 to ptr
  %14 = getelementptr inbounds %Node, ptr %13, i32 0, i64 0
  %15 = load i64, ptr %14
  %16 = insertvalue %Node %12, i64 %15, 0
  store %Node %16, ptr %13
  call fastcc void @"drop"(i64 %x3)
  %17 = inttoptr i64 %x4 to ptr
  %18 = getelementptr inbounds %Node, ptr %17, i32 0, i64 1
  %x210 = load i64, ptr %18
  switch i64 %x210, label %default_1 [i64 0, label %"Cnat_1"
                                      i64 2, label %"FAgda.Builtin.Nat._-__1"]
"Cnat_1":
  %19 = inttoptr i64 %x4 to ptr
  %20 = getelementptr inbounds %Node, ptr %19, i32 0, i64 2
  %x553 = load i64, ptr %20
  %21 = insertvalue %Node undef, i64 0, 1
  %"Cnat_1_res" = insertvalue %Node %21, i64 %x553, 2
  br label %continue_1
"FAgda.Builtin.Nat._-__1":
  %22 = inttoptr i64 %x4 to ptr
  %23 = getelementptr inbounds %Node, ptr %22, i32 0, i64 2
  %x554 = load i64, ptr %23
  %24 = inttoptr i64 %x4 to ptr
  %25 = getelementptr inbounds %Node, ptr %24, i32 0, i64 3
  %x555 = load i64, ptr %25
  %"FAgda.Builtin.Nat._-__1_res" = call
                                   fastcc
                                   %Node
                                   @"Agda.Builtin.Nat._-_"(i64 %x554, i64 %x555)
  br label %continue_1
default_1:
  unreachable
continue_1:
  %26 = phi %Node  [%"Cnat_1_res", %"Cnat_1"]
                 , [%"FAgda.Builtin.Nat._-__1_res", %"FAgda.Builtin.Nat._-__1"]
  %x209 = extractvalue %Node %26, 2
  %27 = insertvalue %Node undef, i64 0, 1
  %28 = insertvalue %Node %27, i64 %x209, 2
  %29 = inttoptr i64 %x4 to ptr
  %30 = getelementptr inbounds %Node, ptr %29, i32 0, i64 0
  %31 = load i64, ptr %30
  %32 = insertvalue %Node %28, i64 %31, 0
  store %Node %32, ptr %29
  call fastcc void @"drop"(i64 %x4)
  %x2 = add i64 %x213, %x209
  %33 = insertvalue %Node undef, i64 0, 1
  %34 = insertvalue %Node %33, i64 %x2, 2
  ret %Node %34
}

define fastcc %Node
@"Agda.Builtin.Nat._-_"(i64 %x9, i64 %x10){
  %1 = inttoptr i64 %x9 to ptr
  %2 = getelementptr inbounds %Node, ptr %1, i32 0, i64 1
  %x219 = load i64, ptr %2
  switch i64 %x219, label %default_2 [i64 0, label %"Cnat_2"
                                      i64 2, label %"FAgda.Builtin.Nat._-__2"]
"Cnat_2":
  %3 = inttoptr i64 %x9 to ptr
  %4 = getelementptr inbounds %Node, ptr %3, i32 0, i64 2
  %x556 = load i64, ptr %4
  %5 = insertvalue %Node undef, i64 0, 1
  %"Cnat_2_res" = insertvalue %Node %5, i64 %x556, 2
  br label %continue_2
"FAgda.Builtin.Nat._-__2":
  %6 = inttoptr i64 %x9 to ptr
  %7 = getelementptr inbounds %Node, ptr %6, i32 0, i64 2
  %x557 = load i64, ptr %7
  %8 = inttoptr i64 %x9 to ptr
  %9 = getelementptr inbounds %Node, ptr %8, i32 0, i64 3
  %x558 = load i64, ptr %9
  %"FAgda.Builtin.Nat._-__2_res" = call
                                   fastcc
                                   %Node
                                   @"Agda.Builtin.Nat._-_"(i64 %x557, i64 %x558)
  br label %continue_2
default_2:
  unreachable
continue_2:
  %10 = phi %Node  [%"Cnat_2_res", %"Cnat_2"]
                 , [%"FAgda.Builtin.Nat._-__2_res", %"FAgda.Builtin.Nat._-__2"]
  %x218 = extractvalue %Node %10, 2
  %11 = insertvalue %Node undef, i64 0, 1
  %12 = insertvalue %Node %11, i64 %x218, 2
  %13 = inttoptr i64 %x9 to ptr
  %14 = getelementptr inbounds %Node, ptr %13, i32 0, i64 0
  %15 = load i64, ptr %14
  %16 = insertvalue %Node %12, i64 %15, 0
  store %Node %16, ptr %13
  call fastcc void @"drop"(i64 %x9)
  %17 = inttoptr i64 %x10 to ptr
  %18 = getelementptr inbounds %Node, ptr %17, i32 0, i64 2
  %x56 = load i64, ptr %18
  %19 = insertvalue %Node undef, i64 0, 1
  %20 = insertvalue %Node %19, i64 %x56, 2
  %21 = inttoptr i64 %x10 to ptr
  %22 = getelementptr inbounds %Node, ptr %21, i32 0, i64 0
  %23 = load i64, ptr %22
  %24 = insertvalue %Node %20, i64 %23, 0
  store %Node %24, ptr %21
  call fastcc void @"drop"(i64 %x10)
  %x8 = sub i64 %x218, %x56
  %25 = insertvalue %Node undef, i64 0, 1
  %26 = insertvalue %Node %25, i64 %x8, 2
  ret %Node %26
}

define fastcc %Node
@"DownFromTail.downFrom"(i64 %x19, i64 %x20){
  %1 = inttoptr i64 %x20 to ptr
  %2 = getelementptr inbounds %Node, ptr %1, i32 0, i64 1
  %x229 = load i64, ptr %2
  switch i64 %x229, label %default_3 [i64 0, label %"Cnat_3"
                                      i64 2, label %"FAgda.Builtin.Nat._-__3"]
"Cnat_3":
  %3 = inttoptr i64 %x20 to ptr
  %4 = getelementptr inbounds %Node, ptr %3, i32 0, i64 2
  %x559 = load i64, ptr %4
  %5 = insertvalue %Node undef, i64 0, 1
  %"Cnat_3_res" = insertvalue %Node %5, i64 %x559, 2
  br label %continue_3
"FAgda.Builtin.Nat._-__3":
  %6 = inttoptr i64 %x20 to ptr
  %7 = getelementptr inbounds %Node, ptr %6, i32 0, i64 2
  %x560 = load i64, ptr %7
  %8 = inttoptr i64 %x20 to ptr
  %9 = getelementptr inbounds %Node, ptr %8, i32 0, i64 3
  %x561 = load i64, ptr %9
  %"FAgda.Builtin.Nat._-__3_res" = call
                                   fastcc
                                   %Node
                                   @"Agda.Builtin.Nat._-_"(i64 %x560, i64 %x561)
  br label %continue_3
default_3:
  unreachable
continue_3:
  %10 = phi %Node  [%"Cnat_3_res", %"Cnat_3"]
                 , [%"FAgda.Builtin.Nat._-__3_res", %"FAgda.Builtin.Nat._-__3"]
  %x228 = extractvalue %Node %10, 2
  %11 = insertvalue %Node undef, i64 0, 1
  %12 = insertvalue %Node %11, i64 %x228, 2
  %13 = inttoptr i64 %x20 to ptr
  %14 = getelementptr inbounds %Node, ptr %13, i32 0, i64 0
  %15 = load i64, ptr %14
  %16 = insertvalue %Node %12, i64 %15, 0
  store %Node %16, ptr %13
  switch i64 %x228, label %default_4 [i64 0, label %"0_4"]
"0_4":
  call fastcc void @"drop"(i64 %x20)
  %17 = inttoptr i64 %x19 to ptr
  %18 = getelementptr inbounds %Node, ptr %17, i32 0, i64 1
  %x225 = load i64, ptr %18
  switch i64 %x225, label %default_5 [i64 3, label %"CDownFromTail.List.[]_5"
                                      i64 4, label %"CDownFromTail.List._∷__5"]
"CDownFromTail.List.[]_5":
  %"CDownFromTail.List.[]_5_res" = insertvalue %Node undef, i64 3, 1
  br label %continue_5
"CDownFromTail.List._∷__5":
  %19 = inttoptr i64 %x19 to ptr
  %20 = getelementptr inbounds %Node, ptr %19, i32 0, i64 2
  %x562 = load i64, ptr %20
  %21 = inttoptr i64 %x19 to ptr
  %22 = getelementptr inbounds %Node, ptr %21, i32 0, i64 3
  %x563 = load i64, ptr %22
  call fastcc void @"dup"(i64 %x563)
  call fastcc void @"dup"(i64 %x562)
  %23 = insertvalue %Node undef, i64 4, 1
  %24 = insertvalue %Node %23, i64 %x562, 2
  %"CDownFromTail.List._∷__5_res" = insertvalue %Node %24, i64 %x563, 3
  br label %continue_5
default_5:
  unreachable
continue_5:
  %25 = phi %Node  [%"CDownFromTail.List.[]_5_res", %"CDownFromTail.List.[]_5"]
                 , [%"CDownFromTail.List._∷__5_res", %"CDownFromTail.List._∷__5"]
  %x222 = extractvalue %Node %25, 1
  %x223 = extractvalue %Node %25, 2
  %x224 = extractvalue %Node %25, 3
  switch i64 %x222, label %default_6 [i64 3, label %"CDownFromTail.List.[]_6"
                                      i64 4, label %"CDownFromTail.List._∷__6"]
"CDownFromTail.List.[]_6":
  %26 = insertvalue %Node undef, i64 %x222, 1
  %27 = insertvalue %Node %26, i64 %x223, 2
  %28 = insertvalue %Node %27, i64 %x224, 3
  %29 = inttoptr i64 %x19 to ptr
  %30 = getelementptr inbounds %Node, ptr %29, i32 0, i64 0
  %31 = load i64, ptr %30
  %32 = insertvalue %Node %28, i64 %31, 0
  store %Node %32, ptr %29
  call fastcc void @"drop"(i64 %x19)
  %33 = insertvalue %Node undef, i64 3, 1
  ret %Node %33
"CDownFromTail.List._∷__6":
  %34 = insertvalue %Node undef, i64 %x222, 1
  %35 = insertvalue %Node %34, i64 %x223, 2
  %36 = insertvalue %Node %35, i64 %x224, 3
  %37 = inttoptr i64 %x19 to ptr
  %38 = getelementptr inbounds %Node, ptr %37, i32 0, i64 0
  %39 = load i64, ptr %38
  %40 = insertvalue %Node %36, i64 %39, 0
  store %Node %40, ptr %37
  call fastcc void @"drop"(i64 %x19)
  call fastcc void @"dup"(i64 %x224)
  call fastcc void @"dup"(i64 %x223)
  %41 = insertvalue %Node undef, i64 4, 1
  %42 = insertvalue %Node %41, i64 %x223, 2
  %43 = insertvalue %Node %42, i64 %x224, 3
  ret %Node %43
default_6:
  unreachable
default_4:
  %44 = insertvalue %Node undef, i64 0, 1
  %45 = insertvalue %Node %44, i64 1, 2
  %46 = insertvalue %Node %45, i64 1, 0
  %47 = call fastcc ptr @malloc(i64 32)
  store %Node %46, ptr %47
  %x17 = ptrtoint ptr %47 to i64
  %48 = insertvalue %Node undef, i64 2, 1
  %49 = insertvalue %Node %48, i64 %x20, 2
  %50 = insertvalue %Node %49, i64 %x17, 3
  %51 = insertvalue %Node %50, i64 1, 0
  %52 = call fastcc ptr @malloc(i64 32)
  store %Node %51, ptr %52
  %x16 = ptrtoint ptr %52 to i64
  call fastcc void @"dup"(i64 %x16)
  %53 = insertvalue %Node undef, i64 4, 1
  %54 = insertvalue %Node %53, i64 %x16, 2
  %55 = insertvalue %Node %54, i64 %x19, 3
  %56 = insertvalue %Node %55, i64 1, 0
  %57 = call fastcc ptr @malloc(i64 32)
  store %Node %56, ptr %57
  %x15 = ptrtoint ptr %57 to i64
  %58 = tail call
        fastcc
        %Node
        @"DownFromTail.downFrom"(i64 %x15, i64 %x16)
  ret %Node %58
}

define fastcc %Node
@"DownFromTail.sum"(i64 %x27, i64 %x28){
  %1 = inttoptr i64 %x28 to ptr
  %2 = getelementptr inbounds %Node, ptr %1, i32 0, i64 1
  %x239 = load i64, ptr %2
  switch i64 %x239, label %default_7 [i64 3, label %"CDownFromTail.List.[]_7"
                                      i64 4, label %"CDownFromTail.List._∷__7"
                                      i64 5, label %"FDownFromTail.downFrom_7"]
"CDownFromTail.List.[]_7":
  %"CDownFromTail.List.[]_7_res" = insertvalue %Node undef, i64 3, 1
  br label %continue_7
"CDownFromTail.List._∷__7":
  %3 = inttoptr i64 %x28 to ptr
  %4 = getelementptr inbounds %Node, ptr %3, i32 0, i64 2
  %x564 = load i64, ptr %4
  %5 = inttoptr i64 %x28 to ptr
  %6 = getelementptr inbounds %Node, ptr %5, i32 0, i64 3
  %x566 = load i64, ptr %6
  call fastcc void @"dup"(i64 %x566)
  call fastcc void @"dup"(i64 %x564)
  %7 = insertvalue %Node undef, i64 4, 1
  %8 = insertvalue %Node %7, i64 %x564, 2
  %"CDownFromTail.List._∷__7_res" = insertvalue %Node %8, i64 %x566, 3
  br label %continue_7
"FDownFromTail.downFrom_7":
  %9 = inttoptr i64 %x28 to ptr
  %10 = getelementptr inbounds %Node, ptr %9, i32 0, i64 2
  %x565 = load i64, ptr %10
  %11 = inttoptr i64 %x28 to ptr
  %12 = getelementptr inbounds %Node, ptr %11, i32 0, i64 3
  %x567 = load i64, ptr %12
  %"FDownFromTail.downFrom_7_res" = call
                                    fastcc
                                    %Node
                                    @"DownFromTail.downFrom"(i64 %x565, i64 %x567)
  br label %continue_7
default_7:
  unreachable
continue_7:
  %13 = phi %Node  [%"CDownFromTail.List.[]_7_res", %"CDownFromTail.List.[]_7"]
                 , [%"CDownFromTail.List._∷__7_res", %"CDownFromTail.List._∷__7"]
                 , [%"FDownFromTail.downFrom_7_res", %"FDownFromTail.downFrom_7"]
  %x236 = extractvalue %Node %13, 1
  %x237 = extractvalue %Node %13, 2
  %x238 = extractvalue %Node %13, 3
  switch i64 %x236, label %default_8 [i64 3, label %"CDownFromTail.List.[]_8"
                                      i64 4, label %"CDownFromTail.List._∷__8"]
"CDownFromTail.List.[]_8":
  %14 = insertvalue %Node undef, i64 %x236, 1
  %15 = insertvalue %Node %14, i64 %x237, 2
  %16 = insertvalue %Node %15, i64 %x238, 3
  %17 = inttoptr i64 %x28 to ptr
  %18 = getelementptr inbounds %Node, ptr %17, i32 0, i64 0
  %19 = load i64, ptr %18
  %20 = insertvalue %Node %16, i64 %19, 0
  store %Node %20, ptr %17
  call fastcc void @"drop"(i64 %x28)
  %21 = inttoptr i64 %x27 to ptr
  %22 = getelementptr inbounds %Node, ptr %21, i32 0, i64 1
  %x233 = load i64, ptr %22
  switch i64 %x233, label %default_9 [i64 0, label %"Cnat_9"
                                      i64 1, label %"FAgda.Builtin.Nat._+__9"]
"Cnat_9":
  %23 = inttoptr i64 %x27 to ptr
  %24 = getelementptr inbounds %Node, ptr %23, i32 0, i64 2
  %x568 = load i64, ptr %24
  %25 = insertvalue %Node undef, i64 0, 1
  %"Cnat_9_res" = insertvalue %Node %25, i64 %x568, 2
  br label %continue_9
"FAgda.Builtin.Nat._+__9":
  %26 = inttoptr i64 %x27 to ptr
  %27 = getelementptr inbounds %Node, ptr %26, i32 0, i64 2
  %x569 = load i64, ptr %27
  %28 = inttoptr i64 %x27 to ptr
  %29 = getelementptr inbounds %Node, ptr %28, i32 0, i64 3
  %x570 = load i64, ptr %29
  %"FAgda.Builtin.Nat._+__9_res" = call
                                   fastcc
                                   %Node
                                   @"Agda.Builtin.Nat._+_"(i64 %x569, i64 %x570)
  br label %continue_9
default_9:
  unreachable
continue_9:
  %30 = phi %Node  [%"Cnat_9_res", %"Cnat_9"]
                 , [%"FAgda.Builtin.Nat._+__9_res", %"FAgda.Builtin.Nat._+__9"]
  %x232 = extractvalue %Node %30, 2
  %31 = insertvalue %Node undef, i64 0, 1
  %32 = insertvalue %Node %31, i64 %x232, 2
  %33 = inttoptr i64 %x27 to ptr
  %34 = getelementptr inbounds %Node, ptr %33, i32 0, i64 0
  %35 = load i64, ptr %34
  %36 = insertvalue %Node %32, i64 %35, 0
  store %Node %36, ptr %33
  call fastcc void @"drop"(i64 %x27)
  %37 = insertvalue %Node undef, i64 0, 1
  %38 = insertvalue %Node %37, i64 %x232, 2
  ret %Node %38
"CDownFromTail.List._∷__8":
  %39 = insertvalue %Node undef, i64 %x236, 1
  %40 = insertvalue %Node %39, i64 %x237, 2
  %41 = insertvalue %Node %40, i64 %x238, 3
  %42 = inttoptr i64 %x28 to ptr
  %43 = getelementptr inbounds %Node, ptr %42, i32 0, i64 0
  %44 = load i64, ptr %43
  %45 = insertvalue %Node %41, i64 %44, 0
  store %Node %45, ptr %42
  call fastcc void @"drop"(i64 %x28)
  %46 = insertvalue %Node undef, i64 1, 1
  %47 = insertvalue %Node %46, i64 %x27, 2
  %48 = insertvalue %Node %47, i64 %x237, 3
  %49 = insertvalue %Node %48, i64 1, 0
  %50 = call fastcc ptr @malloc(i64 32)
  store %Node %49, ptr %50
  %x23 = ptrtoint ptr %50 to i64
  %51 = tail call
        fastcc
        %Node
        @"DownFromTail.sum"(i64 %x23, i64 %x238)
  ret %Node %51
default_8:
  unreachable
}

define fastcc void
@main(){
  %1 = insertvalue %Node undef, i64 0, 1
  %2 = insertvalue %Node %1, i64 0, 2
  %3 = insertvalue %Node %2, i64 1, 0
  %4 = call fastcc ptr @malloc(i64 32)
  store %Node %3, ptr %4
  %x38 = ptrtoint ptr %4 to i64
  %5 = insertvalue %Node undef, i64 3, 1
  %6 = insertvalue %Node %5, i64 1, 0
  %7 = call fastcc ptr @malloc(i64 32)
  store %Node %6, ptr %7
  %x37 = ptrtoint ptr %7 to i64
  %8 = insertvalue %Node undef, i64 0, 1
  %9 = insertvalue %Node %8, i64 10, 2
  %10 = insertvalue %Node %9, i64 1, 0
  %11 = call fastcc ptr @malloc(i64 32)
  store %Node %10, ptr %11
  %x36 = ptrtoint ptr %11 to i64
  %12 = insertvalue %Node undef, i64 5, 1
  %13 = insertvalue %Node %12, i64 %x37, 2
  %14 = insertvalue %Node %13, i64 %x36, 3
  %15 = insertvalue %Node %14, i64 1, 0
  %16 = call fastcc ptr @malloc(i64 32)
  store %Node %15, ptr %16
  %x35 = ptrtoint ptr %16 to i64
  %17 = call fastcc %Node @"DownFromTail.sum"(i64 %x38, i64 %x35)
  %x34 = extractvalue %Node %17, 2
  call fastcc void @printf(ptr @"%d", i64 %x34)
  ret void
}

define fastcc void
@"drop"(i64 %x673){
  %1 = inttoptr i64 %x673 to ptr
  %2 = getelementptr inbounds %Node, ptr %1, i32 0, i64 0
  %x672 = load i64, ptr %2
  switch i64 %x672, label %default_10 [i64 1, label %"1_10"]
"1_10":
  %3 = inttoptr i64 %x673 to ptr
  %4 = getelementptr inbounds %Node, ptr %3, i32 0, i64 1
  %x671 = load i64, ptr %4
  switch i64 %x671, label %default_11 [i64 3, label %"CDownFromTail.List.[]_11"
                                       i64 4, label %"CDownFromTail.List._∷__11"
                                       i64 0, label %"Cnat_11"
                                       i64 1, label %"FAgda.Builtin.Nat._+__11"
                                       i64 2, label %"FAgda.Builtin.Nat._-__11"
                                       i64 5, label %"FDownFromTail.downFrom_11"]
"CDownFromTail.List.[]_11":
  %5 = inttoptr i64 %x673 to ptr
  call fastcc void @free(ptr %5)
  ret void
"CDownFromTail.List._∷__11":
  %6 = inttoptr i64 %x673 to ptr
  %7 = getelementptr inbounds %Node, ptr %6, i32 0, i64 2
  %x664 = load i64, ptr %7
  call fastcc void @"drop"(i64 %x664)
  %8 = inttoptr i64 %x673 to ptr
  %9 = getelementptr inbounds %Node, ptr %8, i32 0, i64 3
  %x663 = load i64, ptr %9
  call fastcc void @"drop"(i64 %x663)
  %10 = inttoptr i64 %x673 to ptr
  call fastcc void @free(ptr %10)
  ret void
"Cnat_11":
  %11 = inttoptr i64 %x673 to ptr
  call fastcc void @free(ptr %11)
  ret void
"FAgda.Builtin.Nat._+__11":
  %12 = inttoptr i64 %x673 to ptr
  %13 = getelementptr inbounds %Node, ptr %12, i32 0, i64 2
  %x666 = load i64, ptr %13
  call fastcc void @"drop"(i64 %x666)
  %14 = inttoptr i64 %x673 to ptr
  %15 = getelementptr inbounds %Node, ptr %14, i32 0, i64 3
  %x665 = load i64, ptr %15
  call fastcc void @"drop"(i64 %x665)
  %16 = inttoptr i64 %x673 to ptr
  call fastcc void @free(ptr %16)
  ret void
"FAgda.Builtin.Nat._-__11":
  %17 = inttoptr i64 %x673 to ptr
  %18 = getelementptr inbounds %Node, ptr %17, i32 0, i64 2
  %x668 = load i64, ptr %18
  call fastcc void @"drop"(i64 %x668)
  %19 = inttoptr i64 %x673 to ptr
  %20 = getelementptr inbounds %Node, ptr %19, i32 0, i64 3
  %x667 = load i64, ptr %20
  call fastcc void @"drop"(i64 %x667)
  %21 = inttoptr i64 %x673 to ptr
  call fastcc void @free(ptr %21)
  ret void
"FDownFromTail.downFrom_11":
  %22 = inttoptr i64 %x673 to ptr
  %23 = getelementptr inbounds %Node, ptr %22, i32 0, i64 2
  %x670 = load i64, ptr %23
  call fastcc void @"drop"(i64 %x670)
  %24 = inttoptr i64 %x673 to ptr
  %25 = getelementptr inbounds %Node, ptr %24, i32 0, i64 3
  %x669 = load i64, ptr %25
  call fastcc void @"drop"(i64 %x669)
  %26 = inttoptr i64 %x673 to ptr
  call fastcc void @free(ptr %26)
  ret void
default_11:
  unreachable
default_10:
  %x662 = sub i64 %x672, 1
  %27 = inttoptr i64 %x673 to ptr
  %28 = getelementptr inbounds %Node, ptr %27, i32 0, i64 0
  store i64 %x662, ptr %28
  ret void
}

define fastcc void
@"dup"(i64 %x661){
  %1 = inttoptr i64 %x661 to ptr
  %2 = getelementptr inbounds %Node, ptr %1, i32 0, i64 0
  %x660 = load i64, ptr %2
  %x659 = add i64 %x660, 1
  %3 = inttoptr i64 %x661 to ptr
  %4 = getelementptr inbounds %Node, ptr %3, i32 0, i64 0
  store i64 %x659, ptr %4
  ret void
}