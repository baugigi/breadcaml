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
let g3 x = match x with
  | 0 -> 1
  | 1 -> 6
  | 2 -> 11
  | _ -> (-1)
let tg3 () =
  for i = 0 to 2 do check2 "gmatch " 3 i (g3 i = (i * 5 + 1) mod 1000) done;
  check "g out hi" (g3 3 = (-1) && g3 (-1) = (-1) && g3 300 = (-1))
let g5 x = match x with
  | 0 -> 1
  | 1 -> 6
  | 2 -> 11
  | 3 -> 16
  | 4 -> 21
  | _ -> (-1)
let tg5 () =
  for i = 0 to 4 do check2 "gmatch " 5 i (g5 i = (i * 5 + 1) mod 1000) done;
  check "g out hi" (g5 5 = (-1) && g5 (-1) = (-1) && g5 300 = (-1))
let g50 x = match x with
  | 0 -> 1
  | 1 -> 6
  | 2 -> 11
  | 3 -> 16
  | 4 -> 21
  | 5 -> 26
  | 6 -> 31
  | 7 -> 36
  | 8 -> 41
  | 9 -> 46
  | 10 -> 51
  | 11 -> 56
  | 12 -> 61
  | 13 -> 66
  | 14 -> 71
  | 15 -> 76
  | 16 -> 81
  | 17 -> 86
  | 18 -> 91
  | 19 -> 96
  | 20 -> 101
  | 21 -> 106
  | 22 -> 111
  | 23 -> 116
  | 24 -> 121
  | 25 -> 126
  | 26 -> 131
  | 27 -> 136
  | 28 -> 141
  | 29 -> 146
  | 30 -> 151
  | 31 -> 156
  | 32 -> 161
  | 33 -> 166
  | 34 -> 171
  | 35 -> 176
  | 36 -> 181
  | 37 -> 186
  | 38 -> 191
  | 39 -> 196
  | 40 -> 201
  | 41 -> 206
  | 42 -> 211
  | 43 -> 216
  | 44 -> 221
  | 45 -> 226
  | 46 -> 231
  | 47 -> 236
  | 48 -> 241
  | 49 -> 246
  | _ -> (-1)
let tg50 () =
  for i = 0 to 49 do check2 "gmatch " 50 i (g50 i = (i * 5 + 1) mod 1000) done;
  check "g out hi" (g50 50 = (-1) && g50 (-1) = (-1) && g50 300 = (-1))
let () =
  run "g3" tg3;
  run "g5" tg5;
  run "g50" tg50;
  finish "T06K"
