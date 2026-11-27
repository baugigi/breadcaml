(* ---- prelude comune (generato da gen_tests.py) ---- *)
let fails = ref 0
let fail s = incr fails; print_string "FAIL "; print_string s; print_newline ()
let check s ok = if not ok then fail s
let checkn s n ok = if not ok then fail (s ^ string_of_int n)
let check2 s m n ok =
  if not ok then fail (s ^ string_of_int m ^ "," ^ string_of_int n)
let run s f =
  try f () with
  | Stack_overflow -> fail (s ^ " STACK")
  | Out_of_memory -> fail (s ^ " OOM")
  | Not_found -> fail (s ^ " NOTFOUND")
  | Failure m -> fail (s ^ " FAILURE " ^ m)
  | Invalid_argument m -> fail (s ^ " INVARG " ^ m)
  | _ -> fail (s ^ " EXN")
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
(* t_pe01: letterali char/string della stdlib in PETSCII (stdlib compilata con
   bcamlppx, vedi stdlib_ppx.patch). Il sorgente di questo test e' preprocessato:
   "true" qui e' PETSCII, come quello che deve produrre/riconoscere la stdlib.
   Dove serve un valore ASCII si usa [%ascii ...]. *)
let msg_fail f m = try ignore (f ()); false with Failure x -> x = m | _ -> false
let msg_inv f m = try ignore (f ()); false with Invalid_argument x -> x = m | _ -> false

let t_bool () =
  check "string_of_bool t" (string_of_bool true = "true");
  check "string_of_bool f" (string_of_bool false = "false");
  check "Bool.to_string t" (Bool.to_string true = "true");
  check "Bool.to_string f" (Bool.to_string false = "false");
  check "bool_of_string t" (bool_of_string "true" = true);
  check "bool_of_string f" (bool_of_string "false" = false);
  check "bool_of_string_opt t" (bool_of_string_opt "true" = Some true);
  check "bool_of_string_opt f" (bool_of_string_opt "false" = Some false);
  check "bool_of_string_opt x" (bool_of_string_opt "xyz" = None);
  check "bool_of_string msg" (msg_inv (fun () -> bool_of_string "xyz") "bool_of_string")

let t_int32 () =
  let g s = Int32.to_int (Int32.of_string s) in
  check "dec" (g "123" = 123 && g "-45" = (-45));
  check "0x" (g "0xff" = 255 && g "0x1f" = 31);
  check "0X" (g "0XFF" = 255 && g "0X1f" = 31);
  check "hex digits upper" (g "0xAB" = 171 && g "0xCD" = 205);
  check "hex digits lower" (g "0xab" = 171 && g "0xcd" = 205);
  check "0o" (g "0o17" = 15 && g "0O17" = 15);
  check "0b" (g "0b101" = 5 && g "0B101" = 5);
  check "neg hex" (g "-0x10" = (-16));
  check "bad" (msg_fail (fun () -> Int32.of_string "0xg") "Int32.of_string")

let t_int64 () =
  let g s = Int64.to_int (Int64.of_string s) in
  check "dec" (g "123" = 123 && g "-45" = (-45));
  check "0x" (g "0xff" = 255);
  check "0X" (g "0XFF" = 255);
  check "hex digits" (g "0xAB" = 171 && g "0xab" = 171 && g "0xCD" = 205);
  check "0o" (g "0o17" = 15 && g "0O17" = 15);
  check "0b" (g "0b101" = 5 && g "0B101" = 5);
  check "bad" (msg_fail (fun () -> Int64.of_string "0xg") "Int64.of_string")

let t_escaped () =
  check "Char.escaped a" (Char.escaped 'a' = "a");
  check "Char.escaped nl" (Char.escaped '\n' = "\\n");
  check "Char.escaped tab" (Char.escaped '\t' = "\\t");
  check "Char.escaped cr" (Char.escaped '\r' = "\\r");
  check "Char.escaped bs" (Char.escaped '\b' = "\\b");
  check "Char.escaped backslash" (Char.escaped '\\' = "\\\\");
  check "Char.escaped quote" (Char.escaped '\'' = "\\'");
  check "Bytes.escaped" (Bytes.to_string (Bytes.escaped (Bytes.of_string "a\nb\tc\rd\\e")) = "a\\nb\\tc\\rd\\\\e");
  check "String.escaped" (String.escaped "a\nb\tc\rd\\e" = "a\\nb\\tc\\rd\\\\e");
  check "String.escaped plain" (String.escaped "abc xyz" = "abc xyz")

let t_buffer () =
  let subst k = match k with
    | "a" -> "[A]" | "Foo_Bar" -> "[FB]" | "X1" -> "[X1]" | "q" -> "[Q]" | _ -> "?" in
  let b = Buffer.create 32 in
  Buffer.add_substitute b subst ("1 $a 2 $(a) 3 $" ^ [%ascii "{"] ^ "a" ^ [%ascii "}"] ^ " 4 $Foo_Bar 5 $(Foo_Bar) 6 $X1");
  check "add_substitute" (Buffer.contents b = "1 [A] 2 [A] 3 [A] 4 [FB] 5 [FB] 6 [X1]");
  let b = Buffer.create 8 in
  Buffer.add_substitute b subst "\\$a $q";
  check "add_substitute esc" (Buffer.contents b = "$a [Q]")

let t_char () =
  (* Char.Ascii lavora su caratteri ASCII *)
  check "Ascii.lowercase_ascii" (Char.Ascii.lowercase_ascii [%ascii 'A'] = [%ascii 'a']
                                  && Char.Ascii.lowercase_ascii [%ascii 'z'] = [%ascii 'z']);
  check "Ascii.uppercase_ascii" (Char.Ascii.uppercase_ascii [%ascii 'a'] = [%ascii 'A']
                                  && Char.Ascii.uppercase_ascii [%ascii 'Z'] = [%ascii 'Z']);
  check "Ascii.lowercase" (Char.Ascii.lowercase [%ascii 'Q'] = [%ascii 'q']);
  check "Ascii.uppercase" (Char.Ascii.uppercase [%ascii 'q'] = [%ascii 'Q']);
  (* ASCII -> PETSCII e ritorno: il risultato e' il letterale di questo test *)
  check "to_petscii a" (Char.Ascii.to_petscii [%ascii 'a'] = 'a');
  check "to_petscii A" (Char.Ascii.to_petscii [%ascii 'A'] = 'A');
  check "to_petscii _" (Char.Ascii.to_petscii [%ascii '_'] = '_');
  check "to_petscii |" (Char.Ascii.to_petscii [%ascii '|'] = '|');
  check "of_petscii a" (Char.Ascii.of_petscii 'a' = [%ascii 'a']);
  check "of_petscii A" (Char.Ascii.of_petscii 'A' = [%ascii 'A']);
  check "of_petscii _" (Char.Ascii.of_petscii '_' = [%ascii '_']);
  check "of_petscii |" (Char.Ascii.of_petscii '|' = [%ascii '|']);
  (* PETSCII *)
  check "lowercase" (Char.lowercase 'A' = 'a' && Char.lowercase 'a' = 'a');
  check "uppercase" (Char.uppercase 'a' = 'A' && Char.uppercase 'A' = 'A');
  check "lowercase_ascii" (Char.lowercase_ascii 'Q' = 'q');
  check "is_letter" (Char.is_letter 'x' && Char.is_letter 'X' && not (Char.is_letter '5'));
  check "is_upper/lower" (Char.is_upper 'X' && not (Char.is_upper 'x')
                          && Char.is_lower 'x' && not (Char.is_lower 'X'));
  check "is_digit" (Char.is_digit '5' && not (Char.is_digit 'a'));
  check "is_symbol" (Char.is_symbol '+' && Char.is_symbol '@' && not (Char.is_symbol 'a'));
  check "Common.larw" (Char.code Char.Common.larw = 95);
  check "Common.pound" (Char.code Char.Common.pound = 92);
  check "Common.under" (Char.code Char.Common.under = 164);
  check "Control.cr" (Char.code Char.Control.cr = 13)

let t_msgs () =
  check "hd" (msg_fail (fun () -> List.hd []) "hd");
  check "tl" (msg_fail (fun () -> List.tl []) "tl");
  check "nth" (msg_fail (fun () -> List.nth [1; 2] 5) "nth");
  check "List.nth neg" (msg_inv (fun () -> List.nth [1; 2] (-1)) "List.nth");
  check "Char.chr" (msg_inv (fun () -> Char.chr 300) "Char.chr");
  check "Array.sub" (msg_inv (fun () -> Array.sub [|1; 2|] 0 5) "Array.sub");
  check "String.sub" (msg_inv (fun () -> String.sub "abc" 2 5) "String.sub / Bytes.sub")

let t_sys () =
  check "backend_type" (Sys.backend_type = Sys.Other "BreadCaml");
  check "os_type" (List.mem Sys.os_type ["c64 kernal r1"; "c64 kernal r2"; "c64 kernal r3"; "unknown"])

let () =
  run "bool" t_bool;
  run "int32" t_int32;
  run "int64" t_int64;
  run "escaped" t_escaped;
  run "buffer" t_buffer;
  run "char" t_char;
  run "msgs" t_msgs;
  run "sys" t_sys;
  finish "PE01"
