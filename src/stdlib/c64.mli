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
  end
end
