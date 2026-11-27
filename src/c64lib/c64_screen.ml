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

let cols = 40
let rows = 25

(* Out-of-range coordinates are saturated by the primitives: no check here *)
external get : int -> int -> int = "caml_nonstd_scr_peek"
external put : int -> int -> int -> unit = "caml_nonstd_scr_poke"
external get_color : int -> int -> int = "caml_nonstd_scr_color_peek"
external put_color : int -> int -> int -> unit = "caml_nonstd_scr_color_poke"
external locate : int -> int -> unit = "caml_nonstd_scr_locate"
external cursor_pos : unit -> int = "caml_nonstd_scr_cursor"
external code_of_char : char -> int = "caml_nonstd_scr_code_of_char"
external char_of_code : int -> char = "caml_nonstd_scr_char_of_code"

let cursor () = let p = cursor_pos () in (p land 255, p lsr 8)

let clear () = print_char '\147'
let home () = print_char '\019'
let reverse b = print_char (if b then '\018' else '\146')
let lower_case b = print_char (if b then '\014' else '\142')
let text_color c = Hw.Mem.unsafe_poke 646 c
let border c = Hw.Vic.poke 0x20 c
let background c = Hw.Vic.poke 0x21 c

let put_char x y c = put x y (code_of_char c)
let get_char x y = char_of_code (get x y)

let print_at ?color x y s =
  let n = String.length s in
  let first = if x < 0 then - x else 0
  and last = if x + n > 40 then 39 - x else n - 1 in
  for i = first to last do
    let xx = x + i in
    put xx y (code_of_char (String.unsafe_get s i));
    match color with
      Some c -> put_color xx y c
    | None -> ()
  done

let page () = Hw.Mem.peek_view 648
let fill code = Hw.Mem.unsafe_fill_at (page ()) 0 1000 code
let fill_color c = Hw.Mem.unsafe_fill_at 0xD8 0 1000 c

let scroll_up ?(color = false) () =
  let p = page () in
  Hw.Mem.unsafe_blit_at p 40 p 0 960;
  Hw.Mem.unsafe_fill_at (p + 3) 192 40 32;
  if color then Hw.Mem.unsafe_blit_at 0xD8 40 0xD8 0 960

let scroll_down ?(color = false) () =
  let p = page () in
  Hw.Mem.unsafe_blit_at p 0 p 40 960;
  Hw.Mem.unsafe_fill_at p 0 40 32;
  if color then Hw.Mem.unsafe_blit_at 0xD8 0 0xD8 40 960
