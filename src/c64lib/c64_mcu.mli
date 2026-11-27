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

(** {1 Microcontroller layer}

    Arduino-like services built on {!Hw.Userport}: GPIO, delays, pulses, SPI,
    serial (UART), I2C and tone generation. Pins are numbered [0..7] = PB0..PB7
    and [8] = PA2 (GPIO only; every other service needs a PB pin). The pins
    have passive pull-ups; the levels are 3.3-5 V CMOS/TTL and the CIA can only
    source/sink a few mA: use buffers for anything but logic signals.

    {b Time.} Durations are in CPU cycles (or us, converted with the video
    standard found in [$02A6], 0 = NTSC / 1 = PAL: 1 us = 1.0227 / 0.9852
    cycles). OCaml integers are 15 bit: a single wait/pulse is at most 16383
    cycles (~16 ms). The loops of the bit-banging services run in assembly;
    calls from OCaml add their own overhead (about 100-300 cycles).

    {b Timers.} {!Time}, {!Pulse} and the receive timeouts use CIA 2 timer B;
    {!Uart} and {!Tone} (PB6) use timer A; [Tone] on PB7 uses timer B.
    [Sound.frame_cycles] uses timer B as well. They are not reentrant and are
    incompatible with {!Hw.Nmi.block}.

    {b Interrupts.} A UART frame is sent/received with interrupts disabled
    (about 1 ms at 9600 baud); there is no buffering, so the sender must wait
    for the receiver. *)

module Hw = C64_hw


(** General purpose I/O. *)
module Gpio : sig
  type mode = Input | Output

  val mode : int -> mode -> unit
  val write : int -> bool -> unit
  val read : int -> bool
  val toggle : int -> unit
  (** All raise [Invalid_argument] on a pin outside [0..8]. [write] only
      changes the latch: set the mode first (the latch of a pin that has
      never been written is 0). *)

  val read_port : unit -> int      (** PB0..PB7 as one byte. *)
  val write_port : int -> unit     (** All 8 latches at once. *)
end

(** Delays and a free running clock. *)
module Time : sig
  val cycles_of_us : int -> int
  (** Microseconds to cycles for the current video standard (no range check:
      the result is only valid up to 16383). *)

  external cycles_of_rate : int -> int = "caml_nonstd_up_cycles_of_rate"
  (** [cycles_of_rate hz]: cycles in a period at [hz] Hz, exactly rounded;
      [-1] if [hz = 0] or the result exceeds 16383 (hz < 61 PAL / 63 NTSC). *)

  external delay_cycles : int -> unit = "caml_nonstd_up_delay"
  (** [delay_cycles n] waits about [n + 45] cycles (0 <= n <= 16383). *)

  val delay_us : int -> unit
  val delay_ms : int -> unit
  (** Long delays are split in chunks of 10 ms; each chunk adds the call
      overhead (a few tenths of per cent). *)

  external clock_start : unit -> unit = "caml_nonstd_up_clock_start"
  (** Starts the clock (timer B, free running). *)

  external clock_ticks : unit -> int = "caml_nonstd_up_clock_read"
  (** Ticks since {!clock_start}: 1 tick = 4 cycles (~4 us); 0..16383, then
      it wraps (~64 ms). *)

  val ticks_per_ms : unit -> int   (** 250 (PAL: 246, NTSC: 256). *)
end

(** Single pulses. [pin] is a PB pin, already an output for [out]. *)
module Pulse : sig
  val out : ?level:bool -> int -> us:int -> unit
  (** [out pin ~us] drives [pin] to [level] (default [true]) for [us] us
      (about 60 us to 16 ms; the fixed overhead is compensated), then to the
      opposite level. *)

  val width : ?level:bool -> ?timeout_ms:int -> int -> int
  (** [width pin] waits for the next complete pulse at [level] (default
      [true]) on the input [pin] and measures its width in us (resolution
      ~12 cycles). Returns [-1] if it does not arrive within [timeout_ms]
      (default 100, max 4000) or lasts more than ~16 ms. *)
end

(** SPI master (bit banged, MSB first). Chip select is up to the caller
    ({!Gpio}). A bit takes about 50-100 cycles (about 10 kHz) at [delay = 0];
    each unit of [delay] adds 10 cycles per bit. *)
module Spi : sig
  type t

  val create : ?sck:int -> ?mosi:int -> ?miso:int -> ?mode:int ->
    ?delay:int -> unit -> t
  (** Defaults: [sck] = PB0, [mosi] = PB1, [miso] = PB2 ([-1]: no input,
      reads return 0), [mode] 0..3 (CPOL * 2 + CPHA), [delay] 0..255.
      Sets the pin directions. @raise Invalid_argument on bad arguments. *)

  val transfer : t -> int -> int
  (** Sends a byte (0..255), returns the byte received. *)

  val write : t -> int -> unit
  val read : t -> int     (** Sends 0xFF. *)

  val transfer_bytes : t -> ?pos:int -> ?len:int -> bytes -> unit
  (** Full duplex, in place: the bytes are replaced by the bytes received.
      @raise Invalid_argument if the range is invalid. *)
end

(** Serial port, 8N1, bit banged with timer A (no flow control, no buffer).
    Best up to 9600 baud. Bytes are sent as they are: a string literal is
    PETSCII (see the BreadCaml preprocessor). *)
module Uart : sig
  type t

  val create : ?tx:int -> ?rx:int -> int -> t
  (** [create baud] with [tx] (default PB2, idle high) and [rx] (default
      PB3). Baud: 250..14000. @raise Invalid_argument on bad arguments. *)

  val write_byte : t -> int -> unit
  val write_string : t -> string -> unit

  val read_byte : ?timeout_ms:int -> t -> int
  (** Waits (default 100 ms, max 4000) for a start bit and returns the byte;
      [-1] on timeout, [-2] on framing error (stop bit low). Characters
      arriving while the CPU is busy elsewhere are lost. *)
end

(** I2C master, bit banged over open drain pins (pin low = driven low,
    high = input): add external pull-ups (4.7k to +5V) for reliable use.
    Slow (a few kHz). Addresses are 7 bit. *)
module I2c : sig
  type t

  val create : ?sda:int -> ?scl:int -> unit -> t   (** Default PB4, PB5. *)

  val start : t -> unit
  val stop : t -> unit
  val write_byte : t -> int -> bool    (** [true] if acknowledged. *)
  val read_byte : t -> ack:bool -> int

  val probe : t -> int -> bool
  (** [probe i2c addr]: a device answers at [addr]. *)

  val write_reg : t -> int -> int -> int -> bool
  (** [write_reg i2c addr reg v]: start, addr+W, reg, v, stop. *)

  val read_reg : t -> int -> int -> int
  (** [read_reg i2c addr reg]: write [reg], repeated start, read one byte;
      [-1] if the device does not answer. *)
end

(** Square wave by hardware: PB6 (timer A) or PB7 (timer B), 8..16383 Hz
    (the resolution is 1 cycle of the half period). *)
module Tone : sig
  val start : ?pin:int -> int -> bool
  (** [start ~pin hz] (pin 6 by default) returns [false] if the arguments
      are invalid. The wave keeps running while the program does something
      else, until {!stop}. *)

  val stop : ?pin:int -> unit -> unit
  (** The pin returns to its port B latch value. *)
end
