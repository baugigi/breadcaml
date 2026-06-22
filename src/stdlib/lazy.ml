(* ——————————————————————————————————————————————————————————————————————
   Progetto BreadCaml / The BreadCaml Project
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
   Furiesi è chiaramente  identificato dai marcatori (*++  e ++*), oppure
   con "{i {b BreadCaml Note} nuovo testo...}" nei commenti per OCamlDoc.

   This file is a modified version by Piero Furiesi of the OCaml Standard
   Library and  is distributed under the  terms of the LGPL  License ver.
   2.1   with  the   so-called  "OCaml   LGPL  Linking   Exception"  (see
   src/stdlib/LGPL-LICENSE).   Original  code   removed  or  replaced  is
   enclosed between  (*-- and --*)  markers.  New code authored  by Piero
   Furiesi  is  explicitly  identified  by  (*++ and ++*) markers,  or by
   "{i {b BreadCaml Note} new text...}" in OCamlDoc comments.
   —————————————————————————————————————————————————————————————————————— *)

(**************************************************************************)
(*                                                                        *)
(*                                 OCaml                                  *)
(*                                                                        *)
(*             Damien Doligez, projet Para, INRIA Rocquencourt            *)
(*                                                                        *)
(*   Copyright 1997 Institut National de Recherche en Informatique et     *)
(*     en Automatique.                                                    *)
(*                                                                        *)
(*   All rights reserved.  This file is distributed under the terms of    *)
(*   the GNU Lesser General Public License version 2.1, with the          *)
(*   special exception on linking described in the file LICENSE.          *)
(*                                                                        *)
(**************************************************************************)


(* Module [Lazy]: deferred computations *)


(*
   WARNING: some purple magic is going on here.  Do not take this file
   as an example of how to program in OCaml.
*)


(* We make use of two special tags provided by the runtime:
   [lazy_tag] and [forward_tag].

   A value of type ['a Lazy.t] can be one of three things:
   1. A block of size 1 with tag [lazy_tag].  Its field is a closure of
      type [unit -> 'a] that computes the value.
   2. A block of size 1 with tag [forward_tag].  Its field is the value
      of type ['a] that was computed.
   3. Anything else except a float.  This has type ['a] and is the value
      that was computed.
   Exceptions are stored in format (1).
   The GC will magically change things from (2) to (3) according to its
   fancy.

   If OCaml was configured with the -flat-float-array option (which is
   currently the default), the following is also true:
   We cannot use representation (3) for a [float Lazy.t] because
   [caml_make_array] assumes that only a [float] value can have tag
   [Double_tag].

   We have to use the built-in type constructor [lazy_t] to
   let the compiler implement the special typing and compilation
   rules for the [lazy] keyword.
*)

type 'a t = 'a CamlinternalLazy.t

exception Undefined = CamlinternalLazy.Undefined

external make_forward : 'a -> 'a lazy_t = "caml_lazy_make_forward"

external force : 'a t -> 'a = "%lazy_force"


let force_val = CamlinternalLazy.force_val

let from_fun (f : unit -> 'arg) =
  let x = Obj.new_block Obj.lazy_tag 1 in
  Obj.set_field x 0 (Obj.repr f);
  (Obj.obj x : 'arg t)

let from_val (v : 'arg) =
  let t = Obj.tag (Obj.repr v) in
  if t = Obj.forward_tag || t = Obj.lazy_tag || t = Obj.double_tag then begin
    make_forward v
  end else begin
    (Obj.magic v : 'arg t)
  end


let is_val (l : 'arg t) = Obj.tag (Obj.repr l) <> Obj.lazy_tag

let lazy_from_fun = from_fun

let lazy_from_val = from_val

let lazy_is_val = is_val


let map f x =
  lazy (f (force x))

let map_val f x =
  if is_val x
  then lazy_from_val (f (force x))
  else lazy (f (force x))
