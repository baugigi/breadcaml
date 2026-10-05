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

(* Character operations *)

external code: char -> int = "%identity"
external unsafe_chr: int -> char = "%identity"

let chr n =
  if n < 0 || n > 255 then invalid_arg "Char.chr" else unsafe_chr n

external bytes_create: int -> bytes = "caml_create_bytes"
external bytes_unsafe_set : bytes -> int -> char -> unit
                           = "%bytes_unsafe_set"
external unsafe_to_string : bytes -> string = "%bytes_to_string"

let escaped = function
  | '\'' -> "\\'"
  | '\\' -> "\\\\"
  | '\n' -> "\\n"
  | '\t' -> "\\t"
  | '\r' -> "\\r"
  | '\b' -> "\\b"
  | ' ' .. '~' as c ->
     let s = bytes_create 1 in
     bytes_unsafe_set s 0 c;
     unsafe_to_string s
  | c ->
     let n = code c in
     let s = bytes_create 4 in
     bytes_unsafe_set s 0 '\\';
     bytes_unsafe_set s 1 (unsafe_chr (48 + n / 100));
     bytes_unsafe_set s 2 (unsafe_chr (48 + (n / 10) mod 10));
     bytes_unsafe_set s 3 (unsafe_chr (48 + n mod 10));
     unsafe_to_string s

(*++ *)
module Ascii = struct
  let escaped = escaped
(* ++*)
  let lowercase = function
    | 'A' .. 'Z'
      | '\192' .. '\214'
      | '\216' .. '\222' as c ->
       unsafe_chr(code c + 32)
    | c -> c

  let uppercase = function
    | 'a' .. 'z'
      | '\224' .. '\246'
      | '\248' .. '\254' as c ->
       unsafe_chr(code c - 32)
    | c -> c

  let lowercase_ascii = function
    | 'A' .. 'Z' as c -> unsafe_chr(code c + 32)
    | c -> c

  let uppercase_ascii = function
    | 'a' .. 'z' as c -> unsafe_chr(code c - 32)
    | c -> c

(*++ *)
  let to_petscii = function
    | 'a' .. 'z' as c -> unsafe_chr(code c + 0x80)
    | 'A' .. 'Z' as c -> unsafe_chr(code c - 0x20)
    | '_' -> '\xA4'
    | '|' -> '\xDD'
    | c -> c

  let of_petscii = function
    | '\x41' .. '\x5A' as c -> unsafe_chr(code c + 0x20)
    | '\x61' .. '\x7A' as c -> unsafe_chr(code c - 0x20)
    | '\xC1' .. '\xDA' as c -> unsafe_chr(code c - 0x80)
    | '\xA4' -> '_'
    | '\xDD' -> '|'
    | c -> c

end
(* ++*)

type t = char

let compare c1 c2 = code c1 - code c2
let equal (c1: t) (c2: t) = compare c1 c2 = 0

(*++ *)
let is_control = function
  | '\x00'..'\x1F' | '\x80'..'\x9F' -> true
  | _ -> false

let is_letter = function
  | '\x41'..'\x5A' | '\xC1'..'\xDA' | '\x61'..'\x7A' -> true
  | _ -> false

let is_upper = function
  | '\xC1'..'\xDA' | '\x61'..'\x7A' -> true
  | _ -> false

let is_lower = function
  | '\x41'..'\x5A'  -> true
  | _ -> false

let is_digit = function
  | '\x30'..'\x39' -> true
  | _ -> false

let is_alphanum c = is_letter c || is_digit c

let is_white = function
  | ' ' | '\r' -> true
  | _ -> false

let is_symbol = function
  | '\x21'..'\x2F' | '\x3A'..'\x40' | '\x5B'..'\x5F' -> true
  | _ -> false

let is_graphic = function
  | '\x60' | '\x7B'..'\x7F' | '\xA0'..'\xC0' | '\xDB'..'\xFF' -> true
  | _ -> false

let is_print = function
  | '\x00'..'\x1F' | '\x80'..'\x9F' -> false
  | _ -> true

let is_type = function
  | '\x60'..'\x7F' | '\xE0'..'\xFF' -> false
  | _ -> true

let is_dup = function
  | '\x60'..'\x7F' | '\xE0'..'\xFF' -> true
  | _ -> false

let dup = function
  | '\xA0'..'\xBE' as c -> Some (unsafe_chr(code c + 0x40))
  | '\xC0'..'\xDF' as c -> Some (unsafe_chr(code c - 0x60))
  | _ -> None

let org = function
  | '\x60'..'\x7F' as c -> Some (unsafe_chr(code c + 0x60))
  | '\xE0'..'\xFE' as c -> Some (unsafe_chr(code c - 0x40))
  | '\xFF' -> Some '\xDE'
  | _ -> None

let lowercase_petscii = function
  | '\x61' .. '\x7A' as c -> unsafe_chr(code c - 0x20)
  | '\xC1' .. '\xDA' as c -> unsafe_chr(code c - 0x80)
  | c -> c

let uppercase_petscii = function
  | '\x41' .. '\x5A' as c -> unsafe_chr(code c + 0x80)
  | c -> c

let lowercase = lowercase_petscii
let uppercase = uppercase_petscii
let lowercase_ascii = lowercase_petscii
let uppercase_ascii = uppercase_petscii

module Control = struct
  let up = '\145'
  let dn = '\017'
  let lf = '\157'
  let rt = '\029'
  let blk = '\144'
  let wht = '\005'
  let red = '\028'
  let cyn = '\159'
  let pur = '\156'
  let grn = '\030'
  let blu = '\031'
  let yel = '\158'
  let org = '\129'
  let brn = '\149'
  let pnk = '\150'
  let lgrn = '\153'
  let lblu = '\154'
  let dgry = '\151'
  let mgry = '\152'
  let lgry = '\155'
  let rvson = '\018'
  let rvsoff = '\146'
  let swon = '\009'
  let swoff = '\008'
  let lcase = '\014'
  let ucase = '\142'
  let f1 = '\133'
  let f2 = '\137'
  let f3 = '\134'
  let f4 = '\138'
  let f5 = '\135'
  let f6 = '\139'
  let f7 = '\136'
  let f8 = '\140'
  let stop = '\003'
  let run = '\131'
  let cr = '\013'
  let home = '\019'
  let clr = '\147'
  let del = '\020'
  let inst = '\148'
  let shf_spc = '\160'
  let shf_cr = '\141'
  let ctl_larw = '\006'
  let ctl_uarw = grn
  let ctl_pound = red
  let nul = '\000'
end

module Common = struct
  let under = '\164'
  let upper = '\163'
  let thl = '\183'
  let chl = '\192'
  let bhl = '\175'
  let lvl = '\165'
  let cvl = '\221'
  let rvl = '\167'
  let lvl_ = '\180'
  let rvl_ = '\170'
  let tb1 = upper
  let tb2 = thl
  let tb3 = '\184'
  let bb1 = under
  let bb2 = bhl
  let bb3 = '\185'
  let bb4 = '\162'
  let lb2 = lvl
  let lb3 = '\181'
  let lb4 = '\161'
  let rb2 = rvl
  let rb3 = '\182'
  let tlc = '\176'
  let trc = '\174'
  let blc = '\173'
  let brc = '\189'
  let utj = '\177'
  let dtj = '\178'
  let ltj = '\179'
  let rtj = '\171'
  let fwj = '\219'
  let tlq = '\190'
  let trq = '\188'
  let blq = '\187'
  let brq = '\172'
  let tlbrq = '\191'
  let chk = '\166'
  let lchk = '\220'
  let bchk = '\168'
  let pound = '\092'
  let uarw = '\094'
  let larw = '\095'
end

module UnshiftedOnly = struct
  let spd = '\193'
  let hea = '\211'
  let clb = '\216'
  let dmd = '\218'
  let hl0 = Common.bhl
  let hl1 = '\210'
  let hl2 = '\198'
  let hl3 = Common.chl
  let hl4 = '\196'
  let hl5 = '\197'
  let hl6 = Common.thl
  let vl0 = Common.lvl
  let vl1 = '\212'
  let vl2 = '\199'
  let vl3 = Common.cvl
  let vl4 = '\200'
  let vl5 = '\217'
  let vl6 = Common.rvl
  let tlec = '\207'
  let trec = '\208'
  let blec = '\204'
  let brec = '\250'
  let tlrc = '\213'
  let trrc = '\201'
  let blrc = '\202'
  let brrc = '\203'
  let tlt = '\169'
  let trt = '\223'
  let adl = '\205'
  let ddl = '\206'
  let cross = '\214' 
  let disk = '\209'
  let ring = '\215'
  let pi = '\222'
end

module ShiftedOnly = struct
  let ichk = '\222'
  let adh = '\223'
  let ddh = '\169'
  let cmk = '\186'
end

module Shifted = struct
  include Control
  include Common
  include ShiftedOnly
end

module Unshifted = struct
  include Control
  include Common
  include UnshiftedOnly
end

(* ++*)
