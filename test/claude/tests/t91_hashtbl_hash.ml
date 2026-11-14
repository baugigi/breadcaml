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
let () =
  check "hash int" (Hashtbl.hash 5 = Hashtbl.hash 5);
  check "hash str" (Hashtbl.hash ("ab" ^ "c") = Hashtbl.hash "abc");
  check "hash tuple" (Hashtbl.hash (1, "x") = Hashtbl.hash (1, "x" ^ ""));
  check "hash range" (let h = Hashtbl.hash 12345 in h >= 0);
  let h = Hashtbl.create 16 in
  for i = 0 to 99 do Hashtbl.replace h i (i * 2) done;
  check "length" (Hashtbl.length h = 100);
  check "find" (Hashtbl.find h 57 = 114);
  Hashtbl.remove h 57;
  check "remove" (not (Hashtbl.mem h 57) && Hashtbl.length h = 99);
  let hs = Hashtbl.create 16 in
  Hashtbl.add hs "one" 1; Hashtbl.add hs ("tw" ^ "o") 2;
  check "str keys" (Hashtbl.find hs "two" = 2 && Hashtbl.find hs "one" = 1);
  raises_inv "dummy" (fun () -> invalid_arg "x");
  finish "T91"
