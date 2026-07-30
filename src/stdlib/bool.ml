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

type t = bool = false | true

external not : bool -> bool = "%boolnot"
external ( && ) : bool -> bool -> bool = "%sequand"
external ( || ) : bool -> bool -> bool = "%sequor"
let equal : bool -> bool -> bool = ( = )
let compare : bool -> bool -> int = Stdlib.compare
external to_int : bool -> int = "%identity"
let to_float = function false -> 0. | true -> 1.

(*
let of_string = function
| "false" -> Some false
| "true" -> Some true
| _ -> None
*)

let to_string = function false -> "false" | true -> "true"
