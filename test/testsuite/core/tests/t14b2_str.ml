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
let t_string () =
  check "concat" (String.equal (String.concat ", " ["a"; "b"; "c"]) "a, b, c");
  check "index" (String.index "hello" 'l' = 2 && String.contains "hello" 'e');
  check "upper" (String.equal (String.uppercase_ascii "abc1") "ABC1");
  check "lower" (String.equal (String.lowercase_ascii "ABC1") "abc1");
  let p = String.split_on_char ',' "a,b,,c" in
  check "split" (List.length p = 4 && List.nth p 2 = "" && List.nth p 3 = "c");
  check "trim" (String.equal (String.trim "  x y  ") "x y");
  check "init" (String.equal (String.init 5 (fun i -> Char.chr (Char.code 'a' + i))) "abcde");
  check "map" (String.equal (String.map Char.uppercase_ascii "abc") "ABC");
  check "sub" (String.equal (String.sub "abcdef" 2 3) "cde");
  check "make 0" (String.length (String.make 0 'x') = 0);
  check "chars" (Char.code 'A' = 0xC1 && Char.lowercase_petscii 'A' = 'a')
let () =
  run "string" t_string;
  finish "T14B2"
