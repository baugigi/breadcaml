open Asttypes
open Parsetree
open Ast_mapper

let trans_string = Petscii.petsciify_string
let trans_char = Petscii.petsciify_char

let err_msg ~lvl ~loc message =
  Scanf.format_from_string
    ("Error: [" ^ String.make (2 * lvl) '%' ^ "pet...] " ^ message) ""
  |> Location.errorf ~loc
  |> Ast_mapper.extension_of_error

(* PETSCII rewriters for all syntactic domains *)
let deep_petsciifier =
  let deep_expr mapper expr = match expr.pexp_desc with
    | Pexp_constant(Pconst_string (str, loc, delim)) ->
       (try
          Pconst_string(trans_string str, loc, delim)
          |> Ast_helper.Exp.constant ~loc:expr.pexp_loc
        with Invalid_argument _ ->
          err_msg ~lvl:2 ~loc "invalid token in string literal."
          |> Ast_helper.Exp.extension ~loc:expr.pexp_loc)            
    | Pexp_constant(Pconst_char ch) ->
       Pconst_char(trans_char ch)
       |> Ast_helper.Exp.constant ~loc:expr.pexp_loc 
    | _ -> default_mapper.expr mapper expr in
  let deep_pat mapper pat = match pat.ppat_desc with
    | Ppat_constant(Pconst_string(str, loc, delim)) ->
       (try
          Pconst_string(trans_string str, loc, delim)
          |> Ast_helper.Pat.constant ~loc:pat.ppat_loc
        with Invalid_argument _ ->
          err_msg ~lvl:2 ~loc "invalid token in string literal."
          |> Ast_helper.Pat.extension ~loc:pat.ppat_loc)
    | Ppat_constant(Pconst_char ch) ->
       Pconst_char(trans_char ch)
       |> Ast_helper.Pat.constant ~loc:pat.ppat_loc
    | _ -> default_mapper.pat mapper pat in
  let deep_attribute mapper attr =
    let payload = match attr.attr_payload with
      | PStr items -> PStr(List.map (mapper.structure_item mapper) items)
      | PTyp typ -> PTyp(mapper.typ mapper typ)
      | PPat(pat, expr_opt) -> 
         PPat(mapper.pat mapper pat, Option.map (mapper.expr mapper) expr_opt)
      | PSig sg -> PSig(List.map (mapper.signature_item mapper) sg) in
    { attr with attr_payload = payload } in
  let deep_struct_item mapper item =
    default_mapper.structure_item mapper item in
  let deep_sig_item mapper item =
    default_mapper.signature_item mapper item
  in
  { default_mapper with
    expr = deep_expr;
    pat = deep_pat;
    attribute = deep_attribute;
    structure_item = deep_struct_item;
    signature_item = deep_sig_item }

(* inline expression hook ([%pet...]) *)
let expr_extender mapper expr = match expr.pexp_desc with
  | Pexp_extension({ loc }, payload) ->
     (match payload with
      | PStr([{ pstr_desc = Pstr_eval({ pexp_desc }, _) }]) ->
         (match pexp_desc with
          | Pexp_constant(Pconst_string(str, str_loc, delim)) ->
             (try
                Pconst_string(trans_string str, str_loc, delim)
                |> Ast_helper.Exp.constant ~loc:expr.pexp_loc
              with Invalid_argument _ ->
                err_msg ~lvl:1 ~loc:str_loc "invalid token in string literal."
                |> Ast_helper.Exp.extension ~loc)
          | Pexp_constant(Pconst_char ch) ->
             Pconst_char (trans_char ch)
             |> Ast_helper.Exp.constant ~loc 
          | _ ->
             err_msg ~lvl:1 ~loc "expects a single string or character literal."
             |> Ast_helper.Exp.extension ~loc)
      | _ ->
         err_msg ~lvl:1 ~loc "expects a single string or character literal."
         |> Ast_helper.Exp.extension ~loc)
  | _ -> default_mapper.expr mapper expr

(* structure block hook ([%%pet...]) for implementation files (.ml) *)
let struct_item_extender mapper item = match item.pstr_desc with 
  | Pstr_extension(({ txt = "pet"; loc }, payload), attrs) ->
     (match payload with
      | PStr items ->
         List.map (deep_petsciifier.structure_item deep_petsciifier) items
         |> Ast_helper.Mod.structure ~loc:item.pstr_loc
         |> Ast_helper.Incl.mk ~loc:item.pstr_loc
         |> Ast_helper.Str.include_ ~loc:item.pstr_loc
      | _ ->
         err_msg ~lvl:2 ~loc "expects a structural payload block."
         |> Ast_helper.Str.extension ~loc:item.pstr_loc ~attrs)
  | _ -> default_mapper.structure_item mapper item

(* signature block hook ([%%pet...]) for interface files (.mli) *)
let sig_item_extender mapper item = match item.psig_desc with
  | Psig_extension(({ txt = "pet"; loc }, payload), attrs) ->
     (match payload with
      | PSig items ->
         List.map (deep_petsciifier.signature_item deep_petsciifier) items
         |> Ast_helper.Mty.signature ~loc:item.psig_loc
         |> Ast_helper.Incl.mk ~loc:item.psig_loc
         |> Ast_helper.Sig.include_ ~loc:item.psig_loc
      | _ ->
         err_msg ~lvl:2 ~loc "expects a signature payload block."
         |> Ast_helper.Sig.extension ~loc:item.psig_loc ~attrs)
  | _ -> default_mapper.signature_item mapper item

