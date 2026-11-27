(* ---- prelude comune (generato da gen_tests.py) ---- *)
let fails = ref 0
let fail s = incr fails; print_string "FAIL "; print_string s; print_newline ()
let check s ok = if not ok then fail s
let checkn s n ok = if not ok then fail (s ^ string_of_int n)
let check2 s m n ok =
  if not ok then fail (s ^ string_of_int m ^ "," ^ string_of_int n)
let raises_inv s f =
  try ignore (f ()); fail (s ^ " NOEXN")
  with Invalid_argument _ -> () | _ -> fail (s ^ " BADEXN")
let raises_dz s f =
  try ignore (f ()); fail (s ^ " NOEXN")
  with Division_by_zero -> () | _ -> fail (s ^ " BADEXN")
let finish t =
  print_string t;
  if !fails = 0 then print_string " OK" else print_string " FAIL";
  print_newline ()
(* ---- fine prelude ---- *)
let l a = Array.length a
let en e = match e with
  | Invalid_argument s -> "Invalid_argument " ^ s
  | Failure s -> "Failure " ^ s
  | Not_found -> "Not_found"
  | Stack_overflow -> "Stack_overflow"
  | Out_of_memory -> "Out_of_memory"
  | Division_by_zero -> "Division_by_zero"
  | _ -> "other"
let run s f = try f () with e -> fail (s ^ " EXN " ^ en e)
let l a = Array.length a
(* copie locali di make_matrix: polimorfica, monomorfa, con set sicuro *)
let gmm sx sy init =
  let res = Array.make sx [||] in
  for x = 0 to pred sx do Array.unsafe_set res x (Array.make sy init) done;
  res
let imm sx sy (init : int) =
  let res = Array.make sx [||] in
  for x = 0 to pred sx do Array.unsafe_set res x (Array.make sy init) done;
  res
let smm sx sy init =
  let res = Array.make sx [||] in
  for x = 0 to pred sx do res.(x) <- Array.make sy init done;
  res
let gset (a : 'a array) i (v : 'a) = Array.unsafe_set a i v
let gget (a : 'a array) i = Array.unsafe_get a i
let gmake n (x : 'a) = Array.make n x
let gsafe_set (a : 'a array) i (v : 'a) = a.(i) <- v
let () =
  run "pred" (fun () -> check "pred" (pred 1 = 0));
  run "gmake int" (fun () -> check "gmake" (l (gmake 3 5) = 3));
  run "gmake atom" (fun () -> check "gmake" (l (gmake 3 [||]) = 3));
  run "gset" (fun () -> let r = Array.make 2 0 in gset r 0 7; check "gset" (r.(0) = 7));
  run "gget" (fun () -> let r = Array.make 2 9 in check "gget" (gget r 1 = 9));
  run "gsafe_set" (fun () -> let r = Array.make 2 0 in gsafe_set r 1 7; check "gsafe" (r.(1) = 7));
  run "gset blk" (fun () ->
    let r = Array.make 2 [||] in gset r 0 (Array.make 3 4); check "gsetb" (l r.(0) = 3));
  run "mm 0x0 stdlib" (fun () -> check "mm0" (l (Array.make_matrix 0 0 5) = 0));
  run "mm 1x0 stdlib" (fun () -> check "mm10" (l (Array.make_matrix 1 0 5) = 1));
  run "mm 1x1 stdlib" (fun () -> check "mm11" (l (Array.make_matrix 1 1 5) = 1));
  run "mm 1x1 stdlib idx" (fun () -> check "mm11i" ((Array.make_matrix 1 1 5).(0).(0) = 5));
  run "gmm 1x1" (fun () -> check "gmm" ((gmm 1 1 5).(0).(0) = 5));
  run "gmm 4x4" (fun () -> check "gmm" ((gmm 4 4 5).(3).(3) = 5));
  run "imm 1x1" (fun () -> check "imm" ((imm 1 1 5).(0).(0) = 5));
  run "imm 4x4" (fun () -> check "imm" ((imm 4 4 5).(3).(3) = 5));
  run "smm 1x1" (fun () -> check "smm" ((smm 1 1 5).(0).(0) = 5));
  run "smm 4x4" (fun () -> check "smm" ((smm 4 4 5).(3).(3) = 5));
  (* Array.concat (dopo la correzione di BEQ -> BNE sulla fine lista) *)
  run "cc []" (fun () -> check "cc0" (l (Array.concat ([] : int array list)) = 0));
  run "cc [a]" (fun () -> check "cc1" (l (Array.concat [Array.make 3 1]) = 3));
  run "cc [a;b]" (fun () -> let c = Array.concat [Array.make 3 1; Array.make 2 2] in
    check "cc2" (l c = 5 && c.(2) = 1 && c.(3) = 2 && c.(4) = 2));
  run "cc [a;[||];b]" (fun () -> check "cc3" (l (Array.concat [Array.make 3 1; [||]; Array.make 2 2]) = 5));
  run "cc [[||]]" (fun () -> check "cc4" (l (Array.concat [[||]]) = 0));
  run "cc big" (fun () -> check "cc5" (l (Array.concat [Array.make 100 1; Array.make 100 2]) = 200));
  run "cc 255" (fun () -> check "cc6" (l (Array.concat [Array.make 128 1; Array.make 127 2]) = 255));
  run "cc 256" (fun () -> raises_inv "cc7" (fun () -> Array.concat [Array.make 128 1; Array.make 128 2]));
  run "cc float" (fun () -> let c = Array.concat [Array.make 40 1.5; Array.make 45 2.5] in
    check "ccf len" (l c = 85); check "ccf elts" (c.(39) = 1.5 && c.(40) = 2.5 && c.(84) = 2.5));
  run "cc float bad" (fun () -> raises_inv "ccf bad" (fun () -> Array.concat [Array.make 43 1.5; Array.make 43 1.5]));
  finish "D_MM"
