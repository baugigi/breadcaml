from common import *

# ---------------------------------------------------------------------------
# T01: blocchi di size 1..10, 126..129, 254, 255 (record, varianti, tuple)
#      MAKEBLOCK n t (n>3 usa caml_MKBLKN: ordine size/tag), GETFIELD/SETFIELD n
# ---------------------------------------------------------------------------
def t01(sizes, tag, tags=False):
    o = [PRELUDE]
    A = 5
    for n in sizes:
        o.append("type r%d = { %s }\n" % (
            n, "; ".join("mutable x%d_%d: int" % (n, i) for i in range(n))))
        o.append("let mk%d a = { %s }\n" % (
            n, "; ".join("x%d_%d = a + %d" % (n, i, i % 16) for i in range(n))))
        o.append("let sum%d r = %s\n" % (
            n, " + ".join("r.x%d_%d" % (n, i) for i in range(n))))
        idx = sample(n)
        vals = [A + i % 16 for i in range(n)]
        s0 = sum(vals)
        newv = {i: 100 + i % 7 for i in idx}
        s1 = s0 - sum(vals[i] for i in idx) + sum(newv.values())
        assert abs(s0) < 16000 and abs(s1) < 16000
        b = ["let t%d () =" % n, "  let r = mk%d %d in" % (n, A),
             '  check "r%d size" (Obj.size (Obj.repr r) = %d);' % (n, n),
             '  check "r%d tag" (Obj.tag (Obj.repr r) = 0);' % n,
             '  check "r%d sum0" (sum%d r = %d);' % (n, n, s0)]
        for i in idx:
            b.append('  check "r%d.x%d" (r.x%d_%d = %d);' % (n, i, n, i, vals[i]))
        for i in idx:
            b.append("  r.x%d_%d <- %d;" % (n, i, newv[i]))
        b.append('  check "r%d sum1" (sum%d r = %d);' % (n, n, s1))
        for i in idx:
            b.append('  check "r%d.x%d b" (r.x%d_%d = %d)%s' % (
                n, i, n, i, newv[i], ";" if i != idx[-1] else ""))
        o.append("\n".join(b) + "\n")

    if tags:
        # varianti: tag != size, size > 3  (cattura MAKEBLOCK t s con t,s scambiati)
        ar = [4, 5, 4, 7, 5, 4, 6, 8, 4, 12]
        o.append("type tv =\n" + "\n".join(
            "  | K%d of %s" % (t, " * ".join(["int"] * a)) for t, a in enumerate(ar)) + "\n")
        o.append("let mkv t a = match t with\n" + "\n".join(
            "  | %d -> K%d (%s)" % (t, t, ", ".join("a + %d" % j for j in range(a)))
            for t, a in enumerate(ar)) + "\n  | _ -> K0 (a, a, a, a)\n")
        o.append("let which v = match v with\n" + "\n".join(
            "  | K%d _ -> %d" % (t, t) for t in range(len(ar))) + "\n")
        o.append("let vsum v = match v with\n" + "\n".join(
            "  | K%d (%s) -> %s" % (t, ",".join("p%d" % j for j in range(a)),
                                    " + ".join("p%d" % j for j in range(a)))
            for t, a in enumerate(ar)) + "\n")
        b = ["let tv () =", "  for t = 0 to %d do" % (len(ar) - 1), "    let v = mkv t 10 in"]
        b.append('    checkn "variant which " t (which v = t);')
        b.append('    checkn "variant tag " t (Obj.tag (Obj.repr v) = t);')
        b.append("    checkn \"variant size \" t (Obj.size (Obj.repr v) = (match t with %s | _ -> 0));" % " | ".join(
            "%d -> %d" % (t, a) for t, a in enumerate(ar)))
        b.append("    checkn \"variant sum \" t (vsum v = (match t with %s | _ -> 0))" % " | ".join(
            "%d -> %d" % (t, 10 * a + a * (a - 1) // 2) for t, a in enumerate(ar)))
        b.append("  done\n")
        o.append("\n".join(b))

        # tuple
        tl = []
        for k in [4, 5, 8, 20]:
            o.append("let tup%d a = (%s)\n" % (k, ", ".join("a + %d" % j for j in range(k))))
            tl.append("let tt%d () =\n  let (%s) = tup%d 3 in\n  check \"tuple%d\" (%s)\n" % (
                k, ", ".join("p%d" % j for j in range(k)), k, k,
                " && ".join("p%d = %d" % (j, 3 + j) for j in range(k))))
        o.extend(tl)
    m = ["let () ="]
    for n in sizes:
        m.append('  run "r%d" t%d;' % (n, n))
    if tags:
        m.append('  run "variants" tv;')
        for k in [4, 5, 8, 20]:
            m.append('  run "tuple%d" tt%d;' % (k, k))
    m.append('  finish "%s"' % tag)
    o.append("\n".join(m) + "\n")
    return "".join(o)


# ---------------------------------------------------------------------------
# T01F: record e array "piatti" di soli float (MAKEFLOATBLOCK, GETFLOATFIELD n,
#       SETFLOATFIELD n) fino a 85 campi = 255 parole; letture ripetute che
#       allocano un float a ogni accesso (GC dentro GETFLOATFIELD)
# ---------------------------------------------------------------------------
def t01f(sizes, tag):
    o = [PRELUDE]
    A = 2.0
    for n in sizes:
        vals = [A + i % 16 for i in range(n)]
        s0 = sum(vals)
        idx = sample(n)
        newv = {i: 100.5 + i % 7 for i in idx}
        s1 = s0 - sum(vals[i] for i in idx) + sum(newv.values())
        o.append("type f%d = { %s }\n" % (n, "; ".join("mutable y%d_%d: float" % (n, i) for i in range(n))))
        o.append("let mk%d a = { %s }\n" % (n, "; ".join("y%d_%d = a +. %d.0" % (n, i, i % 16) for i in range(n))))
        o.append("let sum%d r = %s\n" % (n, " +. ".join("r.y%d_%d" % (n, i) for i in range(n))))
        o.append("let mka%d a = [| %s |]\n" % (n, "; ".join("a +. %d.0" % (i % 16) for i in range(n))))
        o.append("let suma%d x = %s\n" % (n, " +. ".join("x.(%d)" % i for i in range(n))))
        b = ["let t%d () =" % n, "  let r = mk%d %r in" % (n, A),
             '  check "f%d sum0" (sum%d r = %r);' % (n, n, s0)]
        for i in idx:
            b.append('  check "f%d.y%d" (r.y%d_%d = %r);' % (n, i, n, i, vals[i]))
        for i in idx:
            b.append("  r.y%d_%d <- %r;" % (n, i, newv[i]))
        b.append('  check "f%d sum1" (sum%d r = %r);' % (n, n, s1))
        for i in idx:
            b.append('  check "f%d.y%d b" (r.y%d_%d = %r);' % (n, i, n, i, newv[i]))
        b.append('  for it = 1 to 40 do checkn "f%d sum loop " it (sum%d r = %r) done;' % (n, n, s1))
        b.append("  let x = mka%d %r in" % (n, A))
        b.append('  check "arrlit len %d" (Array.length x = %d);' % (n, n))
        b.append('  check "arrlit sum0 %d" (suma%d x = %r);' % (n, n, s0))
        for i in idx:
            b.append('  x.(%d) <- %r;' % (i, newv[i]))
        b.append('  check "arrlit sum1 %d" (suma%d x = %r);' % (n, n, s1))
        b.append('  for it = 1 to 40 do checkn "arrlit loop " it (suma%d x = %r) done' % (n, s1))
        o.append("\n".join(b) + "\n")
    m = ["let () ="]
    for n in sizes:
        m.append('  run "f%d" t%d;' % (n, n))
    m.append('  finish "%s"' % tag)
    o.append("\n".join(m) + "\n")
    return "".join(o)


# ---------------------------------------------------------------------------
# T02: blocchi grandi (array di 127/128/255 puntatori) che sopravvivono a molti GC;
#      sharing fisico preservato; set di blocchi live; garbage di blocchi da 255 parole
# ---------------------------------------------------------------------------
def t02():
    o = [PRELUDE]
    N = 150
    def esum(n, a):
        return sum(i % 16 + a for i in range(n))
    e127, e128, e255 = esum(127, 1) + 127 * 1, esum(128, 2) + 128 * 2, esum(255, 3) + 255 * 3
    # sumarr somma p + q con p = i mod 16 e q = a: quindi n*a + sum(i mod 16) + ... gia' incluso
    e127 = sum(i % 16 for i in range(127)) + 127 * 1
    e128 = sum(i % 16 for i in range(128)) + 128 * 2
    e255 = sum(i % 16 for i in range(255)) + 255 * 3
    for v in (e127, e128, e255):
        assert v < 16000
    total = 0
    for i in range(1, N + 1):
        total = (total + 328 + i) & 0x3FFF
    o.append("""let mkarr n a = Array.init n (fun i -> (i mod 16, a))
let sumarr arr =
  let s = ref 0 in
  for i = 0 to Array.length arr - 1 do
    let (p, q) = arr.(i) in
    s := !s + p + q
  done;
  !s
let b127 = mkarr 127 1
let b128 = mkarr 128 2
let b255 = mkarr 255 3
let shared = let t = (7, 8) in Array.make 255 t
let intarr = Array.init 255 (fun i -> i * 3)
let live = Array.make 40 (0, 0)
let total = ref 0
let garbage i =
  let s = String.make 200 'g' in
  let a = Array.make 120 i in
  let l = [i; i + 1; i + 2; i + 3; i + 4; i + 5; i + 6; i + 7] in
  let r = Array.make 255 i in
  String.length s + Array.length a + List.length l + r.(0)
let verify tag =
  checkn "b127 " tag (Array.length b127 = 127 && sumarr b127 = %d);
  checkn "b128 " tag (Array.length b128 = 128 && sumarr b128 = %d);
  checkn "b255 " tag (Array.length b255 = 255 && sumarr b255 = %d);
  checkn "shared " tag (shared.(0) == shared.(254) && shared.(127) == shared.(128)
                        && fst shared.(0) = 7 && snd shared.(254) = 8);
  checkn "intarr " tag (intarr.(0) = 0 && intarr.(127) = 381 && intarr.(128) = 384
                        && intarr.(254) = 762);
  checkn "not shared " tag (not (b127.(0) == b127.(16)))
let verify_live () =
  let ok = ref true in
  for j = 0 to 39 do
    let (p, q) = live.(j) in
    let e = %d - ((%d - j) mod 40 + 40) mod 40 in
    if not (p = e && q = e + 1) then ok := false
  done;
  check "live" !ok
let t () =
  for i = 1 to %d do
    total := (!total + garbage i) land 16383;
    live.(i mod 40) <- (i, i + 1);
    if i mod 10 = 0 then verify i
  done;
  check "total" (!total = %d);
  verify_live ()
let () =
  run "gc-big" t;
  finish "T02"
""" % (e127, e128, e255, N, N, N, total))
    return "".join(o)


# ---------------------------------------------------------------------------
# T03: array: make/get/set ai bordi, sub/append/concat/blit, float array,
#      stress ripetuto per far scattare il GC dentro le primitive
# ---------------------------------------------------------------------------
def t03(sections, tag):
    o = [PRELUDE]
    def add(sec, text):
        if sec in sections:
            o.append(text)
    sizes = [0, 1, 2, 3, 126, 127, 128, 129, 253, 254, 255]
    probes = [0, 1, 2, 126, 127, 128, 129, 253, 254, 255, 256]
    add("int", "let sizes = %s\nlet probes = %s\n" % (
        arr(map(str, sizes)), arr(map(str, probes))))
    add("int", """let pget a i = a.(i)
let pset a i v = a.(i) <- v
let test_size n =
  let a = Array.make n 7 in
  checkn "make len " n (Array.length a = n);
  (let bad = ref (-1) in
   for i = n - 1 downto 0 do if a.(i) <> 7 then bad := i done;
   check2 "make fill " n !bad (!bad < 0));
  for i = 0 to n - 1 do a.(i) <- i * 3 + 1 done;
  let ok = ref true in
  for i = 0 to n - 1 do if a.(i) <> i * 3 + 1 then ok := false done;
  checkn "get/set " n !ok;
  for k = 0 to %d do
    let p = probes.(k) in
    if p < n then begin
      check2 "probe " n p (a.(p) = p * 3 + 1);
      check2 "pget " n p (pget a p = p * 3 + 1);
      pset a p (p + 5);
      check2 "pset " n p (a.(p) = p + 5);
      a.(p) <- p * 3 + 1
    end else begin
      raises_inv "get oob" (fun () -> a.(p));
      raises_inv "set oob" (fun () -> a.(p) <- 1);
      raises_inv "pget oob" (fun () -> pget a p);
      raises_inv "pset oob" (fun () -> pset a p 1)
    end
  done;
  raises_inv "get -1" (fun () -> a.(-1));
  raises_inv "set -1" (fun () -> a.(-1) <- 1);
  let b = Array.init n (fun i -> i * 3 + 1) in
  let c = Array.copy a in
  let ok2 = ref (Array.length b = n && Array.length c = n) in
  for i = 0 to n - 1 do
    if b.(i) <> i * 3 + 1 || c.(i) <> i * 3 + 1 then ok2 := false
  done;
  checkn "init/copy " n !ok2;
  if n > 0 then begin
    c.(n - 1) <- 99;
    checkn "copy independent " n (a.(n - 1) = (n - 1) * 3 + 1)
  end
""" % (len(probes) - 1))
    add("int", """let test_make_err () =
  raises_inv "make 256" (fun () -> Array.make 256 0);
  raises_inv "make 300" (fun () -> Array.make 300 0);
  raises_inv "make -1" (fun () -> Array.make (-1) 0);
  raises_inv "make 256 blk" (fun () -> Array.make 256 [1]);
  raises_inv "make 86 f" (fun () -> Array.make 86 1.5);
  raises_inv "make 128 f" (fun () -> Array.make 128 1.5);
  raises_inv "make 255 f" (fun () -> Array.make 255 1.5)
let test_make_blk () =
  let l = [1; 2; 3] in
  for it = 1 to 40 do
    let a = Array.make 255 l in
    checkn "make blk len " it (Array.length a = 255);
    checkn "make blk elt " it (a.(0) == l && a.(127) == l && a.(128) == l && a.(254) == l)
  done
""")
    # float array
    fs = [0, 1, 2, 3, 84, 85]
    fs = [0, 1, 2, 3, 84, 85]
    fprobes = [0, 1, 2, 3, 83, 84, 85, 86, 127, 128]
    add("float", "let pget a i = a.(i)\nlet pset a i v = a.(i) <- v\nlet fsizes = %s\nlet fprobes = %s\n" % (arr(map(str, fs)), arr(map(str, fprobes))))
    add("float", """let test_fsize n =
  let a = Array.make n 1.5 in
  checkn "f make len " n (Array.length a = n);
  (let bad = ref (-1) in
   for i = n - 1 downto 0 do if a.(i) <> 1.5 then bad := i done;
   check2 "f make fill " n !bad (!bad < 0));
  for i = 0 to n - 1 do a.(i) <- float_of_int i *. 0.5 done;
  let ok = ref true in
  for i = 0 to n - 1 do if a.(i) <> float_of_int i *. 0.5 then ok := false done;
  checkn "f get/set " n !ok;
  for k = 0 to %d do
    let p = fprobes.(k) in
    if p < n then begin
      check2 "f probe " n p (a.(p) = float_of_int p *. 0.5);
      check2 "f pget " n p (pget a p = float_of_int p *. 0.5)
    end else begin
      raises_inv "f get oob" (fun () -> a.(p));
      raises_inv "f set oob" (fun () -> a.(p) <- 1.0);
      raises_inv "f pget oob" (fun () -> pget a p)
    end
  done;
  let b = Array.init n (fun i -> float_of_int i) in
  let c = Array.copy a in
  let ok2 = ref (Array.length b = n && Array.length c = n) in
  for i = 0 to n - 1 do
    if b.(i) <> float_of_int i || c.(i) <> float_of_int i *. 0.5 then ok2 := false
  done;
  checkn "f init/copy " n !ok2
""" % (len(fprobes) - 1))

    # sub / append / concat / blit  su int array
    add("subs", """let ident n = Array.init n (fun i -> i)
let ident_b n = Array.init n (fun i -> 1000 + i)
let sub_case ofs len =
  let s = Array.sub (ident 255) ofs len in
  check2 "sub len " ofs len (Array.length s = len);
  let ok = ref true in
  for i = 0 to len - 1 do if s.(i) <> ofs + i then ok := false done;
  check2 "sub elts " ofs len !ok
let append_case n1 n2 =
  let c = Array.append (ident n1) (ident_b n2) in
  check2 "append len " n1 n2 (Array.length c = n1 + n2);
  let ok = ref true in
  for i = 0 to n1 + n2 - 1 do
    if c.(i) <> (if i < n1 then i else 1000 + i - n1) then ok := false
  done;
  check2 "append elts " n1 n2 !ok
let concat_case l =
  let a = List.map ident l in
  let c = Array.concat a in
  let tot = List.fold_left (+) 0 l in
  checkn "concat len " tot (Array.length c = tot);
  let ok = ref true in
  let pos = ref 0 in
  List.iter (fun n ->
    for i = 0 to n - 1 do if c.(!pos + i) <> i then ok := false done;
    pos := !pos + n) l;
  checkn "concat elts " tot !ok
let blit_same so d n =
  let a = ident 255 in
  Array.blit a so a d n;
  let ok = ref true in
  for i = 0 to 254 do
    let e = if i >= d && i < d + n then so + i - d else i in
    if a.(i) <> e then ok := false
  done;
  check2 "blit same " so d (!ok && true);
  if not !ok then fail ("  (n=" ^ string_of_int n ^ ")")
let blit_other so d n =
  let a = ident 255 and b = ident_b 255 in
  Array.blit a so b d n;
  let ok = ref true in
  for i = 0 to 254 do
    let e = if i >= d && i < d + n then so + i - d else 1000 + i in
    if b.(i) <> e then ok := false
  done;
  check2 "blit other " so d (!ok && true);
  if not !ok then fail ("  (n=" ^ string_of_int n ^ ")")
""")
    sub_ok = [(0, 0), (0, 1), (0, 255), (254, 1), (255, 0), (1, 254), (127, 128),
              (128, 127), (127, 1), (128, 1), (0, 127), (0, 128), (100, 155), (0, 254)]
    sub_bad = [(0, 256), (255, 1), (1, 255), (-1, 1), (0, -1), (254, 2)]
    app_ok = [(0, 0), (0, 5), (5, 0), (127, 128), (128, 127), (1, 254), (254, 1),
              (255, 0), (0, 255), (100, 100), (127, 127), (128, 126)]
    app_bad = [(128, 128), (255, 1), (1, 255), (200, 56)]
    cat_ok = [[50, 100, 105], [127, 0, 128], [0, 0, 0], [255], [128, 127],
              [1, 1, 1, 1], [0, 255], [255, 0], [100, 0, 0, 155], [127, 128]]
    cat_bad = [[128, 128], [255, 1], [100, 100, 100]]
    blit_ok = [(0, 1, 254), (1, 0, 254), (0, 127, 128), (127, 0, 128), (0, 128, 127),
               (128, 0, 127), (100, 101, 100), (101, 100, 100), (0, 0, 255), (0, 0, 0),
               (254, 0, 1), (0, 254, 1), (128, 127, 127), (127, 128, 127), (3, 5, 200)]
    b = ["let test_sub () ="]
    for ofs, ln in sub_ok:
        b.append("  sub_case %s %s;" % (oi(ofs), oi(ln)))
    for ofs, ln in sub_bad:
        b.append('  raises_inv "sub bad" (fun () -> Array.sub (ident 255) %s %s);' % (oi(ofs), oi(ln)))
    b.append("  ()\nlet test_append () =")
    for x, y in app_ok:
        b.append("  append_case %d %d;" % (x, y))
    for x, y in app_bad:
        b.append('  raises_inv "append bad" (fun () -> Array.append (ident %d) (ident %d));' % (x, y))
    b.append("  ()\nlet test_concat () =")
    for l in cat_ok:
        b.append("  concat_case [%s];" % "; ".join(map(str, l)))
    for l in cat_bad:
        b.append('  raises_inv "concat bad" (fun () -> Array.concat [%s]);' % "; ".join(
            "ident %d" % x for x in l))
    b.append('  check "concat []" (Array.length (Array.concat ([] : int array list)) = 0)')
    b.append("\nlet test_blit () =")
    for so, d, n in blit_ok:
        b.append("  blit_same %d %d %d;" % (so, d, n))
        b.append("  blit_other %d %d %d;" % (so, d, n))
    for so, d, n in [(0, 0, 256), (1, 0, 255), (0, 1, 255), (-1, 0, 1), (0, -1, 1)]:
        b.append('  raises_inv "blit bad" (fun () -> Array.blit (ident 255) %s (ident 255) %s %s);' % (
            oi(so), oi(d), oi(n)))
    b.append("  ()\n")
    add("subs", "\n".join(b))

    # float: sub/append/concat/blit
    add("fsubs", """let fid n = Array.init n (fun i -> float_of_int i)
let fid_b n = Array.init n (fun i -> float_of_int (1000 + i))
let fsub_case ofs len =
  let s = Array.sub (fid 85) ofs len in
  check2 "fsub len " ofs len (Array.length s = len);
  let ok = ref true in
  for i = 0 to len - 1 do if s.(i) <> float_of_int (ofs + i) then ok := false done;
  check2 "fsub elts " ofs len !ok
let fappend_case n1 n2 =
  let c = Array.append (fid n1) (fid_b n2) in
  check2 "fappend len " n1 n2 (Array.length c = n1 + n2);
  let ok = ref true in
  for i = 0 to n1 + n2 - 1 do
    if c.(i) <> (if i < n1 then float_of_int i else float_of_int (1000 + i - n1))
    then ok := false
  done;
  check2 "fappend elts " n1 n2 !ok
let fblit_same so d n =
  let a = fid 85 in
  Array.blit a so a d n;
  let ok = ref true in
  for i = 0 to 84 do
    let e = if i >= d && i < d + n then so + i - d else i in
    if a.(i) <> float_of_int e then ok := false
  done;
  check2 "fblit same " so d !ok
let fblit_other so d n =
  let a = fid 85 and b = fid_b 85 in
  Array.blit a so b d n;
  let ok = ref true in
  for i = 0 to 84 do
    let e = if i >= d && i < d + n then so + i - d else 1000 + i in
    if b.(i) <> float_of_int e then ok := false
  done;
  check2 "fblit other " so d !ok
let test_fsub () =
  fsub_case 0 0; fsub_case 0 1; fsub_case 0 85; fsub_case 84 1; fsub_case 85 0;
  fsub_case 1 84; fsub_case 42 43; fsub_case 43 42;
  raises_inv "fsub bad" (fun () -> Array.sub (fid 85) 1 85);
  fappend_case 0 0; fappend_case 42 43; fappend_case 43 42; fappend_case 1 84;
  fappend_case 84 1; fappend_case 85 0; fappend_case 0 85;
  raises_inv "fappend bad" (fun () -> Array.append (fid 43) (fid 43));
  raises_inv "fappend bad2" (fun () -> Array.append (fid 85) (fid 1));
  let c = Array.concat [fid 40; fid_b 45] in
  check "fconcat len" (Array.length c = 85);
  check "fconcat elts" (c.(0) = 0.0 && c.(39) = 39.0 && c.(40) = 1000.0 && c.(84) = 1044.0);
  raises_inv "fconcat bad" (fun () -> Array.concat [fid 43; fid 43]);
  fblit_same 0 1 84; fblit_same 1 0 84; fblit_same 0 42 43; fblit_same 42 0 43;
  fblit_same 0 0 85; fblit_same 84 0 1; fblit_same 0 84 1;
  fblit_other 0 1 84; fblit_other 1 0 84; fblit_other 0 42 43; fblit_other 42 0 43;
  fblit_other 0 0 85; fblit_other 84 0 1; fblit_other 0 84 1
""")

    # stress: GC dentro le primitive (puntatori interni / TMP non radici)
    add("stress", """let ident n = Array.init n (fun i -> i)
let ident_b n = Array.init n (fun i -> 1000 + i)
let fid n = Array.init n (fun i -> float_of_int i)
let fid_b n = Array.init n (fun i -> float_of_int (1000 + i))
let stress_int () =
  let a = ident 200 and b = ident_b 55 in
  for it = 1 to 250 do
    let c = Array.append a b in
    let ok1 = Array.length c = 255 && c.(0) = 0 && c.(199) = 199
              && c.(200) = 1000 && c.(254) = 1054 in
    checkn "stress append " it ok1;
    let d = Array.sub c (it mod 40) 200 in
    let k = it mod 40 in
    checkn "stress sub " it (Array.length d = 200 && d.(0) = k
                             && d.(199) = (if k = 0 then 199 else 999 + k));
    let e = Array.concat [a; b] in
    checkn "stress concat " it (Array.length e = 255 && e.(0) = 0 && e.(254) = 1054
                                && e.(200) = 1000);
    let f = Array.make 255 it in
    checkn "stress make " it (f.(0) = it && f.(254) = it);
    Array.blit c 0 f 1 254;
    checkn "stress blit " it (f.(0) = it && f.(1) = 0 && f.(254) = 1053)
  done
let stress_float () =
  let a = fid 40 and b = fid_b 45 in
  for it = 1 to 150 do
    let c = Array.append a b in
    checkn "fstress append " it (Array.length c = 85 && c.(0) = 0.0 && c.(39) = 39.0
                                 && c.(40) = 1000.0 && c.(84) = 1044.0);
    let d = Array.sub c 5 80 in
    checkn "fstress sub " it (Array.length d = 80 && d.(0) = 5.0 && d.(79) = 1044.0);
    let e = Array.concat [a; b] in
    checkn "fstress concat " it (Array.length e = 85 && e.(84) = 1044.0);
    let g = Array.make 85 (float_of_int it) in
    checkn "fstress make " it (g.(0) = float_of_int it && g.(84) = float_of_int it)
  done
""")
    add("atoms", """let test_atoms () =
  let a = Array.make 0 1 in
  let b = Array.sub [|1; 2|] 1 0 in
  let c = Array.concat ([] : int array list) in
  let d = Array.append ([||] : int array) [||] in
  let e = Array.init 0 (fun i -> i) in
  let f = Array.copy ([||] : int array) in
  check "atoms len" (Array.length a = 0 && Array.length b = 0 && Array.length c = 0
                     && Array.length d = 0 && Array.length e = 0 && Array.length f = 0);
  check "atoms phys" (a == b && b == c && c == d && d == e && e == f);
  check "atoms obj" (Obj.size (Obj.repr a) = 0);
  check "atom new_block" (Obj.new_block 0 0 == Obj.repr a);
  let lit1 = ([||] : int array) and lit2 = ([||] : int array) in
  check "atoms lit" (lit1 == lit2 && lit1 == a);
  let fa = Array.make 0 1.5 in
  check "float atom" (Array.length fa = 0 && Obj.repr fa == Obj.repr a);
  let keep = (a, [|b|], [c], ref d) in
  for i = 1 to 120 do
    ignore (String.make 200 'x');
    ignore (Array.make 100 i);
    ignore (Array.make 255 [i])
  done;
  let (a1, ba, cl, rd) = keep in
  check "atoms survive gc" (a1 == a && Array.length ba.(0) = 0 && ba.(0) == a
                            && (match cl with [x] -> x == a | _ -> false) && !rd == a);
  check "empty string" (String.length "" = 0 && String.length (String.make 0 'x') = 0
                        && Bytes.length (Bytes.create 0) = 0);
  check "empty string cmp" (String.equal "" (String.make 0 'a') && compare "" (String.make 0 'a') = 0
                            && "" < "a" && not ("a" < "") && "" <= String.make 0 'z'
                            && "" >= String.make 0 'z');
  raises_inv "empty get" (fun () -> a.(0));
  raises_inv "empty set" (fun () -> a.(0) <- 1);
  raises_inv "empty sub" (fun () -> Array.sub a 0 1);
  raises_inv "empty string get" (fun () -> String.get "" 0);
  check "atoms blit" (Array.blit a 0 b 0 0; true);
  check "atoms fill" (let x = Array.make 3 0 in Array.blit a 0 x 0 0; x.(0) = 0 && x.(2) = 0)
""")
    m = ["let () ="]
    if "atoms" in sections:
        m.append('  run "atoms" test_atoms;')
    if "int" in sections:
        m.append('  for i = 0 to %d do run "size" (fun () -> test_size sizes.(i)) done;' % (len(sizes) - 1))
        m.append('  run "make_err" test_make_err;')
        m.append('  run "make_blk" test_make_blk;')
    if "float" in sections:
        m.append('  for i = 0 to %d do run "fsize" (fun () -> test_fsize fsizes.(i)) done;' % (len(fs) - 1))
    if "subs" in sections:
        m += ['  run "sub" test_sub;', '  run "append" test_append;', '  run "concat" test_concat;',
              '  run "blit" test_blit;']
    if "fsubs" in sections:
        m.append('  run "fsub" test_fsub;')
    if "stress" in sections:
        m += ['  run "stress_int" stress_int;', '  run "stress_float" stress_float;']
    m.append('  finish "%s"' % tag)
    o.append("\n".join(m) + "\n")
    return "".join(o)
