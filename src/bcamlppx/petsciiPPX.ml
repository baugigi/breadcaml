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

open Asttypes
open Parsetree
open Ast_mapper
open Ast_helper

let err_token   = "invalid PETSCII token in string literal."
let err_payload = "%%ascii: invalid payload."
let error ~loc err =
  extension_of_error (Location.errorf ~loc (Scanf.format_from_string err ""))

let expr_transformer mapper expr = match expr.pexp_desc with
  | Pexp_extension ({ txt = "ascii"; loc }, payload) ->
     begin match payload with
     | PStr [{ pstr_desc = Pstr_eval ({ pexp_desc; pexp_loc } as expr', _) }] ->
        begin match pexp_desc with
        | Pexp_constant (Pconst_string _ | Pconst_char _) -> expr'
        | _ -> Exp.extension ~loc:pexp_loc (error ~loc:pexp_loc err_payload)
        end
     | _ -> Exp.extension ~loc (error ~loc err_payload)
     end
  | Pexp_constant (Pconst_string (str, str_loc, delim)) ->
     begin
       try Exp.constant ~loc:expr.pexp_loc
             (Pconst_string (Petscii.of_string str, str_loc, delim)) with
       | Invalid_argument _ ->
          Exp.extension ~loc:expr.pexp_loc (error ~loc:str_loc err_token)
     end
  | Pexp_constant (Pconst_char ch) ->
     Exp.constant ~loc:expr.pexp_loc (Pconst_char (Petscii.of_char ch))
  | _ -> default_mapper.expr mapper expr

let pat_transformer mapper pat = match pat.ppat_desc with
  | Ppat_extension ({ txt = "ascii"; loc }, payload) ->
     begin match payload with
     | PStr [{ pstr_desc = Pstr_eval ({ pexp_desc; pexp_loc }, _) }] ->
        begin match pexp_desc with
        | Pexp_constant (Pconst_string (s, l, d)) ->
           Pat.constant (Pconst_string (s, l, d))
        | Pexp_constant (Pconst_char c) -> Pat.constant (Pconst_char c)
        | _ -> Pat.extension ~loc:pat.ppat_loc
                 (error ~loc:pat.ppat_loc err_payload)
        end
     | _ -> Pat.extension ~loc (error ~loc err_payload)
     end
  | Ppat_constant (Pconst_string (str, str_loc, delim)) ->
     begin
       try Pat.constant ~loc:pat.ppat_loc
             (Pconst_string (Petscii.of_string str, str_loc, delim)) with
       | Invalid_argument _ ->
          Pat.extension ~loc:pat.ppat_loc (error ~loc:str_loc err_token)
     end
  | Ppat_constant (Pconst_char ch) ->
     Pat.constant ~loc:pat.ppat_loc (Pconst_char (Petscii.of_char ch))
  | _ -> default_mapper.pat mapper pat

let mapper =
  { default_mapper with
    expr = expr_transformer;
    pat  = pat_transformer }
