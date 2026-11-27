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

(** Hires / multicolor bitmap graphics (VIC-II), 320x200 (hires) or 160x200
    (multicolor, 4 colors per 4x8 cell). Origin (0,0) is the top left.

    {b Memory.} The VIC sees 16 KB at a time ("bank"). The program must
    leave the bitmap area outside the OCaml stack: with the standard
    [bank2] layout run with [-mem 0x7FFF] (stack below $8000):
    {v
      $8000-$83E7  screen matrix (colors)      $83F8-$83FF sprite pointers
      $8400-$8FFF  sprite data (pointers 16..63)
      $9000-$9FFF  CPU only (VIC sees char ROM there)
      $A000-$BF3F  bitmap (RAM under the BASIC ROM, handled automatically)
      $BF40-$BFFF  3 more sprite blocks (pointers 253..255)
    v}
    {b Interrupts.} Do not rely on the BASIC ROM while the bitmap is in
    $A000-$BFFF; reading it back from OCaml needs [Hw.Mem.peek ~ram:true]
    (and [Hw.Nmi.block] against RESTORE). *)

module Hw = C64_hw

type mode = Hires | Multicolor

type layout = {
  bank : int;    (** VIC bank 0, 1 or 2 (bank 3 is not supported). *)
  screen : int;  (** Screen matrix offset in the bank: multiple of 0x400, not
                     in 0x1000-0x1FFF of banks 0 and 2 (char ROM image). *)
  bitmap : int;  (** Bitmap offset in the bank: 0x2000, or 0 only in bank 1
                     (offset 0 of banks 0 and 2 shows the char ROM). *)
  sprites : int; (** Sprite data offset in the bank (used by [Sprite]). *)
}

val bank2 : layout  (** bank 2: screen $8000, bitmap $A000. *)
val bank1 : layout  (** bank 1: screen $4000, bitmap $6000; needs [-mem 0x3FFF]. *)

val init : ?mode:mode -> layout -> unit
(** Switches to bitmap mode (default [Hires]). Resets pen and window.
    @raise Invalid_argument on an invalid layout. The bitmap is not cleared. *)

val exit : unit -> unit
(** Back to text mode, bank 0, standard memory control. *)

val width : unit -> int   (** 320 (hires) or 160 (multicolor). *)
val height : int          (** 200 *)

val clear : unit -> unit
(** Clears the bitmap (all pixels pen 0). *)

val fill_screen : int -> unit
(** Fills the screen matrix with a byte. *)

val colors : ink:int -> paper:int -> unit
(** Hires: sets every cell colors (pen 1 = [ink], pen 0 = [paper]).
    Multicolor: pen 1 = [ink], pen 2 = [paper] (matrix nibbles). *)

val fill_color : int -> unit
(** Fills the color RAM (multicolor pen 3 color). *)

val background : int -> unit
(** Background color ($D021, multicolor pen 0). *)

val pen : int -> unit
(** Hires: 0 (erase) or 1. Multicolor: 0..3. *)

external plot : int -> int -> unit = "caml_nonstd_gfx_plot"
(** Pixel with the current pen; silently clipped. *)

external point : int -> int -> int = "caml_nonstd_gfx_point"
(** Pen value of the pixel, or [-1] if outside. *)

external line : int -> int -> int -> int -> unit = "caml_nonstd_gfx_line"
(** [line x1 y1 x2 y2]: Bresenham line, clipped. Fully visible lines use a
    self-modifying fast loop. *)

external window : int -> int -> int -> int -> unit
  = "caml_nonstd_gfx_window"
(** [window x0 y0 x1 y1] defines virtual coordinates: [(x0,y0)] maps to the
    top left pixel and [(x1,y1)] to the bottom right one (spans may be
    reversed, giving flipped axes; coordinates are saturated to +-16383).
    Must be called after [init]. @raise Invalid_argument if a span is < 2. *)

external unwindow : unit -> unit = "caml_nonstd_gfx_unwindow"
  (** Back to physical coordinates. *)

(** {b Shapes} are drawn with [line]/[plot], so they are clipped and follow
    the window (in virtual coordinates; with a window that enlarges, rows of
    [fill_rect] / [fill_circle] may leave gaps). In multicolor mode pixels
    are twice as wide as tall, so circles come out as ellipses. *)

val hline : int -> int -> int -> unit  (** [hline x1 x2 y] *)
val vline : int -> int -> int -> unit  (** [vline x y1 y2] *)
val rect : int -> int -> int -> int -> unit
(** [rect x1 y1 x2 y2]: outline. *)
val fill_rect : int -> int -> int -> int -> unit
val circle : int -> int -> int -> unit
(** [circle cx cy r]: midpoint algorithm. A negative [r] is taken as 0. *)
val fill_circle : int -> int -> int -> unit
