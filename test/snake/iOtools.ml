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

type coord = int * int

external get_key : unit -> char = "IOtools_get_key"
external unsafe_get_char : int -> int = "IOtools_videoram_read"
external unsafe_put_char : int -> int -> unit = "IOtools_videoram_write"
external unsafe_set_cursor_position : int -> unit = "IOtools_set_cursor_position"

let range min (value : int) max =
  (* (value : int) avoids to be compiled as a call to caml_compare *)
  min <= value && value <= max

let get_char (x, y) =
  assert ((range 0 x 39) && (range 0 y 24));
  unsafe_get_char (40 * (24 - y) + x)

let put_char (x, y) ch =
  assert ((range 0 x 39) && (range 0 y 24) && (range 0 ch 255));
  unsafe_put_char (40 * (24 - y) + x) ch

let set_cursor_position (x, y) =
  assert ((range 0 x 39) && (range 0 y 24));
  unsafe_set_cursor_position (256 * (24 - y) + x)

let print_at pos s =
  set_cursor_position pos;
  print_string s

let clear_screen () = print_char '\147'

let set_uppercase () = print_char '\142'
