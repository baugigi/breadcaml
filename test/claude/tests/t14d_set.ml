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
module IS = Set.Make (struct type t = int let compare (a : int) b = compare a b end)
let t_set () =
  let s = ref IS.empty in
  for i = 0 to 99 do s := IS.add (scr i) !s done;
  check "set card" (IS.cardinal !s = 100 && IS.mem (scr 7) !s && not (IS.mem 1000 !s));
  check "min/max" (IS.min_elt !s = 2 && IS.max_elt !s = 210)
let () =
  run "set" t_set;
  finish "T14D"
