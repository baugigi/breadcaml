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
let pget a i = a.(i)
let pset a i v = a.(i) <- v
let fsizes = [| 0; 1; 2; 3; 84; 85 |]
let fprobes = [| 0; 1; 2; 3; 83; 84; 85; 86; 127; 128 |]
let test_fsize n =
  let a = Array.make n 1.5 in
  checkn "f make len " n (Array.length a = n);
  (let bad = ref (-1) in
   for i = n - 1 downto 0 do if a.(i) <> 1.5 then bad := i done;
   check2 "f make fill " n !bad (!bad < 0));
  for i = 0 to n - 1 do a.(i) <- float_of_int i *. 0.5 done;
  let ok = ref true in
  for i = 0 to n - 1 do if a.(i) <> float_of_int i *. 0.5 then ok := false done;
  checkn "f get/set " n !ok;
  for k = 0 to 9 do
    let p = fprobes.(k) in
    if p < n then begin
      check2 "f probe " n p (a.(p) = float_of_int p *. 0.5);
      check2 "f pget " n p (pget a p = float_of_int p *. 0.5)
    end else begin
      raises_inv "f get oob" (fun () -> a.(p));
      raises_inv "f set oob" (fun () -> a.(p) <- 1.0);
      raises_inv "f pget oob" (fun () -> pget a p)
    end
  done;
  let b = Array.init n (fun i -> float_of_int i) in
  let c = Array.copy a in
  let ok2 = ref (Array.length b = n && Array.length c = n) in
  for i = 0 to n - 1 do
    if b.(i) <> float_of_int i || c.(i) <> float_of_int i *. 0.5 then ok2 := false
  done;
  checkn "f init/copy " n !ok2
let () =
  for i = 0 to 5 do run "fsize" (fun () -> test_fsize fsizes.(i)) done;
  finish "T03B"
