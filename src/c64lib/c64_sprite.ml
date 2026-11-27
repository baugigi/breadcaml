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
module Gfx = C64_gfx

(* Out-of-range arguments are saturated to the nearest edge of the interval,
   instead of raising an exception. The annotation avoids the polymorphic
   caml_lessthan/caml_greaterthan. *)
let clamp lo hi (x : int) = if x < lo then lo else if x > hi then hi else x

let lay = ref Gfx.bank2
let setup l = lay := l
let layout () = !lay

let ptr_page () = !lay.Gfx.bank * 64 + (!lay.Gfx.screen lsr 8) + 3
let sn n = clamp 0 7 n

let setb reg n b =
  let v = Hw.Vic.peek reg in
  Hw.Vic.poke reg (if b then v lor (1 lsl n) else v land (lnot (1 lsl n)))

let page blk = !lay.Gfx.bank * 64 + (blk lsr 2)
let off blk = (blk land 3) * 64

let define blk data =
  if Array.length data < 63 then
    invalid_arg "C64.Sprite.define";
  let blk = clamp 0 255 blk in
  let p = page blk and o = off blk in
  for i = 0 to 62 do Hw.Mem.poke_at p (o + i) (data.(i) land 255) done

let define_string blk s =
  if String.length s < 63 then
    invalid_arg "C64.Sprite.define_string";
  let blk = clamp 0 255 blk in
  let p = page blk and o = off blk in
  for i = 0 to 62 do Hw.Mem.poke_at p (o + i) (Char.code s.[i]) done

(* 21 rows of 24 chars; any char other than ' ' and '.' sets the pixel *)
let define_art blk rows =
  if Array.length rows < 21 then
    invalid_arg "C64.Sprite.define_art";
  let blk = clamp 0 255 blk in
  let p = page blk and o = off blk in
  for r = 0 to 20 do
    let row = rows.(r) in
    for b = 0 to 2 do
      let v = ref 0 in
      for i = 0 to 7 do
        let k = b * 8 + i in
        let on = k < String.length row && row.[k] <> ' ' && row.[k] <> '.' in
        v := (!v lsl 1) lor (if on then 1 else 0)
      done;
      Hw.Mem.poke_at p (o + r * 3 + b) !v
    done
  done

(* multicolor: 21 rows of 12 chars '0'..'3' (pen of each double pixel) *)
let define_art_mc blk rows =
  if Array.length rows < 21 then
    invalid_arg "C64.Sprite.define_art_mc";
  let blk = clamp 0 255 blk in
  let p = page blk and o = off blk in
  for r = 0 to 20 do
    let row = rows.(r) in
    for b = 0 to 2 do
      let v = ref 0 in
      for i = 0 to 3 do
        let k = b * 4 + i in
        let c = if k < String.length row then Char.code row.[k] - 48 else 0 in
        v := (!v lsl 2) lor (c land 3)
      done;
      Hw.Mem.poke_at p (o + r * 3 + b) !v
    done
  done

let assign n blk = Hw.Mem.poke_at (ptr_page ()) (0xF8 + sn n) blk

(* VIC registers: $15 enable, $1C multicolor, $1D expand x, $17 expand y,
   $1B priority, $27+n color, $25/$26 shared colors, $10 x bit 8 *)
let enable n b = setb 0x15 (sn n) b
let multicolor n b = setb 0x1C (sn n) b
let expand_x n b = setb 0x1D (sn n) b
let expand_y n b = setb 0x17 (sn n) b
let behind n b = setb 0x1B (sn n) b
let color n c = Hw.Vic.poke (0x27 + sn n) c
let mcolors c1 c2 = Hw.Vic.poke 0x25 c1; Hw.Vic.poke 0x26 c2

let pos n x y =
  let n = sn n and x = clamp 0 511 x in
  Hw.Vic.poke (2 * n) (x land 255);
  setb 0x10 n (x > 255);
  Hw.Vic.poke (2 * n + 1) (y land 255)

let move n x y = pos n (x + 24) (y + 50)

let hit_sprites () = Hw.Vic.peek 0x1E
let hit_background () = Hw.Vic.peek 0x1F
