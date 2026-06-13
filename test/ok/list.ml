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

let rec map f = function
  | [] -> []
  | x::xs -> (f x) :: (map f xs)
let rec nth l n =
  match n, l with
  | 0, x::_ -> Some x
  | p, _::r when p > 0 -> nth r (pred p)
  | _ -> None
let x () =
  let l = map (fun n -> n * n) [1;2;3;4;5] in
  match nth l 2 with
  | Some n -> n
  | None -> -1
;;

x ()
    
