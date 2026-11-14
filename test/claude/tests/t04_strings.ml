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
let lens = [| 0; 1; 2; 3; 4; 5; 6; 7; 8; 9; 10; 125; 126; 127; 128; 129; 252; 253; 254; 255; 256; 257; 258; 506; 507; 508; 509 |]
let test_len n =
  let b = Bytes.make n 'a' in
  checkn "blen " n (Bytes.length b = n);
  let ok = ref true in
  for i = 0 to n - 1 do if Bytes.get b i <> 'a' then ok := false done;
  checkn "fill " n !ok;
  raises_inv "get n" (fun () -> Bytes.get b n);
  raises_inv "set n" (fun () -> Bytes.set b n 'x');
  raises_inv "get -1" (fun () -> Bytes.get b (-1));
  if n > 0 then begin
    Bytes.set b (n - 1) 'z';
    checkn "set last " n (Bytes.get b (n - 1) = 'z');
    if n > 1 then checkn "set keeps prev " n (Bytes.get b (n - 2) = 'a')
  end;
  let s = Bytes.to_string b in
  let t = Bytes.to_string b in
  checkn "to_string len " n (String.length s = n && String.length t = n);
  checkn "equal copy " n (String.equal s t);
  checkn "= copy " n (s = t);
  checkn "compare copy " n (compare s t = 0);
  checkn "<= copy " n (s <= t);
  checkn ">= copy " n (s >= t);
  checkn "not < copy " n (not (s < t));
  checkn "not > copy " n (not (s > t));
  checkn "<> copy " n (not (s <> t));
  if n > 0 then begin
    let c = Bytes.copy b in
    Bytes.set c (n - 1) 'y';
    let y = Bytes.to_string c in
    checkn "neq " n (not (String.equal s y));
    checkn "cmp gt " n (compare s y > 0);
    checkn "cmp lt " n (compare y s < 0);
    checkn "y < s " n (y < s);
    checkn "y <= s " n (y <= s);
    checkn "s > y " n (s > y);
    checkn "s >= y " n (s >= y);
    checkn "not s < y " n (not (s < y));
    checkn "not s <= y " n (not (s <= y));
    checkn "not y > s " n (not (y > s));
    checkn "not y >= s " n (not (y >= s))
  end;
  if n < 509 then begin
    let p = s ^ "a" in
    checkn "concat len " n (String.length p = n + 1);
    checkn "prefix lt " n (compare s p < 0 && compare p s > 0 && s < p && p > s);
    checkn "sub back " n (String.equal (String.sub p 0 n) s)
  end;
  raises_inv "sub +1" (fun () -> String.sub s 0 (n + 1));
  raises_inv "sub neg" (fun () -> String.sub s (-1) 0)
let test_make_err () =
  raises_inv "make 510" (fun () -> Bytes.make 510 'a');
  raises_inv "create 510" (fun () -> Bytes.create 510);
  raises_inv "create 600" (fun () -> Bytes.create 600);
  raises_inv "create -1" (fun () -> Bytes.create (-1));
  raises_inv "concat >509" (fun () -> String.make 300 'a' ^ String.make 300 'b')
let test_pattern n =
  let b = Bytes.create n in
  for i = 0 to n - 1 do Bytes.set b i (Char.chr (32 + i mod 90)) done;
  let ok = ref true in
  for i = 0 to n - 1 do
    if Bytes.get b i <> Char.chr (32 + i mod 90) then ok := false
  done;
  checkn "pattern " n !ok;
  let s = Bytes.to_string b in
  let ok2 = ref true in
  for i = 0 to n - 1 do
    if String.get s i <> Char.chr (32 + i mod 90) then ok2 := false
  done;
  checkn "pattern str " n !ok2;
  (* blit sovrapposto sullo stesso buffer, spostamento di 1 *)
  if n > 2 then begin
    Bytes.blit b 0 b 1 (n - 1);
    checkn "blit up " n (Bytes.get b 0 = Char.chr 32 && Bytes.get b 1 = Char.chr 32
                         && Bytes.get b (n - 1) = Char.chr (32 + (n - 2) mod 90));
    Bytes.blit b 1 b 0 (n - 1);
    checkn "blit dn " n (Bytes.get b 0 = Char.chr 32 && Bytes.get b (n - 2) = Char.chr (32 + (n - 2) mod 90))
  end
let pool = [| ""; "a"; "b"; "aa"; "ab"; "ba"; "abc"; "abd"; "a\000"; "ab\000"; "\127"; "\128"; "\255"; "aaaa"; "aaab"; "xxxxxxx"; "xxxxxxxx"; "xxxxxxxxx"; "abcdefghijklmnopqrst"; "\000"; "\000\000" |]
let pool2 = Array.init 21 (fun i -> Bytes.to_string (Bytes.of_string pool.(i)))
let pexp = "=<<<<<<<<<<<<<<<<<<<<>=<<<<<<<<<<<<<<<<<>>>>=>><>>>><<<>><<<>>>>><=<<<<><<<<<<<<<<>>>><>=<<<><<<<>><<<<>>>>>>>=>>>><<<>><<<>>>>><>><=<>><<<>><<<<>>>><>><>=>><<<>><<<>>>>><<<<<<=<<<<<<<<<<>>>><>><<<>=<<<>><<<<>>>>>>>>>>>>=<<>>>>>>>>>>>>>>>>>>>=<>>>>>>>>>>>>>>>>>>>>=>>>>>>>>>><><<<<><<<<=<<<<<>>>><><<<<><<<<>=<<<<>>>>>>>>>>>><<<>>=<<>>>>>>>>>>>>><<<>>>=<>>>>>>>>>>>>><<<>>>>=>>>>><>><><>><<<>><<<=>>><<<<<<<<<<<<<<<<<<=<><<<<<<<<<<<<<<<<<<>="
let test_pool () =
  for i = 0 to 20 do
    for j = 0 to 20 do
      let a = pool.(i) and b = pool2.(j) in
      let e = String.get pexp (i * 21 + j) in
      let c = compare a b in
      check2 "pool cmp " i j (if e = '<' then c < 0 else if e = '=' then c = 0 else c > 0);
      check2 "pool eq " i j (String.equal a b = (e = '='));
      check2 "pool lt " i j ((a < b) = (e = '<'));
      check2 "pool le " i j ((a <= b) = (e <> '>'));
      check2 "pool gt " i j ((a > b) = (e = '>'));
      check2 "pool ge " i j ((a >= b) = (e <> '<'));
      check2 "pool ne " i j ((a <> b) = (e <> '='))
    done
  done
let test_soi () =
  check "soi 0" (String.equal (string_of_int 0) " 0");
  check "soi 1" (String.equal (string_of_int 1) " 1");
  check "soi 9" (String.equal (string_of_int 9) " 9");
  check "soi 10" (String.equal (string_of_int 10) " 10");
  check "soi 11" (String.equal (string_of_int 11) " 11");
  check "soi 99" (String.equal (string_of_int 99) " 99");
  check "soi 100" (String.equal (string_of_int 100) " 100");
  check "soi 101" (String.equal (string_of_int 101) " 101");
  check "soi 999" (String.equal (string_of_int 999) " 999");
  check "soi 1000" (String.equal (string_of_int 1000) " 1000");
  check "soi 1001" (String.equal (string_of_int 1001) " 1001");
  check "soi 9999" (String.equal (string_of_int 9999) " 9999");
  check "soi 10000" (String.equal (string_of_int 10000) " 10000");
  check "soi 10001" (String.equal (string_of_int 10001) " 10001");
  check "soi 16383" (String.equal (string_of_int 16383) " 16383");
  check "soi -1" (String.equal (string_of_int (-1)) "-1");
  check "soi -9" (String.equal (string_of_int (-9)) "-9");
  check "soi -10" (String.equal (string_of_int (-10)) "-10");
  check "soi -99" (String.equal (string_of_int (-99)) "-99");
  check "soi -100" (String.equal (string_of_int (-100)) "-100");
  check "soi -999" (String.equal (string_of_int (-999)) "-999");
  check "soi -1000" (String.equal (string_of_int (-1000)) "-1000");
  check "soi -9999" (String.equal (string_of_int (-9999)) "-9999");
  check "soi -10000" (String.equal (string_of_int (-10000)) "-10000");
  check "soi -16383" (String.equal (string_of_int (-16383)) "-16383");
  check "soi -16384" (String.equal (string_of_int (-16384)) "-16384");
  ()
let () =
  for i = 0 to 26 do run "len" (fun () -> test_len lens.(i)) done;
  run "make_err" test_make_err;
  List.iter (fun n -> run "pattern" (fun () -> test_pattern n)) [255; 256; 257; 300; 508; 509];
  run "pool" test_pool;
  run "soi" test_soi;
  finish "T04"
