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
type m3_3 = Mc3_3_0 | Mc3_3_1 | Mc3_3_2 | Mb3_3_0 of int | Mb3_3_1 of int | Mb3_3_2 of int
let fm3_3 = function
  | Mc3_3_0 -> 1
  | Mc3_3_1 -> 4
  | Mc3_3_2 -> 7
  | Mb3_3_0 x -> x + 0
  | Mb3_3_1 x -> x + 11
  | Mb3_3_2 x -> x + 22
let allm3_3 a = [| Mc3_3_0; Mc3_3_1; Mc3_3_2; Mb3_3_0 (a + 0); Mb3_3_1 (a + 0); Mb3_3_2 (a + 0) |]
let swm3_3 () =
  let t = allm3_3 7 in
  for i = 0 to 5 do
    let e = if i < 3 then (i * 3 + 1) mod 1000 else 7 + (i - 3) * 11 in
    check2 "swm " 3 i (fm3_3 t.(i) = e)
  done
type m10_10 = Mc10_10_0 | Mc10_10_1 | Mc10_10_2 | Mc10_10_3 | Mc10_10_4 | Mc10_10_5 | Mc10_10_6 | Mc10_10_7 | Mc10_10_8 | Mc10_10_9 | Mb10_10_0 of int | Mb10_10_1 of int | Mb10_10_2 of int | Mb10_10_3 of int | Mb10_10_4 of int | Mb10_10_5 of int | Mb10_10_6 of int | Mb10_10_7 of int | Mb10_10_8 of int | Mb10_10_9 of int
let fm10_10 = function
  | Mc10_10_0 -> 1
  | Mc10_10_1 -> 4
  | Mc10_10_2 -> 7
  | Mc10_10_3 -> 10
  | Mc10_10_4 -> 13
  | Mc10_10_5 -> 16
  | Mc10_10_6 -> 19
  | Mc10_10_7 -> 22
  | Mc10_10_8 -> 25
  | Mc10_10_9 -> 28
  | Mb10_10_0 x -> x + 0
  | Mb10_10_1 x -> x + 11
  | Mb10_10_2 x -> x + 22
  | Mb10_10_3 x -> x + 33
  | Mb10_10_4 x -> x + 44
  | Mb10_10_5 x -> x + 55
  | Mb10_10_6 x -> x + 66
  | Mb10_10_7 x -> x + 77
  | Mb10_10_8 x -> x + 88
  | Mb10_10_9 x -> x + 99
let allm10_10 a = [| Mc10_10_0; Mc10_10_1; Mc10_10_2; Mc10_10_3; Mc10_10_4; Mc10_10_5; Mc10_10_6; Mc10_10_7; Mc10_10_8; Mc10_10_9; Mb10_10_0 (a + 0); Mb10_10_1 (a + 0); Mb10_10_2 (a + 0); Mb10_10_3 (a + 0); Mb10_10_4 (a + 0); Mb10_10_5 (a + 0); Mb10_10_6 (a + 0); Mb10_10_7 (a + 0); Mb10_10_8 (a + 0); Mb10_10_9 (a + 0) |]
let swm10_10 () =
  let t = allm10_10 7 in
  for i = 0 to 19 do
    let e = if i < 10 then (i * 3 + 1) mod 1000 else 7 + (i - 10) * 11 in
    check2 "swm " 10 i (fm10_10 t.(i) = e)
  done
let () =
  run "swm3_3" swm3_3;
  run "swm10_10" swm10_10;
  finish "10_10"
