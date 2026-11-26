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
module Hw : sig

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

    val peek_view : int -> int   (** Faster {!peek} (CPU view). *)
    val peek_ram : int -> int    (** Faster [peek ~ram:true]. *)
    val peek_at_view : int -> int -> int
    val peek_at_ram : int -> int -> int

    val poke : int -> int -> unit
    (** [poke a v] writes [v] at [a]. Raises [Invalid_argument] if [a] is
        below the end of the BreadCaml stack (program, heap, stack, zero page
        and system area are protected). *)

    val poke_at : int -> int -> int -> unit
    (** [poke_at page off v]: same as {!poke}, page form. *)

    val unsafe_poke : int -> int -> unit
    (** Like {!poke}, no check at all. *)

    val unsafe_poke_at : int -> int -> int -> unit

    val fill : int -> int -> int -> unit
    (** [fill a len v] writes [v] (8 bit) in [len] bytes from [a] (short
        form), [0 <= len <= 16383]. Raises [Invalid_argument] like {!poke},
        and if [len] is negative or the range wraps past [0xFFFF]. *)

    val fill_at : int -> int -> int -> int -> unit
    (** [fill_at page off len v]: same as {!fill}, page form. *)

    val blit : int -> int -> int -> unit
    (** [blit src dst len] copies [len] bytes from [src] to [dst] (short
        forms); source and destination may overlap. Only [dst] is checked
        (as in {!fill}). *)

    val blit_at : int -> int -> int -> int -> int -> unit
    (** [blit_at spage soff dpage doff len]: same as {!blit}, page form. *)

    val unsafe_fill : int -> int -> int -> unit
    val unsafe_fill_at : int -> int -> int -> int -> unit
    val unsafe_blit : int -> int -> int -> unit
    val unsafe_blit_at : int -> int -> int -> int -> int -> unit
  end

  (** Blocking of the non maskable interrupt. *)
  module Nmi : sig
    val block : unit -> unit
    (** Makes NMIs (RESTORE key included) harmless: required before
        [peek ~ram:true] / [peek_at ~ram:true], which switch all ROMs off for a
        few cycles. The state is cleared by {!unblock} or at program exit. *)

    val unblock : unit -> unit
    (** Restores the Kernal NMI vector and re-enables NMIs. *)
  end

  (** Chip registers. [peek off] / [poke off v] access the register at offset
      [off] from the chip base (0..127); [v] is masked to 8 bits. No checks. *)

  (** VIC-II, base [$D000]. *)
  module Vic : sig
    val peek : int -> int
    val poke : int -> int -> unit
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
    val peek : int -> int
    val poke : int -> int -> unit
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
    val peek : int -> int
    val poke : int -> int -> unit
  end

  (** CIA 2, base [$DD00] (serial bus, user port, VIC bank, NMI). *)
  module Cia2 : sig
    val peek : int -> int
    val poke : int -> int -> unit
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
    val read : unit -> int          (** pins PB0..PB7 *)
    val write : int -> unit         (** output latch of port B *)
    val ddr : unit -> int           (** direction register *)
    val set_ddr : int -> unit

    val set_bits : int -> unit      (** [PRB <- PRB lor mask] *)
    val clear_bits : int -> unit    (** [PRB <- PRB land (lnot mask)] *)
    val toggle_bits : int -> unit   (** [PRB <- PRB lxor mask] *)
    val dir_out : int -> unit       (** the pins in [mask] become outputs *)
    val dir_in : int -> unit        (** the pins in [mask] become inputs *)

    val pa2_read : unit -> bool     (** level of PA2 *)
    val pa2_write : bool -> unit    (** output latch of PA2 *)
    val pa2_output : bool -> unit   (** direction of PA2: [true] = output *)

    val flag2 : unit -> bool
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
    val open_file : int -> int -> int -> string -> int
    (** [open_file lfn dev sa name] (SETLFS, SETNAM, OPEN). For a disk
        drive [name] is a file name with the DOS modifiers, e.g.
        ["FILE,S,R"], ["@0:FILE,S,W"], or a command if [sa = 15]. *)

    val close : int -> unit               (** [close lfn] *)
    val chkin : int -> int                (** [chkin lfn]: input from [lfn] *)
    val chkout : int -> int               (** [chkout lfn]: output to [lfn] *)
    val clrchn : unit -> unit             (** restore keyboard and screen *)
    val clall : unit -> unit              (** close all files, like [clrchn] *)

    val chrin : unit -> int
    (** Read a byte from the current input channel; check {!readst} after
        each byte ({!st_eof} is set while reading the last byte). *)

    val chrout : int -> unit
    (** Write a byte to the current output channel. *)

    val readst : unit -> int              (** the status byte (ST) *)

    val load_at : int -> int -> string -> int -> int -> int
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

    val set_range : int -> int -> int -> int -> unit
    (** [set_range spage soff epage eoff] sets the memory area to save
        ([\[start, end)]), for {!save_raw}. *)

    val save_raw : int -> string -> int
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
    val peek : int -> int
    val poke : int -> int -> unit
  end
end

(** Keyboard and joysticks. *)
module Key : sig
  val get : unit -> char
  (** The next key from the keyboard buffer (a PETSCII code, as returned by
      the Kernal), or ['\000'] if no key is waiting. Never blocks. *)

  val wait : unit -> char
  (** Waits for a key and returns it. No echo, no cursor. *)

  val joy : int -> int
  (** [joy port] (port 1 or 2) returns a bit mask: {!joy_up}, {!joy_down},
      {!joy_left}, {!joy_right}, {!joy_fire}; a bit is set when the
      corresponding switch is closed. Reading port 1 briefly interferes with
      the keyboard scan. *)

  val joy_up : int  val joy_down : int  val joy_left : int
  val joy_right : int  val joy_fire : int
end

(** 40x25 text screen. [x] is the column (0..39), [y] the row (0..24).
    Direct access functions use {e screen codes} (the values stored in the
    screen RAM), not PETSCII: see {!code_of_char} and {!char_of_code}.
    Functions without [unsafe_] raise [Invalid_argument] when the coordinates
    are out of range. *)
module Screen : sig
  val cols : int
  val rows : int

  (** {2 Through the Kernal (PETSCII)} *)

  val clear : unit -> unit            (** Clears the screen, cursor at home. *)
  val home : unit -> unit             (** Cursor at the top left corner. *)
  val locate : int -> int -> unit     (** [locate x y] moves the cursor. *)
  val cursor : unit -> int * int      (** Cursor position [(x, y)]. *)
  val reverse : bool -> unit          (** Reverse video on/off for printing. *)
  val lower_case : bool -> unit
  (** [lower_case true] selects the upper/lower case character set,
      [false] the upper case/graphics one. *)

  val text_color : int -> unit        (** Color (0..15) for printing. *)
  val border : int -> unit            (** Border color. *)
  val background : int -> unit        (** Background color. *)

  (** {2 Direct access (screen codes)} *)

  val get : int -> int -> int
  val put : int -> int -> int -> unit
  (** [put x y code] stores the screen code [code] (0..255). *)

  val unsafe_get : int -> int -> int
  val unsafe_put : int -> int -> int -> unit

  val get_color : int -> int -> int
  val put_color : int -> int -> int -> unit
  (** Color RAM, colors 0..15; reading returns the low nybble. *)

  val unsafe_get_color : int -> int -> int
  val unsafe_put_color : int -> int -> int -> unit

  val code_of_char : char -> int
  (** Screen code of a PETSCII character. Control codes ([0x00-0x1F],
      [0x80-0x9F]) give the space code ([0x20]). *)

  val char_of_code : int -> char
  (** PETSCII character for a screen code (the reverse video bit is ignored). *)

  val put_char : int -> int -> char -> unit
  (** [put_char x y c] is [put x y (code_of_char c)]. *)

  val get_char : int -> int -> char

  val print_at : ?color:int -> int -> int -> string -> unit
  (** [print_at ?color x y s] writes [s] directly in the screen RAM, from
      column [x] of row [y]; characters beyond column 39 are dropped. With
      [~color] the color RAM is set too. The cursor does not move. *)

  val fill : int -> unit              (** Fills the whole screen with a code. *)
  val fill_color : int -> unit        (** Fills the whole color RAM. *)

  val scroll_up : ?color:bool -> unit -> unit
  (** Scrolls the screen one row up (the last row is filled with spaces);
      with [~color:true] the color RAM scrolls too. *)

  val scroll_down : ?color:bool -> unit -> unit
end


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
module Gfx : sig
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

  val plot : int -> int -> unit
  (** Pixel with the current pen; silently clipped. *)

  val point : int -> int -> int
  (** Pen value of the pixel, or [-1] if outside. *)

  val line : int -> int -> int -> int -> unit
  (** [line x1 y1 x2 y2]: Bresenham line, clipped. Fully visible lines use a
      self-modifying fast loop. *)

  val window : int -> int -> int -> int -> unit
  (** [window x0 y0 x1 y1] defines virtual coordinates: [(x0,y0)] maps to the
      top left pixel and [(x1,y1)] to the bottom right one (spans may be
      reversed, giving flipped axes; coordinates are saturated to +-16383).
      Must be called after [init]. @raise Invalid_argument if a span is < 2. *)

  val unwindow : unit -> unit  (** Back to physical coordinates. *)

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
  (** [circle cx cy r]: midpoint algorithm. @raise Invalid_argument if [r < 0]. *)
  val fill_circle : int -> int -> int -> unit
end

(** Hardware sprites (VIC-II). Data are copied into the VIC bank: the source
    array or string can be discarded (it becomes garbage) right after
    [define]. A block is 64 bytes; [blk] is the block number in the VIC bank
    (address in the bank = [blk * 64]) and is also the sprite pointer value.
    With [Gfx.bank2] blocks 16..63 are free ($8400-$8FFF; 253..255 too).
    Call [setup] with the same layout given to [Gfx.init] (default [Gfx.bank2]).
    Sprite numbers are 0..7. Sprite pixel (24,50) is the top left of the
    320x200 screen area. *)
module Sprite : sig
  val setup : Gfx.layout -> unit
  val layout : unit -> Gfx.layout

  val define : int -> int array -> unit
  (** [define blk a]: copies [a.(0..62)] (bytes; 3 per row, 21 rows). *)

  val define_string : int -> string -> unit
  (** Same, from the first 63 characters of a string. *)

  val define_art : int -> string array -> unit
  (** [define_art blk rows]: 21 rows of 24 characters; ' ' and '.' are empty
      pixels, any other character sets it. *)

  val define_art_mc : int -> string array -> unit
  (** Multicolor: 21 rows of 12 characters ['0'..'3'] (pen of each double
      pixel: 0 transparent, 1 and 3 = [mcolors], 2 = [color]). *)

  val assign : int -> int -> unit
  (** [assign n blk]: sprite [n] shows block [blk]. *)

  val enable : int -> bool -> unit
  val pos : int -> int -> int -> unit
  (** [pos n x y]: raw VIC coordinates, [x] in 0..511. *)

  val move : int -> int -> int -> unit
  (** [move n x y] = [pos n (x+24) (y+50)] (screen pixel coordinates). *)

  val color : int -> int -> unit
  val mcolors : int -> int -> unit  (** The two shared multicolor colors. *)
  val multicolor : int -> bool -> unit
  val expand_x : int -> bool -> unit
  val expand_y : int -> bool -> unit
  val behind : int -> bool -> unit  (** Priority: behind the foreground. *)

  val hit_sprites : unit -> int
  (** Sprite-sprite collision bits ($D01E); reading clears them. *)

  val hit_background : unit -> int
  (** Sprite-background collision bits ($D01F); reading clears them. *)
end

(** SID sound. The SID clock depends on the video standard, so frequencies,
    the lowest and highest pitch change: PAL 985248 Hz (max 3848 Hz),
    NTSC 1022727 Hz (max 3994 Hz), PAL-N 1023440 Hz. Register value
    F = Hz * 2^24 / clock. [init] measures the frame length with a CIA timer
    to detect it (19656 cycles PAL, 17095 NTSC, 16768 old NTSC, 20280 PAL-N).
    Voices are numbered 1..3 as in [Hw.Sid.voice]. The SID registers are
    write-only, so [Sound] keeps a shadow copy: do not mix with direct
    [Hw.Sid.poke] on the same registers. *)
module Sound : sig
  type system = Pal | Ntsc | Pal_n

  val frame_cycles : unit -> int
  (** Cycles of one video frame (IRQs are masked ~3 frames while measuring). *)

  val system_of_cycles : int -> system
  val detect : unit -> system
  val system : unit -> system
  val set_system : system -> unit
  val clock_khz : unit -> int
  val max_hz : unit -> int      (** Highest frequency (F = 65535). *)
  val min_mhz : unit -> int     (** Lowest frequency (F = 1), in millihertz. *)

  val init : ?detect_clock:bool -> unit -> unit
  (** Clears the SID, volume 15, detects the clock (default). *)

  val wait_frame : unit -> unit  (** Waits for raster line 248. *)

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
end

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
module Mcu : sig

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

    val cycles_of_rate : int -> int
    (** [cycles_of_rate hz]: cycles in a period at [hz] Hz, exactly rounded;
        [-1] if [hz = 0] or the result exceeds 16383 (hz < 61 PAL / 63 NTSC). *)

    val delay_cycles : int -> unit
    (** [delay_cycles n] waits about [n + 45] cycles (0 <= n <= 16383). *)

    val delay_us : int -> unit
    val delay_ms : int -> unit
    (** Long delays are split in chunks of 10 ms; each chunk adds the call
        overhead (a few tenths of per cent). *)

    val clock_start : unit -> unit
    (** Starts the clock (timer B, free running). *)

    val clock_ticks : unit -> int
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
end

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
module Disk : sig

  exception Kernal_error of int
  (** A Kernal error code ({!Hw.Kernal.err_file_not_found}...); 5 = device
      not present. *)

  exception Status_error of int
  (** A serial bus error: the status byte (ST) of the failed transfer. *)

  exception Dos_error of int * string
  (** [Dos_error (code, message)]: error reported by the drive, e.g.
      [(62, "FILE NOT FOUND")]. The message is in PETSCII (uppercase). *)

  val default_device : int ref

  val close_all : unit -> unit
  (** Closes all the files and the command channels (also done at exit). *)

  (** {2 Command channel} *)

  type status = { code : int; message : string; track : int; sector : int }
  (** The reply ["nn,MESSAGE,tt,ss"] of the drive. [code] < 20 is not an
      error ([0] = OK, [1] = files scratched: [track] is the count). *)

  val status : ?dev:int -> unit -> status
  (** Reads the error channel (and clears the error). *)

  val command : ?dev:int -> string -> status
  (** [command cmd] sends a DOS command and returns the resulting status;
      raises {!Dos_error} if [code >= 20]. *)

  val raw_command : ?dev:int -> string -> status
  (** As {!command}, without raising {!Dos_error}. *)

  val command_read : ?dev:int -> string -> int -> string
  (** [command_read cmd maxlen] sends [cmd] and reads the binary answer: up
      to [maxlen] bytes, up to the end of the message. *)

  val scratch : ?dev:int -> string -> int
  (** [scratch name]: deletes the file(s) (wildcards allowed); returns how
      many were deleted. *)

  val rename : ?dev:int -> src:string -> string -> unit
  (** [rename ~src dst] *)

  val copy : ?dev:int -> src:string -> string -> unit
  (** [copy ~src dst]: on the same drive. *)

  val validate : ?dev:int -> unit -> unit
  val format : ?dev:int -> ?id:string -> string -> unit
  (** [format ~id name]: erases the disk (with [id]: full format; without:
      quick format of an already formatted disk). {b Destroys all data.} On
      an SD2IEC it works on a mounted image only. *)

  (** {2 Files} *)

  type kind = Seq | Prg | Usr
  type mode =
    | Replace   (** create, or overwrite an existing file (["@0:"] prefix:
                    the name must not contain a path) *)
    | Create    (** fails with {!Dos_error} [63] if the file exists *)
    | Append    (** append to an existing file *)

  type in_file
  type out_file

  val open_in : ?dev:int -> ?kind:kind -> string -> in_file
  (** Default kind: [Seq]. Raises {!Dos_error} [62] if the file does not
      exist. *)

  val open_out : ?dev:int -> ?kind:kind -> ?mode:mode -> string -> out_file
  (** Default mode: [Replace]. *)

  val close_in : in_file -> unit
  val close_out : out_file -> unit
  (** [close_out] also checks the drive: raises {!Dos_error} if a write
      failed (e.g. [72] disk full). Always close the files that you write. *)

  val in_eof : in_file -> bool
  (** [true] once the last byte has been read. *)

  val input_byte : in_file -> int
  val input_char : in_file -> char
  (** Raise [End_of_file] after the last byte. *)

  val input : in_file -> bytes -> int -> int -> int
  (** [input f b pos len]: reads up to [len] bytes; returns [0] at the end of
      the file. Much faster than byte by byte. *)

  type newline = Cr | Lf | Crlf
  (** Line terminator: [Cr] is the PETSCII one (default), [Lf] and [Crlf] are
      for the files written on other systems (whose text is ASCII: see
      {!Char.Ascii}). *)

  val input_line : ?nl:newline -> in_file -> string
  (** Raises [End_of_file] at the end of the file. *)

  val input_all : in_file -> string
  (** The rest of the file (it must fit in the heap, twice). *)

  val output_byte : out_file -> int -> unit
  val output_char : out_file -> char -> unit
  val output_string : out_file -> string -> unit
  val output_substring : out_file -> string -> int -> int -> unit
  val output_bytes : out_file -> bytes -> unit
  val output_newline : ?nl:newline -> out_file -> unit

  val read_file : ?dev:int -> ?kind:kind -> string -> string
  val write_file : ?dev:int -> ?kind:kind -> ?mode:mode -> string -> string -> unit
  (** [write_file name contents] *)

  (** {2 Programs and memory images} *)

  val load_at : ?dev:int -> string -> int -> int -> int * int
  (** [load_at name page off] loads the file into memory at [page*256+off]
      ({b nothing protects BreadCaml}: see {!Hw.Kernal.load_at}); returns the
      end address (last byte + 1) as [(page, off)]. *)

  val load_prg : ?dev:int -> string -> int * int
  (** Loads at the address stored in the first two bytes of the file. *)

  val save : ?dev:int -> ?replace:bool -> string -> int -> int -> int -> int -> unit
  (** [save name spage soff epage eoff] saves [\[start, end)] as a program
      file; [replace] (default [true]) overwrites an existing file. *)

  (** {2 Directory} *)

  type entry_type = DSeq | DPrg | DUsr | DRel | DDel | DDir | DOther of string
  (** [DDir]: sub-directory (SD2IEC, CMD); [DOther]: any other type string,
      as listed by the drive. *)

  type entry = {
    name : string;
    blocks : int32;         (** 254-byte blocks (16 bit, unsigned) *)
    etype : entry_type;
    closed : bool;          (** [false]: "splat" file, never closed *)
    locked : bool;          (** write protected ([<]) *)
  }

  val dir_iter : ?dev:int -> ?pattern:string -> (entry -> unit) -> unit
  (** Calls [f] for each directory entry, one at a time as they arrive from
      the drive, with no list allocated (the directory of an SD card can be
      very long). [pattern] is a DOS filter, e.g. ["a*"] or ["*=p"]; a
      pattern starting with ['='] is a bare option (SD2IEC: ["=p"]).
      [f] may use other files; it must not start another directory
      listing on the same drive. *)

  val dir_fold : ?dev:int -> ?pattern:string -> (entry -> 'a -> 'a) -> 'a -> 'a

  type disk_info = { title : string; id : string; free : int32 }

  val disk_info : ?dev:int -> unit -> disk_info
  (** Title and id of the disk and free blocks; reads the whole
      directory. *)

  val exists : ?dev:int -> string -> bool
end

(** Extras of the SD2IEC firmware (and clones: uIEC, ...). Commands that a
    real 1541 does not know raise {!Disk.Dos_error} (code 30..33). Reference:
    the sd2iec README. *)
module Sd2iec : sig

  val detect : ?dev:int -> unit -> bool
  (** [true] if the device answers as an SD2IEC. It sends ["UI"], a warm
      reset of the drive: use it {e before} opening files. *)

  (** {2 Directories and disk images} *)

  val chdir : ?dev:int -> string -> unit
  (** [chdir name]: enter the sub-directory (or mount the disk image, [.d64],
      [.d71], [.d81], [.dnp], [.m2i]) [name]. *)

  val chdir_path : ?dev:int -> string list -> unit
  (** Enters the directories one after the other. *)

  val parent : ?dev:int -> unit -> unit
  (** Back to the parent directory (leaves a mounted image). *)

  val root : ?dev:int -> unit -> unit
  (** Root of the partition (or of the mounted image). *)

  val mkdir : ?dev:int -> string -> unit
  val rmdir : ?dev:int -> string -> unit
  (** The directory must be empty; no path allowed. *)

  val mount : ?dev:int -> string -> unit
  (** Same as [chdir]. *)

  val unmount : ?dev:int -> unit -> unit
  (** Leaves the image: [root] then [parent]. *)

  (** {2 Partitions} *)

  val partition : ?dev:int -> int -> unit
  (** [partition n]: select the partition [n] (1..254). *)

  val partition_iter : ?dev:int -> (int -> string -> unit) -> unit
  (** [f number name] for each partition (the listing ["$=P"]). *)

  (** {2 Real time clock} *)

  type time = { year : int; month : int; day : int; hour : int;
                minute : int; second : int; weekday : int }
  (** [hour] is 0..23, [weekday] 0 = Sunday. *)

  val read_time : ?dev:int -> unit -> time option
  (** [None] if the device has no RTC or it is not set. *)

  val set_time : ?dev:int -> time -> unit
  (** [weekday] is ignored (computed). Years 1980..2079. *)

  (** {2 Settings} *)

  val set_device_address : ?dev:int -> int -> unit
  (** [set_device_address n] (8..30): the drive answers at [n] from now on;
      not saved at reset unless {!save_settings} is called (with the new
      device number). Close the files of the device first. *)

  val save_settings : ?dev:int -> unit -> unit
end
