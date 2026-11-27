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

(* ———————————————————————————————————————————————————————————————————————
   Disk drives and SD2IEC.  Pure OCaml over Hw.Kernal.  No top-level effect
   (the tables are created at the first use, and only then at_exit is
   registered), so that linking C64 for another module costs nothing here.
   Command strings are written in lowercase in the source: the BreadCaml
   preprocessor turns them into the PETSCII codes that DOS wants.
   ——————————————————————————————————————————————————————————————————————— *)

module Hw = C64_hw

module K = Hw.Kernal

exception Kernal_error of int
exception Status_error of int
exception Dos_error of int * string

type status = { code : int; message : string; track : int; sector : int }

let default_device = ref 8

let devof = function
  | None -> !default_device
  | Some d ->
    if d < 4 || d > 30 then invalid_arg "C64.Disk: device number" else d

let kerr e = if e <> 0 then raise (Kernal_error e)

(* Logical files: lfn 2..9 (secondary address = lfn), index = lfn.
   The command channel of device d has lfn 32 + d and stays open until the
   end of the program (closing it would close all the files of the drive). *)
type state = { busy : bool array; devs : int array; cmd : bool array }

let state_ref : state option ref = ref None

let close_everything s =
  for lfn = 2 to 9 do
    if s.busy.(lfn) then (K.close lfn; s.busy.(lfn) <- false)
  done;
  for dev = 4 to 30 do
    if s.cmd.(dev) then (K.close (32 + dev); s.cmd.(dev) <- false)
  done

let state () =
  match !state_ref with
  | Some s -> s
  | None ->
    let s = { busy = Array.make 10 false; devs = Array.make 10 0;
              cmd = Array.make 31 false } in
    state_ref := Some s;
    at_exit (fun () -> close_everything s);
    s

let close_all () = close_everything (state ())

let alloc_lfn dev =
  let s = state () in
  let rec go n =
    if n > 9 then raise (Kernal_error K.err_too_many_files)
    else if s.busy.(n) then go (n + 1)
    else (s.busy.(n) <- true; s.devs.(n) <- dev; n) in
  go 2

let free_lfn lfn = (state ()).busy.(lfn) <- false

(* ---- the command / error channel ---- *)

let ensure_cmd dev =
  let s = state () in
  if not s.cmd.(dev) then begin
    kerr (K.open_file (32 + dev) dev 15 "");
    s.cmd.(dev) <- true
  end

let forget_command_channel dev =
  let s = state () in
  if s.cmd.(dev) then (K.close (32 + dev); s.cmd.(dev) <- false)

(* Reads the message up to CR (excluded) from the current input channel. *)
let read_message () =
  let b = Buffer.create 40 in
  let fin = ref false in
  while not !fin do
    let c = K.chrin () in
    let st = K.readst () in
    if st land 0x83 <> 0 then (K.clrchn (); raise (Status_error st));
    if c = 13 then fin := true
    else begin
      if Buffer.length b < 100 then Buffer.add_char b (Char.chr c);
      if st land K.st_eof <> 0 then fin := true
    end
  done;
  Buffer.contents b

let parse_status s =
  let n = String.length s in
  let find i =
    let rec go k = if k >= n || s.[k] = ',' then k else go (k + 1) in
    go i in
  let num i j =
    let v = ref 0 in
    for k = i to j - 1 do
      let d = Char.code s.[k] - 48 in
      if d >= 0 && d <= 9 then v := !v * 10 + d
    done;
    !v in
  let a = find 0 in
  let b = find (a + 1) in
  let c = find (b + 1) in
  { code = num 0 a;
    message = (if a >= n then "" else String.sub s (a + 1) (b - a - 1));
    track = (if b >= n then 0 else num (b + 1) c);
    sector = (if c >= n then 0 else num (c + 1) n) }

let read_status dev =
  ensure_cmd dev;
  kerr (K.chkin (32 + dev));
  let r = read_message () in
  K.clrchn ();
  parse_status r

let send dev cmd =
  ensure_cmd dev;
  kerr (K.chkout (32 + dev));
  String.iter (fun c -> K.chrout (Char.code c)) cmd;
  K.chrout 13;
  K.clrchn ()

let status ?dev () = read_status (devof dev)

let raw_command ?dev cmd =
  let dev = devof dev in
  send dev cmd;
  read_status dev

let command ?dev cmd =
  let st = raw_command ?dev cmd in
  if st.code >= 20 then raise (Dos_error (st.code, st.message));
  st

(* Sends [cmd] and returns the raw reply (up to [maxlen] bytes, up to the
   EOI): for the commands that answer with binary data. *)
let command_read ?dev cmd maxlen =
  let dev = devof dev in
  send dev cmd;
  kerr (K.chkin (32 + dev));
  let b = Buffer.create 16 in
  let fin = ref false in
  while not !fin do
    let c = K.chrin () in
    let st = K.readst () in
    if st land 0x83 <> 0 then (K.clrchn (); raise (Status_error st));
    Buffer.add_char b (Char.chr c);
    if st land K.st_eof <> 0 || Buffer.length b >= maxlen then fin := true
  done;
  K.clrchn ();
  Buffer.contents b

let scratch ?dev name = (command ?dev ("s:" ^ name)).track
let rename ?dev ~src dst = ignore (command ?dev ("r:" ^ dst ^ "=" ^ src))
let copy ?dev ~src dst = ignore (command ?dev ("c:" ^ dst ^ "=" ^ src))
let validate ?dev () = ignore (command ?dev "v")
let format ?dev ?id name =
  ignore (command ?dev
            (match id with None -> "n:" ^ name | Some i -> "n:" ^ name ^ "," ^ i))

(* ---- sequential files ---- *)

type kind = Seq | Prg | Usr
type mode = Replace | Create | Append

let kind_suffix = function Seq -> ",s" | Prg -> ",p" | Usr -> ",u"

type in_file = { in_lfn : int; in_dev : int;
                 mutable in_open : bool; mutable in_eof : bool }
type out_file = { out_lfn : int; out_dev : int; mutable out_open : bool }

let open_gen dev spec =
  ensure_cmd dev;
  let lfn = alloc_lfn dev in
  let e = K.open_file lfn dev lfn spec in
  if e <> 0 then (free_lfn lfn; raise (Kernal_error e));
  let st = (try read_status dev
            with e -> K.close lfn; free_lfn lfn; raise e) in
  if st.code >= 20 then begin
    K.close lfn; free_lfn lfn;
    raise (Dos_error (st.code, st.message))
  end;
  lfn

let open_in ?dev ?(kind = Seq) name =
  let dev = devof dev in
  let lfn = open_gen dev (name ^ kind_suffix kind ^ ",r") in
  { in_lfn = lfn; in_dev = dev; in_open = true; in_eof = false }

let open_out ?dev ?(kind = Seq) ?(mode = Replace) name =
  let dev = devof dev in
  let spec = match mode with
    | Replace -> "@0:" ^ name ^ kind_suffix kind ^ ",w"
    | Create -> name ^ kind_suffix kind ^ ",w"
    | Append -> name ^ kind_suffix kind ^ ",a" in
  let lfn = open_gen dev spec in
  { out_lfn = lfn; out_dev = dev; out_open = true }

let check_in f = if not f.in_open then invalid_arg "C64.Disk: file closed"
let check_out f = if not f.out_open then invalid_arg "C64.Disk: file closed"

let close_in f =
  if f.in_open then begin
    f.in_open <- false;
    K.close f.in_lfn;
    free_lfn f.in_lfn
  end

let close_out f =
  if f.out_open then begin
    f.out_open <- false;
    K.close f.out_lfn;
    free_lfn f.out_lfn;
    let st = read_status f.out_dev in
    if st.code >= 20 then raise (Dos_error (st.code, st.message))
  end

let in_eof f = f.in_eof

(* one byte, channel already selected *)
let rd f =
  let c = K.chrin () in
  let st = K.readst () in
  if st land 0x83 <> 0 then (K.clrchn (); raise (Status_error st));
  if st land K.st_eof <> 0 then f.in_eof <- true;
  c

let input_byte f =
  check_in f;
  if f.in_eof then raise End_of_file;
  kerr (K.chkin f.in_lfn);
  let c = rd f in
  K.clrchn ();
  c

let input_char f = Char.chr (input_byte f)

let input f b pos len =
  check_in f;
  if pos < 0 || len < 0 || pos > Bytes.length b - len then
    invalid_arg "C64.Disk.input";
  if f.in_eof || len = 0 then 0
  else begin
    kerr (K.chkin f.in_lfn);
    let n = ref 0 in
    while !n < len && not f.in_eof do
      Bytes.unsafe_set b (pos + !n) (Char.unsafe_chr (rd f));
      incr n
    done;
    K.clrchn ();
    !n
  end

type newline = Cr | Lf | Crlf

let input_line ?(nl = Cr) f =
  check_in f;
  if f.in_eof then raise End_of_file;
  let stop = if nl = Cr then 13 else 10 in
  let b = Buffer.create 40 in
  kerr (K.chkin f.in_lfn);
  let fin = ref false in
  while not !fin do
    let c = rd f in
    if c = stop then fin := true
    else begin
      Buffer.add_char b (Char.chr c);
      if f.in_eof then fin := true
    end
  done;
  K.clrchn ();
  let n = Buffer.length b in
  if nl = Crlf && n > 0 && Buffer.nth b (n - 1) = Char.chr 13 then
    Buffer.sub b 0 (n - 1)
  else Buffer.contents b

let input_all f =
  let b = Buffer.create 256 in
  let tmp = Bytes.create 64 in
  let rec go () =
    let n = input f tmp 0 64 in
    if n > 0 then (Buffer.add_subbytes b tmp 0 n; go ()) in
  go ();
  Buffer.contents b

(* output: errors of the drive (disk full...) show up in [close_out] or
   [status]; the bus errors are raised at once. *)
let wr c =
  K.chrout c;
  let st = K.readst () in
  if st land 0x83 <> 0 then (K.clrchn (); raise (Status_error st))

let output_byte f c =
  check_out f;
  kerr (K.chkout f.out_lfn);
  wr (c land 255);
  K.clrchn ()

let output_char f c = output_byte f (Char.code c)

let output_substring f s pos len =
  check_out f;
  if pos < 0 || len < 0 || pos > String.length s - len then
    invalid_arg "C64.Disk.output_substring";
  kerr (K.chkout f.out_lfn);
  for i = pos to pos + len - 1 do
    wr (Char.code (String.unsafe_get s i))
  done;
  K.clrchn ()

let output_string f s = output_substring f s 0 (String.length s)
let output_bytes f b = output_string f (Bytes.unsafe_to_string b)

let output_newline ?(nl = Cr) f =
  check_out f;
  kerr (K.chkout f.out_lfn);
  (match nl with
   | Cr -> wr 13
   | Lf -> wr 10
   | Crlf -> wr 13; wr 10);
  K.clrchn ()

let read_file ?dev ?kind name =
  let f = open_in ?dev ?kind name in
  let s = (try input_all f with e -> close_in f; raise e) in
  close_in f;
  s

let write_file ?dev ?kind ?mode name s =
  let f = open_out ?dev ?kind ?mode name in
  (try output_string f s with e -> (try close_out f with _ -> ()); raise e);
  close_out f

(* ---- memory <-> file ---- *)

let load_at ?dev name page off =
  kerr (K.load_at (devof dev) 0 name page off);
  (K.load_end_page (), K.load_end_off ())

let load_prg ?dev name =
  kerr (K.load_at (devof dev) 1 name 0 0);
  (K.load_end_page (), K.load_end_off ())

let save ?dev ?(replace = true) name spage soff epage eoff =
  let name = if replace then "@0:" ^ name else name in
  kerr (K.save ~dev:(devof dev) name spage soff epage eoff)

(* ---- directory ---- *)

type entry_type = DSeq | DPrg | DUsr | DRel | DDel | DDir | DOther of string

type entry = { name : string; blocks : int32; etype : entry_type;
               closed : bool; locked : bool }

type disk_info = { title : string; id : string; free : int32 }

let entry_type_of_string s =
  if s = "seq" then DSeq
  else if s = "prg" then DPrg
  else if s = "usr" then DUsr
  else if s = "rel" then DRel
  else if s = "del" then DDel
  else if s = "dir" then DDir
  else DOther s

type line = Header of string * string | Entry of entry | Free of int32
          | Skip

let parse_line buf n (blocks : int32) =
  let at i = Char.code (Bytes.unsafe_get buf i) in
  let quote from =
    let rec go i = if i >= n then -1 else if at i = 34 then i else go (i + 1) in
    go from in
  let q1 = quote 0 in
  if q1 < 0 then begin
    (* no name: "BLOCKS FREE." *)
    Free blocks
  end else begin
    let q2 = quote (q1 + 1) in
    let q2 = if q2 < 0 then n else q2 in
    if n > 0 && at 0 = 0x12 then begin
      (* header: [rvs on] "TITLE" ID DOS; the title is padded inside the
         quotes with shifted spaces *)
      let e = ref q2 in
      while !e > q1 + 1 && (at (!e - 1) = 0xA0 || at (!e - 1) = 32) do
        decr e
      done;
      let title = Bytes.sub_string buf (q1 + 1) (!e - q1 - 1) in
      let i0 = q2 + 2 in
      let idl = if i0 + 2 <= n then 2 else if i0 < n then n - i0 else 0 in
      Header (title, if idl > 0 then Bytes.sub_string buf i0 idl else "")
    end else begin
      let name = Bytes.sub_string buf (q1 + 1) (q2 - q1 - 1) in
      let i = ref (q2 + 1) in
      while !i < n && at !i = 32 do incr i done;
      let closed = not (!i < n && at !i = 42) in
      if not closed then incr i;
      let ty = if !i + 3 <= n then Bytes.sub_string buf !i 3 else "" in
      let j = !i + 3 in
      let locked = j < n && at j = 60 in
      Entry { name; blocks; etype = entry_type_of_string ty; closed; locked }
    end
  end

(* Reads a whole listing; one line at a time, so that the callbacks can do
   their own disk I/O. *)
let scan dev pattern on_line =
  let lfn = alloc_lfn dev in
  let spec =
    if pattern = "" then "$"
    else if String.length pattern > 0 && Char.code pattern.[0] = 61
    then "$" ^ pattern           (* "=p" *)
    else "$:" ^ pattern in
  let e = K.open_file lfn dev 0 spec in
  if e <> 0 then (free_lfn lfn; raise (Kernal_error e));
  let buf = Bytes.create 80 in
  let finish () = K.clrchn (); K.close lfn; free_lfn lfn in
  (try
     kerr (K.chkin lfn);
     ignore (K.chrin ()); ignore (K.chrin ());     (* load address *)
     K.clrchn ();
     let go = ref true in
     while !go do
       kerr (K.chkin lfn);
       let l0 = K.chrin () in
       let l1 = K.chrin () in
       if l0 = 0 && l1 = 0 then (K.clrchn (); go := false)
       else begin
         let b0 = K.chrin () in
         let b1 = K.chrin () in
         let n = ref 0 in
         let c = ref (K.chrin ()) in
         while !c <> 0 do
           if !n < 80 then (Bytes.unsafe_set buf !n (Char.unsafe_chr !c); incr n);
           c := K.chrin ()
         done;
         let st = K.readst () in
         K.clrchn ();
         if st land 0x83 <> 0 then raise (Status_error st);
         (* 16 bit unsigned: more than an OCaml int (15 bits) can hold *)
         let blocks =
           Int32.add (Int32.of_int b0) (Int32.shift_left (Int32.of_int b1) 8) in
         on_line (parse_line buf !n blocks);
         if st land K.st_eof <> 0 then go := false
       end
     done
   with e -> finish (); raise e);
  finish ()

let dir_iter ?dev ?(pattern = "") f =
  scan (devof dev) pattern
    (function Entry e -> f e | Header _ | Free _ | Skip -> ())

let dir_fold ?dev ?pattern f init =
  let acc = ref init in
  dir_iter ?dev ?pattern (fun e -> acc := f e !acc);
  !acc

let disk_info ?dev () =
  let title = ref "" and id = ref "" and free = ref 0l in
  scan (devof dev) ""
    (function
      | Header (t, i) -> title := t; id := i
      | Free n -> free := n
      | Entry _ | Skip -> ());
  { title = !title; id = !id; free = !free }

let exists ?dev name =
  let found = ref false in
  dir_iter ?dev ~pattern:name (fun _ -> found := true);
  !found
