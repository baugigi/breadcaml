# Utilita' comuni per il generatore dei test BreadCaml.
# Gli interi OCaml sul C64 sono a 15 bit: -16384 .. 16383 (Sys.int_size = 15).

PRELUDE = r'''(* ---- prelude comune (generato da gen_tests.py) ---- *)
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
'''

def w15(x):
    """wrap a intero con segno a 15 bit (semantica degli int sul C64)"""
    return ((x + 16384) & 0x7FFF) - 16384

def tdiv(a, b):
    """divisione troncata verso zero (semantica C / OCaml)"""
    q = abs(a) // abs(b)
    return q if (a < 0) == (b < 0) else -q

def tmod(a, b):
    return a - b * tdiv(a, b)

def oi(n):
    """letterale intero OCaml, parentesi se negativo"""
    return str(n) if n >= 0 else "(%d)" % n

def ostr(b):
    """letterale stringa OCaml da bytes, con escape decimali"""
    out = []
    for c in b:
        if 32 <= c < 127 and c not in (34, 92):
            out.append(chr(c))
        else:
            out.append("\\%03d" % c)
    return '"' + "".join(out) + '"'

def sgn(x):
    return -1 if x < 0 else (1 if x > 0 else 0)

def arr(items):
    return "[| " + "; ".join(items) + " |]"

def sample(n, extra=()):
    """indici di interesse in [0,n): inizio, primi, meta', ultimi"""
    s = {0, 1, 2, 3, 4, n // 2, n - 3, n - 2, n - 1}
    s.update(extra)
    return sorted(i for i in s if 0 <= i < n)
