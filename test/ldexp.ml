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

let print_frexp x =
  let p = frexp x in
  print_string " (";
  print_float (fst p);
  print_string ",";
  print_int (snd p);
  print_string ") ";
;;
let f x n =
  print_float x;
  print_string " ";
  print_int n;
  print_frexp x;
  (try
     let x' = ldexp x n in
     print_float x';
     print_frexp x';
   with _ ->
     print_string "overflow");
  print_newline();
;;

f (2.0) (-200);
f (2.0) (-2);
f (2.0) (-1);
f (-2.0) (-200);
f (-2.0) (-2);
f (-2.0) (-1);
f (2.0) (+200);
f (2.0) (+2);
f (2.0) (+1);
f (-2.0) (+200);
f (-2.0) (+2);
f (-2.0) (+1);

