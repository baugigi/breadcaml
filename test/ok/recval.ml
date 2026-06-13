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

let hd (x, _) = x
    
let tl (_, t) = t

let rec mycirc = ((fun _ -> 1), mycirc)

let rec f c = function
  | 0 -> hd c
  | n when n > 0 -> f (tl c) (pred n)
  | _ -> fun _ -> -1

let x() = f mycirc 8 ()

;;

x();;
