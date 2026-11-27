(* ——————————————————————————————————————————————————————————————————————
   The BreadCaml Project / Progetto BreadCaml
   Copyright (C) 21-Apr-2026 Piero Furiesi
   
   This program is  free software; you can redistribute  it and/or modify
   it under the terms of the  GNU GENERAL PUBLIC LICENSE (GPL) version 2,
   as specified in the LICENSE-en file in the project root folder.
   
   Questo  programma  è software  libero;  può  essere ridistribuito  e/o
   modificato nei termini della GNU GENERAL PUBLIC LICENSE (GPL) versione
   2, come specificato nel file  LICENZA-it nella cartella principale del
   progetto.
   —————————————————————————————————————————————————————————————————————— *)

external get_key : unit -> char = "IOtools_get_key"
external unsafe_get_char : int -> int = "IOtools_videoram_read"
external unsafe_put_char : int -> int -> unit = "IOtools_videoram_write"
external unsafe_set_cursor_position : int -> unit = "IOtools_set_cursor_position"

let range min (value : int) max =
  (* the type annotation avoids compilation involving calls to caml_compare *)
    min <= value && value <= max

let get_char x y =
  (* assert ((range 0 x 39) && (range 0 y 24)); *)
  unsafe_get_char (40 * (24 - y) + x)

let put_char x y ch =
  (* assert ((range 0 x 39) && (range 0 y 24) && (range 0 ch 255)); *)
  unsafe_put_char (40 * (24 - y) + x) ch

let set_cursor_position x y =
  (* assert ((range 0 x 39) && (range 0 y 24)); *)
  unsafe_set_cursor_position (256 * (24 - y) + x)

let print_at x y s =
  set_cursor_position x y;
  print_string s

let print_center y str =
  print_at ((40 - String.length str) / 2) y str
