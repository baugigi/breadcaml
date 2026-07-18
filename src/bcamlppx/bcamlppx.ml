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

let bcamlppx _argv =
  { default_mapper with
    expr = (fun m e -> PolyvarPPX.expr_rewriter m (PetsciiPPX.expr_extender m e));
    pat = PolyvarPPX.pat_rewriter;
    typ = PolyvarPPX.typ_rewriter;
    structure_item = PetsciiPPX.struct_item_extender;
    signature_item = PetsciiPPX.sig_item_extender }

let self = Sys.argv.(0)

let () =
  match Sys.argv with
  | [| self; dbfile; infile; outfile |] ->
     let fd = Unix.(openfile dbfile [O_RDWR; O_CREAT] 0o666) in
     Unix.(lockf fd F_LOCK 0);
     begin (* critical section *)
       if Unix.((fstat fd).st_size) > 0 then
         PolyvarPPX.db_load (Unix.in_channel_of_descr fd);
       run_main (fun _ -> bcamlppx [| self; infile; outfile |]);
       ignore Unix.(lseek fd 0 SEEK_SET);
       Unix.ftruncate fd 0;
       PolyvarPPX.db_save (Unix.out_channel_of_descr fd);
     end; (* critical section *)
     Unix.(lockf fd F_ULOCK 0);
     Unix.close fd
  | _ ->
     Printf.eprintf "Usage: %s <db_file> <in_file> <out_file>\n" self;
     exit 1
