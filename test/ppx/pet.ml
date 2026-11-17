(* ——————————————————————————————————————————————————————————————————————
   Progetto BreadCaml / The BreadCaml Project
   Copyright (C) 21-Apr-2026 Piero Furiesi
   
   Questo  programma  è software  libero;  può  essere ridistribuito  e/o
   modificato nei termini della GNU GENERAL PUBLIC LICENSE (GPL) versione
   2, come specificato nel file  LICENZA-it nella cartella principale del
   progetto.
   
   This program is  free software; you can redistribute  it and/or modify
   it under the terms of the  GNU GENERAL PUBLIC LICENSE (GPL) version 2,
   as specified in the LICENSE-en file in the project root folder.
   —————————————————————————————————————————————————————————————————————— *)
let a = "dl{RED}aàs"
let b = "{CLR}ciao" ^ a
let c = 'a'
let d = b ^ "{RVSOFF}"
let e = b ^ [%ascii "{RVSOFF}"]
(*
let f s = match s with
  | [%ascii "{CLR}gigi"] -> "ASCII: " ^ s
  | "{CLR}gigi" -> "PETSCII: " ^ s
  | "{CTL-A}" -> "PETSCII: " ^ s
  | _ -> s
 *)

let f = function
  | [%ascii "{CLR}gigi"] as s -> "ASCII: " ^ s
  | "{CLR}gigi" as s -> "PETSCII: " ^ s
  | "{CTL-A}" as s -> "PETSCII: " ^ s
  | s -> s

let () =
  List.iter print_endline [ a; b; String.make 1 c; d; e ];
  print_endline (f [%ascii "{CLR}gigi"]);
  print_endline (f "{CLR}gigi");
  print_endline (f "{CTL-A}");
  
  

