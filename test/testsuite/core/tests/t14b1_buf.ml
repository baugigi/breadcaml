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
let t_buffer () =
  let b = Buffer.create 16 in
  for i = 1 to 169 do Buffer.add_char b 'a'; Buffer.add_string b "bc" done;
  check "blen" (Buffer.length b = 507);
  let s = Buffer.contents b in
  check "bcontents" (String.length s = 507 && String.get s 0 = 'a' && String.get s 1 = 'b'
                     && String.get s 2 = 'c' && String.get s 504 = 'a' && String.get s 506 = 'c');
  Buffer.add_string b "xy";
  check "b509" (Buffer.length b = 509);
  (try Buffer.add_char b 'z'; fail "buffer overflow NOEXN" with Failure _ -> () | Invalid_argument _ -> ());
  Buffer.clear b;
  check "bclear" (Buffer.length b = 0)
let () =
  run "buffer" t_buffer;
  finish "T14B1"
