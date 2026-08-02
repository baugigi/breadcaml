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

(* If this file is named 'config.ml' then it has been created by the
   'configure' script: edit 'src/breadcaml/config.ml.tpl' instead. *)

let header_includes	= ["c64defs.asm"]
let pre_code_includes	= ["loader.asm"; "codegen.asm"]
let post_code_includes	= ["runtime.asm"; "memory.asm"; "stdlib.asm"]
let trailer_includes	= ["showmem.asm"]

let ocamlc  = "/home/piero/.opam/LTS/bin/ocamlc.opt"
let libdir  = "/home/piero/.opam/LTS/lib/bcamlc"
let bindir  = "/home/piero/.opam/LTS/bin"
let acme    = "/home/piero/.opam/LTS/bin/acme"
let version = "0.0.alpha_4.14.2"

