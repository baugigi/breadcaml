(* ----------------------------------------------------------------------
   Progetto BreadCaml / The BreadCaml Project
   Copyright (C) 21-Apr-2026 Piero Furiesi

   Questo  programma  è software  libero;  può  essere ridistribuito  e/o
   modificato nei termini della GNU General Public License (GPL) versione
   2; si veda il file LICENZA-it nella cartella radice del progetto.

   This program is  free software; you can redistribute  it and/or modify
   it under the terms of the  GNU General Public License (GPL) version 2,
   as specified in the LICENSE-en file in the project root folder.
   ---------------------------------------------------------------------- *)

(* Show info *)
let show = function
  | Cmdline.Where ->  print_endline Config.libdir; exit 0
  | Cmdline.Ocamlc -> print_endline Config.ocamlc; exit 0
  | Cmdline.Acme ->   print_endline Config.acme;   exit 0
  | Cmdline.Version ->
     let comp_desc = match Filename.basename Sys.argv.(0) with
       | "bcamlopt" -> "native code"
       | "bcamlc"   -> "bytecode"
       | _ -> failwith "unknown compiler!" in
     Printf.printf
       "The OCaml %s compiler for the Commodore C64, version %s\n%!"
       comp_desc Config.version;
     exit 0

(* Sys.command wrapper *)
let sys_command ~verbose ~command =
  if verbose then
    Printf.printf "BreadCaml> Executing command:‘%s’\n%!" command;
  match Sys.command command with
  | 0 -> ()
  | n -> Printf.eprintf "Error: command ‘%s’ exited with status code %u.\n%!"
           command n;
         exit n

(* Sys.remove wrapper *)
let sys_remove file =
  try Sys.remove file
  with _ -> Printf.printf "Warning: file ‘%s’ not removed\n%!" file
                            
(* Run acme *)
let acme ~verbose ~asmfile cmdline =
  sys_command ~verbose ~command:(cmdline ^ " " ^ Filename.quote asmfile)

(* Run ocamlc *)
let ocamlc ?bytefile ~verbose cmdline =
  let command = match bytefile with
    | Some bytefile -> cmdline ^ " -o " ^  Filename.quote bytefile
    | None -> cmdline in
  sys_command ~verbose ~command

(* Main *)
let () = match Cmdline.parse () with
  | Show info -> show info
  | Compileonly { ocamlc_cmdline; verbose } -> ocamlc ocamlc_cmdline ~verbose
  | Fullprocess { ocamlc_cmdline; acme_cmdline; prgfile; top_of_mem;
                  stack_pages; externs; verbose } ->
     try 
       let bytefile = Filename.temp_file ~temp_dir:"." prgfile ".bc~" in
       let asmfile  = Filename.temp_file ~temp_dir:"." prgfile ".asm~" in
       ocamlc ocamlc_cmdline ~bytefile ~verbose;
       Export.export
         ~bytefile ~asmfile ~stack_pages ~top_of_mem ~prgfile ~externs;
       acme acme_cmdline ~asmfile ~verbose ;
       sys_remove asmfile;
       sys_remove bytefile
     with Sys_error err ->
       Printf.eprintf "Sys_error: %s\n%!" err; exit 1
