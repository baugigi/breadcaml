(* ——————————————————————————————————————————————————————————————————————
   Progetto BreadCaml / The BreadCaml Project
                                     SOFTWARE DI TERZI/3RD PARTY SOFTWARE
   OCamlclean
     Origine/Source: https://github.com/bvaugon/ocamlclean
     Copyright (C) 2015 Benoît Vaugon
     Integrazione in BreadCaml/Integration into BreadCaml:
     Copyright (C) 21-Apr-2026 Piero Furiesi

   Questo file  è distribuito  nei termini della  licenza CeCILL  (il cui
   testo  è riportato  in src/breadcaml/ocamlclean/CeCILL-LICENSE-fr,  in
   lingua francese,  e in  src/breadcaml/ocamlclean/CeCILL-LICENSE-en, in
   lingua  inglese).   L'art.   5.3.4   di  detta  licenza   ne  consente
   l'integrazione nel  Progetto BreadCaml e la  sua ridistribuzione sotto
   licenza GNU GPL.

   This file  is distributed under the  terms of the CeCILL  License (the
   text  of which  is  in src/breadcaml/ocamlclean/CeCILL-LICENSE-fr,  in
   French language, or  in src/breadcaml/ocamlclean/CeCILL-LICENSE-en, in
   English). Article  5.3.4 of that  license allows its  integration into
   The BreadCaml  Project and  its redistribution  under the  GNU General
   Public License.
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

let compute_used code =
  let nb_instr = Array.length code in
  let used = Array.make nb_instr false in
  let rec f i =
    if i < nb_instr && not used.(i) then (
      used.(i) <- true;
      match code.(i) with
        | BRANCH ptr ->
          f ptr
        | BRANCHIF ptr | BRANCHIFNOT ptr | COMPBRANCH (_, _, ptr)
        | PUSH_RETADDR ptr | CLOSURE (_, ptr) | PUSHTRAP ptr ->
          f (succ i);
          f ptr;
        | CLOSUREREC (_, ptrs) ->
          f (succ i);
          Array.iter f ptrs;
        | SWITCH (iptrs, pptrs) ->
          Array.iter f iptrs;
          Array.iter f pptrs;
        | GRAB _ -> f (pred i) ; f (succ i)
        | RETURN _ | APPTERM (_, _) | STOP | RAISE | RERAISE | RAISE_NOTRACE -> ()
        | _ ->
          f (succ i)
    )
  in
  f 0;
  used
;;

let clean_code code used =
  let nb_instr = Array.length code in
  for i = 0 to nb_instr - 1 do
    if not used.(i) then code.(i) <- Step1.nop;
  done
;;

let clean code =
  let used = compute_used code in
  clean_code code used;
;;
