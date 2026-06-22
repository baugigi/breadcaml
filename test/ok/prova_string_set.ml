(* ——————————————————————————————————————————————————————————————————————
   Progetto BreadCaml / The BreadCaml Project
   Copyright (C) 21-Apr-2026 Piero Furiesi

   Questo  programma è  software libero;  è possibile  ridistribuirlo e/o
   modificarlo secondo i  termini della GNU General  Public License (GPL)
   versione  2,  come specificato  nel  file  LICENZA-it nella  directory
   principale del progetto.

   This program is  free software; you can redistribute  it and/or modify
   it under the terms of the  GNU General Public License (GPL) version 2,
   as specified in the LICENSE-en file in the project root.
   —————————————————————————————————————————————————————————————————————— *)

external string_length : string -> int = "%string_length"
external string_create : int -> string = "caml_create_string"
external string_unsafe_set : string -> int -> char -> unit = "%string_unsafe_set";;
external string_safe_set : string -> int -> char -> unit = "caml_string_set";;
external unsafe_char_of_int : int -> char = "%identity";;


let mystring len =
  let str = string_create len in
  string_safe_set str 0 '*';
  for i = pred len downto 1 do
    string_safe_set str i (unsafe_char_of_int (48 + i mod 10))
  done;
  str
;;

for i = 1 to 20 do
  print_string (mystring i);
  print_newline ();
done


let mystring str =
  let len = string_length str in
  string_safe_set str 0 '*';
  for i = pred len downto 1 do
    string_safe_set str i (unsafe_char_of_int (48 + i mod 10))
  done;
  str
;;

print_string (mystring "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx");
print_newline ();

