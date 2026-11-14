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
let t_string () =
  check "concat" (String.equal (String.concat ", " ["a"; "b"; "c"]) "a, b, c");
  check "index" (String.index "hello" 'l' = 2 && String.contains "hello" 'e');
  check "upper" (String.equal (String.uppercase_ascii "abc1") "ABC1");
  check "lower" (String.equal (String.lowercase_ascii "ABC1") "abc1");
  let p = String.split_on_char ',' "a,b,,c" in
  check "split" (List.length p = 4 && List.nth p 2 = "" && List.nth p 3 = "c");
  check "trim" (String.equal (String.trim "  x y  ") "x y");
  check "init" (String.equal (String.init 5 (fun i -> Char.chr (97 + i))) "abcde");
  check "map" (String.equal (String.map Char.uppercase_ascii "abc") "ABC");
  check "sub" (String.equal (String.sub "abcdef" 2 3) "cde");
  check "make 0" (String.length (String.make 0 'x') = 0);
  check "chars" (Char.code 'A' = 65 && Char.lowercase_ascii 'A' = 'a')
let () =
  run "buffer" t_buffer;
  run "qs" t_qs;
  run "string" t_string;
  finish "T14B"
