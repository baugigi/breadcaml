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
type tree = Leaf | Node of tree * int * tree
type cell = { mutable next: cell option; v: int }
let rec build d i = if d = 0 then Leaf
  else Node (build (d - 1) (2 * i), i, build (d - 1) (2 * i + 1))
let rec tsum t = match t with Leaf -> 0 | Node (l, v, r) -> tsum l + v + tsum r
let rec tcount t = match t with Leaf -> 0 | Node (l, _, r) -> tcount l + 1 + tcount r
let rec lst n acc = if n = 0 then acc else lst (n - 1) (n :: acc)
let prev = ref Leaf
let t_tree () =
  for it = 1 to 30 do
    let t = build 8 1 in
    checkn "tree count " it (tcount t = 255);
    checkn "tree sum " it (tsum t = -128);
    checkn "prev sum " it (tsum !prev = (if it = 1 then 0 else -128));
    prev := t
  done
let t_lists () =
  for it = 1 to 8 do
    List.iter (fun n ->
      let l = lst n [] in
      check2 "list len " it n (List.length l = n);
      check2 "list sum " it n (List.fold_left (+) 0 l = (match n with 0 -> 0 | 1 -> 1 | 2 -> 3 | 127 -> 8128 | 128 -> 8256 | 255 -> -128 | 300 -> 12382 | _ -> 0));
      check2 "list rev rev " it n (List.rev (List.rev l) = l)) [0; 1; 2; 127; 128; 255; 300]
  done
let t_strings () =
  for it = 1 to 5 do
    let s = ref "" in
    for i = 1 to 250 do s := !s ^ "ab" done;
    checkn "str len " it (String.length !s = 500);
    checkn "str chars " it (String.get !s 0 = 'a' && String.get !s 1 = 'b'
                            && String.get !s 498 = 'a' && String.get !s 499 = 'b')
  done
let t_closures () =
  for it = 1 to 5 do
    let fs = ref [] in
    for i = 1 to 100 do fs := (fun x -> x + i) :: !fs done;
    let f = List.fold_left (fun f g -> (fun x -> g (f x))) (fun x -> x) !fs in
    checkn "compose " it (f 0 = 5050)
  done
let t_matrix () =
  for it = 1 to 6 do
    let m = Array.make_matrix 16 16 0 in
    for i = 0 to 15 do for j = 0 to 15 do m.(i).(j) <- i + j done done;
    let s = ref 0 in
    for i = 0 to 15 do for j = 0 to 15 do s := !s + m.(i).(j) done done;
    checkn "matrix " it (!s = 3840 && m.(15).(15) = 30 && m.(0).(0) = 0)
  done
let t_chain () =
  for it = 1 to 6 do
    let head = ref None in
    for i = 0 to 199 do head := Some { next = !head; v = i mod 10 } done;
    let rec walk c acc = match c with None -> acc | Some x -> walk x.next (acc + x.v) in
    checkn "chain " it (walk !head 0 = 900)
  done
let t_floats () =
  for it = 1 to 6 do
    let l = ref [] in
    for i = 1 to 100 do l := float_of_int i :: !l done;
    let s = List.fold_left (+.) 0.0 !l in
    checkn "floats " it (s = 5050.0)
  done
let () =
  run "tree" t_tree; run "lists" t_lists; run "strings" t_strings;
  run "closures" t_closures; run "matrix" t_matrix; run "chain" t_chain;
  run "floats" t_floats;
  finish "T13"
