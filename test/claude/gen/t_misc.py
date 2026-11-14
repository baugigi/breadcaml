from common import *

# ---------------------------------------------------------------------------
# T11: confronto polimorfico (caml_compare_val): tuple, liste, array, varianti...
# ---------------------------------------------------------------------------
def t11(parts, tag):
    o = [PRELUDE]
    o.append("""let sg n = if n < 0 then -1 else if n > 0 then 1 else 0
let ck s a b e =
  check (s ^ " compare") (sg (compare a b) = e);
  check (s ^ " =") ((a = b) = (e = 0));
  check (s ^ " <>") ((a <> b) = (e <> 0));
  check (s ^ " <") ((a < b) = (e < 0));
  check (s ^ " <=") ((a <= b) = (e <= 0));
  check (s ^ " >") ((a > b) = (e > 0));
  check (s ^ " >=") ((a >= b) = (e >= 0))
type v = A | B of int | C of int | D of int * int
type tree = Leaf | Node of tree * int * tree
let rec build d i = if d = 0 then Leaf
  else Node (build (d - 1) (2 * i), i, build (d - 1) (2 * i + 1))
let rec build2 d i = if d = 0 then Leaf
  else Node (build2 (d - 1) (2 * i), (if d = 1 && i = 33 then i + 1 else i), build2 (d - 1) (2 * i + 1))
let lst n k = let rec go i acc = if i < 0 then acc else go (i - 1) ((k + i) :: acc) in go (n - 1) []
let lstx n k pos =
  let rec go i acc = if i < 0 then acc
    else go (i - 1) ((if i = pos then k + i + 1 else k + i) :: acc) in go (n - 1) []
let arrx n k pos = Array.init n (fun i -> if i = pos then k + i + 1 else k + i)
let z = ref 0
""")
    b = ["let t_basic () ="]
    cases = [
        ('"int"', "3", "4", -1), ('"int="', "3", "3", 0), ('"int>"', "9", "(-9)", 1),
        ('"int ext"', "16383", "(-16384)", 1), ('"low-byte-equal"', "133", "5", 1),
        ('"low-byte-equal2"', "5", "133", -1), ('"low-byte-equal3"', "(-123)", "5", -1),
        ('"low-byte-equal4"', "261", "5", 1), ('"chr"', "'a'", "'b'", -1),
        ('"bool"', "false", "true", -1), ('"unit"', "()", "()", 0),
        ('"A<B"', "A", "(B !z)", -1), ('"B>A"', "(B 1)", "A", 1),
        ('"B<B"', "(B 1)", "(B (1 + !z))", 0), ('"B1<B2"', "(B 1)", "(B (2 + !z))", -1),
        ('"B<C tag"', "(B 5)", "(C !z)", -1), ('"D>C tag"', "(D (1, 2))", "(C 9)", 1),
        ('"D<D"', "(D (1, 2 + !z))", "(D (1, 3))", -1), ('"D=D"', "(D (1, 2 + !z))", "(D (1, 2))", 0),
        ('"None<Some"', "None", "(Some (1 + !z))", -1), ('"Some<Some"', "(Some 1)", "(Some (2 + !z))", -1),
        ('"Some str"', '(Some "a")', '(Some ("b" ^ ""))', -1),
        ('"ref"', "(ref 1)", "(ref (2 + !z))", -1), ('"ref="', "(ref (5 + !z))", "(ref 5)", 0),
        ('"str in tup"', '("a", 1)', '("a" ^ "", 2)', -1), ('"str in tup2"', '("ab", 1)', '("a" ^ "", 2)', 1),
        ('"flt in tup"', "(1.5, 2)", "(1.5 +. 0.0, 3)", -1), ('"flt in tup2"', "(1.5, 2)", "(2.5, 1)", -1),
        ('"flt in tup="', "(1.5 +. 0.0, 2)", "(1.5, 2)", 0),
        ('"nested"', '[(1, "a"); (2, "b")]', '[(1, "a"); (2, "c" ^ "")]', -1),
        ('"nested="', '[(1, "a"); (2, "b")]', '[(1, "a" ^ ""); (2, "b")]', 0),
        ('"str"', '"abc"', '("ab" ^ "d")', -1), ('"str 509"', "(String.make 509 'a')", "(String.make 509 'a')", 0),
    ]
    for nm, x, y, e in cases:
        b.append("  ck %s %s %s %s;" % (nm, x, y, oi(e)))
    b.append("  ()\n")
    if "basic" in parts: o.append("\n".join(b))
    # tuple: differenza in ogni posizione
    tl = []
    for k in [2, 3, 4, 5, 8]:
        if "tup" not in parts:
            break
        tup = lambda mod: "(" + ", ".join(
            ("x + %d" % (j + (1 if j == mod else 0))) for j in range(k)) + ")"
        o.append("let tp%d x = %s\n" % (k, tup(-1)))
        for pos in range(k):
            o.append("let tp%d_%d x = %s\n" % (k, pos, tup(pos)))
        c = ["let t_tup%d () =" % k, '  ck "tup%d eq" (tp%d 10) (tp%d 10) 0;' % (k, k, k)]
        for pos in range(k):
            c.append('  ck "tup%d lt@%d" (tp%d 10) (tp%d_%d 10) (-1);' % (k, pos, k, k, pos))
            c.append('  ck "tup%d gt@%d" (tp%d_%d 10) (tp%d 10) 1;' % (k, pos, k, pos, k))
        c.append("  ()\n")
        tl.append("\n".join(c))
    if "tup" in parts: o.extend(tl)
    # liste
    b = ["let t_list () ="]
    for n in [0, 1, 2, 3, 10, 100, 200]:
        b.append('  ck "list%d eq" (lst %d 1) (lst %d 1) 0;' % (n, n, n))
        b.append('  ck "list%d prefix" (lst %d 1) (lst %d 1) (-1);' % (n, n, n + 1))
        b.append('  ck "list%d prefix2" (lst %d 1) (lst %d 1) 1;' % (n, n + 1, n))
        if n > 0:
            b.append('  ck "list%d last" (lst %d 1) (lstx %d 1 %d) (-1);' % (n, n, n, n - 1))
            b.append('  ck "list%d first" (lstx %d 1 0) (lst %d 1) 1;' % (n, n, n))
    b.append("  ()\n")
    if "list" in parts: o.append("\n".join(b))
    # array
    b = ["let t_arr () ="]
    for n in [1, 2, 3, 126, 127, 128, 129, 254, 255]:
        b.append('  ck "arr%d eq" (arrx %d 1 (-1)) (arrx %d 1 (-1)) 0;' % (n, n, n))
        for pos in sorted({0, n // 2, n - 1}):
            b.append('  ck "arr%d lt@%d" (arrx %d 1 (-1)) (arrx %d 1 %d) (-1);' % (n, pos, n, n, pos))
            b.append('  ck "arr%d gt@%d" (arrx %d 1 %d) (arrx %d 1 (-1)) 1;' % (n, pos, n, n, pos))
        if n < 255:
            b.append('  ck "arr%d size" (arrx %d 1 (-1)) (arrx %d 1 (-1)) (-1);' % (n, n, n + 1))
    b.append('  ck "arr empty" ([||] : int array) [||] 0;')
    b.append("  ()\n")
    if "arr" in parts: o.append("\n".join(b))
    if "misc" in parts: o.append("""let t_tree () =
  ck "tree eq" (build 6 1) (build 6 1) 0;
  ck "tree lt" (build 6 1) (build2 6 1) (-1);
  ck "tree gt" (build2 6 1) (build 6 1) 1;
  ck "tree leaf" Leaf (build 1 1) (-1)
let t_fun () =
  raises_inv "compare fun" (fun () -> compare (fun x -> x + 1) (fun x -> x + 2));
  raises_inv "equal fun" (fun () -> (fun x -> x + 1) = (fun x -> x + 2))
let t_custom () =
  ck "i32 lt" (Int32.of_int (1 + !z)) (Int32.of_int 2) (-1);
  ck "i32 eq" (Int32.of_int (5 + !z)) (Int32.of_int 5) 0;
  ck "i32 gt" 2147483647l (-2147483648l) 1;
  ck "i32 neg" (-5l) 3l (-1);
  ck "i64 lt" (Int64.of_int (1 + !z)) (Int64.of_int 2) (-1);
  ck "i64 eq" (Int64.of_int (5 + !z)) (Int64.of_int 5) 0;
  ck "i64 big" 9223372036854775807L (-9223372036854775808L) 1;
  ck "i64 hi" 4294967296L 4294967295L 1;
  ck "i64 lo" 4294967295L 4294967296L (-1);
  ck "i32 in tuple" (1, Int32.of_int (2 + !z)) (1, Int32.of_int 3) (-1)
let t_farr () =
  ck "farr lt" [| 1.0; 2.0 |] [| 1.0; 3.0 |] (-1);
  ck "farr eq" [| 1.0; 2.0 |] [| 1.0; 2.0 |] 0;
  ck "farr size" [| 1.0 |] [| 1.0; 2.0 |] (-1);
  ck "farr gt" [| 1.0; 4.0; 0.5 |] [| 1.0; 3.0; 9.0 |] 1;
  ck "farr last" [| 1.0; 2.0; 3.0 |] [| 1.0; 2.0; 3.5 |] (-1);
  ck "farr neg" [| -1.0; 2.0 |] [| 1.0; 2.0 |] (-1);
  ck "farr empty" [||] [| 1.0 |] (-1);
  ck "farr in tuple" (1, [| 1.0; 2.0 |]) (1, [| 1.0; 2.5 |]) (-1)
exception E1 of int
exception E2 of int
let t_exn () =
  ck "exn eq" (E1 1) (E1 1) 0;
  ck "exn lt" (E1 1) (E1 2) (-1);
  ck "exn gt" (E1 (3 + !z)) (E1 2) 1;
  check "exn diff" (compare (E1 1) (E2 1) <> 0);
  check "exn antisym" (sg (compare (E1 1) (E2 1)) = - (sg (compare (E2 1) (E1 1))));
  ck "exn failure" (Failure "a") (Failure "b") (-1);
  ck "exn failure eq" (Failure "a") (Failure "a") 0
""")
    m = ["let () ="]
    if "basic" in parts: m.append('  run "basic" t_basic;')
    if "tup" in parts:
        for k in [2, 3, 4, 5, 8]:
            m.append('  run "t_tup%d" t_tup%d;' % (k, k))
    if "list" in parts: m.append('  run "list" t_list;')
    if "arr" in parts: m.append('  run "arr" t_arr;')
    if "misc" in parts:
        m += ['  run "tree" t_tree;', '  run "fun" t_fun;', '  run "custom" t_custom;', '  run "farr" t_farr;', '  run "exn" t_exn;']
    m.append('  finish "%s"' % tag)
    o.append("\n".join(m) + "\n")
    return "".join(o)


# ---------------------------------------------------------------------------
# T13: stress del GC con strutture miste vive durante molte collezioni
# ---------------------------------------------------------------------------
def t13():
    o = [PRELUDE]
    # albero completo, profondita' 8: nodi 255, somma 1..255 = 32640 -> -128 a 15 bit
    ts = w15(sum(range(1, 256)))
    ls = {n: w15(n * (n + 1) // 2) for n in [0, 1, 2, 127, 128, 255, 300]}
    o.append("""type tree = Leaf | Node of tree * int * tree
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
    checkn "tree sum " it (tsum t = %d);
    checkn "prev sum " it (tsum !prev = (if it = 1 then 0 else %d));
    prev := t
  done
let t_lists () =
  for it = 1 to 8 do
    List.iter (fun n ->
      let l = lst n [] in
      check2 "list len " it n (List.length l = n);
      check2 "list sum " it n (List.fold_left (+) 0 l = (match n with %s | _ -> 0));
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
""" % (ts, ts, " | ".join("%d -> %d" % (n, v) for n, v in ls.items())))
    return "".join(o)


# ---------------------------------------------------------------------------
# T14: moduli della stdlib ridotta (List, Array, Buffer, Map, Set, Queue, Stack, String)
# ---------------------------------------------------------------------------
def t14(parts, tag):
    o = [PRELUDE]
    scr = lambda n: (n * 37 + 11) % 211
    srt = sorted(scr(i) for i in range(200))
    srt255 = sorted(scr(i) for i in range(255))
    keys100 = [scr(i) for i in range(60)]
    srt100 = sorted(scr(i) for i in range(100))
    keys_after = w15(sum(keys100) - scr(17))
    txt = ("""let scr n = (n * 37 + 11) mod 211
let cmpi (a : int) b = compare a b
module IM = Map.Make (struct type t = int let compare (a : int) b = compare a b end)
module IS = Set.Make (struct type t = int let compare (a : int) b = compare a b end)
let t_list () =
  let l = List.init 200 scr in
  check "len" (List.length l = 200);
  check "nth" (List.nth l 199 = %d && List.nth l 0 = %d);
  let s = List.sort cmpi l in
  check "sort first/last" (List.hd s = %d && List.nth s 199 = %d && List.nth s 100 = %d);
  let rec sorted = function a :: (b :: _ as t) -> a <= b && sorted t | _ -> true in
  check "sorted" (sorted s);
  let s2 = List.stable_sort cmpi (List.rev l) in
  check "stable_sort" (s2 = s);
  check "rev" (List.rev (List.rev l) = l);
  check "map" (List.nth (List.map (fun x -> x + 1) l) 5 = %d);
  check "filter" (List.length (List.filter (fun x -> x mod 2 = 0) l) = %d);
  check "mem" (List.mem %d l && not (List.mem 1000 l));
  check "exists/for_all" (List.exists (fun x -> x = %d) l && List.for_all (fun x -> x >= 0) l);
  check "assoc" (List.assoc 3 [(1, 10); (3, 30)] = 30);
  (try ignore (List.nth l 200); fail "nth NOEXN" with Failure _ -> ());
  check "fold_right" (List.fold_right (fun x a -> x + a) [1; 2; 3] 0 = 6);
  check "concat" (List.length (List.concat [l; l]) = 400);
  check "sort_uniq" (List.length (List.sort_uniq cmpi (l @ l)) = 200);
  check "append" (List.length (l @ l) = 400)
let t_array () =
  let a = Array.init 255 scr in
  Array.sort cmpi a;
  check "asort" (a.(0) = %d && a.(254) = %d && a.(127) = %d);
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
let t_buffer () =
  let b = Buffer.create 16 in
  for i = 1 to 169 do Buffer.add_char b 'a'; Buffer.add_string b "bc" done;
  check "blen" (Buffer.length b = 507);
  let s = Buffer.contents b in
  check "bcontents" (String.length s = 507 && String.get s 0 = 'a' && String.get s 1 = 'b'
                     && String.get s 2 = 'c' && String.get s 504 = 'a' && String.get s 506 = 'c');
  Buffer.add_string b "xy";
  check "b509" (Buffer.length b = 509);
  (try Buffer.add_char b 'z'; fail "buffer overflow NOEXN" with Failure _ -> () | Invalid_argument _ -> ());
  Buffer.clear b;
  check "bclear" (Buffer.length b = 0)
let t_map () =
  let m = ref IM.empty in
  for i = 0 to 59 do m := IM.add (scr i) i !m done;
  check "card" (IM.cardinal !m = 60);
  check "find" (IM.find (scr 17) !m = 17 && IM.find (scr 59) !m = 59);
  check "mem" (IM.mem (scr 50) !m && not (IM.mem 1000 !m));
  (try ignore (IM.find 1000 !m); fail "find NOEXN" with Not_found -> ());
  m := IM.remove (scr 17) !m;
  check "removed" (not (IM.mem (scr 17) !m) && IM.cardinal !m = 59);
  check "fold" (IM.fold (fun k _ acc -> acc + k) !m 0 = %d)
let t_set () =
  let s = ref IS.empty in
  for i = 0 to 99 do s := IS.add (scr i) !s done;
  check "set card" (IS.cardinal !s = 100 && IS.mem (scr 7) !s && not (IS.mem 1000 !s));
  check "min/max" (IS.min_elt !s = %d && IS.max_elt !s = %d)
let t_qs () =
  let q = Queue.create () in
  for i = 0 to 254 do Queue.add i q done;
  check "qlen" (Queue.length q = 255);
  let ok = ref true in
  for i = 0 to 254 do if Queue.take q <> i then ok := false done;
  check "qfifo" (!ok && Queue.is_empty q);
  let s = Stack.create () in
  for i = 0 to 254 do Stack.push i s done;
  check "slen" (Stack.length s = 255);
  let ok2 = ref true in
  for i = 254 downto 0 do if Stack.pop s <> i then ok2 := false done;
  check "slifo" (!ok2 && Stack.is_empty s)
let t_string () =
  check "concat" (String.equal (String.concat ", " ["a"; "b"; "c"]) "a, b, c");
  check "index" (String.index "hello" 'l' = 2 && String.contains "hello" 'e');
  check "upper" (String.equal (String.uppercase_ascii "abc1") "ABC1");
  check "lower" (String.equal (String.lowercase_ascii "ABC1") "abc1");
  let p = String.split_on_char ',' "a,b,,c" in
  check "split" (List.length p = 4 && List.nth p 2 = "" && List.nth p 3 = "c");
  check "trim" (String.equal (String.trim "  x y  ") "x y");
  check "init" (String.equal (String.init 5 (fun i -> Char.chr (97 + i))) "abcde");
  check "map" (String.equal (String.map Char.uppercase_ascii "abc") "ABC");
  check "sub" (String.equal (String.sub "abcdef" 2 3) "cde");
  check "make 0" (String.length (String.make 0 'x') = 0);
  check "chars" (Char.code 'A' = 65 && Char.lowercase_ascii 'A' = 'a')
let () =
  run "list" t_list; run "array" t_array; run "buffer" t_buffer; run "map" t_map;
  run "queue/stack" t_qs; run "string" t_string;
  finish "T14"
""" % (scr(199), scr(0), srt[0], srt[199], srt[100], scr(5) + 1,
       sum(1 for i in range(200) if scr(i) % 2 == 0), scr(7), scr(13),
       srt255[0], srt255[254], srt255[127], keys_after, srt100[0], srt100[99]))
    import re as _re
    chunks = _re.split(r'(?m)^(?=let |module )', txt)
    keep = []
    for c in chunks:
        if not c.strip():
            continue
        if c.startswith("let () ="):
            continue
        if c.startswith("module IM"):
            if "map" in parts: keep.append(c)
        elif c.startswith("module IS"):
            if "set" in parts: keep.append(c)
        elif c.startswith("let t_"):
            nm = c.split()[1][2:]
            if nm in parts: keep.append(c)
        else:
            keep.append(c)
    o.append("".join(keep))
    run = {"list": "t_list", "array": "t_array", "buffer": "t_buffer", "map": "t_map", "set": "t_set",
           "qs": "t_qs", "string": "t_string"}
    m = ["let () ="]
    for p in ["list", "array", "buffer", "map", "set", "qs", "string"]:
        if p in parts:
            m.append('  run "%s" %s;' % (p, run[p]))
    m.append('  finish "%s"' % tag)
    o.append("\n".join(m) + "\n")
    return "".join(o)


# ---------------------------------------------------------------------------
# Sonde per primitive MANCANTI o dubbie: file separati, cosi' un errore di
# assemblaggio/link su una primitiva non maschera gli altri test.
# ---------------------------------------------------------------------------
def p90_array_fill():
    return PRELUDE + """let () =
  let a = Array.make 10 0 in
  Array.fill a 2 5 7;
  check "fill mid" (a.(1) = 0 && a.(2) = 7 && a.(6) = 7 && a.(7) = 0);
  let b = Array.make 255 1 in
  Array.fill b 0 255 9;
  let ok = ref true in
  for i = 0 to 254 do if b.(i) <> 9 then ok := false done;
  check "fill 255" !ok;
  Array.fill b 127 2 3;
  check "fill 127..128" (b.(126) = 9 && b.(127) = 3 && b.(128) = 3 && b.(129) = 9);
  Array.fill b 0 0 5;
  check "fill 0" (b.(0) = 9);
  let f = Array.make 40 1.5 in
  Array.fill f 3 30 2.5;
  check "fill float" (f.(2) = 1.5 && f.(3) = 2.5 && f.(32) = 2.5 && f.(33) = 1.5);
  raises_inv "fill bad" (fun () -> Array.fill b 200 100 0);
  finish "T90"
"""

def p91_hash():
    return PRELUDE + """let () =
  check "hash int" (Hashtbl.hash 5 = Hashtbl.hash 5);
  check "hash str" (Hashtbl.hash ("ab" ^ "c") = Hashtbl.hash "abc");
  check "hash tuple" (Hashtbl.hash (1, "x") = Hashtbl.hash (1, "x" ^ ""));
  check "hash range" (let h = Hashtbl.hash 12345 in h >= 0);
  let h = Hashtbl.create 16 in
  for i = 0 to 99 do Hashtbl.replace h i (i * 2) done;
  check "length" (Hashtbl.length h = 100);
  check "find" (Hashtbl.find h 57 = 114);
  Hashtbl.remove h 57;
  check "remove" (not (Hashtbl.mem h 57) && Hashtbl.length h = 99);
  let hs = Hashtbl.create 16 in
  Hashtbl.add hs "one" 1; Hashtbl.add hs ("tw" ^ "o") 2;
  check "str keys" (Hashtbl.find hs "two" = 2 && Hashtbl.find hs "one" = 1);
  raises_inv "dummy" (fun () -> invalid_arg "x");
  finish "T91"
"""

def p92_lazy():
    return PRELUDE + """let cnt = ref 0
let () =
  let l = lazy (incr cnt; 41 + 1) in
  check "lazy not forced" (!cnt = 0 && not (Lazy.is_val l));
  check "force" (Lazy.force l = 42);
  check "force twice" (Lazy.force l = 42 && !cnt = 1);
  check "is_val" (Lazy.is_val l);
  let v = Lazy.from_val 7 in
  check "from_val" (Lazy.force v = 7 && Lazy.is_val v);
  let m = lazy (Lazy.force l + 1) in
  check "nested" (Lazy.force m = 43);
  let e = lazy (raise Not_found) in
  (try ignore (Lazy.force e); fail "lazy exn NOEXN" with Not_found -> ());
  (try ignore (Lazy.force e); fail "lazy exn2 NOEXN" with _ -> ());
  finish "T92"
"""

def p93_hashtbl_make():
    return PRELUDE + """module H = Hashtbl.Make (struct
  type t = int
  let equal (a : int) b = a = b
  let hash (x : int) = x land 255
end)
let () =
  let h = H.create 16 in
  for i = 0 to 199 do H.replace h i (i + 1) done;
  check "length" (H.length h = 200);
  check "find" (H.find h 150 = 151 && H.find h 0 = 1 && H.find h 199 = 200);
  H.remove h 150;
  check "remove" (not (H.mem h 150) && H.length h = 199);
  H.replace h 3 99;
  check "replace" (H.find h 3 = 99 && H.length h = 199);
  (try ignore (H.find h 1000); fail "find NOEXN" with Not_found -> ());
  let s = ref 0 in
  H.iter (fun k v -> s := (!s + k + v) land 16383) h;
  check "iter" (!s >= 0);
  finish "T93"
"""

def p94_floatarray():
    return PRELUDE + """let () =
  let a = Float.Array.create 10 in
  Float.Array.fill a 0 10 1.5;
  check "fill" (Float.Array.get a 0 = 1.5 && Float.Array.get a 9 = 1.5);
  Float.Array.set a 3 2.5;
  check "set" (Float.Array.get a 3 = 2.5 && Float.Array.length a = 10);
  let b = Float.Array.make 85 0.5 in
  check "make 85" (Float.Array.length b = 85 && Float.Array.get b 84 = 0.5);
  Float.Array.blit a 0 b 80 5;
  check "blit" (Float.Array.get b 80 = 1.5 && Float.Array.get b 83 = 2.5 && Float.Array.get b 79 = 0.5);
  let c = Float.Array.append a a in
  check "append" (Float.Array.length c = 20 && Float.Array.get c 13 = 2.5);
  let d = Float.Array.sub b 80 5 in
  check "sub" (Float.Array.length d = 5 && Float.Array.get d 3 = 2.5);
  let e = Float.Array.copy a in
  Float.Array.set e 0 9.0;
  check "copy" (Float.Array.get a 0 = 1.5);
  raises_inv "oob" (fun () -> Float.Array.get b 85);
  finish "T94"
"""

def p95_obj():
    return PRELUDE + """let () =
  check "tag int" (Obj.tag (Obj.repr 5) = Obj.int_tag);
  check "tag string" (Obj.tag (Obj.repr ("a" ^ "b")) = Obj.string_tag);
  check "tag double" (Obj.tag (Obj.repr (1.5 +. 0.0)) = Obj.double_tag);
  check "tag closure" (Obj.tag (Obj.repr (fun x -> x + 1)) = Obj.closure_tag);
  check "tag farray" (Obj.tag (Obj.repr (Array.make 3 1.5)) = Obj.double_array_tag);
  check "tag tuple" (Obj.tag (Obj.repr (ref 0)) = 0);
  List.iter (fun n ->
    let b = Obj.new_block 0 n in
    check2 "new_block size " n 0 (Obj.size b = n);
    let ok = ref true in
    for i = 0 to n - 1 do if not (Obj.field b i == Obj.repr 0) then ok := false done;
    check2 "new_block init " n 0 !ok) [1; 2; 3; 126; 127; 128; 129; 254; 255];
  List.iter (fun n ->
    let b = Obj.new_block 0 n in
    for i = 0 to n - 1 do Obj.set_field b i (Obj.repr (i + 1)) done;
    let d = Obj.dup b in
    check2 "dup size " n 0 (Obj.size d = n && not (d == b));
    let ok = ref true in
    for i = 0 to n - 1 do if not (Obj.field d i == Obj.repr (i + 1)) then ok := false done;
    check2 "dup fields " n 0 !ok;
    Obj.set_field d 0 (Obj.repr 99);
    check2 "dup indep " n 0 (Obj.field b 0 == Obj.repr 1)) [1; 2; 127; 128; 255];
  let b = Obj.new_block 7 3 in
  check "tag 7" (Obj.tag b = 7 && Obj.size b = 3);
  Obj.set_tag b 9;
  check "set_tag" (Obj.tag b = 9);
  check "is_block/is_int" (Obj.is_block (Obj.repr "x") && Obj.is_int (Obj.repr 3));
  finish "T95"
"""
