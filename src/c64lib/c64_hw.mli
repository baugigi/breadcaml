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

(** Low level hardware access. Nothing here is portable and little is safe. *)


(** Raw memory access.

    Addresses are 16 bit, OCaml ints are 15 bit, so two encodings exist:
    - {b short}: [a] in [0 .. 0x3FFF] is address [a]; [a] in
      [-0x4000 .. -1] is address [a + 0x10000] ([0xC000 .. 0xFFFF]).
      Use [0xD020 - 0x10000] to write [0xD020].
    - {b page}: [peek_at page off] is address [page * 256 + off],
      with [page] and [off] in [0 .. 255]. Reaches the whole 64 KB.

    Values written are masked to 8 bits. Arguments are never validated. *)
module Mem : sig

  val peek : ?ram:bool -> int -> int
  (** [peek a] reads what the CPU sees at [a]. With [~ram:true] it reads
      the RAM under the ROMs/I/O (interrupts disabled during the read). *)

  val peek_at : ?ram:bool -> int -> int -> int
  (** [peek_at page off]: same as {!peek}, page form. *)

  external peek_view : int -> int = "caml_nonstd_hw_peek"
    (** Faster {!peek} (CPU view). *)
  external peek_ram : int -> int = "caml_nonstd_hw_peek_ram"
    (** Faster [peek ~ram:true]. *)
  external peek_at_view : int -> int -> int = "caml_nonstd_hw_peek_at"
  external peek_at_ram : int -> int -> int = "caml_nonstd_hw_peek_at_ram"

  external poke : int -> int -> unit = "caml_nonstd_hw_poke"
  (** [poke a v] writes [v] at [a]. Raises [Invalid_argument] if [a] is
      below the end of the BreadCaml stack (program, heap, stack, zero page
      and system area are protected). *)

  external poke_at : int -> int -> int -> unit = "caml_nonstd_hw_poke_at"
  (** [poke_at page off v]: same as {!poke}, page form. *)

  external unsafe_poke : int -> int -> unit = "caml_nonstd_hw_unsafe_poke"
  (** Like {!poke}, no check at all. *)

  external unsafe_poke_at : int -> int -> int -> unit
    = "caml_nonstd_hw_unsafe_poke_at"

  val fill : int -> int -> int -> unit
  (** [fill a len v] writes [v] (8 bit) in [len] bytes from [a] (short
      form), [0 <= len <= 16383]. Raises [Invalid_argument] like {!poke},
      and if [len] is negative or the range wraps past [0xFFFF]. *)

  external fill_at : int -> int -> int -> int -> unit
    = "caml_nonstd_hw_fill_at"
  (** [fill_at page off len v]: same as {!fill}, page form. *)

  val blit : int -> int -> int -> unit
  (** [blit src dst len] copies [len] bytes from [src] to [dst] (short
      forms); source and destination may overlap. Only [dst] is checked
      (as in {!fill}). *)

  external blit_at : int -> int -> int -> int -> int -> unit
    = "caml_nonstd_hw_blit_at"
  (** [blit_at spage soff dpage doff len]: same as {!blit}, page form. *)

  val unsafe_fill : int -> int -> int -> unit
  external unsafe_fill_at : int -> int -> int -> int -> unit
    = "caml_nonstd_hw_unsafe_fill_at"
  val unsafe_blit : int -> int -> int -> unit
  external unsafe_blit_at : int -> int -> int -> int -> int -> unit
    = "caml_nonstd_hw_unsafe_blit_at"
end

(** Blocking of the non maskable interrupt. *)
module Nmi : sig
  external block : unit -> unit = "caml_nonstd_hw_nmi_block"
  (** Makes NMIs (RESTORE key included) harmless: required before
      [peek ~ram:true] / [peek_at ~ram:true], which switch all ROMs off for a
      few cycles. The state is cleared by {!unblock} or at program exit. *)

  external unblock : unit -> unit = "caml_nonstd_hw_nmi_unblock"
  (** Restores the Kernal NMI vector and re-enables NMIs. *)
end

(** Chip registers. [peek off] / [poke off v] access the register at offset
    [off] from the chip base (0..127); [v] is masked to 8 bits. No checks. *)

(** VIC-II, base [$D000]. *)
module Vic : sig
  external peek : int -> int = "caml_nonstd_hw_vic_peek"
  external poke : int -> int -> unit = "caml_nonstd_hw_vic_poke"
  val mx : int -> int   (** offset of the X position of sprite [n] (0..7) *)
  val my : int -> int   (** offset of the Y position of sprite [n] *)
  val mc : int -> int   (** offset of the color of sprite [n] *)
  val mx8 : int   val cr1 : int    val raster : int  val lpx : int
  val lpy : int   val me : int     val cr2 : int     val mye : int
  val vmcb : int  val irqst : int  val irqen : int   val mdp : int
  val mmc : int   val mxe : int    val mm : int      val md : int
  val ec : int    val b0c : int    val b1c : int     val b2c : int
  val b3c : int   val mm0 : int    val mm1 : int
end

(** SID, base [$D400]. Most registers are write-only. *)
module Sid : sig
  external peek : int -> int = "caml_nonstd_hw_sid_peek"
  external poke : int -> int -> unit = "caml_nonstd_hw_sid_poke"
  val voice : int -> int  (** [voice n]: offset of voice [n] (1..3); add
                              [fl], [fh], [pwl], [pwh], [cr], [ad], [sr]. *)
  val fl : int  val fh : int  val pwl : int  val pwh : int
  val cr : int  val ad : int  val sr : int
  val fcl : int  val fch : int  val resflt : int  val modvol : int
  val potx : int  val poty : int  val osc3 : int  val env3 : int
end

(** Register offsets shared by the two CIAs. *)
module Cia : sig
  val pra : int  val prb : int  val ddra : int  val ddrb : int
  val talo : int  val tahi : int  val tblo : int  val tbhi : int
  val tod10 : int  val todsec : int  val todmin : int  val todhr : int
  val sdr : int  val icr : int  val cra : int  val crb : int
end

(** CIA 1, base [$DC00] (keyboard, joysticks, IRQ). Reading [Cia.icr]
    clears the interrupt flags. *)
module Cia1 : sig
  external peek : int -> int = "caml_nonstd_hw_cia1_peek"
  external poke : int -> int -> unit = "caml_nonstd_hw_cia1_poke"
end

(** CIA 2, base [$DD00] (serial bus, user port, VIC bank, NMI). *)
module Cia2 : sig
  external peek : int -> int = "caml_nonstd_hw_cia2_peek"
  external poke : int -> int -> unit = "caml_nonstd_hw_cia2_poke"
end

(** User port (CIA 2 port B, PA2, /FLAG2). The pins PB0..PB7 are the port B
    bits; PB6 and PB7 can also be driven by the CIA 2 timers (see
    {!Mcu.Tone}). Pin masks are 8 bit (bit [n] = PB[n]); values are masked.
    Direction bits: 1 = output. Reset state: all inputs.

    {b Hardware warning.} The user port is wired DIRECTLY to CIA 2 (a
    6526, no longer made, often soldered, which also drives the IEC bus and
    the VIC bank through port A): there is no buffering, no current limiting
    and no ESD protection. Pins are 5 V TTL/CMOS levels, sink/source only a
    few mA, and must never see a voltage below 0 V or above ~5.25 V. Never
    connect the 9 V AC pins to anything. Read the "User port: hardware
    safety" notes (userport.md) before connecting anything; use series
    resistors, buffers and level shifters, plug only with the power off.

    {b Caveats.} The bit operations ([set_bits], [clear_bits], [toggle_bits],
    [dir_out], [dir_in]) are read-modify-write: [set_bits] etc. read the
    {e pins}, so a heavily loaded output can read back wrong and corrupt the
    other bits. PA2 shares port A with the VIC bank and the serial bus: only
    bit 2 is ever modified. [flag2] reads the CIA 2 interrupt register, which
    clears {e all} its flags and is incompatible with {!Nmi.block}.
    The timing primitives of {!Mcu} use timer B (the tone generator and UART
    use timer A and PB6/PB7): do not mix them with {!Nmi.block} or
    {!Cia2.poke} on the timer registers. *)
module Userport : sig
  external read : unit -> int = "caml_nonstd_up_read"  (** pins PB0..PB7 *)
  external write : int -> unit = "caml_nonstd_up_write"
    (** output latch of port B *)
  external ddr : unit -> int = "caml_nonstd_up_ddr"
    (** direction register *)
  external set_ddr : int -> unit = "caml_nonstd_up_set_ddr"

  external set_bits : int -> unit = "caml_nonstd_up_set"
    (** [PRB <- PRB lor mask] *)
  external clear_bits : int -> unit = "caml_nonstd_up_clear"
    (** [PRB <- PRB land (lnot mask)] *)
  external toggle_bits : int -> unit = "caml_nonstd_up_toggle"
    (** [PRB <- PRB lxor mask] *)
  external dir_out : int -> unit = "caml_nonstd_up_dir_out"
    (** the pins in [mask] become outputs *)
  external dir_in : int -> unit = "caml_nonstd_up_dir_in"
    (** the pins in [mask] become inputs *)

  external pa2_read : unit -> bool = "caml_nonstd_up_pa2_read"
    (** level of PA2 *)
  external pa2_write : bool -> unit = "caml_nonstd_up_pa2_write"
    (** output latch of PA2 *)
  external pa2_output : bool -> unit = "caml_nonstd_up_pa2_dir"
    (** direction of PA2: [true] = output *)

  external flag2 : unit -> bool = "caml_nonstd_up_flag2"
  (** [true] if a negative edge arrived on /FLAG2 since the last read of the
      CIA 2 interrupt register (this call clears all the flags). *)
end

(** Kernal I/O routines (through the jump table), one primitive per
    routine, for the serial bus (disk drives, SD2IEC). Low level: nothing is
    checked and no exception is raised.

    Functions that can fail return the Kernal error code ([0] = no error).
    Most {e DOS} errors (file not found on [open_file], disk full, ...) are
    not reported by the Kernal but by the drive error channel (logical file
    15, secondary address 15) and, partly, by {!readst}.

    Logical file numbers [lfn] are 1..255 and unique among the open files (at
    most 10 files can be open together); [dev] is the device number (8 is the
    first disk drive); [sa] is the secondary address (the drive channel,
    0..15; 255 = none). File names and commands are at most 255 characters
    (longer ones are truncated) and are used in place, so they are read while
    the Kernal runs, with no allocation.

    {b Current channels.} After {!chkin}/{!chkout} the standard input/output
    (keyboard, screen: [print_string], [read_line], {!Key}...) is redirected
    to the file until {!clrchn} is called. Always call {!clrchn} before
    returning to normal I/O. Files are not closed by the end of the program
    (use {!close} or {!clall}); a drive keeps its file open with the LED on.

    Addresses are in the {e page form} [page off] (see {!Mem}): the 16 bit
    address [page * 256 + off] with both values in [0..255]. *)
module Kernal : sig
  external open_file : int -> int -> int -> string -> int
    = "caml_nonstd_kn_open"
  (** [open_file lfn dev sa name] (SETLFS, SETNAM, OPEN). For a disk
      drive [name] is a file name with the DOS modifiers, e.g.
      ["FILE,S,R"], ["@0:FILE,S,W"], or a command if [sa = 15]. *)

  external close : int -> unit = "caml_nonstd_kn_close"  (** [close lfn] *)
  external chkin : int -> int = "caml_nonstd_kn_chkin"
    (** [chkin lfn]: input from [lfn] *)
  external chkout : int -> int = "caml_nonstd_kn_chkout"
    (** [chkout lfn]: output to [lfn] *)
  external clrchn : unit -> unit = "caml_nonstd_kn_clrchn"
    (** restore keyboard and screen *)
  external clall : unit -> unit = "caml_nonstd_kn_clall"
    (** close all files, like [clrchn] *)

  external chrin : unit -> int = "caml_nonstd_kn_chrin"
  (** Read a byte from the current input channel; check {!readst} after
      each byte ({!st_eof} is set while reading the last byte). *)

  external chrout : int -> unit = "caml_nonstd_kn_chrout"
  (** Write a byte to the current output channel. *)

  external readst : unit -> int = "caml_nonstd_kn_readst"
    (** the status byte (ST) *)

  external load_at : int -> int -> string -> int -> int -> int
    = "caml_nonstd_kn_load"
  (** [load_at dev sa name page off] loads a file into memory (LOAD) and
      returns the error code. With [sa = 0] the file is loaded at
      [page * 256 + off]; with [sa <> 0] at the address stored in the first
      two bytes of the file ([page] and [off] are ignored). {b Nothing
      protects the program, the heap or the stack of BreadCaml from being
      overwritten.} The end address (last byte + 1) is then given by
      {!load_end_page} and {!load_end_off}. Kernal messages are
      suppressed. *)

  val load_end_page : unit -> int
  val load_end_off : unit -> int

  external set_range : int -> int -> int -> int -> unit
    = "caml_nonstd_kn_range"
  (** [set_range spage soff epage eoff] sets the memory area to save
      ([\[start, end)]), for {!save_raw}. *)

  external save_raw : int -> string -> int = "caml_nonstd_kn_save"
  (** [save_raw dev name] saves the area set by {!set_range} (SAVE) as a
      program file (the first two bytes are the start address) and returns
      the error code. Kernal messages are suppressed. *)

  val save : dev:int -> string -> int -> int -> int -> int -> int
  (** [save ~dev name spage soff epage eoff]: {!set_range} then
      {!save_raw}. The area is read with the current memory configuration
      (ROMs visible as the CPU sees them). *)

  (** Kernal error codes. *)
  val err_too_many_files : int       val err_file_open : int
  val err_file_not_open : int        val err_file_not_found : int
  val err_device_not_present : int   val err_not_input_file : int
  val err_not_output_file : int      val err_missing_file_name : int
  val err_illegal_device : int

  (** Bits of the status byte. *)
  val st_timeout_write : int  val st_timeout_read : int
  val st_eof : int            val st_device_not_present : int
end

(** Color RAM, base [$D800]: offsets 0..999; [peek] returns the low nybble. *)
module Color : sig
  external peek : int -> int = "caml_nonstd_hw_color_peek"
  external poke : int -> int -> unit = "caml_nonstd_hw_color_poke"
end
