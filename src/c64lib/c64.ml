(* ——————————————————————————————————————————————————————————————————————
   The BreadCaml Project / Progetto BreadCaml
   Copyright (C) 21-Apr-2026 Piero Furiesi
   
   This program is  free software; you can redistribute  it and/or modify
   it under the terms of the  GNU GENERAL PUBLIC LICENSE (GPL) version 2,
   as specified in the LICENSE-en file in the project root folder.
   
   Questo  programma  è software  libero;  può  essere ridistribuito  e/o
   modificato nei termini della GNU GENERAL PUBLIC LICENSE (GPL) versione
   2, come specificato nel file  LICENZA-it nella cartella principale del
   progetto.
   —————————————————————————————————————————————————————————————————————— *)

(* Facade: every submodule lives in its own compilation unit (c64_*.ml), so
   that ocamlclean can discard the unused ones. The aliases below cost nothing
   at run time. *)

module Hw = C64_hw
module Key = C64_key
module Screen = C64_screen
module Gfx = C64_gfx
module Sprite = C64_sprite
module Sound = C64_sound
module Mcu = C64_mcu
module Disk = C64_disk
module Sd2iec = C64_sd2iec
