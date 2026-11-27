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
(* c64lib: argomenti fuori range saturati ai bordi (mai Invalid_argument), conversioni petscii/screen code *)
open C64
let t_screen () =
  Screen.clear ();
  Screen.put 0 0 1;  Screen.put (-5) (-5) 2;
  check "put-neg" (Screen.get 0 0 = 2);
  Screen.put 100 100 3;
  check "put-big" (Screen.get 39 24 = 3);
  Screen.put 39 0 4; Screen.put 40 0 5;
  check "put-x40" (Screen.get 39 0 = 5);
  check "get-neg" (Screen.get (-1) (-1) = 2);
  check "get-big" (Screen.get 99 99 = 3);
  Screen.put_color 1 1 7; Screen.put_color 99 99 6;
  check "col" (Screen.get_color 1 1 = 7);
  check "col-big" (Screen.get_color 39 24 = 6);
  check "col-sat" (Screen.get_color 99 99 = 6);
  Screen.print_at 38 1 "ABCDE";
  check "pa-right" (Screen.get 38 1 = Screen.code_of_char 'A' && Screen.get 39 1 = Screen.code_of_char 'B');
  Screen.print_at (-2) 2 "ABCDE";
  check "pa-left" (Screen.get 0 2 = Screen.code_of_char 'C' && Screen.get 2 2 = Screen.code_of_char 'E');
  Screen.print_at 5 99 "Z";
  check "pa-row" (Screen.get 5 24 = Screen.code_of_char 'Z')
let t_conv () =
  for c = 32 to 95 do
    checkn "rt" c (Char.code (Screen.char_of_code (Screen.code_of_char (Char.chr c))) = c)
  done;
  check "A" (Screen.code_of_char 'A' = 65);
  check "@" (Screen.code_of_char '@' = 0);
  check "sp" (Screen.code_of_char ' ' = 32)
let vic r = Hw.Mem.peek_at 0xD0 r
let t_sprite () =
  Sprite.pos 9 600 100;
  check "sp-x" (vic 14 = 255);
  check "sp-msb" (vic 16 land 128 <> 0);
  check "sp-y" (vic 15 = 100);
  Sprite.pos (-3) (-9) 10;
  check "sp0-x" (vic 0 = 0);
  check "sp0-y" (vic 1 = 10);
  check "sp0-msb" (vic 16 land 1 = 0)
let t_sound () =
  Sound.note 3 95;
  let l = Sound.shadow 14 and h = Sound.shadow 15 in
  Sound.note 9 200;
  check "note-sat" (Sound.shadow 14 = l && Sound.shadow 15 = h);
  Sound.freq_hz 1 0;
  let l = Sound.shadow 0 and h = Sound.shadow 1 in
  Sound.freq_hz 1 (-5);
  check "hz-sat" (Sound.shadow 0 = l && Sound.shadow 1 = h)
let () =
  run "screen" t_screen; run "conv" t_conv;
  run "sprite" t_sprite; run "sound" t_sound;
  finish "T20"
