from common import *

# ---------------------------------------------------------------------------
# T08: interi a 15 bit: bordi, wrap, divisioni con segno, shift (checksum per riga)
# ---------------------------------------------------------------------------
V15 = [-16384, -16383, -8192, -257, -256, -255, -129, -128, -127, -3, -2, -1, 0, 1, 2,
       3, 126, 127, 128, 129, 254, 255, 256, 257, 8191, 8192, 16382, 16383]

def row15(f, a):
    c = 0
    for b in V15:
        r = f(a, b)
        assert -16384 <= r <= 16383
        c = (c * 7 + (r & 16383) + (((r >> 14) & 1) * 5)) & 16383
    return c

def t08():
    o = [PRELUDE]
    NV = len(V15)
    o.append("let vals = %s\nlet z = ref 0\n" % arr(oi(v) for v in V15))
    o.append("""let row f a =
  let c = ref 0 in
  for j = 0 to %d do
    let r = f a vals.(j) in
    c := (!c * 7 + (r land 16383) + ((r lsr 14) land 1) * 5) land 16383
  done;
  !c
let chk name f e =
  for i = 0 to %d do
    if row f vals.(i) <> e.(i) then fail (name ^ " row " ^ string_of_int i)
  done
""" % (NV - 1, NV - 1))
    sh = lambda b: (b & 15) % 15
    ops = [
        ("add", "fun a b -> a + b", lambda a, b: w15(a + b)),
        ("sub", "fun a b -> a - b", lambda a, b: w15(a - b)),
        ("mul", "fun a b -> a * b", lambda a, b: w15(a * b)),
        ("div", "fun a b -> if b = 0 then 0 else a / b",
         lambda a, b: 0 if b == 0 else w15(tdiv(a, b))),
        ("mod", "fun a b -> if b = 0 then 0 else a mod b",
         lambda a, b: 0 if b == 0 else w15(tmod(a, b))),
        ("and", "fun a b -> a land b", lambda a, b: w15(a & b)),
        ("or", "fun a b -> a lor b", lambda a, b: w15(a | b)),
        ("xor", "fun a b -> a lxor b", lambda a, b: w15(a ^ b)),
        ("lsl", "fun a b -> a lsl ((b land 15) mod 15)", lambda a, b: w15(a << sh(b))),
        ("lsr", "fun a b -> a lsr ((b land 15) mod 15)",
         lambda a, b: w15((a & 0x7FFF) >> sh(b))),
        ("asr", "fun a b -> a asr ((b land 15) mod 15)", lambda a, b: a >> sh(b)),
        ("neg", "fun a _ -> - a", lambda a, b: w15(-a)),
        ("lnot", "fun a _ -> lnot a", lambda a, b: w15(~a)),
        ("cmp", "fun a b -> let c = compare a b in if c < 0 then -1 else if c > 0 then 1 else 0", lambda a, b: sgn(a - b)),
        ("succ", "fun a _ -> succ a", lambda a, b: w15(a + 1)),
        ("pred", "fun a _ -> pred a", lambda a, b: w15(a - 1)),
        ("abs", "fun a _ -> abs a", lambda a, b: w15(abs(a))),
        ("off+5", "fun a _ -> a + 5", lambda a, b: w15(a + 5)),
        ("off-5", "fun a _ -> a - 5", lambda a, b: w15(a - 5)),
        ("off+300", "fun a _ -> a + 300", lambda a, b: w15(a + 300)),
        ("off-300", "fun a _ -> a - 300", lambda a, b: w15(a - 300)),
        ("mulc", "fun a _ -> a * 3", lambda a, b: w15(a * 3)),
    ]
    for nm, _, _ in ops:
        pass
    b = []
    for i, (nm, code, py) in enumerate(ops):
        exp = [row15(py, a) for a in V15]
        b.append("let e%d = %s\n" % (i, arr(map(str, exp))))
    o.append("".join(b))
    o.append("""let direct () =
  check "max_int" (max_int = 16383);
  check "min_int" (min_int = -16384);
  check "max+1" (max_int + 1 = min_int);
  check "min-1" (min_int - 1 = max_int);
  check "neg min" ((-min_int) = min_int);
  check "abs min" (abs min_int = min_int);
  check "max*2" (max_int * 2 = -2);
  check "min*min" (min_int * min_int = 0);
  check "1 lsl 14" (1 lsl 14 = min_int);
  check "lnot 0" (lnot 0 = -1);
  check "-7/2" ((-7) / 2 = -3);
  check "-7 mod 2" ((-7) mod 2 = -1);
  check "7/-2" (7 / (-2) = -3);
  check "7 mod -2" (7 mod (-2) = 1);
  check "-7/-2" ((-7) / (-2) = 3);
  check "-7 mod -2" ((-7) mod (-2) = -1);
  check "min/-1" (min_int / (-1) = min_int);
  check "min mod -1" (min_int mod (-1) = 0);
  check "16383/128" (16383 / 128 = 127);
  check "-16384/256" ((-16384) / 256 = -64);
  check "300*50" (300 * 50 = 15000);
  check "129*127" (129 * 127 = 16383);
  check "256*64" (256 * 64 = min_int);
  raises_dz "div0" (fun () -> 1 / !z);
  raises_dz "mod0" (fun () -> 1 mod !z);
  raises_dz "div0 neg" (fun () -> (-1) / !z);
  check "compare" (compare min_int max_int < 0 && compare max_int min_int > 0 && compare 3 3 = 0);
  check "min max" (min 3 4 = 3 && max (-3) 4 = 4 && min min_int 0 = min_int);
  check "char a" (Char.code 'a' = 65);
  check "char z" (Char.code 'z' = 90 && Char.code 'A' = 193);
  check "char 255" (Char.code (Char.chr 255) = 255);
  check "char 0" (Char.code (Char.chr 0) = 0);
  check "bool" ((1 < 2) = true && (2 < 1) = false && not (1 = 2))
""")
    m = ["let () =", '  run "direct" direct;']
    for i, (nm, code, py) in enumerate(ops):
        m.append('  run "%s" (fun () -> chk "%s" (%s) e%d);' % (nm, nm, code, i))
    m.append('  finish "T08"')
    o.append("\n".join(m) + "\n")
    return "".join(o)


# ---------------------------------------------------------------------------
# T10: Int32 / Int64 (stdlib_integers.asm): operazioni per riga con checksum a
#      chunk di 14 bit, conversioni, to_string, of_float
# ---------------------------------------------------------------------------
def m32(x):
    x &= 0xFFFFFFFF
    return x - (1 << 32) if x >> 31 else x

def m64(x):
    x &= 0xFFFFFFFFFFFFFFFF
    return x - (1 << 64) if x >> 63 else x

V32 = [0, 1, -1, 2, -2, 3, 7, 255, 256, 65535, 65536, 2**31 - 1, -2**31, 2**31 - 2,
       -(2**31 - 1), 0x12345678, 0xDEADBEEF - 2**32, 0x55555555, 0xAAAAAAAA - 2**32]
V64 = [0, 1, -1, 2, 255, 65536, 2**31 - 1, 2**31, 2**32, 2**63 - 1, -2**63,
       0x123456789ABCDEF0, -0x5555555555555556]

def lit(v, suf):
    return ("%d%s" % (v, suf)) if v >= 0 else "(%d%s)" % (v, suf)

def mkops(bits):
    m = m32 if bits == 32 else m64
    M = (1 << bits) - 1
    sm = bits - 1
    def div(a, b): return 0 if b == 0 else m(tdiv(a, b))
    def rem(a, b): return 0 if b == 0 else m(tmod(a, b))
    return [
        ("add", lambda a, b: m(a + b)), ("sub", lambda a, b: m(a - b)),
        ("mul", lambda a, b: m(a * b)), ("and", lambda a, b: m(a & b)),
        ("or", lambda a, b: m(a | b)), ("xor", lambda a, b: m(a ^ b)),
        ("div", div), ("rem", rem),
        ("shl", lambda a, b: m(a << (b & sm))),
        ("shr", lambda a, b: m(a >> (b & sm))),
        ("shru", lambda a, b: m((a & M) >> (b & sm))),
        ("neg", lambda a, b: m(-a)), ("lognot", lambda a, b: m(~a)),
        ("cmp", lambda a, b: sgn(a - b)),
        ("succ", lambda a, b: m(a + 1)), ("pred", lambda a, b: m(a - 1)),
    ]

def csum(r, bits):
    ru = r & ((1 << bits) - 1)
    chunks = 3 if bits == 32 else 5
    return sum(((ru >> (14 * j)) & 16383) * w for j, w in enumerate([1, 3, 11, 5, 13][:chunks]))

def rows(vals, bits):
    res = {}
    for nm, f in mkops(bits):
        rr = []
        for a in vals:
            c = 0
            for b in vals:
                r = f(a, b)
                c = (c * 7 + csum(r, bits)) & 16383
            rr.append(c)
        res[nm] = rr
    return res

def ocaml_ops(T, suf):
    # T = "Int32"/"Int64", suf = "l"/"L"; shift counts from the low bits of b
    z = "0" + suf
    sm = 31 if T == "Int32" else 63
    return [
        ("add", "fun a b -> %s.add a b" % T), ("sub", "fun a b -> %s.sub a b" % T),
        ("mul", "fun a b -> %s.mul a b" % T), ("and", "fun a b -> %s.logand a b" % T),
        ("or", "fun a b -> %s.logor a b" % T), ("xor", "fun a b -> %s.logxor a b" % T),
        ("div", "fun a b -> if %s.compare b %s = 0 then %s else %s.div a b" % (T, z, z, T)),
        ("rem", "fun a b -> if %s.compare b %s = 0 then %s else %s.rem a b" % (T, z, z, T)),
        ("shl", "fun a b -> %s.shift_left a (%s.to_int b land %d)" % (T, T, sm)),
        ("shr", "fun a b -> %s.shift_right a (%s.to_int b land %d)" % (T, T, sm)),
        ("shru", "fun a b -> %s.shift_right_logical a (%s.to_int b land %d)" % (T, T, sm)),
        ("neg", "fun a _ -> %s.neg a" % T), ("lognot", "fun a _ -> %s.lognot a" % T),
        ("cmp", "fun a b -> %s.of_int (%s.compare a b)" % (T, T)),
        ("succ", "fun a _ -> %s.succ a" % T), ("pred", "fun a _ -> %s.pred a" % T),
    ]

def gen_ops_file(T, suf, bits, vals, tname):
    o = [PRELUDE]
    nv = len(vals)
    o.append("let vals = %s\n" % arr(lit(v, suf) for v in vals))
    chunks = 3 if bits == 32 else 5
    wts = [1, 3, 11, 5, 13][:chunks]
    parts = []
    for j in range(chunks):
        if j == 0:
            sh = "r"
        else:
            sh = "(%s.shift_right_logical r %d)" % (T, 14 * j)
        parts.append("%s.to_int (%s.logand %s 16383%s) * %d" % (T, T, sh, suf, wts[j]))
    o.append("""let row f a =
  let c = ref 0 in
  for j = 0 to %d do
    let r = f a vals.(j) in
    c := (!c * 7 + %s) land 16383
  done;
  !c
let chk name f e =
  for i = 0 to %d do
    if row f vals.(i) <> e.(i) then fail (name ^ " row " ^ string_of_int i)
  done
""" % (nv - 1, " + ".join(parts), nv - 1))
    res = rows(vals, bits)
    oc = ocaml_ops(T, suf)
    for nm, _ in oc:
        o.append("let e_%s = %s\n" % (nm, arr(map(str, res[nm]))))
    m = ["let () ="]
    for nm, code in oc:
        m.append('  run "%s" (fun () -> chk "%s %s" (%s) e_%s);' % (nm, T, nm, code, nm))
    return o, m

def t10_32():
    o, m = gen_ops_file("Int32", "l", 32, V32, "T10a")
    o.append("""let basic () =
  check "i32 add" (Int32.to_int (Int32.add 100l 200l) = 300);
  check "i32 sub" (Int32.to_int (Int32.sub 100l 300l) = -200);
  check "i32 mul" (Int32.to_int (Int32.mul 100l 100l) = 10000);
  check "i32 div" (Int32.to_int (Int32.div 100l 7l) = 14);
  check "i32 rem" (Int32.to_int (Int32.rem 100l 7l) = 2);
  check "i32 div neg" (Int32.to_int (Int32.div (-100l) 7l) = -14);
  check "i32 rem neg" (Int32.to_int (Int32.rem (-100l) 7l) = -2);
  check "i32 div by neg" (Int32.to_int (Int32.div 100l (-7l)) = -14);
  check "i32 shl" (Int32.to_int (Int32.shift_left 1l 10) = 1024);
  check "i32 shr" (Int32.to_int (Int32.shift_right 4096l 4) = 256);
  check "i32 shr neg" (Int32.to_int (Int32.shift_right (-4096l) 4) = -256);
  check "i32 shru 28" (Int32.to_int (Int32.shift_right_logical (-1l) 28) = 15);
  check "i32 shl 31" (Int32.compare (Int32.shift_left 1l 31) (-2147483648l) = 0);
  check "i32 min/-1" (Int32.compare (Int32.div (-2147483648l) (-1l)) (-2147483648l) = 0);
  check "i32 min rem -1" (Int32.to_int (Int32.rem (-2147483648l) (-1l)) = 0);
  raises_dz "i32 div0" (fun () -> Int32.div 5l (Int32.sub 3l 3l));
  raises_dz "i32 rem0" (fun () -> Int32.rem 5l (Int32.sub 3l 3l));
  check "i32 max+1" (Int32.compare (Int32.add 2147483647l 1l) (-2147483648l) = 0);
  check "i32 min-1" (Int32.compare (Int32.sub (-2147483648l) 1l) 2147483647l = 0);
  check "i32 mul ovf" (Int32.compare (Int32.mul 65536l 65536l) 0l = 0);
  check "i32 mul 46341" (Int32.compare (Int32.mul 46341l 46341l) (-2147479015l) = 0)
let conv () =
  let l = [0; 1; -1; 2; 127; 128; 255; 256; 16383; -16384; -16383; 8192; -8193] in
  List.iter (fun n ->
    checkn "i32 of_int/to_int " n (Int32.to_int (Int32.of_int n) = n)) l;
  check "i32 of_int -1 hi" (Int32.to_int (Int32.shift_right_logical (Int32.of_int (-1)) 28) = 15);
  check "i32 of_int -1 eq" (Int32.compare (Int32.of_int (-1)) (-1l) = 0);
  check "i32 of_int min" (Int32.compare (Int32.of_int (-16384)) (-16384l) = 0);
  check "i32 of_int max" (Int32.compare (Int32.of_int 16383) 16383l = 0);
  check "i32 cmp 0 min" (Int32.compare 0l (-2147483648l) > 0 && Int32.compare (-2147483648l) 0l < 0);
  check "i32 cmp top+128" (Int32.compare 2130706432l (-16777216l) > 0 && Int32.compare (-16777216l) 2130706432l < 0);
  check "i32 cmp 1 min+1" (Int32.compare 1l (-2147483647l) > 0 && Int32.compare 5l (-2147483643l) > 0);
  check "i32 to_int low15" (Int32.to_int 65537l = 1);
  check "i32 to_int low15b" (Int32.to_int 32768l = 0 && Int32.to_int 16384l = -16384)
""")
    strs = [0, 1, -1, 12345, -12345, 99999, 65536, 2**31 - 1, -2**31]
    b = ["let tostr () ="]
    for v in strs:
        b.append('  check "i32 to_string %d" (String.equal (Int32.to_string %s) %s);' % (
            v, lit(v, "l"), ostr(str(v).encode())))
    b.append("  ()\n")
    o.append("\n".join(b))
    fl = [(0.0, 0), (1.0, 1), (-1.0, -1), (2.5, 2), (-2.5, -2), (0.99, 0), (-0.99, 0),
          (255.0, 255), (65536.0, 65536), (1000000000.0, 10**9), (-1000000000.0, -10**9),
          (2147483647.0, 2**31 - 1), (-2147483648.0, -2**31), (123456.75, 123456)]
    b = ["let ofloat () ="]
    for f, v in fl:
        b.append('  check "i32 of_float %r" (Int32.compare (Int32.of_float %s) %s = 0);' % (
            f, ("(%r)" % f) if f < 0 else repr(f), lit(v, "l")))
    b.append("  ()\n")
    o.append("\n".join(b))
    m.insert(1, '  run "basic" basic;')
    m.insert(2, '  run "conv" conv;')
    m.insert(3, '  run "tostr" tostr;')
    m.insert(4, '  run "ofloat" ofloat;')
    m.append('  finish "T10A"')
    o.append("\n".join(m) + "\n")
    return "".join(o)

def t10_64():
    o, m = gen_ops_file("Int64", "L", 64, V64, "T10b")
    o.append("""let basic () =
  check "i64 add" (Int64.to_int (Int64.add 100L 200L) = 300);
  check "i64 sub" (Int64.to_int (Int64.sub 100L 300L) = -200);
  check "i64 mul" (Int64.to_int (Int64.mul 100L 100L) = 10000);
  check "i64 div" (Int64.to_int (Int64.div 100L 7L) = 14);
  check "i64 rem" (Int64.to_int (Int64.rem 100L 7L) = 2);
  check "i64 div neg" (Int64.to_int (Int64.div (-100L) 7L) = -14);
  check "i64 rem neg" (Int64.to_int (Int64.rem (-100L) 7L) = -2);
  check "i64 shl" (Int64.to_int (Int64.shift_left 1L 10) = 1024);
  check "i64 shru 60" (Int64.to_int (Int64.shift_right_logical (-1L) 60) = 15);
  check "i64 shr neg" (Int64.to_int (Int64.shift_right (-4096L) 4) = -256);
  check "i64 shl 63" (Int64.compare (Int64.shift_left 1L 63) (-9223372036854775808L) = 0);
  check "i64 shl 32" (Int64.compare (Int64.shift_left 1L 32) 4294967296L = 0);
  check "i64 min/-1" (Int64.compare (Int64.div (-9223372036854775808L) (-1L)) (-9223372036854775808L) = 0);
  check "i64 min rem -1" (Int64.to_int (Int64.rem (-9223372036854775808L) (-1L)) = 0);
  raises_dz "i64 div0" (fun () -> Int64.div 5L (Int64.sub 3L 3L));
  raises_dz "i64 rem0" (fun () -> Int64.rem 5L (Int64.sub 3L 3L));
  check "i64 max+1" (Int64.compare (Int64.add 9223372036854775807L 1L) (-9223372036854775808L) = 0);
  check "i64 mul 2^32" (Int64.compare (Int64.mul 4294967296L 4294967296L) 0L = 0);
  check "i64 mul 2^31 2^31" (Int64.compare (Int64.mul 2147483648L 2147483648L) 4611686018427387904L = 0)
let conv () =
  let l = [0; 1; -1; 2; 127; 128; 255; 256; 16383; -16384; -16383; 8192; -8193] in
  List.iter (fun n ->
    checkn "i64 of_int/to_int " n (Int64.to_int (Int64.of_int n) = n)) l;
  check "i64 of_int -1 hi" (Int64.to_int (Int64.shift_right_logical (Int64.of_int (-1)) 60) = 15);
  check "i64 of_int -1 eq" (Int64.compare (Int64.of_int (-1)) (-1L) = 0);
  check "i64 cmp 0 min" (Int64.compare 0L (-9223372036854775808L) > 0 && Int64.compare (-9223372036854775808L) 0L < 0);
  check "i64 cmp top+128" (Int64.compare 9151314442816847872L (-72057594037927936L) > 0);
  check "i64 of_int32 -1" (Int64.to_int (Int64.shift_right_logical (Int64.of_int32 (-1l)) 60) = 15);
  check "i64 of_int32 max" (Int64.compare (Int64.of_int32 2147483647l) 2147483647L = 0);
  check "i64 of_int32 min" (Int64.compare (Int64.of_int32 (-2147483648l)) (-2147483648L) = 0);
  check "i64 to_int32 trunc" (Int32.to_int (Int64.to_int32 4294967297L) = 1);
  check "i64 to_int32 neg" (Int32.compare (Int64.to_int32 (-1L)) (-1l) = 0);
  check "i64 to_int32 big" (Int32.compare (Int64.to_int32 8589934591L) (-1l) = 0)
""")
    strs = [0, 1, -1, 12345, -12345, 4294967296, 1000000007, 2**63 - 1, -2**63]
    b = ["let tostr () ="]
    for v in strs:
        b.append('  check "i64 to_string %d" (String.equal (Int64.to_string %s) %s);' % (
            v, lit(v, "L"), ostr(str(v).encode())))
    b.append("  ()\n")
    o.append("\n".join(b))
    fl = [(0.0, 0), (1.0, 1), (-1.0, -1), (2.5, 2), (-2.5, -2), (0.99, 0), (-0.99, 0),
          (255.0, 255), (65536.0, 65536), (1000000000.0, 10**9), (-1000000000.0, -10**9),
          (2147483647.0, 2**31 - 1), (-2147483648.0, -2**31), (4294967296.0, 2**32),
          (-4294967296.0, -2**32), (4294967295.0, 2**32 - 1)]
    b = ["let ofloat () ="]
    for f, v in fl:
        b.append('  check "i64 of_float %r" (Int64.compare (Int64.of_float %s) %s = 0);' % (
            f, ("(%r)" % f) if f < 0 else repr(f), lit(v, "L")))
    b.append("  ()\n")
    o.append("\n".join(b))
    m.insert(1, '  run "basic" basic;')
    m.insert(2, '  run "conv" conv;')
    m.insert(3, '  run "tostr" tostr;')
    m.insert(4, '  run "ofloat" ofloat;')
    m.append('  finish "T10B"')
    o.append("\n".join(m) + "\n")
    return "".join(o)


# ---------------------------------------------------------------------------
# T12: float
# ---------------------------------------------------------------------------
def t12():
    o = [PRELUDE]
    o.append("""let near a b = abs_float (a -. b) <= 1e-6 *. (1.0 +. abs_float b)
let ple a b = a <= b
let pge a b = a >= b
let plt a b = a < b
let pgt a b = a > b
let peq a b = a = b
let rec fsum i acc = if i = 0 then acc else fsum (i - 1) (acc +. 0.5)
let t_conv () =
  List.iter (fun n -> checkn "int_of_float(float_of_int n) " n (int_of_float (float_of_int n) = n))
    [-16384; -16383; -257; -256; -255; -129; -128; -1; 0; 1; 127; 128; 255; 256; 257; 8192; 16383]
let t_trunc () =
  check "int_of_float 2.9" (int_of_float 2.9 = 2);
  check "int_of_float 0.5" (int_of_float 0.5 = 0);
  check "int_of_float 255.99" (int_of_float 255.99 = 255);
  check "int_of_float 16383.0" (int_of_float 16383.0 = 16383);
  check "int_of_float 100.0" (int_of_float 100.0 = 100);
  (* troncamento verso zero per i negativi (FACINX/QINT arrotonda verso -inf?) *)
  check "int_of_float -2.9" (int_of_float (-2.9) = -2);
  check "int_of_float -0.5" (int_of_float (-0.5) = 0);
  check "int_of_float -255.99" (int_of_float (-255.99) = -255);
  check "int_of_float -16384.0" (int_of_float (-16384.0) = -16384)
let t_arith () =
  check "add" (0.25 +. 0.25 = 0.5);
  check "sub" (0.75 -. 0.25 = 0.5);
  check "mul" (3.0 *. 0.5 = 1.5);
  check "div" (1.0 /. 4.0 = 0.25);
  check "neg" (-. 2.0 = (-2.0));
  check "abs" (abs_float (-1.5) = 1.5 && abs_float 1.5 = 1.5);
  check "copysign" (copysign 2.0 (-1.0) = (-2.0) && copysign (-2.0) 1.0 = 2.0);
  check "floor" (floor 2.5 = 2.0 && floor (-2.5) = (-3.0) && floor 3.0 = 3.0 && floor 0.0 = 0.0);
  check "ceil" (ceil 2.5 = 3.0 && ceil (-2.5) = (-2.0) && ceil 3.0 = 3.0);
  check "float_of_int" (float_of_int 3 /. 4.0 = 0.75 && float_of_int (-3) = (-3.0));
  check "fsum" (fsum 200 0.0 = 100.0)
let t_cmp () =
  let x = 0.25 +. 0.25 and y = 0.5 *. 1.0 in
  check "eq" (x = y);
  check "not ne" (not (x <> y));
  check "le eq" (x <= y);
  check "ge eq" (x >= y);
  check "not lt eq" (not (x < y));
  check "not gt eq" (not (x > y));
  check "compare eq" (compare x y = 0);
  check "peq" (peq x y);
  check "ple eq" (ple x y);
  check "pge eq" (pge x y);
  check "not plt eq" (not (plt x y));
  check "not pgt eq" (not (pgt x y));
  let a = 1.5 +. 0.0 and b = 2.5 +. 0.0 in
  check "lt" (a < b && not (b < a));
  check "le" (a <= b && not (b <= a));
  check "gt" (b > a && not (a > b));
  check "ge" (b >= a && not (a >= b));
  check "compare" (compare a b < 0 && compare b a > 0);
  check "plt" (plt a b && not (plt b a));
  check "ple" (ple a b && not (ple b a));
  check "pgt" (pgt b a && not (pgt a b));
  check "pge" (pge b a && not (pge a b));
  let n1 = -. a and n2 = -. b in
  check "neg lt" (n2 < n1 && n1 > n2 && n2 <= n1 && n1 >= n2);
  check "neg/pos" (n1 < a && a > n1 && compare n1 a < 0);
  check "zero" (0.0 = 0.0 +. 0.0 && compare 0.0 (0.5 -. 0.5) = 0)
let t_math () =
  check "sqrt 16" (near (sqrt 16.0) 4.0);
  check "sqrt 2" (near (sqrt 2.0) 1.41421356);
  check "exp 0" (near (exp 0.0) 1.0);
  check "exp 1" (near (exp 1.0) 2.71828183);
  check "log 1" (near (log 1.0) 0.0);
  check "log 10" (near (log 10.0) 2.30258509);
  check "sin 0" (near (sin 0.0) 0.0);
  check "cos 0" (near (cos 0.0) 1.0);
  check "sin 1" (near (sin 1.0) 0.84147098);
  check "atan 1" (near (atan 1.0) 0.78539816);
  check "pow" (near (2.0 ** 10.0) 1024.0);
  check "log10" (near (log10 100.0) 2.0)
let t_frexp () =
  List.iter (fun (x, m, e) ->
    let (m1, e1) = frexp x in
    check2 "frexp mant " (int_of_float x) 0 (m1 = m);
    check2 "frexp exp " (int_of_float x) 0 (e1 = e))
    [(8.0, 0.5, 4); (1.0, 0.5, 1); (0.75, 0.75, 0); (-3.0, -0.75, 2); (0.0, 0.0, 0);
     (0.5, 0.5, 0); (100.0, 0.78125, 7); (-100.0, -0.78125, 7)]
let t_ldexp () =
  check "ldexp 1 10" (ldexp 1.0 10 = 1024.0);
  check "ldexp 1 0" (ldexp 1.0 0 = 1.0);
  check "ldexp 3 -1" (ldexp 3.0 (-1) = 1.5);
  check "ldexp 5 3" (ldexp 5.0 3 = 40.0);
  check "ldexp 0 5" (ldexp 0.0 5 = 0.0);
  check "ldexp 1 -10" (ldexp 1.0 (-10) = 0.0009765625);
  check "ldexp -1.5 2" (ldexp (-1.5) 2 = (-6.0));
  check "ldexp 1 100 inv" (ldexp 1.0 100 *. ldexp 1.0 (-100) = 1.0)
let t_str () =
  List.iter (fun (s, v) -> check ("float_of_string " ^ s) (near (float_of_string s) v))
    [("12.5", 12.5); ("-0.25", -0.25); ("100", 100.0); ("0.5", 0.5); ("3", 3.0)];
  List.iter (fun v -> check "string_of_float round" (near (float_of_string (string_of_float v)) v))
    [1.5; -0.25; 100.0; 0.001; 3.14159; 16383.0]
let t_class () =
  check "classify 0" (classify_float 0.0 = FP_zero);
  check "classify 1" (classify_float 1.0 = FP_normal);
  check "classify -7" (classify_float (-7.0) = FP_normal)
let t_box () =
  let l = [1.5; 2.5; 3.5] in
  check "fold" (List.fold_left (+.) 0.0 l = 7.5);
  let r = (1.5, 2.5) in
  check "tuple" (fst r +. snd r = 4.0);
  let a = Array.make 3 0.0 in
  a.(0) <- 1.5; a.(1) <- 2.5; a.(2) <- a.(0) +. a.(1);
  check "arr" (a.(2) = 4.0)
let () =
  run "conv" t_conv; run "trunc" t_trunc; run "arith" t_arith; run "cmp" t_cmp;
  run "math" t_math; run "frexp" t_frexp; run "ldexp" t_ldexp; run "str" t_str;
  run "class" t_class; run "box" t_box;
  finish "T12"
""")
    return "".join(o)
