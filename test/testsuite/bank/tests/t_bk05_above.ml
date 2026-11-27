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
(* t_bk05: verifica DETERMINISTICA che i dati stiano nella RAM sotto il BASIC
   ROM ($A000-$BFFF) quando si eseguono le routine BASIC con operandi in heap.
   `above x` usa la primitiva di test bk_addr (bk_addr.asm, bk_addr.c), che
   restituisce Val_int(indirizzo / 2) con segno: $A000..$BFFF = -12288..-8193. Si alloca finche' un blocco nuovo cade in
   quella zona, poi si costruiscono subito i dati di prova (senza GC in mezzo)
   e si eseguono FCOMP, FIN, FOUT, MOVMF e syserr su di essi.
   Un tentativo e' valido solo se alla fine tutti i blocchi sono ancora sopra
   $A000 (se un GC li ha spostati si ritenta). Serve -mem 0xCFFF. *)
external addr : 'a -> int = "bk_addr"   (* Val_int(indirizzo / 2): bk_addr.asm + bk_addr.c *)
let above x = let v = addr x in v >= -12288 && v <= -8193
let near a b = abs_float (a -. b) <= 1e-5 *. (1.0 +. abs_float b)
let mk i = float_of_int i *. 0.25 +. 1.0
let fresh () = ref 0
let rec reach n = if n = 0 then false else if above (fresh ()) then true else reach (n - 1)
let attempt () =
  if not (reach 6000) then false else begin
    let a = mk 5 and b = mk 9 in                  (* 2.25 e 3.25 *)
    let sa = string_of_float a and sb = string_of_float b in
    let c = mk 5 in
    (* FCOMP: secondo operando in heap sopra $A000 *)
    check "A lt" (a < b);
    check "A gt" (b > a);
    check "A eq" (a = c && compare a c = 0);
    check "A cmp" (compare a b < 0 && compare b a > 0);
    (* FIN: stringhe in heap sopra $A000 *)
    check "A fos a" (near (float_of_string sa) 2.25);
    check "A fos b" (near (float_of_string sb) 3.25);
    (* MOVMF: il risultato viene scritto in heap sopra $A000 *)
    let s = a +. b in
    let p = a *. b in
    let q = sqrt (a *. a) in
    check "A add" (near s 5.5);
    check "A mul" (near p 7.3125);
    check "A sqrt" (near q 2.25);
    (* FOUT *)
    check "A fout" (near (float_of_string (string_of_float s)) 5.5);
    (* syserr: messaggio copiato dalla ROM BASIC *)
    (try ignore (exp 1000.0)
     with Sys_error m -> check "A msg" (String.length m > 0 && String.length m < 23)
        | _ -> ());
    above a && above b && above c && above sa && above sb && above s && above p
  end
let valid = ref 0
let t_above () =
  let n = ref 0 in
  while !valid < 3 && !n < 12 do
    incr n;
    if attempt () then incr valid
  done;
  check "heap sopra $A000 (tentativi validi)" (!valid >= 3)
let () =
  run "above" t_above;
  finish "BK05"
