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
let comp i =
  let s = String.make 200 'g' in
  let a = Array.make 120 i in
  let l = [i; i + 1; i + 2; i + 3; i + 4; i + 5; i + 6; i + 7] in
  let r = Array.make 255 i in
  (String.length s, Array.length a, List.length l, r.(0), r.(254), a.(119))
let () =
  let e1 = ref 0 and e2 = ref 0 and e3 = ref 0 and e4 = ref 0 and e5 = ref 0 and e6 = ref 0 in
  let first = ref 0 in
  let t = ref 0 and t2 = ref 0 in
  for i = 1 to 150 do
    let (s, a, l, r0, r1, a1) = comp i in
    if s <> 200 then (incr e1; if !first = 0 then first := i);
    if a <> 120 then incr e2;
    if l <> 8 then incr e3;
    if r0 <> i then incr e4;
    if r1 <> i then incr e5;
    if a1 <> i then incr e6;
    t := (!t + s + a + l + r0) land 16383;
    t2 := (!t2 + 328 + i) land 16383
  done;
  dg "string len bad" !e1 0; dg "array len bad" !e2 0; dg "list len bad" !e3 0;
  dg "r.(0) bad" !e4 0; dg "r.(254) bad" !e5 0; dg "a.(119) bad" !e6 0;
  dg "first bad i" !first 0;
  dg "total (land)" !t2 11373;
  dg "total (components)" !t 11373;
  finish "d_gc"
