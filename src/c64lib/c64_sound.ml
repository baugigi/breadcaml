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

(* Out-of-range arguments are saturated to the nearest edge of the interval,
   instead of raising an exception. The annotation avoids the polymorphic
   caml_lessthan/caml_greaterthan. *)
let clamp lo hi (x : int) = if x < lo then lo else if x > hi then hi else x

module Sid = Hw.Sid
type system = Pal | Ntsc | Pal_n
type source = Osc3 | Env3
type dest = Freq of int | Pw of int | Cutoff | Volume | Resonance

external frame_cycles : unit -> int = "caml_nonstd_snd_frame_cycles"
external wait_frame : unit -> unit = "caml_nonstd_snd_wait_frame"

let tri = 0x10 and saw = 0x20 and pulse = 0x40 and noise = 0x80

let system_of_cycles c =
  (* c is half the frame cycles: PAL-N 10140, PAL 9828, NTSC 8547 *)
  if c >= 10000 then Pal_n else if c >= 9000 then Pal else Ntsc
let detect () = system_of_cycles (frame_cycles ())
let sys = ref Pal
let system () = !sys
let set_system s = sys := s

(* clock / 128, and a few derived figures (ints are only 15 bit) *)
let c2 () = match !sys with Pal -> 7697 | Ntsc -> 7990 | Pal_n -> 7996
let clock_khz () = match !sys with Pal -> 985 | Ntsc -> 1023 | Pal_n -> 1023
let max_hz () = match !sys with Pal -> 3848 | Ntsc -> 3994 | Pal_n -> 3997
let min_mhz () = match !sys with Pal -> 58 | Ntsc -> 60 | Pal_n -> 61

(* octave 6 (C6..B6) SID values, high and low byte *)
let pal_h = [| 69;73;78;82;87;92;98;104;110;117;124;131 |]
let pal_l = [| 156;192;35;200;180;235;114;76;128;18;8;104 |]
let ntsc_h = [| 67;71;75;79;84;89;94;100;106;112;119;126 |]
let ntsc_l = [| 15;12;70;191;125;132;214;122;115;200;125;151 |]
let paln_h = [| 67;70;75;79;84;89;94;100;106;112;119;126 |]
let paln_l = [| 3;255;56;177;110;116;197;104;96;180;103;129 |]

let sh = Array.make 32 0
let shadow r = sh.(r)
let w r v = sh.(r) <- v; Sid.poke r v

let vb v = Sid.voice (clamp 1 3 v)

let rh = ref 0 and rl = ref 0   (* result of the frequency computations *)

let note_regs n =
  let n = clamp 0 95 n in
  let o = n / 12 and k = n mod 12 in
  let th, tl = match !sys with
    | Pal -> pal_h, pal_l | Ntsc -> ntsc_h, ntsc_l | Pal_n -> paln_h, paln_l in
  rh := th.(k); rl := tl.(k);
  if o <= 6 then
    for _ = 1 to 6 - o do
      rl := (!rl lsr 1) lor ((!rh land 1) lsl 7);
      rh := !rh lsr 1
    done
  else begin
    let h = (!rh lsl 1) lor (!rl lsr 7) in
    if h > 255 then (rh := 255; rl := 255)
    else (rh := h; rl := (!rl lsl 1) land 255)
  end

(* F = hz * 2^17 / (clock/128), 17 fractional bits of hz / c2 *)
let hz_regs hz =
  let hz = clamp 0 (max_hz ()) hz in
  let c = c2 () in
  let r = ref hz and qh = ref 0 and ql = ref 0 in
  for _ = 1 to 17 do
    r := !r * 2;
    qh := (!qh lsl 1) lor (!ql lsr 7);
    ql := (!ql lsl 1) land 255;
    if !r >= c then (r := !r - c; ql := !ql lor 1)
  done;
  if !qh > 255 then (rh := 255; rl := 255) else (rh := !qh; rl := !ql)

(* quarter units: F / 4, in 0..16383 *)
let f4_of_hz hz =
  let hz = clamp 0 (max_hz ()) hz in
  let c = c2 () in
  let r = ref hz and q = ref 0 in
  for _ = 1 to 15 do
    r := !r * 2; q := !q * 2;
    if !r >= c then (r := !r - c; q := !q + 1)
  done;
  if !q > 16383 then 16383 else !q

let freq_raw v ~hi ~lo =
  let b = vb v in w b (lo land 255); w (b + 1) (hi land 255)
let freq_hz v hz = hz_regs hz; freq_raw v ~hi:!rh ~lo:!rl
let note v n = note_regs n; freq_raw v ~hi:!rh ~lo:!rl
let freq_f4 v q =
  freq_raw v ~hi:((q lsr 6) land 255) ~lo:((q land 63) lsl 2)

let ctl v mask b =
  let r = vb v + 4 in
  w r (if b then sh.(r) lor mask else sh.(r) land (lnot mask))
let gate v b = ctl v 1 b
let sync v b = ctl v 2 b
let ring v b = ctl v 4 b
let test v b = ctl v 8 b
let waveform v wf =
  let r = vb v + 4 in w r ((sh.(r) land 0x0F) lor (wf land 0xF0))

let adsr v ~a ~d ~s ~r =
  let b = vb v in
  w (b + 5) (((a land 15) lsl 4) lor (d land 15));
  w (b + 6) (((s land 15) lsl 4) lor (r land 15))
let pulse_width v p =
  let b = vb v in w (b + 2) (p land 255); w (b + 3) ((p lsr 8) land 15)

let cutoff c = w Sid.fcl (c land 7); w Sid.fch ((c lsr 3) land 255)
let resonance r = w Sid.resflt ((sh.(Sid.resflt) land 0x0F) lor ((r land 15) lsl 4))
(* voice 1..3, or 4 for the external input *)
let route v b =
  let v = clamp 1 4 v in
  let m = 1 lsl (v - 1) in
  w Sid.resflt (if b then sh.(Sid.resflt) lor m else sh.(Sid.resflt) land (lnot m))
let filter_mode ~lp ~bp ~hp =
  let v = sh.(Sid.modvol) land 0x8F in
  w Sid.modvol (v lor (if lp then 0x10 else 0) lor (if bp then 0x20 else 0)
                lor (if hp then 0x40 else 0))
let mute_voice3 b =
  let v = sh.(Sid.modvol) in
  w Sid.modvol (if b then v lor 0x80 else v land 0x7F)
let volume n = w Sid.modvol ((sh.(Sid.modvol) land 0xF0) lor (n land 15))

let pot_x () = Sid.peek Sid.potx
let pot_y () = Sid.peek Sid.poty

let silence () =
  for v = 1 to 3 do gate v false done; volume 0

let init ?(detect_clock = true) () =
  for r = 0 to 0x18 do w r 0 done;
  if detect_clock then sys := detect ();
  volume 15

let play v n = note v n; gate v true
let stop v = gate v false

(* ---- OSC3 / ENV3: voice 3 as a free LFO / random source ---- *)
let lfo ?(wave = tri) f =
  let f = clamp 0 16383 f in
  freq_raw 3 ~hi:(f lsr 8) ~lo:(f land 255);
  w (vb 3 + 4) (wave land 0xF0);   (* control reg of voice 3, gate off *)
  mute_voice3 true
let lfo_raw ?(wave = tri) ~hi ~lo () =
  freq_raw 3 ~hi ~lo; w (vb 3 + 4) (wave land 0xF0); mute_voice3 true
let random_init () = lfo_raw ~wave:noise ~hi:255 ~lo:255 ()
let sample = function Osc3 -> Sid.peek Sid.osc3 | Env3 -> Sid.peek Sid.env3
let random () = Sid.peek Sid.osc3

(* s in -128..127, d any int in +-16383: s * d / 128 without overflow *)
let scale s d = s * (d asr 7) + ((s * (d land 127)) asr 7)

let modulate src dst ~base ~depth =
  let d = scale (sample src - 128) depth in
  let x = base + d in
  match dst with
  | Freq v -> freq_f4 v (clamp 0 16383 x)
  | Pw v -> pulse_width v (clamp 0 4095 x)
  | Cutoff -> cutoff (clamp 0 2047 x)
  | Volume -> volume (clamp 0 15 x)
  | Resonance -> resonance (clamp 0 15 x)
