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
let ident n = Array.init n (fun i -> i)
let ident_b n = Array.init n (fun i -> 1000 + i)
let report nm a e len =
  let first = ref (-1) in
  for i = len - 1 downto 0 do if a.(i) <> e i then first := i done;
  dg (nm ^ " first bad idx") !first (-1);
  if !first >= 0 then dg (nm ^ " value there") a.(!first) (e !first)
let same so d n =
  let a = ident 255 in
  ex "same" (fun () -> Array.blit a so a d n);
  report ("same " ^ string_of_int so ^ "," ^ string_of_int d ^ "," ^ string_of_int n) a
    (fun i -> if i >= d && i < d + n then so + i - d else i) 255
let other so d n =
  let a = ident 255 and b = ident_b 255 in
  ex "other" (fun () -> Array.blit a so b d n);
  report ("other " ^ string_of_int so ^ "," ^ string_of_int d ^ "," ^ string_of_int n) b
    (fun i -> if i >= d && i < d + n then so + i - d else 1000 + i) 255
let () =
  let c = [| (0, 0, 0); (0, 0, 1); (254, 0, 1); (0, 254, 1); (0, 1, 2); (1, 0, 2);
             (3, 5, 200); (127, 128, 100); (128, 127, 100) |] in
  for k = 0 to Array.length c - 1 do
    let (so, d, n) = c.(k) in
    same so d n; other so d n
  done;
  let a = ident 10 in
  Array.blit a 2 a 4 3;
  report "small overlap fwd" a (fun i -> if i >= 4 && i < 7 then i - 2 else i) 10;
  let b = ident 10 in
  Array.blit b 4 b 2 3;
  report "small overlap bwd" b (fun i -> if i >= 2 && i < 5 then i + 2 else i) 10;
  finish "d_blit"
