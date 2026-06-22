(* ——————————————————————————————————————————————————————————————————————
   Progetto BreadCaml / The BreadCaml Project
   Copyright (C) 21-Apr-2026 Piero Furiesi

   Questo  programma è  software libero;  è possibile  ridistribuirlo e/o
   modificarlo secondo i  termini della GNU General  Public License (GPL)
   versione  2,  come specificato  nel  file  LICENZA-it nella  directory
   principale del progetto.

   This program is  free software; you can redistribute  it and/or modify
   it under the terms of the  GNU General Public License (GPL) version 2,
   as specified in the LICENSE-en file in the project root.
   —————————————————————————————————————————————————————————————————————— *)

(** The C64 library.

    A bunch of useful definitions for programming in OCaml for a C64.
*)


(** {1 Extensions of module [Stdlib.Int]} *)
module Int : sig
  include module type of Int

  (** [div_mod n m] returns the same result as [(n / m, n mod m)], but is twice
      as fast as the latter.
      @raise Division_by_zero if [y] is zero. *)
  external div_mod : int -> int -> int * int = "caml_nonstd_div_mod"

end


(** {1 Extensions of module [Stdlib.Float]} *)
module Float : sig
  include module type of Float

  (** [sign x] returns [1], [0] or [-1] depending on whether [x] is positive,
      zero, or negative. Faster than [compare x 0.]. *)
  external sign: float -> int = "caml_nonstd_sign_float"

end


(** {1 IRQ handling} *)
module IRQ : sig
  (** {b This module needs to be compiled with the [-irqsupport] option.} *)

  (** The type of IRQ handlers.
      An IRQ handler may be the standard Kernal routine, a custom routine, or an
      OCaml function of type [unit -> 'a]. *)
  type 'a t =
    | Kernal
    | Custom
    | Callback of (unit -> 'a)
      
  (** [set_handler handler] registers and activates the specified IRQ [handler],
      as explained below:

      - [Kernal]: {i the standard Kernal IRQ routine} starting at ROM address
      $EA31, which increments the real-time clock, controls cursor blinking,
      controls the cassette device, and scans the keyboard.

      - [Callback f]: {i the functional value} [f]. When an IRQ needs to be
      served, the current evaluation process is suspended and a wrapper provided
      by the runtime support will call [f], passing it [()] as an argument. When
      the evaluation of [f ()] is terminated, its result is discarded and
      control passes to the standard Kernal IRQ routine, after which the
      previously suspended execution is resumed. Note that [f] can be defined
      directly in OCaml or declared as an [external].

      - [Custom]: {i a custom routine from an ACME assembly file.} A label named
      {i caml_irq_custom_handler} must be provided so that the assembler can
      resolve it to the routine starting address, which will be written into the
      IRQ vector (C64_CINV, at $0314-$0315). The custom routine must not be
      declared with the [external] keyword, as it is not an external
      implementation of a valid OCaml functional value and is invisible to the
      OCaml program. Custom handlers usually end by passing control to the
      standard Kernal routine (i.e. with a {i JMP $EA31} instruction).
     
      Programmers should be aware that {i concurrent access to shared resources
      can lead to unpredictable effects} in the absence of a concurrency control
      mechanisms, which must be carefully considered when implementing an
      interrupt handler. *)
  val set_handler : 'a t -> unit

end
