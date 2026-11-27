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
let fid n = Array.init n (fun i -> float_of_int i)
let fid_b n = Array.init n (fun i -> float_of_int (1000 + i))
let fsub_case ofs len =
  let s = Array.sub (fid 85) ofs len in
  check2 "fsub len " ofs len (Array.length s = len);
  let ok = ref true in
  for i = 0 to len - 1 do if s.(i) <> float_of_int (ofs + i) then ok := false done;
  check2 "fsub elts " ofs len !ok
let fappend_case n1 n2 =
  let c = Array.append (fid n1) (fid_b n2) in
  check2 "fappend len " n1 n2 (Array.length c = n1 + n2);
  let ok = ref true in
  for i = 0 to n1 + n2 - 1 do
    if c.(i) <> (if i < n1 then float_of_int i else float_of_int (1000 + i - n1))
    then ok := false
  done;
  check2 "fappend elts " n1 n2 !ok
let fblit_same so d n =
  let a = fid 85 in
  Array.blit a so a d n;
  let ok = ref true in
  for i = 0 to 84 do
    let e = if i >= d && i < d + n then so + i - d else i in
    if a.(i) <> float_of_int e then ok := false
  done;
  check2 "fblit same " so d !ok
let fblit_other so d n =
  let a = fid 85 and b = fid_b 85 in
  Array.blit a so b d n;
  let ok = ref true in
  for i = 0 to 84 do
    let e = if i >= d && i < d + n then so + i - d else 1000 + i in
    if b.(i) <> float_of_int e then ok := false
  done;
  check2 "fblit other " so d !ok
let () =
  run "fsub 0 0" (fun () -> fsub_case 0 0);
  run "fsub 0 1" (fun () -> fsub_case 0 1);
  run "fsub 0 85" (fun () -> fsub_case 0 85);
  run "fsub 84 1" (fun () -> fsub_case 84 1);
  run "fsub 85 0" (fun () -> fsub_case 85 0);
  run "fsub 1 84" (fun () -> fsub_case 1 84);
  run "fsub 42 43" (fun () -> fsub_case 42 43);
  run "fsub 43 42" (fun () -> fsub_case 43 42);
  run "fsub bad" (fun () -> raises_inv "fsub bad" (fun () -> Array.sub (fid 85) 1 85));
  run "fapp 0 0" (fun () -> fappend_case 0 0);
  run "fapp 42 43" (fun () -> fappend_case 42 43);
  run "fapp 43 42" (fun () -> fappend_case 43 42);
  run "fapp 1 84" (fun () -> fappend_case 1 84);
  run "fapp 84 1" (fun () -> fappend_case 84 1);
  run "fapp 85 0" (fun () -> fappend_case 85 0);
  run "fapp 0 85" (fun () -> fappend_case 0 85);
  run "fapp bad" (fun () -> raises_inv "fappend bad" (fun () -> Array.append (fid 43) (fid 43)));
  run "fapp bad2" (fun () -> raises_inv "fappend bad2" (fun () -> Array.append (fid 85) (fid 1)));
  run "fconcat" (fun () -> let c = Array.concat [fid 40; fid_b 45] in check "fconcat len" (Array.length c = 85));
  run "fconcat bad" (fun () -> raises_inv "fconcat bad" (fun () -> Array.concat [fid 43; fid 43]));
  run "fblit_same 0 1 84" (fun () -> fblit_same 0 1 84);
  run "fblit_same 1 0 84" (fun () -> fblit_same 1 0 84);
  run "fblit_same 0 42 43" (fun () -> fblit_same 0 42 43);
  run "fblit_same 42 0 43" (fun () -> fblit_same 42 0 43);
  run "fblit_same 0 0 85" (fun () -> fblit_same 0 0 85);
  run "fblit_same 84 0 1" (fun () -> fblit_same 84 0 1);
  run "fblit_same 0 84 1" (fun () -> fblit_same 0 84 1);
  run "fblit_other 0 1 84" (fun () -> fblit_other 0 1 84);
  run "fblit_other 1 0 84" (fun () -> fblit_other 1 0 84);
  run "fblit_other 0 42 43" (fun () -> fblit_other 0 42 43);
  run "fblit_other 42 0 43" (fun () -> fblit_other 42 0 43);
  run "fblit_other 0 0 85" (fun () -> fblit_other 0 0 85);
  run "fblit_other 84 0 1" (fun () -> fblit_other 84 0 1);
  run "fblit_other 0 84 1" (fun () -> fblit_other 0 84 1);
  finish "D_FSUB"
