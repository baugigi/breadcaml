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

(** {1 Disk drives and SD2IEC}

    Files, drive commands and directories on the serial bus, built on
    {!Hw.Kernal}. Programs that do not use these modules do not pay for them.

    {b Names and PETSCII.} File names and commands are sent as they are: they
    are PETSCII strings, and BreadCaml translates the string literals to
    PETSCII. A name written in {e lowercase} in the source (["data"]) becomes
    the unshifted letters that you type at the C64 keyboard (and that BASIC
    sends); an {e uppercase} literal (["DATA"]) is a different, shifted name.
    The same holds for the commands: write ["s:data"], not ["S:DATA"].

    {b Devices.} [?dev] is the device number (4..30); the default is
    {!Disk.default_device} (8). Several drives can be used at the same time.

    {b Drive errors.} The Kernal reports only bus errors; DOS errors (file not
    found, disk full...) are read from the drive error channel, which this
    module opens on the first use of each device and keeps open (closing it
    would close all the files of the drive) until the end of the program or
    {!Disk.close_all}. A DOS error code >= 20 raises {!Disk.Dos_error}.

    {b Limits.} At most 8 files are open together. Block counts are [int32]
    (OCaml integers have 15 bits, a drive can report up to 65535). Reading an
    empty file may give one CR. Do not call {!Hw.Kernal.clall} or {!Hw.Kernal.close} on lfn 2..9 and
    32+device behind the back of this module. *)

module Hw = C64_hw


exception Kernal_error of int
(** A Kernal error code ({!Hw.Kernal.err_file_not_found}...); 5 = device
    not present. *)

exception Status_error of int
(** A serial bus error: the status byte (ST) of the failed transfer. *)

exception Dos_error of int * string
(** [Dos_error (code, message)]: error reported by the drive, e.g.
    [(62, "FILE NOT FOUND")]. The message is in PETSCII (uppercase). *)

val default_device : int ref

val close_all : unit -> unit
(** Closes all the files and the command channels (also done at exit). *)

(** {2 Command channel} *)

type status = { code : int; message : string; track : int; sector : int }
(** The reply ["nn,MESSAGE,tt,ss"] of the drive. [code] < 20 is not an
    error ([0] = OK, [1] = files scratched: [track] is the count). *)

val status : ?dev:int -> unit -> status
(** Reads the error channel (and clears the error). *)

val command : ?dev:int -> string -> status
(** [command cmd] sends a DOS command and returns the resulting status;
    raises {!Dos_error} if [code >= 20]. *)

val raw_command : ?dev:int -> string -> status
(** As {!command}, without raising {!Dos_error}. *)

val command_read : ?dev:int -> string -> int -> string
(** [command_read cmd maxlen] sends [cmd] and reads the binary answer: up
    to [maxlen] bytes, up to the end of the message. *)

val scratch : ?dev:int -> string -> int
(** [scratch name]: deletes the file(s) (wildcards allowed); returns how
    many were deleted. *)

val rename : ?dev:int -> src:string -> string -> unit
(** [rename ~src dst] *)

val copy : ?dev:int -> src:string -> string -> unit
(** [copy ~src dst]: on the same drive. *)

val validate : ?dev:int -> unit -> unit
val format : ?dev:int -> ?id:string -> string -> unit
(** [format ~id name]: erases the disk (with [id]: full format; without:
    quick format of an already formatted disk). {b Destroys all data.} On
    an SD2IEC it works on a mounted image only. *)

(** {2 Files} *)

type kind = Seq | Prg | Usr
type mode =
  | Replace   (** create, or overwrite an existing file (["@0:"] prefix:
                  the name must not contain a path) *)
  | Create    (** fails with {!Dos_error} [63] if the file exists *)
  | Append    (** append to an existing file *)

type in_file
type out_file

val open_in : ?dev:int -> ?kind:kind -> string -> in_file
(** Default kind: [Seq]. Raises {!Dos_error} [62] if the file does not
    exist. *)

val open_out : ?dev:int -> ?kind:kind -> ?mode:mode -> string -> out_file
(** Default mode: [Replace]. *)

val close_in : in_file -> unit
val close_out : out_file -> unit
(** [close_out] also checks the drive: raises {!Dos_error} if a write
    failed (e.g. [72] disk full). Always close the files that you write. *)

val in_eof : in_file -> bool
(** [true] once the last byte has been read. *)

val input_byte : in_file -> int
val input_char : in_file -> char
(** Raise [End_of_file] after the last byte. *)

val input : in_file -> bytes -> int -> int -> int
(** [input f b pos len]: reads up to [len] bytes; returns [0] at the end of
    the file. Much faster than byte by byte. *)

type newline = Cr | Lf | Crlf
(** Line terminator: [Cr] is the PETSCII one (default), [Lf] and [Crlf] are
    for the files written on other systems (whose text is ASCII: see
    {!Char.Ascii}). *)

val input_line : ?nl:newline -> in_file -> string
(** Raises [End_of_file] at the end of the file. *)

val input_all : in_file -> string
(** The rest of the file (it must fit in the heap, twice). *)

val output_byte : out_file -> int -> unit
val output_char : out_file -> char -> unit
val output_string : out_file -> string -> unit
val output_substring : out_file -> string -> int -> int -> unit
val output_bytes : out_file -> bytes -> unit
val output_newline : ?nl:newline -> out_file -> unit

val read_file : ?dev:int -> ?kind:kind -> string -> string
val write_file : ?dev:int -> ?kind:kind -> ?mode:mode -> string -> string -> unit
(** [write_file name contents] *)

(** {2 Programs and memory images} *)

val load_at : ?dev:int -> string -> int -> int -> int * int
(** [load_at name page off] loads the file into memory at [page*256+off]
    ({b nothing protects BreadCaml}: see {!Hw.Kernal.load_at}); returns the
    end address (last byte + 1) as [(page, off)]. *)

val load_prg : ?dev:int -> string -> int * int
(** Loads at the address stored in the first two bytes of the file. *)

val save : ?dev:int -> ?replace:bool -> string -> int -> int -> int -> int -> unit
(** [save name spage soff epage eoff] saves [\[start, end)] as a program
    file; [replace] (default [true]) overwrites an existing file. *)

(** {2 Directory} *)

type entry_type = DSeq | DPrg | DUsr | DRel | DDel | DDir | DOther of string
(** [DDir]: sub-directory (SD2IEC, CMD); [DOther]: any other type string,
    as listed by the drive. *)

type entry = {
  name : string;
  blocks : int32;         (** 254-byte blocks (16 bit, unsigned) *)
  etype : entry_type;
  closed : bool;          (** [false]: "splat" file, never closed *)
  locked : bool;          (** write protected ([<]) *)
}

val dir_iter : ?dev:int -> ?pattern:string -> (entry -> unit) -> unit
(** Calls [f] for each directory entry, one at a time as they arrive from
    the drive, with no list allocated (the directory of an SD card can be
    very long). [pattern] is a DOS filter, e.g. ["a*"] or ["*=p"]; a
    pattern starting with ['='] is a bare option (SD2IEC: ["=p"]).
    [f] may use other files; it must not start another directory
    listing on the same drive. *)

val dir_fold : ?dev:int -> ?pattern:string -> (entry -> 'a -> 'a) -> 'a -> 'a

type disk_info = { title : string; id : string; free : int32 }

val disk_info : ?dev:int -> unit -> disk_info
(** Title and id of the disk and free blocks; reads the whole
    directory. *)

val exists : ?dev:int -> string -> bool
(**/**)

(** Internal functions, used by {!C64_sd2iec}; not part of the interface. *)

val devof : int option -> int
val send : int -> string -> unit
val forget_command_channel : int -> unit
