(* ---- prelude comune (generato da gen_tests.py) ---- *)
let fails = ref 0
let fail s = incr fails; print_string "FAIL "; print_string s; print_newline ()
let check s ok = if not ok then fail s
let checkn s n ok = if not ok then fail (s ^ string_of_int n)
let check2 s m n ok =
  if not ok then fail (s ^ string_of_int m ^ "," ^ string_of_int n)
let run s f = try f () with _ -> fail (s ^ " EXN")
let raises_inv s f =
  try ignore (f ()); fail (s ^ " NOEXN")
  with Invalid_argument _ -> () | _ -> fail (s ^ " BADEXN")
let raises_dz s f =
  try ignore (f ()); fail (s ^ " NOEXN")
  with Division_by_zero -> () | _ -> fail (s ^ " BADEXN")
let finish t =
  print_string t;
  if !fails = 0 then print_string " OK" else print_string " FAIL";
  print_newline ()
(* ---- fine prelude ---- *)
let vals = [| 0L; 1L; (-1L); 2L; 255L; 65536L; 2147483647L; 2147483648L; 4294967296L; 9223372036854775807L; (-9223372036854775808L); 1311768467463790320L; (-6148914691236517206L) |]
let row f a =
  let c = ref 0 in
  for j = 0 to 12 do
    let r = f a vals.(j) in
    c := (!c * 7 + Int64.to_int (Int64.logand r 16383L) * 1 + Int64.to_int (Int64.logand (Int64.shift_right_logical r 14) 16383L) * 3 + Int64.to_int (Int64.logand (Int64.shift_right_logical r 28) 16383L) * 11 + Int64.to_int (Int64.logand (Int64.shift_right_logical r 42) 16383L) * 5 + Int64.to_int (Int64.logand (Int64.shift_right_logical r 56) 16383L) * 13) land 16383
  done;
  !c
let chk name f e =
  for i = 0 to 12 do
    if row f vals.(i) <> e.(i) then fail (name ^ " row " ^ string_of_int i)
  done
let e_add = [| 7684; 2755; 13470; 2452; 7713; 9779; 13642; 13804; 3524; 3102; 9604; 12964; 12193 |]
let e_sub = [| 3953; 13858; 9739; 723; 8832; 11067; 15461; 8133; 13167; 7819; 14321; 3880; 3019 |]
let e_mul = [| 0; 7684; 3953; 8326; 3202; 10179; 3258; 10720; 3109; 3569; 16000; 10347; 9838 |]
let e_and = [| 0; 6961; 7684; 15300; 15813; 10688; 14179; 3304; 9264; 14980; 9088; 13973; 14784 |]
let e_or = [| 7684; 420; 1039; 8162; 12910; 9744; 4154; 10484; 10628; 6415; 2308; 3486; 15438 |]
let e_xor = [| 7684; 9843; 9739; 9246; 13481; 15440; 6359; 7180; 1364; 7819; 9604; 5897; 654 |]
let e_div = [| 0; 134; 13946; 8563; 15924; 10205; 16070; 11098; 16072; 1806; 15735; 9939; 1465 |]
let e_rem = [| 0; 7976; 984; 16322; 13863; 6317; 2070; 12009; 8419; 4087; 4358; 750; 15619 |]
let e_shl = [| 0; 3168; 2648; 1728; 9632; 16248; 4078; 9544; 2704; 15320; 3712; 13947; 3632 |]
let e_shr = [| 0; 9297; 1039; 9529; 11793; 7467; 4901; 5606; 11212; 2075; 15348; 12069; 14101 |]
let e_shru = [| 0; 9297; 5375; 9529; 11793; 7467; 4901; 5606; 11212; 2075; 3300; 12069; 2053 |]
let e_neg = [| 0; 1039; 16081; 1342; 12465; 3463; 6471; 6774; 670; 3409; 3712; 7345; 10966 |]
let e_lognot = [| 1039; 1342; 0; 1645; 12768; 4675; 6774; 11319; 5215; 3712; 13711; 7648; 11269 |]
let e_cmp = [| 14070; 910; 7364; 11596; 11892; 2572; 15284; 716; 3316; 15738; 3424; 15420; 178 |]
let e_succ = [| 16081; 15778; 0; 15475; 4352; 12445; 6104; 5801; 11905; 3712; 3409; 9472; 5851 |]
let e_pred = [| 1039; 0; 1342; 16081; 4958; 13960; 10952; 10649; 369; 14014; 13711; 10078; 6457 |]
let basic () =
  check "i64 add" (Int64.to_int (Int64.add 100L 200L) = 300);
  check "i64 sub" (Int64.to_int (Int64.sub 100L 300L) = -200);
  check "i64 mul" (Int64.to_int (Int64.mul 100L 100L) = 10000);
  check "i64 div" (Int64.to_int (Int64.div 100L 7L) = 14);
  check "i64 rem" (Int64.to_int (Int64.rem 100L 7L) = 2);
  check "i64 div neg" (Int64.to_int (Int64.div (-100L) 7L) = -14);
  check "i64 rem neg" (Int64.to_int (Int64.rem (-100L) 7L) = -2);
  check "i64 shl" (Int64.to_int (Int64.shift_left 1L 10) = 1024);
  check "i64 shru 60" (Int64.to_int (Int64.shift_right_logical (-1L) 60) = 15);
  check "i64 shr neg" (Int64.to_int (Int64.shift_right (-4096L) 4) = -256);
  check "i64 shl 63" (Int64.compare (Int64.shift_left 1L 63) (-9223372036854775808L) = 0);
  check "i64 shl 32" (Int64.compare (Int64.shift_left 1L 32) 4294967296L = 0);
  check "i64 min/-1" (Int64.compare (Int64.div (-9223372036854775808L) (-1L)) (-9223372036854775808L) = 0);
  check "i64 min rem -1" (Int64.to_int (Int64.rem (-9223372036854775808L) (-1L)) = 0);
  raises_dz "i64 div0" (fun () -> Int64.div 5L (Int64.sub 3L 3L));
  raises_dz "i64 rem0" (fun () -> Int64.rem 5L (Int64.sub 3L 3L));
  check "i64 max+1" (Int64.compare (Int64.add 9223372036854775807L 1L) (-9223372036854775808L) = 0);
  check "i64 mul 2^32" (Int64.compare (Int64.mul 4294967296L 4294967296L) 0L = 0);
  check "i64 mul 2^31 2^31" (Int64.compare (Int64.mul 2147483648L 2147483648L) 4611686018427387904L = 0)
let conv () =
  let l = [0; 1; -1; 2; 127; 128; 255; 256; 16383; -16384; -16383; 8192; -8193] in
  List.iter (fun n ->
    checkn "i64 of_int/to_int " n (Int64.to_int (Int64.of_int n) = n)) l;
  check "i64 of_int -1 hi" (Int64.to_int (Int64.shift_right_logical (Int64.of_int (-1)) 60) = 15);
  check "i64 of_int -1 eq" (Int64.compare (Int64.of_int (-1)) (-1L) = 0);
  check "i64 cmp 0 min" (Int64.compare 0L (-9223372036854775808L) > 0 && Int64.compare (-9223372036854775808L) 0L < 0);
  check "i64 cmp top+128" (Int64.compare 9151314442816847872L (-72057594037927936L) > 0);
  check "i64 of_int32 -1" (Int64.to_int (Int64.shift_right_logical (Int64.of_int32 (-1l)) 60) = 15);
  check "i64 of_int32 max" (Int64.compare (Int64.of_int32 2147483647l) 2147483647L = 0);
  check "i64 of_int32 min" (Int64.compare (Int64.of_int32 (-2147483648l)) (-2147483648L) = 0);
  check "i64 to_int32 trunc" (Int32.to_int (Int64.to_int32 4294967297L) = 1);
  check "i64 to_int32 neg" (Int32.compare (Int64.to_int32 (-1L)) (-1l) = 0);
  check "i64 to_int32 big" (Int32.compare (Int64.to_int32 8589934591L) (-1l) = 0)
let tostr () =
  check "i64 to_string 0" (String.equal (Int64.to_string 0L) "0");
  check "i64 to_string 1" (String.equal (Int64.to_string 1L) "1");
  check "i64 to_string -1" (String.equal (Int64.to_string (-1L)) "-1");
  check "i64 to_string 12345" (String.equal (Int64.to_string 12345L) "12345");
  check "i64 to_string -12345" (String.equal (Int64.to_string (-12345L)) "-12345");
  check "i64 to_string 4294967296" (String.equal (Int64.to_string 4294967296L) "4294967296");
  check "i64 to_string 1000000007" (String.equal (Int64.to_string 1000000007L) "1000000007");
  check "i64 to_string 9223372036854775807" (String.equal (Int64.to_string 9223372036854775807L) "9223372036854775807");
  check "i64 to_string -9223372036854775808" (String.equal (Int64.to_string (-9223372036854775808L)) "-9223372036854775808");
  ()
let ofloat () =
  check "i64 of_float 0.0" (Int64.compare (Int64.of_float 0.0) 0L = 0);
  check "i64 of_float 1.0" (Int64.compare (Int64.of_float 1.0) 1L = 0);
  check "i64 of_float -1.0" (Int64.compare (Int64.of_float (-1.0)) (-1L) = 0);
  check "i64 of_float 2.5" (Int64.compare (Int64.of_float 2.5) 2L = 0);
  check "i64 of_float -2.5" (Int64.compare (Int64.of_float (-2.5)) (-2L) = 0);
  check "i64 of_float 0.99" (Int64.compare (Int64.of_float 0.99) 0L = 0);
  check "i64 of_float -0.99" (Int64.compare (Int64.of_float (-0.99)) 0L = 0);
  check "i64 of_float 255.0" (Int64.compare (Int64.of_float 255.0) 255L = 0);
  check "i64 of_float 65536.0" (Int64.compare (Int64.of_float 65536.0) 65536L = 0);
  check "i64 of_float 1000000000.0" (Int64.compare (Int64.of_float 1000000000.0) 1000000000L = 0);
  check "i64 of_float -1000000000.0" (Int64.compare (Int64.of_float (-1000000000.0)) (-1000000000L) = 0);
  check "i64 of_float 2147483647.0" (Int64.compare (Int64.of_float 2147483647.0) 2147483647L = 0);
  check "i64 of_float -2147483648.0" (Int64.compare (Int64.of_float (-2147483648.0)) (-2147483648L) = 0);
  check "i64 of_float 4294967296.0" (Int64.compare (Int64.of_float 4294967296.0) 4294967296L = 0);
  check "i64 of_float -4294967296.0" (Int64.compare (Int64.of_float (-4294967296.0)) (-4294967296L) = 0);
  check "i64 of_float 4294967295.0" (Int64.compare (Int64.of_float 4294967295.0) 4294967295L = 0);
  ()
let () =
  run "basic" basic;
  run "conv" conv;
  run "tostr" tostr;
  run "ofloat" ofloat;
  run "add" (fun () -> chk "Int64 add" (fun a b -> Int64.add a b) e_add);
  run "sub" (fun () -> chk "Int64 sub" (fun a b -> Int64.sub a b) e_sub);
  run "mul" (fun () -> chk "Int64 mul" (fun a b -> Int64.mul a b) e_mul);
  run "and" (fun () -> chk "Int64 and" (fun a b -> Int64.logand a b) e_and);
  run "or" (fun () -> chk "Int64 or" (fun a b -> Int64.logor a b) e_or);
  run "xor" (fun () -> chk "Int64 xor" (fun a b -> Int64.logxor a b) e_xor);
  run "div" (fun () -> chk "Int64 div" (fun a b -> if Int64.compare b 0L = 0 then 0L else Int64.div a b) e_div);
  run "rem" (fun () -> chk "Int64 rem" (fun a b -> if Int64.compare b 0L = 0 then 0L else Int64.rem a b) e_rem);
  run "shl" (fun () -> chk "Int64 shl" (fun a b -> Int64.shift_left a (Int64.to_int b land 63)) e_shl);
  run "shr" (fun () -> chk "Int64 shr" (fun a b -> Int64.shift_right a (Int64.to_int b land 63)) e_shr);
  run "shru" (fun () -> chk "Int64 shru" (fun a b -> Int64.shift_right_logical a (Int64.to_int b land 63)) e_shru);
  run "neg" (fun () -> chk "Int64 neg" (fun a _ -> Int64.neg a) e_neg);
  run "lognot" (fun () -> chk "Int64 lognot" (fun a _ -> Int64.lognot a) e_lognot);
  run "cmp" (fun () -> chk "Int64 cmp" (fun a b -> Int64.of_int (Int64.compare a b)) e_cmp);
  run "succ" (fun () -> chk "Int64 succ" (fun a _ -> Int64.succ a) e_succ);
  run "pred" (fun () -> chk "Int64 pred" (fun a _ -> Int64.pred a) e_pred);
  finish "T10B"
