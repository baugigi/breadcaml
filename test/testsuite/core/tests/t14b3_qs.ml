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
let t_qs () =
  let q = Queue.create () in
  for i = 0 to 254 do Queue.add i q done;
  check "qlen" (Queue.length q = 255);
  let ok = ref true in
  for i = 0 to 254 do if Queue.take q <> i then ok := false done;
  check "qfifo" (!ok && Queue.is_empty q);
  let s = Stack.create () in
  for i = 0 to 254 do Stack.push i s done;
  check "slen" (Stack.length s = 255);
  let ok2 = ref true in
  for i = 254 downto 0 do if Stack.pop s <> i then ok2 := false done;
  check "slifo" (!ok2 && Stack.is_empty s)
let () =
  run "qs" t_qs;
  finish "T14B3"
