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

let rec f n =
  if n <= 1 then
    1
  else
    f (pred n) + 1;;

f 127;; (* 127 chiamate ricorsive, -stacksize 4 *)
f 255;; (* 255 chiamate ricorsive, -stacksize 8 *)
f 511;; (* 511 chiamate ricorsive, -stacksize 16 *)


