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
let sub_case ofs len =
  let s = Array.sub (ident 255) ofs len in
  check2 "sub len " ofs len (Array.length s = len);
  let ok = ref true in
  for i = 0 to len - 1 do if s.(i) <> ofs + i then ok := false done;
  check2 "sub elts " ofs len !ok
let append_case n1 n2 =
  let c = Array.append (ident n1) (ident_b n2) in
  check2 "append len " n1 n2 (Array.length c = n1 + n2);
  let ok = ref true in
  for i = 0 to n1 + n2 - 1 do
    if c.(i) <> (if i < n1 then i else 1000 + i - n1) then ok := false
  done;
  check2 "append elts " n1 n2 !ok
let concat_case l =
  let a = List.map ident l in
  let c = Array.concat a in
  let tot = List.fold_left (+) 0 l in
  checkn "concat len " tot (Array.length c = tot);
  let ok = ref true in
  let pos = ref 0 in
  List.iter (fun n ->
    for i = 0 to n - 1 do if c.(!pos + i) <> i then ok := false done;
    pos := !pos + n) l;
  checkn "concat elts " tot !ok
let blit_same so d n =
  let a = ident 255 in
  Array.blit a so a d n;
  let ok = ref true in
  for i = 0 to 254 do
    let e = if i >= d && i < d + n then so + i - d else i in
    if a.(i) <> e then ok := false
  done;
  check2 "blit same " so d (!ok && true);
  if not !ok then fail ("  (n=" ^ string_of_int n ^ ")")
let blit_other so d n =
  let a = ident 255 and b = ident_b 255 in
  Array.blit a so b d n;
  let ok = ref true in
  for i = 0 to 254 do
    let e = if i >= d && i < d + n then so + i - d else 1000 + i in
    if b.(i) <> e then ok := false
  done;
  check2 "blit other " so d (!ok && true);
  if not !ok then fail ("  (n=" ^ string_of_int n ^ ")")
let test_sub () =
  sub_case 0 0;
  sub_case 0 1;
  sub_case 0 255;
  sub_case 254 1;
  sub_case 255 0;
  sub_case 1 254;
  sub_case 127 128;
  sub_case 128 127;
  sub_case 127 1;
  sub_case 128 1;
  sub_case 0 127;
  sub_case 0 128;
  sub_case 100 155;
  sub_case 0 254;
  raises_inv "sub bad" (fun () -> Array.sub (ident 255) 0 256);
  raises_inv "sub bad" (fun () -> Array.sub (ident 255) 255 1);
  raises_inv "sub bad" (fun () -> Array.sub (ident 255) 1 255);
  raises_inv "sub bad" (fun () -> Array.sub (ident 255) (-1) 1);
  raises_inv "sub bad" (fun () -> Array.sub (ident 255) 0 (-1));
  raises_inv "sub bad" (fun () -> Array.sub (ident 255) 254 2);
  ()
let test_append () =
  append_case 0 0;
  append_case 0 5;
  append_case 5 0;
  append_case 127 128;
  append_case 128 127;
  append_case 1 254;
  append_case 254 1;
  append_case 255 0;
  append_case 0 255;
  append_case 100 100;
  append_case 127 127;
  append_case 128 126;
  raises_inv "append bad" (fun () -> Array.append (ident 128) (ident 128));
  raises_inv "append bad" (fun () -> Array.append (ident 255) (ident 1));
  raises_inv "append bad" (fun () -> Array.append (ident 1) (ident 255));
  raises_inv "append bad" (fun () -> Array.append (ident 200) (ident 56));
  ()
let test_concat () =
  concat_case [50; 100; 105];
  concat_case [127; 0; 128];
  concat_case [0; 0; 0];
  concat_case [255];
  concat_case [128; 127];
  concat_case [1; 1; 1; 1];
  concat_case [0; 255];
  concat_case [255; 0];
  concat_case [100; 0; 0; 155];
  concat_case [127; 128];
  raises_inv "concat bad" (fun () -> Array.concat [ident 128; ident 128]);
  raises_inv "concat bad" (fun () -> Array.concat [ident 255; ident 1]);
  raises_inv "concat bad" (fun () -> Array.concat [ident 100; ident 100; ident 100]);
  check "concat []" (Array.length (Array.concat ([] : int array list)) = 0)

let test_blit () =
  blit_same 0 1 254;
  blit_other 0 1 254;
  blit_same 1 0 254;
  blit_other 1 0 254;
  blit_same 0 127 128;
  blit_other 0 127 128;
  blit_same 127 0 128;
  blit_other 127 0 128;
  blit_same 0 128 127;
  blit_other 0 128 127;
  blit_same 128 0 127;
  blit_other 128 0 127;
  blit_same 100 101 100;
  blit_other 100 101 100;
  blit_same 101 100 100;
  blit_other 101 100 100;
  blit_same 0 0 255;
  blit_other 0 0 255;
  blit_same 0 0 0;
  blit_other 0 0 0;
  blit_same 254 0 1;
  blit_other 254 0 1;
  blit_same 0 254 1;
  blit_other 0 254 1;
  blit_same 128 127 127;
  blit_other 128 127 127;
  blit_same 127 128 127;
  blit_other 127 128 127;
  blit_same 3 5 200;
  blit_other 3 5 200;
  raises_inv "blit bad" (fun () -> Array.blit (ident 255) 0 (ident 255) 0 256);
  raises_inv "blit bad" (fun () -> Array.blit (ident 255) 1 (ident 255) 0 255);
  raises_inv "blit bad" (fun () -> Array.blit (ident 255) 0 (ident 255) 1 255);
  raises_inv "blit bad" (fun () -> Array.blit (ident 255) (-1) (ident 255) 0 1);
  raises_inv "blit bad" (fun () -> Array.blit (ident 255) 0 (ident 255) (-1) 1);
  ()
let () =
  run "sub" test_sub;
  run "append" test_append;
  run "concat" test_concat;
  run "blit" test_blit;
  finish "T03C"
