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

let i, j = ref 0, ref 0

let _ =
  i := -10;
  while !i <= 10 do
    print_string "i="; 
    print_int !i;
    print_string "; j=";
    j := -10;
    while !j <= 10 do
      print_int !j;
      print_string ", ";
      j := !j + 1
    done;
    print_newline();
    i := !i + 1
  done
    
