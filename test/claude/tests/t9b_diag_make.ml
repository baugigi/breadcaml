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
let rep nm n got =
  let first = ref (-1) and cnt = ref 0 in
  for i = n - 1 downto 0 do if not (got i) then (first := i; incr cnt) done;
  dg (nm ^ " bad count n=" ^ string_of_int n) !cnt 0;
  if !cnt > 0 then dg (nm ^ " first bad idx n=" ^ string_of_int n) !first (-1)
let () =
  let sizes = [| 1; 2; 3; 4; 10; 120; 127; 128; 255 |] in
  let v = ref 9 in
  for k = 0 to Array.length sizes - 1 do
    let n = sizes.(k) in
    ex "int const" (fun () -> let a = Array.make n 7 in rep "int const 7" n (fun i -> a.(i) = 7));
    ex "int zero" (fun () -> let a = Array.make n 0 in rep "int zero" n (fun i -> a.(i) = 0));
    ex "int var" (fun () -> let a = Array.make n !v in rep "int var 9" n (fun i -> a.(i) = 9));
    ex "int neg" (fun () -> let a = Array.make n (-3) in rep "int neg" n (fun i -> a.(i) = (-3)))
  done;
  let fz = [| 1; 2; 3; 4; 10; 84; 85 |] in
  for k = 0 to Array.length fz - 1 do
    let n = fz.(k) in
    ex "float const" (fun () -> let a = Array.make n 1.5 in rep "float const" n (fun i -> a.(i) = 1.5));
    ex "float zero" (fun () -> let a = Array.make n 0.0 in rep "float zero" n (fun i -> a.(i) = 0.0))
  done;
  ex "make tuple" (fun () ->
    let t = (1, 2) in let a = Array.make 5 t in
    rep "tuple" 5 (fun i -> a.(i) == t));
  ex "make str" (fun () ->
    let t = "ab" in let a = Array.make 5 t in
    rep "string" 5 (fun i -> a.(i) == t));
  finish "d_make"
