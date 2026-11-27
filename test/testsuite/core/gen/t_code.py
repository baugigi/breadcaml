from common import *

# ---------------------------------------------------------------------------
# T05: ambiente delle closure (ENVACC n, CLOSURE n, CLOSUREREC f v, OFFSETCLOSURE)
# ---------------------------------------------------------------------------
def t05(KS, VS, MS, tag):
    o = [PRELUDE]
    a = 2
    for k in KS:
        lets = "".join("  let v%d = a + %d in\n" % (i, i % 4) for i in range(k))
        o.append("let clo%d a =\n%s  fun x -> x + %s\n" % (
            k, lets, " + ".join("v%d" % i for i in range(k))))
    for v in VS:
        lets = "".join("  let v%d = a + %d in\n" % (i, i % 4) for i in range(v))
        o.append("""let rc%d a =
%s  let rec f x = if x = 0 then %s else g (x - 1)
  and g x = if x = 0 then 0 else f (x - 1) in
  (f, g)
""" % (v, lets, " + ".join("v%d" % i for i in range(v))))
    for m in MS:
        fs = []
        for i in range(m):
            fs.append("%s m%d_h%d x = if x = 0 then %d else m%d_h%d (x - 1)" % (
                "let rec" if i == 0 else "and", m, i, i, m, (i + 1) % m))
        o.append("\n".join(fs) + "\n")
    b = ["let () ="]
    for k in KS:
        s = sum(a + i % 4 for i in range(k))
        assert s + 10 < 16000
        b.append('  run "clo%d" (fun () -> let f = clo%d %d in '
                 'check2 "clo " %d 3 (f 3 = %d); check2 "clo " %d 10 (f 10 = %d); '
                 'check2 "clo " %d 3 (f 3 = %d));' % (k, k, a, k, 3 + s, k, 10 + s, k, 3 + s))
    for v in VS:
        s = sum(1 + i % 4 for i in range(v))
        assert s < 16000
        b.append('  run "rc%d" (fun () -> let (f, g) = rc%d 1 in '
                 'checkn "rc f4 " %d (f 4 = %d); checkn "rc f3 " %d (f 3 = 0); '
                 'checkn "rc g3 " %d (g 3 = %d); checkn "rc g4 " %d (g 4 = 0));' % (
                     v, v, v, s, v, v, s, v))
    for m in MS:
        n1 = 2 * m + 3
        b.append('  run "mrec%d" (fun () -> checkn "mrec h0 " %d (m%d_h0 %d = %d); '
                 'checkn "mrec hlast " %d (m%d_h%d 5 = %d));' % (
                     m, m, m, n1, n1 % m, m, m, m - 1, (m - 1 + 5) % m))
    b.append('  finish "%s"' % tag)
    o.append("\n".join(b) + "\n")
    return "".join(o)


# ---------------------------------------------------------------------------
# T06: SWITCH (costanti/blocchi), match su interi densi, rami BEQ/BNEQ/BLT..,
#      confronti con costanti ai bordi di byte, range di caratteri (BULTINT)
# ---------------------------------------------------------------------------
def t06(NC, MIX, ND, CIDX, misc, tag):
    o = [PRELUDE]
    for n in NC:
        o.append("type c%d = %s\n" % (n, " | ".join("C%d_%d" % (n, i) for i in range(n))))
        o.append("let f%d = function\n%s\n" % (n, "\n".join(
            "  | C%d_%d -> %d" % (n, i, (i * 7 + 3) % 1000) for i in range(n))))
        o.append("let all%d = %s\n" % (n, arr("C%d_%d" % (n, i) for i in range(n))))
        o.append("let e%d = %s\n" % (n, arr(str((i * 7 + 3) % 1000) for i in range(n))))
        o.append("let sw%d () =\n  for i = 0 to %d do check2 \"sw \" %d i (f%d all%d.(i) = e%d.(i)) done\n" % (
            n, n - 1, n, n, n, n))
    for nc, nb in MIX:
        tag = "%d_%d" % (nc, nb)
        cs = ["Mc%s_%d" % (tag, i) for i in range(nc)]
        bs = ["Mb%s_%d of int" % (tag, j) for j in range(nb)]
        o.append("type m%s = %s\n" % (tag, " | ".join(cs + bs)))
        arms = ["  | Mc%s_%d -> %d" % (tag, i, (i * 3 + 1) % 1000) for i in range(nc)]
        arms += ["  | Mb%s_%d x -> x + %d" % (tag, j, j * 11) for j in range(nb)]
        o.append("let fm%s = function\n%s\n" % (tag, "\n".join(arms)))
        o.append("let allm%s a = %s\n" % (tag, arr(
            ["Mc%s_%d" % (tag, i) for i in range(nc)] +
            ["Mb%s_%d (a + 0)" % (tag, j) for j in range(nb)])))
        o.append("""let swm%s () =
  let t = allm%s 7 in
  for i = 0 to %d do
    let e = if i < %d then (i * 3 + 1) mod 1000 else 7 + (i - %d) * 11 in
    check2 "swm " %d i (fm%s t.(i) = e)
  done
""" % (tag, tag, nc + nb - 1, nc, nc, nc, tag))
    # match su interi consecutivi
    for n in ND:
        o.append("let g%d x = match x with\n%s\n  | _ -> (-1)\n" % (n, "\n".join(
            "  | %d -> %d" % (i, (i * 5 + 1) % 1000) for i in range(n))))
        o.append("let tg%d () =\n  for i = 0 to %d do check2 \"gmatch \" %d i (g%d i = (i * 5 + 1) mod 1000) done;\n"
                 "  check \"g out hi\" (g%d %d = (-1) && g%d (-1) = (-1) && g%d 300 = (-1))\n" % (
                     n, n - 1, n, n, n, n, n, n))
    if misc: o.append("""let h x = match x with
  | -2 -> 10 | -1 -> 11 | 0 -> 12 | 1 -> 13 | 2 -> 14 | 3 -> 15 | 4 -> 16 | _ -> 0
let th () =
  check "h" (h (-2) = 10 && h (-1) = 11 && h 0 = 12 && h 1 = 13 && h 4 = 16
             && h (-3) = 0 && h 5 = 0 && h 254 = 0 && h (-254) = 0)
""")
    # confronti con costante: bit 1:<, 2:<=, 4:>, 8:>=, 16:=, 32:<>
    C = [-16384, -257, -256, -255, -129, -128, -127, -123, -2, -1, 0, 1, 2, 5, 126, 127,
         128, 129, 133, 254, 255, 256, 257, 261, 16382, 16383]
    X = sorted(set(C + [3, 4, 6, 7, 131, 132, 134, 135, -5, -6, 8191, -8192, -124, -122]))
    if CIDX: o.append("let xs = %s\n" % arr(oi(x) for x in X))
    for idx, c in enumerate(C):
        if idx not in CIDX:
            continue
        cc = oi(c)
        o.append("""let bits%d x =
  (if x < %s then 1 else 0) + (if x <= %s then 2 else 0) + (if x > %s then 4 else 0)
  + (if x >= %s then 8 else 0) + (if x = %s then 16 else 0) + (if x <> %s then 32 else 0)
""" % (idx, cc, cc, cc, cc, cc, cc))
        e = [(1 * (x < c) + 2 * (x <= c) + 4 * (x > c) + 8 * (x >= c)
              + 16 * (x == c) + 32 * (x != c)) for x in X]
        o.append("let ex%d = %s\n" % (idx, arr(map(str, e))))
        o.append("let tb%d () =\n  for j = 0 to %d do check2 \"bits c=\" %s j "
                 "(bits%d xs.(j) = ex%d.(j)) done\n" % (
                     idx, len(X) - 1, oi(c), idx, idx))
    # range di caratteri (OFFSETINT + BULTINT)
    cls = lambda ch: 1 if 65 <= ch <= 90 else 2 if 193 <= ch <= 218 else 3 if 48 <= ch <= 57 else 0  # PETSCII
    PC = [0, 47, 48, 57, 58, 64, 65, 90, 91, 96, 97, 122, 128, 192, 193, 218, 219, 255]
    if misc: o.append("""let cls ch = match ch with 'a'..'z' -> 1 | 'A'..'Z' -> 2 | '0'..'9' -> 3 | _ -> 0
let pc = %s
let ec = %s
let tcls () =
  for i = 0 to %d do check2 "cls " pc.(i) i (cls (Char.chr pc.(i)) = ec.(i)) done
""" % (arr(map(str, PC)), arr(str(cls(c)) for c in PC), len(PC) - 1))
    b = ["let () ="]
    for n in NC:
        b.append('  run "sw%d" sw%d;' % (n, n))
    for nc, nb in MIX:
        b.append('  run "swm%d_%d" swm%d_%d;' % (nc, nb, nc, nb))
    for n in ND:
        b.append('  run "g%d" tg%d;' % (n, n))
    if misc:
        b.append('  run "h" th;')
    for idx in CIDX:
        b.append('  run "bits%d" tb%d;' % (idx, idx))
    if misc:
        b.append('  run "cls" tcls;')
    b.append('  finish "%s"' % tag)
    o.append("\n".join(b) + "\n")
    return "".join(o)


# ---------------------------------------------------------------------------
# T07: pila (ACC n alto, ASSIGN n), APPLY/GRAB/RESTART/APPTERM/RETURN con molti argomenti
# ---------------------------------------------------------------------------
def t07(KD, KA, NA, TA, misc, tag, apm='all'):
    o = [PRELUDE]
    a = 3
    for k in KD:
        lets = "".join("  let v%d = a + %d in\n" % (i, i % 4) for i in range(k))
        o.append("let deep%d a =\n%s  %s\n" % (k, lets, " + ".join("v%d" % i for i in range(k))))
        o.append("let deeprev%d a =\n%s  %s\n" % (k, lets, " + ".join("v%d" % i for i in range(k - 1, -1, -1))))
        if k <= 124:   # RETURN n = k + 3 <= 127; il letterale array spinge k-1 valori => ACC fino a ~2k
            o.append("let deeparr%d a =\n%s  let r = [| %s |] in\n  let s = ref 0 in\n"
                     "  for i = 0 to %d do s := !s + r.(i) done;\n  !s\n" % (
                         k, lets, "; ".join("v%d" % i for i in range(k)), k - 1))
    for k in KA:
        o.append("let asg%d () =\n%s  for i = 1 to 3 do\n%s  done;\n  %s\n" % (
            k, "".join("  let r%d = ref 0 in\n" % i for i in range(k)),
            "".join("    r%d := !r%d + %d;\n" % (i, i, i % 5 + 1) for i in range(k)),
            " + ".join("!r%d" % i for i in range(k))))
    for n in NA:
        ps = " ".join("a%d" % i for i in range(1, n + 1))
        o.append("let ap%d %s = %s\n" % (n, ps, " + ".join("a%d" % i for i in range(1, n + 1))))
    for n in TA:
        ps = " ".join("b%d" % i for i in range(3, n + 1))
        sm = "".join(" + b%d" % i for i in range(3, n + 1))
        o.append("let rec lp%d i acc %s = if i = 0 then acc%s else lp%d (i - 1) (acc + 1) %s\n" % (
            n, ps, sm, n, ps))
    if misc: o.append("""let rec cnt n = if n = 0 then 0 else 1 + cnt (n - 1)
let over1 a = if a > 1000 then (fun b -> 0) else (fun b -> a + b)
let over3 a = if a > 1000 then (fun b c d -> 0) else (fun b c d -> a + b + c + d)
let rec evn n = if n = 0 then true else odd (n - 1)
and odd n = if n = 0 then false else evn (n - 1)
""")
    b = ["let () ="]
    for k in KD:
        s = sum(a + i % 4 for i in range(k))
        b.append('  run "deep%d" (fun () -> checkn "deep " %d (deep%d %d = %d); '
                 'checkn "deeprev " %d (deeprev%d %d = %d)%s);' % (
                     k, k, k, a, s, k, k, a, s,
                     ('; checkn "deeparr " %d (deeparr%d %d = %d)' % (k, k, a, s)) if k <= 124 else ""))
    for k in KA:
        s = sum(3 * (i % 5 + 1) for i in range(k))
        assert s < 16000
        b.append('  run "asg%d" (fun () -> checkn "assign " %d (asg%d () = %d));' % (k, k, k, s))
    for n in NA:
        args = " ".join(str(i) for i in range(1, n + 1))
        e = n * (n + 1) // 2
        k = max(1, n // 2)
        lo = " ".join(str(i) for i in range(1, k + 1))
        hi = " ".join(str(i) for i in range(k + 1, n + 1))
        line = '  run "ap%d" (fun () -> ' % n
        if apm in ('all', 'full'):
            line += 'checkn "apply " %d (ap%d %s = %d);' % (n, n, args, e)
        if n >= 2 and apm in ('all', 'p1'):
            line += ' let p = ap%d %s in checkn "papply " %d (p %s = %d);' % (n, lo, n, hi, e)
        if n > 2 and apm in ('all', 'p2'):
            line += ' let q = ap%d %s in let r = q %d in checkn "papply2 " %d (r %s = %d);' % (
                n, "1", 2, n, " ".join(str(i) for i in range(3, n + 1)), e)
        line += ' ());'
        b.append(line)
    for n in TA:
        extra = " ".join(str(i) for i in range(3, n + 1))
        e = 5 + sum(range(3, n + 1))
        e300 = 300 + sum(range(3, n + 1))
        assert e300 < 16000
        b.append('  run "lp%d" (fun () -> checkn "tailcall " %d (lp%d 5 0 %s = %d); '
                 'checkn "tailcall300 " %d (lp%d 300 0 %s = %d));' % (n, n, n, extra, e, n, n, extra, e300))
    if misc: b.append('  run "over" (fun () -> check "over1" (over1 1 2 = 3); check "over3" (over3 1 2 3 4 = 10); '
             'let f = over3 1 2 in check "over3 partial" (f 3 4 = 10 && f 10 20 = 33));')
    if misc: b.append('  run "cnt" (fun () -> check "cnt50" (cnt 50 = 50); check "cnt100" (cnt 100 = 100));')
    if misc: b.append('  run "evodd" (fun () -> check "evn 100" (evn 100); check "odd 101" (odd 101); '
             'check "evn 101" (not (evn 101)));')
    b.append('  finish "%s"' % tag)
    o.append("\n".join(b) + "\n")
    return "".join(o)


# ---------------------------------------------------------------------------
# T09: eccezioni (trap frame, RAISE da frame profondi, payload, rilancio)
# ---------------------------------------------------------------------------
def t09(KS, misc, tag):
    o = [PRELUDE]
    for k in KS:
        lets = "".join("  let v%d = a + %d in\n" % (i, i % 4) for i in range(k))
        o.append("let thrower%d a =\n%s  if v0 + v%d > 0 then raise (E1 (%s)) else 0\n" % (
            k, lets, k - 1, " + ".join("v%d" % i for i in range(k))))
    pre = """exception E1 of int
exception E2 of string * int
exception E3
let rec down n = if n = 0 then raise Not_found else 1 + down (n - 1)
let rec down_try n = if n = 0 then raise E3 else (try 1 + down_try (n - 1) with E1 _ -> 0)
let nested () =
  try
    try
      try raise (E1 5) with E2 _ -> 0
    with E1 n -> raise (E2 ("re", n + 1))
  with E2 (s, n) -> if String.equal s "re" then n else -1
let reraise () =
  try (try raise E3 with e -> raise e) with E3 -> 1 | _ -> 2
let guard n = try raise (E1 n) with E1 k when k > 3 -> 1 | E1 _ -> 2
let after_trap_balance () =
  (* push/pop di trap in loop: se SP non e' bilanciato la ricorsione sotto crolla *)
  let c = ref 0 in
  for i = 1 to 300 do
    (try if i mod 3 = 0 then raise Not_found else incr c with Not_found -> c := !c + 2)
  done;
  !c
let prim_exn () =
  let r = ref 0 in
  (try ignore (Array.make 300 0) with Invalid_argument _ -> incr r);
  (try ignore ([|1; 2|].(5)) with Invalid_argument _ -> incr r);
  (try ignore ("abc".[10]) with Invalid_argument _ -> incr r);
  (try ignore (1 / (!r - !r)) with Division_by_zero -> incr r);
  (try ignore (5 mod (!r - !r)) with Division_by_zero -> incr r);
  (try failwith "boom" with Failure s -> if String.equal s "boom" then incr r);
  (try invalid_arg "ia" with Invalid_argument s -> if String.equal s "ia" then incr r);
  (try ignore (List.assoc 3 [(1, 2)]) with Not_found -> incr r);
  !r
let alloc_in_try () =
  let ok = ref true in
  for i = 1 to 150 do
    (try
       let s = String.make 150 'q' in
       let a = Array.make 100 i in
       raise (E2 (s, Array.length a + i))
     with E2 (s, n) -> if not (String.length s = 150 && n = 100 + i) then ok := false)
  done;
  !ok
"""
    o.insert(1, pre if misc else pre.split('let rec down')[0])
    b = ["let () ="]
    for k in KS:
        s = sum(2 + i % 4 for i in range(k))
        assert s < 16000
        b.append('  run "thr%d" (fun () -> checkn "thrower " %d (try thrower%d 2 with E1 n -> n) = %d);' % (k, k, k, s)
                 if False else
                 '  run "thr%d" (fun () -> checkn "thrower " %d ((try thrower%d 2 with E1 n -> n) = %d));' % (k, k, k, s))
    if misc:
        b.append('  run "down" (fun () -> check "down 50" ((try down 50 with Not_found -> -7) = -7); '
                 'check "down 100" ((try down 100 with Not_found -> -7) = -7));')
        b.append('  run "down_try" (fun () -> check "down_try" ((try down_try 60 with E3 -> 9) = 9));')
        b.append('  run "nested" (fun () -> check "nested" (nested () = 6));')
        b.append('  run "reraise" (fun () -> check "reraise" (reraise () = 1));')
        b.append('  run "guard" (fun () -> check "guard" (guard 5 = 1 && guard 3 = 2 && guard 4 = 1));')
        # after_trap_balance: i multipli di 3 -> 100 volte +2, altri 200 volte +1
        b.append('  run "trapbal" (fun () -> check "trapbal" (after_trap_balance () = %d));' % (100 * 2 + 200))
        b.append('  run "prim_exn" (fun () -> check "prim_exn" (prim_exn () = 8));')
        b.append('  run "alloc_in_try" (fun () -> check "alloc_in_try" (alloc_in_try ()));')
    b.append('  finish "%s"' % tag)
    o.append("\n".join(b) + "\n")
    return "".join(o)


# ---------------------------------------------------------------------------
# T07p: sonda: variabili locali in numero > 127 dentro un'espressione NON in coda
# (la pila viene ripulita con POP, non con RETURN n). Non e' detto che rientri nei
# limiti documentati: un errore di caml_range qui indica il limite di POP/ACC.
# ---------------------------------------------------------------------------
def t07pop(K, tag):
    o = [PRELUDE]
    a = 3
    for k in K:
        lets = "".join("    let v%d = a + %d in\n" % (i, i % 4) for i in range(k))
        o.append("let pop%d a =\n  let r =\n%s    %s in\n  r + 1\n" % (
            k, lets, " + ".join("v%d" % i for i in range(k))))
    b = ["let () ="]
    for k in K:
        s = sum(a + i % 4 for i in range(k)) + 1
        assert s < 16000
        b.append('  run "pop%d" (fun () -> checkn "pop " %d (pop%d %d = %d));' % (k, k, k, a, s))
    b.append('  finish "%s"' % tag)
    o.append("\n".join(b) + "\n")
    return "".join(o)
