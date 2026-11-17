(** Commodore 64 specific modules (BreadCaml only; not in the OCaml stdlib). *)

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

  (** Color RAM, base [$D800]: offsets 0..999; [peek] returns the low nybble. *)
  module Color : sig
    val peek : int -> int
    val poke : int -> int -> unit
  end
end
