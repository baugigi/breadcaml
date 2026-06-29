(* ppx_petscii - a naive ppx-rewriter for oc64ml *)

open Ast_mapper
open Asttypes
open Parsetree 
open C64.Petscii
  
let map_char = function
  | 'A' .. 'Z' as ch -> Char.lowercase_ascii ch
  | 'a' .. 'z' as ch -> Char.uppercase_ascii ch
  | '_' -> '\164' (* underscore *)
  | ch -> ch 
  
let petcode_of_str = function
  | "{CRSR\164UP}" -> Some crsr_up
  | "{CRSR\164DN}" -> Some crsr_dn
  | "{CRSR\164LT}" -> Some crsr_lt
  | "{CRSR\164RT}" -> Some crsr_rt
  | "{BLACK}" -> Some black
  | "{WHITE}" -> Some white
  | "{RED}" -> Some red
  | "{CYAN}" -> Some cyan
  | "{PURPLE}" -> Some purple
  | "{GREEN}" -> Some green
  | "{L\164GREEN}" -> Some l_green
  | "{BLUE}" -> Some blue
  | "{L\164BLUE}" -> Some l_blue
  | "{YELLOW}" -> Some yellow
  | "{ORANGE}" -> Some orange
  | "{BROWN}" -> Some brown
  | "{L\164RED}" | "{PINK}" -> Some l_red
  | "{GREY1}" | "{GRAY1}" -> Some grey1
  | "{GREY2}" | "{GRAY2}" -> Some grey2
  | "{GREY3}" | "{GRAY3}" -> Some grey3
  | "{RVS\164ON}" -> Some rvs_on
  | "{RVS\164OFF}" -> Some rvs_off
  | "{CASE\164LOCK}" -> Some case_lock
  | "{CASE\164UNLOCK}" -> Some case_unlock
  | "{LO\164CASE}" -> Some lo_case
  | "{UP\164CASE}" -> Some up_case
  | "{F1}" -> Some f1
  | "{F2}" -> Some f2
  | "{F3}" -> Some f3
  | "{F4}" -> Some f4
  | "{F5}" -> Some f5
  | "{F6}" -> Some f6
  | "{F7}" -> Some f7
  | "{F8}" -> Some f8
  | "{NULL}" -> Some null
  | "{STOP}" -> Some stop
  | "{RETURN}" -> Some return
  | "{SH\164RETURN}" -> Some sh_return
  | "{HOME}" -> Some home
  | "{CLR}" -> Some clr
  | "{DEL}" -> Some del
  | "{INST}" -> Some inst
  | "{SH\164SPACE}" -> Some sh_space
  | "{UNDERSCORE}" -> Some underscore
  | "{RUN}" -> Some run
  | "{POUND}" -> Some pound
  | "{UP\164ARROW}" -> Some up_arrow
  | "{LT\164ARROW}" -> Some lt_arrow
  | "{PI}" -> Some pi
  | _ -> None
       
let petsciify str =
  let open String in
  let rec subst_petcodes str =
    try
      let op_bra = index str '{' in
      let cl_bra = index_from str op_bra '}' + 1 in
      let petcode = petcode_of_str (sub str op_bra (cl_bra - op_bra)) in
      let left = match petcode with
        | Some ch -> sub str 0 op_bra ^ make 1 ch
        | None -> sub str 0 cl_bra
      and right = sub str cl_bra (length str - cl_bra) in
      left ^ subst_petcodes right
    with _ -> str in
  subst_petcodes (map map_char str)


let expr_mapper mapper expr =
  match expr with
  | {pexp_desc =
       Pexp_extension
         ({txt = "pet"},
          PStr
            [{pstr_desc =
                Pstr_eval
                  ({pexp_desc =
                      Pexp_constant
                        (Pconst_string (s, t))}, _)}])} ->
     Ast_helper.Exp.constant (Pconst_string (petsciify s, t))
  | _ -> default_mapper.expr mapper expr
       
let mapper_petscii argv =
  {default_mapper with expr = expr_mapper}
  
let _ =
  register "ppx_petscii" mapper_petscii
