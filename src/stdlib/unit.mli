(* ----------------------------------------------------------------------
   Progetto BreadCaml / The BreadCaml Project
                                     SOFTWARE DI TERZI/3RD PARTY SOFTWARE
   OCaml Standard Library
     Origine/Source: https://ocaml.org
     Copyright (C) 1996 Institut National de Recherche en Informatique et
     en Automatique
     Modifiche/Modifications: 21-Apr-2026 Piero Furiesi

   Questo file è distribuito nei termini  della licenza LGPL ver. 2.1 con
   le eccezioni riportate nel file LICENSE (in inglese).
   Il codice originale rimosso o sostituito è incluso tra (*-- e --*); le
   aggiunte sono  identificate da  (*++ e ++*)  oppure, nei  commenti per
   OCamldoc, da {i {b BreadCaml Note} ... }.

   This file is distributed under the terms of the LGPL License ver.  2.1
   with the exceptions stated in file LICENSE.
   Original code  removed or replaced  is enclosed between (*--  and --*)
   markers;  new code  is  identified by  (*++ and  ++*)  markers, or  by
   {i {b BreadCaml Note} ... } in OCamldoc comments.
   ---------------------------------------------------------------------- *)

(**************************************************************************)
(*                                                                        *)
(*                                 OCaml                                  *)
(*                                                                        *)
(*                         The OCaml programmers                          *)
(*                                                                        *)
(*   Copyright 2018 Institut National de Recherche en Informatique et     *)
(*     en Automatique.                                                    *)
(*                                                                        *)
(*   All rights reserved.  This file is distributed under the terms of    *)
(*   the GNU Lesser General Public License version 2.1, with the          *)
(*   special exception on linking described in the file LICENSE.          *)
(*                                                                        *)
(**************************************************************************)

(** Unit values.

    @since 4.08 *)

(** {1:unit The unit type} *)

type t = unit = () (**)
(** The unit type.

    The constructor [()] is included here so that it has a path,
    but it is not intended to be used in user-defined data types.
 *)

val equal : t -> t -> bool
(** [equal u1 u2] is [true]. *)

val compare : t -> t -> int
(** [compare u1 u2] is [0]. *)

val to_string : t -> string
(** [to_string b] is ["()"]. *)
