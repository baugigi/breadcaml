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
let scr n = (n * 37 + 11) mod 211
let cmpi (a : int) b = compare a b
module IM = Map.Make (struct type t = int let compare (a : int) b = compare a b end)
let t_map () =
  let m = ref IM.empty in
  for i = 0 to 59 do m := IM.add (scr i) i !m done;
  check "card" (IM.cardinal !m = 60);
  check "find" (IM.find (scr 17) !m = 17 && IM.find (scr 59) !m = 59);
  check "mem" (IM.mem (scr 50) !m && not (IM.mem 1000 !m));
  (try ignore (IM.find 1000 !m); fail "find NOEXN" with Not_found -> ());
  m := IM.remove (scr 17) !m;
  check "removed" (not (IM.mem (scr 17) !m) && IM.cardinal !m = 59);
  check "fold" (IM.fold (fun k _ acc -> acc + k) !m 0 = 6219)
let () =
  run "map" t_map;
  finish "T14C"
