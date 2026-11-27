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

(** 40x25 text screen. [x] is the column (0..39), [y] the row (0..24).
    Direct access functions use {e screen codes} (the values stored in the
    screen RAM), not PETSCII: see {!code_of_char} and {!char_of_code}. *)

module Hw = C64_hw

val cols : int
val rows : int

(** {2 Through the Kernal (PETSCII)} *)

val clear : unit -> unit            (** Clears the screen, cursor at home. *)
val home : unit -> unit             (** Cursor at the top left corner. *)
external locate : int -> int -> unit = "caml_nonstd_scr_locate"
(** [locate x y] moves the cursor. Out-of-range coordinates are saturated
    to the screen (see "Direct access" below). *)
val cursor : unit -> int * int      (** Cursor position [(x, y)]. *)
val reverse : bool -> unit          (** Reverse video on/off for printing. *)
val lower_case : bool -> unit
(** [lower_case true] selects the upper/lower case character set,
    [false] the upper case/graphics one. *)

val text_color : int -> unit        (** Color (0..15) for printing. *)
val border : int -> unit            (** Border color. *)
val background : int -> unit        (** Background color. *)

(** {2 Direct access (screen codes)}

    Coordinates are never checked: [x] is saturated to [0..39] and [y] to
    [0..24] (a value outside the range is replaced by the nearest edge), so
    no exception is raised. *)

external get : int -> int -> int = "caml_nonstd_scr_peek"
external put : int -> int -> int -> unit = "caml_nonstd_scr_poke"
(** [put x y code] stores the screen code [code] (0..255). *)

external get_color : int -> int -> int = "caml_nonstd_scr_color_peek"
external put_color : int -> int -> int -> unit
  = "caml_nonstd_scr_color_poke"
(** Color RAM, colors 0..15; reading returns the low nybble. *)

external code_of_char : char -> int = "caml_nonstd_scr_code_of_char"
(** Screen code of a PETSCII character. Control codes ([0x00-0x1F],
    [0x80-0x9F]) give the space code ([0x20]). *)

external char_of_code : int -> char = "caml_nonstd_scr_char_of_code"
(** PETSCII character for a screen code (the reverse video bit is ignored). *)

val put_char : int -> int -> char -> unit
(** [put_char x y c] is [put x y (code_of_char c)]. *)

val get_char : int -> int -> char

val print_at : ?color:int -> int -> int -> string -> unit
(** [print_at ?color x y s] writes [s] directly in the screen RAM, from
    column [x] of row [y]; characters outside columns 0..39 are dropped
    ([y] is saturated to [0..24]). With [~color] the color RAM is set too.
    The cursor does not move. *)

val fill : int -> unit              (** Fills the whole screen with a code. *)
val fill_color : int -> unit        (** Fills the whole color RAM. *)

val scroll_up : ?color:bool -> unit -> unit
(** Scrolls the screen one row up (the last row is filled with spaces);
    with [~color:true] the color RAM scrolls too. *)

val scroll_down : ?color:bool -> unit -> unit
