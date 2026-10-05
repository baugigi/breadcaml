(**************************************************************************)
(*                                                                        *)
(*                                 OCaml                                  *)
(*                                                                        *)
(*             Xavier Leroy, projet Cristal, INRIA Rocquencourt           *)
(*                                                                        *)
(*   Copyright 1996 Institut National de Recherche en Informatique et     *)
(*     en Automatique.                                                    *)
(*                                                                        *)
(*   All rights reserved.  This file is distributed under the terms of    *)
(*   the GNU Lesser General Public License version 2.1, with the          *)
(*   special exception on linking described in the file LICENSE.          *)
(*                                                                        *)
(**************************************************************************)

(** Character operations. *)

(*++ *)
(** Characters are the elements of [string] and [bytes] values; they represent
    bytes (8-bit integers), that is, each [char] value corresponds one-to-one to
    an integer between 0 and 255. The integer represented by a [char] value is
    its "character code". BreadCaml runtime and library functions use the
    {b PETSCII encoding}, unless otherwise specified.

    {1 Pre-processing of character literals}

    The Breadcaml preprocessor translates [char] literals to PETSCII, according
    to the following rules:
    - Letters are translated to the {{!classify} typeable} PETSCII characters
    with the corresponding glyphs of the {{!charset} shifted character set};
    - The characters ['_'] and ['|'] are translated to ['\164'] «[▁]» and
    ['\221'] «[│]», respectively;
    - Other characters are mapped to themselves.

    The following definitions apply:
    
    {1:charset PETSCII character sets}
      
    - {b Unshifted set:} the Commodore 64 startup character set, also called
    "Uppercase/Graphics". When this set is active, pressing an alphabetic key
    displays a capital letter, while pressing it along with «SHIFT» displays the
    graphic glyph shown on the right on the front face of the key.
    - {b Shifted set:} the character set that is obtained by pressing the
    SHIFT+CBM key combination once when the unshifted set is active, also called
    "Lowercase/Uppercase". When this set is active, pressing an alphabetic key
    displays a lowercase letter, while pressing it along with «SHIFT» displays
    an uppercase letter. {b This is the default character set for the BreadCaml
    runtime environment and library functions.}

    {1:classify PETSCII character classification}

    - {b Control character:} a character with a code in the ranges 0-31 or
    128-159.  Control characters have no associated glyphs (although they can be
    represented by "reverse" glyphs when the Commodore 64 is in "quote mode" or
    "insert mode").
    - {b Letter:} a character whose glyph is a letter.
    - {b Digit:} a character whose glyph is a decimal digit.
    - {b Whitespace:} the space character [' '] and the control character
    ['\r'].
    
    - {b Symbol:} a character with a code in the ranges
    {ul
    {- 33-47 (['!'], ['"'], ['#'], ['$'], ['%'], ['&'], ['\''], ['('], [')'],
    ['*'], ['+'], [','], ['-'], ['.'], ['/']),}
    {- 58-64 ([':'], [';'], ['<'], ['='], ['>'], ['?'], ['\@']),}
    {- 91-95 (['\['], ['\092'] «[£]», ['\]'], ['\094'] «[↑]», ['\095'] «[←]»).}}
    - {b Graphic character:} any other character different from the preceding
    ones.
    - {b Printable character:} a character associated with a glyph, even if
    empty. All characters are printable, except for control characters.
    - {b Duplicate character:} a character whose code is in the ranges {b
    96-127} or {b 224-255}. Duplicate characters display the same glyphs as the
    corresponding characters in the ranges {b 192-223} and {b 160-190}.
    Notably, ['\126'] and ['\255'] are both duplicates of ['\222'] («[🮖]», or
    «[π]» in the unshifted set).
    - {b Typeable character:} a character which can be generated from the
    Commodore 64 keyboard. All characters are typeable, except for duplicate
    ones.
*)

external code : char -> int = "%identity"
(** [code c] is the 8-bit integer associated with the character [c]. *)

val chr : int -> char
(** [chr i] is the character associated with the integer [i].
    @raise Invalid_argument if the argument is outside the range 0-255. *)

val is_control: char -> bool
(** [is_control c] is [true] if and only if [c] is a {{!classify} control
    character}. *)

val is_letter: char -> bool
(** [is_letter c] is [true] if and only if [c] is a {{!classify} letter}. *)

val is_upper: char -> bool
(** [is_upper c] is [true] if and only if [c] is an uppercase {{!classify}
    letter}. *)

val is_lower: char -> bool
(** [is_lower c] is [true] if and only if [c] is a lowercase {{!classify}
    letter}. *)

val is_digit: char -> bool
(** [is_digit c] is [true] if and only if [c] is a {{!classify} digit}. *)

val is_alphanum: char -> bool
(** [is_alphanum c] is [true] if and only if [c] is a {{!classify} letter} or a
    {{!classify} digit}. *)

val is_white: char -> bool
(** [is_white c] is [true] if and only if [c] is a {{!classify} whitespace
    character}. *)

val is_symbol: char -> bool
(** [is_symbol c] is [true] if and only if [c] is a {{!classify} symbol}. *)

val is_graphic: char -> bool
(** [is_graphic c] is [true] if and only if [c] is a {{!classify} graphic
    character}. *)

val is_print: char -> bool
(** [is_print c] is [true] if and only if [c] is a {{!classify} printable
    character}. *)

val is_type: char -> bool
(** [is_type c] is [true] if and only if [c] is a {{!classify} typeable
    character}. *)

val is_dup: char -> bool
(** [is_dup c] is [true] if and only if [c] is a {{!classify} duplicate
    character}. *)

val dup: char -> char option
(** [dup c] is [Some d] if [d] is the {{!classify} duplicate} of [c], else
    [None]. If [c] is ['\222'], which has two duplicates ['\126'] and ['\255'],
    [dup c] returns [Some '\126']. *)

val org: char -> char option
(** [org d] is [Some c] if [d] is a {{!classify} duplicate} of [c], else
    [None]. *)

val lowercase_petscii : char -> char
(** [lowercase_petscii c] is the character corresponding to the {{!classify}
    letter} [c] converted to lowercase; if [c] is not a letter, then
    [lowercase_petscii c] is [c]. *)

val uppercase_petscii : char -> char
(** [uppercase_petscii c] is the {{!classify} typeable character} corresponding
    to the {{!classify} letter} [c] converted to uppercase; if [c] is not a
    letter, then [uppercase_petscii c] is [c].

    Note that [uppercase_petscii(lowercase_petscii c)] <> [c] if and only if [c]
    is a duplicate letter character. *)

(** {1 Deprecated functions}

    These functions are here only for compatibility with the original OCaml
    [Char] module.
*)

val escaped : char -> string
  [@@ocaml.deprecated "Use [Char.Ascii.escaped] instead."]
(** Return a string representing the given character, with special characters
    escaped following the lexical conventions of OCaml. All characters outside
    the ASCII printable range (32..126) are escaped, as well as backslash, and
    single-quote.
    @deprecated Use the functions in the {!Ascii} module to operate on
      the ASCII character set. *)

val lowercase : char -> char
  [@@ocaml.deprecated "Use [lowercase_petscii] instead."]
(** [lowercase] is an alias for {!lowercase_petscii}.
    @deprecated Use the functions in the {!Ascii} module to operate on
      the ASCII character set. *)

val uppercase : char -> char
  [@@ocaml.deprecated "Use [uppercase_petscii] instead."]
(** [uppercase] is an alias for {!uppercase_petscii}.
    @deprecated Use the functions in the {!Ascii} module to operate on
      the ASCII character set. *)

val lowercase_ascii : char -> char
  [@@ocaml.deprecated "Use [lowercase_petscii] instead."]
(** [lowercase_ascii] is an alias for {!lowercase_petscii}.
    @deprecated Use the functions in the {!Ascii} module to operate on
      the ASCII character set. *)

val uppercase_ascii : char -> char
  [@@ocaml.deprecated "Use [uppercase_petscii] instead."]
(** [uppercase_ascii] is an alias for {!uppercase_petscii}.
    @deprecated Use the functions in the {!Ascii} module to operate on
      the ASCII character set. *)

(** {1 Operations on the ASCII and Latin-1 character sets} *)

(** Operations on the US-ASCII and ISO Latin-1 (8859-1) character sets.

    Useful for data conversion and communication outside the Commodore 64
    world. *)
module Ascii: sig
(* ++*)

  val escaped : char -> string
  (** Return a string representing the given character,
      with special characters escaped following the lexical conventions
      of OCaml.
      All characters outside the ASCII printable range (32..126) are
      escaped, as well as backslash, and single-quote. *)

  val lowercase : char -> char
    [@@ocaml.deprecated (*-- "Use Char.lowercase_ascii instead." --*)
     (*++ *) "Use Char.Ascii.lowercase_ascii instead." (* ++*)]
  (** Convert the given character to its equivalent lowercase character,
      using the ISO Latin-1 (8859-1) character set.
      @deprecated Functions operating on Latin-1 character set are deprecated. *)
 
  val uppercase : char -> char
   [@@ocaml.deprecated (*-- "Use Char.uppercase_ascii instead." --*)
    (*++ *) "Use Char.Ascii.uppercase_ascii instead." (* ++*)]
  (** Convert the given character to its equivalent uppercase character,
      using the ISO Latin-1 (8859-1) character set.
      @deprecated Functions operating on Latin-1 character set are deprecated. *)

  val lowercase_ascii : char -> char
  (** Convert the given character to its equivalent lowercase character,
      using the US-ASCII character set.
      @since 4.03.0 *)

  val uppercase_ascii : char -> char
  (** Convert the given character to its equivalent uppercase character,
      using the US-ASCII character set.
      @since 4.03.0 *)

(*++ *)
  val to_petscii: char -> char
  (** Translate the argument from ASCII to PETSCII, according to the following
      mapping:
      - Letters are translated to the typeable PETSCII characters with the
      corresponding glyphs;
      - The characters ['_'] and ['|'] are translated to ['\164'] «[▁]» and
      ['\221'] «[│]», respectively;
      - Other ASCII characters and those with code from 128 to 255 are mapped to
      themselves. *)

  val of_petscii: char -> char
  (** Translate the argument from PETSCII to ASCII, according to the following
      mapping:
      - PETSCII letters (both typeable and duplicate characters) are translated
      to the ASCII characters with the corresponding glyphs;
      - The characters ['\164'] «[▁]» and ['\221'] «[│]» are translated to ['_']
      and ['|'], respectively;
      - Other characters are mapped to themselves. *)
end

(** {1 PETSCII memonic constants} *)

(** The following modules define several mnemonic constants to easily reference
    PETSCII characters and their associated glyphs:
    - {!Shifted} and {!Unshifted} modules provide mmnemonics for the {{!charset}
    shifted} and {{!charset} unshifted} character sets, respectively;
    - {!Control} is the subset of mnemonics referencing {{!classify} control
    characters};
    - {!ShiftedOnly} and {!UnshiftedOnly} modules are the subsets of mnemonics
    referencing glyphs available in the {{!charset} shifted} or {{!charset}
    unshifted} character sets only;
    - {!Common} is the subsets of mnemonics referencing glyphs available in both
    the {{!charset} shifted} and {{!charset} unshifted} character sets.
 *)

(** Mnemonic constants for PETSCII control characters *)
module Control : sig

  (** {2 cursor movements} *)

  val up : char
  val dn : char
  val lf : char
  val rt : char

  (** {2 colours} *)

  val blk : char
  val wht : char
  val red : char
  val cyn : char
  val pur : char
  val grn : char
  val blu : char
  val yel : char
  val org : char
  val brn : char
  val pnk : char
  val lgrn : char
  val lblu : char
  val dgry : char
  val mgry : char
  val lgry : char

  (** {2 character sets} *)

  (** {3 enable/disable reverse mode} *)			

  val rvson : char
  val rvsoff : char

  (** {3 enable/disable set switching} *)	

  val swon : char
  val swoff : char

  (** {3 charset selection} *)		

  val lcase : char
  val ucase : char

  (** {2 function keys} *)

  val f1 : char
  val f2 : char
  val f3 : char
  val f4 : char
  val f5 : char
  val f6 : char
  val f7 : char
  val f8 : char

  (** {2 other keys} *)

  (** RUN/STOP *)	
  val stop : char

  (** SHIFT+RUN/STOP *)	
  val run : char

  (** RETURN *) 	
  val cr : char

  (** CLR/HOME *)	
  val home : char

  (** SHIFT+CLR/HOME *)	
  val clr : char

  (** INST/DEL *)	
  val del : char

  (** SHIFT+INST/DEL *)	
  val inst : char

  (** SHIFT+SPACE BAR *)	
  val shf_spc : char

  (** SHIFT+RETURN *)	
  val shf_cr : char

  (** CTL+LEFT ARROW *)	
  val ctl_larw : char

  (** CTL+UP ARROW *)	
  val ctl_uarw : char

  (** CTL+POUND *)  	
  val ctl_pound : char

  (** {2 misc} *)

  (** NULL *)		
  val nul : char
end

(** Mnemonic constants for glyphs available in both character sets *)
module Common : sig

  (** {2 one-pixel-wide lines} *)

  (** [▁] underscore *)	
  val under : char

  (** [▔] upperscore *)	
  val upper : char

  (** {2 two-pixel-wide lines} *)

  (** [🮂] top horizontal line *)		
  val thl : char

  (** [🭲] central horizontal line *)	
  val chl : char

  (** [▂] bottom horizontal line *)		
  val bhl : char

  (** [▏] left vertical line *)		
  val lvl : char

  (** [🭲] central vertical line *)		
  val cvl : char

  (** [🮇] right vertical line *)		
  val rvl : char

  (** {i alternate characters} *)

  (** same glyph as {!lvl} *)		
  val lvl_ : char

  (** same glyph as {!rvl} *)		
  val rvl_ : char

  (** {2 blocks} *)

  (** [▔] top block, 1 pixel wide *)	
  val tb1 : char

  (** [🮂] top block, 2 pixel wide *)	
  val tb2 : char

  (** [🮃] top block, 3 pixel wide *)	
  val tb3 : char

  (** [▁] bottom block, 1 pixel wide *)	
  val bb1 : char

  (** [▂] bottom block, 2 pixel wide *)	
  val bb2 : char

  (** [▃] bottom block, 3 pixel wide *)	
  val bb3 : char

  (** [▄] bottom block, 4 pixel wide *)	
  val bb4 : char

  (** [▎] left block, 2 pixel wide *)	
  val lb2 : char

  (** [▍] left block, 3 pixel wide *)	
  val lb3 : char

  (** [▌] left block, 4 pixel wide *)	
  val lb4 : char

  (** [🮇] right block, 2 pixel wide *)	
  val rb2 : char

  (** [🮈] right block, 3 pixel wide *)	
  val rb3 : char

  (** {2 corners} *)

  (** [┌] top left corner *)		
  val tlc : char

  (** [┐] top right corner *)		
  val trc : char

  (** [└] bottom left corner *)		
  val blc : char

  (** [┘] bottom right corner *)		
  val brc : char

  (** {2 junctions} *)

  (** [┴] upward pointing T-junction *) 	
  val utj : char

  (** [┬] downward pointing T-junction *)	
  val dtj : char

  (** [┤] left pointing T-junction *)	
  val ltj : char

  (** [├] right-pointing T-junction *)	
  val rtj : char

  (** [┼] four-way junction (big '+') *)	
  val fwj : char

  (** {2 quadrants} *)

  (** [▘] top-left quadrant *)		
  val tlq : char

  (** [▝] top-right quadrant *)		
  val trq : char

  (** [▖] bottom-left quadrant *)		
  val blq : char

  (** [▗] bottom-right quadrant *)		
  val brq : char

  (** [▚] top-left, bottom-right quads *)	
  val tlbrq : char

  (** {2 checker shades} *)

  (** [🮕] checker *)			
  val chk : char

  (** [🮌] left half checker *)		
  val lchk : char

  (** [🮏] bottom half checker *)		
  val bchk : char

  (** {2 misc} *)

  (** [£] British Pound sign *)		
  val pound : char

  (** [↑] up arrow *)			
  val uarw : char

  (** [←] left arrow *)			
  val larw : char
end

(** Mnemonic constants for glyphs available only in the shifted set *)
module ShiftedOnly : sig

  (** {2 checker shades} *)

  (** [🮖] inverse checker shade *)		
  val ichk : char

  (** {2 diagonal hatches} *)

  (** [🮙] ascending diagonal hatch *) 	
  val adh : char

  (** [🮘] descending diagonal hatch *) 	
  val ddh : char

  (** {2 misc} *)

  (** [✓] check mark, tick *)		
  val cmk : char
end

(** Mnemonic constants for glyphs available only in the unshifted set *)
module UnshiftedOnly : sig

  (** {2 card suits} *)

  (** [♠] spade suit *) 	
  val spd : char

  (** [♥] heart suit *) 	
  val hea : char

  (** [♣] club suit *)  	
  val clb : char

  (** [♦] diamond suit *)	
  val dmd : char

  (** {2 two-pixel-wide lines} *)

  (** [▂] horizontal line, at bottom edge *)	
  val hl0 : char

  (** [🭻] horizontal line, 1 px from bottom edge *)	
  val hl1 : char

  (** [🭺] horizontal line, 2 px from bottom edge *)	
  val hl2 : char

  (** [🭸] horizontal line, 3 px from bottom edge *)	
  val hl3 : char

  (** [🭷] horizontal line, 4 px from bottom edge *)	
  val hl4 : char

  (** [🭶] horizontal line, 5 px from bottom edge *)	
  val hl5 : char

  (** [🮂] horizontal line, 6 px from bottom edge *)	
  val hl6 : char

  (** [▎] vertical line, at left edge *)    	
  val vl0 : char

  (** [🭰] vertical line, 1 px from left edge *)	
  val vl1 : char

  (** [🭱] vertical line, 2 px from left edge *)	
  val vl2 : char

  (** [│] vertical line, 3 px from left edge *)	
  val vl3 : char

  (** [🭴] vertical line, 4 px from left edge *)	
  val vl4 : char

  (** [🭵] vertical line, 5 px from left edge *)	
  val vl5 : char

  (** [🮇] vertical line, 6 px from left edge *)	
  val vl6 : char

  (** {2 edge corners} *)

  (** [🭽] top left edge corner *)   	
  val tlec : char

  (** [🭾] top right edge corner *)  	
  val trec : char

  (** [🭼] bottom left edge corner *)	
  val blec : char

  (** [🭿] bottom right edge corner *)	
  val brec : char

  (** {2 rounded corners} *)

  (** [╭] top left rounded corner *)   	
  val tlrc : char

  (** [╮] top right rounded corner *)   	
  val trrc : char

  (** [╰] bottom left rounded corner *)   	
  val blrc : char

  (** [╯] bottom right rounded corner *)   	
  val brrc : char

  (** {2 triangles} *)

  (** [◤] top left triangle *)		
  val tlt : char

  (** [◥] top right triangle *)		
  val trt : char

  (** {2 diagonal lines} *)

  (** [╱] ascending diagonal line *)	
  val adl : char

  (** [╲] descending diagonal line *)	
  val ddl : char

  (** [╳] diagonal cross (big 'X') *)	
  val cross : char

  (** {2 circular glyphs} *)

  (** [●] disk, solid circle *)		
  val disk : char

  (** [○] ring, hollow circle *)		
  val ring : char

  (** {2 misc} *)

  (** [π] Greek small letter pi *)		
  val pi : char
end

(** Mnemonic constants for the shifted character set *)
module Shifted : sig
  include module type of Control 
  include module type of Common
  include module type of ShiftedOnly
end

(** Mnemonic constants for the unshifted character set *)
module Unshifted : sig
  include module type of Control
  include module type of Common
  include module type of UnshiftedOnly
end



(** {1 Comparison and equality} *)
(* ++*)

type t = char

(** An alias for the type of characters. *)

val compare: t -> t -> int
(** The comparison function for characters, with the same specification as
    {!Stdlib.compare}.  Along with the type [t], this function [compare]
    allows the module [Char] to be passed as argument to the functors
    {!Set.Make} and {!Map.Make}. *)

val equal: t -> t -> bool
(** The equal function for chars.
    @since 4.03.0 *)

(**/**)

(* The following is for system use only. Do not call directly. *)

external unsafe_chr : int -> char = "%identity"
