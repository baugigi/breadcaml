(* ——————————————————————————————————————————————————————————————————————
   The BreadCaml Project / Progetto BreadCaml
   Copyright (C) 21-Apr-2026 Piero Furiesi

                   3RD PARTY SOFTWARE / SOFTWARE DI TERZI
   OCamlclean - (C) Benoît Vaugon <https://github.com/bvaugon/ocamlclean>

   This  file,  originally  distributed  under  the  CeCILL  license,  is
   included in  the BreadCaml Project  and, pursuant to Section  5.3.4 of
   that license —  see LICENSE-fr, in French, or  LICENSE-en, in English,
   in this directory — is redistributed under the GNU GPL version 2.

   Questo file, originariamente distribuito con licenza CeCILL, è incluso
   nel Progetto  BreadCaml e, in  conformità all′Articolo 5.3.4  di detta
   licenza — vedere LICENSE-fr, in francese, o LICENSE-en, in inglese, in
   questa cartella — è ridistribuito con licenza GNU GPL versione 2.
   —————————————————————————————————————————————————————————————————————— *)
(*************************************************************************)
(*                                                                       *)
(*                              OCamlClean                               *)
(*                                                                       *)
(*                             Benoit Vaugon                             *)
(*                                                                       *)
(*    This file is distributed under the terms of the CeCILL license.    *)
(*    See file LICENSE-en.                                               *)
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
