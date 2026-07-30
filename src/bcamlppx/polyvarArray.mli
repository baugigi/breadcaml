(* ----------------------------------------------------------------------
   Progetto BreadCaml / The BreadCaml Project
   Copyright (C) 21-Apr-2026 Piero Furiesi

   Questo  programma  è software  libero;  può  essere ridistribuito  e/o
   modificato nei termini della GNU General Public License (GPL) versione
   2; si veda il file LICENZA-it nella cartella radice del progetto.

   This program is  free software; you can redistribute  it and/or modify
   it under the terms of the  GNU General Public License (GPL) version 2,
   as specified in the LICENSE-en file in the project root folder.
   ---------------------------------------------------------------------- *)

(** [a] is an array of 32768 6-char strings such that, for each string [a.(i)],
    [Btype.hash_variant a.(i)] evaluates to a 15-bit integer from [-16384] to
    [16383], and [Btype.hash_variant a.(i) = Btype.hash_variant a.(j)] if and
    only if [i = j].  [Btype.hash_variant : string -> int] is the function used
    by ocamlc to compute hashes for the internal representation of polymorphic
    variants. *)
val a : string array
