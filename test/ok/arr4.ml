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

let rot a =
  let _ = match Array.length a with
    | 0 -> ()
    | l -> 
       let a0 = a.(0) in
       for i = 0 to l - 2 do
         a.(i) <- a.(succ i)
       done;
       a.(pred l) <- a0 in
  a
;;
let a = [| 0; 1; 2; 3; 4; 5; 6; 7; 8; 9 |]
    in (rot a).(0)
;;
