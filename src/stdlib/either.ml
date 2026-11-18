(* ——————————————————————————————————————————————————————————————————————
   The BreadCaml Project / Progetto BreadCaml
   Copyright (C) 21-Apr-2026 Piero Furiesi

                   3RD PARTY SOFTWARE / SOFTWARE DI TERZI
           OCaml Core System - (C) 1996 INRIA <https://ocaml.org>

   Modifications / Modifiche: 21-Apr-2026 Piero Furiesi

   This file  is distributed under  the terms  of the GNU  LESSER GENERAL
   PUBLIC LICENSE  (LGPL) version 2.1,  with the exception stated  in the
   LICENSE  file.
   Modifications:  (*-- and  --*)  enclose original  code  that has  been
   commented out; (*++  and ++*) delimit new code sections;  new notes in
   OCamldoc comments are marked with {i {b BreadCaml Note} text…  }.

   Questo file è distribuito nei  termini della GNU LESSER GENERAL PUBLIC
   LICENSE (LGPL) versione 2.1, con l’eccezione indicata nel file LICENSE
   (in inglese).
   Modifiche: il codice originale  escluso tramite commentatura è incluso
   tra (*-- e --*); (*++ e  ++*) delimitano il nuovo codice; il marcatore
   {i {b BreadCaml Note} testo…  } indica note ai commenti di OCamldoc.
   —————————————————————————————————————————————————————————————————————— *)
(**************************************************************************)
(*                                                                        *)
(*                                 OCaml                                  *)
(*                                                                        *)
(*         Gabriel Scherer, projet Parsifal, INRIA Saclay                 *)
(*                                                                        *)
(*   Copyright 2019 Institut National de Recherche en Informatique et     *)
(*     en Automatique.                                                    *)
(*                                                                        *)
(*   All rights reserved.  This file is distributed under the terms of    *)
(*   the GNU Lesser General Public License version 2.1, with the          *)
(*   special exception on linking described in the file LICENSE.          *)
(*                                                                        *)
(**************************************************************************)

type ('a, 'b) t = Left of 'a | Right of 'b

let left v = Left v
let right v = Right v

let is_left = function
| Left _ -> true
| Right _ -> false

let is_right = function
| Left _ -> false
| Right _ -> true

let find_left = function
| Left v -> Some v
| Right _ -> None

let find_right = function
| Left _ -> None
| Right v -> Some v

let map_left f = function
| Left v -> Left (f v)
| Right _ as e -> e

let map_right f = function
| Left _ as e -> e
| Right v -> Right (f v)

let map ~left ~right = function
| Left v -> Left (left v)
| Right v -> Right (right v)

let fold ~left ~right = function
| Left v -> left v
| Right v -> right v

let iter = fold

let for_all = fold

let equal ~left ~right e1 e2 = match e1, e2 with
| Left v1, Left v2 -> left v1 v2
| Right v1, Right v2 -> right v1 v2
| Left _, Right _ | Right _, Left _ -> false

let compare ~left ~right e1 e2 = match e1, e2 with
| Left v1, Left v2 -> left v1 v2
| Right v1, Right v2 -> right v1 v2
| Left _, Right _ -> (-1)
| Right _, Left _ -> 1
