(* ——————————————————————————————————————————————————————————————————————
   The BreadCaml Project / Progetto BreadCaml
   Copyright (C) 21-Apr-2026 Piero Furiesi
   
   This program is  free software; you can redistribute  it and/or modify
   it under the terms of the  GNU GENERAL PUBLIC LICENSE (GPL) version 2,
   as specified in the LICENSE-en file in the project root folder.
   
   Questo  programma  è software  libero;  può  essere ridistribuito  e/o
   modificato nei termini della GNU GENERAL PUBLIC LICENSE (GPL) versione
   2, come specificato nel file  LICENZA-it nella cartella principale del
   progetto.
   —————————————————————————————————————————————————————————————————————— *)
open Asttypes
open Parsetree
open Ast_mapper
open Ast_helper

let err_token = "invalid PETSCII token in string literal."
let err_ascii = "%%ascii: invalid payload."
let err_petscii = "%%petscii: invalid payload."
let error ~loc err =
  extension_of_error (Location.errorf ~loc (Scanf.format_from_string err ""))


let expr_rewriter mapper expr = match expr.pexp_desc with
  | Pexp_extension({ txt = "ascii"; loc }, PStr[item]) ->
    (match item.pstr_desc with
     | Pstr_eval
         ({ pexp_desc = Pexp_constant(Pconst_string _ | Pconst_char _ as k) },
          attrs) ->
       Exp.constant ~loc ~attrs k
     | _ ->
       Exp.extension ~loc (error ~loc err_ascii))
  | Pexp_extension({ txt = "petscii"; loc }, PStr[item]) ->
    (match item.pstr_desc with
     | Pstr_eval
         ({ pexp_desc = Pexp_constant(Pconst_string(str, str_loc, delim)) },
          attrs) ->
       (match Petscii.translate_string str with
        | petstr -> Exp.constant ~loc ~attrs (Pconst_string(petstr, str_loc, delim))
        | exception Failure _ -> Exp.extension ~loc (error ~loc:str_loc err_token))
     | _ ->
       Exp.extension ~loc (error ~loc err_petscii))
  | Pexp_constant(Pconst_string(str, str_loc, delim)) ->
    (match Petscii.translate_string_fmt str with
     | petstr ->
       Exp.constant ~loc:expr.pexp_loc ~attrs:expr.pexp_attributes
         (Pconst_string(petstr, str_loc, delim))
     | exception Failure _ ->
       Exp.extension ~loc:expr.pexp_loc (error ~loc:str_loc err_token))
  | Pexp_constant(Pconst_char ch) ->
    Exp.constant ~loc:expr.pexp_loc ~attrs:expr.pexp_attributes
      (Pconst_char(Petscii.translate_char ch))
  | _ ->
    default_mapper.expr mapper expr


(* Patterns allowed in [%ascii? ...]: char/string constants, char intervals and
   or-patterns of them. They are left untranslated (raw codes). *)
let rec raw_pattern p = match p.ppat_desc with
  | Ppat_constant(Pconst_char _ | Pconst_string _)
  | Ppat_interval(Pconst_char _, Pconst_char _) -> true
  | Ppat_or(p1, p2) -> raw_pattern p1 && raw_pattern p2
  | _ -> false

let pat_rewriter mapper pat = match pat.ppat_desc with
  | Ppat_extension({ txt = "ascii"; loc }, PPat(p, None)) ->
    if raw_pattern p then p
    else Pat.extension ~loc (error ~loc err_ascii)
  | Ppat_extension({ txt = "ascii"; loc }, PStr[item]) ->
    (match item.pstr_desc with
     | Pstr_eval
         ({ pexp_desc = Pexp_constant(Pconst_string _ | Pconst_char _ as k) },
          attrs) ->
       Pat.constant ~loc ~attrs k
     | _ ->
       Pat.extension ~loc (error ~loc err_ascii))
  | Ppat_constant(Pconst_string(str, str_loc, delim)) ->
    (match Petscii.translate_string str with
     | petstr ->
       Pat.constant ~loc:pat.ppat_loc ~attrs:pat.ppat_attributes
         (Pconst_string(petstr, str_loc, delim))
     | exception Failure _ ->
       Pat.extension ~loc:pat.ppat_loc (error ~loc:str_loc err_token))
  | Ppat_constant(Pconst_char ch) ->
    Pat.constant ~loc:pat.ppat_loc ~attrs:pat.ppat_attributes
      (Pconst_char(Petscii.translate_char ch))
  | Ppat_interval(Pconst_char c1, Pconst_char c2) ->
    Pat.interval ~loc:pat.ppat_loc ~attrs:pat.ppat_attributes
      (Pconst_char(Petscii.translate_char c1))
      (Pconst_char(Petscii.translate_char c2))
  | _ ->
    default_mapper.pat mapper pat


let mapper =
  { default_mapper with
    expr = expr_rewriter;
    pat  = pat_rewriter }
