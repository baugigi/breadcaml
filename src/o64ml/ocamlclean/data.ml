(* ——————————————————————————————————————————————————————————————————————
   Progetto O64ml / The O64ml Project
                                     SOFTWARE DI TERZI/3RD PARTY SOFTWARE
   OCamlclean       
     Origine/Source: https://github.com/bvaugon/ocamlclean
     Copyright (C) 2015 Benoît Vaugon
     Integrazione in O64ml/Integration into O64ml:
     Copyright (C) 21-Apr-2026 Piero Furiesi

   Questo file  è distribuito  nei termini della  licenza CeCILL  (il cui
   testo è riportato in src/o64ml/ocamlclean/CeCILL-LICENSE-fr, in lingua
   francese,  e  in   src/o64ml/ocamlclean/CeCILL-LICENSE-en,  in  lingua
   inglese).  L'art.  5.3.4 di  detta licenza ne  consente l'integrazione
   nel Progetto O64ml e la sua ridistribuzione sotto licenza GNU GPL.

   This file  is distributed under the  terms of the CeCILL  License (the
   text of which is in src/o64ml/ocamlclean/CeCILL-LICENSE-fr, in French,
   or  in src/o64ml/ocamlclean/CeCILL-LICENSE-en,  in English).   Article
   5.3.4 of  that license allows  its integration into The  O64ml Project
   and its redistribution under the GNU General Public License.
   —————————————————————————————————————————————————————————————————————— *)

(*************************************************************************)
(*                                                                       *)
(*                              OCamlClean                               *)
(*                                                                       *)
(*                             Benoit Vaugon                             *)
(*                                                                       *)
(*    This file is distributed under the terms of the CeCILL license.    *)
(*    See file CeCILL-LICENSE-en.                                        *)
(*                                                                       *)
(*************************************************************************)

open OByteLib.Normalised_instr

exception Exn of string

let parse ic index =
  let (offset, _) =
    try
      OByteLib.Index.find_section index OByteLib.Section.DATA
    with Not_found ->
      raise (Exn "code section not found")
  in
  seek_in ic offset;
  let (data : Obj.t array) = input_value ic in
  data
;;

let clean code orig_data =
  let nb_data = Array.length orig_data in
  let nb_instr = Array.length code in
  let map = Array.make nb_data None in
  let invmap = Array.make nb_data 0 in
  let counter = ref 12 in
  let remap p =
    match map.(p) with
      | None ->
        let new_p = !counter in
        counter := succ new_p;
        map.(p) <- Some new_p;
        invmap.(new_p) <- p;
        new_p
      | Some new_p -> new_p
  in
  for i = 0 to !counter - 1 do
    map.(i) <- Some i;
    invmap.(i) <- i;
  done;
  for i = 0 to nb_instr - 1 do
    match code.(i) with
      | GETGLOBAL p -> code.(i) <- GETGLOBAL (remap p);
      | _ -> ()
  done;
  for i = 0 to nb_instr - 1 do
    match code.(i) with
      | SETGLOBAL p ->
        begin match map.(p) with
          | None -> code.(i) <- Step1.nop;
          | Some new_p -> code.(i) <- SETGLOBAL new_p;
        end
      | _ -> ()
  done;
  let new_data = Array.init !counter (fun p -> orig_data.(invmap.(p))) in
  new_data
;;

let export oc data =
  output_value oc data;
;;
