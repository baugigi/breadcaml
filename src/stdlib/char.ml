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

(* Character operations *)

external code: char -> int = "%identity"
external unsafe_chr: int -> char = "%identity"

let chr n =
  if n < 0 || n > 255 then invalid_arg "Char.chr" else unsafe_chr n

external bytes_create: int -> bytes = "caml_create_bytes"
external bytes_unsafe_set : bytes -> int -> char -> unit
                           = "%bytes_unsafe_set"
external unsafe_to_string : bytes -> string = "%bytes_to_string"

let escaped = function
  | '\'' -> "\\'"
  | '\\' -> "\\\\"
  | '\n' -> "\\n"
  | '\t' -> "\\t"
  | '\r' -> "\\r"
  | '\b' -> "\\b"
  | ' ' .. '~' as c ->
      let s = bytes_create 1 in
      bytes_unsafe_set s 0 c;
      unsafe_to_string s
  | c ->
      let n = code c in
      let s = bytes_create 4 in
      bytes_unsafe_set s 0 '\\';
      bytes_unsafe_set s 1 (unsafe_chr (48 + n / 100));
      bytes_unsafe_set s 2 (unsafe_chr (48 + (n / 10) mod 10));
      bytes_unsafe_set s 3 (unsafe_chr (48 + n mod 10));
      unsafe_to_string s

let lowercase = function
  | 'A' .. 'Z'
  | '\192' .. '\214'
  | '\216' .. '\222' as c ->
    unsafe_chr(code c + 32)
  | c -> c

let uppercase = function
  | 'a' .. 'z'
  | '\224' .. '\246'
  | '\248' .. '\254' as c ->
    unsafe_chr(code c - 32)
  | c -> c

let lowercase_ascii = function
  | 'A' .. 'Z' as c -> unsafe_chr(code c + 32)
  | c -> c

let uppercase_ascii = function
  | 'a' .. 'z' as c -> unsafe_chr(code c - 32)
  | c -> c

type t = char

let compare c1 c2 = code c1 - code c2
let equal (c1: t) (c2: t) = compare c1 c2 = 0
