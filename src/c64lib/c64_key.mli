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

(** Keyboard and joysticks. *)

external get : unit -> char = "caml_nonstd_get_key"
(** The next key from the keyboard buffer (a PETSCII code, as returned by
    the Kernal), or ['\000'] if no key is waiting. Never blocks. *)

external wait : unit -> char = "caml_nonstd_wait_key"
(** Waits for a key and returns it. No echo, no cursor. *)

external joy : int -> int = "caml_nonstd_joystick"
(** [joy port] (port 1 or 2) returns a bit mask: {!joy_up}, {!joy_down},
    {!joy_left}, {!joy_right}, {!joy_fire}; a bit is set when the
    corresponding switch is closed. Reading port 1 briefly interferes with
    the keyboard scan. *)

val joy_up : int  val joy_down : int  val joy_left : int
val joy_right : int  val joy_fire : int
