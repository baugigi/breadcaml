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

(* Wrapper for Sys.command *)
let exec_cmd ~verbose ~command =
  if verbose then
    Printf.printf "BreadCaml> Executing command:‘%s’\n%!" command;
  match Sys.command command with
  | 0 -> ()
  | n -> Printf.eprintf "Error: command ‘%s’ exited with status code %u.\n%!"
           command n;
         exit n

(* Run acme *)
let acme ~verbose ~asmfile cmdline =
  exec_cmd ~verbose ~command:(cmdline ^ " " ^ Filename.quote asmfile)

(* Run ocamlc *)
let ocamlc ?bytefile ~verbose cmdline =
  let command = match bytefile with
    | Some bytefile -> cmdline ^ " -o " ^  Filename.quote bytefile
    | None -> cmdline in
  exec_cmd ~verbose ~command

(* Main *)
let () =
  try
    let Cmdline.{ verbose; ocamlc_cmdline; mode } = Cmdline.parse () in
    match mode with
    | Compileonly ->
       ocamlc
         ~verbose ocamlc_cmdline
    | Fullprocess { acme_cmdline; prgfile; externs; top_of_mem; stack_pages } ->
       let bytefile = Filename.temp_file ~temp_dir:"." prgfile ".bc~" in
       let asmfile  = Filename.temp_file ~temp_dir:"." prgfile ".asm~" in
       ocamlc
         ~bytefile ~verbose ocamlc_cmdline;
       Export.export
         ~bytefile ~asmfile ~stack_pages ~top_of_mem ~prgfile ~externs;
       acme
         ~verbose ~asmfile acme_cmdline;
       (try Sys.remove bytefile with _ -> ());
       (try Sys.remove asmfile with _ -> ())
  with Sys_error err ->
    Printf.eprintf "Sys_error: %s\n%!" err;
    exit 1
