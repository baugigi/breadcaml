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

type 'a t = { mutable c : 'a list; mutable len : int; }

exception Empty

let create () = { c = []; len = 0; }

let clear s = s.c <- []; s.len <- 0

let copy s = { c = s.c; len = s.len; }

let push x s = s.c <- x :: s.c; s.len <- s.len + 1

let pop s =
  match s.c with
  | hd::tl -> s.c <- tl; s.len <- s.len - 1; hd
  | []     -> raise Empty

let pop_opt s =
  match s.c with
  | hd::tl -> s.c <- tl; s.len <- s.len - 1; Some hd
  | []     -> None

let top s =
  match s.c with
  | hd::_ -> hd
  | []    -> raise Empty

let top_opt s =
  match s.c with
  | hd::_ -> Some hd
  | []    -> None

let is_empty s = (s.c = [])

let length s = s.len

let iter f s = List.iter f s.c

let fold f acc s = List.fold_left f acc s.c

(** {1 Iterators} *)

let to_seq s = List.to_seq s.c

let add_seq q i = Seq.iter (fun x -> push x q) i

let of_seq g =
  let s = create() in
  add_seq s g;
  s
