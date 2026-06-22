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

let clean code =
  let f i bc =
    match bc with
      | BRANCH ptr | BRANCHIF ptr | BRANCHIFNOT ptr | COMPBRANCH (_, _, ptr) ->
        if ptr = i + 1 then code.(i) <- Step1.nop;
      | _ -> ()
  in
  Array.iteri f code;
;;
