(* ----------------------------------------------------------------------
   Progetto BreadCaml / The BreadCaml Project
   Copyright (C) 21-Apr-2026 Piero Furiesi

   Questo  programma è  software libero;  è possibile  ridistribuirlo e/o
   modificarlo secondo i  termini della GNU General  Public License (GPL)
   versione  2,  come specificato  nel  file  LICENZA-it nella  directory
   principale del progetto.

   This program is  free software; you can redistribute  it and/or modify
   it under the terms of the  GNU General Public License (GPL) version 2,
   as specified in the LICENSE-en file in the project root.
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
