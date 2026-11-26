(**************************************************************************)
(*                                                                        *)
(*                                 OCaml                                  *)
(*                                                                        *)
(*                          Benoit Vaugon, ENSTA                          *)
(*                                                                        *)
(*   Copyright 2014 Institut National de Recherche en Informatique et     *)
(*     en Automatique.                                                    *)
(*                                                                        *)
(*   All rights reserved.  This file is distributed under the terms of    *)
(*   the GNU Lesser General Public License version 2.1, with the          *)
(*   special exception on linking described in the file LICENSE.          *)
(*                                                                        *)
(**************************************************************************)

(* BREADCAML: reduced interface, see camlinternalFormat.ml *)

open CamlinternalFormatBasics

type ('b, 'c) acc =
  | Acc_formatting_lit of ('b, 'c) acc * formatting_lit
  | Acc_string_literal of ('b, 'c) acc * string
  | Acc_char_literal   of ('b, 'c) acc * char
  | Acc_data_string    of ('b, 'c) acc * string
  | Acc_data_char      of ('b, 'c) acc * char
  | Acc_delay          of ('b, 'c) acc * ('b -> 'c)
  | Acc_flush          of ('b, 'c) acc
  | Acc_invalid_arg    of ('b, 'c) acc * string
  | End_of_acc

val make_printf :
  (('b, 'c) acc -> 'd) -> ('b, 'c) acc ->
  ('a, 'b, 'c, 'c, 'c, 'd) CamlinternalFormatBasics.fmt -> 'a

val output_acc : out_channel -> (out_channel, unit) acc -> unit
val bufput_acc : Buffer.t -> (Buffer.t, unit) acc -> unit
val strput_acc : Buffer.t -> (unit, string) acc -> unit
