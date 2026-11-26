(* C64.Disk (and C64.Sd2iec when an SD2IEC is found).  Needs a drive or a
   virtual drive with a writable disk at device 8.  Names in lowercase. *)

open C64

let failed = ref 0

let check name cond =
  if cond then print_string "ok "
  else (incr failed; print_string "FAIL ");
  print_string name;
  print_newline ()

let dos_code f = try f (); 0 with Disk.Dos_error (c, _) -> c

let () =
  (* text file *)
  Disk.write_file "dtest" "hello\rworld\r";
  check "read_file" (Disk.read_file "dtest" = "hello\rworld\r");
  let f = Disk.open_in "dtest" in
  let l1 = Disk.input_line f in
  let l2 = Disk.input_line f in
  check "input_line" (l1 = "hello" && l2 = "world");
  check "eof" (Disk.in_eof f);
  check "End_of_file"
    (try ignore (Disk.input_line f); false with End_of_file -> true);
  Disk.close_in f;

  (* append *)
  let o = Disk.open_out ~mode:Disk.Append "dtest" in
  Disk.output_string o "more";
  Disk.output_newline o;
  Disk.close_out o;
  check "append" (Disk.read_file "dtest" = "hello\rworld\rmore\r");

  (* errors *)
  check "create exists"
    (dos_code (fun () -> Disk.close_out (Disk.open_out ~mode:Disk.Create "dtest"))
     = 63);
  check "not found"
    (dos_code (fun () -> Disk.close_in (Disk.open_in "nonesuch")) = 62);
  check "status ok" ((Disk.status ()).Disk.code < 20);

  (* directory *)
  let n = ref 0 and ok = ref false in
  Disk.dir_iter ~pattern:"dtest" (fun e ->
      incr n;
      ok := e.Disk.name = "dtest" && e.Disk.etype = Disk.DSeq
            && Int32.compare e.Disk.blocks 1l >= 0 && e.Disk.closed);
  check "dir_iter" (!n = 1 && !ok);
  check "exists" (Disk.exists "dtest" && not (Disk.exists "nonesuch"));
  check "dir_fold" (Disk.dir_fold (fun _ k -> k + 1) 0 >= 1);
  let info = Disk.disk_info () in
  check "disk_info" (Int32.compare info.Disk.free 0l > 0);

  (* binary file, 300 bytes *)
  let b = Bytes.create 300 in
  for i = 0 to 299 do Bytes.set b i (Char.chr (i land 255)) done;
  let o = Disk.open_out ~kind:Disk.Prg "dbin" in
  Disk.output_bytes o b;
  Disk.close_out o;
  let f = Disk.open_in ~kind:Disk.Prg "dbin" in
  let r = Bytes.make 300 '\000' in
  let n1 = Disk.input f r 0 200 in
  let n2 = Disk.input f r 200 200 in
  let n3 = Disk.input f r 0 10 in
  Disk.close_in f;
  check "binary" (n1 = 200 && n2 = 100 && n3 = 0 && Bytes.equal b r);

  (* rename, scratch *)
  Disk.rename ~src:"dtest" "dtest2";
  check "rename" (Disk.exists "dtest2" && not (Disk.exists "dtest"));
  check "scratch" (Disk.scratch "dtest2" = 1 && Disk.scratch "dbin" = 1);
  check "scratched" (not (Disk.exists "dtest2"));

  (* memory <-> file *)
  for i = 0 to 15 do Hw.Mem.poke_at 0xC0 i (i * 3) done;
  Disk.save "dtmem" 0xC0 0 0xC0 16;
  for i = 0 to 15 do Hw.Mem.poke_at 0xC0 i 0 done;
  let (ep, eo) = Disk.load_at "dtmem" 0xC1 0 in
  let same = ref true in
  for i = 0 to 15 do
    if Hw.Mem.peek_at 0xC1 i <> i * 3 then same := false done;
  check "load_at" (!same && ep = 0xC1 && eo = 16);
  let (ep, eo) = Disk.load_prg "dtmem" in
  let same = ref true in
  for i = 0 to 15 do
    if Hw.Mem.peek_at 0xC0 i <> i * 3 then same := false done;
  check "load_prg" (!same && ep = 0xC0 && eo = 16);
  ignore (Disk.scratch "dtmem");

  (* bus error *)
  check "no device"
    (try ignore (Disk.status ~dev:30 ()); false
     with Disk.Kernal_error _ | Disk.Status_error _ -> true);

  (* SD2IEC *)
  if Sd2iec.detect () then begin
    print_string "sd2iec found"; print_newline ();
    Sd2iec.mkdir "dtdir";
    Sd2iec.chdir "dtdir";
    Disk.write_file "inside" "x";
    check "in subdir" (Disk.exists "inside");
    Sd2iec.parent ();
    check "parent" (not (Disk.exists "inside"));
    let isdir = ref false in
    Disk.dir_iter ~pattern:"dtdir" (fun e ->
        isdir := e.Disk.etype = Disk.DDir);
    check "dir type" !isdir;
    Sd2iec.chdir "dtdir";
    ignore (Disk.scratch "inside");
    Sd2iec.parent ();
    Sd2iec.rmdir "dtdir";
    check "rmdir" (not (Disk.exists "dtdir"));
    (match Sd2iec.read_time () with
     | None -> print_string "no rtc"; print_newline ()
     | Some t ->
       check "rtc" (t.Sd2iec.month >= 1 && t.Sd2iec.month <= 12
                    && t.Sd2iec.hour < 24));
    let np = ref 0 in
    Sd2iec.partition_iter (fun _ _ -> incr np);
    check "partitions" (!np >= 1)
  end else begin
    print_string "no sd2iec"; print_newline ()
  end;

  Disk.close_all ();
  print_string (if !failed = 0 then "ALL OK" else "FAILED");
  print_newline ()
