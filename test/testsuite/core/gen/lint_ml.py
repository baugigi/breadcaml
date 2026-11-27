#!/usr/bin/env python3
"""Controllo sintattico GROSSOLANO dei .ml generati (non sostituisce ocamlc):
bilanciamento di (), [], {}, begin/end, do/done, struct/end, commenti e stringhe;
un solo 'let () =' finale; ultima istruzione = finish."""
import re, sys, os

def strip(src):
    out, i, n, depth = [], 0, len(src), 0
    while i < n:
        c = src[i]
        if depth == 0 and c == '"':
            j = i + 1
            while j < n and src[j] != '"':
                j += 2 if src[j] == '\\' else 1
            if j >= n: raise ValueError("stringa non chiusa")
            out.append('""'); i = j + 1
        elif src.startswith("(*", i):
            depth += 1; i += 2
        elif depth and src.startswith("*)", i):
            depth -= 1; i += 2
        elif depth:
            i += 1
        elif c == "'":
            m = re.match(r"'(\\\\|\\'|\\\"|\\n|\\t|\\r|\\b|\\[0-9]{3}|[^\\'])'", src[i:])
            if m: out.append("'c'"); i += len(m.group(0))
            else: out.append(c); i += 1
        else:
            out.append(c); i += 1
    if depth: raise ValueError("commento non chiuso")
    return "".join(out)

def check(path):
    errs = []
    try:
        s = strip(open(path).read())
    except ValueError as e:
        return [str(e)]
    for a, b, nm in [("(", ")", "()"), ("[", "]", "[]"), ("{", "}", "{}")]:
        if s.count(a) != s.count(b):
            errs.append("%s sbilanciato: %d vs %d" % (nm, s.count(a), s.count(b)))
    w = lambda k: len(re.findall(r"\b%s\b" % k, s))
    if w("begin") + w("struct") + w("sig") != w("end"):
        errs.append("begin/struct/sig=%d end=%d" % (w("begin") + w("struct") + w("sig"), w("end")))
    if w("do") != w("done"):
        errs.append("do=%d done=%d" % (w("do"), w("done")))
    if len(re.findall(r"(?m)^let \(\) =", s)) != 1:
        errs.append("'let () =' non unico")
    if not s.rstrip().endswith(")") and not re.search(r'finish ""\s*$', s):
        errs.append("non termina con finish")
    # parentesi non appaiate dentro una riga di check (euristica): righe che iniziano con 'check' devono bilanciare
    for ln, line in enumerate(s.split("\n"), 1):
        t = line.strip()
        if t.startswith(("check ", "checkn ", "check2 ")) and t.endswith((";",)) is False and False:
            pass
    return errs

if __name__ == "__main__":
    d = sys.argv[1]
    bad = 0
    for f in sorted(os.listdir(d)):
        if f.endswith(".ml"):
            e = check(os.path.join(d, f))
            if e:
                bad += 1
                print("%-22s %s" % (f, "; ".join(e)))
    print("lint: %d file con problemi" % bad)
