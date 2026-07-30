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

(** [mapper] converts all ASCII characters in char and string literals
    in expressions and patterns with the corresponding PETSCII ones,
    and allows to insert tokens as [{RED}], [{CLR}], [{RVSON}],
    etc. in string literals to specify special PETSCII characters.  To
    protect a literal from conversion, write [[%ascii "text"]] for
    strings and [[%ascii 'c']] for chars. *)
val mapper : Ast_mapper.mapper
