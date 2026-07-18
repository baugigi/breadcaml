open Asttypes
open Parsetree 
open Ast_mapper

exception Too_many_tags

type db_t = { mutable index : int;
              renamings : (string, string) Hashtbl.t }

let db = ref { index = -1;
               renamings = Hashtbl.create 16 }

let db_load in_ch =
  db := Marshal.from_channel in_ch

let db_save out_ch =
  Marshal.to_channel out_ch !db [];
  flush out_ch

let new_tag () = match succ !db.index with
  | 32768 -> raise Too_many_tags
  | i -> !db.index <- i;
         PolyvarArray.a.(i) 

let rename_tag tag =
  try
    Hashtbl.find !db.renamings tag
  with Not_found ->
    let newtag = new_tag () in
    Hashtbl.add !db.renamings tag newtag;
    newtag

let expr_rewriter mapper expr = match expr.pexp_desc with
  | Pexp_variant (lbl, exp_opt) ->
     Ast_helper.Exp.variant
       ~loc:expr.pexp_loc
       ~attrs:expr.pexp_attributes
       (rename_tag lbl)
       exp_opt
  | _ -> default_mapper.expr mapper expr

let pat_rewriter mapper pat = match pat.ppat_desc with
  | Ppat_variant (lbl, pat_opt) ->
     Ast_helper.Pat.variant
       ~loc:pat.ppat_loc
       ~attrs:pat.ppat_attributes
       (rename_tag lbl)
       pat_opt
  | _ -> default_mapper.pat mapper pat

let typ_rewriter mapper typ = match typ.ptyp_desc with
  | Ptyp_variant (row_flds, flag, lbls_opt) ->
     let row_fld_rewriter = function
       | { prf_desc = Rtag(lbl_loc, bflag, ctypl) } ->
          Ast_helper.Rf.tag
            { lbl_loc with txt = rename_tag lbl_loc.txt }
            bflag
            ctypl
       | row_fld -> row_fld in
     let lbls_opt_rewriter = function
       | Some lbls -> Some (List.map rename_tag lbls)
       | None -> None in
     Ast_helper.Typ.variant
       ~loc:typ.ptyp_loc
       ~attrs:typ.ptyp_attributes
       (List.map row_fld_rewriter row_flds)
       flag
       (lbls_opt_rewriter lbls_opt)
  | _ -> default_mapper.typ mapper typ

