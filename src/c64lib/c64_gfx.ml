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

module Hw = C64_hw

type mode = Hires | Multicolor
type layout = { bank : int; screen : int; bitmap : int; sprites : int }

let bank2 = { bank = 2; screen = 0; bitmap = 0x2000; sprites = 0x0400 }
let bank1 = { bank = 1; screen = 0; bitmap = 0x2000; sprites = 0x0400 }

external prim_init : int -> int -> int -> int -> unit = "caml_nonstd_gfx_init"
external prim_exit : unit -> unit = "caml_nonstd_gfx_exit"
external prim_pen : int -> unit = "caml_nonstd_gfx_pen"
external plot : int -> int -> unit = "caml_nonstd_gfx_plot"
external point : int -> int -> int = "caml_nonstd_gfx_point"
external line : int -> int -> int -> int -> unit = "caml_nonstd_gfx_line"
external window : int -> int -> int -> int -> unit = "caml_nonstd_gfx_window"
external unwindow : unit -> unit = "caml_nonstd_gfx_unwindow"

let cur = ref bank2
let cur_mode = ref Hires
let active = ref false

let width () = if !cur_mode = Hires then 320 else 160
let height = 200

let page l = l.bank * 64 + (l.screen lsr 8)
let bitmap_page () = !cur.bank * 64 + (!cur.bitmap lsr 8)

let init ?(mode = Hires) l =
  prim_init l.bank l.screen l.bitmap (if mode = Hires then 0 else 1);
  cur := l; cur_mode := mode; active := true

let exit () = if !active then (prim_exit (); active := false)

let clear () =
  (* 8000 bytes = 31 pages + 64 *)
  let p = bitmap_page () in
  Hw.Mem.unsafe_fill_at p 0 8000 0

let fill_screen v =
  Hw.Mem.unsafe_fill_at (page !cur) 0 1000 v

(* In hires mode the screen matrix byte is (ink lsl 4) lor paper;
   in multicolor it holds colors 1 (high nibble) and 2 (low nibble). *)
let colors ~ink ~paper = fill_screen (((ink land 15) lsl 4) lor (paper land 15))
let fill_color v = Hw.Mem.unsafe_fill_at 0xD8 0 1000 v

let pen p = prim_pen p
let background c = Hw.Vic.poke 0x21 c

let hline x1 x2 y = line x1 y x2 y
let vline x y1 y2 = line x y1 x y2

let rect x1 y1 x2 y2 =
  hline x1 x2 y1; hline x1 x2 y2; vline x1 y1 y2; vline x2 y1 y2

let fill_rect x1 y1 x2 y2 =
  let ya = if y1 < y2 then y1 else y2 and yb = if y1 < y2 then y2 else y1 in
  for y = ya to yb do line x1 y x2 y done

(* midpoint circle, 8-fold symmetry *)
let circle cx cy r =
  let r = if r < 0 then 0 else r in
  let x = ref r and y = ref 0 and d = ref (1 - r) in
  while !x >= !y do
    let a = !x and b = !y in
    plot (cx + a) (cy + b); plot (cx + b) (cy + a);
    plot (cx - b) (cy + a); plot (cx - a) (cy + b);
    plot (cx - a) (cy - b); plot (cx - b) (cy - a);
    plot (cx + b) (cy - a); plot (cx + a) (cy - b);
    incr y;
    if !d < 0 then d := !d + 2 * !y + 1
    else begin decr x; d := !d + 2 * (!y - !x) + 1 end
  done

let fill_circle cx cy r =
  let r = if r < 0 then 0 else r in
  let x = ref r and y = ref 0 and d = ref (1 - r) in
  while !x >= !y do
    let a = !x and b = !y in
    hline (cx - a) (cx + a) (cy + b); hline (cx - a) (cx + a) (cy - b);
    hline (cx - b) (cx + b) (cy + a); hline (cx - b) (cx + b) (cy - a);
    incr y;
    if !d < 0 then d := !d + 2 * !y + 1
    else begin decr x; d := !d + 2 * (!y - !x) + 1 end
  done
