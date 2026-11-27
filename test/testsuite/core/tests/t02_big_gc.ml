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
let mkarr n a = Array.init n (fun i -> (i mod 16, a))
let sumarr arr =
  let s = ref 0 in
  for i = 0 to Array.length arr - 1 do
    let (p, q) = arr.(i) in
    s := !s + p + q
  done;
  !s
let b127 = mkarr 127 1
let b128 = mkarr 128 2
let b255 = mkarr 255 3
let shared = let t = (7, 8) in Array.make 255 t
let intarr = Array.init 255 (fun i -> i * 3)
let live = Array.make 40 (0, 0)
let total = ref 0
let garbage i =
  let s = String.make 200 'g' in
  let a = Array.make 120 i in
  let l = [i; i + 1; i + 2; i + 3; i + 4; i + 5; i + 6; i + 7] in
  let r = Array.make 255 i in
  String.length s + Array.length a + List.length l + r.(0)
let verify tag =
  checkn "b127 " tag (Array.length b127 = 127 && sumarr b127 = 1072);
  checkn "b128 " tag (Array.length b128 = 128 && sumarr b128 = 1216);
  checkn "b255 " tag (Array.length b255 = 255 && sumarr b255 = 2670);
  checkn "shared " tag (shared.(0) == shared.(254) && shared.(127) == shared.(128)
                        && fst shared.(0) = 7 && snd shared.(254) = 8);
  checkn "intarr " tag (intarr.(0) = 0 && intarr.(127) = 381 && intarr.(128) = 384
                        && intarr.(254) = 762);
  checkn "not shared " tag (not (b127.(0) == b127.(16)))
let verify_live () =
  let ok = ref true in
  for j = 0 to 39 do
    let (p, q) = live.(j) in
    let e = 150 - ((150 - j) mod 40 + 40) mod 40 in
    if not (p = e && q = e + 1) then ok := false
  done;
  check "live" !ok
let t () =
  for i = 1 to 150 do
    total := (!total + garbage i) land 16383;
    live.(i mod 40) <- (i, i + 1);
    if i mod 10 = 0 then verify i
  done;
  check "total" (!total = 11373);
  verify_live ()
let () =
  run "gc-big" t;
  finish "T02"
