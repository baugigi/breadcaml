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

let mymap f l =
  let rec aux accu f = function
    | [] -> accu
    | x :: xs -> aux ((f x) :: accu) f xs in
  aux [] f l
let f n = 3 * n
let l = [0; 1; 2; 3; 4; 5; 6; 7; 8; 9]
let l1 = mymap f l
let l2 = List.map f l
let rec p l1 l2 = match l1,l2 with
  |[],_ -> ()
  |x::xs,y::ys ->
    print_int x;
    print_string ",";
    print_int y;
    print_newline ();
    p xs ys
  |_ -> failwith "p"

let _ = p l1 l2
          
