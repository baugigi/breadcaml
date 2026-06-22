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

let number = 8
let rec fact_rec n = match n with
  | 0 | 1 -> 1
  | _ -> n * (fact_rec (pred n))
let rec fact_tail n accu = match n with
  | 0 | 1 -> accu
  | _ -> fact_tail (pred n) (n * accu)
let rec fact_cont n k = match n with
  | 0 | 1 -> k 1
  | _ -> fact_cont (pred n) (fun x -> (n * x)) |> k
let fact_iter n =
  let r = ref 1 in
  for i = 1 to n do
    r := !r * i
  done;
  !r

let _ =
  print_int (fact_rec number);
  print_newline ();
  print_int (fact_tail number 1);
  print_newline ();
  print_int (fact_cont number (fun x -> x));
  print_newline ();
  print_int (fact_iter number);
  print_newline ();
