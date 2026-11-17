(* ——————————————————————————————————————————————————————————————————————
   Progetto BreadCaml / The BreadCaml Project
   Copyright (C) 21-Apr-2026 Piero Furiesi

                                     SOFTWARE DI TERZI/3RD PARTY SOFTWARE
   OCaml Core System                   (C) 1996 INRIA <https://ocaml.org>

   Modifiche/Modifications: 21-Apr-2026 Piero Furiesi

   Questo file è distribuito nei  termini della GNU LESSER GENERAL PUBLIC
   LICENSE (LGPL) versione 2.1, con l’eccezione indicata nel file LICENSE
   (in inglese).
   Modifiche: il codice originale  escluso tramite commentatura è incluso
   tra (*-- e --*); (*++ e  ++*) delimitano il nuovo codice; il marcatore
   {i {b BreadCaml Note} testo…  } indica nuovi commenti di OCamldoc.

   This file  is distributed under  the terms  of the GNU  LESSER GENERAL
   PUBLIC LICENSE  (LGPL) version 2.1,  with the exception stated  in the
   LICENSE  file.
   Modifications:  (*-- and  --*)  enclose original  code  that has  been
   commented out; (*++  and ++*) delimit new code  sections; new OCamldoc
   comments are marked with: {i {b BreadCaml Note} text…  }.
   —————————————————————————————————————————————————————————————————————— *)
  module Make : functor (Ord : OrderedType) -> S
    with type elt = Ord.t
     and type t = Set.Make(Ord).t
