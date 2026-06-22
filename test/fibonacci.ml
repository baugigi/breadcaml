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

let rec fibo_rec n =
  if n <= 1 then n else (fibo_rec (n - 1)) + (fibo_rec (n - 2))

let fibo_tail n =
  let rec aux n b a =
    if n <= 0 then a else aux (n - 1) (a + b) b
  in aux n 1 0
   
let n = 40

let _ =
  print_string ("fibo_tail " ^ (string_of_int n) ^ "=");
  print_int (fibo_tail n);
  print_newline ();
  print_string ("fibo_rec  " ^ (string_of_int n) ^ "=");
  print_int (fibo_rec n);
  print_newline ();
    
