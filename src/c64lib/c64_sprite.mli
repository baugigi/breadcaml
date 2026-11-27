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

(** Hardware sprites (VIC-II). Data are copied into the VIC bank: the source
    array or string can be discarded (it becomes garbage) right after
    [define]. A block is 64 bytes; [blk] is the block number in the VIC bank
    (address in the bank = [blk * 64]) and is also the sprite pointer value.
    With [Gfx.bank2] blocks 16..63 are free ($8400-$8FFF; 253..255 too).
    Call [setup] with the same layout given to [Gfx.init] (default [Gfx.bank2]).
    Sprite numbers are 0..7. Sprite pixel (24,50) is the top left of the
    320x200 screen area. *)

module Hw = C64_hw
module Gfx = C64_gfx

val setup : Gfx.layout -> unit
val layout : unit -> Gfx.layout

val define : int -> int array -> unit
(** [define blk a]: copies [a.(0..62)] (bytes; 3 per row, 21 rows). *)

val define_string : int -> string -> unit
(** Same, from the first 63 characters of a string. *)

val define_art : int -> string array -> unit
(** [define_art blk rows]: 21 rows of 24 characters; ' ' and '.' are empty
    pixels, any other character sets it. *)

val define_art_mc : int -> string array -> unit
(** Multicolor: 21 rows of 12 characters ['0'..'3'] (pen of each double
    pixel: 0 transparent, 1 and 3 = [mcolors], 2 = [color]). *)

val assign : int -> int -> unit
(** [assign n blk]: sprite [n] shows block [blk]. *)

val enable : int -> bool -> unit
val pos : int -> int -> int -> unit
(** [pos n x y]: raw VIC coordinates, [x] in 0..511. *)

val move : int -> int -> int -> unit
(** [move n x y] = [pos n (x+24) (y+50)] (screen pixel coordinates). *)

val color : int -> int -> unit
val mcolors : int -> int -> unit  (** The two shared multicolor colors. *)
val multicolor : int -> bool -> unit
val expand_x : int -> bool -> unit
val expand_y : int -> bool -> unit
val behind : int -> bool -> unit  (** Priority: behind the foreground. *)

val hit_sprites : unit -> int
(** Sprite-sprite collision bits ($D01E); reading clears them. *)

val hit_background : unit -> int
(** Sprite-background collision bits ($D01F); reading clears them. *)
