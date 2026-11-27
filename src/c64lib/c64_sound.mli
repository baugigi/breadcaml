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

(** SID sound. The SID clock depends on the video standard, so frequencies,
    the lowest and highest pitch change: PAL 985248 Hz (max 3848 Hz),
    NTSC 1022727 Hz (max 3994 Hz), PAL-N 1023440 Hz. Register value
    F = Hz * 2^24 / clock. [init] measures the frame length with a CIA timer
    to detect it (19656 cycles PAL, 17095 NTSC, 16768 old NTSC, 20280 PAL-N; the count is halved to fit 15 bits).
    Voices are numbered 1..3 as in [Hw.Sid.voice]. The SID registers are
    write-only, so [Sound] keeps a shadow copy: do not mix with direct
    [Hw.Sid.poke] on the same registers. *)

module Hw = C64_hw

type system = Pal | Ntsc | Pal_n

external frame_cycles : unit -> int = "caml_nonstd_snd_frame_cycles"
(** Half the cycles of one video frame (a full count, up to 20280, would
    not fit an OCaml 15-bit integer): PAL 9828, NTSC 8547, old NTSC 8384,
    PAL-N 10140. IRQs are masked ~3 frames while measuring. *)

val system_of_cycles : int -> system
val detect : unit -> system
val system : unit -> system
val set_system : system -> unit
val clock_khz : unit -> int
val max_hz : unit -> int      (** Highest frequency (F = 65535). *)
val min_mhz : unit -> int     (** Lowest frequency (F = 1), in millihertz. *)

val init : ?detect_clock:bool -> unit -> unit
(** Clears the SID, volume 15, detects the clock (default). *)

external wait_frame : unit -> unit = "caml_nonstd_snd_wait_frame"
  (** Waits for raster line 248. *)

(** {2 Voices} *)

val tri : int  val saw : int  val pulse : int  val noise : int
(** Waveform bits, combinable with [lor]. *)

val waveform : int -> int -> unit
val gate : int -> bool -> unit
val sync : int -> bool -> unit   (** Hard sync with the previous voice. *)
val ring : int -> bool -> unit   (** Ring modulation (needs [tri]). *)
val test : int -> bool -> unit   (** Test bit: holds/resets the oscillator. *)
val adsr : int -> a:int -> d:int -> s:int -> r:int -> unit  (** 0..15 each. *)
val pulse_width : int -> int -> unit  (** 0..4095. *)

val freq_raw : int -> hi:int -> lo:int -> unit
val freq_hz : int -> int -> unit  (** Integer Hz, 0..[max_hz]. *)
val note : int -> int -> unit
(** [note v n]: [n] = semitones above C0 (0..95; A4 = 57), equal
    temperament; notes above the SID range saturate. *)
val freq_f4 : int -> int -> unit  (** F/4 as one int (0..16383). *)
val f4_of_hz : int -> int

val play : int -> int -> unit     (** [note] then [gate]. *)
val stop : int -> unit            (** Gate off (release). *)
val silence : unit -> unit

(** {2 Filter and volume} *)

val cutoff : int -> unit          (** 0..2047. *)
val resonance : int -> unit       (** 0..15. *)
val route : int -> bool -> unit   (** Voice 1..3, or 4 = external input. *)
val filter_mode : lp:bool -> bp:bool -> hp:bool -> unit
val mute_voice3 : bool -> unit
val volume : int -> unit          (** 0..15. *)
val pot_x : unit -> int
val pot_y : unit -> int
val shadow : int -> int           (** Last value written to a register. *)

(** {2 Modulation with voice 3 (OSC3 / ENV3)}

    Voice 3 can run silently as an LFO: its waveform output (OSC3) and
    envelope (ENV3) are readable. [modulate] samples it once and writes
    the target register; call it repeatedly (e.g. once per [wait_frame]). *)

type source = Osc3 | Env3
type dest =
  | Freq of int   (** voice; value unit is F/4 (see [f4_of_hz]) *)
  | Pw of int     (** voice; 0..4095 *)
  | Cutoff | Volume | Resonance

val lfo : ?wave:int -> int -> unit
(** [lfo ~wave f]: voice 3 at register value [f] (0..16383), muted from
    the output. About [f * 0.0587] Hz on PAL. *)

val lfo_raw : ?wave:int -> hi:int -> lo:int -> unit -> unit
val random_init : unit -> unit  (** Voice 3 noise at full speed. *)
val random : unit -> int        (** OSC3 as a random byte. *)
val sample : source -> int

val modulate : source -> dest -> base:int -> depth:int -> unit
(** Writes [base + (sample - 128) * depth / 128] (clamped to the range of
    [dest]). [depth] in -16383..16383. *)
