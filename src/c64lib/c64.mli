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
(** Commodore 64 specific modules (BreadCaml only; not in the OCaml standard
    library). They live in the [c64lib] directory of the distribution; link
    them explicitly: [bcamlopt c64lib.cma prog.ml] (same for [bcamlc]). *)

(** Low level hardware access. Nothing here is portable and little is safe. *)
module Hw = C64_hw

(** Keyboard and joysticks. *)
module Key = C64_key

(** 40x25 text screen. [x] is the column (0..39), [y] the row (0..24).
    Direct access functions use {e screen codes} (the values stored in the
    screen RAM), not PETSCII: see {!code_of_char} and {!char_of_code}. *)
module Screen = C64_screen

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
module Gfx = C64_gfx

(** Hardware sprites (VIC-II). Data are copied into the VIC bank: the source
    array or string can be discarded (it becomes garbage) right after
    [define]. A block is 64 bytes; [blk] is the block number in the VIC bank
    (address in the bank = [blk * 64]) and is also the sprite pointer value.
    With [Gfx.bank2] blocks 16..63 are free ($8400-$8FFF; 253..255 too).
    Call [setup] with the same layout given to [Gfx.init] (default [Gfx.bank2]).
    Sprite numbers are 0..7. Sprite pixel (24,50) is the top left of the
    320x200 screen area. *)
module Sprite = C64_sprite

(** SID sound. The SID clock depends on the video standard, so frequencies,
    the lowest and highest pitch change: PAL 985248 Hz (max 3848 Hz),
    NTSC 1022727 Hz (max 3994 Hz), PAL-N 1023440 Hz. Register value
    F = Hz * 2^24 / clock. [init] measures the frame length with a CIA timer
    to detect it (19656 cycles PAL, 17095 NTSC, 16768 old NTSC, 20280 PAL-N; the count is halved to fit 15 bits).
    Voices are numbered 1..3 as in [Hw.Sid.voice]. The SID registers are
    write-only, so [Sound] keeps a shadow copy: do not mix with direct
    [Hw.Sid.poke] on the same registers. *)
module Sound = C64_sound

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
module Mcu = C64_mcu

(** {1 Disk drives and SD2IEC}

    Files, drive commands and directories on the serial bus, built on
    {!Hw.Kernal}. Programs that do not use these modules do not pay for them.

    {b Names and PETSCII.} File names and commands are sent as they are: they
    are PETSCII strings, and BreadCaml translates the string literals to
    PETSCII. A name written in {e lowercase} in the source (["data"]) becomes
    the unshifted letters that you type at the C64 keyboard (and that BASIC
    sends); an {e uppercase} literal (["DATA"]) is a different, shifted name.
    The same holds for the commands: write ["s:data"], not ["S:DATA"].

    {b Devices.} [?dev] is the device number (4..30); the default is
    {!Disk.default_device} (8). Several drives can be used at the same time.

    {b Drive errors.} The Kernal reports only bus errors; DOS errors (file not
    found, disk full...) are read from the drive error channel, which this
    module opens on the first use of each device and keeps open (closing it
    would close all the files of the drive) until the end of the program or
    {!Disk.close_all}. A DOS error code >= 20 raises {!Disk.Dos_error}.

    {b Limits.} At most 8 files are open together. Block counts are [int32]
    (OCaml integers have 15 bits, a drive can report up to 65535). Reading an
    empty file may give one CR. Do not call {!Hw.Kernal.clall} or {!Hw.Kernal.close} on lfn 2..9 and
    32+device behind the back of this module. *)
module Disk = C64_disk

(** Extras of the SD2IEC firmware (and clones: uIEC, ...). Commands that a
    real 1541 does not know raise {!Disk.Dos_error} (code 30..33). Reference:
    the sd2iec README. *)
module Sd2iec = C64_sd2iec
