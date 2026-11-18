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
