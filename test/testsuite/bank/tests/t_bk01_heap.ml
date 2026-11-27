(* ---- prelude comune (generato da gen_tests.py) ---- *)
let fails = ref 0
let fail s = incr fails; print_string "FAIL "; print_string s; print_newline ()
let check s ok = if not ok then fail s
let checkn s n ok = if not ok then fail (s ^ string_of_int n)
let check2 s m n ok =
  if not ok then fail (s ^ string_of_int m ^ "," ^ string_of_int n)
let run s f =
  try f () with
  | Stack_overflow -> fail (s ^ " STACK")
  | Out_of_memory -> fail (s ^ " OOM")
  | Not_found -> fail (s ^ " NOTFOUND")
  | Failure m -> fail (s ^ " FAILURE " ^ m)
  | Invalid_argument m -> fail (s ^ " INVARG " ^ m)
  | _ -> fail (s ^ " EXN")
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
(* t_bk01: heap e pila oltre $A000 (BASIC ROM sovrapposta, -mem 0xCFFF).
   Strutture vive di vario tipo che attraversano molti cicli di GC: i dati
   si spostano tra i due semispazi, quindi prima o poi stanno sopra $A000.
   Se il BASIC ROM restasse attiva in lettura, i controlli fallirebbero. *)
let burn k = for i = 1 to k do ignore (List.init 20 (fun j -> j + i)) done
let l = List.init 60 (fun i -> i * 7 + 1)
let a = Array.init 80 (fun i -> i * 3)
let b = Bytes.init 100 (fun i -> Char.chr (65 + i mod 26))
let ps = List.init 20 (fun i -> (i, string_of_int (i * i)))
let cl = List.init 10 (fun k -> (fun x -> x + k))
let cnt = ref 0
let buf = Buffer.create 16
let verify r =
  check2 "list " r 0 (List.length l = 60 && List.nth l 59 = 414 && List.hd l = 1);
  check2 "array " r 0 (Array.length a = 80 && a.(79) = 237 && a.(40) = 120);
  let ok = ref true in
  for i = 0 to 99 do if Char.code (Bytes.get b i) <> 65 + i mod 26 then ok := false done;
  check2 "bytes " r 0 !ok;
  check2 "pairs " r 0
    (List.for_all (fun (i, s) -> s = string_of_int (i * i)) ps);
  check2 "closures " r 0
    (List.for_all2 (fun k f -> f 100 = 100 + k) (List.init 10 (fun k -> k)) cl);
  check2 "ref " r 0 (!cnt = r * (r + 1) / 2);
  check2 "buffer " r 0 (Buffer.length buf = r && Buffer.nth buf (r - 1) = Char.chr (48 + r mod 10))
let t_rounds () =
  for r = 1 to 14 do
    burn (80 + r * 37);
    cnt := !cnt + r;
    Buffer.add_char buf (Char.chr (48 + r mod 10));
    verify r
  done
let t_growth () =
  (* struttura che cresce attraverso i GC, in testa *)
  let acc = ref [] in
  for i = 1 to 150 do
    acc := i :: !acc;
    if i mod 25 = 0 then burn 150
  done;
  check "growth len" (List.length !acc = 150);
  check "growth sum" (List.fold_left (+) 0 !acc = 11325)
let () =
  run "rounds" t_rounds;
  run "growth" t_growth;
  finish "BK01"
