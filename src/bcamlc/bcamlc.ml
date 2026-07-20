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

let myself = Sys.argv.(0)
let bn_myself = Filename.basename myself

let fail_if cond msg =
  if cond then failwith (Printf.sprintf "Error: %s\n" msg)

(* Set the compiler desc and acme option according to the command name *)
type compiler_t = { desc: string; acme_opt: string }
let compiler = match bn_myself with
  | "bcamlopt" -> { desc = "native code"; acme_opt = "" }
  | "bcamlc" ->   { desc = "bytecode"; acme_opt = "-Dcaml_INTERP=1" }
  | _ -> Printf.eprintf "‘%s’: unknown BreadCaml compiler.\n" bn_myself;
         exit 1

(* SYNOPSIS:
   command [-o outfile.ext] [OPTIONS] [OCAMLC_OPTIONS] FILE… [-- [ACME_OPTIONS]]
   command -c [OCAMLC_OPTIONS] FILE…
   command (-where|-ocamlc|-acme|-version|-help|--help)
   OPTIONS: -mem address  -stack npages  -showmem  -db dbfile  -verbose
 *)

(* Default values for options and arguments *)
let input_files = ref []
let o_arg = ref ""
let compile_only = ref false
let mem_arg = ref 0x9FFF
let stack_arg = ref 4
let showmem = ref false
let db = ref "bcamlppx.db"
let verbose = ref false
let acme_opts = ref [compiler.acme_opt]
let ocamlc_opts = ref []

(* Init the file extensions flags *)
let ml, mli, cmo, asm = ref false, ref false, ref false, ref false

(* Treat anonymous arguments as input FILEs or OCAMLC_OPTIONS *)
let anon_fun arg = match Filename.extension arg with
  | ".ml"  -> ml  := true; input_files := arg :: !input_files
  | ".mli" -> mli := true; input_files := arg :: !input_files
  | ".cmo" -> cmo := true; input_files := arg :: !input_files
  | ".asm" -> asm := true; input_files := arg :: !input_files
  | _ -> ocamlc_opts := arg :: !ocamlc_opts

(* Treat all options following '--' as ACME_OPTIONS *)
let rest_all args = acme_opts := args

(* Manage -where, -ocamlc, -acme, and -version options *)
let where () = print_endline Config.libdir; exit 0
let where_ocamlc () = print_endline Config.ocamlc; exit 0
let where_acme () = print_endline Config.acme; exit 0
let version () =
  Printf.printf "The OCaml %s compiler for the Commodore C64, version %s\n%!"
    compiler.desc Config.version;
  exit 0

(* Wrapper for Sys.command *)
exception Exec_error of string * int
let exec_cmd cmd =
  if !verbose then Printf.printf "Executing command:‘%s’\n%!" cmd;
  match Sys.command cmd with
  | 0 -> ()
  | n -> raise (Exec_error (cmd, n))

(* Run acme, passing it its options and the input file name *)
let acme in_file =
  let cmd =
    String.concat " "
      (Filename.quote Config.acme
       :: (if !showmem then "-Dcaml_SHOWMEM=1" else "")
       :: (if !verbose then "-v9" else "")
       :: !acme_opts
       @ [Filename.quote in_file]) in
  exec_cmd cmd

(* Run ocamlc, passing it its options and the output file name, if any *)
let ocamlc ?out_file () =
  let cmd =
    let no_asm_files =
      List.filter
        (fun f -> not (Filename.check_suffix f ".asm"))
        !input_files in
    String.concat " "
      (("CAMLLIB=" ^ Filename.quote Config.libdir)
       :: Filename.quote Config.ocamlc
       :: "-custom"
       :: (if !verbose then "-verbose" else "")
       :: (if !compile_only then "-c" else "")
       :: "-ppx"
       :: Filename.quote (Config.bindir ^ "/bcamlppx " ^ !db)
       :: !ocamlc_opts
       @ (match out_file with Some by -> ["-o"; Filename.quote by] | _ -> [])
       @ List.map Filename.quote no_asm_files) in
  exec_cmd cmd

(* Usage message *)
let usage = Printf.sprintf
 ("Usage:\n\
   %s [-o outfile.ext] [OPTIONS] [OCAMLC_OPTIONS] FILE… [-- [ACME_OPTIONS]]\n\
   %s -c [OCAMLC_OPTIONS] FILE…\n\
   %s (-where|-ocamlc|-acme|-version|-help|--help )\n\
   \n\
   Compile and links the given FILEs into a standalone %s executable\n\
   file for Commodore 64 computers.\n\
   See also <https://github/baugigi/breadcaml> and the %s(1) man page.\n\
   \n\
   FILE type is determined by extension:\n\
   \  .ml/.mli: OCaml compilation unit, implementation/interface source code\n\
   \  .cmo:     OCaml compiled bytecode\n\
   \  .cma:     OCaml bytecode library\n\
   \  .c/.o:    C source/object code\n\
   \  .asm:     ACME assembly source code\n\n\
   Options:") myself myself myself compiler.desc bn_myself

(* Arg.(key * spec * doc) list for Arg.align and Arg.parse *)
let bcamlc_opts =
  let nl_tab s = "\n" ^ String.make 18 ' ' ^ s in
  Arg.["-o", Set_string o_arg,
       "outfile.ext"
       ^ " Define the output files and the compilation process: if ext is"
       ^ nl_tab "‘asm’, generate the assembly file ‘outfile.asm’; if .ext is"
       ^ nl_tab "‘prg’, also assemble it into the executable ‘outfile.prg’.";
       
       "-c", Set compile_only,
       " Compile only: run ocamlc with [OCAMLC_OPTIONS] on given FILEs.";
       
       "-mem", Set_int mem_arg,
       "address"
       ^ " Set the maximum available memory address for the executable."
       ^ nl_tab (Printf.sprintf "Default: %#4x (%5d)." !mem_arg !mem_arg);

       "-stack", Set_int stack_arg,
       "pages"
       ^ " Define the stack size, in 256-byte pages."
       ^ nl_tab (Printf.sprintf "Default: %d pages." !stack_arg);

       "-showmem", Set showmem,
       " Show information on memory allocation.";

       "-db", Set_string db,
       "filename"
       ^ " Set the filename for the bcamlppx preprocessor database.";

       "-verbose", Set verbose,
       " Verbose mode.";

       "-where", Unit where,
       " Show the location of the BreadCaml standard library and exit.";

       "-ocamlc", Unit where_ocamlc,
       " Show the location of the OCaml bytecode compiler and exit.";

       "-acme", Unit where_acme,
       " Show the location of the ACME cross-assembler and exit.";

       "-version", Unit version,
       " Show version and exit.";

       "--", Rest_all rest_all,
       "ACME_OPTIONS Pass the options following ‘--’ to acme.\n"
       ^ "  OCAMLC_OPTIONS  Pass any options not listed above to ocamlc."]

(* Dynamically add any options not listed above to the ocamlc ones *)
let rec dyn_add_ocamlc_opts acc n =
  if n = Array.length Sys.argv then acc
  else match Sys.argv.(n) with
       | "--" | "-help" | "--help" -> acc
       | opt when opt.[0] = '-'
                  && not (List.exists (fun (o,_,_) -> o = opt) bcamlc_opts) ->
          let add_opt () = ocamlc_opts := opt :: !ocamlc_opts in 
          dyn_add_ocamlc_opts ((opt, Arg.Unit add_opt, "") :: acc) (succ n)
       | _ -> dyn_add_ocamlc_opts acc (succ n)

(* Main *)
let () =
  try
    (* Parse the command line and set all references accordingly *)
    let specs = dyn_add_ocamlc_opts bcamlc_opts 1 in
    Arg.parse (Arg.align specs) anon_fun usage;
    
    (* Check whether the input files exist and args are correct *)
    let not_found =
      List.filter (fun f -> not (Sys.file_exists f)) !input_files in
    fail_if (not_found != []) (String.concat ", " not_found ^ " not found.");
    fail_if (!input_files = []) "No input file specified.";
    fail_if (!stack_arg <= 0)  "-stack argument must be greater than 0.";
    fail_if (!mem_arg < 0x1000 || !mem_arg >= 0xD000)
      "-mem argument must range from 0x1000 to 0xCFFF.";

    (* Set the default output file name *)
    let o_default = Filename.remove_extension(List.hd !input_files) ^ ".prg" in

    (* Restore the correct order of file names and ocamlc options *)
    input_files := List.rev !input_files;
    ocamlc_opts := List.rev !ocamlc_opts;
    if !compile_only then
      (* -c option: check if all file types are correct, then call ocamlc *)
      begin
        fail_if !asm "‘.asm’ files are not allowed with the ‘-c’ option.";
        fail_if !cmo "‘.cmo’ files are not allowed with the ‘-c’ option.";
        fail_if (!o_arg <> "") "Options ‘-c’ and ‘-o’ are incompatible.";
        fail_if (not (!ml || !mli)) "No ‘.ml’ or ‘.mli’ files to compile.";
        ocamlc ()
      end
    else
      begin
        (* Check whether the arguments are correct *)
        if !o_arg = "" then o_arg := o_default;
        let (o_name, o_ext) =
          Filename.(remove_extension !o_arg, extension !o_arg) in
        fail_if (o_ext <> ".asm" && o_ext <> ".prg")
          "‘-o’ argument must end with ‘.asm’ or ‘.prg’.";
        fail_if (not (!ml || !cmo))
          "No ‘.ml’ or ‘.cmo’ files to compile or link.";

        (* Set bytecode, assembly, and executable filenames *)
        let bytefile = Filename.temp_file ~temp_dir:"." o_name ".byte" in
        let asmfile = o_name ^ ".asm" in
        let prgfile = o_name ^ ".prg" in

        (* Run ocamlc for bytecode generation *)
        ocamlc ~out_file:bytefile ();

        (* Translate the bytecode into assembly and export it  *)
        Export.export ~bytefile ~asmfile ~prgfile
          ~top_of_mem:mem_arg
          ~stack_pages:stack_arg
          ~externs:(List.filter
                      (fun f -> Filename.check_suffix f ".asm")
                      !input_files);

        (* Run the assembler if requested *)
        if o_ext = ".prg" then acme asmfile;

        (* Delete the intermediate bytecode file *)
        try Sys.remove bytefile with _ -> ()
      end
  with
  | Exec_error (cmd, n) ->
     Printf.eprintf "Error: command ‘%s’ exited with status code %u.\n%!" cmd n;
     exit n
  | Failure err ->
     Printf.eprintf "%s\nTry ‘%s -help’ or ‘man %s’ for more info.\n%!"
       err myself myself;
     exit 1
  | Sys_error err ->
     Printf.eprintf "%s\n%!" err;
     exit 1
