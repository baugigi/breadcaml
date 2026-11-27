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
let sizes = [| 0; 1; 2; 3; 126; 127; 128; 129; 253; 254; 255 |]
let probes = [| 0; 1; 2; 126; 127; 128; 129; 253; 254; 255; 256 |]
let pget a i = a.(i)
let pset a i v = a.(i) <- v
let test_size n =
  let a = Array.make n 7 in
  checkn "make len " n (Array.length a = n);
  (let bad = ref (-1) in
   for i = n - 1 downto 0 do if a.(i) <> 7 then bad := i done;
   check2 "make fill " n !bad (!bad < 0));
  for i = 0 to n - 1 do a.(i) <- i * 3 + 1 done;
  let ok = ref true in
  for i = 0 to n - 1 do if a.(i) <> i * 3 + 1 then ok := false done;
  checkn "get/set " n !ok;
  for k = 0 to 10 do
    let p = probes.(k) in
    if p < n then begin
      check2 "probe " n p (a.(p) = p * 3 + 1);
      check2 "pget " n p (pget a p = p * 3 + 1);
      pset a p (p + 5);
      check2 "pset " n p (a.(p) = p + 5);
      a.(p) <- p * 3 + 1
    end else begin
      raises_inv "get oob" (fun () -> a.(p));
      raises_inv "set oob" (fun () -> a.(p) <- 1);
      raises_inv "pget oob" (fun () -> pget a p);
      raises_inv "pset oob" (fun () -> pset a p 1)
    end
  done;
  raises_inv "get -1" (fun () -> a.(-1));
  raises_inv "set -1" (fun () -> a.(-1) <- 1);
  let b = Array.init n (fun i -> i * 3 + 1) in
  let c = Array.copy a in
  let ok2 = ref (Array.length b = n && Array.length c = n) in
  for i = 0 to n - 1 do
    if b.(i) <> i * 3 + 1 || c.(i) <> i * 3 + 1 then ok2 := false
  done;
  checkn "init/copy " n !ok2;
  if n > 0 then begin
    c.(n - 1) <- 99;
    checkn "copy independent " n (a.(n - 1) = (n - 1) * 3 + 1)
  end
let test_make_err () =
  raises_inv "make 256" (fun () -> Array.make 256 0);
  raises_inv "make 300" (fun () -> Array.make 300 0);
  raises_inv "make -1" (fun () -> Array.make (-1) 0);
  raises_inv "make 256 blk" (fun () -> Array.make 256 [1]);
  raises_inv "make 86 f" (fun () -> Array.make 86 1.5);
  raises_inv "make 128 f" (fun () -> Array.make 128 1.5);
  raises_inv "make 255 f" (fun () -> Array.make 255 1.5)
let test_make_blk () =
  let l = [1; 2; 3] in
  for it = 1 to 40 do
    let a = Array.make 255 l in
    checkn "make blk len " it (Array.length a = 255);
    checkn "make blk elt " it (a.(0) == l && a.(127) == l && a.(128) == l && a.(254) == l)
  done
let () =
  for i = 0 to 10 do run "size" (fun () -> test_size sizes.(i)) done;
  run "make_err" test_make_err;
  run "make_blk" test_make_blk;
  finish "T03A"
