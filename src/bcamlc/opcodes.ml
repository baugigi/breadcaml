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
open OByteLib.Instr

let opc_of = function
  (* stack *)
  | ACC0 -> 0 | ACC1 -> 1 | ACC2 -> 2 | ACC3 -> 3 | ACC4 -> 4 | ACC5 -> 5
  | ACC6 -> 6 | ACC7 -> 7 | ACC _ -> 8 | PUSH -> 9  | POP _ -> 19
  | ASSIGN _ -> 20
  (* environment *)
  | ENVACC1 -> 21 | ENVACC2 -> 22 | ENVACC3 -> 23 | ENVACC4 -> 24
  | ENVACC _ -> 25
  (* closures *)
  | PUSH_RETADDR _ -> 31 | APPLY _ -> 32 | APPLY1 -> 33 | APPLY2 -> 34
  | APPLY3 -> 35 | APPTERM (_, _) -> 36 | APPTERM1 _ -> 37 | APPTERM2 _ -> 38
  | APPTERM3 _ -> 39 | RETURN _ -> 40 | RESTART -> 41 | GRAB _ -> 42
  | CLOSURE (_, _) -> 43 | CLOSUREREC (_, _, _, _) -> 44 | OFFSETCLOSUREM2 -> 45
  | OFFSETCLOSURE0 -> 46 | OFFSETCLOSURE2 -> 47 | OFFSETCLOSURE _ -> 48
  (* globals *)
  | GETGLOBAL _ -> 53 | GETGLOBALFIELD (_, _) -> 55 | SETGLOBAL _ -> 57
  (* blocks *)
  | ATOM0 -> 58 | ATOM _ -> 59 | MAKEBLOCK (_, _) -> 62 | MAKEBLOCK1 _ -> 63
  | MAKEBLOCK2 _ -> 64 | MAKEBLOCK3 _ -> 65 | GETFIELD0 -> 67 | GETFIELD1 -> 68
  | GETFIELD2 -> 69 | GETFIELD3 -> 70 | GETFIELD _ -> 71 | SETFIELD0 -> 73
  | SETFIELD1 -> 74 | SETFIELD2 -> 75 | SETFIELD3 -> 76 | SETFIELD _ -> 77
  (* arrays *)
  | VECTLENGTH -> 79 | GETVECTITEM -> 80 | SETVECTITEM -> 81
  (* float arrays *)
  | MAKEFLOATBLOCK _ -> 66 | GETFLOATFIELD _ -> 72 | SETFLOATFIELD _ -> 78
  (* bytes/strings *)
  | GETBYTESCHAR -> 82 | SETBYTESCHAR -> 83 | GETSTRINGCHAR -> 148
  (* exceptions *)
  | PUSHTRAP _ -> 89 | POPTRAP -> 90 | RAISE -> 91 | RERAISE -> 146
  | RAISE_NOTRACE -> 147
  (* externals *)
  | C_CALL1 _ -> 93 | C_CALL2 _ -> 94 | C_CALL3 _ -> 95 | C_CALL4 _ -> 96
  | C_CALL5 _ -> 97 | C_CALLN (_, _) -> 98
  (* constants *)
  | CONST0 -> 99 | CONST1 -> 100 | CONST2 -> 101 | CONST3 -> 102
  | CONSTINT _ -> 103
  (* arithm.-logical *)
  | BOOLNOT -> 88 | NEGINT -> 109 | ADDINT -> 110 | SUBINT -> 111
  | MULINT -> 112 | DIVINT -> 113 | MODINT -> 114 | ANDINT -> 115
  | ORINT -> 116 | XORINT -> 117 | LSLINT -> 118 | LSRINT -> 119 | ASRINT -> 120
  | EQ -> 121 | NEQ -> 122 | LTINT -> 123 | LEINT -> 124 | GTINT -> 125
  | GEINT -> 126 | OFFSETINT _ -> 127 | OFFSETREF _ -> 128 | ISINT -> 129
  | ULTINT -> 137 | UGEINT -> 138
  (* branches *)
  | BRANCH _ -> 84 | BRANCHIF _ -> 85 | BRANCHIFNOT _ -> 86
  | SWITCH (_, _) -> 87 | BEQ (_, _) -> 131 | BNEQ (_, _) -> 132
  | BLTINT (_, _) -> 133 | BLEINT (_, _) -> 134 | BGTINT (_, _) -> 135
  | BGEINT (_, _) -> 136 | BULTINT (_, _) -> 139 | BUGEINT (_, _) -> 140
  (* objects *)
  | GETMETHOD -> 130  | GETPUBMET (_, _) -> 141 | GETDYNMET -> 142
  (* PUSH- combined *)
  | PUSHACC0 -> 10 | PUSHACC1 -> 11 | PUSHACC2 -> 12 | PUSHACC3 -> 13
  | PUSHACC4 -> 14 | PUSHACC5 -> 15 | PUSHACC6 -> 16 | PUSHACC7 -> 17
  | PUSHACC _ -> 18 | PUSHENVACC1 -> 26 | PUSHENVACC2 -> 27 | PUSHENVACC3 -> 28
  | PUSHENVACC4 -> 29 | PUSHENVACC _ -> 30 | PUSHOFFSETCLOSUREM2 -> 49
  | PUSHOFFSETCLOSURE0 -> 50 | PUSHOFFSETCLOSURE2 -> 51
  | PUSHOFFSETCLOSURE _ -> 52 | PUSHGETGLOBAL _ -> 54
  | PUSHGETGLOBALFIELD (_, _) -> 56 | PUSHATOM0 -> 60 | PUSHATOM _ -> 61
  | PUSHCONST0 -> 104 | PUSHCONST1 -> 105 | PUSHCONST2 -> 106
  | PUSHCONST3 -> 107 | PUSHCONSTINT _ -> 108
  (* halt/debug/misc. *)
  | CHECK_SIGNALS -> 92 | STOP -> 143 | EVENT -> 144 | BREAK -> 145

type instr_arg =
  | Num of int
  | Ptr of int
  | Ptrs of int array

let lbl_fmt = format_of_string "caml_%04x"
let opc_fmt = format_of_string "+i%02x"
let arg_fmt = format_of_string "%d"
let cmd_sep = ":"
let arg_sep = ","
let cmdarg_sep = " "
let tab = 10
let max_col = 80
let col = ref 0

let (~%) f x y = f y x
let (#%) fold f = ~%(fold ~%f)
let (^...) str1 str2 =
  let spaces = String.(make (max 1 (tab - length str1)) ' ') in
  str1 ^ spaces ^ str2

let str_of_arg = function
  | Num n -> Printf.sprintf arg_fmt n
  | Ptr p -> Printf.sprintf lbl_fmt p
  | Ptrs ps ->
    let args = Array.(to_list (map (Printf.sprintf lbl_fmt) ps)) in
    "[" ^ String.concat arg_sep args ^ "]"

let str_of_lbl label = Printf.sprintf lbl_fmt label

let emit_op oc label opcode args =
  let args_str = String.concat arg_sep (List.map str_of_arg args) in
  let cmd = Printf.sprintf opc_fmt opcode
            ^ if args_str = "" then "" else cmdarg_sep ^ args_str in
  let len_cmd = String.length cmd in
  match label with
  | Some lbl ->
    output_string oc ("\n" ^ str_of_lbl lbl ^... cmd);
    col := tab + len_cmd
  | None ->
    let new_col = !col + String.length arg_sep + len_cmd in
    if new_col <= max_col
    then (output_string oc (cmd_sep ^ cmd);
          col := new_col)
    else (output_string oc ("\n" ^ "" ^... cmd);
          col := tab + len_cmd)

let emit_asm oc label instr args = emit_op oc label (opc_of instr) args

(* -otime: direct calls.
   The following sequences, whose callee is known at compile time and whose
   arity is exactly the number of arguments, are replaced by the native-only
   opcodes 0xa0-0xa3 (see codegen.asm), which skip the closure's code pointer
   read and the callee's GRAB:
     PUSHOFFSETCLOSURE0; APPLYn          -> PUSH; APPLYD n,t
     PUSHOFFSETCLOSURE0; APPTERMn s      -> PUSH; APPTERMD n,s,t
     [PUSH]GETGLOBAL g; APPLYn           -> ...; APPLYG n,t
     [PUSH]GETGLOBAL g; APPTERMn s       -> ...; APPTERMG n,s,t
   where t is the callee's entry, past its GRAB. A global g is a known function
   when its only SETGLOBAL immediately follows the CLOSURE (or the one-function
   CLOSUREREC) that builds it. *)
let direct_calls = ref false

let find_direct_calls code is_ptr =
  let n = Array.length code in
  let is_entry = Array.make n false in
  let mark p = if 0 <= p && p < n then is_entry.(p) <- true in
  Array.iter (function
      | CLOSURE (_, p) -> mark p
      | CLOSUREREC (_, _, o, t) -> mark o; Array.iter mark t
      | _ -> ()) code;
  (* encl.(i) = entry of the function that contains instruction i *)
  let encl = Array.make n (-1) in
  let cur = ref (-1) in
  Array.iteri (fun i _ -> if is_entry.(i) then cur := i; encl.(i) <- !cur) code;
  let setcount = Hashtbl.create 64 in
  Array.iter (function
      | SETGLOBAL g ->
        Hashtbl.replace setcount g
          (1 + (try Hashtbl.find setcount g with Not_found -> 0))
      | _ -> ()) code;
  let gfun = Hashtbl.create 64 in
  let add_gfun g e =
    if Hashtbl.find_opt setcount g = Some 1 then Hashtbl.replace gfun g e in
  for i = 0 to n - 2 do
    if not (is_ptr (i + 1)) then
      match code.(i), code.(i + 1) with
      | CLOSURE (_, e), SETGLOBAL g -> add_gfun g e
      | CLOSUREREC (1, _, e, [||]), ACC0
        when i + 2 < n && not (is_ptr (i + 2)) ->
        (match code.(i + 2) with SETGLOBAL g -> add_gfun g e | _ -> ())
      | _ -> ()
  done;
  (* Where to enter the callee e when called with the given arity *)
  let target e arity =
    if e < 0 || e >= n then None
    else match code.(e) with
      | GRAB m -> if m = arity - 1 && e + 1 < n then Some (e + 1) else None
      | _ -> if arity = 1 then Some e else None in
  let call_of = function
    | APPLY1 -> Some (1, None) | APPLY2 -> Some (2, None)
    | APPLY3 -> Some (3, None)
    | APPTERM1 s -> Some (1, Some s) | APPTERM2 s -> Some (2, Some s)
    | APPTERM3 s -> Some (3, Some s)
    | _ -> None in
  let repl = Hashtbl.create 64 in
  let extra = ref [] in
  for i = 0 to n - 2 do
    if not (is_ptr (i + 1)) then
      match call_of code.(i + 1) with
      | None -> ()
      | Some (arity, tail) ->
        let site = match code.(i) with
          | PUSHOFFSETCLOSURE0 when encl.(i) >= 0 -> Some (encl.(i), true)
          | GETGLOBAL g | PUSHGETGLOBAL g ->
            (match Hashtbl.find_opt gfun g with
             | Some e -> Some (e, false)
             | None -> None)
          | _ -> None in
        match site with
        | None -> ()
        | Some (e, self) ->
          match target e arity with
          | None -> ()
          | Some t ->
            extra := t :: !extra;
            if self then Hashtbl.replace repl i (opc_of PUSH, []);
            let opc = match self, tail with
              | true, None -> 0xa0 | true, Some _ -> 0xa1
              | false, None -> 0xa2 | false, Some _ -> 0xa3 in
            let args = match tail with
              | None -> [Num arity; Ptr t]
              | Some s -> [Num arity; Num s; Ptr t] in
            Hashtbl.replace repl (i + 1) (opc, args)
  done;
  repl, !extra

let export oc code =
  let module AdrSet = Set.Make(Int) in
  let pointers =
    let init = AdrSet.add 0 AdrSet.empty in
    let add_ptrs instr =
      List.fold_left #% AdrSet.add (get_ptrs instr) in
    Array.fold_left #% add_ptrs code init in
  let repl, extra =
    if !direct_calls
    then find_direct_calls code (fun adr -> AdrSet.mem adr pointers)
    else Hashtbl.create 1, [] in
  let pointers = List.fold_left (fun set adr -> AdrSet.add adr set)
      pointers extra in
  let export_lbl_instr adr instr =
    let label = if AdrSet.mem adr pointers then Some adr else None in
    match Hashtbl.find_opt repl adr with
    | Some (opcode, args) -> emit_op oc label opcode args
    | None ->
    match instr with
    | ACC n | APPLY n | ASSIGN n | CONSTINT n | ENVACC n | GETFIELD n
    | GETFLOATFIELD n | GETGLOBAL n | GRAB n | OFFSETCLOSURE n
    | OFFSETINT n | OFFSETREF n | POP n | PUSHACC n | PUSHCONSTINT n
    | PUSHENVACC n | PUSHGETGLOBAL n | PUSHOFFSETCLOSURE n | RETURN n
    | SETFIELD n | SETFLOATFIELD n | SETGLOBAL n | APPTERM1 n
    | APPTERM2 n | APPTERM3 n | ATOM n | MAKEBLOCK1 n | MAKEBLOCK2 n
    | MAKEBLOCK3 n | PUSHATOM n | MAKEFLOATBLOCK n | C_CALL1 n
    | C_CALL2 n | C_CALL3 n | C_CALL4 n | C_CALL5 n ->
      emit_asm oc label instr [Num n]
    | BRANCH ptr | BRANCHIF ptr | BRANCHIFNOT ptr | PUSHTRAP ptr
    | PUSH_RETADDR ptr ->
      emit_asm oc label instr [Ptr ptr]
    | BEQ (n, ptr) | BGEINT (n, ptr) | BGTINT (n, ptr) | BLEINT (n, ptr)
    | BLTINT (n, ptr) | BNEQ (n, ptr) | BUGEINT (n, ptr) | BULTINT (n, ptr)
    | CLOSURE (n, ptr) ->
      emit_asm oc label instr [Num n; Ptr ptr]
    | APPTERM (n, m) | MAKEBLOCK (n, m) | C_CALLN (n, m)
    | GETGLOBALFIELD (n, m) | PUSHGETGLOBALFIELD (n, m) ->
      emit_asm oc label instr [Num n; Num m]
    | GETPUBMET (tag, _) ->
      emit_asm oc label instr [Num (tag land 0x7FFF)]
    | SWITCH (n, ptrs) ->
      emit_asm oc label instr [Num (n land 0xFFFF); Ptrs ptrs]
    | CLOSUREREC (f, v, o, t) ->
      emit_asm oc label instr [Num f; Num v; Ptr o; Ptrs t]
    | _instr_with_no_args_ ->
      emit_asm oc label instr [] in
  output_string oc "\ncaml_program\n";
  Array.iteri export_lbl_instr code;
  output_string oc "\ncaml_program_end\n"
