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

(** [Too_many_tags] is raised by the preprocessor when the number of
    all polymorphic variant tags to rename exceeds 32768. *)
exception Too_many_tags

(** [mapper] operates an all expressions with polymorphic variant tags, renaming
    them so that [Btypes.hash_variant] (the function used by ocamlc to compute
    hashes for their internal representation) always returns an integer which
    fits in 15 bits. The rewriter uses a database file to save and reload all
    renamings, because it must operate globally on all compilation units.
    @raise [Too_many_tags] when the number of polymorphic variant tags
      to rename exceeds 32768. *)
val mapper : Ast_mapper.mapper

(** [db_load in_ch] loads the renaming database from channel
    [in_ch]. *)
val db_load : in_channel -> unit

(** [db_save out_ch] saves the renaming database to channel
    [out_ch]. *)
val db_save : out_channel -> unit

(** [db_dump in_ch out_ch] reads from channel [in_ch] the renaming
    database and dumps it to channel [out_ch]. *)
val db_dump : in_channel -> out_channel -> unit

