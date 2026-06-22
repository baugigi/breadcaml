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

let glob = "A"
         
let mod_glob () =
  let ch = Char.code glob.[0] in
  print_string glob;
  print_int ch;
  print_string " -> ";
  glob.[0] <- Char.chr(succ ch);
  print_endline glob
  
let _ =
  while (ignore (read_line ()); true) do
    mod_glob ()
  done
