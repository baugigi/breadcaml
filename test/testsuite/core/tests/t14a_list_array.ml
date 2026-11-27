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
let scr n = (n * 37 + 11) mod 211
let cmpi (a : int) b = compare a b
let t_list () =
  let l = List.init 200 scr in
  check "len" (List.length l = 200);
  check "nth" (List.nth l 199 = 200 && List.nth l 0 = 11);
  let s = List.sort cmpi l in
  check "sort first/last" (List.hd s = 1 && List.nth s 199 = 210 && List.nth s 100 = 106);
  let rec sorted = function a :: (b :: _ as t) -> a <= b && sorted t | _ -> true in
  check "sorted" (sorted s);
  let s2 = List.stable_sort cmpi (List.rev l) in
  check "stable_sort" (s2 = s);
  check "rev" (List.rev (List.rev l) = l);
  check "map" (List.nth (List.map (fun x -> x + 1) l) 5 = 197);
  check "filter" (List.length (List.filter (fun x -> x mod 2 = 0) l) = 100);
  check "mem" (List.mem 59 l && not (List.mem 1000 l));
  check "exists/for_all" (List.exists (fun x -> x = 70) l && List.for_all (fun x -> x >= 0) l);
  check "assoc" (List.assoc 3 [(1, 10); (3, 30)] = 30);
  (try ignore (List.nth l 200); fail "nth NOEXN" with Failure _ -> ());
  check "fold_right" (List.fold_right (fun x a -> x + a) [1; 2; 3] 0 = 6);
  check "concat" (List.length (List.concat [l; l]) = 400);
  check "sort_uniq" (List.length (List.sort_uniq cmpi (l @ l)) = 200);
  check "append" (List.length (l @ l) = 400)
let t_array () =
  let a = Array.init 255 scr in
  Array.sort cmpi a;
  check "asort" (a.(0) = 0 && a.(254) = 210 && a.(127) = 104);
  let ok = ref true in
  for i = 0 to 253 do if a.(i) > a.(i + 1) then ok := false done;
  check "asorted" !ok;
  let b = Array.init 255 scr in
  Array.stable_sort cmpi b;
  check "stable_sort" (b.(0) = a.(0) && b.(254) = a.(254) && b.(100) = a.(100));
  let c = Array.of_list (Array.to_list b) in
  check "of_list/to_list" (Array.length c = 255 && c.(254) = b.(254));
  let m = Array.map (fun x -> x * 2) c in
  check "map" (m.(10) = 2 * c.(10));
  let t = Array.fold_left (+) 0 (Array.init 100 (fun i -> i)) in
  check "fold" (t = 4950);
  let r = ref 0 in
  Array.iteri (fun i x -> r := !r + i - x) (Array.init 10 (fun i -> i));
  check "iteri" (!r = 0)
let () =
  run "list" t_list;
  run "array" t_array;
  finish "T14A"
