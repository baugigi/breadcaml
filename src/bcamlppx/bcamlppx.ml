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

(* PPX rewriter for BreadCaml *)

open Ast_mapper

let self = Sys.argv.(0)
let bn_self = Filename.basename self

let usage () =
  Printf.printf
    "%s - The BreadCaml preprocessor.\n\
     Usage:\t%s <db_file> <in_file> <out_file>\n\
     \t%s -d|--dump <db_file>\n\
     \t%s -h|-help|--help\n\
     Read the AST from <in_file>, pre-process it using the <db_file> database\n\
     and save the resulting AST in <out_file>.\n\
     \n\
     Options:\n\
     \  -d, --dump <db_file>\n\
     \tshow the list of polymorphic variant renamings saved in <db_file>\n\
     \  -h, -help, --help\n\
     \tprint this message\n"
    bn_self bn_self bn_self bn_self

let petscii_mapper _argv = PetsciiPPX.mapper
let polyvar_mapper _argv = PolyvarPPX.mapper

let run_petscii_mapper infile outfile =
  run_main (fun _ -> petscii_mapper [| self; infile; outfile |])
  
let run_polyvar_mapper dbfile infile outfile =
  let fd = Unix.(openfile dbfile [O_RDWR; O_CREAT] 0o666) in
  Unix.(lockf fd F_LOCK 0);
  begin (* critical section *)
    if Unix.((fstat fd).st_size) > 0 then
      PolyvarPPX.db_load (Unix.in_channel_of_descr fd);
    run_main (fun _ -> polyvar_mapper [| self; infile; outfile |]);
    ignore Unix.(lseek fd 0 SEEK_SET);
    Unix.ftruncate fd 0;
    PolyvarPPX.db_save (Unix.out_channel_of_descr fd);
  end; (* critical section *)
  Unix.(lockf fd F_ULOCK 0);
  Unix.close fd

let () =
  match Sys.argv with
  | [| self; dbfile; infile; outfile |] ->
     (* temp file for mapper-to-mapper AST piping  *)
     (try
        let (tmpfile, tmpch) =
          Filename.open_temp_file ~mode:[Open_binary] "bcamlppx" ".ast" in
        (* Run polyvar_mapper, output to temp file *)
        Unix.handle_unix_error run_polyvar_mapper dbfile infile tmpfile;
        flush tmpch;
        (* Run petscii_mapper, input from temp file *)
        run_petscii_mapper tmpfile outfile;
        (* Delete temp file *)
        Sys.remove tmpfile
      with
      | Sys_error err ->
         Printf.eprintf "%s: %s\n%!" self err;
         exit 1
      | _ ->
         Printf.eprintf "%s: Unknown error\n%!" self;
         exit 1)
  | [| _; o; dbfile |] when List.mem o ["-d"; "--dump"] ->
     Unix.handle_unix_error
       (fun file -> 
         let fd = Unix.(openfile file [O_RDONLY; O_NONBLOCK] 0o666) in
         PolyvarPPX.db_dump (Unix.in_channel_of_descr fd) stdout;
         Unix.close fd)
       dbfile
  | [| _; o |] when List.mem o ["-h"; "-help"; "--help"] ->
     usage ();
     exit 0
  | _ ->
     Printf.eprintf
       "Illegal option or argument in command line:\n«%s»\n\n%!"
       (String.concat " " (Array.to_list Sys.argv));
     usage ();
     exit 1
