(* ——————————————————————————————————————————————————————————————————————
   Progetto BreadCaml / The BreadCaml Project
   Copyright (C) 2026 Piero Furiesi

   Questo  programma è  software libero;  è possibile  ridistribuirlo e/o
   modificarlo secondo i  termini della GNU General  Public License (GPL)
   versione  2,  come specificato  nel  file  LICENZA-it nella  directory
   principale del progetto.

   This program is  free software; you can redistribute  it and/or modify
   it under the terms of the  GNU General Public License (GPL) version 2,
   as specified in the LICENSE-en file in the project root.
   —————————————————————————————————————————————————————————————————————— *)

(** [mapper] converts all ASCII characters in char and string literals in
    expressions and patterns with the corresponding PETSCII ones, and allows to
    specify special PETSCII characters with tokens as [{RED}], [{CLR}],
    [{RVSON}], etc.  To protect a literal from conversion, use [%ascii "string"]
    or [%ascii 'c']. *)
val mapper : Ast_mapper.mapper
