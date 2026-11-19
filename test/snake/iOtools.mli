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
external unsafe_set_cursor_position : int -> unit
  = "IOtools_set_cursor_position"
val range : int -> int -> int -> bool
val get_char : int -> int -> int
val put_char : int -> int -> int -> unit
val set_cursor_position : int -> int -> unit
val print_at : int -> int -> string -> unit
val print_center : int -> string -> unit
