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
let clo1 a =
  let v0 = a + 0 in
  fun x -> x + v0
let clo2 a =
  let v0 = a + 0 in
  let v1 = a + 1 in
  fun x -> x + v0 + v1
let clo3 a =
  let v0 = a + 0 in
  let v1 = a + 1 in
  let v2 = a + 2 in
  fun x -> x + v0 + v1 + v2
let clo4 a =
  let v0 = a + 0 in
  let v1 = a + 1 in
  let v2 = a + 2 in
  let v3 = a + 3 in
  fun x -> x + v0 + v1 + v2 + v3
let clo5 a =
  let v0 = a + 0 in
  let v1 = a + 1 in
  let v2 = a + 2 in
  let v3 = a + 3 in
  let v4 = a + 0 in
  fun x -> x + v0 + v1 + v2 + v3 + v4
let clo6 a =
  let v0 = a + 0 in
  let v1 = a + 1 in
  let v2 = a + 2 in
  let v3 = a + 3 in
  let v4 = a + 0 in
  let v5 = a + 1 in
  fun x -> x + v0 + v1 + v2 + v3 + v4 + v5
let clo7 a =
  let v0 = a + 0 in
  let v1 = a + 1 in
  let v2 = a + 2 in
  let v3 = a + 3 in
  let v4 = a + 0 in
  let v5 = a + 1 in
  let v6 = a + 2 in
  fun x -> x + v0 + v1 + v2 + v3 + v4 + v5 + v6
let clo8 a =
  let v0 = a + 0 in
  let v1 = a + 1 in
  let v2 = a + 2 in
  let v3 = a + 3 in
  let v4 = a + 0 in
  let v5 = a + 1 in
  let v6 = a + 2 in
  let v7 = a + 3 in
  fun x -> x + v0 + v1 + v2 + v3 + v4 + v5 + v6 + v7
let clo9 a =
  let v0 = a + 0 in
  let v1 = a + 1 in
  let v2 = a + 2 in
  let v3 = a + 3 in
  let v4 = a + 0 in
  let v5 = a + 1 in
  let v6 = a + 2 in
  let v7 = a + 3 in
  let v8 = a + 0 in
  fun x -> x + v0 + v1 + v2 + v3 + v4 + v5 + v6 + v7 + v8
let clo16 a =
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
  let v10 = a + 2 in
  let v11 = a + 3 in
  let v12 = a + 0 in
  let v13 = a + 1 in
  let v14 = a + 2 in
  let v15 = a + 3 in
  fun x -> x + v0 + v1 + v2 + v3 + v4 + v5 + v6 + v7 + v8 + v9 + v10 + v11 + v12 + v13 + v14 + v15
let clo63 a =
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
  let v10 = a + 2 in
  let v11 = a + 3 in
  let v12 = a + 0 in
  let v13 = a + 1 in
  let v14 = a + 2 in
  let v15 = a + 3 in
  let v16 = a + 0 in
  let v17 = a + 1 in
  let v18 = a + 2 in
  let v19 = a + 3 in
  let v20 = a + 0 in
  let v21 = a + 1 in
  let v22 = a + 2 in
  let v23 = a + 3 in
  let v24 = a + 0 in
  let v25 = a + 1 in
  let v26 = a + 2 in
  let v27 = a + 3 in
  let v28 = a + 0 in
  let v29 = a + 1 in
  let v30 = a + 2 in
  let v31 = a + 3 in
  let v32 = a + 0 in
  let v33 = a + 1 in
  let v34 = a + 2 in
  let v35 = a + 3 in
  let v36 = a + 0 in
  let v37 = a + 1 in
  let v38 = a + 2 in
  let v39 = a + 3 in
  let v40 = a + 0 in
  let v41 = a + 1 in
  let v42 = a + 2 in
  let v43 = a + 3 in
  let v44 = a + 0 in
  let v45 = a + 1 in
  let v46 = a + 2 in
  let v47 = a + 3 in
  let v48 = a + 0 in
  let v49 = a + 1 in
  let v50 = a + 2 in
  let v51 = a + 3 in
  let v52 = a + 0 in
  let v53 = a + 1 in
  let v54 = a + 2 in
  let v55 = a + 3 in
  let v56 = a + 0 in
  let v57 = a + 1 in
  let v58 = a + 2 in
  let v59 = a + 3 in
  let v60 = a + 0 in
  let v61 = a + 1 in
  let v62 = a + 2 in
  fun x -> x + v0 + v1 + v2 + v3 + v4 + v5 + v6 + v7 + v8 + v9 + v10 + v11 + v12 + v13 + v14 + v15 + v16 + v17 + v18 + v19 + v20 + v21 + v22 + v23 + v24 + v25 + v26 + v27 + v28 + v29 + v30 + v31 + v32 + v33 + v34 + v35 + v36 + v37 + v38 + v39 + v40 + v41 + v42 + v43 + v44 + v45 + v46 + v47 + v48 + v49 + v50 + v51 + v52 + v53 + v54 + v55 + v56 + v57 + v58 + v59 + v60 + v61 + v62
let clo64 a =
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
  let v10 = a + 2 in
  let v11 = a + 3 in
  let v12 = a + 0 in
  let v13 = a + 1 in
  let v14 = a + 2 in
  let v15 = a + 3 in
  let v16 = a + 0 in
  let v17 = a + 1 in
  let v18 = a + 2 in
  let v19 = a + 3 in
  let v20 = a + 0 in
  let v21 = a + 1 in
  let v22 = a + 2 in
  let v23 = a + 3 in
  let v24 = a + 0 in
  let v25 = a + 1 in
  let v26 = a + 2 in
  let v27 = a + 3 in
  let v28 = a + 0 in
  let v29 = a + 1 in
  let v30 = a + 2 in
  let v31 = a + 3 in
  let v32 = a + 0 in
  let v33 = a + 1 in
  let v34 = a + 2 in
  let v35 = a + 3 in
  let v36 = a + 0 in
  let v37 = a + 1 in
  let v38 = a + 2 in
  let v39 = a + 3 in
  let v40 = a + 0 in
  let v41 = a + 1 in
  let v42 = a + 2 in
  let v43 = a + 3 in
  let v44 = a + 0 in
  let v45 = a + 1 in
  let v46 = a + 2 in
  let v47 = a + 3 in
  let v48 = a + 0 in
  let v49 = a + 1 in
  let v50 = a + 2 in
  let v51 = a + 3 in
  let v52 = a + 0 in
  let v53 = a + 1 in
  let v54 = a + 2 in
  let v55 = a + 3 in
  let v56 = a + 0 in
  let v57 = a + 1 in
  let v58 = a + 2 in
  let v59 = a + 3 in
  let v60 = a + 0 in
  let v61 = a + 1 in
  let v62 = a + 2 in
  let v63 = a + 3 in
  fun x -> x + v0 + v1 + v2 + v3 + v4 + v5 + v6 + v7 + v8 + v9 + v10 + v11 + v12 + v13 + v14 + v15 + v16 + v17 + v18 + v19 + v20 + v21 + v22 + v23 + v24 + v25 + v26 + v27 + v28 + v29 + v30 + v31 + v32 + v33 + v34 + v35 + v36 + v37 + v38 + v39 + v40 + v41 + v42 + v43 + v44 + v45 + v46 + v47 + v48 + v49 + v50 + v51 + v52 + v53 + v54 + v55 + v56 + v57 + v58 + v59 + v60 + v61 + v62 + v63
let () =
  run "clo1" (fun () -> let f = clo1 2 in check2 "clo " 1 3 (f 3 = 5); check2 "clo " 1 10 (f 10 = 12); check2 "clo " 1 3 (f 3 = 5));
  run "clo2" (fun () -> let f = clo2 2 in check2 "clo " 2 3 (f 3 = 8); check2 "clo " 2 10 (f 10 = 15); check2 "clo " 2 3 (f 3 = 8));
  run "clo3" (fun () -> let f = clo3 2 in check2 "clo " 3 3 (f 3 = 12); check2 "clo " 3 10 (f 10 = 19); check2 "clo " 3 3 (f 3 = 12));
  run "clo4" (fun () -> let f = clo4 2 in check2 "clo " 4 3 (f 3 = 17); check2 "clo " 4 10 (f 10 = 24); check2 "clo " 4 3 (f 3 = 17));
  run "clo5" (fun () -> let f = clo5 2 in check2 "clo " 5 3 (f 3 = 19); check2 "clo " 5 10 (f 10 = 26); check2 "clo " 5 3 (f 3 = 19));
  run "clo6" (fun () -> let f = clo6 2 in check2 "clo " 6 3 (f 3 = 22); check2 "clo " 6 10 (f 10 = 29); check2 "clo " 6 3 (f 3 = 22));
  run "clo7" (fun () -> let f = clo7 2 in check2 "clo " 7 3 (f 3 = 26); check2 "clo " 7 10 (f 10 = 33); check2 "clo " 7 3 (f 3 = 26));
  run "clo8" (fun () -> let f = clo8 2 in check2 "clo " 8 3 (f 3 = 31); check2 "clo " 8 10 (f 10 = 38); check2 "clo " 8 3 (f 3 = 31));
  run "clo9" (fun () -> let f = clo9 2 in check2 "clo " 9 3 (f 3 = 33); check2 "clo " 9 10 (f 10 = 40); check2 "clo " 9 3 (f 3 = 33));
  run "clo16" (fun () -> let f = clo16 2 in check2 "clo " 16 3 (f 3 = 59); check2 "clo " 16 10 (f 10 = 66); check2 "clo " 16 3 (f 3 = 59));
  run "clo63" (fun () -> let f = clo63 2 in check2 "clo " 63 3 (f 3 = 222); check2 "clo " 63 10 (f 10 = 229); check2 "clo " 63 3 (f 3 = 222));
  run "clo64" (fun () -> let f = clo64 2 in check2 "clo " 64 3 (f 3 = 227); check2 "clo " 64 10 (f 10 = 234); check2 "clo " 64 3 (f 3 = 227));
  finish "T05A"
