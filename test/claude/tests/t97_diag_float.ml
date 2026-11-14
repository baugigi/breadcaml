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
let dg s got exp =
  if got <> exp then begin
    incr fails; print_string s; print_string " got="; print_int got;
    print_string " exp="; print_int exp; print_newline ()
  end
let dgb s b = dg s (if b then 1 else 0) 1
let ex s f = try f () with _ -> dg (s ^ " exn") 1 0
let () =
  let sizes = [| 1; 2; 3; 10; 84; 85 |] in
  for k = 0 to Array.length sizes - 1 do
    let n = sizes.(k) in
    let nm s = s ^ " n=" ^ string_of_int n in
    ex (nm "make") (fun () ->
      let a = Array.make n 1.5 in
      dg (nm "length") (Array.length a) n;
      dg (nm "get0") (int_of_float (a.(0) *. 2.0)) 3;
      dg (nm "getlast") (int_of_float (a.(n - 1) *. 2.0)) 3;
      (try ignore a.(n); dg (nm "oob get NOEXN") 0 1
       with Invalid_argument _ -> () | _ -> dg (nm "oob get other exn") 1 0);
      (try a.(n) <- 1.0; dg (nm "oob set NOEXN") 0 1
       with Invalid_argument _ -> () | _ -> dg (nm "oob set other exn") 1 0);
      a.(n - 1) <- 2.5;
      dg (nm "set last") (int_of_float (a.(n - 1) *. 2.0)) 5);
    ex (nm "init") (fun () ->
      let b = Array.init n (fun i -> float_of_int i) in
      dg (nm "init len") (Array.length b) n;
      dg (nm "init last") (int_of_float b.(n - 1)) (n - 1);
      dg (nm "init first") (int_of_float b.(0)) 0);
    ex (nm "sub") (fun () ->
      let b = Array.init n (fun i -> float_of_int i) in
      let s = Array.sub b 0 1 in
      dg (nm "sub len") (Array.length s) 1;
      dg (nm "sub 0") (int_of_float s.(0)) 0;
      let c = Array.append (Array.sub b 0 1) (Array.sub b 0 1) in
      dg (nm "append len") (Array.length c) 2)
  done;
  ex "lit1" (fun () -> let x = [| 1.5 |] in
    dg "lit1 len" (Array.length x) 1; dg "lit1 val" (int_of_float (x.(0) *. 2.0)) 3);
  ex "lit2" (fun () -> let x = [| 1.5; 2.5 |] in
    dg "lit2 len" (Array.length x) 2; dg "lit2 v0" (int_of_float (x.(0) *. 2.0)) 3;
    dg "lit2 v1" (int_of_float (x.(1) *. 2.0)) 5);
  ex "lit3" (fun () -> let x = [| 1.5; 2.5; 3.5 |] in
    dg "lit3 v0" (int_of_float (x.(0) *. 2.0)) 3; dg "lit3 v2" (int_of_float (x.(2) *. 2.0)) 7);
  finish "d_float"
