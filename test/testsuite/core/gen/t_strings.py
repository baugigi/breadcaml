from common import *

# ---------------------------------------------------------------------------
# T04: stringhe di 0..509 byte (size = 1..255 parole), confronti, padding
# ---------------------------------------------------------------------------
def t04():
    o = [PRELUDE]
    lens = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 125, 126, 127, 128, 129, 252, 253,
            254, 255, 256, 257, 258, 506, 507, 508, 509]
    o.append("let lens = %s\n" % arr(map(str, lens)))
    o.append('''let test_len n =
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
''')
    pool = [b"", b"a", b"b", b"aa", b"ab", b"ba", b"abc", b"abd", b"a\x00", b"ab\x00",
            b"\x7f", b"\x80", b"\xff", b"aaaa", b"aaab", b"x" * 7, b"x" * 8, b"x" * 9,
            bytes(range(97, 117)), b"\x00", b"\x00\x00"]
    m = len(pool)
    e = ""
    for a in pool:
        for b in pool:
            e += "<" if a < b else (">" if a > b else "=")
    assert len(e) <= 509
    o.append("let pool = %s\n" % arr(ostr(p) for p in pool))
    o.append("let pool2 = Array.init %d (fun i -> Bytes.to_string (Bytes.of_string pool.(i)))\n" % m)
    o.append("let pexp = %s\n" % ostr(e.encode()))
    o.append('''let test_pool () =
  for i = 0 to %d do
    for j = 0 to %d do
      let a = pool.(i) and b = pool2.(j) in
      let e = String.get pexp (i * %d + j) in
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
''' % (m - 1, m - 1, m))
    # string_of_int: formato C64 (spazio o '-', max 5 cifre, niente zeri iniziali)
    vals = [0, 1, 9, 10, 11, 99, 100, 101, 999, 1000, 1001, 9999, 10000, 10001, 16383,
            -1, -9, -10, -99, -100, -999, -1000, -9999, -10000, -16383, -16384]
    b = ["let test_soi () ="]
    for v in vals:
        s = (" " if v >= 0 else "-") + str(abs(v))
        b.append('  check "soi %d" (String.equal (string_of_int %s) %s);' % (v, oi(v), ostr(s.encode())))
    b.append("  ()\n")
    o.append("\n".join(b))
    o.append('''let () =
  for i = 0 to %d do run "len" (fun () -> test_len lens.(i)) done;
  run "make_err" test_make_err;
  List.iter (fun n -> run "pattern" (fun () -> test_pattern n)) [255; 256; 257; 300; 508; 509];
  run "pool" test_pool;
  run "soi" test_soi;
  finish "T04"
''' % (len(lens) - 1))
    return "".join(o)
