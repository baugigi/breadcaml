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
type c2 = C2_0 | C2_1
let f2 = function
  | C2_0 -> 3
  | C2_1 -> 10
let all2 = [| C2_0; C2_1 |]
let e2 = [| 3; 10 |]
let sw2 () =
  for i = 0 to 1 do check2 "sw " 2 i (f2 all2.(i) = e2.(i)) done
type c3 = C3_0 | C3_1 | C3_2
let f3 = function
  | C3_0 -> 3
  | C3_1 -> 10
  | C3_2 -> 17
let all3 = [| C3_0; C3_1; C3_2 |]
let e3 = [| 3; 10; 17 |]
let sw3 () =
  for i = 0 to 2 do check2 "sw " 3 i (f3 all3.(i) = e3.(i)) done
type c4 = C4_0 | C4_1 | C4_2 | C4_3
let f4 = function
  | C4_0 -> 3
  | C4_1 -> 10
  | C4_2 -> 17
  | C4_3 -> 24
let all4 = [| C4_0; C4_1; C4_2; C4_3 |]
let e4 = [| 3; 10; 17; 24 |]
let sw4 () =
  for i = 0 to 3 do check2 "sw " 4 i (f4 all4.(i) = e4.(i)) done
type c5 = C5_0 | C5_1 | C5_2 | C5_3 | C5_4
let f5 = function
  | C5_0 -> 3
  | C5_1 -> 10
  | C5_2 -> 17
  | C5_3 -> 24
  | C5_4 -> 31
let all5 = [| C5_0; C5_1; C5_2; C5_3; C5_4 |]
let e5 = [| 3; 10; 17; 24; 31 |]
let sw5 () =
  for i = 0 to 4 do check2 "sw " 5 i (f5 all5.(i) = e5.(i)) done
type c6 = C6_0 | C6_1 | C6_2 | C6_3 | C6_4 | C6_5
let f6 = function
  | C6_0 -> 3
  | C6_1 -> 10
  | C6_2 -> 17
  | C6_3 -> 24
  | C6_4 -> 31
  | C6_5 -> 38
let all6 = [| C6_0; C6_1; C6_2; C6_3; C6_4; C6_5 |]
let e6 = [| 3; 10; 17; 24; 31; 38 |]
let sw6 () =
  for i = 0 to 5 do check2 "sw " 6 i (f6 all6.(i) = e6.(i)) done
type c10 = C10_0 | C10_1 | C10_2 | C10_3 | C10_4 | C10_5 | C10_6 | C10_7 | C10_8 | C10_9
let f10 = function
  | C10_0 -> 3
  | C10_1 -> 10
  | C10_2 -> 17
  | C10_3 -> 24
  | C10_4 -> 31
  | C10_5 -> 38
  | C10_6 -> 45
  | C10_7 -> 52
  | C10_8 -> 59
  | C10_9 -> 66
let all10 = [| C10_0; C10_1; C10_2; C10_3; C10_4; C10_5; C10_6; C10_7; C10_8; C10_9 |]
let e10 = [| 3; 10; 17; 24; 31; 38; 45; 52; 59; 66 |]
let sw10 () =
  for i = 0 to 9 do check2 "sw " 10 i (f10 all10.(i) = e10.(i)) done
let () =
  run "sw2" sw2;
  run "sw3" sw3;
  run "sw4" sw4;
  run "sw5" sw5;
  run "sw6" sw6;
  run "sw10" sw10;
  finish "T06A"
