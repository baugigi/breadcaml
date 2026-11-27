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
module H = Hashtbl.Make (struct
  type t = int
  let equal (a : int) b = a = b
  let hash (x : int) = x land 255
end)
let () =
  let h = H.create 16 in
  for i = 0 to 199 do H.replace h i (i + 1) done;
  check "length" (H.length h = 200);
  check "find" (H.find h 150 = 151 && H.find h 0 = 1 && H.find h 199 = 200);
  H.remove h 150;
  check "remove" (not (H.mem h 150) && H.length h = 199);
  H.replace h 3 99;
  check "replace" (H.find h 3 = 99 && H.length h = 199);
  (try ignore (H.find h 1000); fail "find NOEXN" with Not_found -> ());
  let s = ref 0 in
  H.iter (fun k v -> s := (!s + k + v) land 16383) h;
  check "iter" (!s >= 0);
  finish "T93"
