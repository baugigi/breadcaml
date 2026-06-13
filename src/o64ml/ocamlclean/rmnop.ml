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

let compute_map orig_code =
  let nb_instr = Array.length orig_code in
  let map = Array.make nb_instr 0 in
  let rec f i j =
    if i < nb_instr then (
      map.(i) <- j;
      if orig_code.(i) = Step1.nop
      then f (succ i) j
      else f (succ i) (succ j)
    )
  in
  f 0 0;
  map
;;

let compress orig_code map =
  let orig_size = Array.length orig_code in
  let new_size = map.(Array.length map - 1) + 1 in
  let new_code = Array.make new_size Step1.nop in
  for i = 0 to orig_size - 1 do
    if orig_code.(i) <> Step1.nop
    then new_code.(map.(i)) <- orig_code.(i);
  done;
  new_code
;;

let clean orig_code =
  let map = compute_map orig_code in
  let new_code = compress orig_code map in
  Array.map (Step1.remap_instr map) new_code
;;
