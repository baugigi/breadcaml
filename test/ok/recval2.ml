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

let rec myval = (f, 1, myval)
and f _ = match myval with (_, x, _) -> x
and a = [| 1.; 2. |]
;;
let x() = f 100;;
x();;
