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

module Petscii = Petscii

module Int : sig
  include module type of Int
  external div_mod : int -> int -> int * int = "caml_nonstd_div_mod"
end

module Float : sig
  include module type of Float
  external sign : float -> int = "caml_nonstd_sign_float"
end
