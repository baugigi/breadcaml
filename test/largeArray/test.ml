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

open LargeArray

(*
BUG nelle applicazioni parziali:
LargeArray.iter e LargeArray.map sono definite correttamente così:

let iter f = Array.(iter (iter f))
let map f = Array.(map (map f))
let iter2 f = Array.(iter2 (iter2 f))

ma il programma fa la botta. Se invece le ridefinisco così, allora funziona:

   (nb per ridefinirle qui ho esposto il tipo concreto in largeArray.mli)
*)



let iter f a = Array.(iter (fun a' -> iter f a') a)
let map f a = Array.(map (fun a' -> map f a') a)
let iter2 f a b = Array.(iter2 (fun a' b' -> iter2 f a' b') a b)

let a = init 500 float_of_int

let () =
  print_endline "iter";
  iter print_float a;
  print_endline "map";
  let b = map sqrt a in
  print_endline "iter2";
  iter2 (fun x y ->
      print_float x;
      print_float y;
      print_newline ()) a b

  (* svalvola random ---> GC bug! *)

