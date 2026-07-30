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

type 'a t = 'a option = None | Some of 'a

let none = None
let some v = Some v
let value o ~default = match o with Some v -> v | None -> default
let get = function Some v -> v | None -> invalid_arg "option is None"
let bind o f = match o with None -> None | Some v -> f v
let join = function Some o -> o | None -> None
let map f o = match o with None -> None | Some v -> Some (f v)
let fold ~none ~some = function Some v -> some v | None -> none
let iter f = function Some v -> f v | None -> ()
let is_none = function None -> true | Some _ -> false
let is_some = function None -> false | Some _ -> true

let equal eq o0 o1 = match o0, o1 with
| Some v0, Some v1 -> eq v0 v1
| None, None -> true
| _ -> false

let compare cmp o0 o1 = match o0, o1 with
| Some v0, Some v1 -> cmp v0 v1
| None, None -> 0
| None, Some _ -> -1
| Some _, None -> 1

let to_result ~none = function None -> Error none | Some v -> Ok v
let to_list = function None -> [] | Some v -> [v]
let to_seq = function None -> Seq.empty | Some v -> Seq.return v
