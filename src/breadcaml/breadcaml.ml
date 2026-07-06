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

open Filename

exception Exec_error of string * int

let input_files = ref []	(* *.{ml, mli, cmo, asm} input files *)
let o_arg = ref ""		(* -o option argument *)
let compile_only = ref false	(* -c option *)
let mem_arg = ref 0x9FFF	(* -mem option argument *)
let stack_arg = ref 4    	(* -stack option argument *)
let interp = ref false		(* -interp option *)
let showmem = ref false  	(* -showmem option *)
let verbose = ref false  	(* -verbose option *)
let ocamlc_opts = ref []	(* ocamlc options *)
let acme_opts = ref []		(* acme options *)
let ml, mli, cmo, asm = ref false, ref false, ref false, ref false
let myself = Sys.argv.(0)

let anon_fun arg = match extension arg with
  | ".ml"  -> ml  := true; input_files := arg :: !input_files
  | ".mli" -> mli := true; input_files := arg :: !input_files
  | ".cmo" -> cmo := true; input_files := arg :: !input_files
  | ".asm" -> asm := true; input_files := arg :: !input_files
  | _ -> ocamlc_opts := arg :: !ocamlc_opts

let rest_all args = acme_opts := args

let version () =
  Printf.printf
    "The OCaml compiler for the Commodore C64, version %s\n%!"
    Config.version;
  exit 0

let where () = 
  print_endline Config.libdir;
  exit 0

let where_ocamlc () = 
  print_endline Config.ocamlc;
  exit 0

let where_acme () = 
  print_endline Config.acme;
  exit 0

let help () =
  exit (Sys.command "man breadcaml")

let exec_cmd cmd =
  if !verbose then Printf.printf "Executing command: «%s»\n%!" cmd;
  match Sys.command cmd with
  | 0 -> ()
  | n -> raise (Exec_error (cmd, n))

let ocamlc ?out_file () =
  let cmd =
    let no_asm_files =
      List.filter (fun f -> not (check_suffix f ".asm")) !input_files in
    String.concat " "
      (("CAMLLIB=" ^ quote Config.libdir)
       :: quote Config.ocamlc
       :: "-custom"
       :: (if !verbose then "-verbose" else "")
       :: (if !compile_only then "-c" else "")
       :: !ocamlc_opts
       @ (match out_file with Some by -> ["-o"; quote by] | _ -> [])
       @ List.map quote no_asm_files) in
  exec_cmd cmd

let acme in_file =
  let cmd =
    String.concat " "
      (quote Config.acme
       :: (if !interp then "-Dcaml_INTERP=1" else "")
       :: (if !showmem then "-Dcaml_SHOWMEM=1" else "")
       :: (if !verbose then "-v9" else "")
       :: !acme_opts
       @ [quote in_file]) in
  exec_cmd cmd

let usage = Printf.sprintf
 ("Usage:\n\
   %s [-o outfile.ext] [OPTIONS] [OCAMLC_OPTIONS] FILE… [--[ACME_OPTIONS]]\n\
   %s -c [OCAMLC_OPTIONS] FILE…\n\
   %s (-where|-ocamlc|-acme|-version|-help|--help )\n\
   \n\
   Compile and links the given FILEs into an executable file for C64 computers.\n\
   See also <https://github/baugigi/breadcaml> and the breadcaml(1) man page.\n\
   \n\
   FILE type is determined by extension:\n\
   \  .ml/.mli:  OCaml compilation unit, implementation/interface source code\n\
   \  .cmo/.cmi: OCaml compiled bytecode/interface\n\
   \  .cma:      OCaml bytecode library\n\
   \  .c/.o:     C source/object code\n\
   \  .asm:      ACME assembly source code\n\
   \n\
   Options:") myself myself myself

let breadcaml_opts =
  let spacer = String.make 18 ' ' in
  Arg.["-o", Set_string o_arg,
       "outfile.ext "
       ^ "Define the output files and the compilation process: if ext is\n"
       ^ spacer
       ^ "'asm', generate the assembly file 'outfile.asm'; if .ext is\n"
       ^ spacer
       ^ "'prg', also assemble it into the executable 'outfile.prg'.";
       "-c", Set compile_only,
       " Compile only.";
       "-interp", Set interp,
       " Generate a bytecode file that includes the interpreter.";
       "-mem", Set_int mem_arg,
       "address Set the maximum available memory address for the executable.\n"
       ^ spacer ^ (Printf.sprintf "Default: %#4x (%5d)." !mem_arg !mem_arg);
       "-stack", Set_int stack_arg,
       "pages Define the stack size, in 256-byte pages.\n"
       ^ spacer ^ (Printf.sprintf "Default: %d." !stack_arg);
       "-showmem", Set showmem, " Show information on memory allocation.";
       "-verbose", Set verbose, " Verbose mode.";
       "-where", Unit where,
       " Show the location of the BreadCaml standard library and exit.";
       "-ocamlc", Unit where_ocamlc,
       " Show the location of the OCaml bytecode compiler and exit.";
       "-acme", Unit where_acme,
       " Show the location of the ACME cross-assembler and exit.";
       "-version", Unit version, " Show version and exit.";
       "--", Rest_all rest_all,
       "ACME_OPTIONS Pass the options following -- to acme.\n"
       ^ "  OCAMLC_OPTIONS  Pass any options not listed above to ocamlc."]

let rec dyn_add_ocamlc_opts acc n =
  (* dynamically add any non-breadcaml options to the ocamlc ones *)
  if n = Array.length Sys.argv then acc
  else match Sys.argv.(n) with
       | "--" | "-help" | "--help" -> acc
       | opt when opt.[0] = '-'
                  && not (List.exists (fun (o,_,_) -> o = opt) breadcaml_opts) ->
          let add_opt () = ocamlc_opts := opt :: !ocamlc_opts in 
          dyn_add_ocamlc_opts ((opt, Arg.Unit add_opt, "") :: acc) (succ n)
       | _ -> dyn_add_ocamlc_opts acc (succ n)

let fail_if cond msg =
  if cond then failwith (Printf.sprintf "Error: %s\n" msg)

let () =
  try
    let specs = dyn_add_ocamlc_opts breadcaml_opts 1 in
    Arg.parse (Arg.align specs) anon_fun usage;
    let not_found =
      List.filter (fun f -> not (Sys.file_exists f)) !input_files in
    fail_if (not_found != []) (String.concat ", " not_found ^ " not found.");
    fail_if (!input_files = []) "No input file specified.";
    fail_if (!stack_arg <= 0)  "-stack argument must be greater than 0.";
    fail_if (!mem_arg < 0x1000 || !mem_arg >= 0xD000)
      "-mem argument must range from 0x1000 to 0xCFFF.";
    let o_default = match !input_files with
      | f :: _ -> remove_extension f ^ ".prg"
      | [] -> "" in
    input_files := List.rev !input_files;
    ocamlc_opts := List.rev !ocamlc_opts;
    if !compile_only then
      begin
        fail_if !asm ".asm files are not allowed with the «-c» option.";
        fail_if !cmo ".cmo files are not allowed with the «-c» option.";
        fail_if (!o_arg <> "") "Options «-c» and «-o» are incompatible.";
        fail_if (not (!ml || !mli)) "No «.ml» or «.mli» files to compile.";
        ocamlc ()
      end
    else
      begin
        if !o_arg = "" then o_arg := o_default;
        let o_name, o_ext = remove_extension !o_arg, extension !o_arg in
        fail_if (o_ext <> ".asm" && o_ext <> ".prg")
          "«-o» argument must end with «.asm» or «.prg».";
        fail_if (not (!ml || !cmo))
          "No «.ml» or «.cmo» files to compile or link.";
        let bytefile = temp_file ~temp_dir:"." o_name ".byte" in
        let asmfile = o_name ^ ".asm" in
        let prgfile = o_name ^ ".prg" in
        ocamlc ~out_file:bytefile ();
        Export.export ~bytefile ~asmfile ~prgfile
          ~externs:(List.filter (fun f -> check_suffix f ".asm") !input_files)
          ~top_of_mem:mem_arg ~stack_pages:stack_arg;
        if o_ext = ".prg" then acme asmfile;
        try Sys.remove bytefile with _ -> ()
      end
  with
  | Exec_error (cmd, n) ->
     Printf.eprintf
       "Error: command «%s» exited with status code %u.\n%!" cmd n;
     exit n
  | Failure err ->
     Printf.eprintf
       "%s\nTry '%s -help' or 'man %s' for more info.\n%!" err myself myself;
     exit 1
  | Sys_error err ->
     Printf.eprintf "%s\n%!" err;
     exit 1
