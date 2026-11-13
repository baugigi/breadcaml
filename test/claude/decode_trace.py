#!/usr/bin/env python3
"""Decodifica i log del monitor di VICE (trace exec su $F1CA = CHROUT) in testo.
Uso: decode_trace.py file.log [...]   (con piu' file: stampa anche una riga di sintesi)
Charset: C64 maiuscole/grafici (default). $5F e' la freccia a sinistra (mostrata come '_').
Se il log contiene piu' esecuzioni (righe 'TRACE:'), ogni sezione e' decodificata a parte."""
import re, sys
LINE = re.compile(r'^\.C:f1ca\s+\S+\s+PHA\s+-\s+A:([0-9A-Fa-f]{2})')
LOWER = False      # charset corrente: False = maiuscole/grafici, True = minuscole/maiuscole
def char(a):
    global LOWER
    if a == 0x0E: LOWER = True;  return ''          # passa al charset minuscole/maiuscole
    if a == 0x8E: LOWER = False; return ''          # torna a maiuscole/grafici
    if a in (0x0D, 0x8D): return '\n'
    if a == 0x0A: return ''
    if a == 0x93: return '\n[CLR]\n'
    if a == 0x5F: return '_'
    if 0x41 <= a <= 0x5A: return chr(a + 32) if LOWER else chr(a)       # $41-$5A: a-z (lower) / A-Z (upper)
    if 0xC1 <= a <= 0xDA: return chr(a - 0x80) if LOWER else '<%s>' % chr(a - 0x80)  # A-Z (lower) / glifo grafico (upper)
    if 0x20 <= a <= 0x5D: return chr(a)
    return '<$%02X>' % a
def decode(path):
    global LOWER
    LOWER = False
    runs, cur = [], None
    for l in open(path, errors='replace'):
        if 'TRACE:' in l:                       # inizio di una nuova esecuzione
            cur = []; runs.append(cur)
            continue
        m = LINE.match(l)
        if m:
            if cur is None: cur = []; runs.append(cur)
            cur.append(int(m.group(1), 16))
    out = []
    for r in runs:
        LOWER = False
        out.append(''.join(char(a) for a in r))
    return out
def verdict(txt):
    t = txt.upper()
    if 'FAIL' in t: return 'FAIL'
    if 'OK' in t: return 'OK'
    return '?'
if __name__ == '__main__':
    many = len(sys.argv) > 2
    import os
    for p in sys.argv[1:]:
        sz = os.path.getsize(p)
        nrun = sum(1 for l in open(p, errors='replace') if 'TRACE:' in l)
        if sz % 8192 == 0 or (nrun and sz // max(nrun, 1) % 8192 < 64):
            print('!! ATTENZIONE: %s ha dimensione %d (multiplo di 8 KiB): probabile log TRONCATO\n'
                  '!! (ultimo blocco del buffer non scritto). Chiudere il log prima di uscire da VICE.' % (p, sz))
        for i, t in enumerate(decode(p), 1):
            print('=== %s (esecuzione %d) ===' % (p, i)); print(t.strip('\n'))
            if many: print('--> %s' % verdict(t))
