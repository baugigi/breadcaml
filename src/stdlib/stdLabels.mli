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
(*                Jacques Garrigue, Kyoto University RIMS                 *)
(*                                                                        *)
(*   Copyright 2001 Institut National de Recherche en Informatique et     *)
(*     en Automatique.                                                    *)
(*                                                                        *)
(*   All rights reserved.  This file is distributed under the terms of    *)
(*   the GNU Lesser General Public License version 2.1, with the          *)
(*   special exception on linking described in the file LICENSE.          *)
(*                                                                        *)
(**************************************************************************)

(** Standard labeled libraries.

   This meta-module provides versions of the {!Array}, {!Bytes},
   {!List} and {!String} modules where function arguments are
   systematically labeled.  It is intended to be opened at the top of
   source files, as shown below.

   {[
     open StdLabels

     let to_upper = String.map ~f:Char.uppercase_ascii
     let seq len = List.init ~f:(function i -> i) ~len
     let everything = Array.create_matrix ~dimx:42 ~dimy:42 42
   ]}

*)

module Array = ArrayLabels
module Bytes = BytesLabels
module List = ListLabels
module String = StringLabels
