from common import *

# Programmi diagnostici: stampano "nome got=X exp=Y" solo per i valori sbagliati,
# cosi' si vede COSA restituisce il runtime (e non solo che il test e' fallito).
DG = r'''let dg s got exp =
  if got <> exp then begin
    incr fails; print_string s; print_string " got="; print_int got;
    print_string " exp="; print_int exp; print_newline ()
  end
let dgb s b = dg s (if b then 1 else 0) 1
let ex s f = try f () with _ -> dg (s ^ " exn") 1 0
'''

def d_cmp():
    o = [PRELUDE, DG]
    o.append('''type v = A | B of int | D of int * int
let z = ref 0
let sgn c = if c < 0 then -1 else if c > 0 then 1 else 0
let ci (a : int) (b : int) = sgn (compare a b)
let pc a b = sgn (compare a b)
let () =
  let pairs = [| (3, 4, -1); (3, 3, 0); (4, 3, 1); (9, -9, 1); (-9, 9, -1);
                 (16383, -16384, 1); (-16384, 16383, -1); (133, 5, 1); (5, 133, -1);
                 (-123, 5, -1); (261, 5, 1); (0, 0, 0) |] in
  for i = 0 to Array.length pairs - 1 do
    let (a, b, e) = pairs.(i) in
    dg ("ci " ^ string_of_int a ^ "," ^ string_of_int b) (ci a b) e;
    dg ("pc " ^ string_of_int a ^ "," ^ string_of_int b) (pc a b) e
  done;
  ex "c0" (fun () -> dg "float lt" (pc 1.5 2.5) (-1));
  ex "c1" (fun () -> dg "float eq" (pc 1.5 1.5) 0);
  ex "c2" (fun () -> dg "string lt" (pc "a" "b") (-1));
  ex "c3" (fun () -> dg "string eq" (pc "ab" ("a" ^ "b")) 0);
  ex "c4" (fun () -> dg "tup lt" (pc (1, 2) (1, 3 + !z)) (-1));
  ex "c5" (fun () -> dg "tup eq" (pc (1, 2) (1, 2 + !z)) 0);
  ex "c6" (fun () -> dg "tup gt" (pc (1, 3) (1, 2 + !z)) 1);
  ex "c7" (fun () -> dg "tup lt@0" (pc (1, 2) (2 + !z, 2)) (-1));
  ex "c8" (fun () -> dgb "tup =" ((1, 2) = (1, 2 + !z)));
  ex "c9" (fun () -> dgb "tup <>" ((1, 2) <> (1, 3 + !z)));
  ex "c10" (fun () -> dg "list lt" (pc [1; 2] [1; 3 + !z]) (-1));
  ex "c11" (fun () -> dg "list eq" (pc [1; 2] [1; 2 + !z]) 0);
  ex "c12" (fun () -> dg "some lt" (pc (Some 1) (Some (2 + !z))) (-1));
  ex "c13" (fun () -> dg "B lt" (pc (B 1) (B (2 + !z))) (-1));
  ex "c14" (fun () -> dg "D lt" (pc (D (1, 2)) (D (1, 3 + !z))) (-1));
  ex "c15" (fun () -> dg "D eq" (pc (D (1, 2)) (D (1, 2 + !z))) 0);
  ex "c16" (fun () -> dg "arr lt" (pc [|1; 2|] [|1; 3 + !z|]) (-1));
  finish "d_cmp"
''')
    return "".join(o)

def d_cmp2():
    # Compare: differenze > 127 (tag, size blocchi, size stringhe) e contatore campi (.next_item)
    n = 230
    ctors = " | ".join("C%d of int" % i for i in range(n))
    o = [PRELUDE, DG]
    o.append("type big = " + ctors + r'''
let z = ref 0
let sgn c = if c < 0 then -1 else if c > 0 then 1 else 0
let pc a b = sgn (compare a b)
let () =
  ex "t0" (fun () -> dg "tag 229>0" (pc (C229 (1 + !z)) (C0 1)) 1);
  ex "t1" (fun () -> dg "tag 0<229" (pc (C0 1) (C229 (1 + !z))) (-1));
  ex "t2" (fun () -> dg "tag 130>0" (pc (C130 1) (C0 (1 + !z))) 1);
  ex "t3" (fun () -> dg "tag 0<130" (pc (C0 (1 + !z)) (C130 1)) (-1));
  ex "t4" (fun () -> dg "tag 129>2" (pc (C129 (1 + !z)) (C2 1)) 1);
  ex "t5" (fun () -> dg "tag 127>0" (pc (C127 (1 + !z)) (C0 1)) 1);
  ex "t6" (fun () -> dgb "tag <" (C0 1 < C229 (1 + !z)));
  ex "t7" (fun () -> dgb "tag >" (C229 1 > C0 (1 + !z)));
  let a200 = Array.make 200 0 and a10 = Array.make 10 0 in
  let a129 = Array.make 129 5 and a1 = Array.make 1 5 in
  ex "s0" (fun () -> dg "arr 200>10" (pc a200 a10) 1);
  ex "s1" (fun () -> dg "arr 10<200" (pc a10 a200) (-1));
  ex "s2" (fun () -> dg "arr 129>1" (pc a129 a1) 1);
  ex "s3" (fun () -> dg "arr 1<129" (pc a1 a129) (-1));
  ex "s4" (fun () -> dg "arr 200=200" (pc a200 (Array.make 200 0)) 0);
  ex "s5" (fun () -> dgb "arr <" (a10 < a200));
  let s300 = String.make 300 'a' and s10 = String.make 10 'a' in
  ex "r0" (fun () -> dg "str 300>10" (pc s300 s10) 1);
  ex "r1" (fun () -> dg "str 10<300" (pc s10 s300) (-1));
  ex "r2" (fun () -> dg "str 300=300" (pc s300 (String.make 300 'a')) 0);
  ex "r3" (fun () -> dgb "str <" (s10 < s300));
  ex "r4" (fun () -> dgb "str >" (s300 > s10));
  ex "n0" (fun () -> dg "t5 eq" (pc (1, 2, 3, 4, 5) (1, 2, 3, 4, 5 + !z)) 0);
  ex "n1" (fun () -> dg "t5 last" (pc (1, 2, 3, 4, 5) (1, 2, 3, 4, 6 + !z)) (-1));
  ex "n2" (fun () -> dg "t5 4th" (pc (1, 2, 3, 5, 5) (1, 2, 3, 4 + !z, 9)) 1);
  ex "n3" (fun () -> dg "t5 3rd" (pc (1, 2, 3, 9, 9) (1, 2, 4 + !z, 0, 0)) (-1));
  ex "n4" (fun () -> dg "t5 2nd" (pc (1, 3, 0, 0, 0) (1, 2 + !z, 9, 9, 9)) 1);
  ex "n5" (fun () -> dg "t5 1st" (pc (0, 9, 9, 9, 9) (1 + !z, 0, 0, 0, 0)) (-1));
  ex "n6" (fun () -> dg "t3 last" (pc (1, 2, 3) (1, 2, 4 + !z)) (-1));
  ex "n7" (fun () -> dg "t3 mid" (pc (1, 3, 0) (1, 2 + !z, 9)) 1);
  ex "n8" (fun () -> dg "t4 eq" (pc (1, 2, 3, 4) (1, 2, 3, 4 + !z)) 0);
  ex "na" (fun () -> dg "arr4 last" (pc [|1; 2; 3; 4|] [|1; 2; 3; 5 + !z|]) (-1));
  ex "nb" (fun () -> dg "arr4 eq" (pc [|1; 2; 3; 4|] [|1; 2; 3; 4 + !z|]) 0);
  ex "nc" (fun () -> dg "list last" (pc [1; 2; 3; 4] [1; 2; 3; 5 + !z]) (-1));
  ex "nd" (fun () -> dg "list prefix" (pc [1; 2; 3] [1; 2; 3; 4 + !z]) (-1));
  ex "m0" (fun () -> dg "nest eq" (pc ((1, 2, 3), (4, 5, 6)) ((1, 2, 3), (4, 5, 6 + !z))) 0);
  ex "m1" (fun () -> dg "nest lt" (pc ((1, 2, 3), (4, 5, 6)) ((1, 2, 3), (4, 5, 7 + !z))) (-1));
  ex "m2" (fun () -> dg "nest gt" (pc ((1, 2, 3), (4, 5, 6), 7) ((1, 2, 3), (4, 5, 6), 6 + !z)) 1);
  ex "m3" (fun () -> dg "nest in" (pc ((1, 2, 3), 9, 9) ((1, 2, 4 + !z), 0, 0)) (-1));
  ex "m4" (fun () -> dg "list of tup" (pc [(1, 2, 3); (4, 5, 6)] [(1, 2, 3); (4, 5, 7 + !z)]) (-1));
  finish "d_cmp2"
''')
    return "".join(o)

def d_float():
    o = [PRELUDE, DG]
    o.append('''let () =
  let sizes = [| 1; 2; 3; 10; 84; 85 |] in
  for k = 0 to Array.length sizes - 1 do
    let n = sizes.(k) in
    let nm s = s ^ " n=" ^ string_of_int n in
    ex (nm "make") (fun () ->
      let a = Array.make n 1.5 in
      dg (nm "length") (Array.length a) n;
      dg (nm "get0") (int_of_float (a.(0) *. 2.0)) 3;
      dg (nm "getlast") (int_of_float (a.(n - 1) *. 2.0)) 3;
      (try ignore a.(n); dg (nm "oob get NOEXN") 0 1
       with Invalid_argument _ -> () | _ -> dg (nm "oob get other exn") 1 0);
      (try a.(n) <- 1.0; dg (nm "oob set NOEXN") 0 1
       with Invalid_argument _ -> () | _ -> dg (nm "oob set other exn") 1 0);
      a.(n - 1) <- 2.5;
      dg (nm "set last") (int_of_float (a.(n - 1) *. 2.0)) 5);
    ex (nm "init") (fun () ->
      let b = Array.init n (fun i -> float_of_int i) in
      dg (nm "init len") (Array.length b) n;
      dg (nm "init last") (int_of_float b.(n - 1)) (n - 1);
      dg (nm "init first") (int_of_float b.(0)) 0);
    ex (nm "sub") (fun () ->
      let b = Array.init n (fun i -> float_of_int i) in
      let s = Array.sub b 0 1 in
      dg (nm "sub len") (Array.length s) 1;
      dg (nm "sub 0") (int_of_float s.(0)) 0;
      let c = Array.append (Array.sub b 0 1) (Array.sub b 0 1) in
      dg (nm "append len") (Array.length c) 2)
  done;
  ex "lit1" (fun () -> let x = [| 1.5 |] in
    dg "lit1 len" (Array.length x) 1; dg "lit1 val" (int_of_float (x.(0) *. 2.0)) 3);
  ex "lit2" (fun () -> let x = [| 1.5; 2.5 |] in
    dg "lit2 len" (Array.length x) 2; dg "lit2 v0" (int_of_float (x.(0) *. 2.0)) 3;
    dg "lit2 v1" (int_of_float (x.(1) *. 2.0)) 5);
  ex "lit3" (fun () -> let x = [| 1.5; 2.5; 3.5 |] in
    dg "lit3 v0" (int_of_float (x.(0) *. 2.0)) 3; dg "lit3 v2" (int_of_float (x.(2) *. 2.0)) 7);
  finish "d_float"
''')
    return "".join(o)

def d_gc():
    total = 0
    for i in range(1, 151):
        total = (total + 328 + i) & 0x3FFF
    o = [PRELUDE, DG]
    o.append('''let comp i =
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
  dg "total (land)" !t2 %d;
  dg "total (components)" !t %d;
  finish "d_gc"
''' % (total, total))
    return "".join(o)

def d_blit():
    o = [PRELUDE, DG]
    o.append('''let ident n = Array.init n (fun i -> i)
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
''')
    return "".join(o)

def d_atoms():
    o = [PRELUDE, DG]
    o.append('''let () =
  let a = Array.make 0 1 in
  let b = Array.sub [|1; 2|] 1 0 in
  let c = Array.concat ([] : int array list) in
  let d = Array.append ([||] : int array) [||] in
  let e = Array.init 0 (fun i -> i) in
  let f = Array.copy ([||] : int array) in
  let l = ([||] : int array) in
  dg "len a" (Array.length a) 0;  dg "len b" (Array.length b) 0;
  dg "len c" (Array.length c) 0;  dg "len d" (Array.length d) 0;
  dg "len e" (Array.length e) 0;  dg "len f" (Array.length f) 0;
  dgb "a==b" (a == b); dgb "a==c" (a == c); dgb "a==d" (a == d);
  dgb "a==e" (a == e); dgb "a==f" (a == f); dgb "a==literal" (a == l);
  dg "Obj.size a" (Obj.size (Obj.repr a)) 0;
    dgb "new_block 0 0 == a" (Obj.new_block 0 0 == Obj.repr a);
  ex "blit n=0 same" (fun () -> Array.blit a 0 a 0 0);
  ex "blit n=0 other" (fun () -> let x = Array.make 3 0 in Array.blit a 0 x 0 0;
                         dg "x.(0) after blit 0" x.(0) 0; dg "x.(2) after blit 0" x.(2) 0);
  let keep = (a, [|b|]) in
  for i = 1 to 120 do
    ignore (String.make 200 'x'); ignore (Array.make 100 i); ignore (Array.make 255 [i])
  done;
  let (a1, ba) = keep in
  dgb "after gc a1==a" (a1 == a);
  dgb "after gc ba.(0)==a" (Array.length ba.(0) = 0 && ba.(0) == a);
  finish "d_atoms"
''')
    return "".join(o)


def d_make():
    o = [PRELUDE, DG]
    o.append('''let rep nm n got =
  let first = ref (-1) and cnt = ref 0 in
  for i = n - 1 downto 0 do if not (got i) then (first := i; incr cnt) done;
  dg (nm ^ " bad count n=" ^ string_of_int n) !cnt 0;
  if !cnt > 0 then dg (nm ^ " first bad idx n=" ^ string_of_int n) !first (-1)
let () =
  let sizes = [| 1; 2; 3; 4; 10; 120; 127; 128; 255 |] in
  let v = ref 9 in
  for k = 0 to Array.length sizes - 1 do
    let n = sizes.(k) in
    ex "int const" (fun () -> let a = Array.make n 7 in rep "int const 7" n (fun i -> a.(i) = 7));
    ex "int zero" (fun () -> let a = Array.make n 0 in rep "int zero" n (fun i -> a.(i) = 0));
    ex "int var" (fun () -> let a = Array.make n !v in rep "int var 9" n (fun i -> a.(i) = 9));
    ex "int neg" (fun () -> let a = Array.make n (-3) in rep "int neg" n (fun i -> a.(i) = (-3)))
  done;
  let fz = [| 1; 2; 3; 4; 10; 84; 85 |] in
  for k = 0 to Array.length fz - 1 do
    let n = fz.(k) in
    ex "float const" (fun () -> let a = Array.make n 1.5 in rep "float const" n (fun i -> a.(i) = 1.5));
    ex "float zero" (fun () -> let a = Array.make n 0.0 in rep "float zero" n (fun i -> a.(i) = 0.0))
  done;
  ex "make tuple" (fun () ->
    let t = (1, 2) in let a = Array.make 5 t in
    rep "tuple" 5 (fun i -> a.(i) == t));
  ex "make str" (fun () ->
    let t = "ab" in let a = Array.make 5 t in
    rep "string" 5 (fun i -> a.(i) == t));
  finish "d_make"
''')
    return "".join(o)
