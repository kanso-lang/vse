%KValue = type { i64, i64 }
%parsed = type { i64, i64 }
%KBytes = type { i64, ptr }

; Inline twins of the runtime's hot one-liners (tag tests and value
; constructors). LTO declines to inline these across the .ll/.o module
; boundary, leaving a real call on every `if` condition and constructor;
; internal linkage keeps them from colliding with the runtime's own
; definitions, and alwaysinline folds them into every call site.
define internal %KValue @k_int(i64 %n) alwaysinline {
  %v = insertvalue %KValue { i64 0, i64 undef }, i64 %n, 1
  ret %KValue %v
}
define internal %KValue @k_float(double %d) alwaysinline {
  %bits = bitcast double %d to i64
  %v = insertvalue %KValue { i64 1, i64 undef }, i64 %bits, 1
  ret %KValue %v
}
define internal %KValue @k_bool(i64 %b) alwaysinline {
  %c = icmp ne i64 %b, 0
  %tag = select i1 %c, i64 2, i64 3
  %v = insertvalue %KValue { i64 undef, i64 0 }, i64 %tag, 0
  ret %KValue %v
}
define internal %KValue @k_none() alwaysinline {
  ret %KValue { i64 4, i64 0 }
}
define internal i64 @k_not_failure(%KValue %v) alwaysinline {
  %tag = extractvalue %KValue %v, 0
  %ne = icmp ne i64 %tag, 5
  %nn = icmp ne i64 %tag, 4
  %ok = and i1 %ne, %nn
  %r = zext i1 %ok to i64
  ret i64 %r
}
define internal i64 @k_truthy(%KValue %v) alwaysinline {
  %tag = extractvalue %KValue %v, 0
  %t = icmp eq i64 %tag, 2
  br i1 %t, label %yes, label %chkf
yes:
  ret i64 1
chkf:
  %f = icmp eq i64 %tag, 3
  br i1 %f, label %no, label %bad
no:
  ret i64 0
bad:
  %r = call i64 @k_truthy_bad()
  ret i64 %r
}
define internal i64 @k_check_tag(%KValue %v, i64 %t) alwaysinline {
  %tag = extractvalue %KValue %v, 0
  %c = icmp eq i64 %tag, %t
  %r = zext i1 %c to i64
  ret i64 %r
}
define internal i64 @k_check_int(%KValue %v, i64 %n) alwaysinline {
  %tag = extractvalue %KValue %v, 0
  %pay = extractvalue %KValue %v, 1
  %ct = icmp eq i64 %tag, 0
  %cp = icmp eq i64 %pay, %n
  %c = and i1 %ct, %cp
  %r = zext i1 %c to i64
  ret i64 %r
}
define internal i64 @k_check_bool(%KValue %v) alwaysinline {
  %tag = extractvalue %KValue %v, 0
  %t = icmp eq i64 %tag, 2
  %f = icmp eq i64 %tag, 3
  %c = or i1 %t, %f
  %r = zext i1 %c to i64
  ret i64 %r
}
declare i64 @k_truthy_bad()

declare %KValue @k_str_n(ptr, i64)
declare %KValue @k_err(%KValue, ptr)
declare %KValue @k_err_hop(%KValue, ptr)
declare %KValue @k_rec(i64, i64, ptr)
declare %KValue @k_field(%KValue, i64)
declare %KValue @k_keyed_check(%KValue, i64)
declare %KValue @k_keyed_field(%KValue, ptr)
declare %KValue @k_err_inner(%KValue)
declare i64 @k_check_rec(%KValue, i64, i64)
declare i64 @k_check_str(%KValue, ptr, i64)
declare %KValue @k_concat(%KValue, %KValue)
declare %KValue @k_render(%KValue, i64)
declare %KValue @k_add(%KValue, %KValue)
declare %KValue @k_sub(%KValue, %KValue)
declare %KValue @k_mul(%KValue, %KValue)
declare %KValue @k_div(%KValue, %KValue, ptr)
declare %KValue @k_cmp(%KValue, %KValue, i64)
declare %KValue @k_desc_print(%KValue)
declare %KValue @k_seq(%KValue, %KValue)
declare void @k_die(ptr) noreturn
declare { i64, i1 } @llvm.sadd.with.overflow.i64(i64, i64)
declare { i64, i1 } @llvm.ssub.with.overflow.i64(i64, i64)
declare { i64, i1 } @llvm.smul.with.overflow.i64(i64, i64)
declare %KValue @k_list_lit(i64, ptr)
declare %KValue @k_map_lit(i64, ptr)
declare %KValue @k_closure(ptr, i64, ptr)
declare %KValue @k_fnref(ptr)
declare %KValue @k_env_get(ptr, i64)
declare %KValue @k_b_at(%KValue, %KValue)
declare %KValue @k_index(%KValue, %KValue, ptr)
declare %KValue @k_b_bytes(%KValue)
declare %KValue @k_b_chars(%KValue)
declare %KValue @k_b_concat(%KValue, %KValue)
declare %KValue @k_b_utf8(%KValue, ptr)
declare %KValue @k_desc_args()
declare %KValue @k_desc_stdin()
declare %KValue @k_b_read_file(%KValue)
declare %KValue @k_b_write_file(%KValue, %KValue)
declare %KValue @k_maybe_bind(%KValue, %KValue)
declare %KValue @k_desc_join(%KValue, %KValue)
declare %KValue @k_desc_sleep(%KValue)
declare %KValue @k_desc_random(%KValue)
declare void @k_beat_push()
declare void @k_beat_iter()
declare void @k_carry_reset()
declare void @k_carry_stage(%KValue)
declare %KValue @k_carry_take(i64)
declare void @k_beat_iter_carry()
declare %KValue @k_beat_pop(%KValue)
declare %KValue @k_call1(%KValue, %KValue)
declare %KValue @k_call2(%KValue, %KValue, %KValue)
declare %KValue @k_call3(%KValue, %KValue, %KValue, %KValue)
declare %KValue @k_call4(%KValue, %KValue, %KValue, %KValue, %KValue)
declare %KValue @k_b_char_code(%KValue)
declare %KValue @k_b_entries(%KValue)
declare %KValue @k_b_filter(%KValue, %KValue)
declare %KValue @k_b_from_code(%KValue, ptr)
declare %KValue @k_b_join(%KValue, %KValue)
declare %KValue @k_b_length(%KValue)
declare %KValue @k_b_map(%KValue, %KValue)
declare %KValue @k_b_push(%KValue, %KValue)
declare %KValue @k_b_push_mut(%KValue, %KValue)
declare %KValue @k_b_put(%KValue, %KValue, %KValue)
declare %KValue @k_b_slice(%KValue, %KValue, %KValue)
declare %KValue @k_b_find2(%KValue, %KValue, %KValue, %KValue)
declare %KValue @k_b_sort(%KValue)
declare %KValue @k_b_sum(%KValue)
declare %KValue @k_b_to_float(%KValue, ptr)
declare %KValue @k_b_sqrt(%KValue)
declare %KValue @k_b_round(%KValue)
declare %KValue @k_b_to_int(%KValue, ptr)

@s0 = private unnamed_addr constant [6 x i8] c"entry\00"
@s1 = private unnamed_addr constant [7 x i8] c"record\00"
@s2 = private unnamed_addr constant [1 x i8] c"\00"
@s3 = private unnamed_addr constant [4 x i8] c"key\00"
@s4 = private unnamed_addr constant [6 x i8] c"value\00"
@s5 = private unnamed_addr constant [9 x i8] c"_fold_at\00"
@s6 = private unnamed_addr constant [71 x i8] c"integer overflow (int64 native build; spec int is arbitrary precision)\00"
@s7 = private unnamed_addr constant [50 x i8] c"no overload of `_fold_at` matches these arguments\00"
@s8 = private unnamed_addr constant [10 x i8] c"_range_to\00"
@s9 = private unnamed_addr constant [51 x i8] c"no overload of `_range_to` matches these arguments\00"
@s10 = private unnamed_addr constant [7 x i8] c"argmax\00"
@s11 = private unnamed_addr constant [48 x i8] c"no overload of `argmax` matches these arguments\00"
@s12 = private unnamed_addr constant [6 x i8] c"count\00"
@s13 = private unnamed_addr constant [47 x i8] c"no overload of `count` matches these arguments\00"
@s14 = private unnamed_addr constant [5 x i8] c"fold\00"
@s15 = private unnamed_addr constant [46 x i8] c"no overload of `fold` matches these arguments\00"
@s16 = private unnamed_addr constant [8 x i8] c"maximum\00"
@s17 = private unnamed_addr constant [49 x i8] c"no overload of `maximum` matches these arguments\00"
@s18 = private unnamed_addr constant [5 x i8] c"mean\00"
@s19 = private unnamed_addr constant [28 x i8] c"mean at ./enumerable.kso:20\00"
@s20 = private unnamed_addr constant [46 x i8] c"no overload of `mean` matches these arguments\00"
@s21 = private unnamed_addr constant [8 x i8] c"minimum\00"
@s22 = private unnamed_addr constant [49 x i8] c"no overload of `minimum` matches these arguments\00"
@s23 = private unnamed_addr constant [6 x i8] c"range\00"
@s24 = private unnamed_addr constant [47 x i8] c"no overload of `range` matches these arguments\00"
@s25 = private unnamed_addr constant [6 x i8] c"total\00"
@s26 = private unnamed_addr constant [47 x i8] c"no overload of `total` matches these arguments\00"
@s27 = private unnamed_addr constant [4 x i8] c"_sq\00"
@s28 = private unnamed_addr constant [45 x i8] c"no overload of `_sq` matches these arguments\00"
@s29 = private unnamed_addr constant [7 x i8] c"_tally\00"
@s30 = private unnamed_addr constant [48 x i8] c"no overload of `_tally` matches these arguments\00"
@s31 = private unnamed_addr constant [13 x i8] c"_with_voters\00"
@s32 = private unnamed_addr constant [54 x i8] c"no overload of `_with_voters` matches these arguments\00"
@s33 = private unnamed_addr constant [6 x i8] c"cloud\00"
@s34 = private unnamed_addr constant [47 x i8] c"no overload of `cloud` matches these arguments\00"
@s35 = private unnamed_addr constant [5 x i8] c"dims\00"
@s36 = private unnamed_addr constant [46 x i8] c"no overload of `dims` matches these arguments\00"
@s37 = private unnamed_addr constant [6 x i8] c"dist2\00"
@s38 = private unnamed_addr constant [47 x i8] c"no overload of `dist2` matches these arguments\00"
@s39 = private unnamed_addr constant [5 x i8] c"main\00"
@s40 = private unnamed_addr constant [46 x i8] c"no overload of `main` matches these arguments\00"
@s41 = private unnamed_addr constant [6 x i8] c"means\00"
@s42 = private unnamed_addr constant [14 x i8] c"plurality VSE "
@s43 = private unnamed_addr constant [23 x i8] c"means at ./main.kso:31\00"
@s44 = private unnamed_addr constant [14 x i8] c"approval  VSE "
@s45 = private unnamed_addr constant [23 x i8] c"means at ./main.kso:32\00"
@s46 = private unnamed_addr constant [14 x i8] c"score     VSE "
@s47 = private unnamed_addr constant [23 x i8] c"means at ./main.kso:33\00"
@s48 = private unnamed_addr constant [14 x i8] c"star      VSE "
@s49 = private unnamed_addr constant [23 x i8] c"means at ./main.kso:34\00"
@s50 = private unnamed_addr constant [14 x i8] c"irv       VSE "
@s51 = private unnamed_addr constant [23 x i8] c"means at ./main.kso:35\00"
@s52 = private unnamed_addr constant [14 x i8] c"minimax   VSE "
@s53 = private unnamed_addr constant [23 x i8] c"means at ./main.kso:36\00"
@s54 = private unnamed_addr constant [47 x i8] c"no overload of `means` matches these arguments\00"
@s55 = private unnamed_addr constant [6 x i8] c"ncand\00"
@s56 = private unnamed_addr constant [47 x i8] c"no overload of `ncand` matches these arguments\00"
@s57 = private unnamed_addr constant [5 x i8] c"nvot\00"
@s58 = private unnamed_addr constant [46 x i8] c"no overload of `nvot` matches these arguments\00"
@s59 = private unnamed_addr constant [6 x i8] c"point\00"
@s60 = private unnamed_addr constant [47 x i8] c"no overload of `point` matches these arguments\00"
@s61 = private unnamed_addr constant [5 x i8] c"runs\00"
@s62 = private unnamed_addr constant [46 x i8] c"no overload of `runs` matches these arguments\00"
@s63 = private unnamed_addr constant [8 x i8] c"socutil\00"
@s64 = private unnamed_addr constant [49 x i8] c"no overload of `socutil` matches these arguments\00"
@s65 = private unnamed_addr constant [9 x i8] c"socutils\00"
@s66 = private unnamed_addr constant [50 x i8] c"no overload of `socutils` matches these arguments\00"
@s67 = private unnamed_addr constant [7 x i8] c"trials\00"
@s68 = private unnamed_addr constant [48 x i8] c"no overload of `trials` matches these arguments\00"
@s69 = private unnamed_addr constant [5 x i8] c"util\00"
@s70 = private unnamed_addr constant [46 x i8] c"no overload of `util` matches these arguments\00"
@s71 = private unnamed_addr constant [10 x i8] c"utilities\00"
@s72 = private unnamed_addr constant [51 x i8] c"no overload of `utilities` matches these arguments\00"
@s73 = private unnamed_addr constant [4 x i8] c"vse\00"
@s74 = private unnamed_addr constant [21 x i8] c"vse at ./main.kso:70\00"
@s75 = private unnamed_addr constant [45 x i8] c"no overload of `vse` matches these arguments\00"
@s76 = private unnamed_addr constant [14 x i8] c"_approval_col\00"
@s77 = private unnamed_addr constant [55 x i8] c"no overload of `_approval_col` matches these arguments\00"
@s78 = private unnamed_addr constant [10 x i8] c"_approves\00"
@s79 = private unnamed_addr constant [51 x i8] c"no overload of `_approves` matches these arguments\00"
@s80 = private unnamed_addr constant [15 x i8] c"_argmax_except\00"
@s81 = private unnamed_addr constant [56 x i8] c"no overload of `_argmax_except` matches these arguments\00"
@s82 = private unnamed_addr constant [8 x i8] c"_better\00"
@s83 = private unnamed_addr constant [49 x i8] c"no overload of `_better` matches these arguments\00"
@s84 = private unnamed_addr constant [10 x i8] c"_first_is\00"
@s85 = private unnamed_addr constant [51 x i8] c"no overload of `_first_is` matches these arguments\00"
@s86 = private unnamed_addr constant [4 x i8] c"_in\00"
@s87 = private unnamed_addr constant [45 x i8] c"no overload of `_in` matches these arguments\00"
@s88 = private unnamed_addr constant [12 x i8] c"_irv_counts\00"
@s89 = private unnamed_addr constant [53 x i8] c"no overload of `_irv_counts` matches these arguments\00"
@s90 = private unnamed_addr constant [8 x i8] c"_irv_go\00"
@s91 = private unnamed_addr constant [49 x i8] c"no overload of `_irv_go` matches these arguments\00"
@s92 = private unnamed_addr constant [10 x i8] c"_irv_next\00"
@s93 = private unnamed_addr constant [51 x i8] c"no overload of `_irv_next` matches these arguments\00"
@s94 = private unnamed_addr constant [10 x i8] c"_keep_min\00"
@s95 = private unnamed_addr constant [51 x i8] c"no overload of `_keep_min` matches these arguments\00"
@s96 = private unnamed_addr constant [10 x i8] c"_keep_top\00"
@s97 = private unnamed_addr constant [51 x i8] c"no overload of `_keep_top` matches these arguments\00"
@s98 = private unnamed_addr constant [16 x i8] c"_margin_or_high\00"
@s99 = private unnamed_addr constant [57 x i8] c"no overload of `_margin_or_high` matches these arguments\00"
@s100 = private unnamed_addr constant [11 x i8] c"_min_alive\00"
@s101 = private unnamed_addr constant [52 x i8] c"no overload of `_min_alive` matches these arguments\00"
@s102 = private unnamed_addr constant [6 x i8] c"_pair\00"
@s103 = private unnamed_addr constant [47 x i8] c"no overload of `_pair` matches these arguments\00"
@s104 = private unnamed_addr constant [14 x i8] c"_prefer_count\00"
@s105 = private unnamed_addr constant [55 x i8] c"no overload of `_prefer_count` matches these arguments\00"
@s106 = private unnamed_addr constant [12 x i8] c"_rank_first\00"
@s107 = private unnamed_addr constant [53 x i8] c"no overload of `_rank_first` matches these arguments\00"
@s108 = private unnamed_addr constant [14 x i8] c"_score_ballot\00"
@s109 = private unnamed_addr constant [34 x i8] c"_score_ballot at ./methods.kso:55\00"
@s110 = private unnamed_addr constant [55 x i8] c"no overload of `_score_ballot` matches these arguments\00"
@s111 = private unnamed_addr constant [11 x i8] c"_score_col\00"
@s112 = private unnamed_addr constant [52 x i8] c"no overload of `_score_col` matches these arguments\00"
@s113 = private unnamed_addr constant [14 x i8] c"_worst_margin\00"
@s114 = private unnamed_addr constant [55 x i8] c"no overload of `_worst_margin` matches these arguments\00"
@s115 = private unnamed_addr constant [16 x i8] c"approval_winner\00"
@s116 = private unnamed_addr constant [57 x i8] c"no overload of `approval_winner` matches these arguments\00"
@s117 = private unnamed_addr constant [11 x i8] c"irv_winner\00"
@s118 = private unnamed_addr constant [52 x i8] c"no overload of `irv_winner` matches these arguments\00"
@s119 = private unnamed_addr constant [15 x i8] c"minimax_winner\00"
@s120 = private unnamed_addr constant [56 x i8] c"no overload of `minimax_winner` matches these arguments\00"
@s121 = private unnamed_addr constant [17 x i8] c"plurality_winner\00"
@s122 = private unnamed_addr constant [58 x i8] c"no overload of `plurality_winner` matches these arguments\00"
@s123 = private unnamed_addr constant [13 x i8] c"score_winner\00"
@s124 = private unnamed_addr constant [54 x i8] c"no overload of `score_winner` matches these arguments\00"
@s125 = private unnamed_addr constant [12 x i8] c"star_winner\00"
@s126 = private unnamed_addr constant [53 x i8] c"no overload of `star_winner` matches these arguments\00"

define ptr @k_type_name(i64 %id) {
entry:
  switch i64 %id, label %TD [
    i64 0, label %T0
  ]
T0:
  ret ptr @s0
TD:
  ret ptr @s1
}

define i64 @k_type_field_count(i64 %id) {
entry:
  switch i64 %id, label %CD [
    i64 0, label %C0
  ]
C0:
  ret i64 2
CD:
  ret i64 0
}

define ptr @k_type_field_name(i64 %id, i64 %i) {
entry:
  switch i64 %id, label %TD [
    i64 0, label %T0
  ]
T0F0:
  ret ptr @s3
T0F1:
  ret ptr @s4
T0:
  switch i64 %i, label %TD [
    i64 0, label %T0F0
    i64 1, label %T0F1
  ]
TD:
  ret ptr @s2
}

define tailcc %KValue @d__fold_at_4(%KValue %x0, %KValue %x1, %KValue %x2, i64 %x3r) {
entry:
  %x3 = insertvalue %KValue { i64 0, i64 undef }, i64 %x3r, 1
  %t1 = extractvalue %KValue %x1, 0
  %t2 = icmp ne i64 %t1, 5
  %t3 = icmp ne i64 %t1, 4
  %t4 = and i1 %t2, %t3
  br i1 %t4, label %L1, label %fail0
L1:
  %t5 = call %KValue @k_b_length(%KValue %x0)
  %t6 = extractvalue %KValue %t5, 1
  %t7 = extractvalue %KValue %x3, 1
  %t8 = icmp slt i64 %t6, %t7
  %t9 = select i1 %t8, %KValue { i64 2, i64 0 }, %KValue { i64 3, i64 0 }
  %t10 = extractvalue %KValue %t9, 0
  %t11 = icmp ne i64 %t10, 5
  %t12 = icmp ne i64 %t10, 4
  %t13 = and i1 %t11, %t12
  br i1 %t13, label %L2, label %L3
L3:
  ret %KValue %t9
L2:
  %t14 = call i64 @k_truthy(%KValue %t9)
  %t15 = icmp ne i64 %t14, 0
  br i1 %t15, label %L4, label %L5
L4:
  ret %KValue %x1
L5:
  %t16 = extractvalue %KValue %x0, 0
  %t17 = icmp eq i64 %t16, 13
  %t18 = extractvalue %KValue %x3, 0
  %t19 = icmp eq i64 %t18, 0
  %t20 = and i1 %t17, %t19
  br i1 %t20, label %L6, label %L7
L6:
  %t21 = extractvalue %KValue %x0, 1
  %t22 = inttoptr i64 %t21 to ptr
  %t23 = getelementptr %KBytes, ptr %t22, i64 0, i32 0
  %t24 = load i64, ptr %t23
  %t25 = extractvalue %KValue %x3, 1
  %t26 = icmp sge i64 %t25, 1
  %t27 = icmp sle i64 %t25, %t24
  %t28 = and i1 %t26, %t27
  br i1 %t28, label %L9, label %L7
L9:
  %t29 = getelementptr %KBytes, ptr %t22, i64 0, i32 1
  %t30 = load ptr, ptr %t29
  %t31 = add i64 %t25, -1
  %t32 = getelementptr i8, ptr %t30, i64 %t31
  %t33 = load i8, ptr %t32
  %t34 = zext i8 %t33 to i64
  %t35 = insertvalue %KValue { i64 0, i64 undef }, i64 %t34, 1
  br label %L8
L7:
  %t36 = call %KValue @k_b_at(%KValue %x0, %KValue %x3)
  br label %L8
L8:
  %t37 = phi %KValue [ %t35, %L9 ], [ %t36, %L7 ]
  %t38 = call %KValue @k_call2(%KValue %x2, %KValue %x1, %KValue %t37)
  %t39 = extractvalue %KValue %x3, 1
  %t40 = extractvalue %KValue { i64 0, i64 1 }, 1
  %t41 = call { i64, i1 } @llvm.sadd.with.overflow.i64(i64 %t39, i64 %t40)
  %t42 = extractvalue { i64, i1 } %t41, 0
  %t43 = extractvalue { i64, i1 } %t41, 1
  br i1 %t43, label %L11, label %L10
L11:
  call void @k_die(ptr @s6)
  unreachable
L10:
  %t44 = insertvalue %KValue { i64 0, i64 undef }, i64 %t42, 1
  call void @k_carry_reset()
  call void @k_carry_stage(%KValue %x0)
  call void @k_carry_stage(%KValue %t38)
  call void @k_beat_iter_carry()
  %t45 = call %KValue @k_carry_take(i64 0)
  %t46 = call %KValue @k_carry_take(i64 1)
  %t47 = extractvalue %KValue %t44, 1
  %t48 = musttail call tailcc %KValue @d__fold_at_4(%KValue %t45, %KValue %t46, %KValue %x2, i64 %t47)
  ret %KValue %t48
fail0:
  %t49 = extractvalue %KValue %x0, 0
  %t50 = icmp ne i64 %t49, 5
  %t51 = icmp ne i64 %t49, 4
  %t52 = and i1 %t50, %t51
  br i1 %t52, label %L13, label %L12
L12:
  %t53 = call %KValue @k_err_hop(%KValue %x0, ptr @s5)
  ret %KValue %t53
L13:
  %t54 = extractvalue %KValue %x1, 0
  %t55 = icmp ne i64 %t54, 5
  %t56 = icmp ne i64 %t54, 4
  %t57 = and i1 %t55, %t56
  br i1 %t57, label %L15, label %L14
L14:
  %t58 = call %KValue @k_err_hop(%KValue %x1, ptr @s5)
  ret %KValue %t58
L15:
  %t59 = extractvalue %KValue %x2, 0
  %t60 = icmp ne i64 %t59, 5
  %t61 = icmp ne i64 %t59, 4
  %t62 = and i1 %t60, %t61
  br i1 %t62, label %L17, label %L16
L16:
  %t63 = call %KValue @k_err_hop(%KValue %x2, ptr @s5)
  ret %KValue %t63
L17:
  %t64 = extractvalue %KValue %x3, 0
  %t65 = icmp ne i64 %t64, 5
  %t66 = icmp ne i64 %t64, 4
  %t67 = and i1 %t65, %t66
  br i1 %t67, label %L19, label %L18
L18:
  %t68 = call %KValue @k_err_hop(%KValue %x3, ptr @s5)
  ret %KValue %t68
L19:
  call void @k_die(ptr @s7)
  unreachable
}

define tailcc %KValue @d__range_to_3(i64 %x0r, i64 %x1r, %KValue %x2) {
entry:
  %x0 = insertvalue %KValue { i64 0, i64 undef }, i64 %x0r, 1
  %x1 = insertvalue %KValue { i64 0, i64 undef }, i64 %x1r, 1
  %t1 = extractvalue %KValue %x0, 1
  %t2 = extractvalue %KValue %x1, 1
  %t3 = icmp slt i64 %t1, %t2
  %t4 = select i1 %t3, %KValue { i64 2, i64 0 }, %KValue { i64 3, i64 0 }
  %t5 = extractvalue %KValue %t4, 0
  %t6 = icmp ne i64 %t5, 5
  %t7 = icmp ne i64 %t5, 4
  %t8 = and i1 %t6, %t7
  br i1 %t8, label %L1, label %L2
L2:
  ret %KValue %t4
L1:
  %t9 = call i64 @k_truthy(%KValue %t4)
  %t10 = icmp ne i64 %t9, 0
  br i1 %t10, label %L3, label %L4
L3:
  ret %KValue %x2
L4:
  %t11 = extractvalue %KValue %x1, 1
  %t12 = extractvalue %KValue { i64 0, i64 1 }, 1
  %t13 = call { i64, i1 } @llvm.sadd.with.overflow.i64(i64 %t11, i64 %t12)
  %t14 = extractvalue { i64, i1 } %t13, 0
  %t15 = extractvalue { i64, i1 } %t13, 1
  br i1 %t15, label %L6, label %L5
L6:
  call void @k_die(ptr @s6)
  unreachable
L5:
  %t16 = insertvalue %KValue { i64 0, i64 undef }, i64 %t14, 1
  %t17 = call %KValue @k_b_push(%KValue %x2, %KValue %x1)
  %t18 = extractvalue %KValue %x0, 1
  %t19 = extractvalue %KValue %t16, 1
  %t20 = musttail call tailcc %KValue @d__range_to_3(i64 %t18, i64 %t19, %KValue %t17)
  ret %KValue %t20
fail0:
  %t21 = extractvalue %KValue %x0, 0
  %t22 = icmp ne i64 %t21, 5
  %t23 = icmp ne i64 %t21, 4
  %t24 = and i1 %t22, %t23
  br i1 %t24, label %L8, label %L7
L7:
  %t25 = call %KValue @k_err_hop(%KValue %x0, ptr @s8)
  ret %KValue %t25
L8:
  %t26 = extractvalue %KValue %x1, 0
  %t27 = icmp ne i64 %t26, 5
  %t28 = icmp ne i64 %t26, 4
  %t29 = and i1 %t27, %t28
  br i1 %t29, label %L10, label %L9
L9:
  %t30 = call %KValue @k_err_hop(%KValue %x1, ptr @s8)
  ret %KValue %t30
L10:
  %t31 = extractvalue %KValue %x2, 0
  %t32 = icmp ne i64 %t31, 5
  %t33 = icmp ne i64 %t31, 4
  %t34 = and i1 %t32, %t33
  br i1 %t34, label %L12, label %L11
L11:
  %t35 = call %KValue @k_err_hop(%KValue %x2, ptr @s8)
  ret %KValue %t35
L12:
  call void @k_die(ptr @s9)
  unreachable
}

define tailcc %KValue @klam0(ptr %env, %KValue %a0, %KValue %a1) {
entry:
  %t1 = call %KValue @k_env_get(ptr %env, i64 0)
  %t2 = extractvalue %KValue %t1, 0
  %t3 = icmp eq i64 %t2, 13
  %t4 = extractvalue %KValue %a0, 0
  %t5 = icmp eq i64 %t4, 0
  %t6 = and i1 %t3, %t5
  br i1 %t6, label %L1, label %L2
L1:
  %t7 = extractvalue %KValue %t1, 1
  %t8 = inttoptr i64 %t7 to ptr
  %t9 = getelementptr %KBytes, ptr %t8, i64 0, i32 0
  %t10 = load i64, ptr %t9
  %t11 = extractvalue %KValue %a0, 1
  %t12 = icmp sge i64 %t11, 1
  %t13 = icmp sle i64 %t11, %t10
  %t14 = and i1 %t12, %t13
  br i1 %t14, label %L4, label %L2
L4:
  %t15 = getelementptr %KBytes, ptr %t8, i64 0, i32 1
  %t16 = load ptr, ptr %t15
  %t17 = add i64 %t11, -1
  %t18 = getelementptr i8, ptr %t16, i64 %t17
  %t19 = load i8, ptr %t18
  %t20 = zext i8 %t19 to i64
  %t21 = insertvalue %KValue { i64 0, i64 undef }, i64 %t20, 1
  br label %L3
L2:
  %t22 = call %KValue @k_b_at(%KValue %t1, %KValue %a0)
  br label %L3
L3:
  %t23 = phi %KValue [ %t21, %L4 ], [ %t22, %L2 ]
  %t24 = extractvalue %KValue %t1, 0
  %t25 = icmp eq i64 %t24, 13
  %t26 = extractvalue %KValue %a1, 0
  %t27 = icmp eq i64 %t26, 0
  %t28 = and i1 %t25, %t27
  br i1 %t28, label %L5, label %L6
L5:
  %t29 = extractvalue %KValue %t1, 1
  %t30 = inttoptr i64 %t29 to ptr
  %t31 = getelementptr %KBytes, ptr %t30, i64 0, i32 0
  %t32 = load i64, ptr %t31
  %t33 = extractvalue %KValue %a1, 1
  %t34 = icmp sge i64 %t33, 1
  %t35 = icmp sle i64 %t33, %t32
  %t36 = and i1 %t34, %t35
  br i1 %t36, label %L8, label %L6
L8:
  %t37 = getelementptr %KBytes, ptr %t30, i64 0, i32 1
  %t38 = load ptr, ptr %t37
  %t39 = add i64 %t33, -1
  %t40 = getelementptr i8, ptr %t38, i64 %t39
  %t41 = load i8, ptr %t40
  %t42 = zext i8 %t41 to i64
  %t43 = insertvalue %KValue { i64 0, i64 undef }, i64 %t42, 1
  br label %L7
L6:
  %t44 = call %KValue @k_b_at(%KValue %t1, %KValue %a1)
  br label %L7
L7:
  %t45 = phi %KValue [ %t43, %L8 ], [ %t44, %L6 ]
  %t46 = extractvalue %KValue %t23, 0
  %t47 = extractvalue %KValue %t45, 0
  %t48 = icmp eq i64 %t46, 0
  %t49 = icmp eq i64 %t47, 0
  %t50 = and i1 %t48, %t49
  br i1 %t50, label %L9, label %L10
L9:
  %t51 = extractvalue %KValue %t23, 1
  %t52 = extractvalue %KValue %t45, 1
  %t53 = icmp slt i64 %t51, %t52
  %t54 = select i1 %t53, %KValue { i64 2, i64 0 }, %KValue { i64 3, i64 0 }
  br label %L11
L10:
  %t55 = call %KValue @k_cmp(%KValue %t23, %KValue %t45, i64 2)
  br label %L11
L11:
  %t56 = phi %KValue [ %t54, %L9 ], [ %t55, %L10 ]
  %t57 = extractvalue %KValue %t56, 0
  %t58 = icmp ne i64 %t57, 5
  %t59 = icmp ne i64 %t57, 4
  %t60 = and i1 %t58, %t59
  br i1 %t60, label %L12, label %L13
L13:
  ret %KValue %t56
L12:
  %t61 = call i64 @k_truthy(%KValue %t56)
  %t62 = icmp ne i64 %t61, 0
  br i1 %t62, label %L14, label %L15
L14:
  ret %KValue %a1
L15:
  ret %KValue %a0
}

define %KValue @w_klam0(ptr %env, %KValue %a0, %KValue %a1) {
entry:
  %r = call tailcc %KValue @klam0(ptr %env, %KValue %a0, %KValue %a1)
  ret %KValue %r
}

define tailcc %KValue @d_argmax_1(%KValue %x0) {
entry:
  %t1 = call %KValue @k_b_length(%KValue %x0)
  %t2 = extractvalue %KValue %t1, 1
  %t3 = call tailcc %KValue @d_range_1(i64 %t2)
  %t4 = alloca [1 x %KValue]
  %t5 = getelementptr [1 x %KValue], ptr %t4, i64 0, i64 0
  store %KValue %x0, ptr %t5
  %t6 = call %KValue @k_closure(ptr @w_klam0, i64 1, ptr %t4)
  %t7 = musttail call tailcc %KValue @d_fold_3(%KValue %t3, %KValue { i64 0, i64 1 }, %KValue %t6)
  ret %KValue %t7
fail0:
  %t8 = extractvalue %KValue %x0, 0
  %t9 = icmp ne i64 %t8, 5
  %t10 = icmp ne i64 %t8, 4
  %t11 = and i1 %t9, %t10
  br i1 %t11, label %L2, label %L1
L1:
  %t12 = call %KValue @k_err_hop(%KValue %x0, ptr @s10)
  ret %KValue %t12
L2:
  call void @k_die(ptr @s11)
  unreachable
}

define tailcc %KValue @klam1(ptr %env, %KValue %a0, %KValue %a1) {
entry:
  %t1 = call %KValue @k_env_get(ptr %env, i64 0)
  %t2 = extractvalue %KValue %a1, 0
  %t3 = extractvalue %KValue %t1, 0
  %t4 = icmp eq i64 %t2, 0
  %t5 = icmp eq i64 %t3, 0
  %t6 = and i1 %t4, %t5
  br i1 %t6, label %L1, label %L2
L1:
  %t7 = extractvalue %KValue %a1, 1
  %t8 = extractvalue %KValue %t1, 1
  %t9 = icmp eq i64 %t7, %t8
  %t10 = select i1 %t9, %KValue { i64 2, i64 0 }, %KValue { i64 3, i64 0 }
  br label %L3
L2:
  %t11 = call %KValue @k_cmp(%KValue %a1, %KValue %t1, i64 0)
  br label %L3
L3:
  %t12 = phi %KValue [ %t10, %L1 ], [ %t11, %L2 ]
  %t13 = extractvalue %KValue %t12, 0
  %t14 = icmp ne i64 %t13, 5
  %t15 = icmp ne i64 %t13, 4
  %t16 = and i1 %t14, %t15
  br i1 %t16, label %L4, label %L5
L5:
  ret %KValue %t12
L4:
  %t17 = call i64 @k_truthy(%KValue %t12)
  %t18 = icmp ne i64 %t17, 0
  br i1 %t18, label %L6, label %L7
L6:
  %t19 = extractvalue %KValue %a0, 0
  %t20 = extractvalue %KValue { i64 0, i64 1 }, 0
  %t21 = icmp eq i64 %t19, 0
  %t22 = icmp eq i64 %t20, 0
  %t23 = and i1 %t21, %t22
  br i1 %t23, label %L8, label %L9
L8:
  %t24 = extractvalue %KValue %a0, 1
  %t25 = extractvalue %KValue { i64 0, i64 1 }, 1
  %t26 = call { i64, i1 } @llvm.sadd.with.overflow.i64(i64 %t24, i64 %t25)
  %t27 = extractvalue { i64, i1 } %t26, 0
  %t28 = extractvalue { i64, i1 } %t26, 1
  br i1 %t28, label %L9, label %L11
L11:
  %t29 = insertvalue %KValue { i64 0, i64 undef }, i64 %t27, 1
  br label %L10
L9:
  %t30 = call %KValue @k_add(%KValue %a0, %KValue { i64 0, i64 1 })
  br label %L10
L10:
  %t31 = phi %KValue [ %t29, %L11 ], [ %t30, %L9 ]
  ret %KValue %t31
L7:
  ret %KValue %a0
}

define %KValue @w_klam1(ptr %env, %KValue %a0, %KValue %a1) {
entry:
  %r = call tailcc %KValue @klam1(ptr %env, %KValue %a0, %KValue %a1)
  ret %KValue %r
}

define tailcc %KValue @d_count_2(%KValue %x0, %KValue %x1) {
entry:
  %t1 = alloca [1 x %KValue]
  %t2 = getelementptr [1 x %KValue], ptr %t1, i64 0, i64 0
  store %KValue %x1, ptr %t2
  %t3 = call %KValue @k_closure(ptr @w_klam1, i64 1, ptr %t1)
  %t4 = musttail call tailcc %KValue @d_fold_3(%KValue %x0, %KValue { i64 0, i64 0 }, %KValue %t3)
  ret %KValue %t4
fail0:
  %t5 = extractvalue %KValue %x0, 0
  %t6 = icmp ne i64 %t5, 5
  %t7 = icmp ne i64 %t5, 4
  %t8 = and i1 %t6, %t7
  br i1 %t8, label %L2, label %L1
L1:
  %t9 = call %KValue @k_err_hop(%KValue %x0, ptr @s12)
  ret %KValue %t9
L2:
  %t10 = extractvalue %KValue %x1, 0
  %t11 = icmp ne i64 %t10, 5
  %t12 = icmp ne i64 %t10, 4
  %t13 = and i1 %t11, %t12
  br i1 %t13, label %L4, label %L3
L3:
  %t14 = call %KValue @k_err_hop(%KValue %x1, ptr @s12)
  ret %KValue %t14
L4:
  call void @k_die(ptr @s13)
  unreachable
}

define tailcc %KValue @d_fold_3(%KValue %x0, %KValue %x1, %KValue %x2) {
entry:
  %t1 = extractvalue %KValue %x1, 0
  %t2 = icmp ne i64 %t1, 5
  %t3 = icmp ne i64 %t1, 4
  %t4 = and i1 %t2, %t3
  br i1 %t4, label %L1, label %fail0
L1:
  %t5 = extractvalue %KValue { i64 0, i64 1 }, 1
  call void @k_beat_push()
  %t6 = call tailcc %KValue @d__fold_at_4(%KValue %x0, %KValue %x1, %KValue %x2, i64 %t5)
  %t7 = call %KValue @k_beat_pop(%KValue %t6)
  ret %KValue %t7
fail0:
  %t8 = extractvalue %KValue %x0, 0
  %t9 = icmp ne i64 %t8, 5
  %t10 = icmp ne i64 %t8, 4
  %t11 = and i1 %t9, %t10
  br i1 %t11, label %L3, label %L2
L2:
  %t12 = call %KValue @k_err_hop(%KValue %x0, ptr @s14)
  ret %KValue %t12
L3:
  %t13 = extractvalue %KValue %x1, 0
  %t14 = icmp ne i64 %t13, 5
  %t15 = icmp ne i64 %t13, 4
  %t16 = and i1 %t14, %t15
  br i1 %t16, label %L5, label %L4
L4:
  %t17 = call %KValue @k_err_hop(%KValue %x1, ptr @s14)
  ret %KValue %t17
L5:
  %t18 = extractvalue %KValue %x2, 0
  %t19 = icmp ne i64 %t18, 5
  %t20 = icmp ne i64 %t18, 4
  %t21 = and i1 %t19, %t20
  br i1 %t21, label %L7, label %L6
L6:
  %t22 = call %KValue @k_err_hop(%KValue %x2, ptr @s14)
  ret %KValue %t22
L7:
  call void @k_die(ptr @s15)
  unreachable
}

define tailcc %KValue @klam2(ptr %env, %KValue %a0, %KValue %a1) {
entry:
  %t1 = extractvalue %KValue %a0, 0
  %t2 = extractvalue %KValue %a1, 0
  %t3 = icmp eq i64 %t1, 0
  %t4 = icmp eq i64 %t2, 0
  %t5 = and i1 %t3, %t4
  br i1 %t5, label %L1, label %L2
L1:
  %t6 = extractvalue %KValue %a0, 1
  %t7 = extractvalue %KValue %a1, 1
  %t8 = icmp slt i64 %t6, %t7
  %t9 = select i1 %t8, %KValue { i64 2, i64 0 }, %KValue { i64 3, i64 0 }
  br label %L3
L2:
  %t10 = call %KValue @k_cmp(%KValue %a0, %KValue %a1, i64 2)
  br label %L3
L3:
  %t11 = phi %KValue [ %t9, %L1 ], [ %t10, %L2 ]
  %t12 = extractvalue %KValue %t11, 0
  %t13 = icmp ne i64 %t12, 5
  %t14 = icmp ne i64 %t12, 4
  %t15 = and i1 %t13, %t14
  br i1 %t15, label %L4, label %L5
L5:
  ret %KValue %t11
L4:
  %t16 = call i64 @k_truthy(%KValue %t11)
  %t17 = icmp ne i64 %t16, 0
  br i1 %t17, label %L6, label %L7
L6:
  ret %KValue %a1
L7:
  ret %KValue %a0
}

define %KValue @w_klam2(ptr %env, %KValue %a0, %KValue %a1) {
entry:
  %r = call tailcc %KValue @klam2(ptr %env, %KValue %a0, %KValue %a1)
  ret %KValue %r
}

define tailcc %KValue @d_maximum_1(%KValue %x0) {
entry:
  %t1 = extractvalue %KValue %x0, 0
  %t2 = icmp eq i64 %t1, 13
  %t3 = extractvalue %KValue { i64 0, i64 1 }, 0
  %t4 = icmp eq i64 %t3, 0
  %t5 = and i1 %t2, %t4
  br i1 %t5, label %L1, label %L2
L1:
  %t6 = extractvalue %KValue %x0, 1
  %t7 = inttoptr i64 %t6 to ptr
  %t8 = getelementptr %KBytes, ptr %t7, i64 0, i32 0
  %t9 = load i64, ptr %t8
  %t10 = extractvalue %KValue { i64 0, i64 1 }, 1
  %t11 = icmp sge i64 %t10, 1
  %t12 = icmp sle i64 %t10, %t9
  %t13 = and i1 %t11, %t12
  br i1 %t13, label %L4, label %L2
L4:
  %t14 = getelementptr %KBytes, ptr %t7, i64 0, i32 1
  %t15 = load ptr, ptr %t14
  %t16 = add i64 %t10, -1
  %t17 = getelementptr i8, ptr %t15, i64 %t16
  %t18 = load i8, ptr %t17
  %t19 = zext i8 %t18 to i64
  %t20 = insertvalue %KValue { i64 0, i64 undef }, i64 %t19, 1
  br label %L3
L2:
  %t21 = call %KValue @k_b_at(%KValue %x0, %KValue { i64 0, i64 1 })
  br label %L3
L3:
  %t22 = phi %KValue [ %t20, %L4 ], [ %t21, %L2 ]
  %t23 = alloca [1 x %KValue]
  %t24 = call %KValue @k_closure(ptr @w_klam2, i64 0, ptr %t23)
  %t25 = musttail call tailcc %KValue @d_fold_3(%KValue %x0, %KValue %t22, %KValue %t24)
  ret %KValue %t25
fail0:
  %t26 = extractvalue %KValue %x0, 0
  %t27 = icmp ne i64 %t26, 5
  %t28 = icmp ne i64 %t26, 4
  %t29 = and i1 %t27, %t28
  br i1 %t29, label %L6, label %L5
L5:
  %t30 = call %KValue @k_err_hop(%KValue %x0, ptr @s16)
  ret %KValue %t30
L6:
  call void @k_die(ptr @s17)
  unreachable
}

define tailcc %KValue @d_mean_1(%KValue %x0) {
entry:
  %t1 = call %KValue @k_float(double 0x0000000000000000)
  %t2 = call tailcc %KValue @d_total_1(%KValue %x0)
  %t3 = extractvalue %KValue %t1, 0
  %t4 = extractvalue %KValue %t2, 0
  %t5 = icmp eq i64 %t3, 0
  %t6 = icmp eq i64 %t4, 0
  %t7 = and i1 %t5, %t6
  br i1 %t7, label %L1, label %L2
L1:
  %t8 = extractvalue %KValue %t1, 1
  %t9 = extractvalue %KValue %t2, 1
  %t10 = call { i64, i1 } @llvm.sadd.with.overflow.i64(i64 %t8, i64 %t9)
  %t11 = extractvalue { i64, i1 } %t10, 0
  %t12 = extractvalue { i64, i1 } %t10, 1
  br i1 %t12, label %L2, label %L4
L4:
  %t13 = insertvalue %KValue { i64 0, i64 undef }, i64 %t11, 1
  br label %L3
L2:
  %t14 = call %KValue @k_add(%KValue %t1, %KValue %t2)
  br label %L3
L3:
  %t15 = phi %KValue [ %t13, %L4 ], [ %t14, %L2 ]
  %t16 = call %KValue @k_b_length(%KValue %x0)
  %t17 = call %KValue @k_div(%KValue %t15, %KValue %t16, ptr @s19)
  ret %KValue %t17
fail0:
  %t18 = extractvalue %KValue %x0, 0
  %t19 = icmp ne i64 %t18, 5
  %t20 = icmp ne i64 %t18, 4
  %t21 = and i1 %t19, %t20
  br i1 %t21, label %L6, label %L5
L5:
  %t22 = call %KValue @k_err_hop(%KValue %x0, ptr @s18)
  ret %KValue %t22
L6:
  call void @k_die(ptr @s20)
  unreachable
}

define tailcc %KValue @klam3(ptr %env, %KValue %a0, %KValue %a1) {
entry:
  %t1 = extractvalue %KValue %a1, 0
  %t2 = extractvalue %KValue %a0, 0
  %t3 = icmp eq i64 %t1, 0
  %t4 = icmp eq i64 %t2, 0
  %t5 = and i1 %t3, %t4
  br i1 %t5, label %L1, label %L2
L1:
  %t6 = extractvalue %KValue %a1, 1
  %t7 = extractvalue %KValue %a0, 1
  %t8 = icmp slt i64 %t6, %t7
  %t9 = select i1 %t8, %KValue { i64 2, i64 0 }, %KValue { i64 3, i64 0 }
  br label %L3
L2:
  %t10 = call %KValue @k_cmp(%KValue %a1, %KValue %a0, i64 2)
  br label %L3
L3:
  %t11 = phi %KValue [ %t9, %L1 ], [ %t10, %L2 ]
  %t12 = extractvalue %KValue %t11, 0
  %t13 = icmp ne i64 %t12, 5
  %t14 = icmp ne i64 %t12, 4
  %t15 = and i1 %t13, %t14
  br i1 %t15, label %L4, label %L5
L5:
  ret %KValue %t11
L4:
  %t16 = call i64 @k_truthy(%KValue %t11)
  %t17 = icmp ne i64 %t16, 0
  br i1 %t17, label %L6, label %L7
L6:
  ret %KValue %a1
L7:
  ret %KValue %a0
}

define %KValue @w_klam3(ptr %env, %KValue %a0, %KValue %a1) {
entry:
  %r = call tailcc %KValue @klam3(ptr %env, %KValue %a0, %KValue %a1)
  ret %KValue %r
}

define tailcc %KValue @d_minimum_1(%KValue %x0) {
entry:
  %t1 = extractvalue %KValue %x0, 0
  %t2 = icmp eq i64 %t1, 13
  %t3 = extractvalue %KValue { i64 0, i64 1 }, 0
  %t4 = icmp eq i64 %t3, 0
  %t5 = and i1 %t2, %t4
  br i1 %t5, label %L1, label %L2
L1:
  %t6 = extractvalue %KValue %x0, 1
  %t7 = inttoptr i64 %t6 to ptr
  %t8 = getelementptr %KBytes, ptr %t7, i64 0, i32 0
  %t9 = load i64, ptr %t8
  %t10 = extractvalue %KValue { i64 0, i64 1 }, 1
  %t11 = icmp sge i64 %t10, 1
  %t12 = icmp sle i64 %t10, %t9
  %t13 = and i1 %t11, %t12
  br i1 %t13, label %L4, label %L2
L4:
  %t14 = getelementptr %KBytes, ptr %t7, i64 0, i32 1
  %t15 = load ptr, ptr %t14
  %t16 = add i64 %t10, -1
  %t17 = getelementptr i8, ptr %t15, i64 %t16
  %t18 = load i8, ptr %t17
  %t19 = zext i8 %t18 to i64
  %t20 = insertvalue %KValue { i64 0, i64 undef }, i64 %t19, 1
  br label %L3
L2:
  %t21 = call %KValue @k_b_at(%KValue %x0, %KValue { i64 0, i64 1 })
  br label %L3
L3:
  %t22 = phi %KValue [ %t20, %L4 ], [ %t21, %L2 ]
  %t23 = alloca [1 x %KValue]
  %t24 = call %KValue @k_closure(ptr @w_klam3, i64 0, ptr %t23)
  %t25 = musttail call tailcc %KValue @d_fold_3(%KValue %x0, %KValue %t22, %KValue %t24)
  ret %KValue %t25
fail0:
  %t26 = extractvalue %KValue %x0, 0
  %t27 = icmp ne i64 %t26, 5
  %t28 = icmp ne i64 %t26, 4
  %t29 = and i1 %t27, %t28
  br i1 %t29, label %L6, label %L5
L5:
  %t30 = call %KValue @k_err_hop(%KValue %x0, ptr @s21)
  ret %KValue %t30
L6:
  call void @k_die(ptr @s22)
  unreachable
}

define tailcc %KValue @d_range_1(i64 %x0r) {
entry:
  %x0 = insertvalue %KValue { i64 0, i64 undef }, i64 %x0r, 1
  %t1 = alloca [1 x %KValue]
  %t2 = call %KValue @k_list_lit(i64 0, ptr %t1)
  %t3 = extractvalue %KValue %x0, 1
  %t4 = extractvalue %KValue { i64 0, i64 1 }, 1
  %t5 = musttail call tailcc %KValue @d__range_to_3(i64 %t3, i64 %t4, %KValue %t2)
  ret %KValue %t5
fail0:
  %t6 = extractvalue %KValue %x0, 0
  %t7 = icmp ne i64 %t6, 5
  %t8 = icmp ne i64 %t6, 4
  %t9 = and i1 %t7, %t8
  br i1 %t9, label %L2, label %L1
L1:
  %t10 = call %KValue @k_err_hop(%KValue %x0, ptr @s23)
  ret %KValue %t10
L2:
  call void @k_die(ptr @s24)
  unreachable
}

define tailcc %KValue @klam4(ptr %env, %KValue %a0, %KValue %a1) {
entry:
  %t1 = extractvalue %KValue %a0, 0
  %t2 = extractvalue %KValue %a1, 0
  %t3 = icmp eq i64 %t1, 0
  %t4 = icmp eq i64 %t2, 0
  %t5 = and i1 %t3, %t4
  br i1 %t5, label %L1, label %L2
L1:
  %t6 = extractvalue %KValue %a0, 1
  %t7 = extractvalue %KValue %a1, 1
  %t8 = call { i64, i1 } @llvm.sadd.with.overflow.i64(i64 %t6, i64 %t7)
  %t9 = extractvalue { i64, i1 } %t8, 0
  %t10 = extractvalue { i64, i1 } %t8, 1
  br i1 %t10, label %L2, label %L4
L4:
  %t11 = insertvalue %KValue { i64 0, i64 undef }, i64 %t9, 1
  br label %L3
L2:
  %t12 = call %KValue @k_add(%KValue %a0, %KValue %a1)
  br label %L3
L3:
  %t13 = phi %KValue [ %t11, %L4 ], [ %t12, %L2 ]
  ret %KValue %t13
}

define %KValue @w_klam4(ptr %env, %KValue %a0, %KValue %a1) {
entry:
  %r = call tailcc %KValue @klam4(ptr %env, %KValue %a0, %KValue %a1)
  ret %KValue %r
}

define tailcc %KValue @d_total_1(%KValue %x0) {
entry:
  %t1 = alloca [1 x %KValue]
  %t2 = call %KValue @k_closure(ptr @w_klam4, i64 0, ptr %t1)
  %t3 = musttail call tailcc %KValue @d_fold_3(%KValue %x0, %KValue { i64 0, i64 0 }, %KValue %t2)
  ret %KValue %t3
fail0:
  %t4 = extractvalue %KValue %x0, 0
  %t5 = icmp ne i64 %t4, 5
  %t6 = icmp ne i64 %t4, 4
  %t7 = and i1 %t5, %t6
  br i1 %t7, label %L2, label %L1
L1:
  %t8 = call %KValue @k_err_hop(%KValue %x0, ptr @s25)
  ret %KValue %t8
L2:
  call void @k_die(ptr @s26)
  unreachable
}

define tailcc %KValue @d__sq_1(%KValue %x0) {
entry:
  %t1 = extractvalue %KValue %x0, 0
  %t2 = icmp ne i64 %t1, 5
  %t3 = icmp ne i64 %t1, 4
  %t4 = and i1 %t2, %t3
  br i1 %t4, label %L1, label %fail0
L1:
  %t5 = extractvalue %KValue %x0, 0
  %t6 = extractvalue %KValue %x0, 0
  %t7 = icmp eq i64 %t5, 0
  %t8 = icmp eq i64 %t6, 0
  %t9 = and i1 %t7, %t8
  br i1 %t9, label %L2, label %L3
L2:
  %t10 = extractvalue %KValue %x0, 1
  %t11 = extractvalue %KValue %x0, 1
  %t12 = call { i64, i1 } @llvm.smul.with.overflow.i64(i64 %t10, i64 %t11)
  %t13 = extractvalue { i64, i1 } %t12, 0
  %t14 = extractvalue { i64, i1 } %t12, 1
  br i1 %t14, label %L3, label %L5
L5:
  %t15 = insertvalue %KValue { i64 0, i64 undef }, i64 %t13, 1
  br label %L4
L3:
  %t16 = call %KValue @k_mul(%KValue %x0, %KValue %x0)
  br label %L4
L4:
  %t17 = phi %KValue [ %t15, %L5 ], [ %t16, %L3 ]
  ret %KValue %t17
fail0:
  %t18 = extractvalue %KValue %x0, 0
  %t19 = icmp ne i64 %t18, 5
  %t20 = icmp ne i64 %t18, 4
  %t21 = and i1 %t19, %t20
  br i1 %t21, label %L7, label %L6
L6:
  %t22 = call %KValue @k_err_hop(%KValue %x0, ptr @s27)
  ret %KValue %t22
L7:
  call void @k_die(ptr @s28)
  unreachable
}

define tailcc %KValue @d__tally_2(%KValue %x0, %KValue %x1) {
entry:
  %t1 = call tailcc %KValue @d_socutils_1(%KValue %x1)
  %t2 = extractvalue %KValue %x0, 0
  %t3 = icmp eq i64 %t2, 13
  %t4 = extractvalue %KValue { i64 0, i64 1 }, 0
  %t5 = icmp eq i64 %t4, 0
  %t6 = and i1 %t3, %t5
  br i1 %t6, label %L1, label %L2
L1:
  %t7 = extractvalue %KValue %x0, 1
  %t8 = inttoptr i64 %t7 to ptr
  %t9 = getelementptr %KBytes, ptr %t8, i64 0, i32 0
  %t10 = load i64, ptr %t9
  %t11 = extractvalue %KValue { i64 0, i64 1 }, 1
  %t12 = icmp sge i64 %t11, 1
  %t13 = icmp sle i64 %t11, %t10
  %t14 = and i1 %t12, %t13
  br i1 %t14, label %L4, label %L2
L4:
  %t15 = getelementptr %KBytes, ptr %t8, i64 0, i32 1
  %t16 = load ptr, ptr %t15
  %t17 = add i64 %t11, -1
  %t18 = getelementptr i8, ptr %t16, i64 %t17
  %t19 = load i8, ptr %t18
  %t20 = zext i8 %t19 to i64
  %t21 = insertvalue %KValue { i64 0, i64 undef }, i64 %t20, 1
  br label %L3
L2:
  %t22 = call %KValue @k_b_at(%KValue %x0, %KValue { i64 0, i64 1 })
  br label %L3
L3:
  %t23 = phi %KValue [ %t21, %L4 ], [ %t22, %L2 ]
  %t24 = call tailcc %KValue @d_plurality_winner_1(%KValue %x1)
  %t25 = call tailcc %KValue @d_vse_2(%KValue %t1, %KValue %t24)
  %t26 = extractvalue %KValue %t23, 0
  %t27 = extractvalue %KValue %t25, 0
  %t28 = icmp eq i64 %t26, 0
  %t29 = icmp eq i64 %t27, 0
  %t30 = and i1 %t28, %t29
  br i1 %t30, label %L5, label %L6
L5:
  %t31 = extractvalue %KValue %t23, 1
  %t32 = extractvalue %KValue %t25, 1
  %t33 = call { i64, i1 } @llvm.sadd.with.overflow.i64(i64 %t31, i64 %t32)
  %t34 = extractvalue { i64, i1 } %t33, 0
  %t35 = extractvalue { i64, i1 } %t33, 1
  br i1 %t35, label %L6, label %L8
L8:
  %t36 = insertvalue %KValue { i64 0, i64 undef }, i64 %t34, 1
  br label %L7
L6:
  %t37 = call %KValue @k_add(%KValue %t23, %KValue %t25)
  br label %L7
L7:
  %t38 = phi %KValue [ %t36, %L8 ], [ %t37, %L6 ]
  %t39 = extractvalue %KValue %x0, 0
  %t40 = icmp eq i64 %t39, 13
  %t41 = extractvalue %KValue { i64 0, i64 2 }, 0
  %t42 = icmp eq i64 %t41, 0
  %t43 = and i1 %t40, %t42
  br i1 %t43, label %L9, label %L10
L9:
  %t44 = extractvalue %KValue %x0, 1
  %t45 = inttoptr i64 %t44 to ptr
  %t46 = getelementptr %KBytes, ptr %t45, i64 0, i32 0
  %t47 = load i64, ptr %t46
  %t48 = extractvalue %KValue { i64 0, i64 2 }, 1
  %t49 = icmp sge i64 %t48, 1
  %t50 = icmp sle i64 %t48, %t47
  %t51 = and i1 %t49, %t50
  br i1 %t51, label %L12, label %L10
L12:
  %t52 = getelementptr %KBytes, ptr %t45, i64 0, i32 1
  %t53 = load ptr, ptr %t52
  %t54 = add i64 %t48, -1
  %t55 = getelementptr i8, ptr %t53, i64 %t54
  %t56 = load i8, ptr %t55
  %t57 = zext i8 %t56 to i64
  %t58 = insertvalue %KValue { i64 0, i64 undef }, i64 %t57, 1
  br label %L11
L10:
  %t59 = call %KValue @k_b_at(%KValue %x0, %KValue { i64 0, i64 2 })
  br label %L11
L11:
  %t60 = phi %KValue [ %t58, %L12 ], [ %t59, %L10 ]
  %t61 = call tailcc %KValue @d_approval_winner_1(%KValue %x1)
  %t62 = call tailcc %KValue @d_vse_2(%KValue %t1, %KValue %t61)
  %t63 = extractvalue %KValue %t60, 0
  %t64 = extractvalue %KValue %t62, 0
  %t65 = icmp eq i64 %t63, 0
  %t66 = icmp eq i64 %t64, 0
  %t67 = and i1 %t65, %t66
  br i1 %t67, label %L13, label %L14
L13:
  %t68 = extractvalue %KValue %t60, 1
  %t69 = extractvalue %KValue %t62, 1
  %t70 = call { i64, i1 } @llvm.sadd.with.overflow.i64(i64 %t68, i64 %t69)
  %t71 = extractvalue { i64, i1 } %t70, 0
  %t72 = extractvalue { i64, i1 } %t70, 1
  br i1 %t72, label %L14, label %L16
L16:
  %t73 = insertvalue %KValue { i64 0, i64 undef }, i64 %t71, 1
  br label %L15
L14:
  %t74 = call %KValue @k_add(%KValue %t60, %KValue %t62)
  br label %L15
L15:
  %t75 = phi %KValue [ %t73, %L16 ], [ %t74, %L14 ]
  %t76 = extractvalue %KValue %x0, 0
  %t77 = icmp eq i64 %t76, 13
  %t78 = extractvalue %KValue { i64 0, i64 3 }, 0
  %t79 = icmp eq i64 %t78, 0
  %t80 = and i1 %t77, %t79
  br i1 %t80, label %L17, label %L18
L17:
  %t81 = extractvalue %KValue %x0, 1
  %t82 = inttoptr i64 %t81 to ptr
  %t83 = getelementptr %KBytes, ptr %t82, i64 0, i32 0
  %t84 = load i64, ptr %t83
  %t85 = extractvalue %KValue { i64 0, i64 3 }, 1
  %t86 = icmp sge i64 %t85, 1
  %t87 = icmp sle i64 %t85, %t84
  %t88 = and i1 %t86, %t87
  br i1 %t88, label %L20, label %L18
L20:
  %t89 = getelementptr %KBytes, ptr %t82, i64 0, i32 1
  %t90 = load ptr, ptr %t89
  %t91 = add i64 %t85, -1
  %t92 = getelementptr i8, ptr %t90, i64 %t91
  %t93 = load i8, ptr %t92
  %t94 = zext i8 %t93 to i64
  %t95 = insertvalue %KValue { i64 0, i64 undef }, i64 %t94, 1
  br label %L19
L18:
  %t96 = call %KValue @k_b_at(%KValue %x0, %KValue { i64 0, i64 3 })
  br label %L19
L19:
  %t97 = phi %KValue [ %t95, %L20 ], [ %t96, %L18 ]
  %t98 = call tailcc %KValue @d_score_winner_1(%KValue %x1)
  %t99 = call tailcc %KValue @d_vse_2(%KValue %t1, %KValue %t98)
  %t100 = extractvalue %KValue %t97, 0
  %t101 = extractvalue %KValue %t99, 0
  %t102 = icmp eq i64 %t100, 0
  %t103 = icmp eq i64 %t101, 0
  %t104 = and i1 %t102, %t103
  br i1 %t104, label %L21, label %L22
L21:
  %t105 = extractvalue %KValue %t97, 1
  %t106 = extractvalue %KValue %t99, 1
  %t107 = call { i64, i1 } @llvm.sadd.with.overflow.i64(i64 %t105, i64 %t106)
  %t108 = extractvalue { i64, i1 } %t107, 0
  %t109 = extractvalue { i64, i1 } %t107, 1
  br i1 %t109, label %L22, label %L24
L24:
  %t110 = insertvalue %KValue { i64 0, i64 undef }, i64 %t108, 1
  br label %L23
L22:
  %t111 = call %KValue @k_add(%KValue %t97, %KValue %t99)
  br label %L23
L23:
  %t112 = phi %KValue [ %t110, %L24 ], [ %t111, %L22 ]
  %t113 = extractvalue %KValue %x0, 0
  %t114 = icmp eq i64 %t113, 13
  %t115 = extractvalue %KValue { i64 0, i64 4 }, 0
  %t116 = icmp eq i64 %t115, 0
  %t117 = and i1 %t114, %t116
  br i1 %t117, label %L25, label %L26
L25:
  %t118 = extractvalue %KValue %x0, 1
  %t119 = inttoptr i64 %t118 to ptr
  %t120 = getelementptr %KBytes, ptr %t119, i64 0, i32 0
  %t121 = load i64, ptr %t120
  %t122 = extractvalue %KValue { i64 0, i64 4 }, 1
  %t123 = icmp sge i64 %t122, 1
  %t124 = icmp sle i64 %t122, %t121
  %t125 = and i1 %t123, %t124
  br i1 %t125, label %L28, label %L26
L28:
  %t126 = getelementptr %KBytes, ptr %t119, i64 0, i32 1
  %t127 = load ptr, ptr %t126
  %t128 = add i64 %t122, -1
  %t129 = getelementptr i8, ptr %t127, i64 %t128
  %t130 = load i8, ptr %t129
  %t131 = zext i8 %t130 to i64
  %t132 = insertvalue %KValue { i64 0, i64 undef }, i64 %t131, 1
  br label %L27
L26:
  %t133 = call %KValue @k_b_at(%KValue %x0, %KValue { i64 0, i64 4 })
  br label %L27
L27:
  %t134 = phi %KValue [ %t132, %L28 ], [ %t133, %L26 ]
  %t135 = call tailcc %KValue @d_star_winner_1(%KValue %x1)
  %t136 = call tailcc %KValue @d_vse_2(%KValue %t1, %KValue %t135)
  %t137 = extractvalue %KValue %t134, 0
  %t138 = extractvalue %KValue %t136, 0
  %t139 = icmp eq i64 %t137, 0
  %t140 = icmp eq i64 %t138, 0
  %t141 = and i1 %t139, %t140
  br i1 %t141, label %L29, label %L30
L29:
  %t142 = extractvalue %KValue %t134, 1
  %t143 = extractvalue %KValue %t136, 1
  %t144 = call { i64, i1 } @llvm.sadd.with.overflow.i64(i64 %t142, i64 %t143)
  %t145 = extractvalue { i64, i1 } %t144, 0
  %t146 = extractvalue { i64, i1 } %t144, 1
  br i1 %t146, label %L30, label %L32
L32:
  %t147 = insertvalue %KValue { i64 0, i64 undef }, i64 %t145, 1
  br label %L31
L30:
  %t148 = call %KValue @k_add(%KValue %t134, %KValue %t136)
  br label %L31
L31:
  %t149 = phi %KValue [ %t147, %L32 ], [ %t148, %L30 ]
  %t150 = extractvalue %KValue %x0, 0
  %t151 = icmp eq i64 %t150, 13
  %t152 = extractvalue %KValue { i64 0, i64 5 }, 0
  %t153 = icmp eq i64 %t152, 0
  %t154 = and i1 %t151, %t153
  br i1 %t154, label %L33, label %L34
L33:
  %t155 = extractvalue %KValue %x0, 1
  %t156 = inttoptr i64 %t155 to ptr
  %t157 = getelementptr %KBytes, ptr %t156, i64 0, i32 0
  %t158 = load i64, ptr %t157
  %t159 = extractvalue %KValue { i64 0, i64 5 }, 1
  %t160 = icmp sge i64 %t159, 1
  %t161 = icmp sle i64 %t159, %t158
  %t162 = and i1 %t160, %t161
  br i1 %t162, label %L36, label %L34
L36:
  %t163 = getelementptr %KBytes, ptr %t156, i64 0, i32 1
  %t164 = load ptr, ptr %t163
  %t165 = add i64 %t159, -1
  %t166 = getelementptr i8, ptr %t164, i64 %t165
  %t167 = load i8, ptr %t166
  %t168 = zext i8 %t167 to i64
  %t169 = insertvalue %KValue { i64 0, i64 undef }, i64 %t168, 1
  br label %L35
L34:
  %t170 = call %KValue @k_b_at(%KValue %x0, %KValue { i64 0, i64 5 })
  br label %L35
L35:
  %t171 = phi %KValue [ %t169, %L36 ], [ %t170, %L34 ]
  %t172 = call tailcc %KValue @d_irv_winner_1(%KValue %x1)
  %t173 = call tailcc %KValue @d_vse_2(%KValue %t1, %KValue %t172)
  %t174 = extractvalue %KValue %t171, 0
  %t175 = extractvalue %KValue %t173, 0
  %t176 = icmp eq i64 %t174, 0
  %t177 = icmp eq i64 %t175, 0
  %t178 = and i1 %t176, %t177
  br i1 %t178, label %L37, label %L38
L37:
  %t179 = extractvalue %KValue %t171, 1
  %t180 = extractvalue %KValue %t173, 1
  %t181 = call { i64, i1 } @llvm.sadd.with.overflow.i64(i64 %t179, i64 %t180)
  %t182 = extractvalue { i64, i1 } %t181, 0
  %t183 = extractvalue { i64, i1 } %t181, 1
  br i1 %t183, label %L38, label %L40
L40:
  %t184 = insertvalue %KValue { i64 0, i64 undef }, i64 %t182, 1
  br label %L39
L38:
  %t185 = call %KValue @k_add(%KValue %t171, %KValue %t173)
  br label %L39
L39:
  %t186 = phi %KValue [ %t184, %L40 ], [ %t185, %L38 ]
  %t187 = extractvalue %KValue %x0, 0
  %t188 = icmp eq i64 %t187, 13
  %t189 = extractvalue %KValue { i64 0, i64 6 }, 0
  %t190 = icmp eq i64 %t189, 0
  %t191 = and i1 %t188, %t190
  br i1 %t191, label %L41, label %L42
L41:
  %t192 = extractvalue %KValue %x0, 1
  %t193 = inttoptr i64 %t192 to ptr
  %t194 = getelementptr %KBytes, ptr %t193, i64 0, i32 0
  %t195 = load i64, ptr %t194
  %t196 = extractvalue %KValue { i64 0, i64 6 }, 1
  %t197 = icmp sge i64 %t196, 1
  %t198 = icmp sle i64 %t196, %t195
  %t199 = and i1 %t197, %t198
  br i1 %t199, label %L44, label %L42
L44:
  %t200 = getelementptr %KBytes, ptr %t193, i64 0, i32 1
  %t201 = load ptr, ptr %t200
  %t202 = add i64 %t196, -1
  %t203 = getelementptr i8, ptr %t201, i64 %t202
  %t204 = load i8, ptr %t203
  %t205 = zext i8 %t204 to i64
  %t206 = insertvalue %KValue { i64 0, i64 undef }, i64 %t205, 1
  br label %L43
L42:
  %t207 = call %KValue @k_b_at(%KValue %x0, %KValue { i64 0, i64 6 })
  br label %L43
L43:
  %t208 = phi %KValue [ %t206, %L44 ], [ %t207, %L42 ]
  %t209 = call tailcc %KValue @d_minimax_winner_1(%KValue %x1)
  %t210 = call tailcc %KValue @d_vse_2(%KValue %t1, %KValue %t209)
  %t211 = extractvalue %KValue %t208, 0
  %t212 = extractvalue %KValue %t210, 0
  %t213 = icmp eq i64 %t211, 0
  %t214 = icmp eq i64 %t212, 0
  %t215 = and i1 %t213, %t214
  br i1 %t215, label %L45, label %L46
L45:
  %t216 = extractvalue %KValue %t208, 1
  %t217 = extractvalue %KValue %t210, 1
  %t218 = call { i64, i1 } @llvm.sadd.with.overflow.i64(i64 %t216, i64 %t217)
  %t219 = extractvalue { i64, i1 } %t218, 0
  %t220 = extractvalue { i64, i1 } %t218, 1
  br i1 %t220, label %L46, label %L48
L48:
  %t221 = insertvalue %KValue { i64 0, i64 undef }, i64 %t219, 1
  br label %L47
L46:
  %t222 = call %KValue @k_add(%KValue %t208, %KValue %t210)
  br label %L47
L47:
  %t223 = phi %KValue [ %t221, %L48 ], [ %t222, %L46 ]
  %t224 = alloca [6 x %KValue]
  %t225 = getelementptr [6 x %KValue], ptr %t224, i64 0, i64 0
  store %KValue %t38, ptr %t225
  %t226 = getelementptr [6 x %KValue], ptr %t224, i64 0, i64 1
  store %KValue %t75, ptr %t226
  %t227 = getelementptr [6 x %KValue], ptr %t224, i64 0, i64 2
  store %KValue %t112, ptr %t227
  %t228 = getelementptr [6 x %KValue], ptr %t224, i64 0, i64 3
  store %KValue %t149, ptr %t228
  %t229 = getelementptr [6 x %KValue], ptr %t224, i64 0, i64 4
  store %KValue %t186, ptr %t229
  %t230 = getelementptr [6 x %KValue], ptr %t224, i64 0, i64 5
  store %KValue %t223, ptr %t230
  %t231 = call %KValue @k_list_lit(i64 6, ptr %t224)
  ret %KValue %t231
fail0:
  %t232 = extractvalue %KValue %x0, 0
  %t233 = icmp ne i64 %t232, 5
  %t234 = icmp ne i64 %t232, 4
  %t235 = and i1 %t233, %t234
  br i1 %t235, label %L50, label %L49
L49:
  %t236 = call %KValue @k_err_hop(%KValue %x0, ptr @s29)
  ret %KValue %t236
L50:
  %t237 = extractvalue %KValue %x1, 0
  %t238 = icmp ne i64 %t237, 5
  %t239 = icmp ne i64 %t237, 4
  %t240 = and i1 %t238, %t239
  br i1 %t240, label %L52, label %L51
L51:
  %t241 = call %KValue @k_err_hop(%KValue %x1, ptr @s29)
  ret %KValue %t241
L52:
  call void @k_die(ptr @s30)
  unreachable
}

define tailcc %KValue @klam5(ptr %env, %KValue %a0) {
entry:
  %t1 = call %KValue @k_env_get(ptr %env, i64 0)
  %t2 = call %KValue @k_env_get(ptr %env, i64 1)
  %t3 = call %KValue @k_env_get(ptr %env, i64 2)
  %t4 = extractvalue %KValue %t1, 0
  %t5 = extractvalue %KValue { i64 0, i64 1 }, 0
  %t6 = icmp eq i64 %t4, 0
  %t7 = icmp eq i64 %t5, 0
  %t8 = and i1 %t6, %t7
  br i1 %t8, label %L1, label %L2
L1:
  %t9 = extractvalue %KValue %t1, 1
  %t10 = extractvalue %KValue { i64 0, i64 1 }, 1
  %t11 = call { i64, i1 } @llvm.ssub.with.overflow.i64(i64 %t9, i64 %t10)
  %t12 = extractvalue { i64, i1 } %t11, 0
  %t13 = extractvalue { i64, i1 } %t11, 1
  br i1 %t13, label %L2, label %L4
L4:
  %t14 = insertvalue %KValue { i64 0, i64 undef }, i64 %t12, 1
  br label %L3
L2:
  %t15 = call %KValue @k_sub(%KValue %t1, %KValue { i64 0, i64 1 })
  br label %L3
L3:
  %t16 = phi %KValue [ %t14, %L4 ], [ %t15, %L2 ]
  %t17 = call tailcc %KValue @d_utilities_2(%KValue %t3, %KValue %a0)
  %t18 = call tailcc %KValue @d__tally_2(%KValue %t2, %KValue %t17)
  %t19 = extractvalue %KValue %t16, 1
  %t20 = musttail call tailcc %KValue @d_trials_2(i64 %t19, %KValue %t18)
  ret %KValue %t20
}

define %KValue @w_klam5(ptr %env, %KValue %a0) {
entry:
  %r = call tailcc %KValue @klam5(ptr %env, %KValue %a0)
  ret %KValue %r
}

define tailcc %KValue @d__with_voters_3(%KValue %x0, %KValue %x1, %KValue %x2) {
entry:
  %t1 = call tailcc %KValue @d_ncand_0()
  %t2 = call tailcc %KValue @d_dims_0()
  %t3 = alloca [1 x %KValue]
  %t4 = call %KValue @k_list_lit(i64 0, ptr %t3)
  %t5 = extractvalue %KValue %t1, 1
  %t6 = extractvalue %KValue %t2, 1
  %t7 = call tailcc %KValue @d_cloud_3(i64 %t5, i64 %t6, %KValue %t4)
  %t8 = extractvalue %KValue %t7, 0
  %t9 = icmp eq i64 %t8, 8
  br i1 %t9, label %L1, label %L2
L1:
  %t11 = alloca [3 x %KValue]
  %t12 = getelementptr [3 x %KValue], ptr %t11, i64 0, i64 0
  store %KValue %x0, ptr %t12
  %t13 = getelementptr [3 x %KValue], ptr %t11, i64 0, i64 1
  store %KValue %x1, ptr %t13
  %t14 = getelementptr [3 x %KValue], ptr %t11, i64 0, i64 2
  store %KValue %x2, ptr %t14
  %t15 = call %KValue @k_closure(ptr @w_klam5, i64 3, ptr %t11)
  %t10 = call %KValue @k_maybe_bind(%KValue %t7, %KValue %t15)
  ret %KValue %t10
L2:
  %t16 = extractvalue %KValue %t7, 0
  %t17 = icmp ne i64 %t16, 5
  %t18 = icmp ne i64 %t16, 4
  %t19 = and i1 %t17, %t18
  br i1 %t19, label %L4, label %L3
L3:
  ret %KValue %t7
L4:
  %t20 = extractvalue %KValue %x0, 0
  %t21 = extractvalue %KValue { i64 0, i64 1 }, 0
  %t22 = icmp eq i64 %t20, 0
  %t23 = icmp eq i64 %t21, 0
  %t24 = and i1 %t22, %t23
  br i1 %t24, label %L5, label %L6
L5:
  %t25 = extractvalue %KValue %x0, 1
  %t26 = extractvalue %KValue { i64 0, i64 1 }, 1
  %t27 = call { i64, i1 } @llvm.ssub.with.overflow.i64(i64 %t25, i64 %t26)
  %t28 = extractvalue { i64, i1 } %t27, 0
  %t29 = extractvalue { i64, i1 } %t27, 1
  br i1 %t29, label %L6, label %L8
L8:
  %t30 = insertvalue %KValue { i64 0, i64 undef }, i64 %t28, 1
  br label %L7
L6:
  %t31 = call %KValue @k_sub(%KValue %x0, %KValue { i64 0, i64 1 })
  br label %L7
L7:
  %t32 = phi %KValue [ %t30, %L8 ], [ %t31, %L6 ]
  %t33 = call tailcc %KValue @d_utilities_2(%KValue %x2, %KValue %t7)
  %t34 = call tailcc %KValue @d__tally_2(%KValue %x1, %KValue %t33)
  call void @k_carry_reset()
  call void @k_carry_stage(%KValue %t34)
  call void @k_beat_iter_carry()
  %t35 = call %KValue @k_carry_take(i64 0)
  %t36 = extractvalue %KValue %t32, 1
  %t37 = musttail call tailcc %KValue @d_trials_2(i64 %t36, %KValue %t35)
  ret %KValue %t37
fail0:
  %t38 = extractvalue %KValue %x0, 0
  %t39 = icmp ne i64 %t38, 5
  %t40 = icmp ne i64 %t38, 4
  %t41 = and i1 %t39, %t40
  br i1 %t41, label %L10, label %L9
L9:
  %t42 = call %KValue @k_err_hop(%KValue %x0, ptr @s31)
  ret %KValue %t42
L10:
  %t43 = extractvalue %KValue %x1, 0
  %t44 = icmp ne i64 %t43, 5
  %t45 = icmp ne i64 %t43, 4
  %t46 = and i1 %t44, %t45
  br i1 %t46, label %L12, label %L11
L11:
  %t47 = call %KValue @k_err_hop(%KValue %x1, ptr @s31)
  ret %KValue %t47
L12:
  %t48 = extractvalue %KValue %x2, 0
  %t49 = icmp ne i64 %t48, 5
  %t50 = icmp ne i64 %t48, 4
  %t51 = and i1 %t49, %t50
  br i1 %t51, label %L14, label %L13
L13:
  %t52 = call %KValue @k_err_hop(%KValue %x2, ptr @s31)
  ret %KValue %t52
L14:
  call void @k_die(ptr @s32)
  unreachable
}

define tailcc %KValue @klam6(ptr %env, %KValue %a0) {
entry:
  %t1 = call %KValue @k_env_get(ptr %env, i64 0)
  %t2 = call %KValue @k_env_get(ptr %env, i64 1)
  %t3 = call %KValue @k_env_get(ptr %env, i64 2)
  %t4 = extractvalue %KValue %t1, 0
  %t5 = extractvalue %KValue { i64 0, i64 1 }, 0
  %t6 = icmp eq i64 %t4, 0
  %t7 = icmp eq i64 %t5, 0
  %t8 = and i1 %t6, %t7
  br i1 %t8, label %L1, label %L2
L1:
  %t9 = extractvalue %KValue %t1, 1
  %t10 = extractvalue %KValue { i64 0, i64 1 }, 1
  %t11 = call { i64, i1 } @llvm.ssub.with.overflow.i64(i64 %t9, i64 %t10)
  %t12 = extractvalue { i64, i1 } %t11, 0
  %t13 = extractvalue { i64, i1 } %t11, 1
  br i1 %t13, label %L2, label %L4
L4:
  %t14 = insertvalue %KValue { i64 0, i64 undef }, i64 %t12, 1
  br label %L3
L2:
  %t15 = call %KValue @k_sub(%KValue %t1, %KValue { i64 0, i64 1 })
  br label %L3
L3:
  %t16 = phi %KValue [ %t14, %L4 ], [ %t15, %L2 ]
  %t17 = call %KValue @k_b_push(%KValue %t3, %KValue %a0)
  %t18 = extractvalue %KValue %t16, 1
  %t19 = extractvalue %KValue %t2, 1
  %t20 = musttail call tailcc %KValue @d_cloud_3(i64 %t18, i64 %t19, %KValue %t17)
  ret %KValue %t20
}

define %KValue @w_klam6(ptr %env, %KValue %a0) {
entry:
  %r = call tailcc %KValue @klam6(ptr %env, %KValue %a0)
  ret %KValue %r
}

define tailcc %KValue @d_cloud_3(i64 %x0r, i64 %x1r, %KValue %x2) {
entry:
  %x0 = insertvalue %KValue { i64 0, i64 undef }, i64 %x0r, 1
  %x1 = insertvalue %KValue { i64 0, i64 undef }, i64 %x1r, 1
  %t1 = extractvalue %KValue %x0, 0
  %t2 = icmp eq i64 %t1, 0
  %t3 = extractvalue %KValue %x0, 1
  %t4 = icmp eq i64 %t3, 0
  %t5 = and i1 %t2, %t4
  br i1 %t5, label %L1, label %fail0
L1:
  ret %KValue %x2
fail0:
  %t6 = alloca [1 x %KValue]
  %t7 = call %KValue @k_list_lit(i64 0, ptr %t6)
  %t8 = extractvalue %KValue %x1, 1
  %t9 = call tailcc %KValue @d_point_2(i64 %t8, %KValue %t7)
  %t10 = extractvalue %KValue %t9, 0
  %t11 = icmp eq i64 %t10, 8
  br i1 %t11, label %L2, label %L3
L2:
  %t13 = alloca [3 x %KValue]
  %t14 = getelementptr [3 x %KValue], ptr %t13, i64 0, i64 0
  store %KValue %x0, ptr %t14
  %t15 = getelementptr [3 x %KValue], ptr %t13, i64 0, i64 1
  store %KValue %x1, ptr %t15
  %t16 = getelementptr [3 x %KValue], ptr %t13, i64 0, i64 2
  store %KValue %x2, ptr %t16
  %t17 = call %KValue @k_closure(ptr @w_klam6, i64 3, ptr %t13)
  %t12 = call %KValue @k_maybe_bind(%KValue %t9, %KValue %t17)
  ret %KValue %t12
L3:
  %t18 = extractvalue %KValue %t9, 0
  %t19 = icmp ne i64 %t18, 5
  %t20 = icmp ne i64 %t18, 4
  %t21 = and i1 %t19, %t20
  br i1 %t21, label %L5, label %L4
L4:
  ret %KValue %t9
L5:
  %t22 = extractvalue %KValue %x0, 1
  %t23 = extractvalue %KValue { i64 0, i64 1 }, 1
  %t24 = call { i64, i1 } @llvm.ssub.with.overflow.i64(i64 %t22, i64 %t23)
  %t25 = extractvalue { i64, i1 } %t24, 0
  %t26 = extractvalue { i64, i1 } %t24, 1
  br i1 %t26, label %L7, label %L6
L7:
  call void @k_die(ptr @s6)
  unreachable
L6:
  %t27 = insertvalue %KValue { i64 0, i64 undef }, i64 %t25, 1
  %t28 = call %KValue @k_b_push_mut(%KValue %x2, %KValue %t9)
  %t29 = extractvalue %KValue %t27, 1
  %t30 = extractvalue %KValue %x1, 1
  %t31 = musttail call tailcc %KValue @d_cloud_3(i64 %t29, i64 %t30, %KValue %t28)
  ret %KValue %t31
fail1:
  %t32 = extractvalue %KValue %x0, 0
  %t33 = icmp ne i64 %t32, 5
  %t34 = icmp ne i64 %t32, 4
  %t35 = and i1 %t33, %t34
  br i1 %t35, label %L9, label %L8
L8:
  %t36 = call %KValue @k_err_hop(%KValue %x0, ptr @s33)
  ret %KValue %t36
L9:
  %t37 = extractvalue %KValue %x1, 0
  %t38 = icmp ne i64 %t37, 5
  %t39 = icmp ne i64 %t37, 4
  %t40 = and i1 %t38, %t39
  br i1 %t40, label %L11, label %L10
L10:
  %t41 = call %KValue @k_err_hop(%KValue %x1, ptr @s33)
  ret %KValue %t41
L11:
  %t42 = extractvalue %KValue %x2, 0
  %t43 = icmp ne i64 %t42, 5
  %t44 = icmp ne i64 %t42, 4
  %t45 = and i1 %t43, %t44
  br i1 %t45, label %L13, label %L12
L12:
  %t46 = call %KValue @k_err_hop(%KValue %x2, ptr @s33)
  ret %KValue %t46
L13:
  call void @k_die(ptr @s34)
  unreachable
}

define tailcc %KValue @d_dims_0() {
entry:
  ret %KValue { i64 0, i64 2 }
fail0:
  call void @k_die(ptr @s36)
  unreachable
}

define tailcc %KValue @klam7(ptr %env, %KValue %a0) {
entry:
  %t1 = call %KValue @k_env_get(ptr %env, i64 0)
  %t2 = call %KValue @k_env_get(ptr %env, i64 1)
  %t3 = extractvalue %KValue %t1, 0
  %t4 = icmp eq i64 %t3, 13
  %t5 = extractvalue %KValue %a0, 0
  %t6 = icmp eq i64 %t5, 0
  %t7 = and i1 %t4, %t6
  br i1 %t7, label %L1, label %L2
L1:
  %t8 = extractvalue %KValue %t1, 1
  %t9 = inttoptr i64 %t8 to ptr
  %t10 = getelementptr %KBytes, ptr %t9, i64 0, i32 0
  %t11 = load i64, ptr %t10
  %t12 = extractvalue %KValue %a0, 1
  %t13 = icmp sge i64 %t12, 1
  %t14 = icmp sle i64 %t12, %t11
  %t15 = and i1 %t13, %t14
  br i1 %t15, label %L4, label %L2
L4:
  %t16 = getelementptr %KBytes, ptr %t9, i64 0, i32 1
  %t17 = load ptr, ptr %t16
  %t18 = add i64 %t12, -1
  %t19 = getelementptr i8, ptr %t17, i64 %t18
  %t20 = load i8, ptr %t19
  %t21 = zext i8 %t20 to i64
  %t22 = insertvalue %KValue { i64 0, i64 undef }, i64 %t21, 1
  br label %L3
L2:
  %t23 = call %KValue @k_b_at(%KValue %t1, %KValue %a0)
  br label %L3
L3:
  %t24 = phi %KValue [ %t22, %L4 ], [ %t23, %L2 ]
  %t25 = extractvalue %KValue %t2, 0
  %t26 = icmp eq i64 %t25, 13
  %t27 = extractvalue %KValue %a0, 0
  %t28 = icmp eq i64 %t27, 0
  %t29 = and i1 %t26, %t28
  br i1 %t29, label %L5, label %L6
L5:
  %t30 = extractvalue %KValue %t2, 1
  %t31 = inttoptr i64 %t30 to ptr
  %t32 = getelementptr %KBytes, ptr %t31, i64 0, i32 0
  %t33 = load i64, ptr %t32
  %t34 = extractvalue %KValue %a0, 1
  %t35 = icmp sge i64 %t34, 1
  %t36 = icmp sle i64 %t34, %t33
  %t37 = and i1 %t35, %t36
  br i1 %t37, label %L8, label %L6
L8:
  %t38 = getelementptr %KBytes, ptr %t31, i64 0, i32 1
  %t39 = load ptr, ptr %t38
  %t40 = add i64 %t34, -1
  %t41 = getelementptr i8, ptr %t39, i64 %t40
  %t42 = load i8, ptr %t41
  %t43 = zext i8 %t42 to i64
  %t44 = insertvalue %KValue { i64 0, i64 undef }, i64 %t43, 1
  br label %L7
L6:
  %t45 = call %KValue @k_b_at(%KValue %t2, %KValue %a0)
  br label %L7
L7:
  %t46 = phi %KValue [ %t44, %L8 ], [ %t45, %L6 ]
  %t47 = extractvalue %KValue %t24, 0
  %t48 = extractvalue %KValue %t46, 0
  %t49 = icmp eq i64 %t47, 0
  %t50 = icmp eq i64 %t48, 0
  %t51 = and i1 %t49, %t50
  br i1 %t51, label %L9, label %L10
L9:
  %t52 = extractvalue %KValue %t24, 1
  %t53 = extractvalue %KValue %t46, 1
  %t54 = call { i64, i1 } @llvm.ssub.with.overflow.i64(i64 %t52, i64 %t53)
  %t55 = extractvalue { i64, i1 } %t54, 0
  %t56 = extractvalue { i64, i1 } %t54, 1
  br i1 %t56, label %L10, label %L12
L12:
  %t57 = insertvalue %KValue { i64 0, i64 undef }, i64 %t55, 1
  br label %L11
L10:
  %t58 = call %KValue @k_sub(%KValue %t24, %KValue %t46)
  br label %L11
L11:
  %t59 = phi %KValue [ %t57, %L12 ], [ %t58, %L10 ]
  %t60 = musttail call tailcc %KValue @d__sq_1(%KValue %t59)
  ret %KValue %t60
}

define %KValue @w_klam7(ptr %env, %KValue %a0) {
entry:
  %r = call tailcc %KValue @klam7(ptr %env, %KValue %a0)
  ret %KValue %r
}

define tailcc %KValue @d_dist2_2(%KValue %x0, %KValue %x1) {
entry:
  %t1 = call %KValue @k_b_length(%KValue %x0)
  %t2 = extractvalue %KValue %t1, 1
  %t3 = call tailcc %KValue @d_range_1(i64 %t2)
  %t4 = alloca [2 x %KValue]
  %t5 = getelementptr [2 x %KValue], ptr %t4, i64 0, i64 0
  store %KValue %x0, ptr %t5
  %t6 = getelementptr [2 x %KValue], ptr %t4, i64 0, i64 1
  store %KValue %x1, ptr %t6
  %t7 = call %KValue @k_closure(ptr @w_klam7, i64 2, ptr %t4)
  %t8 = call %KValue @k_b_map(%KValue %t3, %KValue %t7)
  %t9 = musttail call tailcc %KValue @d_total_1(%KValue %t8)
  ret %KValue %t9
fail0:
  %t10 = extractvalue %KValue %x0, 0
  %t11 = icmp ne i64 %t10, 5
  %t12 = icmp ne i64 %t10, 4
  %t13 = and i1 %t11, %t12
  br i1 %t13, label %L2, label %L1
L1:
  %t14 = call %KValue @k_err_hop(%KValue %x0, ptr @s37)
  ret %KValue %t14
L2:
  %t15 = extractvalue %KValue %x1, 0
  %t16 = icmp ne i64 %t15, 5
  %t17 = icmp ne i64 %t15, 4
  %t18 = and i1 %t16, %t17
  br i1 %t18, label %L4, label %L3
L3:
  %t19 = call %KValue @k_err_hop(%KValue %x1, ptr @s37)
  ret %KValue %t19
L4:
  call void @k_die(ptr @s38)
  unreachable
}

define tailcc %KValue @klam8(ptr %env, %KValue %a0) {
entry:
  %t1 = musttail call tailcc %KValue @d_means_1(%KValue %a0)
  ret %KValue %t1
}

define %KValue @w_klam8(ptr %env, %KValue %a0) {
entry:
  %r = call tailcc %KValue @klam8(ptr %env, %KValue %a0)
  ret %KValue %r
}

define tailcc %KValue @d_main_0() {
entry:
  %t1 = call tailcc %KValue @d_runs_0()
  %t2 = call %KValue @k_float(double 0x0000000000000000)
  %t3 = call %KValue @k_float(double 0x0000000000000000)
  %t4 = call %KValue @k_float(double 0x0000000000000000)
  %t5 = call %KValue @k_float(double 0x0000000000000000)
  %t6 = call %KValue @k_float(double 0x0000000000000000)
  %t7 = call %KValue @k_float(double 0x0000000000000000)
  %t8 = alloca [6 x %KValue]
  %t9 = getelementptr [6 x %KValue], ptr %t8, i64 0, i64 0
  store %KValue %t2, ptr %t9
  %t10 = getelementptr [6 x %KValue], ptr %t8, i64 0, i64 1
  store %KValue %t3, ptr %t10
  %t11 = getelementptr [6 x %KValue], ptr %t8, i64 0, i64 2
  store %KValue %t4, ptr %t11
  %t12 = getelementptr [6 x %KValue], ptr %t8, i64 0, i64 3
  store %KValue %t5, ptr %t12
  %t13 = getelementptr [6 x %KValue], ptr %t8, i64 0, i64 4
  store %KValue %t6, ptr %t13
  %t14 = getelementptr [6 x %KValue], ptr %t8, i64 0, i64 5
  store %KValue %t7, ptr %t14
  %t15 = call %KValue @k_list_lit(i64 6, ptr %t8)
  %t16 = extractvalue %KValue %t1, 1
  call void @k_beat_push()
  %t17 = call tailcc %KValue @d_trials_2(i64 %t16, %KValue %t15)
  %t18 = call %KValue @k_beat_pop(%KValue %t17)
  %t19 = alloca [1 x %KValue]
  %t20 = call %KValue @k_closure(ptr @w_klam8, i64 0, ptr %t19)
  %t21 = call %KValue @k_maybe_bind(%KValue %t18, %KValue %t20)
  ret %KValue %t21
fail0:
  call void @k_die(ptr @s40)
  unreachable
}

define tailcc %KValue @d_means_1(%KValue %x0) {
entry:
  %t1 = call %KValue @k_str_n(ptr @s42, i64 14)
  %t2 = extractvalue %KValue %x0, 0
  %t3 = icmp eq i64 %t2, 13
  %t4 = extractvalue %KValue { i64 0, i64 1 }, 0
  %t5 = icmp eq i64 %t4, 0
  %t6 = and i1 %t3, %t5
  br i1 %t6, label %L1, label %L2
L1:
  %t7 = extractvalue %KValue %x0, 1
  %t8 = inttoptr i64 %t7 to ptr
  %t9 = getelementptr %KBytes, ptr %t8, i64 0, i32 0
  %t10 = load i64, ptr %t9
  %t11 = extractvalue %KValue { i64 0, i64 1 }, 1
  %t12 = icmp sge i64 %t11, 1
  %t13 = icmp sle i64 %t11, %t10
  %t14 = and i1 %t12, %t13
  br i1 %t14, label %L4, label %L2
L4:
  %t15 = getelementptr %KBytes, ptr %t8, i64 0, i32 1
  %t16 = load ptr, ptr %t15
  %t17 = add i64 %t11, -1
  %t18 = getelementptr i8, ptr %t16, i64 %t17
  %t19 = load i8, ptr %t18
  %t20 = zext i8 %t19 to i64
  %t21 = insertvalue %KValue { i64 0, i64 undef }, i64 %t20, 1
  br label %L3
L2:
  %t22 = call %KValue @k_b_at(%KValue %x0, %KValue { i64 0, i64 1 })
  br label %L3
L3:
  %t23 = phi %KValue [ %t21, %L4 ], [ %t22, %L2 ]
  %t24 = call tailcc %KValue @d_runs_0()
  %t25 = call %KValue @k_div(%KValue %t23, %KValue %t24, ptr @s43)
  %t26 = call %KValue @k_render(%KValue %t25, i64 0)
  %t27 = call %KValue @k_concat(%KValue %t1, %KValue %t26)
  %t28 = call %KValue @k_desc_print(%KValue %t27)
  %t29 = call %KValue @k_str_n(ptr @s44, i64 14)
  %t30 = extractvalue %KValue %x0, 0
  %t31 = icmp eq i64 %t30, 13
  %t32 = extractvalue %KValue { i64 0, i64 2 }, 0
  %t33 = icmp eq i64 %t32, 0
  %t34 = and i1 %t31, %t33
  br i1 %t34, label %L5, label %L6
L5:
  %t35 = extractvalue %KValue %x0, 1
  %t36 = inttoptr i64 %t35 to ptr
  %t37 = getelementptr %KBytes, ptr %t36, i64 0, i32 0
  %t38 = load i64, ptr %t37
  %t39 = extractvalue %KValue { i64 0, i64 2 }, 1
  %t40 = icmp sge i64 %t39, 1
  %t41 = icmp sle i64 %t39, %t38
  %t42 = and i1 %t40, %t41
  br i1 %t42, label %L8, label %L6
L8:
  %t43 = getelementptr %KBytes, ptr %t36, i64 0, i32 1
  %t44 = load ptr, ptr %t43
  %t45 = add i64 %t39, -1
  %t46 = getelementptr i8, ptr %t44, i64 %t45
  %t47 = load i8, ptr %t46
  %t48 = zext i8 %t47 to i64
  %t49 = insertvalue %KValue { i64 0, i64 undef }, i64 %t48, 1
  br label %L7
L6:
  %t50 = call %KValue @k_b_at(%KValue %x0, %KValue { i64 0, i64 2 })
  br label %L7
L7:
  %t51 = phi %KValue [ %t49, %L8 ], [ %t50, %L6 ]
  %t52 = call tailcc %KValue @d_runs_0()
  %t53 = call %KValue @k_div(%KValue %t51, %KValue %t52, ptr @s45)
  %t54 = call %KValue @k_render(%KValue %t53, i64 0)
  %t55 = call %KValue @k_concat(%KValue %t29, %KValue %t54)
  %t56 = call %KValue @k_desc_print(%KValue %t55)
  %t57 = call %KValue @k_str_n(ptr @s46, i64 14)
  %t58 = extractvalue %KValue %x0, 0
  %t59 = icmp eq i64 %t58, 13
  %t60 = extractvalue %KValue { i64 0, i64 3 }, 0
  %t61 = icmp eq i64 %t60, 0
  %t62 = and i1 %t59, %t61
  br i1 %t62, label %L9, label %L10
L9:
  %t63 = extractvalue %KValue %x0, 1
  %t64 = inttoptr i64 %t63 to ptr
  %t65 = getelementptr %KBytes, ptr %t64, i64 0, i32 0
  %t66 = load i64, ptr %t65
  %t67 = extractvalue %KValue { i64 0, i64 3 }, 1
  %t68 = icmp sge i64 %t67, 1
  %t69 = icmp sle i64 %t67, %t66
  %t70 = and i1 %t68, %t69
  br i1 %t70, label %L12, label %L10
L12:
  %t71 = getelementptr %KBytes, ptr %t64, i64 0, i32 1
  %t72 = load ptr, ptr %t71
  %t73 = add i64 %t67, -1
  %t74 = getelementptr i8, ptr %t72, i64 %t73
  %t75 = load i8, ptr %t74
  %t76 = zext i8 %t75 to i64
  %t77 = insertvalue %KValue { i64 0, i64 undef }, i64 %t76, 1
  br label %L11
L10:
  %t78 = call %KValue @k_b_at(%KValue %x0, %KValue { i64 0, i64 3 })
  br label %L11
L11:
  %t79 = phi %KValue [ %t77, %L12 ], [ %t78, %L10 ]
  %t80 = call tailcc %KValue @d_runs_0()
  %t81 = call %KValue @k_div(%KValue %t79, %KValue %t80, ptr @s47)
  %t82 = call %KValue @k_render(%KValue %t81, i64 0)
  %t83 = call %KValue @k_concat(%KValue %t57, %KValue %t82)
  %t84 = call %KValue @k_desc_print(%KValue %t83)
  %t85 = call %KValue @k_str_n(ptr @s48, i64 14)
  %t86 = extractvalue %KValue %x0, 0
  %t87 = icmp eq i64 %t86, 13
  %t88 = extractvalue %KValue { i64 0, i64 4 }, 0
  %t89 = icmp eq i64 %t88, 0
  %t90 = and i1 %t87, %t89
  br i1 %t90, label %L13, label %L14
L13:
  %t91 = extractvalue %KValue %x0, 1
  %t92 = inttoptr i64 %t91 to ptr
  %t93 = getelementptr %KBytes, ptr %t92, i64 0, i32 0
  %t94 = load i64, ptr %t93
  %t95 = extractvalue %KValue { i64 0, i64 4 }, 1
  %t96 = icmp sge i64 %t95, 1
  %t97 = icmp sle i64 %t95, %t94
  %t98 = and i1 %t96, %t97
  br i1 %t98, label %L16, label %L14
L16:
  %t99 = getelementptr %KBytes, ptr %t92, i64 0, i32 1
  %t100 = load ptr, ptr %t99
  %t101 = add i64 %t95, -1
  %t102 = getelementptr i8, ptr %t100, i64 %t101
  %t103 = load i8, ptr %t102
  %t104 = zext i8 %t103 to i64
  %t105 = insertvalue %KValue { i64 0, i64 undef }, i64 %t104, 1
  br label %L15
L14:
  %t106 = call %KValue @k_b_at(%KValue %x0, %KValue { i64 0, i64 4 })
  br label %L15
L15:
  %t107 = phi %KValue [ %t105, %L16 ], [ %t106, %L14 ]
  %t108 = call tailcc %KValue @d_runs_0()
  %t109 = call %KValue @k_div(%KValue %t107, %KValue %t108, ptr @s49)
  %t110 = call %KValue @k_render(%KValue %t109, i64 0)
  %t111 = call %KValue @k_concat(%KValue %t85, %KValue %t110)
  %t112 = call %KValue @k_desc_print(%KValue %t111)
  %t113 = call %KValue @k_str_n(ptr @s50, i64 14)
  %t114 = extractvalue %KValue %x0, 0
  %t115 = icmp eq i64 %t114, 13
  %t116 = extractvalue %KValue { i64 0, i64 5 }, 0
  %t117 = icmp eq i64 %t116, 0
  %t118 = and i1 %t115, %t117
  br i1 %t118, label %L17, label %L18
L17:
  %t119 = extractvalue %KValue %x0, 1
  %t120 = inttoptr i64 %t119 to ptr
  %t121 = getelementptr %KBytes, ptr %t120, i64 0, i32 0
  %t122 = load i64, ptr %t121
  %t123 = extractvalue %KValue { i64 0, i64 5 }, 1
  %t124 = icmp sge i64 %t123, 1
  %t125 = icmp sle i64 %t123, %t122
  %t126 = and i1 %t124, %t125
  br i1 %t126, label %L20, label %L18
L20:
  %t127 = getelementptr %KBytes, ptr %t120, i64 0, i32 1
  %t128 = load ptr, ptr %t127
  %t129 = add i64 %t123, -1
  %t130 = getelementptr i8, ptr %t128, i64 %t129
  %t131 = load i8, ptr %t130
  %t132 = zext i8 %t131 to i64
  %t133 = insertvalue %KValue { i64 0, i64 undef }, i64 %t132, 1
  br label %L19
L18:
  %t134 = call %KValue @k_b_at(%KValue %x0, %KValue { i64 0, i64 5 })
  br label %L19
L19:
  %t135 = phi %KValue [ %t133, %L20 ], [ %t134, %L18 ]
  %t136 = call tailcc %KValue @d_runs_0()
  %t137 = call %KValue @k_div(%KValue %t135, %KValue %t136, ptr @s51)
  %t138 = call %KValue @k_render(%KValue %t137, i64 0)
  %t139 = call %KValue @k_concat(%KValue %t113, %KValue %t138)
  %t140 = call %KValue @k_desc_print(%KValue %t139)
  %t141 = call %KValue @k_str_n(ptr @s52, i64 14)
  %t142 = extractvalue %KValue %x0, 0
  %t143 = icmp eq i64 %t142, 13
  %t144 = extractvalue %KValue { i64 0, i64 6 }, 0
  %t145 = icmp eq i64 %t144, 0
  %t146 = and i1 %t143, %t145
  br i1 %t146, label %L21, label %L22
L21:
  %t147 = extractvalue %KValue %x0, 1
  %t148 = inttoptr i64 %t147 to ptr
  %t149 = getelementptr %KBytes, ptr %t148, i64 0, i32 0
  %t150 = load i64, ptr %t149
  %t151 = extractvalue %KValue { i64 0, i64 6 }, 1
  %t152 = icmp sge i64 %t151, 1
  %t153 = icmp sle i64 %t151, %t150
  %t154 = and i1 %t152, %t153
  br i1 %t154, label %L24, label %L22
L24:
  %t155 = getelementptr %KBytes, ptr %t148, i64 0, i32 1
  %t156 = load ptr, ptr %t155
  %t157 = add i64 %t151, -1
  %t158 = getelementptr i8, ptr %t156, i64 %t157
  %t159 = load i8, ptr %t158
  %t160 = zext i8 %t159 to i64
  %t161 = insertvalue %KValue { i64 0, i64 undef }, i64 %t160, 1
  br label %L23
L22:
  %t162 = call %KValue @k_b_at(%KValue %x0, %KValue { i64 0, i64 6 })
  br label %L23
L23:
  %t163 = phi %KValue [ %t161, %L24 ], [ %t162, %L22 ]
  %t164 = call tailcc %KValue @d_runs_0()
  %t165 = call %KValue @k_div(%KValue %t163, %KValue %t164, ptr @s53)
  %t166 = call %KValue @k_render(%KValue %t165, i64 0)
  %t167 = call %KValue @k_concat(%KValue %t141, %KValue %t166)
  %t168 = call %KValue @k_desc_print(%KValue %t167)
  %t169 = call %KValue @k_seq(%KValue %t140, %KValue %t168)
  %t170 = call %KValue @k_seq(%KValue %t112, %KValue %t169)
  %t171 = call %KValue @k_seq(%KValue %t84, %KValue %t170)
  %t172 = call %KValue @k_seq(%KValue %t56, %KValue %t171)
  %t173 = call %KValue @k_seq(%KValue %t28, %KValue %t172)
  ret %KValue %t173
fail0:
  %t174 = extractvalue %KValue %x0, 0
  %t175 = icmp ne i64 %t174, 5
  %t176 = icmp ne i64 %t174, 4
  %t177 = and i1 %t175, %t176
  br i1 %t177, label %L26, label %L25
L25:
  %t178 = call %KValue @k_err_hop(%KValue %x0, ptr @s41)
  ret %KValue %t178
L26:
  call void @k_die(ptr @s54)
  unreachable
}

define tailcc %KValue @d_ncand_0() {
entry:
  ret %KValue { i64 0, i64 5 }
fail0:
  call void @k_die(ptr @s56)
  unreachable
}

define tailcc %KValue @d_nvot_0() {
entry:
  ret %KValue { i64 0, i64 20 }
fail0:
  call void @k_die(ptr @s58)
  unreachable
}

define tailcc %KValue @klam9(ptr %env, %KValue %a0) {
entry:
  %t1 = call %KValue @k_env_get(ptr %env, i64 0)
  %t2 = call %KValue @k_env_get(ptr %env, i64 1)
  %t3 = extractvalue %KValue %t1, 0
  %t4 = extractvalue %KValue { i64 0, i64 1 }, 0
  %t5 = icmp eq i64 %t3, 0
  %t6 = icmp eq i64 %t4, 0
  %t7 = and i1 %t5, %t6
  br i1 %t7, label %L1, label %L2
L1:
  %t8 = extractvalue %KValue %t1, 1
  %t9 = extractvalue %KValue { i64 0, i64 1 }, 1
  %t10 = call { i64, i1 } @llvm.ssub.with.overflow.i64(i64 %t8, i64 %t9)
  %t11 = extractvalue { i64, i1 } %t10, 0
  %t12 = extractvalue { i64, i1 } %t10, 1
  br i1 %t12, label %L2, label %L4
L4:
  %t13 = insertvalue %KValue { i64 0, i64 undef }, i64 %t11, 1
  br label %L3
L2:
  %t14 = call %KValue @k_sub(%KValue %t1, %KValue { i64 0, i64 1 })
  br label %L3
L3:
  %t15 = phi %KValue [ %t13, %L4 ], [ %t14, %L2 ]
  %t16 = call %KValue @k_b_push(%KValue %t2, %KValue %a0)
  %t17 = extractvalue %KValue %t15, 1
  %t18 = musttail call tailcc %KValue @d_point_2(i64 %t17, %KValue %t16)
  ret %KValue %t18
}

define %KValue @w_klam9(ptr %env, %KValue %a0) {
entry:
  %r = call tailcc %KValue @klam9(ptr %env, %KValue %a0)
  ret %KValue %r
}

define tailcc %KValue @d_point_2(i64 %x0r, %KValue %x1) {
entry:
  %x0 = insertvalue %KValue { i64 0, i64 undef }, i64 %x0r, 1
  %t1 = extractvalue %KValue %x0, 0
  %t2 = icmp eq i64 %t1, 0
  %t3 = extractvalue %KValue %x0, 1
  %t4 = icmp eq i64 %t3, 0
  %t5 = and i1 %t2, %t4
  br i1 %t5, label %L1, label %fail0
L1:
  ret %KValue %x1
fail0:
  %t6 = call %KValue @k_desc_random(%KValue { i64 0, i64 1000 })
  %t7 = extractvalue %KValue %t6, 0
  %t8 = icmp eq i64 %t7, 8
  br i1 %t8, label %L2, label %L3
L2:
  %t10 = alloca [2 x %KValue]
  %t11 = getelementptr [2 x %KValue], ptr %t10, i64 0, i64 0
  store %KValue %x0, ptr %t11
  %t12 = getelementptr [2 x %KValue], ptr %t10, i64 0, i64 1
  store %KValue %x1, ptr %t12
  %t13 = call %KValue @k_closure(ptr @w_klam9, i64 2, ptr %t10)
  %t9 = call %KValue @k_maybe_bind(%KValue %t6, %KValue %t13)
  ret %KValue %t9
L3:
  %t14 = extractvalue %KValue %t6, 0
  %t15 = icmp ne i64 %t14, 5
  %t16 = icmp ne i64 %t14, 4
  %t17 = and i1 %t15, %t16
  br i1 %t17, label %L5, label %L4
L4:
  ret %KValue %t6
L5:
  %t18 = extractvalue %KValue %x0, 1
  %t19 = extractvalue %KValue { i64 0, i64 1 }, 1
  %t20 = call { i64, i1 } @llvm.ssub.with.overflow.i64(i64 %t18, i64 %t19)
  %t21 = extractvalue { i64, i1 } %t20, 0
  %t22 = extractvalue { i64, i1 } %t20, 1
  br i1 %t22, label %L7, label %L6
L7:
  call void @k_die(ptr @s6)
  unreachable
L6:
  %t23 = insertvalue %KValue { i64 0, i64 undef }, i64 %t21, 1
  %t24 = call %KValue @k_b_push_mut(%KValue %x1, %KValue %t6)
  %t25 = extractvalue %KValue %t23, 1
  %t26 = musttail call tailcc %KValue @d_point_2(i64 %t25, %KValue %t24)
  ret %KValue %t26
fail1:
  %t27 = extractvalue %KValue %x0, 0
  %t28 = icmp ne i64 %t27, 5
  %t29 = icmp ne i64 %t27, 4
  %t30 = and i1 %t28, %t29
  br i1 %t30, label %L9, label %L8
L8:
  %t31 = call %KValue @k_err_hop(%KValue %x0, ptr @s59)
  ret %KValue %t31
L9:
  %t32 = extractvalue %KValue %x1, 0
  %t33 = icmp ne i64 %t32, 5
  %t34 = icmp ne i64 %t32, 4
  %t35 = and i1 %t33, %t34
  br i1 %t35, label %L11, label %L10
L10:
  %t36 = call %KValue @k_err_hop(%KValue %x1, ptr @s59)
  ret %KValue %t36
L11:
  call void @k_die(ptr @s60)
  unreachable
}

define tailcc %KValue @d_runs_0() {
entry:
  ret %KValue { i64 0, i64 400 }
fail0:
  call void @k_die(ptr @s62)
  unreachable
}

define tailcc %KValue @klam10(ptr %env, %KValue %a0) {
entry:
  %t1 = call %KValue @k_env_get(ptr %env, i64 0)
  %t2 = extractvalue %KValue %a0, 0
  %t3 = icmp eq i64 %t2, 13
  %t4 = extractvalue %KValue %t1, 0
  %t5 = icmp eq i64 %t4, 0
  %t6 = and i1 %t3, %t5
  br i1 %t6, label %L1, label %L2
L1:
  %t7 = extractvalue %KValue %a0, 1
  %t8 = inttoptr i64 %t7 to ptr
  %t9 = getelementptr %KBytes, ptr %t8, i64 0, i32 0
  %t10 = load i64, ptr %t9
  %t11 = extractvalue %KValue %t1, 1
  %t12 = icmp sge i64 %t11, 1
  %t13 = icmp sle i64 %t11, %t10
  %t14 = and i1 %t12, %t13
  br i1 %t14, label %L4, label %L2
L4:
  %t15 = getelementptr %KBytes, ptr %t8, i64 0, i32 1
  %t16 = load ptr, ptr %t15
  %t17 = add i64 %t11, -1
  %t18 = getelementptr i8, ptr %t16, i64 %t17
  %t19 = load i8, ptr %t18
  %t20 = zext i8 %t19 to i64
  %t21 = insertvalue %KValue { i64 0, i64 undef }, i64 %t20, 1
  br label %L3
L2:
  %t22 = call %KValue @k_b_at(%KValue %a0, %KValue %t1)
  br label %L3
L3:
  %t23 = phi %KValue [ %t21, %L4 ], [ %t22, %L2 ]
  ret %KValue %t23
}

define %KValue @w_klam10(ptr %env, %KValue %a0) {
entry:
  %r = call tailcc %KValue @klam10(ptr %env, %KValue %a0)
  ret %KValue %r
}

define tailcc %KValue @d_socutil_2(%KValue %x0, %KValue %x1) {
entry:
  %t1 = alloca [1 x %KValue]
  %t2 = getelementptr [1 x %KValue], ptr %t1, i64 0, i64 0
  store %KValue %x1, ptr %t2
  %t3 = call %KValue @k_closure(ptr @w_klam10, i64 1, ptr %t1)
  %t4 = call %KValue @k_b_map(%KValue %x0, %KValue %t3)
  %t5 = musttail call tailcc %KValue @d_total_1(%KValue %t4)
  ret %KValue %t5
fail0:
  %t6 = extractvalue %KValue %x0, 0
  %t7 = icmp ne i64 %t6, 5
  %t8 = icmp ne i64 %t6, 4
  %t9 = and i1 %t7, %t8
  br i1 %t9, label %L2, label %L1
L1:
  %t10 = call %KValue @k_err_hop(%KValue %x0, ptr @s63)
  ret %KValue %t10
L2:
  %t11 = extractvalue %KValue %x1, 0
  %t12 = icmp ne i64 %t11, 5
  %t13 = icmp ne i64 %t11, 4
  %t14 = and i1 %t12, %t13
  br i1 %t14, label %L4, label %L3
L3:
  %t15 = call %KValue @k_err_hop(%KValue %x1, ptr @s63)
  ret %KValue %t15
L4:
  call void @k_die(ptr @s64)
  unreachable
}

define tailcc %KValue @klam11(ptr %env, %KValue %a0) {
entry:
  %t1 = call %KValue @k_env_get(ptr %env, i64 0)
  %t2 = musttail call tailcc %KValue @d_socutil_2(%KValue %t1, %KValue %a0)
  ret %KValue %t2
}

define %KValue @w_klam11(ptr %env, %KValue %a0) {
entry:
  %r = call tailcc %KValue @klam11(ptr %env, %KValue %a0)
  ret %KValue %r
}

define tailcc %KValue @d_socutils_1(%KValue %x0) {
entry:
  %t1 = call tailcc %KValue @d_ncand_0()
  %t2 = extractvalue %KValue %t1, 1
  %t3 = call tailcc %KValue @d_range_1(i64 %t2)
  %t4 = alloca [1 x %KValue]
  %t5 = getelementptr [1 x %KValue], ptr %t4, i64 0, i64 0
  store %KValue %x0, ptr %t5
  %t6 = call %KValue @k_closure(ptr @w_klam11, i64 1, ptr %t4)
  %t7 = call %KValue @k_b_map(%KValue %t3, %KValue %t6)
  ret %KValue %t7
fail0:
  %t8 = extractvalue %KValue %x0, 0
  %t9 = icmp ne i64 %t8, 5
  %t10 = icmp ne i64 %t8, 4
  %t11 = and i1 %t9, %t10
  br i1 %t11, label %L2, label %L1
L1:
  %t12 = call %KValue @k_err_hop(%KValue %x0, ptr @s65)
  ret %KValue %t12
L2:
  call void @k_die(ptr @s66)
  unreachable
}

define tailcc %KValue @klam12(ptr %env, %KValue %a0) {
entry:
  %t1 = call %KValue @k_env_get(ptr %env, i64 0)
  %t2 = call %KValue @k_env_get(ptr %env, i64 1)
  %t3 = musttail call tailcc %KValue @d__with_voters_3(%KValue %t1, %KValue %t2, %KValue %a0)
  ret %KValue %t3
}

define %KValue @w_klam12(ptr %env, %KValue %a0) {
entry:
  %r = call tailcc %KValue @klam12(ptr %env, %KValue %a0)
  ret %KValue %r
}

define tailcc %KValue @d_trials_2(i64 %x0r, %KValue %x1) {
entry:
  %x0 = insertvalue %KValue { i64 0, i64 undef }, i64 %x0r, 1
  %t1 = extractvalue %KValue %x0, 0
  %t2 = icmp eq i64 %t1, 0
  %t3 = extractvalue %KValue %x0, 1
  %t4 = icmp eq i64 %t3, 0
  %t5 = and i1 %t2, %t4
  br i1 %t5, label %L1, label %fail0
L1:
  ret %KValue %x1
fail0:
  %t6 = call tailcc %KValue @d_nvot_0()
  %t7 = call tailcc %KValue @d_dims_0()
  %t8 = alloca [1 x %KValue]
  %t9 = call %KValue @k_list_lit(i64 0, ptr %t8)
  %t10 = extractvalue %KValue %t6, 1
  %t11 = extractvalue %KValue %t7, 1
  %t12 = call tailcc %KValue @d_cloud_3(i64 %t10, i64 %t11, %KValue %t9)
  %t13 = extractvalue %KValue %t12, 0
  %t14 = icmp eq i64 %t13, 8
  br i1 %t14, label %L2, label %L3
L2:
  %t16 = alloca [2 x %KValue]
  %t17 = getelementptr [2 x %KValue], ptr %t16, i64 0, i64 0
  store %KValue %x0, ptr %t17
  %t18 = getelementptr [2 x %KValue], ptr %t16, i64 0, i64 1
  store %KValue %x1, ptr %t18
  %t19 = call %KValue @k_closure(ptr @w_klam12, i64 2, ptr %t16)
  %t15 = call %KValue @k_maybe_bind(%KValue %t12, %KValue %t19)
  ret %KValue %t15
L3:
  %t20 = extractvalue %KValue %t12, 0
  %t21 = icmp ne i64 %t20, 5
  %t22 = icmp ne i64 %t20, 4
  %t23 = and i1 %t21, %t22
  br i1 %t23, label %L5, label %L4
L4:
  ret %KValue %t12
L5:
  call void @k_carry_reset()
  call void @k_carry_stage(%KValue %x0)
  call void @k_carry_stage(%KValue %x1)
  call void @k_carry_stage(%KValue %t12)
  call void @k_beat_iter_carry()
  %t24 = call %KValue @k_carry_take(i64 0)
  %t25 = call %KValue @k_carry_take(i64 1)
  %t26 = call %KValue @k_carry_take(i64 2)
  %t27 = musttail call tailcc %KValue @d__with_voters_3(%KValue %t24, %KValue %t25, %KValue %t26)
  ret %KValue %t27
fail1:
  %t28 = extractvalue %KValue %x0, 0
  %t29 = icmp ne i64 %t28, 5
  %t30 = icmp ne i64 %t28, 4
  %t31 = and i1 %t29, %t30
  br i1 %t31, label %L7, label %L6
L6:
  %t32 = call %KValue @k_err_hop(%KValue %x0, ptr @s67)
  ret %KValue %t32
L7:
  %t33 = extractvalue %KValue %x1, 0
  %t34 = icmp ne i64 %t33, 5
  %t35 = icmp ne i64 %t33, 4
  %t36 = and i1 %t34, %t35
  br i1 %t36, label %L9, label %L8
L8:
  %t37 = call %KValue @k_err_hop(%KValue %x1, ptr @s67)
  ret %KValue %t37
L9:
  call void @k_die(ptr @s68)
  unreachable
}

define tailcc %KValue @d_util_2(%KValue %x0, %KValue %x1) {
entry:
  %t1 = call tailcc %KValue @d_dist2_2(%KValue %x0, %KValue %x1)
  %t2 = call %KValue @k_b_sqrt(%KValue %t1)
  %t3 = extractvalue %KValue { i64 0, i64 0 }, 0
  %t4 = extractvalue %KValue %t2, 0
  %t5 = icmp eq i64 %t3, 0
  %t6 = icmp eq i64 %t4, 0
  %t7 = and i1 %t5, %t6
  br i1 %t7, label %L1, label %L2
L1:
  %t8 = extractvalue %KValue { i64 0, i64 0 }, 1
  %t9 = extractvalue %KValue %t2, 1
  %t10 = call { i64, i1 } @llvm.ssub.with.overflow.i64(i64 %t8, i64 %t9)
  %t11 = extractvalue { i64, i1 } %t10, 0
  %t12 = extractvalue { i64, i1 } %t10, 1
  br i1 %t12, label %L2, label %L4
L4:
  %t13 = insertvalue %KValue { i64 0, i64 undef }, i64 %t11, 1
  br label %L3
L2:
  %t14 = call %KValue @k_sub(%KValue { i64 0, i64 0 }, %KValue %t2)
  br label %L3
L3:
  %t15 = phi %KValue [ %t13, %L4 ], [ %t14, %L2 ]
  ret %KValue %t15
fail0:
  %t16 = extractvalue %KValue %x0, 0
  %t17 = icmp ne i64 %t16, 5
  %t18 = icmp ne i64 %t16, 4
  %t19 = and i1 %t17, %t18
  br i1 %t19, label %L6, label %L5
L5:
  %t20 = call %KValue @k_err_hop(%KValue %x0, ptr @s69)
  ret %KValue %t20
L6:
  %t21 = extractvalue %KValue %x1, 0
  %t22 = icmp ne i64 %t21, 5
  %t23 = icmp ne i64 %t21, 4
  %t24 = and i1 %t22, %t23
  br i1 %t24, label %L8, label %L7
L7:
  %t25 = call %KValue @k_err_hop(%KValue %x1, ptr @s69)
  ret %KValue %t25
L8:
  call void @k_die(ptr @s70)
  unreachable
}

define tailcc %KValue @klam14(ptr %env, %KValue %a0) {
entry:
  %t1 = call %KValue @k_env_get(ptr %env, i64 0)
  %t2 = musttail call tailcc %KValue @d_util_2(%KValue %t1, %KValue %a0)
  ret %KValue %t2
}

define %KValue @w_klam14(ptr %env, %KValue %a0) {
entry:
  %r = call tailcc %KValue @klam14(ptr %env, %KValue %a0)
  ret %KValue %r
}

define tailcc %KValue @klam13(ptr %env, %KValue %a0) {
entry:
  %t1 = call %KValue @k_env_get(ptr %env, i64 0)
  %t2 = alloca [1 x %KValue]
  %t3 = getelementptr [1 x %KValue], ptr %t2, i64 0, i64 0
  store %KValue %a0, ptr %t3
  %t4 = call %KValue @k_closure(ptr @w_klam14, i64 1, ptr %t2)
  %t5 = call %KValue @k_b_map(%KValue %t1, %KValue %t4)
  ret %KValue %t5
}

define %KValue @w_klam13(ptr %env, %KValue %a0) {
entry:
  %r = call tailcc %KValue @klam13(ptr %env, %KValue %a0)
  ret %KValue %r
}

define tailcc %KValue @d_utilities_2(%KValue %x0, %KValue %x1) {
entry:
  %t1 = alloca [1 x %KValue]
  %t2 = getelementptr [1 x %KValue], ptr %t1, i64 0, i64 0
  store %KValue %x1, ptr %t2
  %t3 = call %KValue @k_closure(ptr @w_klam13, i64 1, ptr %t1)
  %t4 = call %KValue @k_b_map(%KValue %x0, %KValue %t3)
  ret %KValue %t4
fail0:
  %t5 = extractvalue %KValue %x0, 0
  %t6 = icmp ne i64 %t5, 5
  %t7 = icmp ne i64 %t5, 4
  %t8 = and i1 %t6, %t7
  br i1 %t8, label %L2, label %L1
L1:
  %t9 = call %KValue @k_err_hop(%KValue %x0, ptr @s71)
  ret %KValue %t9
L2:
  %t10 = extractvalue %KValue %x1, 0
  %t11 = icmp ne i64 %t10, 5
  %t12 = icmp ne i64 %t10, 4
  %t13 = and i1 %t11, %t12
  br i1 %t13, label %L4, label %L3
L3:
  %t14 = call %KValue @k_err_hop(%KValue %x1, ptr @s71)
  ret %KValue %t14
L4:
  call void @k_die(ptr @s72)
  unreachable
}

define tailcc %KValue @d_vse_2(%KValue %x0, %KValue %x1) {
entry:
  %t1 = extractvalue %KValue %x1, 0
  %t2 = icmp ne i64 %t1, 5
  %t3 = icmp ne i64 %t1, 4
  %t4 = and i1 %t2, %t3
  br i1 %t4, label %L1, label %fail0
L1:
  %t5 = call tailcc %KValue @d_mean_1(%KValue %x0)
  %t6 = extractvalue %KValue %x0, 0
  %t7 = icmp eq i64 %t6, 13
  %t8 = extractvalue %KValue %x1, 0
  %t9 = icmp eq i64 %t8, 0
  %t10 = and i1 %t7, %t9
  br i1 %t10, label %L2, label %L3
L2:
  %t11 = extractvalue %KValue %x0, 1
  %t12 = inttoptr i64 %t11 to ptr
  %t13 = getelementptr %KBytes, ptr %t12, i64 0, i32 0
  %t14 = load i64, ptr %t13
  %t15 = extractvalue %KValue %x1, 1
  %t16 = icmp sge i64 %t15, 1
  %t17 = icmp sle i64 %t15, %t14
  %t18 = and i1 %t16, %t17
  br i1 %t18, label %L5, label %L3
L5:
  %t19 = getelementptr %KBytes, ptr %t12, i64 0, i32 1
  %t20 = load ptr, ptr %t19
  %t21 = add i64 %t15, -1
  %t22 = getelementptr i8, ptr %t20, i64 %t21
  %t23 = load i8, ptr %t22
  %t24 = zext i8 %t23 to i64
  %t25 = insertvalue %KValue { i64 0, i64 undef }, i64 %t24, 1
  br label %L4
L3:
  %t26 = call %KValue @k_b_at(%KValue %x0, %KValue %x1)
  br label %L4
L4:
  %t27 = phi %KValue [ %t25, %L5 ], [ %t26, %L3 ]
  %t28 = extractvalue %KValue %t27, 0
  %t29 = extractvalue %KValue %t5, 0
  %t30 = icmp eq i64 %t28, 0
  %t31 = icmp eq i64 %t29, 0
  %t32 = and i1 %t30, %t31
  br i1 %t32, label %L6, label %L7
L6:
  %t33 = extractvalue %KValue %t27, 1
  %t34 = extractvalue %KValue %t5, 1
  %t35 = call { i64, i1 } @llvm.ssub.with.overflow.i64(i64 %t33, i64 %t34)
  %t36 = extractvalue { i64, i1 } %t35, 0
  %t37 = extractvalue { i64, i1 } %t35, 1
  br i1 %t37, label %L7, label %L9
L9:
  %t38 = insertvalue %KValue { i64 0, i64 undef }, i64 %t36, 1
  br label %L8
L7:
  %t39 = call %KValue @k_sub(%KValue %t27, %KValue %t5)
  br label %L8
L8:
  %t40 = phi %KValue [ %t38, %L9 ], [ %t39, %L7 ]
  %t41 = call tailcc %KValue @d_maximum_1(%KValue %x0)
  %t42 = extractvalue %KValue %t41, 0
  %t43 = extractvalue %KValue %t5, 0
  %t44 = icmp eq i64 %t42, 0
  %t45 = icmp eq i64 %t43, 0
  %t46 = and i1 %t44, %t45
  br i1 %t46, label %L10, label %L11
L10:
  %t47 = extractvalue %KValue %t41, 1
  %t48 = extractvalue %KValue %t5, 1
  %t49 = call { i64, i1 } @llvm.ssub.with.overflow.i64(i64 %t47, i64 %t48)
  %t50 = extractvalue { i64, i1 } %t49, 0
  %t51 = extractvalue { i64, i1 } %t49, 1
  br i1 %t51, label %L11, label %L13
L13:
  %t52 = insertvalue %KValue { i64 0, i64 undef }, i64 %t50, 1
  br label %L12
L11:
  %t53 = call %KValue @k_sub(%KValue %t41, %KValue %t5)
  br label %L12
L12:
  %t54 = phi %KValue [ %t52, %L13 ], [ %t53, %L11 ]
  %t55 = call %KValue @k_div(%KValue %t40, %KValue %t54, ptr @s74)
  ret %KValue %t55
fail0:
  %t56 = extractvalue %KValue %x0, 0
  %t57 = icmp ne i64 %t56, 5
  %t58 = icmp ne i64 %t56, 4
  %t59 = and i1 %t57, %t58
  br i1 %t59, label %L15, label %L14
L14:
  %t60 = call %KValue @k_err_hop(%KValue %x0, ptr @s73)
  ret %KValue %t60
L15:
  %t61 = extractvalue %KValue %x1, 0
  %t62 = icmp ne i64 %t61, 5
  %t63 = icmp ne i64 %t61, 4
  %t64 = and i1 %t62, %t63
  br i1 %t64, label %L17, label %L16
L16:
  %t65 = call %KValue @k_err_hop(%KValue %x1, ptr @s73)
  ret %KValue %t65
L17:
  call void @k_die(ptr @s75)
  unreachable
}

define tailcc %KValue @klam15(ptr %env, %KValue %a0) {
entry:
  %t1 = call %KValue @k_env_get(ptr %env, i64 0)
  %t2 = musttail call tailcc %KValue @d__approves_2(%KValue %a0, %KValue %t1)
  ret %KValue %t2
}

define %KValue @w_klam15(ptr %env, %KValue %a0) {
entry:
  %r = call tailcc %KValue @klam15(ptr %env, %KValue %a0)
  ret %KValue %r
}

define tailcc %KValue @d__approval_col_2(%KValue %x0, %KValue %x1) {
entry:
  %t1 = alloca [1 x %KValue]
  %t2 = getelementptr [1 x %KValue], ptr %t1, i64 0, i64 0
  store %KValue %x1, ptr %t2
  %t3 = call %KValue @k_closure(ptr @w_klam15, i64 1, ptr %t1)
  %t4 = call %KValue @k_b_map(%KValue %x0, %KValue %t3)
  %t5 = musttail call tailcc %KValue @d_total_1(%KValue %t4)
  ret %KValue %t5
fail0:
  %t6 = extractvalue %KValue %x0, 0
  %t7 = icmp ne i64 %t6, 5
  %t8 = icmp ne i64 %t6, 4
  %t9 = and i1 %t7, %t8
  br i1 %t9, label %L2, label %L1
L1:
  %t10 = call %KValue @k_err_hop(%KValue %x0, ptr @s76)
  ret %KValue %t10
L2:
  %t11 = extractvalue %KValue %x1, 0
  %t12 = icmp ne i64 %t11, 5
  %t13 = icmp ne i64 %t11, 4
  %t14 = and i1 %t12, %t13
  br i1 %t14, label %L4, label %L3
L3:
  %t15 = call %KValue @k_err_hop(%KValue %x1, ptr @s76)
  ret %KValue %t15
L4:
  call void @k_die(ptr @s77)
  unreachable
}

define tailcc %KValue @d__approves_2(%KValue %x0, %KValue %x1) {
entry:
  %t1 = call tailcc %KValue @d_mean_1(%KValue %x0)
  %t2 = extractvalue %KValue %x0, 0
  %t3 = icmp eq i64 %t2, 13
  %t4 = extractvalue %KValue %x1, 0
  %t5 = icmp eq i64 %t4, 0
  %t6 = and i1 %t3, %t5
  br i1 %t6, label %L1, label %L2
L1:
  %t7 = extractvalue %KValue %x0, 1
  %t8 = inttoptr i64 %t7 to ptr
  %t9 = getelementptr %KBytes, ptr %t8, i64 0, i32 0
  %t10 = load i64, ptr %t9
  %t11 = extractvalue %KValue %x1, 1
  %t12 = icmp sge i64 %t11, 1
  %t13 = icmp sle i64 %t11, %t10
  %t14 = and i1 %t12, %t13
  br i1 %t14, label %L4, label %L2
L4:
  %t15 = getelementptr %KBytes, ptr %t8, i64 0, i32 1
  %t16 = load ptr, ptr %t15
  %t17 = add i64 %t11, -1
  %t18 = getelementptr i8, ptr %t16, i64 %t17
  %t19 = load i8, ptr %t18
  %t20 = zext i8 %t19 to i64
  %t21 = insertvalue %KValue { i64 0, i64 undef }, i64 %t20, 1
  br label %L3
L2:
  %t22 = call %KValue @k_b_at(%KValue %x0, %KValue %x1)
  br label %L3
L3:
  %t23 = phi %KValue [ %t21, %L4 ], [ %t22, %L2 ]
  %t24 = extractvalue %KValue %t1, 0
  %t25 = extractvalue %KValue %t23, 0
  %t26 = icmp eq i64 %t24, 0
  %t27 = icmp eq i64 %t25, 0
  %t28 = and i1 %t26, %t27
  br i1 %t28, label %L5, label %L6
L5:
  %t29 = extractvalue %KValue %t1, 1
  %t30 = extractvalue %KValue %t23, 1
  %t31 = icmp slt i64 %t29, %t30
  %t32 = select i1 %t31, %KValue { i64 2, i64 0 }, %KValue { i64 3, i64 0 }
  br label %L7
L6:
  %t33 = call %KValue @k_cmp(%KValue %t1, %KValue %t23, i64 2)
  br label %L7
L7:
  %t34 = phi %KValue [ %t32, %L5 ], [ %t33, %L6 ]
  %t35 = extractvalue %KValue %t34, 0
  %t36 = icmp ne i64 %t35, 5
  %t37 = icmp ne i64 %t35, 4
  %t38 = and i1 %t36, %t37
  br i1 %t38, label %L8, label %L9
L9:
  ret %KValue %t34
L8:
  %t39 = call i64 @k_truthy(%KValue %t34)
  %t40 = icmp ne i64 %t39, 0
  br i1 %t40, label %L10, label %L11
L10:
  ret %KValue { i64 0, i64 1 }
L11:
  ret %KValue { i64 0, i64 0 }
fail0:
  %t41 = extractvalue %KValue %x0, 0
  %t42 = icmp ne i64 %t41, 5
  %t43 = icmp ne i64 %t41, 4
  %t44 = and i1 %t42, %t43
  br i1 %t44, label %L13, label %L12
L12:
  %t45 = call %KValue @k_err_hop(%KValue %x0, ptr @s78)
  ret %KValue %t45
L13:
  %t46 = extractvalue %KValue %x1, 0
  %t47 = icmp ne i64 %t46, 5
  %t48 = icmp ne i64 %t46, 4
  %t49 = and i1 %t47, %t48
  br i1 %t49, label %L15, label %L14
L14:
  %t50 = call %KValue @k_err_hop(%KValue %x1, ptr @s78)
  ret %KValue %t50
L15:
  call void @k_die(ptr @s79)
  unreachable
}

define tailcc %KValue @klam16(ptr %env, %KValue %a0, %KValue %a1) {
entry:
  %t1 = call %KValue @k_env_get(ptr %env, i64 0)
  %t2 = call %KValue @k_env_get(ptr %env, i64 1)
  %t3 = musttail call tailcc %KValue @d__better_4(%KValue %t1, %KValue %t2, %KValue %a0, %KValue %a1)
  ret %KValue %t3
}

define %KValue @w_klam16(ptr %env, %KValue %a0, %KValue %a1) {
entry:
  %r = call tailcc %KValue @klam16(ptr %env, %KValue %a0, %KValue %a1)
  ret %KValue %r
}

define tailcc %KValue @d__argmax_except_2(%KValue %x0, %KValue %x1) {
entry:
  %t1 = extractvalue %KValue %x1, 0
  %t2 = icmp ne i64 %t1, 5
  %t3 = icmp ne i64 %t1, 4
  %t4 = and i1 %t2, %t3
  br i1 %t4, label %L1, label %fail0
L1:
  %t5 = extractvalue %KValue %x1, 0
  %t6 = extractvalue %KValue { i64 0, i64 1 }, 0
  %t7 = icmp eq i64 %t5, 0
  %t8 = icmp eq i64 %t6, 0
  %t9 = and i1 %t7, %t8
  br i1 %t9, label %L2, label %L3
L2:
  %t10 = extractvalue %KValue %x1, 1
  %t11 = extractvalue %KValue { i64 0, i64 1 }, 1
  %t12 = icmp eq i64 %t10, %t11
  %t13 = select i1 %t12, %KValue { i64 2, i64 0 }, %KValue { i64 3, i64 0 }
  br label %L4
L3:
  %t14 = call %KValue @k_cmp(%KValue %x1, %KValue { i64 0, i64 1 }, i64 0)
  br label %L4
L4:
  %t15 = phi %KValue [ %t13, %L2 ], [ %t14, %L3 ]
  %t16 = call i64 @k_not_failure(%KValue %t15)
  %t17 = icmp ne i64 %t16, 0
  br i1 %t17, label %L5, label %L6
L5:
  %t18 = call i64 @k_truthy(%KValue %t15)
  %t19 = icmp ne i64 %t18, 0
  br i1 %t19, label %L7, label %L8
L7:
  br label %L6
L8:
  br label %L6
L6:
  %t20 = phi %KValue [ %t15, %L4 ], [ { i64 0, i64 2 }, %L7 ], [ { i64 0, i64 1 }, %L8 ]
  %t21 = call %KValue @k_b_length(%KValue %x0)
  %t22 = extractvalue %KValue %t21, 1
  %t23 = call tailcc %KValue @d_range_1(i64 %t22)
  %t24 = alloca [2 x %KValue]
  %t25 = getelementptr [2 x %KValue], ptr %t24, i64 0, i64 0
  store %KValue %x0, ptr %t25
  %t26 = getelementptr [2 x %KValue], ptr %t24, i64 0, i64 1
  store %KValue %x1, ptr %t26
  %t27 = call %KValue @k_closure(ptr @w_klam16, i64 2, ptr %t24)
  %t28 = musttail call tailcc %KValue @d_fold_3(%KValue %t23, %KValue %t20, %KValue %t27)
  ret %KValue %t28
fail0:
  %t29 = extractvalue %KValue %x0, 0
  %t30 = icmp ne i64 %t29, 5
  %t31 = icmp ne i64 %t29, 4
  %t32 = and i1 %t30, %t31
  br i1 %t32, label %L10, label %L9
L9:
  %t33 = call %KValue @k_err_hop(%KValue %x0, ptr @s80)
  ret %KValue %t33
L10:
  %t34 = extractvalue %KValue %x1, 0
  %t35 = icmp ne i64 %t34, 5
  %t36 = icmp ne i64 %t34, 4
  %t37 = and i1 %t35, %t36
  br i1 %t37, label %L12, label %L11
L11:
  %t38 = call %KValue @k_err_hop(%KValue %x1, ptr @s80)
  ret %KValue %t38
L12:
  call void @k_die(ptr @s81)
  unreachable
}

define tailcc %KValue @d__better_4(%KValue %x0, %KValue %x1, %KValue %x2, %KValue %x3) {
entry:
  %t1 = extractvalue %KValue %x3, 0
  %t2 = extractvalue %KValue %x1, 0
  %t3 = icmp eq i64 %t1, 0
  %t4 = icmp eq i64 %t2, 0
  %t5 = and i1 %t3, %t4
  br i1 %t5, label %L1, label %L2
L1:
  %t6 = extractvalue %KValue %x3, 1
  %t7 = extractvalue %KValue %x1, 1
  %t8 = icmp eq i64 %t6, %t7
  %t9 = select i1 %t8, %KValue { i64 2, i64 0 }, %KValue { i64 3, i64 0 }
  br label %L3
L2:
  %t10 = call %KValue @k_cmp(%KValue %x3, %KValue %x1, i64 0)
  br label %L3
L3:
  %t11 = phi %KValue [ %t9, %L1 ], [ %t10, %L2 ]
  %t12 = extractvalue %KValue %t11, 0
  %t13 = icmp ne i64 %t12, 5
  %t14 = icmp ne i64 %t12, 4
  %t15 = and i1 %t13, %t14
  br i1 %t15, label %L4, label %L5
L5:
  ret %KValue %t11
L4:
  %t16 = call i64 @k_truthy(%KValue %t11)
  %t17 = icmp ne i64 %t16, 0
  br i1 %t17, label %L6, label %L7
L6:
  ret %KValue %x2
L7:
  %t18 = extractvalue %KValue %x0, 0
  %t19 = icmp eq i64 %t18, 13
  %t20 = extractvalue %KValue %x2, 0
  %t21 = icmp eq i64 %t20, 0
  %t22 = and i1 %t19, %t21
  br i1 %t22, label %L8, label %L9
L8:
  %t23 = extractvalue %KValue %x0, 1
  %t24 = inttoptr i64 %t23 to ptr
  %t25 = getelementptr %KBytes, ptr %t24, i64 0, i32 0
  %t26 = load i64, ptr %t25
  %t27 = extractvalue %KValue %x2, 1
  %t28 = icmp sge i64 %t27, 1
  %t29 = icmp sle i64 %t27, %t26
  %t30 = and i1 %t28, %t29
  br i1 %t30, label %L11, label %L9
L11:
  %t31 = getelementptr %KBytes, ptr %t24, i64 0, i32 1
  %t32 = load ptr, ptr %t31
  %t33 = add i64 %t27, -1
  %t34 = getelementptr i8, ptr %t32, i64 %t33
  %t35 = load i8, ptr %t34
  %t36 = zext i8 %t35 to i64
  %t37 = insertvalue %KValue { i64 0, i64 undef }, i64 %t36, 1
  br label %L10
L9:
  %t38 = call %KValue @k_b_at(%KValue %x0, %KValue %x2)
  br label %L10
L10:
  %t39 = phi %KValue [ %t37, %L11 ], [ %t38, %L9 ]
  %t40 = extractvalue %KValue %x0, 0
  %t41 = icmp eq i64 %t40, 13
  %t42 = extractvalue %KValue %x3, 0
  %t43 = icmp eq i64 %t42, 0
  %t44 = and i1 %t41, %t43
  br i1 %t44, label %L12, label %L13
L12:
  %t45 = extractvalue %KValue %x0, 1
  %t46 = inttoptr i64 %t45 to ptr
  %t47 = getelementptr %KBytes, ptr %t46, i64 0, i32 0
  %t48 = load i64, ptr %t47
  %t49 = extractvalue %KValue %x3, 1
  %t50 = icmp sge i64 %t49, 1
  %t51 = icmp sle i64 %t49, %t48
  %t52 = and i1 %t50, %t51
  br i1 %t52, label %L15, label %L13
L15:
  %t53 = getelementptr %KBytes, ptr %t46, i64 0, i32 1
  %t54 = load ptr, ptr %t53
  %t55 = add i64 %t49, -1
  %t56 = getelementptr i8, ptr %t54, i64 %t55
  %t57 = load i8, ptr %t56
  %t58 = zext i8 %t57 to i64
  %t59 = insertvalue %KValue { i64 0, i64 undef }, i64 %t58, 1
  br label %L14
L13:
  %t60 = call %KValue @k_b_at(%KValue %x0, %KValue %x3)
  br label %L14
L14:
  %t61 = phi %KValue [ %t59, %L15 ], [ %t60, %L13 ]
  %t62 = extractvalue %KValue %t39, 0
  %t63 = extractvalue %KValue %t61, 0
  %t64 = icmp eq i64 %t62, 0
  %t65 = icmp eq i64 %t63, 0
  %t66 = and i1 %t64, %t65
  br i1 %t66, label %L16, label %L17
L16:
  %t67 = extractvalue %KValue %t39, 1
  %t68 = extractvalue %KValue %t61, 1
  %t69 = icmp slt i64 %t67, %t68
  %t70 = select i1 %t69, %KValue { i64 2, i64 0 }, %KValue { i64 3, i64 0 }
  br label %L18
L17:
  %t71 = call %KValue @k_cmp(%KValue %t39, %KValue %t61, i64 2)
  br label %L18
L18:
  %t72 = phi %KValue [ %t70, %L16 ], [ %t71, %L17 ]
  %t73 = extractvalue %KValue %t72, 0
  %t74 = icmp ne i64 %t73, 5
  %t75 = icmp ne i64 %t73, 4
  %t76 = and i1 %t74, %t75
  br i1 %t76, label %L19, label %L20
L20:
  ret %KValue %t72
L19:
  %t77 = call i64 @k_truthy(%KValue %t72)
  %t78 = icmp ne i64 %t77, 0
  br i1 %t78, label %L21, label %L22
L21:
  ret %KValue %x3
L22:
  ret %KValue %x2
fail0:
  %t79 = extractvalue %KValue %x0, 0
  %t80 = icmp ne i64 %t79, 5
  %t81 = icmp ne i64 %t79, 4
  %t82 = and i1 %t80, %t81
  br i1 %t82, label %L24, label %L23
L23:
  %t83 = call %KValue @k_err_hop(%KValue %x0, ptr @s82)
  ret %KValue %t83
L24:
  %t84 = extractvalue %KValue %x1, 0
  %t85 = icmp ne i64 %t84, 5
  %t86 = icmp ne i64 %t84, 4
  %t87 = and i1 %t85, %t86
  br i1 %t87, label %L26, label %L25
L25:
  %t88 = call %KValue @k_err_hop(%KValue %x1, ptr @s82)
  ret %KValue %t88
L26:
  %t89 = extractvalue %KValue %x2, 0
  %t90 = icmp ne i64 %t89, 5
  %t91 = icmp ne i64 %t89, 4
  %t92 = and i1 %t90, %t91
  br i1 %t92, label %L28, label %L27
L27:
  %t93 = call %KValue @k_err_hop(%KValue %x2, ptr @s82)
  ret %KValue %t93
L28:
  %t94 = extractvalue %KValue %x3, 0
  %t95 = icmp ne i64 %t94, 5
  %t96 = icmp ne i64 %t94, 4
  %t97 = and i1 %t95, %t96
  br i1 %t97, label %L30, label %L29
L29:
  %t98 = call %KValue @k_err_hop(%KValue %x3, ptr @s82)
  ret %KValue %t98
L30:
  call void @k_die(ptr @s83)
  unreachable
}

define tailcc %KValue @d__first_is_3(%KValue %x0, %KValue %x1, %KValue %x2) {
entry:
  %t1 = call tailcc %KValue @d__rank_first_2(%KValue %x0, %KValue %x1)
  %t2 = extractvalue %KValue %t1, 0
  %t3 = extractvalue %KValue %x2, 0
  %t4 = icmp eq i64 %t2, 0
  %t5 = icmp eq i64 %t3, 0
  %t6 = and i1 %t4, %t5
  br i1 %t6, label %L1, label %L2
L1:
  %t7 = extractvalue %KValue %t1, 1
  %t8 = extractvalue %KValue %x2, 1
  %t9 = icmp eq i64 %t7, %t8
  %t10 = select i1 %t9, %KValue { i64 2, i64 0 }, %KValue { i64 3, i64 0 }
  br label %L3
L2:
  %t11 = call %KValue @k_cmp(%KValue %t1, %KValue %x2, i64 0)
  br label %L3
L3:
  %t12 = phi %KValue [ %t10, %L1 ], [ %t11, %L2 ]
  %t13 = extractvalue %KValue %t12, 0
  %t14 = icmp ne i64 %t13, 5
  %t15 = icmp ne i64 %t13, 4
  %t16 = and i1 %t14, %t15
  br i1 %t16, label %L4, label %L5
L5:
  ret %KValue %t12
L4:
  %t17 = call i64 @k_truthy(%KValue %t12)
  %t18 = icmp ne i64 %t17, 0
  br i1 %t18, label %L6, label %L7
L6:
  ret %KValue { i64 0, i64 1 }
L7:
  ret %KValue { i64 0, i64 0 }
fail0:
  %t19 = extractvalue %KValue %x0, 0
  %t20 = icmp ne i64 %t19, 5
  %t21 = icmp ne i64 %t19, 4
  %t22 = and i1 %t20, %t21
  br i1 %t22, label %L9, label %L8
L8:
  %t23 = call %KValue @k_err_hop(%KValue %x0, ptr @s84)
  ret %KValue %t23
L9:
  %t24 = extractvalue %KValue %x1, 0
  %t25 = icmp ne i64 %t24, 5
  %t26 = icmp ne i64 %t24, 4
  %t27 = and i1 %t25, %t26
  br i1 %t27, label %L11, label %L10
L10:
  %t28 = call %KValue @k_err_hop(%KValue %x1, ptr @s84)
  ret %KValue %t28
L11:
  %t29 = extractvalue %KValue %x2, 0
  %t30 = icmp ne i64 %t29, 5
  %t31 = icmp ne i64 %t29, 4
  %t32 = and i1 %t30, %t31
  br i1 %t32, label %L13, label %L12
L12:
  %t33 = call %KValue @k_err_hop(%KValue %x2, ptr @s84)
  ret %KValue %t33
L13:
  call void @k_die(ptr @s85)
  unreachable
}

define tailcc %KValue @d__in_2(%KValue %x0, %KValue %x1) {
entry:
  %t1 = call tailcc %KValue @d_count_2(%KValue %x0, %KValue %x1)
  %t2 = extractvalue %KValue %t1, 0
  %t3 = extractvalue %KValue { i64 0, i64 0 }, 0
  %t4 = icmp eq i64 %t2, 0
  %t5 = icmp eq i64 %t3, 0
  %t6 = and i1 %t4, %t5
  br i1 %t6, label %L1, label %L2
L1:
  %t7 = extractvalue %KValue %t1, 1
  %t8 = extractvalue %KValue { i64 0, i64 0 }, 1
  %t9 = icmp eq i64 %t7, %t8
  %t10 = select i1 %t9, %KValue { i64 2, i64 0 }, %KValue { i64 3, i64 0 }
  br label %L3
L2:
  %t11 = call %KValue @k_cmp(%KValue %t1, %KValue { i64 0, i64 0 }, i64 0)
  br label %L3
L3:
  %t12 = phi %KValue [ %t10, %L1 ], [ %t11, %L2 ]
  %t13 = extractvalue %KValue %t12, 0
  %t14 = icmp ne i64 %t13, 5
  %t15 = icmp ne i64 %t13, 4
  %t16 = and i1 %t14, %t15
  br i1 %t16, label %L4, label %L5
L5:
  ret %KValue %t12
L4:
  %t17 = call i64 @k_truthy(%KValue %t12)
  %t18 = icmp ne i64 %t17, 0
  br i1 %t18, label %L6, label %L7
L6:
  ret %KValue { i64 3, i64 0 }
L7:
  ret %KValue { i64 2, i64 0 }
fail0:
  %t19 = extractvalue %KValue %x0, 0
  %t20 = icmp ne i64 %t19, 5
  %t21 = icmp ne i64 %t19, 4
  %t22 = and i1 %t20, %t21
  br i1 %t22, label %L9, label %L8
L8:
  %t23 = call %KValue @k_err_hop(%KValue %x0, ptr @s86)
  ret %KValue %t23
L9:
  %t24 = extractvalue %KValue %x1, 0
  %t25 = icmp ne i64 %t24, 5
  %t26 = icmp ne i64 %t24, 4
  %t27 = and i1 %t25, %t26
  br i1 %t27, label %L11, label %L10
L10:
  %t28 = call %KValue @k_err_hop(%KValue %x1, ptr @s86)
  ret %KValue %t28
L11:
  call void @k_die(ptr @s87)
  unreachable
}

define tailcc %KValue @klam18(ptr %env, %KValue %a0) {
entry:
  %t1 = call %KValue @k_env_get(ptr %env, i64 0)
  %t2 = call %KValue @k_env_get(ptr %env, i64 1)
  %t3 = musttail call tailcc %KValue @d__first_is_3(%KValue %a0, %KValue %t1, %KValue %t2)
  ret %KValue %t3
}

define %KValue @w_klam18(ptr %env, %KValue %a0) {
entry:
  %r = call tailcc %KValue @klam18(ptr %env, %KValue %a0)
  ret %KValue %r
}

define tailcc %KValue @klam17(ptr %env, %KValue %a0) {
entry:
  %t1 = call %KValue @k_env_get(ptr %env, i64 0)
  %t2 = call %KValue @k_env_get(ptr %env, i64 1)
  %t3 = alloca [2 x %KValue]
  %t4 = getelementptr [2 x %KValue], ptr %t3, i64 0, i64 0
  store %KValue %t2, ptr %t4
  %t5 = getelementptr [2 x %KValue], ptr %t3, i64 0, i64 1
  store %KValue %a0, ptr %t5
  %t6 = call %KValue @k_closure(ptr @w_klam18, i64 2, ptr %t3)
  %t7 = call %KValue @k_b_map(%KValue %t1, %KValue %t6)
  %t8 = musttail call tailcc %KValue @d_total_1(%KValue %t7)
  ret %KValue %t8
}

define %KValue @w_klam17(ptr %env, %KValue %a0) {
entry:
  %r = call tailcc %KValue @klam17(ptr %env, %KValue %a0)
  ret %KValue %r
}

define tailcc %KValue @d__irv_counts_2(%KValue %x0, %KValue %x1) {
entry:
  %t1 = call tailcc %KValue @d_ncand_0()
  %t2 = extractvalue %KValue %t1, 1
  %t3 = call tailcc %KValue @d_range_1(i64 %t2)
  %t4 = alloca [2 x %KValue]
  %t5 = getelementptr [2 x %KValue], ptr %t4, i64 0, i64 0
  store %KValue %x0, ptr %t5
  %t6 = getelementptr [2 x %KValue], ptr %t4, i64 0, i64 1
  store %KValue %x1, ptr %t6
  %t7 = call %KValue @k_closure(ptr @w_klam17, i64 2, ptr %t4)
  %t8 = call %KValue @k_b_map(%KValue %t3, %KValue %t7)
  ret %KValue %t8
fail0:
  %t9 = extractvalue %KValue %x0, 0
  %t10 = icmp ne i64 %t9, 5
  %t11 = icmp ne i64 %t9, 4
  %t12 = and i1 %t10, %t11
  br i1 %t12, label %L2, label %L1
L1:
  %t13 = call %KValue @k_err_hop(%KValue %x0, ptr @s88)
  ret %KValue %t13
L2:
  %t14 = extractvalue %KValue %x1, 0
  %t15 = icmp ne i64 %t14, 5
  %t16 = icmp ne i64 %t14, 4
  %t17 = and i1 %t15, %t16
  br i1 %t17, label %L4, label %L3
L3:
  %t18 = call %KValue @k_err_hop(%KValue %x1, ptr @s88)
  ret %KValue %t18
L4:
  call void @k_die(ptr @s89)
  unreachable
}

define tailcc %KValue @d__irv_go_2(%KValue %x0, %KValue %x1) {
entry:
  %t1 = extractvalue %KValue %x1, 0
  %t2 = icmp ne i64 %t1, 5
  %t3 = icmp ne i64 %t1, 4
  %t4 = and i1 %t2, %t3
  br i1 %t4, label %L1, label %fail0
L1:
  %t5 = call tailcc %KValue @d__irv_counts_2(%KValue %x0, %KValue %x1)
  %t6 = call tailcc %KValue @d_argmax_1(%KValue %t5)
  %t7 = call tailcc %KValue @d_nvot_0()
  %t8 = extractvalue %KValue %t5, 0
  %t9 = icmp eq i64 %t8, 13
  %t10 = extractvalue %KValue %t6, 0
  %t11 = icmp eq i64 %t10, 0
  %t12 = and i1 %t9, %t11
  br i1 %t12, label %L2, label %L3
L2:
  %t13 = extractvalue %KValue %t5, 1
  %t14 = inttoptr i64 %t13 to ptr
  %t15 = getelementptr %KBytes, ptr %t14, i64 0, i32 0
  %t16 = load i64, ptr %t15
  %t17 = extractvalue %KValue %t6, 1
  %t18 = icmp sge i64 %t17, 1
  %t19 = icmp sle i64 %t17, %t16
  %t20 = and i1 %t18, %t19
  br i1 %t20, label %L5, label %L3
L5:
  %t21 = getelementptr %KBytes, ptr %t14, i64 0, i32 1
  %t22 = load ptr, ptr %t21
  %t23 = add i64 %t17, -1
  %t24 = getelementptr i8, ptr %t22, i64 %t23
  %t25 = load i8, ptr %t24
  %t26 = zext i8 %t25 to i64
  %t27 = insertvalue %KValue { i64 0, i64 undef }, i64 %t26, 1
  br label %L4
L3:
  %t28 = call %KValue @k_b_at(%KValue %t5, %KValue %t6)
  br label %L4
L4:
  %t29 = phi %KValue [ %t27, %L5 ], [ %t28, %L3 ]
  %t30 = extractvalue %KValue { i64 0, i64 2 }, 0
  %t31 = extractvalue %KValue %t29, 0
  %t32 = icmp eq i64 %t30, 0
  %t33 = icmp eq i64 %t31, 0
  %t34 = and i1 %t32, %t33
  br i1 %t34, label %L6, label %L7
L6:
  %t35 = extractvalue %KValue { i64 0, i64 2 }, 1
  %t36 = extractvalue %KValue %t29, 1
  %t37 = call { i64, i1 } @llvm.smul.with.overflow.i64(i64 %t35, i64 %t36)
  %t38 = extractvalue { i64, i1 } %t37, 0
  %t39 = extractvalue { i64, i1 } %t37, 1
  br i1 %t39, label %L7, label %L9
L9:
  %t40 = insertvalue %KValue { i64 0, i64 undef }, i64 %t38, 1
  br label %L8
L7:
  %t41 = call %KValue @k_mul(%KValue { i64 0, i64 2 }, %KValue %t29)
  br label %L8
L8:
  %t42 = phi %KValue [ %t40, %L9 ], [ %t41, %L7 ]
  %t43 = extractvalue %KValue %t7, 0
  %t44 = extractvalue %KValue %t42, 0
  %t45 = icmp eq i64 %t43, 0
  %t46 = icmp eq i64 %t44, 0
  %t47 = and i1 %t45, %t46
  br i1 %t47, label %L10, label %L11
L10:
  %t48 = extractvalue %KValue %t7, 1
  %t49 = extractvalue %KValue %t42, 1
  %t50 = icmp slt i64 %t48, %t49
  %t51 = select i1 %t50, %KValue { i64 2, i64 0 }, %KValue { i64 3, i64 0 }
  br label %L12
L11:
  %t52 = call %KValue @k_cmp(%KValue %t7, %KValue %t42, i64 2)
  br label %L12
L12:
  %t53 = phi %KValue [ %t51, %L10 ], [ %t52, %L11 ]
  %t54 = extractvalue %KValue %t53, 0
  %t55 = icmp ne i64 %t54, 5
  %t56 = icmp ne i64 %t54, 4
  %t57 = and i1 %t55, %t56
  br i1 %t57, label %L13, label %L14
L14:
  ret %KValue %t53
L13:
  %t58 = call i64 @k_truthy(%KValue %t53)
  %t59 = icmp ne i64 %t58, 0
  br i1 %t59, label %L15, label %L16
L15:
  ret %KValue %t6
L16:
  %t60 = musttail call tailcc %KValue @d__irv_next_3(%KValue %x0, %KValue %x1, %KValue %t5)
  ret %KValue %t60
fail0:
  %t61 = extractvalue %KValue %x0, 0
  %t62 = icmp ne i64 %t61, 5
  %t63 = icmp ne i64 %t61, 4
  %t64 = and i1 %t62, %t63
  br i1 %t64, label %L18, label %L17
L17:
  %t65 = call %KValue @k_err_hop(%KValue %x0, ptr @s90)
  ret %KValue %t65
L18:
  %t66 = extractvalue %KValue %x1, 0
  %t67 = icmp ne i64 %t66, 5
  %t68 = icmp ne i64 %t66, 4
  %t69 = and i1 %t67, %t68
  br i1 %t69, label %L20, label %L19
L19:
  %t70 = call %KValue @k_err_hop(%KValue %x1, ptr @s90)
  ret %KValue %t70
L20:
  call void @k_die(ptr @s91)
  unreachable
}

define tailcc %KValue @d__irv_next_3(%KValue %x0, %KValue %x1, %KValue %x2) {
entry:
  %t1 = call tailcc %KValue @d__min_alive_2(%KValue %x2, %KValue %x1)
  %t2 = call %KValue @k_b_push(%KValue %x1, %KValue %t1)
  %t3 = musttail call tailcc %KValue @d__irv_go_2(%KValue %x0, %KValue %t2)
  ret %KValue %t3
fail0:
  %t4 = extractvalue %KValue %x0, 0
  %t5 = icmp ne i64 %t4, 5
  %t6 = icmp ne i64 %t4, 4
  %t7 = and i1 %t5, %t6
  br i1 %t7, label %L2, label %L1
L1:
  %t8 = call %KValue @k_err_hop(%KValue %x0, ptr @s92)
  ret %KValue %t8
L2:
  %t9 = extractvalue %KValue %x1, 0
  %t10 = icmp ne i64 %t9, 5
  %t11 = icmp ne i64 %t9, 4
  %t12 = and i1 %t10, %t11
  br i1 %t12, label %L4, label %L3
L3:
  %t13 = call %KValue @k_err_hop(%KValue %x1, ptr @s92)
  ret %KValue %t13
L4:
  %t14 = extractvalue %KValue %x2, 0
  %t15 = icmp ne i64 %t14, 5
  %t16 = icmp ne i64 %t14, 4
  %t17 = and i1 %t15, %t16
  br i1 %t17, label %L6, label %L5
L5:
  %t18 = call %KValue @k_err_hop(%KValue %x2, ptr @s92)
  ret %KValue %t18
L6:
  call void @k_die(ptr @s93)
  unreachable
}

define tailcc %KValue @d__keep_min_4(%KValue %x0, %KValue %x1, %KValue %x2, %KValue %x3) {
entry:
  %t1 = call tailcc %KValue @d__in_2(%KValue %x1, %KValue %x3)
  %t2 = extractvalue %KValue %t1, 0
  %t3 = icmp ne i64 %t2, 5
  %t4 = icmp ne i64 %t2, 4
  %t5 = and i1 %t3, %t4
  br i1 %t5, label %L1, label %L2
L2:
  ret %KValue %t1
L1:
  %t6 = call i64 @k_truthy(%KValue %t1)
  %t7 = icmp ne i64 %t6, 0
  br i1 %t7, label %L3, label %L4
L3:
  ret %KValue %x2
L4:
  %t8 = extractvalue %KValue %x2, 0
  %t9 = extractvalue %KValue { i64 0, i64 0 }, 0
  %t10 = icmp eq i64 %t8, 0
  %t11 = icmp eq i64 %t9, 0
  %t12 = and i1 %t10, %t11
  br i1 %t12, label %L5, label %L6
L5:
  %t13 = extractvalue %KValue %x2, 1
  %t14 = extractvalue %KValue { i64 0, i64 0 }, 1
  %t15 = icmp eq i64 %t13, %t14
  %t16 = select i1 %t15, %KValue { i64 2, i64 0 }, %KValue { i64 3, i64 0 }
  br label %L7
L6:
  %t17 = call %KValue @k_cmp(%KValue %x2, %KValue { i64 0, i64 0 }, i64 0)
  br label %L7
L7:
  %t18 = phi %KValue [ %t16, %L5 ], [ %t17, %L6 ]
  %t19 = extractvalue %KValue %t18, 0
  %t20 = icmp ne i64 %t19, 5
  %t21 = icmp ne i64 %t19, 4
  %t22 = and i1 %t20, %t21
  br i1 %t22, label %L8, label %L9
L9:
  ret %KValue %t18
L8:
  %t23 = call i64 @k_truthy(%KValue %t18)
  %t24 = icmp ne i64 %t23, 0
  br i1 %t24, label %L10, label %L11
L10:
  ret %KValue %x3
L11:
  %t25 = extractvalue %KValue %x0, 0
  %t26 = icmp eq i64 %t25, 13
  %t27 = extractvalue %KValue %x3, 0
  %t28 = icmp eq i64 %t27, 0
  %t29 = and i1 %t26, %t28
  br i1 %t29, label %L12, label %L13
L12:
  %t30 = extractvalue %KValue %x0, 1
  %t31 = inttoptr i64 %t30 to ptr
  %t32 = getelementptr %KBytes, ptr %t31, i64 0, i32 0
  %t33 = load i64, ptr %t32
  %t34 = extractvalue %KValue %x3, 1
  %t35 = icmp sge i64 %t34, 1
  %t36 = icmp sle i64 %t34, %t33
  %t37 = and i1 %t35, %t36
  br i1 %t37, label %L15, label %L13
L15:
  %t38 = getelementptr %KBytes, ptr %t31, i64 0, i32 1
  %t39 = load ptr, ptr %t38
  %t40 = add i64 %t34, -1
  %t41 = getelementptr i8, ptr %t39, i64 %t40
  %t42 = load i8, ptr %t41
  %t43 = zext i8 %t42 to i64
  %t44 = insertvalue %KValue { i64 0, i64 undef }, i64 %t43, 1
  br label %L14
L13:
  %t45 = call %KValue @k_b_at(%KValue %x0, %KValue %x3)
  br label %L14
L14:
  %t46 = phi %KValue [ %t44, %L15 ], [ %t45, %L13 ]
  %t47 = extractvalue %KValue %x0, 0
  %t48 = icmp eq i64 %t47, 13
  %t49 = extractvalue %KValue %x2, 0
  %t50 = icmp eq i64 %t49, 0
  %t51 = and i1 %t48, %t50
  br i1 %t51, label %L16, label %L17
L16:
  %t52 = extractvalue %KValue %x0, 1
  %t53 = inttoptr i64 %t52 to ptr
  %t54 = getelementptr %KBytes, ptr %t53, i64 0, i32 0
  %t55 = load i64, ptr %t54
  %t56 = extractvalue %KValue %x2, 1
  %t57 = icmp sge i64 %t56, 1
  %t58 = icmp sle i64 %t56, %t55
  %t59 = and i1 %t57, %t58
  br i1 %t59, label %L19, label %L17
L19:
  %t60 = getelementptr %KBytes, ptr %t53, i64 0, i32 1
  %t61 = load ptr, ptr %t60
  %t62 = add i64 %t56, -1
  %t63 = getelementptr i8, ptr %t61, i64 %t62
  %t64 = load i8, ptr %t63
  %t65 = zext i8 %t64 to i64
  %t66 = insertvalue %KValue { i64 0, i64 undef }, i64 %t65, 1
  br label %L18
L17:
  %t67 = call %KValue @k_b_at(%KValue %x0, %KValue %x2)
  br label %L18
L18:
  %t68 = phi %KValue [ %t66, %L19 ], [ %t67, %L17 ]
  %t69 = extractvalue %KValue %t46, 0
  %t70 = extractvalue %KValue %t68, 0
  %t71 = icmp eq i64 %t69, 0
  %t72 = icmp eq i64 %t70, 0
  %t73 = and i1 %t71, %t72
  br i1 %t73, label %L20, label %L21
L20:
  %t74 = extractvalue %KValue %t46, 1
  %t75 = extractvalue %KValue %t68, 1
  %t76 = icmp slt i64 %t74, %t75
  %t77 = select i1 %t76, %KValue { i64 2, i64 0 }, %KValue { i64 3, i64 0 }
  br label %L22
L21:
  %t78 = call %KValue @k_cmp(%KValue %t46, %KValue %t68, i64 2)
  br label %L22
L22:
  %t79 = phi %KValue [ %t77, %L20 ], [ %t78, %L21 ]
  %t80 = extractvalue %KValue %t79, 0
  %t81 = icmp ne i64 %t80, 5
  %t82 = icmp ne i64 %t80, 4
  %t83 = and i1 %t81, %t82
  br i1 %t83, label %L23, label %L24
L24:
  ret %KValue %t79
L23:
  %t84 = call i64 @k_truthy(%KValue %t79)
  %t85 = icmp ne i64 %t84, 0
  br i1 %t85, label %L25, label %L26
L25:
  ret %KValue %x3
L26:
  ret %KValue %x2
fail0:
  %t86 = extractvalue %KValue %x0, 0
  %t87 = icmp ne i64 %t86, 5
  %t88 = icmp ne i64 %t86, 4
  %t89 = and i1 %t87, %t88
  br i1 %t89, label %L28, label %L27
L27:
  %t90 = call %KValue @k_err_hop(%KValue %x0, ptr @s94)
  ret %KValue %t90
L28:
  %t91 = extractvalue %KValue %x1, 0
  %t92 = icmp ne i64 %t91, 5
  %t93 = icmp ne i64 %t91, 4
  %t94 = and i1 %t92, %t93
  br i1 %t94, label %L30, label %L29
L29:
  %t95 = call %KValue @k_err_hop(%KValue %x1, ptr @s94)
  ret %KValue %t95
L30:
  %t96 = extractvalue %KValue %x2, 0
  %t97 = icmp ne i64 %t96, 5
  %t98 = icmp ne i64 %t96, 4
  %t99 = and i1 %t97, %t98
  br i1 %t99, label %L32, label %L31
L31:
  %t100 = call %KValue @k_err_hop(%KValue %x2, ptr @s94)
  ret %KValue %t100
L32:
  %t101 = extractvalue %KValue %x3, 0
  %t102 = icmp ne i64 %t101, 5
  %t103 = icmp ne i64 %t101, 4
  %t104 = and i1 %t102, %t103
  br i1 %t104, label %L34, label %L33
L33:
  %t105 = call %KValue @k_err_hop(%KValue %x3, ptr @s94)
  ret %KValue %t105
L34:
  call void @k_die(ptr @s95)
  unreachable
}

define tailcc %KValue @d__keep_top_4(%KValue %x0, %KValue %x1, %KValue %x2, %KValue %x3) {
entry:
  %t1 = call tailcc %KValue @d__in_2(%KValue %x1, %KValue %x3)
  %t2 = extractvalue %KValue %t1, 0
  %t3 = icmp ne i64 %t2, 5
  %t4 = icmp ne i64 %t2, 4
  %t5 = and i1 %t3, %t4
  br i1 %t5, label %L1, label %L2
L2:
  ret %KValue %t1
L1:
  %t6 = call i64 @k_truthy(%KValue %t1)
  %t7 = icmp ne i64 %t6, 0
  br i1 %t7, label %L3, label %L4
L3:
  ret %KValue %x2
L4:
  %t8 = extractvalue %KValue %x2, 0
  %t9 = extractvalue %KValue { i64 0, i64 0 }, 0
  %t10 = icmp eq i64 %t8, 0
  %t11 = icmp eq i64 %t9, 0
  %t12 = and i1 %t10, %t11
  br i1 %t12, label %L5, label %L6
L5:
  %t13 = extractvalue %KValue %x2, 1
  %t14 = extractvalue %KValue { i64 0, i64 0 }, 1
  %t15 = icmp eq i64 %t13, %t14
  %t16 = select i1 %t15, %KValue { i64 2, i64 0 }, %KValue { i64 3, i64 0 }
  br label %L7
L6:
  %t17 = call %KValue @k_cmp(%KValue %x2, %KValue { i64 0, i64 0 }, i64 0)
  br label %L7
L7:
  %t18 = phi %KValue [ %t16, %L5 ], [ %t17, %L6 ]
  %t19 = extractvalue %KValue %t18, 0
  %t20 = icmp ne i64 %t19, 5
  %t21 = icmp ne i64 %t19, 4
  %t22 = and i1 %t20, %t21
  br i1 %t22, label %L8, label %L9
L9:
  ret %KValue %t18
L8:
  %t23 = call i64 @k_truthy(%KValue %t18)
  %t24 = icmp ne i64 %t23, 0
  br i1 %t24, label %L10, label %L11
L10:
  ret %KValue %x3
L11:
  %t25 = extractvalue %KValue %x0, 0
  %t26 = icmp eq i64 %t25, 13
  %t27 = extractvalue %KValue %x2, 0
  %t28 = icmp eq i64 %t27, 0
  %t29 = and i1 %t26, %t28
  br i1 %t29, label %L12, label %L13
L12:
  %t30 = extractvalue %KValue %x0, 1
  %t31 = inttoptr i64 %t30 to ptr
  %t32 = getelementptr %KBytes, ptr %t31, i64 0, i32 0
  %t33 = load i64, ptr %t32
  %t34 = extractvalue %KValue %x2, 1
  %t35 = icmp sge i64 %t34, 1
  %t36 = icmp sle i64 %t34, %t33
  %t37 = and i1 %t35, %t36
  br i1 %t37, label %L15, label %L13
L15:
  %t38 = getelementptr %KBytes, ptr %t31, i64 0, i32 1
  %t39 = load ptr, ptr %t38
  %t40 = add i64 %t34, -1
  %t41 = getelementptr i8, ptr %t39, i64 %t40
  %t42 = load i8, ptr %t41
  %t43 = zext i8 %t42 to i64
  %t44 = insertvalue %KValue { i64 0, i64 undef }, i64 %t43, 1
  br label %L14
L13:
  %t45 = call %KValue @k_b_at(%KValue %x0, %KValue %x2)
  br label %L14
L14:
  %t46 = phi %KValue [ %t44, %L15 ], [ %t45, %L13 ]
  %t47 = extractvalue %KValue %x0, 0
  %t48 = icmp eq i64 %t47, 13
  %t49 = extractvalue %KValue %x3, 0
  %t50 = icmp eq i64 %t49, 0
  %t51 = and i1 %t48, %t50
  br i1 %t51, label %L16, label %L17
L16:
  %t52 = extractvalue %KValue %x0, 1
  %t53 = inttoptr i64 %t52 to ptr
  %t54 = getelementptr %KBytes, ptr %t53, i64 0, i32 0
  %t55 = load i64, ptr %t54
  %t56 = extractvalue %KValue %x3, 1
  %t57 = icmp sge i64 %t56, 1
  %t58 = icmp sle i64 %t56, %t55
  %t59 = and i1 %t57, %t58
  br i1 %t59, label %L19, label %L17
L19:
  %t60 = getelementptr %KBytes, ptr %t53, i64 0, i32 1
  %t61 = load ptr, ptr %t60
  %t62 = add i64 %t56, -1
  %t63 = getelementptr i8, ptr %t61, i64 %t62
  %t64 = load i8, ptr %t63
  %t65 = zext i8 %t64 to i64
  %t66 = insertvalue %KValue { i64 0, i64 undef }, i64 %t65, 1
  br label %L18
L17:
  %t67 = call %KValue @k_b_at(%KValue %x0, %KValue %x3)
  br label %L18
L18:
  %t68 = phi %KValue [ %t66, %L19 ], [ %t67, %L17 ]
  %t69 = extractvalue %KValue %t46, 0
  %t70 = extractvalue %KValue %t68, 0
  %t71 = icmp eq i64 %t69, 0
  %t72 = icmp eq i64 %t70, 0
  %t73 = and i1 %t71, %t72
  br i1 %t73, label %L20, label %L21
L20:
  %t74 = extractvalue %KValue %t46, 1
  %t75 = extractvalue %KValue %t68, 1
  %t76 = icmp slt i64 %t74, %t75
  %t77 = select i1 %t76, %KValue { i64 2, i64 0 }, %KValue { i64 3, i64 0 }
  br label %L22
L21:
  %t78 = call %KValue @k_cmp(%KValue %t46, %KValue %t68, i64 2)
  br label %L22
L22:
  %t79 = phi %KValue [ %t77, %L20 ], [ %t78, %L21 ]
  %t80 = extractvalue %KValue %t79, 0
  %t81 = icmp ne i64 %t80, 5
  %t82 = icmp ne i64 %t80, 4
  %t83 = and i1 %t81, %t82
  br i1 %t83, label %L23, label %L24
L24:
  ret %KValue %t79
L23:
  %t84 = call i64 @k_truthy(%KValue %t79)
  %t85 = icmp ne i64 %t84, 0
  br i1 %t85, label %L25, label %L26
L25:
  ret %KValue %x3
L26:
  ret %KValue %x2
fail0:
  %t86 = extractvalue %KValue %x0, 0
  %t87 = icmp ne i64 %t86, 5
  %t88 = icmp ne i64 %t86, 4
  %t89 = and i1 %t87, %t88
  br i1 %t89, label %L28, label %L27
L27:
  %t90 = call %KValue @k_err_hop(%KValue %x0, ptr @s96)
  ret %KValue %t90
L28:
  %t91 = extractvalue %KValue %x1, 0
  %t92 = icmp ne i64 %t91, 5
  %t93 = icmp ne i64 %t91, 4
  %t94 = and i1 %t92, %t93
  br i1 %t94, label %L30, label %L29
L29:
  %t95 = call %KValue @k_err_hop(%KValue %x1, ptr @s96)
  ret %KValue %t95
L30:
  %t96 = extractvalue %KValue %x2, 0
  %t97 = icmp ne i64 %t96, 5
  %t98 = icmp ne i64 %t96, 4
  %t99 = and i1 %t97, %t98
  br i1 %t99, label %L32, label %L31
L31:
  %t100 = call %KValue @k_err_hop(%KValue %x2, ptr @s96)
  ret %KValue %t100
L32:
  %t101 = extractvalue %KValue %x3, 0
  %t102 = icmp ne i64 %t101, 5
  %t103 = icmp ne i64 %t101, 4
  %t104 = and i1 %t102, %t103
  br i1 %t104, label %L34, label %L33
L33:
  %t105 = call %KValue @k_err_hop(%KValue %x3, ptr @s96)
  ret %KValue %t105
L34:
  call void @k_die(ptr @s97)
  unreachable
}

define tailcc %KValue @d__margin_or_high_3(%KValue %x0, %KValue %x1, %KValue %x2) {
entry:
  %t1 = extractvalue %KValue %x1, 0
  %t2 = extractvalue %KValue %x2, 0
  %t3 = icmp eq i64 %t1, 0
  %t4 = icmp eq i64 %t2, 0
  %t5 = and i1 %t3, %t4
  br i1 %t5, label %L1, label %L2
L1:
  %t6 = extractvalue %KValue %x1, 1
  %t7 = extractvalue %KValue %x2, 1
  %t8 = icmp eq i64 %t6, %t7
  %t9 = select i1 %t8, %KValue { i64 2, i64 0 }, %KValue { i64 3, i64 0 }
  br label %L3
L2:
  %t10 = call %KValue @k_cmp(%KValue %x1, %KValue %x2, i64 0)
  br label %L3
L3:
  %t11 = phi %KValue [ %t9, %L1 ], [ %t10, %L2 ]
  %t12 = extractvalue %KValue %t11, 0
  %t13 = icmp ne i64 %t12, 5
  %t14 = icmp ne i64 %t12, 4
  %t15 = and i1 %t13, %t14
  br i1 %t15, label %L4, label %L5
L5:
  ret %KValue %t11
L4:
  %t16 = call i64 @k_truthy(%KValue %t11)
  %t17 = icmp ne i64 %t16, 0
  br i1 %t17, label %L6, label %L7
L6:
  %t18 = call tailcc %KValue @d_nvot_0()
  ret %KValue %t18
L7:
  %t19 = call tailcc %KValue @d__pair_3(%KValue %x0, %KValue %x1, %KValue %x2)
  %t20 = call tailcc %KValue @d__pair_3(%KValue %x0, %KValue %x2, %KValue %x1)
  %t21 = extractvalue %KValue %t19, 0
  %t22 = extractvalue %KValue %t20, 0
  %t23 = icmp eq i64 %t21, 0
  %t24 = icmp eq i64 %t22, 0
  %t25 = and i1 %t23, %t24
  br i1 %t25, label %L8, label %L9
L8:
  %t26 = extractvalue %KValue %t19, 1
  %t27 = extractvalue %KValue %t20, 1
  %t28 = call { i64, i1 } @llvm.ssub.with.overflow.i64(i64 %t26, i64 %t27)
  %t29 = extractvalue { i64, i1 } %t28, 0
  %t30 = extractvalue { i64, i1 } %t28, 1
  br i1 %t30, label %L9, label %L11
L11:
  %t31 = insertvalue %KValue { i64 0, i64 undef }, i64 %t29, 1
  br label %L10
L9:
  %t32 = call %KValue @k_sub(%KValue %t19, %KValue %t20)
  br label %L10
L10:
  %t33 = phi %KValue [ %t31, %L11 ], [ %t32, %L9 ]
  ret %KValue %t33
fail0:
  %t34 = extractvalue %KValue %x0, 0
  %t35 = icmp ne i64 %t34, 5
  %t36 = icmp ne i64 %t34, 4
  %t37 = and i1 %t35, %t36
  br i1 %t37, label %L13, label %L12
L12:
  %t38 = call %KValue @k_err_hop(%KValue %x0, ptr @s98)
  ret %KValue %t38
L13:
  %t39 = extractvalue %KValue %x1, 0
  %t40 = icmp ne i64 %t39, 5
  %t41 = icmp ne i64 %t39, 4
  %t42 = and i1 %t40, %t41
  br i1 %t42, label %L15, label %L14
L14:
  %t43 = call %KValue @k_err_hop(%KValue %x1, ptr @s98)
  ret %KValue %t43
L15:
  %t44 = extractvalue %KValue %x2, 0
  %t45 = icmp ne i64 %t44, 5
  %t46 = icmp ne i64 %t44, 4
  %t47 = and i1 %t45, %t46
  br i1 %t47, label %L17, label %L16
L16:
  %t48 = call %KValue @k_err_hop(%KValue %x2, ptr @s98)
  ret %KValue %t48
L17:
  call void @k_die(ptr @s99)
  unreachable
}

define tailcc %KValue @klam19(ptr %env, %KValue %a0, %KValue %a1) {
entry:
  %t1 = call %KValue @k_env_get(ptr %env, i64 0)
  %t2 = call %KValue @k_env_get(ptr %env, i64 1)
  %t3 = musttail call tailcc %KValue @d__keep_min_4(%KValue %t1, %KValue %t2, %KValue %a0, %KValue %a1)
  ret %KValue %t3
}

define %KValue @w_klam19(ptr %env, %KValue %a0, %KValue %a1) {
entry:
  %r = call tailcc %KValue @klam19(ptr %env, %KValue %a0, %KValue %a1)
  ret %KValue %r
}

define tailcc %KValue @d__min_alive_2(%KValue %x0, %KValue %x1) {
entry:
  %t1 = call tailcc %KValue @d_ncand_0()
  %t2 = extractvalue %KValue %t1, 1
  %t3 = call tailcc %KValue @d_range_1(i64 %t2)
  %t4 = alloca [2 x %KValue]
  %t5 = getelementptr [2 x %KValue], ptr %t4, i64 0, i64 0
  store %KValue %x0, ptr %t5
  %t6 = getelementptr [2 x %KValue], ptr %t4, i64 0, i64 1
  store %KValue %x1, ptr %t6
  %t7 = call %KValue @k_closure(ptr @w_klam19, i64 2, ptr %t4)
  %t8 = musttail call tailcc %KValue @d_fold_3(%KValue %t3, %KValue { i64 0, i64 0 }, %KValue %t7)
  ret %KValue %t8
fail0:
  %t9 = extractvalue %KValue %x0, 0
  %t10 = icmp ne i64 %t9, 5
  %t11 = icmp ne i64 %t9, 4
  %t12 = and i1 %t10, %t11
  br i1 %t12, label %L2, label %L1
L1:
  %t13 = call %KValue @k_err_hop(%KValue %x0, ptr @s100)
  ret %KValue %t13
L2:
  %t14 = extractvalue %KValue %x1, 0
  %t15 = icmp ne i64 %t14, 5
  %t16 = icmp ne i64 %t14, 4
  %t17 = and i1 %t15, %t16
  br i1 %t17, label %L4, label %L3
L3:
  %t18 = call %KValue @k_err_hop(%KValue %x1, ptr @s100)
  ret %KValue %t18
L4:
  call void @k_die(ptr @s101)
  unreachable
}

define tailcc %KValue @klam20(ptr %env, %KValue %a0) {
entry:
  %t1 = call %KValue @k_env_get(ptr %env, i64 0)
  %t2 = call %KValue @k_env_get(ptr %env, i64 1)
  %t3 = extractvalue %KValue %a0, 0
  %t4 = icmp eq i64 %t3, 13
  %t5 = extractvalue %KValue %t1, 0
  %t6 = icmp eq i64 %t5, 0
  %t7 = and i1 %t4, %t6
  br i1 %t7, label %L1, label %L2
L1:
  %t8 = extractvalue %KValue %a0, 1
  %t9 = inttoptr i64 %t8 to ptr
  %t10 = getelementptr %KBytes, ptr %t9, i64 0, i32 0
  %t11 = load i64, ptr %t10
  %t12 = extractvalue %KValue %t1, 1
  %t13 = icmp sge i64 %t12, 1
  %t14 = icmp sle i64 %t12, %t11
  %t15 = and i1 %t13, %t14
  br i1 %t15, label %L4, label %L2
L4:
  %t16 = getelementptr %KBytes, ptr %t9, i64 0, i32 1
  %t17 = load ptr, ptr %t16
  %t18 = add i64 %t12, -1
  %t19 = getelementptr i8, ptr %t17, i64 %t18
  %t20 = load i8, ptr %t19
  %t21 = zext i8 %t20 to i64
  %t22 = insertvalue %KValue { i64 0, i64 undef }, i64 %t21, 1
  br label %L3
L2:
  %t23 = call %KValue @k_b_at(%KValue %a0, %KValue %t1)
  br label %L3
L3:
  %t24 = phi %KValue [ %t22, %L4 ], [ %t23, %L2 ]
  %t25 = extractvalue %KValue %a0, 0
  %t26 = icmp eq i64 %t25, 13
  %t27 = extractvalue %KValue %t2, 0
  %t28 = icmp eq i64 %t27, 0
  %t29 = and i1 %t26, %t28
  br i1 %t29, label %L5, label %L6
L5:
  %t30 = extractvalue %KValue %a0, 1
  %t31 = inttoptr i64 %t30 to ptr
  %t32 = getelementptr %KBytes, ptr %t31, i64 0, i32 0
  %t33 = load i64, ptr %t32
  %t34 = extractvalue %KValue %t2, 1
  %t35 = icmp sge i64 %t34, 1
  %t36 = icmp sle i64 %t34, %t33
  %t37 = and i1 %t35, %t36
  br i1 %t37, label %L8, label %L6
L8:
  %t38 = getelementptr %KBytes, ptr %t31, i64 0, i32 1
  %t39 = load ptr, ptr %t38
  %t40 = add i64 %t34, -1
  %t41 = getelementptr i8, ptr %t39, i64 %t40
  %t42 = load i8, ptr %t41
  %t43 = zext i8 %t42 to i64
  %t44 = insertvalue %KValue { i64 0, i64 undef }, i64 %t43, 1
  br label %L7
L6:
  %t45 = call %KValue @k_b_at(%KValue %a0, %KValue %t2)
  br label %L7
L7:
  %t46 = phi %KValue [ %t44, %L8 ], [ %t45, %L6 ]
  %t47 = extractvalue %KValue %t24, 0
  %t48 = extractvalue %KValue %t46, 0
  %t49 = icmp eq i64 %t47, 0
  %t50 = icmp eq i64 %t48, 0
  %t51 = and i1 %t49, %t50
  br i1 %t51, label %L9, label %L10
L9:
  %t52 = extractvalue %KValue %t24, 1
  %t53 = extractvalue %KValue %t46, 1
  %t54 = icmp slt i64 %t52, %t53
  %t55 = select i1 %t54, %KValue { i64 2, i64 0 }, %KValue { i64 3, i64 0 }
  br label %L11
L10:
  %t56 = call %KValue @k_cmp(%KValue %t24, %KValue %t46, i64 2)
  br label %L11
L11:
  %t57 = phi %KValue [ %t55, %L9 ], [ %t56, %L10 ]
  %t58 = extractvalue %KValue %t57, 0
  %t59 = icmp ne i64 %t58, 5
  %t60 = icmp ne i64 %t58, 4
  %t61 = and i1 %t59, %t60
  br i1 %t61, label %L12, label %L13
L13:
  ret %KValue %t57
L12:
  %t62 = call i64 @k_truthy(%KValue %t57)
  %t63 = icmp ne i64 %t62, 0
  br i1 %t63, label %L14, label %L15
L14:
  ret %KValue { i64 0, i64 1 }
L15:
  ret %KValue { i64 0, i64 0 }
}

define %KValue @w_klam20(ptr %env, %KValue %a0) {
entry:
  %r = call tailcc %KValue @klam20(ptr %env, %KValue %a0)
  ret %KValue %r
}

define tailcc %KValue @d__pair_3(%KValue %x0, %KValue %x1, %KValue %x2) {
entry:
  %t1 = alloca [2 x %KValue]
  %t2 = getelementptr [2 x %KValue], ptr %t1, i64 0, i64 0
  store %KValue %x2, ptr %t2
  %t3 = getelementptr [2 x %KValue], ptr %t1, i64 0, i64 1
  store %KValue %x1, ptr %t3
  %t4 = call %KValue @k_closure(ptr @w_klam20, i64 2, ptr %t1)
  %t5 = call %KValue @k_b_map(%KValue %x0, %KValue %t4)
  %t6 = musttail call tailcc %KValue @d_total_1(%KValue %t5)
  ret %KValue %t6
fail0:
  %t7 = extractvalue %KValue %x0, 0
  %t8 = icmp ne i64 %t7, 5
  %t9 = icmp ne i64 %t7, 4
  %t10 = and i1 %t8, %t9
  br i1 %t10, label %L2, label %L1
L1:
  %t11 = call %KValue @k_err_hop(%KValue %x0, ptr @s102)
  ret %KValue %t11
L2:
  %t12 = extractvalue %KValue %x1, 0
  %t13 = icmp ne i64 %t12, 5
  %t14 = icmp ne i64 %t12, 4
  %t15 = and i1 %t13, %t14
  br i1 %t15, label %L4, label %L3
L3:
  %t16 = call %KValue @k_err_hop(%KValue %x1, ptr @s102)
  ret %KValue %t16
L4:
  %t17 = extractvalue %KValue %x2, 0
  %t18 = icmp ne i64 %t17, 5
  %t19 = icmp ne i64 %t17, 4
  %t20 = and i1 %t18, %t19
  br i1 %t20, label %L6, label %L5
L5:
  %t21 = call %KValue @k_err_hop(%KValue %x2, ptr @s102)
  ret %KValue %t21
L6:
  call void @k_die(ptr @s103)
  unreachable
}

define tailcc %KValue @klam21(ptr %env, %KValue %a0) {
entry:
  %t1 = call %KValue @k_env_get(ptr %env, i64 0)
  %t2 = call %KValue @k_env_get(ptr %env, i64 1)
  %t3 = call tailcc %KValue @d__score_ballot_2(%KValue %a0, %KValue %t1)
  %t4 = call tailcc %KValue @d__score_ballot_2(%KValue %a0, %KValue %t2)
  %t5 = extractvalue %KValue %t3, 0
  %t6 = extractvalue %KValue %t4, 0
  %t7 = icmp eq i64 %t5, 0
  %t8 = icmp eq i64 %t6, 0
  %t9 = and i1 %t7, %t8
  br i1 %t9, label %L1, label %L2
L1:
  %t10 = extractvalue %KValue %t3, 1
  %t11 = extractvalue %KValue %t4, 1
  %t12 = icmp slt i64 %t10, %t11
  %t13 = select i1 %t12, %KValue { i64 2, i64 0 }, %KValue { i64 3, i64 0 }
  br label %L3
L2:
  %t14 = call %KValue @k_cmp(%KValue %t3, %KValue %t4, i64 2)
  br label %L3
L3:
  %t15 = phi %KValue [ %t13, %L1 ], [ %t14, %L2 ]
  %t16 = extractvalue %KValue %t15, 0
  %t17 = icmp ne i64 %t16, 5
  %t18 = icmp ne i64 %t16, 4
  %t19 = and i1 %t17, %t18
  br i1 %t19, label %L4, label %L5
L5:
  ret %KValue %t15
L4:
  %t20 = call i64 @k_truthy(%KValue %t15)
  %t21 = icmp ne i64 %t20, 0
  br i1 %t21, label %L6, label %L7
L6:
  ret %KValue { i64 0, i64 1 }
L7:
  ret %KValue { i64 0, i64 0 }
}

define %KValue @w_klam21(ptr %env, %KValue %a0) {
entry:
  %r = call tailcc %KValue @klam21(ptr %env, %KValue %a0)
  ret %KValue %r
}

define tailcc %KValue @d__prefer_count_3(%KValue %x0, %KValue %x1, %KValue %x2) {
entry:
  %t1 = extractvalue %KValue %x1, 0
  %t2 = icmp ne i64 %t1, 5
  %t3 = icmp ne i64 %t1, 4
  %t4 = and i1 %t2, %t3
  br i1 %t4, label %L1, label %fail0
L1:
  %t5 = extractvalue %KValue %x2, 0
  %t6 = icmp ne i64 %t5, 5
  %t7 = icmp ne i64 %t5, 4
  %t8 = and i1 %t6, %t7
  br i1 %t8, label %L2, label %fail0
L2:
  %t9 = alloca [2 x %KValue]
  %t10 = getelementptr [2 x %KValue], ptr %t9, i64 0, i64 0
  store %KValue %x2, ptr %t10
  %t11 = getelementptr [2 x %KValue], ptr %t9, i64 0, i64 1
  store %KValue %x1, ptr %t11
  %t12 = call %KValue @k_closure(ptr @w_klam21, i64 2, ptr %t9)
  %t13 = call %KValue @k_b_map(%KValue %x0, %KValue %t12)
  %t14 = musttail call tailcc %KValue @d_total_1(%KValue %t13)
  ret %KValue %t14
fail0:
  %t15 = extractvalue %KValue %x0, 0
  %t16 = icmp ne i64 %t15, 5
  %t17 = icmp ne i64 %t15, 4
  %t18 = and i1 %t16, %t17
  br i1 %t18, label %L4, label %L3
L3:
  %t19 = call %KValue @k_err_hop(%KValue %x0, ptr @s104)
  ret %KValue %t19
L4:
  %t20 = extractvalue %KValue %x1, 0
  %t21 = icmp ne i64 %t20, 5
  %t22 = icmp ne i64 %t20, 4
  %t23 = and i1 %t21, %t22
  br i1 %t23, label %L6, label %L5
L5:
  %t24 = call %KValue @k_err_hop(%KValue %x1, ptr @s104)
  ret %KValue %t24
L6:
  %t25 = extractvalue %KValue %x2, 0
  %t26 = icmp ne i64 %t25, 5
  %t27 = icmp ne i64 %t25, 4
  %t28 = and i1 %t26, %t27
  br i1 %t28, label %L8, label %L7
L7:
  %t29 = call %KValue @k_err_hop(%KValue %x2, ptr @s104)
  ret %KValue %t29
L8:
  call void @k_die(ptr @s105)
  unreachable
}

define tailcc %KValue @klam22(ptr %env, %KValue %a0, %KValue %a1) {
entry:
  %t1 = call %KValue @k_env_get(ptr %env, i64 0)
  %t2 = call %KValue @k_env_get(ptr %env, i64 1)
  %t3 = musttail call tailcc %KValue @d__keep_top_4(%KValue %t1, %KValue %t2, %KValue %a0, %KValue %a1)
  ret %KValue %t3
}

define %KValue @w_klam22(ptr %env, %KValue %a0, %KValue %a1) {
entry:
  %r = call tailcc %KValue @klam22(ptr %env, %KValue %a0, %KValue %a1)
  ret %KValue %r
}

define tailcc %KValue @d__rank_first_2(%KValue %x0, %KValue %x1) {
entry:
  %t1 = call tailcc %KValue @d_ncand_0()
  %t2 = extractvalue %KValue %t1, 1
  %t3 = call tailcc %KValue @d_range_1(i64 %t2)
  %t4 = alloca [2 x %KValue]
  %t5 = getelementptr [2 x %KValue], ptr %t4, i64 0, i64 0
  store %KValue %x0, ptr %t5
  %t6 = getelementptr [2 x %KValue], ptr %t4, i64 0, i64 1
  store %KValue %x1, ptr %t6
  %t7 = call %KValue @k_closure(ptr @w_klam22, i64 2, ptr %t4)
  %t8 = musttail call tailcc %KValue @d_fold_3(%KValue %t3, %KValue { i64 0, i64 0 }, %KValue %t7)
  ret %KValue %t8
fail0:
  %t9 = extractvalue %KValue %x0, 0
  %t10 = icmp ne i64 %t9, 5
  %t11 = icmp ne i64 %t9, 4
  %t12 = and i1 %t10, %t11
  br i1 %t12, label %L2, label %L1
L1:
  %t13 = call %KValue @k_err_hop(%KValue %x0, ptr @s106)
  ret %KValue %t13
L2:
  %t14 = extractvalue %KValue %x1, 0
  %t15 = icmp ne i64 %t14, 5
  %t16 = icmp ne i64 %t14, 4
  %t17 = and i1 %t15, %t16
  br i1 %t17, label %L4, label %L3
L3:
  %t18 = call %KValue @k_err_hop(%KValue %x1, ptr @s106)
  ret %KValue %t18
L4:
  call void @k_die(ptr @s107)
  unreachable
}

define tailcc %KValue @d__score_ballot_2(%KValue %x0, %KValue %x1) {
entry:
  %t1 = call tailcc %KValue @d_minimum_1(%KValue %x0)
  %t2 = call tailcc %KValue @d_maximum_1(%KValue %x0)
  %t3 = call %KValue @k_float(double 0x4014000000000000)
  %t4 = extractvalue %KValue %x0, 0
  %t5 = icmp eq i64 %t4, 13
  %t6 = extractvalue %KValue %x1, 0
  %t7 = icmp eq i64 %t6, 0
  %t8 = and i1 %t5, %t7
  br i1 %t8, label %L1, label %L2
L1:
  %t9 = extractvalue %KValue %x0, 1
  %t10 = inttoptr i64 %t9 to ptr
  %t11 = getelementptr %KBytes, ptr %t10, i64 0, i32 0
  %t12 = load i64, ptr %t11
  %t13 = extractvalue %KValue %x1, 1
  %t14 = icmp sge i64 %t13, 1
  %t15 = icmp sle i64 %t13, %t12
  %t16 = and i1 %t14, %t15
  br i1 %t16, label %L4, label %L2
L4:
  %t17 = getelementptr %KBytes, ptr %t10, i64 0, i32 1
  %t18 = load ptr, ptr %t17
  %t19 = add i64 %t13, -1
  %t20 = getelementptr i8, ptr %t18, i64 %t19
  %t21 = load i8, ptr %t20
  %t22 = zext i8 %t21 to i64
  %t23 = insertvalue %KValue { i64 0, i64 undef }, i64 %t22, 1
  br label %L3
L2:
  %t24 = call %KValue @k_b_at(%KValue %x0, %KValue %x1)
  br label %L3
L3:
  %t25 = phi %KValue [ %t23, %L4 ], [ %t24, %L2 ]
  %t26 = extractvalue %KValue %t25, 0
  %t27 = extractvalue %KValue %t1, 0
  %t28 = icmp eq i64 %t26, 0
  %t29 = icmp eq i64 %t27, 0
  %t30 = and i1 %t28, %t29
  br i1 %t30, label %L5, label %L6
L5:
  %t31 = extractvalue %KValue %t25, 1
  %t32 = extractvalue %KValue %t1, 1
  %t33 = call { i64, i1 } @llvm.ssub.with.overflow.i64(i64 %t31, i64 %t32)
  %t34 = extractvalue { i64, i1 } %t33, 0
  %t35 = extractvalue { i64, i1 } %t33, 1
  br i1 %t35, label %L6, label %L8
L8:
  %t36 = insertvalue %KValue { i64 0, i64 undef }, i64 %t34, 1
  br label %L7
L6:
  %t37 = call %KValue @k_sub(%KValue %t25, %KValue %t1)
  br label %L7
L7:
  %t38 = phi %KValue [ %t36, %L8 ], [ %t37, %L6 ]
  %t39 = extractvalue %KValue %t3, 0
  %t40 = extractvalue %KValue %t38, 0
  %t41 = icmp eq i64 %t39, 0
  %t42 = icmp eq i64 %t40, 0
  %t43 = and i1 %t41, %t42
  br i1 %t43, label %L9, label %L10
L9:
  %t44 = extractvalue %KValue %t3, 1
  %t45 = extractvalue %KValue %t38, 1
  %t46 = call { i64, i1 } @llvm.smul.with.overflow.i64(i64 %t44, i64 %t45)
  %t47 = extractvalue { i64, i1 } %t46, 0
  %t48 = extractvalue { i64, i1 } %t46, 1
  br i1 %t48, label %L10, label %L12
L12:
  %t49 = insertvalue %KValue { i64 0, i64 undef }, i64 %t47, 1
  br label %L11
L10:
  %t50 = call %KValue @k_mul(%KValue %t3, %KValue %t38)
  br label %L11
L11:
  %t51 = phi %KValue [ %t49, %L12 ], [ %t50, %L10 ]
  %t52 = extractvalue %KValue %t2, 0
  %t53 = extractvalue %KValue %t1, 0
  %t54 = icmp eq i64 %t52, 0
  %t55 = icmp eq i64 %t53, 0
  %t56 = and i1 %t54, %t55
  br i1 %t56, label %L13, label %L14
L13:
  %t57 = extractvalue %KValue %t2, 1
  %t58 = extractvalue %KValue %t1, 1
  %t59 = call { i64, i1 } @llvm.ssub.with.overflow.i64(i64 %t57, i64 %t58)
  %t60 = extractvalue { i64, i1 } %t59, 0
  %t61 = extractvalue { i64, i1 } %t59, 1
  br i1 %t61, label %L14, label %L16
L16:
  %t62 = insertvalue %KValue { i64 0, i64 undef }, i64 %t60, 1
  br label %L15
L14:
  %t63 = call %KValue @k_sub(%KValue %t2, %KValue %t1)
  br label %L15
L15:
  %t64 = phi %KValue [ %t62, %L16 ], [ %t63, %L14 ]
  %t65 = call %KValue @k_div(%KValue %t51, %KValue %t64, ptr @s109)
  %t66 = call %KValue @k_b_round(%KValue %t65)
  ret %KValue %t66
fail0:
  %t67 = extractvalue %KValue %x0, 0
  %t68 = icmp ne i64 %t67, 5
  %t69 = icmp ne i64 %t67, 4
  %t70 = and i1 %t68, %t69
  br i1 %t70, label %L18, label %L17
L17:
  %t71 = call %KValue @k_err_hop(%KValue %x0, ptr @s108)
  ret %KValue %t71
L18:
  %t72 = extractvalue %KValue %x1, 0
  %t73 = icmp ne i64 %t72, 5
  %t74 = icmp ne i64 %t72, 4
  %t75 = and i1 %t73, %t74
  br i1 %t75, label %L20, label %L19
L19:
  %t76 = call %KValue @k_err_hop(%KValue %x1, ptr @s108)
  ret %KValue %t76
L20:
  call void @k_die(ptr @s110)
  unreachable
}

define tailcc %KValue @klam23(ptr %env, %KValue %a0) {
entry:
  %t1 = call %KValue @k_env_get(ptr %env, i64 0)
  %t2 = musttail call tailcc %KValue @d__score_ballot_2(%KValue %a0, %KValue %t1)
  ret %KValue %t2
}

define %KValue @w_klam23(ptr %env, %KValue %a0) {
entry:
  %r = call tailcc %KValue @klam23(ptr %env, %KValue %a0)
  ret %KValue %r
}

define tailcc %KValue @d__score_col_2(%KValue %x0, %KValue %x1) {
entry:
  %t1 = alloca [1 x %KValue]
  %t2 = getelementptr [1 x %KValue], ptr %t1, i64 0, i64 0
  store %KValue %x1, ptr %t2
  %t3 = call %KValue @k_closure(ptr @w_klam23, i64 1, ptr %t1)
  %t4 = call %KValue @k_b_map(%KValue %x0, %KValue %t3)
  %t5 = musttail call tailcc %KValue @d_total_1(%KValue %t4)
  ret %KValue %t5
fail0:
  %t6 = extractvalue %KValue %x0, 0
  %t7 = icmp ne i64 %t6, 5
  %t8 = icmp ne i64 %t6, 4
  %t9 = and i1 %t7, %t8
  br i1 %t9, label %L2, label %L1
L1:
  %t10 = call %KValue @k_err_hop(%KValue %x0, ptr @s111)
  ret %KValue %t10
L2:
  %t11 = extractvalue %KValue %x1, 0
  %t12 = icmp ne i64 %t11, 5
  %t13 = icmp ne i64 %t11, 4
  %t14 = and i1 %t12, %t13
  br i1 %t14, label %L4, label %L3
L3:
  %t15 = call %KValue @k_err_hop(%KValue %x1, ptr @s111)
  ret %KValue %t15
L4:
  call void @k_die(ptr @s112)
  unreachable
}

define tailcc %KValue @klam24(ptr %env, %KValue %a0) {
entry:
  %t1 = call %KValue @k_env_get(ptr %env, i64 0)
  %t2 = call %KValue @k_env_get(ptr %env, i64 1)
  %t3 = musttail call tailcc %KValue @d__margin_or_high_3(%KValue %t1, %KValue %t2, %KValue %a0)
  ret %KValue %t3
}

define %KValue @w_klam24(ptr %env, %KValue %a0) {
entry:
  %r = call tailcc %KValue @klam24(ptr %env, %KValue %a0)
  ret %KValue %r
}

define tailcc %KValue @d__worst_margin_2(%KValue %x0, %KValue %x1) {
entry:
  %t1 = call tailcc %KValue @d_ncand_0()
  %t2 = extractvalue %KValue %t1, 1
  %t3 = call tailcc %KValue @d_range_1(i64 %t2)
  %t4 = alloca [2 x %KValue]
  %t5 = getelementptr [2 x %KValue], ptr %t4, i64 0, i64 0
  store %KValue %x0, ptr %t5
  %t6 = getelementptr [2 x %KValue], ptr %t4, i64 0, i64 1
  store %KValue %x1, ptr %t6
  %t7 = call %KValue @k_closure(ptr @w_klam24, i64 2, ptr %t4)
  %t8 = call %KValue @k_b_map(%KValue %t3, %KValue %t7)
  %t9 = musttail call tailcc %KValue @d_minimum_1(%KValue %t8)
  ret %KValue %t9
fail0:
  %t10 = extractvalue %KValue %x0, 0
  %t11 = icmp ne i64 %t10, 5
  %t12 = icmp ne i64 %t10, 4
  %t13 = and i1 %t11, %t12
  br i1 %t13, label %L2, label %L1
L1:
  %t14 = call %KValue @k_err_hop(%KValue %x0, ptr @s113)
  ret %KValue %t14
L2:
  %t15 = extractvalue %KValue %x1, 0
  %t16 = icmp ne i64 %t15, 5
  %t17 = icmp ne i64 %t15, 4
  %t18 = and i1 %t16, %t17
  br i1 %t18, label %L4, label %L3
L3:
  %t19 = call %KValue @k_err_hop(%KValue %x1, ptr @s113)
  ret %KValue %t19
L4:
  call void @k_die(ptr @s114)
  unreachable
}

define tailcc %KValue @klam25(ptr %env, %KValue %a0) {
entry:
  %t1 = call %KValue @k_env_get(ptr %env, i64 0)
  %t2 = musttail call tailcc %KValue @d__approval_col_2(%KValue %t1, %KValue %a0)
  ret %KValue %t2
}

define %KValue @w_klam25(ptr %env, %KValue %a0) {
entry:
  %r = call tailcc %KValue @klam25(ptr %env, %KValue %a0)
  ret %KValue %r
}

define tailcc %KValue @d_approval_winner_1(%KValue %x0) {
entry:
  %t1 = call tailcc %KValue @d_ncand_0()
  %t2 = extractvalue %KValue %t1, 1
  %t3 = call tailcc %KValue @d_range_1(i64 %t2)
  %t4 = alloca [1 x %KValue]
  %t5 = getelementptr [1 x %KValue], ptr %t4, i64 0, i64 0
  store %KValue %x0, ptr %t5
  %t6 = call %KValue @k_closure(ptr @w_klam25, i64 1, ptr %t4)
  %t7 = call %KValue @k_b_map(%KValue %t3, %KValue %t6)
  %t8 = musttail call tailcc %KValue @d_argmax_1(%KValue %t7)
  ret %KValue %t8
fail0:
  %t9 = extractvalue %KValue %x0, 0
  %t10 = icmp ne i64 %t9, 5
  %t11 = icmp ne i64 %t9, 4
  %t12 = and i1 %t10, %t11
  br i1 %t12, label %L2, label %L1
L1:
  %t13 = call %KValue @k_err_hop(%KValue %x0, ptr @s115)
  ret %KValue %t13
L2:
  call void @k_die(ptr @s116)
  unreachable
}

define tailcc %KValue @d_irv_winner_1(%KValue %x0) {
entry:
  %t1 = alloca [1 x %KValue]
  %t2 = call %KValue @k_list_lit(i64 0, ptr %t1)
  %t3 = musttail call tailcc %KValue @d__irv_go_2(%KValue %x0, %KValue %t2)
  ret %KValue %t3
fail0:
  %t4 = extractvalue %KValue %x0, 0
  %t5 = icmp ne i64 %t4, 5
  %t6 = icmp ne i64 %t4, 4
  %t7 = and i1 %t5, %t6
  br i1 %t7, label %L2, label %L1
L1:
  %t8 = call %KValue @k_err_hop(%KValue %x0, ptr @s117)
  ret %KValue %t8
L2:
  call void @k_die(ptr @s118)
  unreachable
}

define tailcc %KValue @klam26(ptr %env, %KValue %a0) {
entry:
  %t1 = call %KValue @k_env_get(ptr %env, i64 0)
  %t2 = musttail call tailcc %KValue @d__worst_margin_2(%KValue %t1, %KValue %a0)
  ret %KValue %t2
}

define %KValue @w_klam26(ptr %env, %KValue %a0) {
entry:
  %r = call tailcc %KValue @klam26(ptr %env, %KValue %a0)
  ret %KValue %r
}

define tailcc %KValue @d_minimax_winner_1(%KValue %x0) {
entry:
  %t1 = call tailcc %KValue @d_ncand_0()
  %t2 = extractvalue %KValue %t1, 1
  %t3 = call tailcc %KValue @d_range_1(i64 %t2)
  %t4 = alloca [1 x %KValue]
  %t5 = getelementptr [1 x %KValue], ptr %t4, i64 0, i64 0
  store %KValue %x0, ptr %t5
  %t6 = call %KValue @k_closure(ptr @w_klam26, i64 1, ptr %t4)
  %t7 = call %KValue @k_b_map(%KValue %t3, %KValue %t6)
  %t8 = musttail call tailcc %KValue @d_argmax_1(%KValue %t7)
  ret %KValue %t8
fail0:
  %t9 = extractvalue %KValue %x0, 0
  %t10 = icmp ne i64 %t9, 5
  %t11 = icmp ne i64 %t9, 4
  %t12 = and i1 %t10, %t11
  br i1 %t12, label %L2, label %L1
L1:
  %t13 = call %KValue @k_err_hop(%KValue %x0, ptr @s119)
  ret %KValue %t13
L2:
  call void @k_die(ptr @s120)
  unreachable
}

define tailcc %KValue @klam28(ptr %env, %KValue %a0) {
entry:
  %t1 = musttail call tailcc %KValue @d_argmax_1(%KValue %a0)
  ret %KValue %t1
}

define %KValue @w_klam28(ptr %env, %KValue %a0) {
entry:
  %r = call tailcc %KValue @klam28(ptr %env, %KValue %a0)
  ret %KValue %r
}

define tailcc %KValue @klam27(ptr %env, %KValue %a0) {
entry:
  %t1 = call %KValue @k_env_get(ptr %env, i64 0)
  %t2 = alloca [1 x %KValue]
  %t3 = call %KValue @k_closure(ptr @w_klam28, i64 0, ptr %t2)
  %t4 = call %KValue @k_b_map(%KValue %t1, %KValue %t3)
  %t5 = musttail call tailcc %KValue @d_count_2(%KValue %t4, %KValue %a0)
  ret %KValue %t5
}

define %KValue @w_klam27(ptr %env, %KValue %a0) {
entry:
  %r = call tailcc %KValue @klam27(ptr %env, %KValue %a0)
  ret %KValue %r
}

define tailcc %KValue @d_plurality_winner_1(%KValue %x0) {
entry:
  %t1 = call tailcc %KValue @d_ncand_0()
  %t2 = extractvalue %KValue %t1, 1
  %t3 = call tailcc %KValue @d_range_1(i64 %t2)
  %t4 = alloca [1 x %KValue]
  %t5 = getelementptr [1 x %KValue], ptr %t4, i64 0, i64 0
  store %KValue %x0, ptr %t5
  %t6 = call %KValue @k_closure(ptr @w_klam27, i64 1, ptr %t4)
  %t7 = call %KValue @k_b_map(%KValue %t3, %KValue %t6)
  %t8 = musttail call tailcc %KValue @d_argmax_1(%KValue %t7)
  ret %KValue %t8
fail0:
  %t9 = extractvalue %KValue %x0, 0
  %t10 = icmp ne i64 %t9, 5
  %t11 = icmp ne i64 %t9, 4
  %t12 = and i1 %t10, %t11
  br i1 %t12, label %L2, label %L1
L1:
  %t13 = call %KValue @k_err_hop(%KValue %x0, ptr @s121)
  ret %KValue %t13
L2:
  call void @k_die(ptr @s122)
  unreachable
}

define tailcc %KValue @klam29(ptr %env, %KValue %a0) {
entry:
  %t1 = call %KValue @k_env_get(ptr %env, i64 0)
  %t2 = musttail call tailcc %KValue @d__score_col_2(%KValue %t1, %KValue %a0)
  ret %KValue %t2
}

define %KValue @w_klam29(ptr %env, %KValue %a0) {
entry:
  %r = call tailcc %KValue @klam29(ptr %env, %KValue %a0)
  ret %KValue %r
}

define tailcc %KValue @d_score_winner_1(%KValue %x0) {
entry:
  %t1 = call tailcc %KValue @d_ncand_0()
  %t2 = extractvalue %KValue %t1, 1
  %t3 = call tailcc %KValue @d_range_1(i64 %t2)
  %t4 = alloca [1 x %KValue]
  %t5 = getelementptr [1 x %KValue], ptr %t4, i64 0, i64 0
  store %KValue %x0, ptr %t5
  %t6 = call %KValue @k_closure(ptr @w_klam29, i64 1, ptr %t4)
  %t7 = call %KValue @k_b_map(%KValue %t3, %KValue %t6)
  %t8 = musttail call tailcc %KValue @d_argmax_1(%KValue %t7)
  ret %KValue %t8
fail0:
  %t9 = extractvalue %KValue %x0, 0
  %t10 = icmp ne i64 %t9, 5
  %t11 = icmp ne i64 %t9, 4
  %t12 = and i1 %t10, %t11
  br i1 %t12, label %L2, label %L1
L1:
  %t13 = call %KValue @k_err_hop(%KValue %x0, ptr @s123)
  ret %KValue %t13
L2:
  call void @k_die(ptr @s124)
  unreachable
}

define tailcc %KValue @klam30(ptr %env, %KValue %a0) {
entry:
  %t1 = call %KValue @k_env_get(ptr %env, i64 0)
  %t2 = musttail call tailcc %KValue @d__score_col_2(%KValue %t1, %KValue %a0)
  ret %KValue %t2
}

define %KValue @w_klam30(ptr %env, %KValue %a0) {
entry:
  %r = call tailcc %KValue @klam30(ptr %env, %KValue %a0)
  ret %KValue %r
}

define tailcc %KValue @d_star_winner_1(%KValue %x0) {
entry:
  %t1 = call tailcc %KValue @d_ncand_0()
  %t2 = extractvalue %KValue %t1, 1
  %t3 = call tailcc %KValue @d_range_1(i64 %t2)
  %t4 = alloca [1 x %KValue]
  %t5 = getelementptr [1 x %KValue], ptr %t4, i64 0, i64 0
  store %KValue %x0, ptr %t5
  %t6 = call %KValue @k_closure(ptr @w_klam30, i64 1, ptr %t4)
  %t7 = call %KValue @k_b_map(%KValue %t3, %KValue %t6)
  %t8 = call tailcc %KValue @d_argmax_1(%KValue %t7)
  %t9 = call tailcc %KValue @d__argmax_except_2(%KValue %t7, %KValue %t8)
  %t10 = call tailcc %KValue @d__prefer_count_3(%KValue %x0, %KValue %t8, %KValue %t9)
  %t11 = call tailcc %KValue @d__prefer_count_3(%KValue %x0, %KValue %t9, %KValue %t8)
  %t12 = extractvalue %KValue %t11, 0
  %t13 = extractvalue %KValue %t10, 0
  %t14 = icmp eq i64 %t12, 0
  %t15 = icmp eq i64 %t13, 0
  %t16 = and i1 %t14, %t15
  br i1 %t16, label %L1, label %L2
L1:
  %t17 = extractvalue %KValue %t11, 1
  %t18 = extractvalue %KValue %t10, 1
  %t19 = icmp slt i64 %t17, %t18
  %t20 = select i1 %t19, %KValue { i64 2, i64 0 }, %KValue { i64 3, i64 0 }
  br label %L3
L2:
  %t21 = call %KValue @k_cmp(%KValue %t11, %KValue %t10, i64 2)
  br label %L3
L3:
  %t22 = phi %KValue [ %t20, %L1 ], [ %t21, %L2 ]
  %t23 = extractvalue %KValue %t22, 0
  %t24 = icmp ne i64 %t23, 5
  %t25 = icmp ne i64 %t23, 4
  %t26 = and i1 %t24, %t25
  br i1 %t26, label %L4, label %L5
L5:
  ret %KValue %t22
L4:
  %t27 = call i64 @k_truthy(%KValue %t22)
  %t28 = icmp ne i64 %t27, 0
  br i1 %t28, label %L6, label %L7
L6:
  ret %KValue %t8
L7:
  %t29 = extractvalue %KValue %t10, 0
  %t30 = extractvalue %KValue %t11, 0
  %t31 = icmp eq i64 %t29, 0
  %t32 = icmp eq i64 %t30, 0
  %t33 = and i1 %t31, %t32
  br i1 %t33, label %L8, label %L9
L8:
  %t34 = extractvalue %KValue %t10, 1
  %t35 = extractvalue %KValue %t11, 1
  %t36 = icmp slt i64 %t34, %t35
  %t37 = select i1 %t36, %KValue { i64 2, i64 0 }, %KValue { i64 3, i64 0 }
  br label %L10
L9:
  %t38 = call %KValue @k_cmp(%KValue %t10, %KValue %t11, i64 2)
  br label %L10
L10:
  %t39 = phi %KValue [ %t37, %L8 ], [ %t38, %L9 ]
  %t40 = extractvalue %KValue %t39, 0
  %t41 = icmp ne i64 %t40, 5
  %t42 = icmp ne i64 %t40, 4
  %t43 = and i1 %t41, %t42
  br i1 %t43, label %L11, label %L12
L12:
  ret %KValue %t39
L11:
  %t44 = call i64 @k_truthy(%KValue %t39)
  %t45 = icmp ne i64 %t44, 0
  br i1 %t45, label %L13, label %L14
L13:
  ret %KValue %t9
L14:
  ret %KValue %t8
fail0:
  %t46 = extractvalue %KValue %x0, 0
  %t47 = icmp ne i64 %t46, 5
  %t48 = icmp ne i64 %t46, 4
  %t49 = and i1 %t47, %t48
  br i1 %t49, label %L16, label %L15
L15:
  %t50 = call %KValue @k_err_hop(%KValue %x0, ptr @s125)
  ret %KValue %t50
L16:
  call void @k_die(ptr @s126)
  unreachable
}

define %KValue @k_user_main() {
entry:
  %r = call tailcc %KValue @d_main_0()
  ret %KValue %r
}
