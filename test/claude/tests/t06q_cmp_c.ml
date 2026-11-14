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
let bits18 x =
  (if x < 133 then 1 else 0) + (if x <= 133 then 2 else 0) + (if x > 133 then 4 else 0)
  + (if x >= 133 then 8 else 0) + (if x = 133 then 16 else 0) + (if x <> 133 then 32 else 0)
let ex18 = [| 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 26; 44; 44; 44; 44; 44; 44; 44; 44; 44; 44 |]
let tb18 () =
  for j = 0 to 39 do check2 "bits c=" 133 j (bits18 xs.(j) = ex18.(j)) done
let bits19 x =
  (if x < 254 then 1 else 0) + (if x <= 254 then 2 else 0) + (if x > 254 then 4 else 0)
  + (if x >= 254 then 8 else 0) + (if x = 254 then 16 else 0) + (if x <> 254 then 32 else 0)
let ex19 = [| 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 26; 44; 44; 44; 44; 44; 44; 44 |]
let tb19 () =
  for j = 0 to 39 do check2 "bits c=" 254 j (bits19 xs.(j) = ex19.(j)) done
let bits20 x =
  (if x < 255 then 1 else 0) + (if x <= 255 then 2 else 0) + (if x > 255 then 4 else 0)
  + (if x >= 255 then 8 else 0) + (if x = 255 then 16 else 0) + (if x <> 255 then 32 else 0)
let ex20 = [| 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 26; 44; 44; 44; 44; 44; 44 |]
let tb20 () =
  for j = 0 to 39 do check2 "bits c=" 255 j (bits20 xs.(j) = ex20.(j)) done
let bits21 x =
  (if x < 256 then 1 else 0) + (if x <= 256 then 2 else 0) + (if x > 256 then 4 else 0)
  + (if x >= 256 then 8 else 0) + (if x = 256 then 16 else 0) + (if x <> 256 then 32 else 0)
let ex21 = [| 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 26; 44; 44; 44; 44; 44 |]
let tb21 () =
  for j = 0 to 39 do check2 "bits c=" 256 j (bits21 xs.(j) = ex21.(j)) done
let bits22 x =
  (if x < 257 then 1 else 0) + (if x <= 257 then 2 else 0) + (if x > 257 then 4 else 0)
  + (if x >= 257 then 8 else 0) + (if x = 257 then 16 else 0) + (if x <> 257 then 32 else 0)
let ex22 = [| 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 26; 44; 44; 44; 44 |]
let tb22 () =
  for j = 0 to 39 do check2 "bits c=" 257 j (bits22 xs.(j) = ex22.(j)) done
let bits23 x =
  (if x < 261 then 1 else 0) + (if x <= 261 then 2 else 0) + (if x > 261 then 4 else 0)
  + (if x >= 261 then 8 else 0) + (if x = 261 then 16 else 0) + (if x <> 261 then 32 else 0)
let ex23 = [| 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 26; 44; 44; 44 |]
let tb23 () =
  for j = 0 to 39 do check2 "bits c=" 261 j (bits23 xs.(j) = ex23.(j)) done
let bits24 x =
  (if x < 16382 then 1 else 0) + (if x <= 16382 then 2 else 0) + (if x > 16382 then 4 else 0)
  + (if x >= 16382 then 8 else 0) + (if x = 16382 then 16 else 0) + (if x <> 16382 then 32 else 0)
let ex24 = [| 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 26; 44 |]
let tb24 () =
  for j = 0 to 39 do check2 "bits c=" 16382 j (bits24 xs.(j) = ex24.(j)) done
let bits25 x =
  (if x < 16383 then 1 else 0) + (if x <= 16383 then 2 else 0) + (if x > 16383 then 4 else 0)
  + (if x >= 16383 then 8 else 0) + (if x = 16383 then 16 else 0) + (if x <> 16383 then 32 else 0)
let ex25 = [| 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 35; 26 |]
let tb25 () =
  for j = 0 to 39 do check2 "bits c=" 16383 j (bits25 xs.(j) = ex25.(j)) done
let () =
  run "bits18" tb18;
  run "bits19" tb19;
  run "bits20" tb20;
  run "bits21" tb21;
  run "bits22" tb22;
  run "bits23" tb23;
  run "bits24" tb24;
  run "bits25" tb25;
  finish "T06Q"
