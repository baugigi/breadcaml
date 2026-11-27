(* ---- prelude comune (generato da gen_tests.py) ---- *)
let fails = ref 0
let fail s = incr fails; print_string "FAIL "; print_string s; print_newline ()
let check s ok = if not ok then fail s
let checkn s n ok = if not ok then fail (s ^ string_of_int n)
let check2 s m n ok =
  if not ok then fail (s ^ string_of_int m ^ "," ^ string_of_int n)
let run s f =
  try f () with
  | Stack_overflow -> fail (s ^ " STACK")
  | Out_of_memory -> fail (s ^ " OOM")
  | Not_found -> fail (s ^ " NOTFOUND")
  | Failure m -> fail (s ^ " FAILURE " ^ m)
  | Invalid_argument m -> fail (s ^ " INVARG " ^ m)
  | _ -> fail (s ^ " EXN")
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
(* t_bk02: routine BASIC (FP) con i dati in heap oltre $A000.
   Ogni chiamata a sqrt/exp/log/sin/cos/atan/**, conversioni e FOUT/STRVAL
   passa dal wrapper che accende e spegne il BASIC ROM. I float boxed, la
   FloatArray e le stringhe devono sopravvivere intatti. *)
let burn k = for i = 1 to k do ignore (List.init 20 (fun j -> j + i)) done
let near a b = abs_float (a -. b) <= 1e-5 *. (1.0 +. abs_float b)
let fa = Array.init 40 (fun i -> float_of_int i *. 0.5)
let fl = List.init 20 (fun i -> float_of_int (i + 1) *. 1.25)
let strs = List.init 8 (fun i -> string_of_float (float_of_int i +. 0.5))
let verify r =
  check2 "farray " r 0 (let ok = ref true in
    Array.iteri (fun i x -> if x <> float_of_int i *. 0.5 then ok := false) fa; !ok);
  check2 "flist " r 0 (let ok = ref true in
    List.iteri (fun i x -> if x <> float_of_int (i + 1) *. 1.25 then ok := false) fl; !ok);
  check2 "strs " r 0 (let ok = ref true in
    List.iteri (fun i s -> if not (near (float_of_string s) (float_of_int i +. 0.5)) then ok := false) strs; !ok)
let t_math () =
  for r = 1 to 10 do
    burn (60 + r * 41);
    Array.iter (fun x ->
      let y = x +. 1.0 in
      check2 "sqrt " r 0 (near (sqrt (y *. y)) y);
      check2 "exp/log " r 0 (near (exp (log y)) y);
      check2 "sin2+cos2 " r 0 (near (sin y *. sin y +. cos y *. cos y) 1.0);
      check2 "pow " r 0 (near (y ** 2.0) (y *. y))) fa;
    check2 "atan " r 0 (near (atan 1.0) 0.78539816);
    verify r
  done
let t_conv () =
  for r = 1 to 10 do
    burn (50 + r * 53);
    List.iter (fun x ->
      let s = string_of_float x in
      check2 "roundtrip " r 0 (near (float_of_string s) x);
      check2 "int_of_float " r 0 (int_of_float x = int_of_float (floor x)) ) fl;
    check2 "sort cmp " r 0 (List.sort compare fl = fl);
    check2 "compare " r 0 (compare (List.hd fl) (List.nth fl 5) < 0
                           && compare (List.nth fl 5) (List.hd fl) > 0
                           && compare (List.nth fl 7) (List.nth fl 7) = 0);
    check2 "float_of_int " r 0 (float_of_int (r * 100) = 100.0 *. float_of_int r);
    verify r
  done
let () =
  run "math" t_math;
  run "conv" t_conv;
  finish "BK02"
