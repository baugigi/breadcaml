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
let cnt = ref 0
let () =
  let l = lazy (incr cnt; 41 + 1) in
  check "lazy not forced" (!cnt = 0 && not (Lazy.is_val l));
  check "force" (Lazy.force l = 42);
  check "force twice" (Lazy.force l = 42 && !cnt = 1);
  check "is_val" (Lazy.is_val l);
  let v = Lazy.from_val 7 in
  check "from_val" (Lazy.force v = 7 && Lazy.is_val v);
  let m = lazy (Lazy.force l + 1) in
  check "nested" (Lazy.force m = 43);
  let e = lazy (raise Not_found) in
  (try ignore (Lazy.force e); fail "lazy exn NOEXN" with Not_found -> ());
  (try ignore (Lazy.force e); fail "lazy exn2 NOEXN" with _ -> ());
  finish "T92"
