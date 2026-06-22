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

let me =  Sys.argv.(0)

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
    Const.version;
  exit 0

let where () = 
  print_endline Const.libdir;
  exit 0

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
      (("CAMLLIB=" ^ Const.libdir)
       :: Const.ocamlc
       :: "-custom"
       :: (if !verbose then "-verbose" else "")
       :: (if !compile_only then "-c" else "")
       :: !ocamlc_opts
       @ (match out_file with Some by -> ["-o"; quote by] | _ -> [])
       @ List.map Filename.quote no_asm_files) in
  exec_cmd cmd

let acme in_file =
  let cmd =
    String.concat " "
      (Const.acme
       :: (if !interp then "-Dcaml_INTERP=1" else "")
       :: (if !showmem then "-Dcaml_SHOWMEM=1" else "")
       :: (if !verbose then "-v9" else "")
       :: !acme_opts
       @ [quote in_file]) in
  exec_cmd cmd

let usage =
  Printf.sprintf
    ("Usage:\
      \t%s\t[-o name.ext] [OPTIONS] [OCAMLC_OPTIONS] FILE ...\n\
      \t\t[-- [ACME_OPTIONS]]\n\
      \t%s\t-c [OCAMLC_OPTIONS] FILE ...\n\
      \t%s\t( -where | -version | -help | --help )\n\n\
      Compile and links the given FILEs and build an executable file for \
      Commodore 64\n\
      computers. Full documentation available online \
      <https://github/baugigi/o64ml>\n\
      or locally via 'man %s'.\n\n\
      Options:") me me me me

let o64ml_opts =
  Arg.["-o", Set_string o_arg,
       "name.ext\
        \t\tDefine the output files and the compilation process.\n\
        \t\t· If ext is 'asm', generate the assembly file 'name.asm',\n\
        \t\t  suitable to be assembled by the ACME cross assembler.\n\
        \t\t· If ext is 'prg', also call ACME to assemble 'name.asm' into\n\
        \t\t  the native-code executable file 'name.prg'.\n\
        \t\tExtensions other than 'asm' and 'prg' are not allowed. If the\n\
        \t\t'-o' option is not present, name.ext is assumed to be the\n\
        \t\tbasename of the last FILE (without the trailing extension)\n\
        \t\twith '.prg' appended.\n";
       "-interp", Set interp,
       "\t\tBytecode interpretation.\n\
        \t\tAdd '-Dcaml_INTERP=1' to ACME_OPTIONS so that ACME generates\n\
        \t\ta '.prg' file containing OCaml bytecode and an interpreter,\n\
        \t\tinstead of a native-code compiled executable. The generated\n\
        \t\tfile is smaller than the corresponding native-code one, but\n\
        \t\tthe execution speed will be slower.\n";
       "-mem", Set_int mem_arg,
       Printf.sprintf
         "address\
          \t\tSet the maximum memory address available for the executable.\n\
          \t\tValid values range from 0x1000 to 0xcfff. Default: 0x%4x.\n"
         !mem_arg;
       "-stack", Set_int stack_arg,
       Printf.sprintf
         "pages\
          \t\tDefine the stack size, in 256-byte pages. Valid values are\n\
          \t\tpositive integers. Default: %d pages.\n"
         !stack_arg;
       "-showmem", Set showmem,
       "\t\tTell ACME to show information related to the allocation of\n\
        \t\tglobal data, code, libraries, heap, and stack. This effect\n\
        \t\tis achieved by adding '-Dcaml_SHOWMEM=1' to ACME_OPTIONS.\n";
       "-c", Set compile_only,
       "\t\tCompile only. Just run ocamlc with '-c' and OCAMLC_OPTIONS,\n\
        \t\tthen exit. The '-c' and '-o' options are incompatible.\n";
       "-verbose", Set verbose,
       "\t\tVerbose mode.\n\
        \t\tAdd '-verbose' to OCAMLC_OPTIONS and '-v9' to ACME_OPTIONS.\n";
       "-where", Unit where,
       "\t\tShow the location of the O64ml standard library and exit.\n";
       "-version", Unit version,
       "\t\tShow version and exit.\n";
       "--", Rest_all rest_all,
       "\t\tPass the following ACME_OPTIONS to the ACME cross assembler.\n\
        \n\
        \t\tOCAMLC_OPTIONS: any other options not listed above and not\n\
        \t\tfollowing '--' are passed to ocamlc.\n"]

let rec dyn_add_ocamlc_opts acc n =
  (* dynamically add any non-o64ml options to the ocamlc ones *)
  if n = Array.length Sys.argv then acc
  else match Sys.argv.(n) with
       | "--" | "-help" | "--help" -> acc
       | opt when opt.[0] = '-'
                  && not (List.exists (fun (o,_,_) -> o = opt) o64ml_opts) ->
          let add_opt () = ocamlc_opts := opt :: !ocamlc_opts in 
          dyn_add_ocamlc_opts ((opt, Arg.Unit add_opt, "") :: acc) (succ n)
       | _ -> dyn_add_ocamlc_opts acc (succ n)

let fail_if cond msg =
  if cond then failwith (Printf.sprintf "Error: %s\n" msg)

let () =
  try
    let specs = dyn_add_ocamlc_opts o64ml_opts 1 in
    Arg.parse (Arg.align specs) anon_fun usage;
    fail_if (!stack_arg <= 0)
      "-stack argument must be greater than 0.";
    fail_if (!mem_arg < 0x1000 || !mem_arg >= 0xD000)
      "-mem argument must range from 0x1000 to 0xCFFF.";
    let o_default = match !input_files with
      | f :: _ -> remove_extension (basename f) ^ ".prg"
      | [] -> "" in
    input_files := List.rev !input_files;
    ocamlc_opts := List.rev !ocamlc_opts;
    if !compile_only then
      begin
        fail_if !asm ".asm files are not allowed with the «-c» option.";
        fail_if !cmo ".cmo files are not allowed with the «-c» option.";
        fail_if (!o_arg <> "") "Options «-c» and «-o» are incompatible.";
        fail_if (not (!ml || !mli)) "No «.ml»/«.mli» files to compile.";
        ocamlc ()
      end
    else
      begin
        if !o_arg = "" then o_arg := o_default;
        let o_name, o_ext = remove_extension !o_arg, extension !o_arg in
        fail_if (o_ext <> ".asm" && o_ext <> ".prg")
          "«-o» argument must end with «.asm» or «.prg».";
        fail_if (not (!ml || !cmo))
          "No «.ml»/«.cmo» files to compile/link.";
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
       "%s\nTry '%s -help' or 'man %s' for more information.\n%!" err me me;
     exit 1
  | Sys_error err ->
     Printf.eprintf "%s\n%!" err;
     exit 1
