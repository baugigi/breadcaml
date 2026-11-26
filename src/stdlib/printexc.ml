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

(* {i {b BreadCaml Note} Reduced version of the module: Printf is not
   available and the runtime does not record backtraces, so the backtrace
   functions are stubs (no backtrace is ever recorded). *)

(*--
open Printf
--*)

type t = exn = ..

(*--
let printers = Atomic.make []
--*)
(*++ *)
let printers = ref []
(* ++*)

(*--
let locfmt = format_of_string "File \"%s\", line %d, characters %d-%d: %s"
--*)
(*++ *)
let locfmt file line first last msg =
  "File \"" ^ file ^ "\", line " ^ string_of_int line ^ ", characters "
  ^ string_of_int first ^ "-" ^ string_of_int last ^ ": " ^ msg
(* ++*)

let field x i =
  let f = Obj.field x i in
  if not (Obj.is_block f) then
(*--
    sprintf "%d" (Obj.magic f : int)           (* can also be a char *)
--*)
(*++ *)
    string_of_int (Obj.magic f : int)          (* can also be a char *)
(* ++*)
  else if Obj.tag f = Obj.string_tag then
(*--
    sprintf "%S" (Obj.magic f : string)
--*)
(*++ *)
    "\"" ^ String.escaped (Obj.magic f : string) ^ "\""
(* ++*)
  else if Obj.tag f = Obj.double_tag then
    string_of_float (Obj.magic f : float)
  else
    "_"

let rec other_fields x i =
  if i >= Obj.size x then ""
  else
(*--
    sprintf ", %s%s" (field x i) (other_fields x (i+1))
--*)
(*++ *)
    ", " ^ field x i ^ other_fields x (i+1)
(* ++*)

let fields x =
  match Obj.size x with
  | 0 -> ""
  | 1 -> ""
(*--
  | 2 -> sprintf "(%s)" (field x 1)
  | _ -> sprintf "(%s%s)" (field x 1) (other_fields x 2)
--*)
(*++ *)
  | 2 -> "(" ^ field x 1 ^ ")"
  | _ -> "(" ^ field x 1 ^ other_fields x 2 ^ ")"
(* ++*)

let use_printers x =
  let rec conv = function
    | hd :: tl ->
        (match hd x with
         | None | exception _ -> conv tl
         | Some s -> Some s)
    | [] -> None in
(*--
  conv (Atomic.get printers)
--*)
(*++ *)
  conv !printers
(* ++*)

let to_string_default = function
  | Out_of_memory -> "Out of memory"
  | Stack_overflow -> "Stack overflow"
(*--
  | Match_failure(file, line, char) ->
      sprintf locfmt file line char (char+5) "Pattern matching failed"
  | Assert_failure(file, line, char) ->
      sprintf locfmt file line char (char+6) "Assertion failed"
  | Undefined_recursive_module(file, line, char) ->
      sprintf locfmt file line char (char+6) "Undefined recursive module"
--*)
(*++ *)
  | Match_failure(file, line, char) ->
      locfmt file line char (char+5) "Pattern matching failed"
  | Assert_failure(file, line, char) ->
      locfmt file line char (char+6) "Assertion failed"
  | Undefined_recursive_module(file, line, char) ->
      locfmt file line char (char+6) "Undefined recursive module"
(* ++*)
  | x ->
      let x = Obj.repr x in
      if Obj.tag x <> 0 then
        (Obj.magic (Obj.field x 0) : string)
      else
        let constructor =
          (Obj.magic (Obj.field (Obj.field x 0) 0) : string) in
        constructor ^ (fields x)

let to_string e =
  match use_printers e with
  | Some s -> s
  | None -> to_string_default e

let print fct arg =
  try
    fct arg
  with x ->
(*--
    eprintf "Uncaught exception: %s\n" (to_string x);
--*)
(*++ *)
    prerr_string ("Uncaught exception: " ^ to_string x ^ "\n");
(* ++*)
    flush stderr;
    raise x

let catch fct arg =
  try
    fct arg
  with x ->
    flush stdout;
(*--
    eprintf "Uncaught exception: %s\n" (to_string x);
--*)
(*++ *)
    prerr_string ("Uncaught exception: " ^ to_string x ^ "\n");
(* ++*)
(*++ *)
    (* no [exit] in BreadCaml *)
    raise Exit
(* ++*)

(*++ *)
(* Backtraces: stubs *)

type raw_backtrace = unit

let get_raw_backtrace () = ()
let raise_with_backtrace e (_ : raw_backtrace) = raise e
let print_raw_backtrace (_ : out_channel) (_ : raw_backtrace) = ()
let raw_backtrace_to_string (_ : raw_backtrace) = ""
let record_backtrace (_ : bool) = ()
let backtrace_status () = false
let get_backtrace () = ""
let print_backtrace (_ : out_channel) = ()
(* ++*)

(*--
let rec register_printer fn =
  let old_printers = Atomic.get printers in
  let new_printers = fn :: old_printers in
  let success = Atomic.compare_and_set printers old_printers new_printers in
  if not success then register_printer fn
--*)
(*++ *)
let register_printer fn =
  printers := fn :: !printers
(* ++*)
