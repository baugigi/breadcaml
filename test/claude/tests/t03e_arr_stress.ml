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
let ident n = Array.init n (fun i -> i)
let ident_b n = Array.init n (fun i -> 1000 + i)
let fid n = Array.init n (fun i -> float_of_int i)
let fid_b n = Array.init n (fun i -> float_of_int (1000 + i))
let stress_int () =
  let a = ident 200 and b = ident_b 55 in
  for it = 1 to 250 do
    let c = Array.append a b in
    let ok1 = Array.length c = 255 && c.(0) = 0 && c.(199) = 199
              && c.(200) = 1000 && c.(254) = 1054 in
    checkn "stress append " it ok1;
    let d = Array.sub c (it mod 40) 200 in
    let k = it mod 40 in
    checkn "stress sub " it (Array.length d = 200 && d.(0) = k
                             && d.(199) = (if k = 0 then 199 else 999 + k));
    let e = Array.concat [a; b] in
    checkn "stress concat " it (Array.length e = 255 && e.(0) = 0 && e.(254) = 1054
                                && e.(200) = 1000);
    let f = Array.make 255 it in
    checkn "stress make " it (f.(0) = it && f.(254) = it);
    Array.blit c 0 f 1 254;
    checkn "stress blit " it (f.(0) = it && f.(1) = 0 && f.(254) = 1053)
  done
let stress_float () =
  let a = fid 40 and b = fid_b 45 in
  for it = 1 to 150 do
    let c = Array.append a b in
    checkn "fstress append " it (Array.length c = 85 && c.(0) = 0.0 && c.(39) = 39.0
                                 && c.(40) = 1000.0 && c.(84) = 1044.0);
    let d = Array.sub c 5 80 in
    checkn "fstress sub " it (Array.length d = 80 && d.(0) = 5.0 && d.(79) = 1044.0);
    let e = Array.concat [a; b] in
    checkn "fstress concat " it (Array.length e = 85 && e.(84) = 1044.0);
    let g = Array.make 85 (float_of_int it) in
    checkn "fstress make " it (g.(0) = float_of_int it && g.(84) = float_of_int it)
  done
let () =
  run "stress_int" stress_int;
  run "stress_float" stress_float;
  finish "T03E"
