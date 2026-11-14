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
let near a b = abs_float (a -. b) <= 1e-6 *. (1.0 +. abs_float b)
let ple a b = a <= b
let pge a b = a >= b
let plt a b = a < b
let pgt a b = a > b
let peq a b = a = b
let rec fsum i acc = if i = 0 then acc else fsum (i - 1) (acc +. 0.5)
let t_conv () =
  List.iter (fun n -> checkn "int_of_float(float_of_int n) " n (int_of_float (float_of_int n) = n))
    [-16384; -16383; -257; -256; -255; -129; -128; -1; 0; 1; 127; 128; 255; 256; 257; 8192; 16383]
let t_trunc () =
  check "int_of_float 2.9" (int_of_float 2.9 = 2);
  check "int_of_float 0.5" (int_of_float 0.5 = 0);
  check "int_of_float 255.99" (int_of_float 255.99 = 255);
  check "int_of_float 16383.0" (int_of_float 16383.0 = 16383);
  check "int_of_float 100.0" (int_of_float 100.0 = 100);
  (* troncamento verso zero per i negativi (FACINX/QINT arrotonda verso -inf?) *)
  check "int_of_float -2.9" (int_of_float (-2.9) = -2);
  check "int_of_float -0.5" (int_of_float (-0.5) = 0);
  check "int_of_float -255.99" (int_of_float (-255.99) = -255);
  check "int_of_float -16384.0" (int_of_float (-16384.0) = -16384)
let t_arith () =
  check "add" (0.25 +. 0.25 = 0.5);
  check "sub" (0.75 -. 0.25 = 0.5);
  check "mul" (3.0 *. 0.5 = 1.5);
  check "div" (1.0 /. 4.0 = 0.25);
  check "neg" (-. 2.0 = (-2.0));
  check "abs" (abs_float (-1.5) = 1.5 && abs_float 1.5 = 1.5);
  check "copysign" (copysign 2.0 (-1.0) = (-2.0) && copysign (-2.0) 1.0 = 2.0);
  check "floor" (floor 2.5 = 2.0 && floor (-2.5) = (-3.0) && floor 3.0 = 3.0 && floor 0.0 = 0.0);
  check "ceil" (ceil 2.5 = 3.0 && ceil (-2.5) = (-2.0) && ceil 3.0 = 3.0);
  check "float_of_int" (float_of_int 3 /. 4.0 = 0.75 && float_of_int (-3) = (-3.0));
  check "fsum" (fsum 200 0.0 = 100.0)
let t_cmp () =
  let x = 0.25 +. 0.25 and y = 0.5 *. 1.0 in
  check "eq" (x = y);
  check "not ne" (not (x <> y));
  check "le eq" (x <= y);
  check "ge eq" (x >= y);
  check "not lt eq" (not (x < y));
  check "not gt eq" (not (x > y));
  check "compare eq" (compare x y = 0);
  check "peq" (peq x y);
  check "ple eq" (ple x y);
  check "pge eq" (pge x y);
  check "not plt eq" (not (plt x y));
  check "not pgt eq" (not (pgt x y));
  let a = 1.5 +. 0.0 and b = 2.5 +. 0.0 in
  check "lt" (a < b && not (b < a));
  check "le" (a <= b && not (b <= a));
  check "gt" (b > a && not (a > b));
  check "ge" (b >= a && not (a >= b));
  check "compare" (compare a b < 0 && compare b a > 0);
  check "plt" (plt a b && not (plt b a));
  check "ple" (ple a b && not (ple b a));
  check "pgt" (pgt b a && not (pgt a b));
  check "pge" (pge b a && not (pge a b));
  let n1 = -. a and n2 = -. b in
  check "neg lt" (n2 < n1 && n1 > n2 && n2 <= n1 && n1 >= n2);
  check "neg/pos" (n1 < a && a > n1 && compare n1 a < 0);
  check "zero" (0.0 = 0.0 +. 0.0 && compare 0.0 (0.5 -. 0.5) = 0)
let t_math () =
  check "sqrt 16" (near (sqrt 16.0) 4.0);
  check "sqrt 2" (near (sqrt 2.0) 1.41421356);
  check "exp 0" (near (exp 0.0) 1.0);
  check "exp 1" (near (exp 1.0) 2.71828183);
  check "log 1" (near (log 1.0) 0.0);
  check "log 10" (near (log 10.0) 2.30258509);
  check "sin 0" (near (sin 0.0) 0.0);
  check "cos 0" (near (cos 0.0) 1.0);
  check "sin 1" (near (sin 1.0) 0.84147098);
  check "atan 1" (near (atan 1.0) 0.78539816);
  check "pow" (near (2.0 ** 10.0) 1024.0);
  check "log10" (near (log10 100.0) 2.0)
let t_frexp () =
  List.iter (fun (x, m, e) ->
    let (m1, e1) = frexp x in
    check2 "frexp mant " (int_of_float x) 0 (m1 = m);
    check2 "frexp exp " (int_of_float x) 0 (e1 = e))
    [(8.0, 0.5, 4); (1.0, 0.5, 1); (0.75, 0.75, 0); (-3.0, -0.75, 2); (0.0, 0.0, 0);
     (0.5, 0.5, 0); (100.0, 0.78125, 7); (-100.0, -0.78125, 7)]
let t_ldexp () =
  check "ldexp 1 10" (ldexp 1.0 10 = 1024.0);
  check "ldexp 1 0" (ldexp 1.0 0 = 1.0);
  check "ldexp 3 -1" (ldexp 3.0 (-1) = 1.5);
  check "ldexp 5 3" (ldexp 5.0 3 = 40.0);
  check "ldexp 0 5" (ldexp 0.0 5 = 0.0);
  check "ldexp 1 -10" (ldexp 1.0 (-10) = 0.0009765625);
  check "ldexp -1.5 2" (ldexp (-1.5) 2 = (-6.0));
  check "ldexp 1 100 inv" (ldexp 1.0 100 *. ldexp 1.0 (-100) = 1.0)
let t_str () =
  List.iter (fun (s, v) -> check ("float_of_string " ^ s) (near (float_of_string s) v))
    [("12.5", 12.5); ("-0.25", -0.25); ("100", 100.0); ("0.5", 0.5); ("3", 3.0)];
  List.iter (fun v -> check "string_of_float round" (near (float_of_string (string_of_float v)) v))
    [1.5; -0.25; 100.0; 0.001; 3.14159; 16383.0]
let t_class () =
  check "classify 0" (classify_float 0.0 = FP_zero);
  check "classify 1" (classify_float 1.0 = FP_normal);
  check "classify -7" (classify_float (-7.0) = FP_normal)
let t_box () =
  let l = [1.5; 2.5; 3.5] in
  check "fold" (List.fold_left (+.) 0.0 l = 7.5);
  let r = (1.5, 2.5) in
  check "tuple" (fst r +. snd r = 4.0);
  let a = Array.make 3 0.0 in
  a.(0) <- 1.5; a.(1) <- 2.5; a.(2) <- a.(0) +. a.(1);
  check "arr" (a.(2) = 4.0)
let () =
  run "conv" t_conv; run "trunc" t_trunc; run "arith" t_arith; run "cmp" t_cmp;
  run "math" t_math; run "frexp" t_frexp; run "ldexp" t_ldexp; run "str" t_str;
  run "class" t_class; run "box" t_box;
  finish "T12"
