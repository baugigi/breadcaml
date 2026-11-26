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

(* SYNOPSIS:
   command [-o outfile] [OPTIONS] [OCAMLC_OPTIONS] FILE... [-- [ACME_OPTIONS]]
   command -c [OCAMLC_OPTIONS] FILE...
   command (-where|-ocamlc|-acme|-version|-help|--help)
   OPTIONS: [-db dbfile] [-mem address] [-stack npages] [-showmem]
            [-mark-and-compact | -stop-and-copy]
            [-osize | -otime] (bcamlopt only)
*)

(* The type for the result of command line parsing *)
type t =
  | Fullprocess of fullprocess_t        (* no -c option *)
  | Compileonly of compileonly_t        (* -c option *)
  | Show of show_t                      (* -where, -ocamlc, -acme, -version *)
and fullprocess_t =
  { ocamlc_cmdline : string;
    acme_cmdline   : string;
    prgfile        : string;
    top_of_mem     : int;
    stack_pages    : int;
    externs        : string list;
    verbose        : bool }
and compileonly_t =
  { ocamlc_cmdline : string;
    verbose        : bool }
and show_t = Where | Ocamlc | Acme | Version

(* Default values for options, option arguments, and file type flags *)
let compile_only = ref false
let input_files  = ref []
let ocamlc_opts  = ref []
let o_arg        = ref ""
let db_arg       = ref ""
let mem_arg      = ref 0x9FFF
let stack_arg    = ref 4
let gc_arg       = ref "mark_and_compact"
let big_o_arg    = ref None (* -O argument *)
let show_opt     = ref None
let showmem      = ref false
let verbose      = ref false
let ml, mli, cmo, asm = ref false, ref false, ref false, ref false

(* Set comp_desc and acme_opts according to the compiler name *)
let comp_desc, acme_opts = match Filename.basename Sys.argv.(0) with
  | "bcamlopt" -> "native code", ref []
  | "bcamlc"   -> "bytecode",    ref ["-Dcaml_INTERP=1"]
  | unknown    -> Printf.eprintf "Unknown compiler: %s\n%!" unknown; exit 1

(* Treat anonymous arguments as input FILEs or OCAMLC_OPTIONS *)
let anon_fun arg = match Filename.extension arg with
  | ".ml"  -> ml  := true; input_files := arg :: !input_files
  | ".mli" -> mli := true; input_files := arg :: !input_files
  | ".cmo" -> cmo := true; input_files := arg :: !input_files
  | ".asm" -> asm := true; input_files := arg :: !input_files
  | _ -> ocamlc_opts := arg :: !ocamlc_opts

(* Treat all options following '--' as ACME_OPTIONS *)
let rest_all args = acme_opts := !acme_opts @ args

(* -where, -ocamlc, -acme, -version: the early bird gets the worm. *)
let show info () = match !show_opt with
  | None -> show_opt := Some info
  | _ -> ()

(* Usage message *)
let usage =
  let me = Sys.argv.(0) in
  Printf.sprintf
    ("Usage:\n\
      %s [-o outfile] [OPTIONS] [OCAMLC_OPTS] FILE... [-- [ACME_OPTS]]\n\
      %s -c [OCAMLC_OPTS] FILE...\n\
      %s -where|-ocamlc|-acme|-version\n\
      \n\
      Compile and links the given FILEs into a standalone %s executable file\n\
      for Commodore 64 computers. See also the %s(1) man page.\n\
      FILE type is determined by extension:\n\
     \  .ml, .mli:  OCaml source code;\n\
     \  .cmo, .cma: OCaml compiled bytecode and libraries;\n\
     \  .c, .o:     C source and object code;\n\
     \  .asm:       ACME assembly source code.\n\
      OCAMLC_OPTS are passed to ocamlc, ACME_OPTS to acme.\n\
      \n\
      Valid OPTIONS are:")
    me me me comp_desc (Filename.basename me)

(* prevent specifying an option with argument more than once *)
let seen_opts = ref []
let set_once o r v =
  if List.mem o !seen_opts then
    raise (Arg.Bad
             (Printf.sprintf "the %s option is specified more than once." o))
  else (r := v; seen_opts := o :: !seen_opts)

(* (key * spec * doc) list for Arg.align and Arg.parse *)
let (^+) s1 s2 = s1 ^ "\n" ^ String.make 17 ' ' ^ s2
let speclist = Arg.[
    ("-o", String (set_once "-o" o_arg),
     "<outfile> Set the output filename; default: the last input FILE name"
     ^+ "with its extension replaced by '.prg'."); 
    ("-c", Set compile_only,
     " Compile only. Run ocamlc with OCAMLC_OPTS on the given FILEs.");
    ("-mem", Int (set_once "-mem" mem_arg),
     "<address> Set the maximum available memory address for the executable;"
     ^+ "default: " ^ (Printf.sprintf "%#4x (%5d)." !mem_arg !mem_arg));
    ("-stack", Int (set_once "-stack" stack_arg),
     "<pages> Define the stack size, in 256-byte pages; default: "
     ^ (Printf.sprintf "%d pages." !stack_arg));
    ("-O", String (fun s -> set_once "-O" big_o_arg (Some s)),
     "size|time Enable native-code optimizations for size (omit speed-oriented"
     ^+ "fast paths in runtime) or speed (use direct calls to functions"
     ^+ "known at compile time).");
    ("-gc", String (set_once "-gc" gc_arg),
     "<gc_algo> Select the garbage collector algorithm: 'stop_and_copy' or"
     ^+ "'mark_and_compact' (default).");
    ("-db", String (set_once "-db" db_arg),
     "<dbfile> Set the pathname for the BreadCaml preprocessor database;"
     ^+ "default: <outfile> with its extension replaced by '.db'.");
    ("-verbose", Set verbose, " Verbose mode.");
    ("-showmem", Set showmem, " Show information on memory allocation.");
    ("-where", Unit (show Where),
     " Show the location of the BreadCaml standard library and exit.");
    ("-ocamlc", Unit (show Ocamlc),
     " Show the location of the OCaml bytecode compiler and exit.");
    ("-acme", Unit (show Acme),
     " Show the location of the ACME cross-assembler and exit.");
    ("-version", Unit (show Version), " Show version and exit.");
    ("--", Rest_all rest_all, "")]

(* Add to ocamlc_opts any options not listed above and not following '--' *)
let rec dyn_add_ocamlc_opts i accu =
  let nargs = Array.length Sys.argv in
  if i = nargs then accu
  else match Sys.argv.(i) with
    | "--" | "-help" | "--help" -> accu
    | opt when opt.[0] = '-' &&
               not (List.exists (fun (o,_,_) -> o = opt) speclist) ->
      let add opt () = ocamlc_opts := opt :: !ocamlc_opts in
      dyn_add_ocamlc_opts (succ i) ((opt, Arg.Unit (add opt), "") :: accu)
    | _ -> dyn_add_ocamlc_opts (succ i) accu

(* Check all arguments according to a checklist *)
let check_args () =
  let missing = List.filter (fun f -> not (Sys.file_exists f)) !input_files in
  let check (cond, err) = if not cond then failwith err in
  let checklist =
    let ( ==> ) b1 b2 = (not b1) || b2 in
    [| (* condition, error message if not met *)
      (!input_files <> [],
       "no input file specified.");
      (missing = [],
       "file(s) '" ^ String.concat "', '" missing ^ "' not found.");
      (!stack_arg > 0,
       "the -stack option requires an argument greater than 0.");
      (comp_desc = "bytecode" ==> (!big_o_arg = None),
       "the -O option is available for the native-code compiler only.");
      (List.mem !big_o_arg [None; Some "size"; Some "time"],
       "the argument to the -O option is invalid.");
      (List.mem !gc_arg ["mark_and_compact"; "stop_and_copy"],
       "the argument to the -gc option is invalid.");
      (0x1000 <= !mem_arg && !mem_arg < 0xD000,
       "the argument to the -mem option is out of range.");
      (!compile_only ==> not !asm,
       ".asm files are not allowed with the -c option.");
      (!compile_only ==> not !cmo,
       ".cmo files are not allowed with the -c option.");
      (!compile_only ==> (!o_arg = ""),
       "the -c and -o options are incompatible.");
      (!compile_only ==> (!ml || !mli),
       "no .ml or .mli files specified.");
      (not !compile_only ==> (!ml || !cmo),
       "no .ml or .cmo files specified.") |] in
  try Array.iter check checklist
  with Failure err ->
    let me = Sys.argv.(0) in
    Printf.eprintf
      "Error: %s\nTry ‘%s -help’ or ‘man %s’ for more info.\n%!" err me me;
    exit 1

(* Main *)
let parse () =
  let module F = Filename in
  let specs () = dyn_add_ocamlc_opts 1 speclist in
  Arg.parse (Arg.align (specs ())) anon_fun usage;
  match !show_opt with
  | Some info -> Show info
  | None ->
    check_args ();    
    let last_file = match !input_files with
      | lf :: _ -> F.remove_extension lf
      | [] -> assert false in
    ocamlc_opts := List.rev !ocamlc_opts;
    input_files := List.rev !input_files;
    let dbfile = match !db_arg, !o_arg with
      | "", "" -> last_file ^ ".db"
      | "", o_arg -> (F.remove_extension o_arg) ^ ".db"
      | _ -> !db_arg in
    let externs, ocamlc_files =
      List.partition (fun f -> F.check_suffix f ".asm") !input_files in
    let ocamlc_cmdline =
      "CAMLLIB=" ^ F.quote Config.libdir
      ^ " " ^ F.quote Config.ocamlc ^ " -custom"
      ^ (if !verbose then " -verbose" else "")
      ^ (if !compile_only then " -c" else "")
      ^ " -ppx " ^ F.quote (Config.bindir ^ "/bcamlppx " ^ dbfile)
      ^ " " ^ String.concat " " (!ocamlc_opts @ (List.map F.quote ocamlc_files))
    in
    if !compile_only then Compileonly { ocamlc_cmdline; verbose = !verbose }
    else
      let prgfile = if !o_arg = "" then last_file ^ ".prg" else !o_arg in
      let acme_cmdline =
        F.quote Config.acme
        ^ " -Dcaml_gc_" ^ !gc_arg ^ "=1"
        ^ (if !big_o_arg = Some "size" then " -Dcaml_osize=1" else "")
        ^ (if !showmem then " -Dcaml_SHOWMEM=1" else "")
        ^ (if !verbose then " -v9" else "")
        ^ " " ^ String.concat " " !acme_opts in
      Opcodes.direct_calls := !big_o_arg = Some "time";
      Fullprocess
        { ocamlc_cmdline; acme_cmdline; prgfile; externs; top_of_mem = !mem_arg;
          stack_pages = !stack_arg; verbose = !verbose }
