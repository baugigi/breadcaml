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
let xs = [| (-16384); (-8192); (-257); (-256); (-255); (-129); (-128); (-127); (-124); (-123); (-122); (-6); (-5); (-2); (-1); 0; 1; 2; 3; 4; 5; 6; 7; 126; 127; 128; 129; 131; 132; 133; 134; 135; 254; 255; 256; 257; 261; 8191; 16382; 16383 |]
let bits9 x =
  (if x < (-1) then 1 else 0) + (if x <= (-1) then 2 else 0) + (if x > (-1) then 4 else 0)
  + (if x >= (-1) then 8 else 0) + (if x = (-1) then 16 else 0) + (if x <> (-1) then 32 else 0)
let ex9 = [| 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 26; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44 |]
let tb9 () =
  for j = 0 to 39 do check2 "bits c=" (-1) j (bits9 xs.(j) = ex9.(j)) done
let bits10 x =
  (if x < 0 then 1 else 0) + (if x <= 0 then 2 else 0) + (if x > 0 then 4 else 0)
  + (if x >= 0 then 8 else 0) + (if x = 0 then 16 else 0) + (if x <> 0 then 32 else 0)
let ex10 = [| 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 26; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44 |]
let tb10 () =
  for j = 0 to 39 do check2 "bits c=" 0 j (bits10 xs.(j) = ex10.(j)) done
let bits11 x =
  (if x < 1 then 1 else 0) + (if x <= 1 then 2 else 0) + (if x > 1 then 4 else 0)
  + (if x >= 1 then 8 else 0) + (if x = 1 then 16 else 0) + (if x <> 1 then 32 else 0)
let ex11 = [| 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 26; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44 |]
let tb11 () =
  for j = 0 to 39 do check2 "bits c=" 1 j (bits11 xs.(j) = ex11.(j)) done
let bits12 x =
  (if x < 2 then 1 else 0) + (if x <= 2 then 2 else 0) + (if x > 2 then 4 else 0)
  + (if x >= 2 then 8 else 0) + (if x = 2 then 16 else 0) + (if x <> 2 then 32 else 0)
let ex12 = [| 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 26; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44 |]
let tb12 () =
  for j = 0 to 39 do check2 "bits c=" 2 j (bits12 xs.(j) = ex12.(j)) done
let bits13 x =
  (if x < 5 then 1 else 0) + (if x <= 5 then 2 else 0) + (if x > 5 then 4 else 0)
  + (if x >= 5 then 8 else 0) + (if x = 5 then 16 else 0) + (if x <> 5 then 32 else 0)
let ex13 = [| 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 26; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44 |]
let tb13 () =
  for j = 0 to 39 do check2 "bits c=" 5 j (bits13 xs.(j) = ex13.(j)) done
let bits14 x =
  (if x < 126 then 1 else 0) + (if x <= 126 then 2 else 0) + (if x > 126 then 4 else 0)
  + (if x >= 126 then 8 else 0) + (if x = 126 then 16 else 0) + (if x <> 126 then 32 else 0)
let ex14 = [| 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 26; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44 |]
let tb14 () =
  for j = 0 to 39 do check2 "bits c=" 126 j (bits14 xs.(j) = ex14.(j)) done
let bits15 x =
  (if x < 127 then 1 else 0) + (if x <= 127 then 2 else 0) + (if x > 127 then 4 else 0)
  + (if x >= 127 then 8 else 0) + (if x = 127 then 16 else 0) + (if x <> 127 then 32 else 0)
let ex15 = [| 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 26; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44 |]
let tb15 () =
  for j = 0 to 39 do check2 "bits c=" 127 j (bits15 xs.(j) = ex15.(j)) done
let bits16 x =
  (if x < 128 then 1 else 0) + (if x <= 128 then 2 else 0) + (if x > 128 then 4 else 0)
  + (if x >= 128 then 8 else 0) + (if x = 128 then 16 else 0) + (if x <> 128 then 32 else 0)
let ex16 = [| 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 26; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44 |]
let tb16 () =
  for j = 0 to 39 do check2 "bits c=" 128 j (bits16 xs.(j) = ex16.(j)) done
let bits17 x =
  (if x < 129 then 1 else 0) + (if x <= 129 then 2 else 0) + (if x > 129 then 4 else 0)
  + (if x >= 129 then 8 else 0) + (if x = 129 then 16 else 0) + (if x <> 129 then 32 else 0)
let ex17 = [| 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 26; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44 |]
let tb17 () =
  for j = 0 to 39 do check2 "bits c=" 129 j (bits17 xs.(j) = ex17.(j)) done
let () =
  run "bits9" tb9;
  run "bits10" tb10;
  run "bits11" tb11;
  run "bits12" tb12;
  run "bits13" tb13;
  run "bits14" tb14;
  run "bits15" tb15;
  run "bits16" tb16;
  run "bits17" tb17;
  finish "T06P"
