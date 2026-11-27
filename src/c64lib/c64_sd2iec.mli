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

(** Extras of the SD2IEC firmware (and clones: uIEC, ...). Commands that a
    real 1541 does not know raise {!Disk.Dos_error} (code 30..33). Reference:
    the sd2iec README. *)

module Disk = C64_disk


val detect : ?dev:int -> unit -> bool
(** [true] if the device answers as an SD2IEC. It sends ["UI"], a warm
    reset of the drive: use it {e before} opening files. *)

(** {2 Directories and disk images} *)

val chdir : ?dev:int -> string -> unit
(** [chdir name]: enter the sub-directory (or mount the disk image, [.d64],
    [.d71], [.d81], [.dnp], [.m2i]) [name]. *)

val chdir_path : ?dev:int -> string list -> unit
(** Enters the directories one after the other. *)

val parent : ?dev:int -> unit -> unit
(** Back to the parent directory (leaves a mounted image). *)

val root : ?dev:int -> unit -> unit
(** Root of the partition (or of the mounted image). *)

val mkdir : ?dev:int -> string -> unit
val rmdir : ?dev:int -> string -> unit
(** The directory must be empty; no path allowed. *)

val mount : ?dev:int -> string -> unit
(** Same as [chdir]. *)

val unmount : ?dev:int -> unit -> unit
(** Leaves the image: [root] then [parent]. *)

(** {2 Partitions} *)

val partition : ?dev:int -> int -> unit
(** [partition n]: select the partition [n] (1..254). *)

val partition_iter : ?dev:int -> (int -> string -> unit) -> unit
(** [f number name] for each partition (the listing ["$=P"]). *)

(** {2 Real time clock} *)

type time = { year : int; month : int; day : int; hour : int;
              minute : int; second : int; weekday : int }
(** [hour] is 0..23, [weekday] 0 = Sunday. *)

val read_time : ?dev:int -> unit -> time option
(** [None] if the device has no RTC or it is not set. *)

val set_time : ?dev:int -> time -> unit
(** [weekday] is ignored (computed). Years 1980..2079. *)

(** {2 Settings} *)

val set_device_address : ?dev:int -> int -> unit
(** [set_device_address n] (8..30): the drive answers at [n] from now on;
    not saved at reset unless {!save_settings} is called (with the new
    device number). Close the files of the device first. *)

val save_settings : ?dev:int -> unit -> unit
