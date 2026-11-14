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
let bits0 x =
  (if x < (-16384) then 1 else 0) + (if x <= (-16384) then 2 else 0) + (if x > (-16384) then 4 else 0)
  + (if x >= (-16384) then 8 else 0) + (if x = (-16384) then 16 else 0) + (if x <> (-16384) then 32 else 0)
let ex0 = [| 26; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44 |]
let tb0 () =
  for j = 0 to 39 do check2 "bits c=" (-16384) j (bits0 xs.(j) = ex0.(j)) done
let bits1 x =
  (if x < (-257) then 1 else 0) + (if x <= (-257) then 2 else 0) + (if x > (-257) then 4 else 0)
  + (if x >= (-257) then 8 else 0) + (if x = (-257) then 16 else 0) + (if x <> (-257) then 32 else 0)
let ex1 = [| 35; 35; 26; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44 |]
let tb1 () =
  for j = 0 to 39 do check2 "bits c=" (-257) j (bits1 xs.(j) = ex1.(j)) done
let bits2 x =
  (if x < (-256) then 1 else 0) + (if x <= (-256) then 2 else 0) + (if x > (-256) then 4 else 0)
  + (if x >= (-256) then 8 else 0) + (if x = (-256) then 16 else 0) + (if x <> (-256) then 32 else 0)
let ex2 = [| 35; 35; 35; 26; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44 |]
let tb2 () =
  for j = 0 to 39 do check2 "bits c=" (-256) j (bits2 xs.(j) = ex2.(j)) done
let bits3 x =
  (if x < (-255) then 1 else 0) + (if x <= (-255) then 2 else 0) + (if x > (-255) then 4 else 0)
  + (if x >= (-255) then 8 else 0) + (if x = (-255) then 16 else 0) + (if x <> (-255) then 32 else 0)
let ex3 = [| 35; 35; 35; 35; 26; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44 |]
let tb3 () =
  for j = 0 to 39 do check2 "bits c=" (-255) j (bits3 xs.(j) = ex3.(j)) done
let bits4 x =
  (if x < (-129) then 1 else 0) + (if x <= (-129) then 2 else 0) + (if x > (-129) then 4 else 0)
  + (if x >= (-129) then 8 else 0) + (if x = (-129) then 16 else 0) + (if x <> (-129) then 32 else 0)
let ex4 = [| 35; 35; 35; 35; 35; 26; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44 |]
let tb4 () =
  for j = 0 to 39 do check2 "bits c=" (-129) j (bits4 xs.(j) = ex4.(j)) done
let bits5 x =
  (if x < (-128) then 1 else 0) + (if x <= (-128) then 2 else 0) + (if x > (-128) then 4 else 0)
  + (if x >= (-128) then 8 else 0) + (if x = (-128) then 16 else 0) + (if x <> (-128) then 32 else 0)
let ex5 = [| 35; 35; 35; 35; 35; 35; 26; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44 |]
let tb5 () =
  for j = 0 to 39 do check2 "bits c=" (-128) j (bits5 xs.(j) = ex5.(j)) done
let bits6 x =
  (if x < (-127) then 1 else 0) + (if x <= (-127) then 2 else 0) + (if x > (-127) then 4 else 0)
  + (if x >= (-127) then 8 else 0) + (if x = (-127) then 16 else 0) + (if x <> (-127) then 32 else 0)
let ex6 = [| 35; 35; 35; 35; 35; 35; 35; 26; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44 |]
let tb6 () =
  for j = 0 to 39 do check2 "bits c=" (-127) j (bits6 xs.(j) = ex6.(j)) done
let bits7 x =
  (if x < (-123) then 1 else 0) + (if x <= (-123) then 2 else 0) + (if x > (-123) then 4 else 0)
  + (if x >= (-123) then 8 else 0) + (if x = (-123) then 16 else 0) + (if x <> (-123) then 32 else 0)
let ex7 = [| 35; 35; 35; 35; 35; 35; 35; 35; 35; 26; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44 |]
let tb7 () =
  for j = 0 to 39 do check2 "bits c=" (-123) j (bits7 xs.(j) = ex7.(j)) done
let bits8 x =
  (if x < (-2) then 1 else 0) + (if x <= (-2) then 2 else 0) + (if x > (-2) then 4 else 0)
  + (if x >= (-2) then 8 else 0) + (if x = (-2) then 16 else 0) + (if x <> (-2) then 32 else 0)
let ex8 = [| 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 26; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44 |]
let tb8 () =
  for j = 0 to 39 do check2 "bits c=" (-2) j (bits8 xs.(j) = ex8.(j)) done
let () =
  run "bits0" tb0;
  run "bits1" tb1;
  run "bits2" tb2;
  run "bits3" tb3;
  run "bits4" tb4;
  run "bits5" tb5;
  run "bits6" tb6;
  run "bits7" tb7;
  run "bits8" tb8;
  finish "T06O"
