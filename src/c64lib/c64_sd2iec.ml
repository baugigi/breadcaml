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

module Disk = C64_disk

(* Commands of the sd2iec firmware (and compatible: uIEC, ...).  They are
   sent on the command channel of the device with [Disk.command]. *)

let left_arrow = String.make 1 (Char.chr 0x5F)    (* PETSCII "←" *)

let fold c = if c >= 0xC1 && c <= 0xDA then c - 0x80 else c

let contains hay needle =
  let n = String.length hay and m = String.length needle in
  let rec at i j =
    j >= m
    || (fold (Char.code hay.[i + j]) = fold (Char.code needle.[j])
        && at i (j + 1)) in
  let rec go i = i + m <= n && (at i 0 || go (i + 1)) in
  go 0

(* "UI" is a warm reset: it closes the files of the drive.  Call this
   before opening any file. *)
let detect ?dev () =
  try
    let st = Disk.raw_command ?dev "ui" in
    st.Disk.code = 73
    && (contains st.Disk.message "sd2iec" || contains st.Disk.message "uiec")
  with Disk.Kernal_error _ | Disk.Status_error _ -> false

(* ---- directories and images ---- *)

let chdir ?dev name = ignore (Disk.command ?dev ("cd:" ^ name))
let parent ?dev () = ignore (Disk.command ?dev ("cd" ^ left_arrow))
let root ?dev () = ignore (Disk.command ?dev "cd//")
let mkdir ?dev name = ignore (Disk.command ?dev ("md:" ^ name))
let rmdir ?dev name = ignore (Disk.command ?dev ("rd:" ^ name))

let mount ?dev image = chdir ?dev image
let unmount ?dev () = root ?dev (); parent ?dev ()

let chdir_path ?dev names =
  List.iter (fun n -> chdir ?dev n) names

(* ---- partitions ---- *)

let partition ?dev n =
  if n < 1 || n > 254 then invalid_arg "C64.Sd2iec.partition";
  ignore (Disk.command ?dev ("cp" ^ string_of_int n))

let partition_iter ?dev f =
  Disk.dir_iter ?dev ~pattern:"=p"
    (fun e -> f (Int32.to_int e.Disk.blocks) e.Disk.name)

(* ---- real time clock ---- *)

type time = { year : int; month : int; day : int; hour : int;
              minute : int; second : int; weekday : int }

(* weekday of a date: 0 = Sunday *)
let weekday_of year month day =
  let t = [| 0; 3; 2; 5; 0; 3; 5; 1; 4; 6; 2; 4 |] in
  let y = if month < 3 then year - 1 else year in
  (y + y / 4 - y / 100 + y / 400 + t.(month - 1) + day) mod 7

let read_time ?dev () =
  let s = Disk.command_read ?dev "t-rd" 9 in
  if String.length s = 9 && Char.code s.[0] < 7 && Char.code s.[2] >= 1
  then begin
    let b i = Char.code s.[i] in
    let h = (b 4) mod 12 + (if b 7 = 0 then 0 else 12) in
    Some { weekday = b 0; year = b 1 + 1900; month = b 2; day = b 3;
           hour = h; minute = b 5; second = b 6 }
  end else begin
    ignore (Disk.status ?dev ());       (* drop the rest of the message *)
    None
  end

let set_time ?dev t =
  if t.year < 1980 || t.year > 2079 || t.month < 1 || t.month > 12
     || t.day < 1 || t.day > 31 || t.hour < 0 || t.hour > 23
     || t.minute < 0 || t.minute > 59 || t.second < 0 || t.second > 59
  then invalid_arg "C64.Sd2iec.set_time";
  let h12 = if t.hour mod 12 = 0 then 12 else t.hour mod 12 in
  let bytes = [ weekday_of t.year t.month t.day; t.year - 1900; t.month;
                t.day; h12; t.minute; t.second;
                (if t.hour >= 12 then 1 else 0) ] in
  let b = Buffer.create 12 in
  Buffer.add_string b "t-wd";
  List.iter (fun v -> Buffer.add_char b (Char.chr v)) bytes;
  ignore (Disk.command ?dev (Buffer.contents b))

(* ---- settings ---- *)

(* The new address is used at once by the drive, but is lost at reset
   unless [save_settings] is called.  Close the files of the device first. *)
let set_device_address ?dev n =
  if n < 8 || n > 30 then invalid_arg "C64.Sd2iec.set_device_address";
  let d = Disk.devof dev in
  (* no status read: the old address does not answer any more *)
  Disk.send d ("u0>" ^ String.make 1 (Char.chr n));
  Disk.forget_command_channel d

let save_settings ?dev () = ignore (Disk.command ?dev "xw")
