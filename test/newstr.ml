(* ——————————————————————————————————————————————————————————————————————
   Progetto O64ml / The O64ml Project
   Copyright (C) 21-Apr-2026 Piero Furiesi

   Questo  programma è  software libero;  è possibile  ridistribuirlo e/o
   modificarlo secondo i  termini della GNU General  Public License (GPL)
   versione  2,  come specificato  nel  file  LICENZA-it nella  directory
   principale del progetto.

   This program is  free software; you can redistribute  it and/or modify
   it under the terms of the  GNU General Public License (GPL) version 2,
   as specified in the LICENSE-en file in the project root.
   —————————————————————————————————————————————————————————————————————— *)

let x = 1;;

let a = "ABCDEFGHI";;
(*
let strcpy a =
  let b = String.create (String.length a) in
  for i = 0 to pred (String.length a) do
    String.set b i (String.get a i);
  done;
  b;;

let b = strcpy a in
xxxxxxxx
 *)
let b = "01234567890123456789"
and c = "012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789" in
try
  Bytes.fill b 10 11 '*';
  Bytes.fill c 290 11 '*';
  print_string b;
  print_newline ();
  print_string c;
  print_newline ();
with _ -> print_string "EXCEPTION CAUGHT.\013"
;;

