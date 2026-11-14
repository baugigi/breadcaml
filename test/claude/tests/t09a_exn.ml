(* ---- prelude comune (generato da gen_tests.py) ---- *)
let fails = ref 0
let fail s = incr fails; print_string "FAIL "; print_string s; print_newline ()
let check s ok = if not ok then fail s
let checkn s n ok = if not ok then fail (s ^ string_of_int n)
let check2 s m n ok =
  if not ok then fail (s ^ string_of_int m ^ "," ^ string_of_int n)
let run s f = try f () with _ -> fail (s ^ " EXN")
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
exception E1 of int
exception E2 of string * int
exception E3
let rec down n = if n = 0 then raise Not_found else 1 + down (n - 1)
let rec down_try n = if n = 0 then raise E3 else (try 1 + down_try (n - 1) with E1 _ -> 0)
let nested () =
  try
    try
      try raise (E1 5) with E2 _ -> 0
    with E1 n -> raise (E2 ("re", n + 1))
  with E2 (s, n) -> if String.equal s "re" then n else -1
let reraise () =
  try (try raise E3 with e -> raise e) with E3 -> 1 | _ -> 2
let guard n = try raise (E1 n) with E1 k when k > 3 -> 1 | E1 _ -> 2
let after_trap_balance () =
  (* push/pop di trap in loop: se SP non e' bilanciato la ricorsione sotto crolla *)
  let c = ref 0 in
  for i = 1 to 300 do
    (try if i mod 3 = 0 then raise Not_found else incr c with Not_found -> c := !c + 2)
  done;
  !c
let prim_exn () =
  let r = ref 0 in
  (try ignore (Array.make 300 0) with Invalid_argument _ -> incr r);
  (try ignore ([|1; 2|].(5)) with Invalid_argument _ -> incr r);
  (try ignore ("abc".[10]) with Invalid_argument _ -> incr r);
  (try ignore (1 / (!r - !r)) with Division_by_zero -> incr r);
  (try ignore (5 mod (!r - !r)) with Division_by_zero -> incr r);
  (try failwith "boom" with Failure s -> if String.equal s "boom" then incr r);
  (try invalid_arg "ia" with Invalid_argument s -> if String.equal s "ia" then incr r);
  (try ignore (List.assoc 3 [(1, 2)]) with Not_found -> incr r);
  !r
let alloc_in_try () =
  let ok = ref true in
  for i = 1 to 150 do
    (try
       let s = String.make 150 'q' in
       let a = Array.make 100 i in
       raise (E2 (s, Array.length a + i))
     with E2 (s, n) -> if not (String.length s = 150 && n = 100 + i) then ok := false)
  done;
  !ok
let thrower3 a =
  let v0 = a + 0 in
  let v1 = a + 1 in
  let v2 = a + 2 in
  if v0 + v2 > 0 then raise (E1 (v0 + v1 + v2)) else 0
let thrower10 a =
  let v0 = a + 0 in
  let v1 = a + 1 in
  let v2 = a + 2 in
  let v3 = a + 3 in
  let v4 = a + 0 in
  let v5 = a + 1 in
  let v6 = a + 2 in
  let v7 = a + 3 in
  let v8 = a + 0 in
  let v9 = a + 1 in
  if v0 + v9 > 0 then raise (E1 (v0 + v1 + v2 + v3 + v4 + v5 + v6 + v7 + v8 + v9)) else 0
let () =
  run "thr3" (fun () -> checkn "thrower " 3 ((try thrower3 2 with E1 n -> n) = 9));
  run "thr10" (fun () -> checkn "thrower " 10 ((try thrower10 2 with E1 n -> n) = 33));
  run "down" (fun () -> check "down 50" ((try down 50 with Not_found -> -7) = -7); check "down 100" ((try down 100 with Not_found -> -7) = -7));
  run "down_try" (fun () -> check "down_try" ((try down_try 60 with E3 -> 9) = 9));
  run "nested" (fun () -> check "nested" (nested () = 6));
  run "reraise" (fun () -> check "reraise" (reraise () = 1));
  run "guard" (fun () -> check "guard" (guard 5 = 1 && guard 3 = 2 && guard 4 = 1));
  run "trapbal" (fun () -> check "trapbal" (after_trap_balance () = 400));
  run "prim_exn" (fun () -> check "prim_exn" (prim_exn () = 8));
  run "alloc_in_try" (fun () -> check "alloc_in_try" (alloc_in_try ()));
  finish "T09A"
