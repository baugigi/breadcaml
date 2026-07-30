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

module CtlChar :
  sig
    val up : char
    val dn : char
    val lf : char
    val rt : char
    val blk : char
    val wht : char
    val red : char
    val cyn : char
    val pur : char
    val grn : char
    val lgrn : char
    val blu : char
    val lblu : char
    val yel : char
    val org : char
    val brn : char
    val lred : char
    val pnk : char
    val dgry : char
    val mgry : char
    val lgry : char
    val rvson : char
    val rvsoff : char
    val swon : char
    val swoff : char
    val lcase : char
    val ucase : char
    val f1 : char
    val f2 : char
    val f3 : char
    val f4 : char
    val f5 : char
    val f6 : char
    val f7 : char
    val f8 : char
    val stop : char
    val ret : char
    val shret : char
    val home : char
    val clr : char
    val del : char
    val inst : char
    val shspc : char
    val run : char
    val nul : char
    val cbm : char -> char
    val ctl : char -> char
  end
module CommonGlyph :
  sig
    val under : char
    val upper : char
    val bhl : char
    val chl : char
    val thl : char
    val lvl : char
    val cvl : char
    val rvl : char
    val bb1 : char
    val bb2 : char
    val bb3 : char
    val bb4 : char
    val tb1 : char
    val tb2 : char
    val tb3 : char
    val lb2 : char
    val lb3 : char
    val lb4 : char
    val rb2 : char
    val rb3 : char
    val tlc : char
    val trc : char
    val blc : char
    val brc : char
    val utj : char
    val dtj : char
    val ltj : char
    val rtj : char
    val fwj : char
    val tlq : char
    val trq : char
    val blq : char
    val brq : char
    val tlbrq : char
    val sh : char
    val bsh : char
    val lsh : char
    val pound : char
    val uarr : char
    val larr : char
  end
module UcaseGlyph :
  sig
    val under : char
    val upper : char
    val bhl : char
    val chl : char
    val thl : char
    val lvl : char
    val cvl : char
    val rvl : char
    val bb1 : char
    val bb2 : char
    val bb3 : char
    val bb4 : char
    val tb1 : char
    val tb2 : char
    val tb3 : char
    val lb2 : char
    val lb3 : char
    val lb4 : char
    val rb2 : char
    val rb3 : char
    val tlc : char
    val trc : char
    val blc : char
    val brc : char
    val utj : char
    val dtj : char
    val ltj : char
    val rtj : char
    val fwj : char
    val tlq : char
    val trq : char
    val blq : char
    val brq : char
    val tlbrq : char
    val sh : char
    val bsh : char
    val lsh : char
    val pound : char
    val uarr : char
    val larr : char
    val spd : char
    val hea : char
    val clb : char
    val dmd : char
    val hl0 : char
    val hl1 : char
    val hl2 : char
    val hl3 : char
    val hl4 : char
    val hl5 : char
    val hl6 : char
    val vl0 : char
    val vl1 : char
    val vl2 : char
    val vl3 : char
    val vl4 : char
    val vl5 : char
    val vl6 : char
    val tlec : char
    val trec : char
    val blec : char
    val brec : char
    val tlrc : char
    val trrc : char
    val blrc : char
    val brrc : char
    val tlt : char
    val trt : char
    val tld : char
    val bld : char
    val cross : char
    val circ : char
    val ring : char
    val pi : char
  end
module LcaseGlyph :
  sig
    val under : char
    val upper : char
    val bhl : char
    val chl : char
    val thl : char
    val lvl : char
    val cvl : char
    val rvl : char
    val bb1 : char
    val bb2 : char
    val bb3 : char
    val bb4 : char
    val tb1 : char
    val tb2 : char
    val tb3 : char
    val lb2 : char
    val lb3 : char
    val lb4 : char
    val rb2 : char
    val rb3 : char
    val tlc : char
    val trc : char
    val blc : char
    val brc : char
    val utj : char
    val dtj : char
    val ltj : char
    val rtj : char
    val fwj : char
    val tlq : char
    val trq : char
    val blq : char
    val brq : char
    val tlbrq : char
    val sh : char
    val bsh : char
    val lsh : char
    val pound : char
    val uarr : char
    val larr : char
    val rsh : char
    val tlsh : char
    val blsh : char
    val check : char
  end

include module type of CtlChar
include module type of CommonGlyph
include module type of UcaseGlyph
include module type of LcaseGlyph

val of_char : char -> char
val of_string : string -> string
