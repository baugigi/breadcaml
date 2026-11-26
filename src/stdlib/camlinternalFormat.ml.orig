(**************************************************************************)
(*                                                                        *)
(*                                 OCaml                                  *)
(*                                                                        *)
(*                          Benoit Vaugon, ENSTA                          *)
(*                                                                        *)
(*   Copyright 2014 Institut National de Recherche en Informatique et     *)
(*     en Automatique.                                                    *)
(*                                                                        *)
(*   All rights reserved.  This file is distributed under the terms of    *)
(*   the GNU Lesser General Public License version 2.1, with the          *)
(*   special exception on linking described in the file LICENSE.          *)
(*                                                                        *)
(**************************************************************************)

(* BREADCAML: reduced version of the original module. Not supported (a
   Printf function applied to such a format, or to its arguments, raises
   Invalid_argument): the formats %(..%), %{..%}, %_, %[..], %l %n %L, the
   boxes of Format (@[), the conversions of int32, int64 and nativeint,
   %e %E %h %H %#F, and the "_" separator of %#d. The parser of the format
   strings, the typing of formats and the "iprintf" machinery are removed.
   The formats are still typed by the compiler (the GADT of
   CamlinternalFormatBasics) and the partial applications work as in OCaml.
   The numbers are converted by the primitives caml_nonstd_string_of_int,
   caml_nonstd_fmt_hex and caml_nonstd_fmt_float (they use the BASIC ROM);
   the ints have 15 bits. %g prints like string_of_float (the precision is
   ignored); %f needs |x| * 10^prec < 2^32, otherwise it prints like
   string_of_float. *)

open CamlinternalFormatBasics

(******************************************************************************)
                                (* Types *)

(* Reversed list of printing atoms. *)
(* Used to accumulate printf arguments. *)
type ('b, 'c) acc =
  | Acc_formatting_lit of ('b, 'c) acc * formatting_lit
  | Acc_string_literal of ('b, 'c) acc * string     (* Literal string *)
  | Acc_char_literal   of ('b, 'c) acc * char       (* Literal char *)
  | Acc_data_string    of ('b, 'c) acc * string     (* Generated string *)
  | Acc_data_char      of ('b, 'c) acc * char       (* Generated char *)
  | Acc_delay          of ('b, 'c) acc * ('b -> 'c)
                                                (* Delayed printing (%a, %t) *)
  | Acc_flush          of ('b, 'c) acc              (* Flush *)
  | Acc_invalid_arg    of ('b, 'c) acc * string
      (* Raise Invalid_argument msg *)
  | End_of_acc

(******************************************************************************)
                               (* Externals *)

(* Digits of the 15 bit pattern of an int: base 0 = octal, 1 = hexadecimal
   with the letters of the unshifted PETSCII a..f, 2 = with the shifted ones. *)
external fmt_hex : int -> int -> string = "caml_nonstd_fmt_hex"

(* Fixed notation with prec (0..9) decimals; "" for inf, nan and when
   |x| * 10^prec >= 2^32. *)
external fmt_float : int -> float -> string = "caml_nonstd_fmt_float"

(******************************************************************************)
                          (* Formatting tools *)

(* Escape a string according to the OCaml lexing convention. *)
let string_to_caml_string str =
  let str = String.escaped str in
  let l = String.length str in
  let res = Bytes.make (l + 2) '\"' in
  String.unsafe_blit str 0 res 1 l;
  Bytes.unsafe_to_string res


(* Convert a char to a string according to the OCaml lexical convention. *)
let format_caml_char c =
  let str = Char.Ascii.escaped c in
  let l = String.length str in
  let res = Bytes.make (l + 2) '\'' in
  String.unsafe_blit str 0 res 1 l;
  Bytes.unsafe_to_string res


(* Default precision for float printing. *)
let default_float_precision fconv =
  match snd fconv with
  | Float_f | Float_e | Float_E | Float_g | Float_G | Float_h | Float_H
  | Float_CF -> -6
  (* For %h %H and %#F formats, a negative precision means "as many digits as
     necessary".  For the other FP formats, we take the absolute value
     of the precision, hence 6 digits by default. *)
  | Float_F -> 12
  (* Default precision for OCaml float printing (%F). *)


(* Add padding spaces around a string. *)
let fix_padding padty width str =
  let len = String.length str in
  let width, padty =
    abs width,
    (* while literal padding widths are always non-negative,
       dynamically-set widths (Arg_padding, eg. %*d) may be negative;
       we interpret those as specifying a padding-to-the-left; this
       means that '0' may get dropped even if it was explicitly set,
       but:
       - this is what the legacy implementation does, and
         we preserve compatibility if possible
       - we could only signal this issue by failing at runtime,
         which is not very nice... *)
    if width < 0 then Left else padty in
  if width <= len then str else
    let res = Bytes.make width (if padty = Zeros then '0' else ' ') in
    begin match padty with
    | Left  -> String.blit str 0 res 0 len
    | Right -> String.blit str 0 res (width - len) len
    | Zeros when len > 0 && (str.[0] = '+' || str.[0] = '-' || str.[0] = ' ') ->
      Bytes.set res 0 str.[0];
      String.blit str 1 res (width - len + 1) (len - 1)
    | Zeros when len > 1 && str.[0] = '0' && (str.[1] = 'x' || str.[1] = 'X') ->
      Bytes.set res 1 str.[1];
      String.blit str 2 res (width - len + 2) (len - 2)
    | Zeros ->
      String.blit str 0 res (width - len) len
    end;
    Bytes.unsafe_to_string res


(* Add '0' padding to int, int32, nativeint or int64 string representation. *)
let fix_int_precision prec str =
  let prec = abs prec in
  let len = String.length str in
  match str.[0] with
  | ('+' | '-' | ' ') as c when prec + 1 > len ->
    let res = Bytes.make (prec + 1) '0' in
    Bytes.set res 0 c;
    String.blit str 1 res (prec - len + 2) (len - 1);
    Bytes.unsafe_to_string res
  | '0' when prec + 2 > len && len > 1 && (str.[1] = 'x' || str.[1] = 'X') ->
    let res = Bytes.make (prec + 2) '0' in
    Bytes.set res 1 str.[1];
    String.blit str 2 res (prec - len + 4) (len - 2);
    Bytes.unsafe_to_string res
  | '0' .. '9' | 'a' .. 'f' | 'A' .. 'F' when prec > len ->
    let res = Bytes.make prec '0' in
    String.blit str 0 res (prec - len) len;
    Bytes.unsafe_to_string res
  | _ ->
    str



let string_of_formatting_lit formatting_lit = match formatting_lit with
  | Close_box            -> "@]"
  (* "{" starts a special token for the bcamlppx: use [%ascii] for "}" *)
  | Close_tag            -> [%ascii "@}"]
  | Break (str, _, _)    -> str
  | FFlush               -> "@?"
  | Force_newline        -> "@\n"
  | Flush_newline        -> "@."
  | Magic_size (str, _)  -> str
  | Escaped_at           -> "@@"
  | Escaped_percent      -> "@%"

(******************************************************************************)
                              (* Conversions *)

let unsupported () = invalid_arg "Printf: unsupported conversion"

(* The numeric strings of the C64 begin with a space instead of the sign '+'. *)
let strip_space s =
  if String.length s > 0 && String.unsafe_get s 0 = ' '
  then String.sub s 1 (String.length s - 1) else s

let dec n = strip_space (string_of_int n)

(* Convert an integer to a string according to a conversion. *)
let convert_int iconv n =
  match iconv with
  | Int_d | Int_i -> dec n
  | Int_pd | Int_pi -> if n >= 0 then "+" ^ dec n else dec n
  | Int_sd | Int_si -> if n >= 0 then " " ^ dec n else dec n
  | Int_x -> fmt_hex 1 n
  | Int_X -> fmt_hex 2 n
  | Int_Cx -> if n = 0 then "0" else "0x" ^ fmt_hex 1 n
  | Int_CX -> if n = 0 then "0" else "0X" ^ fmt_hex 2 n
  | Int_o -> fmt_hex 0 n
  | Int_Co -> if n = 0 then "0" else "0" ^ fmt_hex 0 n
  | Int_u -> if n >= 0 then dec n else fmt_float 0 (float_of_int n +. 32768.)
  | Int_Cd | Int_Ci | Int_Cu -> unsupported ()

let float_string x = strip_space (string_of_float x)

(* %f: fixed notation. Up to 9 decimals are got from the ROM, more are 0s. *)
let fixed_float prec x =
  let p = if prec > 9 then 9 else prec in
  let s = fmt_float p x in
  if s = "" then float_string x
  else if prec > p then s ^ String.make (prec - p) '0'
  else s

(* %F: a valid OCaml float lexeme. *)
let caml_float x =
  if x <> x then "nan"
  else if x = infinity then "infinity"
  else if x = neg_infinity then "neg_infinity"
  else begin
    let s = float_string x in
    let len = String.length s in
    let rec is_valid i =
      if i = len then false else
        match String.unsafe_get s i with
        | '.' | 'e' | 'E' -> true
        | _ -> is_valid (i + 1) in
    if is_valid 0 then s else s ^ "."
  end

(* Convert a float to a string according to a conversion. *)
let convert_float fconv prec x =
  let s = match snd fconv with
    | Float_f -> fixed_float (abs prec) x
    | Float_g | Float_G -> float_string x
    | Float_F -> caml_float x
    | Float_e | Float_E | Float_h | Float_H | Float_CF -> unsupported () in
  match fst fconv with
  | Float_flag_ -> s
  | Float_flag_p ->
    if String.length s > 0 && String.unsafe_get s 0 <> '-' then "+" ^ s else s
  | Float_flag_s ->
    if String.length s > 0 && String.unsafe_get s 0 <> '-' then " " ^ s else s

(******************************************************************************)
                        (* Generic printing function *)

(* Make a generic printing function. *)
(* Used to generate Printf printing functions. *)
(* Parameters:
     k: a continuation finally applied to the accumulator.
     acc: rev list of printing entities (string, char, flush, formatting, ...).
     fmt: the format. *)
let rec make_printf : type a b c d e f .
    ((b, c) acc -> f) -> (b, c) acc ->
    (a, b, c, d, e, f) fmt -> a =
fun k acc fmt -> match fmt with
  | Char rest ->
    fun c ->
      let new_acc = Acc_data_char (acc, c) in
      make_printf k new_acc rest
  | Caml_char rest ->
    fun c ->
      let new_acc = Acc_data_string (acc, format_caml_char c) in
      make_printf k new_acc rest
  | String (pad, rest) ->
    make_padding k acc rest pad (fun str -> str)
  | Caml_string (pad, rest) ->
    make_padding k acc rest pad string_to_caml_string
  | Int (iconv, pad, prec, rest) ->
    make_int_padding_precision k acc rest pad prec convert_int iconv
  | Float (fconv, pad, prec, rest) ->
    make_float_padding_precision k acc rest pad prec fconv
  | Bool (pad, rest) ->
    make_padding k acc rest pad string_of_bool
  | Alpha rest ->
    fun f x -> make_printf k (Acc_delay (acc, fun o -> f o x)) rest
  | Theta rest ->
    fun f -> make_printf k (Acc_delay (acc, f)) rest
  | Flush rest ->
    make_printf k (Acc_flush acc) rest
  | String_literal (str, rest) ->
    make_printf k (Acc_string_literal (acc, str)) rest
  | Char_literal (chr, rest) ->
    make_printf k (Acc_char_literal (acc, chr)) rest
  | Formatting_lit (fmting_lit, rest) ->
    make_printf k (Acc_formatting_lit (acc, fmting_lit)) rest
  | End_of_format ->
    k acc
  | _ ->
    unsupported ()

and make_padding : type x z a b c d e f .
    ((b, c) acc -> f) -> (b, c) acc ->
    (a, b, c, d, e, f) fmt ->
    (x, z -> a) padding -> (z -> string) -> x =
  fun k acc fmt pad trans -> match pad with
  | No_padding ->
    fun x ->
      let new_acc = Acc_data_string (acc, trans x) in
      make_printf k new_acc fmt
  | Lit_padding (padty, width) ->
    fun x ->
      let new_acc = Acc_data_string (acc, fix_padding padty width (trans x)) in
      make_printf k new_acc fmt
  | Arg_padding padty ->
    fun w x ->
      let new_acc = Acc_data_string (acc, fix_padding padty w (trans x)) in
      make_printf k new_acc fmt

(* Fix padding and precision for int, int32, nativeint or int64. *)
(* Take one or two extra integer arguments if needed. *)
and make_int_padding_precision : type x y z a b c d e f .
    ((b, c) acc -> f) -> (b, c) acc ->
    (a, b, c, d, e, f) fmt ->
    (x, y) padding -> (y, z -> a) precision -> (int_conv -> z -> string) ->
    int_conv -> x =
  fun k acc fmt pad prec trans iconv -> match pad, prec with
  | No_padding, No_precision ->
    fun x ->
      let str = trans iconv x in
      make_printf k (Acc_data_string (acc, str)) fmt
  | No_padding, Lit_precision p ->
    fun x ->
      let str = fix_int_precision p (trans iconv x) in
      make_printf k (Acc_data_string (acc, str)) fmt
  | No_padding, Arg_precision ->
    fun p x ->
      let str = fix_int_precision p (trans iconv x) in
      make_printf k (Acc_data_string (acc, str)) fmt
  | Lit_padding (padty, w), No_precision ->
    fun x ->
      let str = fix_padding padty w (trans iconv x) in
      make_printf k (Acc_data_string (acc, str)) fmt
  | Lit_padding (padty, w), Lit_precision p ->
    fun x ->
      let str = fix_padding padty w (fix_int_precision p (trans iconv x)) in
      make_printf k (Acc_data_string (acc, str)) fmt
  | Lit_padding (padty, w), Arg_precision ->
    fun p x ->
      let str = fix_padding padty w (fix_int_precision p (trans iconv x)) in
      make_printf k (Acc_data_string (acc, str)) fmt
  | Arg_padding padty, No_precision ->
    fun w x ->
      let str = fix_padding padty w (trans iconv x) in
      make_printf k (Acc_data_string (acc, str)) fmt
  | Arg_padding padty, Lit_precision p ->
    fun w x ->
      let str = fix_padding padty w (fix_int_precision p (trans iconv x)) in
      make_printf k (Acc_data_string (acc, str)) fmt
  | Arg_padding padty, Arg_precision ->
    fun w p x ->
      let str = fix_padding padty w (fix_int_precision p (trans iconv x)) in
      make_printf k (Acc_data_string (acc, str)) fmt

(* Convert a float, fix padding and precision if needed. *)
(* Take the float argument and one or two extra integer arguments if needed. *)
and make_float_padding_precision : type x y a b c d e f .
    ((b, c) acc -> f) -> (b, c) acc ->
    (a, b, c, d, e, f) fmt ->
    (x, y) padding -> (y, float -> a) precision -> float_conv -> x =
  fun k acc fmt pad prec fconv -> match pad, prec with
  | No_padding, No_precision ->
    fun x ->
      let str = convert_float fconv (default_float_precision fconv) x in
      make_printf k (Acc_data_string (acc, str)) fmt
  | No_padding, Lit_precision p ->
    fun x ->
      let str = convert_float fconv p x in
      make_printf k (Acc_data_string (acc, str)) fmt
  | No_padding, Arg_precision ->
    fun p x ->
      let str = convert_float fconv p x in
      make_printf k (Acc_data_string (acc, str)) fmt
  | Lit_padding (padty, w), No_precision ->
    fun x ->
      let str = convert_float fconv (default_float_precision fconv) x in
      let str' = fix_padding padty w str in
      make_printf k (Acc_data_string (acc, str')) fmt
  | Lit_padding (padty, w), Lit_precision p ->
    fun x ->
      let str = fix_padding padty w (convert_float fconv p x) in
      make_printf k (Acc_data_string (acc, str)) fmt
  | Lit_padding (padty, w), Arg_precision ->
    fun p x ->
      let str = fix_padding padty w (convert_float fconv p x) in
      make_printf k (Acc_data_string (acc, str)) fmt
  | Arg_padding padty, No_precision ->
    fun w x ->
      let str = convert_float fconv (default_float_precision fconv) x in
      let str' = fix_padding padty w str in
      make_printf k (Acc_data_string (acc, str')) fmt
  | Arg_padding padty, Lit_precision p ->
    fun w x ->
      let str = fix_padding padty w (convert_float fconv p x) in
      make_printf k (Acc_data_string (acc, str)) fmt
  | Arg_padding padty, Arg_precision ->
    fun w p x ->
      let str = fix_padding padty w (convert_float fconv p x) in
      make_printf k (Acc_data_string (acc, str)) fmt


(******************************************************************************)
                  (* Output of the accumulator *)

(* Recursively output an "accumulator" containing a reversed list of
   printing entities (string, char, flush, ...) in an output_stream. *)
(* Used as a continuation of make_printf. *)
let rec output_acc o acc = match acc with
  | Acc_formatting_lit (p, fmting_lit) ->
    let s = string_of_formatting_lit fmting_lit in
    output_acc o p; output_string o s;
  | Acc_string_literal (p, s)
  | Acc_data_string (p, s)   -> output_acc o p; output_string o s
  | Acc_char_literal (p, c)
  | Acc_data_char (p, c)     -> output_acc o p; output_char o c
  | Acc_delay (p, f)         -> output_acc o p; f o
  | Acc_flush p              -> output_acc o p; flush o
  | Acc_invalid_arg (p, msg) -> output_acc o p; invalid_arg msg;
  | End_of_acc               -> ()

(* The same, in a buffer. *)
let rec bufput_acc b acc = match acc with
  | Acc_formatting_lit (p, fmting_lit) ->
    let s = string_of_formatting_lit fmting_lit in
    bufput_acc b p; Buffer.add_string b s;
  | Acc_string_literal (p, s)
  | Acc_data_string (p, s)   -> bufput_acc b p; Buffer.add_string b s
  | Acc_char_literal (p, c)
  | Acc_data_char (p, c)     -> bufput_acc b p; Buffer.add_char b c
  | Acc_delay (p, f)         -> bufput_acc b p; f b
  | Acc_flush p              -> bufput_acc b p;
  | Acc_invalid_arg (p, msg) -> bufput_acc b p; invalid_arg msg;
  | End_of_acc               -> ()

(* The same, in a buffer, but %a and %t return a string (used by sprintf). *)
let rec strput_acc b acc = match acc with
  | Acc_formatting_lit (p, fmting_lit) ->
    let s = string_of_formatting_lit fmting_lit in
    strput_acc b p; Buffer.add_string b s;
  | Acc_string_literal (p, s)
  | Acc_data_string (p, s)   -> strput_acc b p; Buffer.add_string b s
  | Acc_char_literal (p, c)
  | Acc_data_char (p, c)     -> strput_acc b p; Buffer.add_char b c
  | Acc_delay (p, f)         -> strput_acc b p; Buffer.add_string b (f ())
  | Acc_flush p              -> strput_acc b p;
  | Acc_invalid_arg (p, msg) -> strput_acc b p; invalid_arg msg;
  | End_of_acc               -> ()
