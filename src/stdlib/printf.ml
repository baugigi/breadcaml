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
(*   Xavier Leroy and Pierre Weis, projet Cristal, INRIA Rocquencourt     *)
(*                                                                        *)
(*   Copyright 1996 Institut National de Recherche en Informatique et     *)
(*     en Automatique.                                                    *)
(*                                                                        *)
(*   All rights reserved.  This file is distributed under the terms of    *)
(*   the GNU Lesser General Public License version 2.1, with the          *)
(*   special exception on linking described in the file LICENSE.          *)
(*                                                                        *)
(**************************************************************************)

open CamlinternalFormatBasics
open CamlinternalFormat

let kfprintf k o (Format (fmt, _)) =
  make_printf (fun acc -> output_acc o acc; k o) End_of_acc fmt
let kbprintf k b (Format (fmt, _)) =
  make_printf (fun acc -> bufput_acc b acc; k b) End_of_acc fmt
(*-- let ikfprintf k oc (Format (fmt, _)) =
  make_iprintf k oc fmt --*)
(*++ *)
(* The reduced CamlinternalFormat has no make_iprintf: the accumulator is
   built (the %a and %t are not called) and dropped. *)
let ikfprintf k oc (Format (fmt, _)) =
  make_printf (fun _ -> k oc) End_of_acc fmt
(* ++*)
let ikbprintf = ikfprintf

let fprintf oc fmt = kfprintf ignore oc fmt
let bprintf b fmt = kbprintf ignore b fmt
let ifprintf oc fmt = ikfprintf ignore oc fmt
let ibprintf b fmt = ikbprintf ignore b fmt
let printf fmt = fprintf stdout fmt
let eprintf fmt = fprintf stderr fmt

let ksprintf k (Format (fmt, _)) =
  let k' acc =
    let buf = Buffer.create 64 in
    strput_acc buf acc;
    k (Buffer.contents buf) in
  make_printf k' End_of_acc fmt

let sprintf fmt = ksprintf (fun s -> s) fmt

let kprintf = ksprintf
