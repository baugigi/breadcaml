(* ——————————————————————————————————————————————————————————————————————
   Progetto O64ml / The O64ml Project
                                     SOFTWARE DI TERZI/3RD PARTY SOFTWARE
   OCaml Standard Library
     Origine/Source: https://ocaml.org
     Copyright (C) 1996 Institut National de Recherche en Informatique et
     en Automatique
     Modifiche/Modifications: Copyright (C) 21-Apr-2026 Piero Furiesi

   Questo file contiene  modifiche apportate da Piero  Furiesi alla OCaml
   Standard  Library ed  è  distribuito nei  termini  della licenza  LGPL
   ver. 2.1  con la  cosiddetta "OCaml LGPL  Linking Exception"  (si veda
   src/stdlib/LGPL-LICENSE).  Il codice originale  rimosso o sostituito è
   racchiuso tra  i marcatori (*-- e  --*).  Il codice prodotto  da Piero
   Furiesi è chiaramente identificato dai marcatori (*++ e ++*).

   This file is a modified version by Piero Furiesi of the OCaml Standard
   Library and  is distributed under the  terms of the LGPL  License ver.
   2.1   with  the   so-called  "OCaml   LGPL  Linking   Exception"  (see
   src/stdlib/LGPL-LICENSE).   Original  code   removed  or  replaced  is
   enclosed between  (*-- and --*)  markers.  New code authored  by Piero
   Furiesi is explicitly identified by (*++ and ++*) markers.
   —————————————————————————————————————————————————————————————————————— *)

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

type ('a, 'e) t = ('a, 'e) result = Ok of 'a | Error of 'e

let ok v = Ok v
let error e = Error e
let value r ~default = match r with Ok v -> v | Error _ -> default
let get_ok = function Ok v -> v | Error _ -> invalid_arg "result is Error _"
let get_error = function Error e -> e | Ok _ -> invalid_arg "result is Ok _"
let bind r f = match r with Ok v -> f v | Error _ as e -> e
let join = function Ok r -> r | Error _ as e -> e
let map f = function Ok v -> Ok (f v) | Error _ as e -> e
let map_error f = function Error e -> Error (f e) | Ok _ as v -> v
let fold ~ok ~error = function Ok v -> ok v | Error e -> error e
let iter f = function Ok v -> f v | Error _ -> ()
let iter_error f = function Error e -> f e | Ok _ -> ()
let is_ok = function Ok _ -> true | Error _ -> false
let is_error = function Error _ -> true | Ok _ -> false

let equal ~ok ~error r0 r1 = match r0, r1 with
| Ok v0, Ok v1 -> ok v0 v1
| Error e0, Error e1 -> error e0 e1
| _, _ -> false

let compare ~ok ~error r0 r1 = match r0, r1 with
| Ok v0, Ok v1 -> ok v0 v1
| Error e0, Error e1 -> error e0 e1
| Ok _, Error _ -> -1
| Error _, Ok _ -> 1

let to_option = function Ok v -> Some v | Error _ -> None
let to_list = function Ok v -> [v] | Error _ -> []
let to_seq = function Ok v -> Seq.return v | Error _ -> Seq.empty
