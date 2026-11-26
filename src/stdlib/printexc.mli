(**************************************************************************)
(*                                                                        *)
(*                                 OCaml                                  *)
(*                                                                        *)
(*             Xavier Leroy, projet Cristal, INRIA Rocquencourt           *)
(*                                                                        *)
(*   Copyright 1996 Institut National de Recherche en Informatique et     *)
(*     en Automatique.                                                    *)
(*                                                                        *)
(*   All rights reserved.  This file is distributed under the terms of    *)
(*   the GNU Lesser General Public License version 2.1, with the          *)
(*   special exception on linking described in the file LICENSE.          *)
(*                                                                        *)
(**************************************************************************)

(** Facilities for printing exceptions.

    {i {b BreadCaml Note} Reduced version of the module: the runtime does
    not record backtraces, so the backtrace functions are stubs:
    {!record_backtrace} does nothing, {!backtrace_status} is always [false],
    {!get_backtrace} and {!raw_backtrace_to_string} return the empty string,
    {!print_backtrace} and {!print_raw_backtrace} print nothing. Not
    provided: [get_callstack], [backtrace_slots], [Slot],
    [exn_slot_id], [exn_slot_name], [set_uncaught_exception_handler]. }
*)

type t = exn = ..
(** The type of exception values. *)

val to_string: exn -> string
(** [Printexc.to_string e] returns a string representation of
   the exception [e]. *)

val to_string_default: exn -> string
(** [Printexc.to_string_default e] returns a string representation of the
    exception [e], ignoring all registered exception printers.
    @since 4.09
*)

val print: ('a -> 'b) -> 'a -> 'b
(** [Printexc.print fn x] applies [fn] to [x] and returns the result.
   If the evaluation of [fn x] raises any exception, the
   name of the exception is printed on standard error output,
   and the exception is raised again. *)

val catch: ('a -> 'b) -> 'a -> 'b
(** [Printexc.catch fn x] is similar to {!Printexc.print}, but
   aborts the program with exit code 2 after printing the
   uncaught exception. *)

val print_backtrace: out_channel -> unit
(** Does nothing (see the note above). *)

val get_backtrace: unit -> string
(** Returns the empty string (see the note above). *)

val record_backtrace: bool -> unit
(** Does nothing (see the note above). *)

val backtrace_status: unit -> bool
(** Always [false] (see the note above). *)

val register_printer: (exn -> string option) -> unit
(** [Printexc.register_printer fn] registers [fn] as an exception
    printer.  The printer should return [None] or raise an exception
    if it does not know how to convert the passed exception, and [Some
    s] with [s] the resulting string if it can convert the passed
    exception. Exceptions raised by the printer are ignored.

    When converting an exception into a string, the printers will be invoked
    in the reverse order of their registrations, until a printer returns
    a [Some s] value (if no such printer exists, the generic printer is
    used).
    @since 3.11.2
*)

val use_printers: exn -> string option
(** [Printexc.use_printers e] returns [None] if there are no registered
    printers and [Some s] with else as the resulting string otherwise.
    @since 4.09
*)

type raw_backtrace
(** The type of raw backtraces (always empty, see the note above). *)

val get_raw_backtrace: unit -> raw_backtrace
(** Returns an empty raw backtrace. *)

val print_raw_backtrace: out_channel -> raw_backtrace -> unit
(** Prints nothing. *)

val raw_backtrace_to_string: raw_backtrace -> string
(** Returns the empty string. *)

val raise_with_backtrace: exn -> raw_backtrace -> 'a
(** Same as [raise]: the backtrace is ignored. *)
