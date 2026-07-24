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


(* Global database of polymorphic variant renamings *)
type db_t =  { mutable index : int;
               renamings : (string, string) Hashtbl.t }
let db = ref { index = -1;
               renamings = Hashtbl.create 16 }

let db_load in_ch =
  db := Marshal.from_channel in_ch

let db_save out_ch =
  Marshal.to_channel out_ch !db [];
  flush out_ch

let db_dump in_ch out_ch =
  let count = ref 0 in
  Hashtbl.iter
    (fun k v ->
      incr count;
      Printf.fprintf out_ch "%5d: `%s\t->\t`%s\n" !count k v)
    (Marshal.from_channel in_ch).renamings;
  flush out_ch


(* Renaming function *)
exception Too_many_tags
let rename_polyvar tag =
  try Hashtbl.find !db.renamings tag with
  | Not_found ->
     let i = succ !db.index in
     let new_tag =
       try PolyvarArray.a.(i) with
       | Invalid_argument _ -> raise Too_many_tags in
     !db.index <- i;
     Hashtbl.add !db.renamings tag new_tag;
     new_tag


(* PPX rewriters *)
let expr_rewriter mapper expr = match expr.pexp_desc with
  | Pexp_variant (lbl, exp_opt) ->
     Ast_helper.Exp.variant
       ~loc:expr.pexp_loc
       ~attrs:expr.pexp_attributes
       (rename_polyvar lbl)
       exp_opt
  | _ -> default_mapper.expr mapper expr

let pat_rewriter mapper pat = match pat.ppat_desc with
  | Ppat_variant (lbl, pat_opt) ->
     Ast_helper.Pat.variant
       ~loc:pat.ppat_loc
       ~attrs:pat.ppat_attributes
       (rename_polyvar lbl)
       pat_opt
  | _ -> default_mapper.pat mapper pat

let typ_rewriter mapper typ = match typ.ptyp_desc with
  | Ptyp_variant (row_flds, flag, lbls_opt) ->
     let row_field_rewriter = function
       | { prf_desc = Rtag(lbl_loc, bflag, ctypl) } ->
          Ast_helper.Rf.tag
            { lbl_loc with
              txt = rename_polyvar lbl_loc.txt }
            bflag ctypl
       | rf -> rf in
     let lbls_opt_rewriter = function
       | Some lbls -> Some (List.map rename_polyvar lbls)
       | None -> None in
     Ast_helper.Typ.variant
       ~loc:typ.ptyp_loc
       ~attrs:typ.ptyp_attributes
       (List.map row_field_rewriter row_flds)
       flag
       (lbls_opt_rewriter lbls_opt)
  | _ -> default_mapper.typ mapper typ

let mapper =
  { default_mapper with
    expr = expr_rewriter;
    pat = pat_rewriter;
    typ = typ_rewriter }
