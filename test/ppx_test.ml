(* ——————————————————————————————————————————————————————————————————————
   Progetto BreadCaml / The BreadCaml Project
   Copyright (C) 21-Apr-2026 Piero Furiesi

   Questo  programma è  software libero;  è possibile  ridistribuirlo e/o
   modificarlo secondo i  termini della GNU General  Public License (GPL)
   versione  2,  come specificato  nel  file  LICENZA-it nella  directory
   principale del progetto.

   This program is  free software; you can redistribute  it and/or modify
   it under the terms of the  GNU General Public License (GPL) version 2,
   as specified in the LICENSE-en file in the project root.
   —————————————————————————————————————————————————————————————————————— *)

open Asttypes
open Parsetree
open Ast_mapper
let test_mapper argv =
  { default_mapper with
    expr = fun mapper expr ->
           match expr with
           | { pexp_desc = Pexp_extension ({ txt = test }, PStr [])} ->
              Ast_helper.Exp.constant (Const_int 42)
           | other ->
              default_mapper.expr mapper other }
let _ =
  register ppx_test test_mapper

