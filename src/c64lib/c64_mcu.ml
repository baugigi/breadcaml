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

(* ======================================================================== *)
(*                       MICROCONTROLLER LAYER                              *)
(* ======================================================================== *)

module Hw = C64_hw

let bad s = invalid_arg ("C64.Mcu." ^ s)
let pal () = Hw.Mem.peek_view 0x2A6 <> 0
let chk_pb f p = if p < 0 || p > 7 then bad (f ^ ": pin")

module Gpio = struct
  type mode = Input | Output
  let chk p = if p < 0 || p > 8 then bad "Gpio: pin"
  let mode p m =
    chk p;
    if p = 8 then Hw.Userport.pa2_output (match m with Output -> true | Input -> false)
    else (match m with
      | Output -> Hw.Userport.dir_out (1 lsl p)
      | Input -> Hw.Userport.dir_in (1 lsl p))
  let write p v =
    chk p;
    if p = 8 then Hw.Userport.pa2_write v
    else if v then Hw.Userport.set_bits (1 lsl p)
    else Hw.Userport.clear_bits (1 lsl p)
  let read p =
    chk p;
    if p = 8 then Hw.Userport.pa2_read ()
    else (Hw.Userport.read () lsr p) land 1 <> 0
  let toggle p =
    chk p;
    if p = 8 then Hw.Userport.pa2_write (not (Hw.Userport.pa2_read ()))
    else Hw.Userport.toggle_bits (1 lsl p)
  let read_port () = Hw.Userport.read ()
  let write_port v = Hw.Userport.write v
end

module Time = struct
  external delay_cycles : int -> unit = "caml_nonstd_up_delay"
  external clock_start : unit -> unit = "caml_nonstd_up_clock_start"
  external clock_ticks : unit -> int = "caml_nonstd_up_clock_read"
  external cycles_of_rate : int -> int = "caml_nonstd_up_cycles_of_rate"

  (* 1 us = 0.98525 cycles (PAL) / 1.02273 cycles (NTSC) *)
  let cycles_of_us us =
    if pal () then us - (us lsr 6) else us + (us lsr 6) + (us lsr 7)
  (* inverse; may exceed 16383 for c > 16140 (PAL): callers clamp *)
  let us_of_cycles c =
    if pal () then c + (c lsr 6) else c - (c lsr 5) + (c lsr 7)

  let delay_us us =
    if us < 0 then bad "Time.delay_us";
    let r = ref us in
    while !r > 10000 do
      delay_cycles (cycles_of_us 10000);
      r := !r - 10000
    done;
    delay_cycles (cycles_of_us !r)

  let delay_ms ms =
    if ms < 0 then bad "Time.delay_ms";
    let r = ref ms in
    while !r >= 10 do
      delay_us 10000;
      r := !r - 10
    done;
    delay_us (!r * 1000)

  let ticks_per_ms () = if pal () then 246 else 256
end

module Pulse = struct
  external out_raw : int -> int -> int -> unit = "caml_nonstd_up_pulse_out"
  external width_raw : int -> int -> int -> int = "caml_nonstd_up_pulse_width"
  let overhead = 56   (* fixed cycles added by pulse_out *)

  let out ?(level = true) pin ~us =
    chk_pb "Pulse.out" pin;
    let c = Time.cycles_of_us us in
    (* NB: 16383 + overhead would not fit in 15 bits (it wraps to a negative) *)
    if us < 0 || c < 0 || c - overhead > 16383 then bad "Pulse.out: us";
    let c = c - overhead in
    out_raw (1 lsl pin) (if level then 1 else 0) (if c < 0 then 0 else c)

  let width ?(level = true) ?(timeout_ms = 100) pin =
    chk_pb "Pulse.width" pin;
    if timeout_ms < 0 || timeout_ms > 4000 then bad "Pulse.width: timeout";
    let c = width_raw (1 lsl pin) (if level then 1 else 0) (timeout_ms * 4) in
    if c < 0 then -1
    else begin
      let u = Time.us_of_cycles c in
      if u < c then 16383 else u
    end
end

module Spi = struct
  external xfer : int -> int -> int -> int = "caml_nonstd_up_spi_xfer"
  external buf : int -> int -> bytes -> int -> int -> unit
    = "caml_nonstd_up_spi_buf"

  type t = { cfg : int; delay : int }

  let create ?(sck = 0) ?(mosi = 1) ?(miso = 2) ?(mode = 0) ?(delay = 0) () =
    chk_pb "Spi.create" sck;
    chk_pb "Spi.create" mosi;
    if miso < -1 || miso > 7 then bad "Spi.create: miso";
    if mode < 0 || mode > 3 then bad "Spi.create: mode";
    if delay < 0 || delay > 255 then bad "Spi.create: delay";
    Hw.Userport.dir_out ((1 lsl sck) lor (1 lsl mosi));
    if miso >= 0 then Hw.Userport.dir_in (1 lsl miso);
    let m = if miso < 0 then 0 else miso in
    let cfg =
      sck lor (mosi lsl 3) lor (m lsl 6)
      lor ((mode lsr 1) lsl 9) lor ((mode land 1) lsl 10)
      lor (if miso < 0 then 1 lsl 12 else 0) in
    { cfg; delay }

  let transfer t b = xfer t.cfg t.delay (b land 255)
  let write t b = ignore (xfer t.cfg t.delay (b land 255))
  let read t = xfer t.cfg t.delay 255

  let transfer_bytes t ?(pos = 0) ?len b =
    let n = Bytes.length b in
    let len = match len with Some l -> l | None -> n - pos in
    if pos < 0 || len < 0 || pos > n - len then bad "Spi.transfer_bytes";
    buf t.cfg t.delay b pos len
end

module Uart = struct
  external tx : int -> int -> unit = "caml_nonstd_up_uart_tx"
  external rx : int -> int -> int = "caml_nonstd_up_uart_rx"

  type t = { tx_cfg : int; rx_cfg : int }

  let create ?(tx = 2) ?(rx = 3) baud =
    chk_pb "Uart.create" tx;
    chk_pb "Uart.create" rx;
    if baud < 250 || baud > 14000 then bad "Uart.create: baud";
    let cpb = Time.cycles_of_rate baud in
    if cpb < 70 || cpb > 4095 then bad "Uart.create: baud";
    Hw.Userport.set_bits (1 lsl tx);       (* idle = high *)
    Hw.Userport.dir_out (1 lsl tx);
    Hw.Userport.dir_in (1 lsl rx);
    { tx_cfg = tx lor (cpb lsl 3); rx_cfg = rx lor (cpb lsl 3) }

  let write_byte u b = tx u.tx_cfg (b land 255)
  let write_string u s =
    for i = 0 to String.length s - 1 do
      tx u.tx_cfg (Char.code (String.get s i))
    done

  let read_byte ?(timeout_ms = 100) u =
    if timeout_ms < 0 || timeout_ms > 4000 then bad "Uart.read_byte: timeout";
    rx u.rx_cfg (timeout_ms * 4)
end

module I2c = struct
  type t = { sda : int; scl : int }   (* pin masks *)

  let create ?(sda = 4) ?(scl = 5) () =
    chk_pb "I2c.create" sda;
    chk_pb "I2c.create" scl;
    if sda = scl then bad "I2c.create: pins";
    let m = (1 lsl sda) lor (1 lsl scl) in
    Hw.Userport.clear_bits m;       (* latch 0: output = drive low *)
    Hw.Userport.dir_in m;           (* released = high *)
    { sda = 1 lsl sda; scl = 1 lsl scl }

  let low m = Hw.Userport.dir_out m
  let rel m = Hw.Userport.dir_in m
  let level t m = Hw.Userport.read () land m <> 0
  let wait () = Time.delay_cycles 20

  (* release SCL and wait for clock stretching (at most ~ 8 ms) *)
  let scl_high t =
    rel t.scl;
    let n = ref 2000 in
    while not (level t t.scl) && !n > 0 do decr n done

  let start t =
    rel t.sda; scl_high t; wait ();
    low t.sda; wait ();
    low t.scl

  let stop t =
    low t.sda; wait ();
    scl_high t; wait ();
    rel t.sda; wait ()

  let write_byte t b =
    for i = 7 downto 0 do
      if (b lsr i) land 1 <> 0 then rel t.sda else low t.sda;
      wait (); scl_high t; wait (); low t.scl
    done;
    rel t.sda; wait (); scl_high t; wait ();
    let ack = not (level t t.sda) in
    low t.scl;
    ack

  let read_byte t ~ack =
    rel t.sda;
    let v = ref 0 in
    for _i = 0 to 7 do
      wait (); scl_high t; wait ();
      v := (!v lsl 1) lor (if level t t.sda then 1 else 0);
      low t.scl
    done;
    if ack then low t.sda else rel t.sda;
    wait (); scl_high t; wait (); low t.scl;
    rel t.sda;
    !v

  let probe t addr =
    start t;
    let a = write_byte t ((addr lsl 1) land 0xFE) in
    stop t;
    a

  let write_reg t addr reg v =
    start t;
    let ok = write_byte t ((addr lsl 1) land 0xFE)
             && write_byte t reg && write_byte t v in
    stop t;
    ok

  let read_reg t addr reg =
    start t;
    if not (write_byte t ((addr lsl 1) land 0xFE) && write_byte t reg)
    then (stop t; -1)
    else begin
      start t;
      if not (write_byte t (((addr lsl 1) land 0xFE) lor 1))
      then (stop t; -1)
      else begin
        let v = read_byte t ~ack:false in
        stop t;
        v
      end
    end
end

module Tone = struct
  external start_raw : int -> int -> bool = "caml_nonstd_up_tone"
  external stop_raw : int -> unit = "caml_nonstd_up_tone_stop"
  let start ?(pin = 6) hz = start_raw pin hz
  let stop ?(pin = 6) () = stop_raw pin
end
