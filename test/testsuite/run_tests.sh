#!/usr/bin/env bash
# Batteria di test BreadCaml: compila (bcamlopt e/o bcamlc), esegue su VICE, verifica gli esiti.
#
# Uso: ./run_tests.sh [-m nat|bc|both] [-s suite,...] [-k regex] [-o dir_out] [-j N] [-i] [-l]
#   -m  modalita': nat (bcamlopt), bc (bcamlc + interprete), both (default)
#   -s  suite: core, diag, ocamlclean, c64lib, bank, petscii, examples, gcsc (core con -gc stop_and_copy), ppx, heapsz (default: tutte). 'core' = core/tests
#   -k  esegue solo i test il cui nome corrisponde alla regex
#   -o  directory dei risultati (default: ./results)
#   -j  numero di VICE in parallelo (default 1)
#   -i  VICE ridotto a icona (aggiunge -minimized a VICE_OPTS)
#   -l  elenca i test e termina
# Ambiente: X64 (default x64sc), VICE_OPTS (opzioni extra, es. "-console" o "+sound"),
#           BCAMLOPT / BCAMLC (default bcamlopt / bcamlc), STALL (s senza output prima di dichiarare un hang, 90).
# Esito per test: OK | FAIL | XFAIL (fallimento atteso, vedi expected.conf) | XPASS (atteso ma passa)
#                 | BUILD-FAIL | XBUILD (errore di build atteso) | NOVERDICT (nessun verdetto: hang/timeout)
# Exit code: 0 se non ci sono esiti inattesi (FAIL, BUILD-FAIL, NOVERDICT) ne' differenze nat/bc.
HERE="$(cd "$(dirname "$0")" && pwd)"
export HERE
export X64="${X64:-x64sc}" BCAMLOPT="${BCAMLOPT:-bcamlopt}" BCAMLC="${BCAMLC:-bcamlc}"

suite_dir() { case $1 in core|gcsc) echo tests;; diag) echo diag;; ocamlclean) echo ocamlclean;; *) echo tests;; esac; }
suite_base() { case $1 in core|diag|ocamlclean|gcsc) echo core;; *) echo $1;; esac; }

# ---- modo interno: un singolo test (invocato da xargs) -------------------------------------
if [ "$1" = "--one" ]; then
  suite=$2; mode=$3; src=$4; out=$5
  n=$(basename "$src" .ml); base=$HERE/$(suite_base "$suite")
  d=$out/$suite/$mode; mkdir -p "$d"
  if [ $mode = nat ]; then CC=$BCAMLOPT; else CC=$BCAMLC; fi
  extra=$(awk -v n="$n" '$1 !~ /^#/ && $1 == n { $1=""; print }' "$base/stack.conf" 2>/dev/null)
  for f in "$base"/*.asm "$base"/*.c; do [ -f "$f" ] && ln -sf "$f" "$d/"; done   # primitive custom (bank)
  [ "$suite" = gcsc ] && extra="$extra -gc stop_and_copy"
  lib=""; grep -qE "open C64|C64\.|\b(Disk|Sd2iec)\." "$src" 2>/dev/null && lib="c64lib.cma"
  rm -f "$d/$n".{prg,txt,raw,build}
  if ! (cd "$d" && $CC $extra -o "$n.prg" $lib "$src" >"$n.build" 2>&1); then st=BUILD-FAIL
  else
    python3 -I "$HERE/tools/vrun.py" "$d/$n.prg" "$d/$n.raw" >/dev/null 2>&1
    [ -f "$d/$n.raw" ] && python3 -I "$HERE/tools/decode_trace.py" "$d/$n.raw" | tr '\r' '\n' > "$d/$n.txt"
    v=$(grep -aE '^([A-Za-z0-9_]+ (OK|FAIL)|FAILED)$' "$d/$n.txt" 2>/dev/null | tail -1)
    case "$v" in *" OK") st=OK;; *" FAIL"|FAILED) st=FAIL;; *) st=NOVERDICT;; esac
  fi
  # fallimenti attesi
  x=$(awk -v k="$suite/$n" -v m="$mode" '$1 !~ /^#/ && $1==k && ($2==m || $2=="*") {print "x"; exit}' "$HERE/expected.conf")
  if [ -n "$x" ]; then case $st in OK) st=XPASS;; BUILD-FAIL) st=XBUILD;; *) st=XFAIL;; esac; fi
  printf '%-10s %-3s %-26s %s\n' "$suite" "$mode" "$n" "$st"
  echo "$st" > "$d/$n.status"
  exit 0
fi

mode=both; suites="core diag ocamlclean c64lib bank petscii examples gcsc ppx heapsz"; pat=.; out=./results; jobs=1; list=0
while getopts "m:s:k:o:j:li" o; do case $o in
  m) mode=$OPTARG;; s) suites=${OPTARG//,/ };; k) pat=$OPTARG;; o) out=$OPTARG;; j) jobs=$OPTARG;; l) list=1;; i) export VICE_OPTS="$VICE_OPTS -minimized";; *) exit 2;; esac; done
out=$(mkdir -p "$out" && cd "$out" && pwd)
[ $mode = both ] && modes="nat bc" || modes=$mode

if [ $list = 0 ]; then
  command -v "$X64" >/dev/null || { echo "VICE ($X64) non trovato: impostare X64" >&2; exit 2; }
  command -v "$BCAMLOPT" >/dev/null || { echo "$BCAMLOPT non trovato nel PATH" >&2; exit 2; }
fi
jobfile=$(mktemp)
for s in $suites; do
  [ $s = ppx ] && continue
  [ $s = heapsz ] && continue
  for m in $modes; do
    for f in "$HERE/$(suite_base $s)/$(suite_dir $s)"/*.ml; do
      n=$(basename "$f" .ml); echo "$n" | grep -Eq "$pat" || continue
      [ $s = gcsc ] && { grep -qx "$n" "$HERE/core/gcsc.list" || continue; }
      if [ $list = 1 ]; then echo "$s $m $n"; else printf '%s\0%s\0%s\0%s\0' "$s" "$m" "$f" "$out"; fi
    done
  done
done > "$jobfile"
[ $list = 1 ] && { cat "$jobfile"; rm -f "$jobfile"; exit 0; }
: > "$out/summary.txt"
[ -s "$jobfile" ] && xargs -0 -n4 -P "$jobs" "$0" --one < "$jobfile" | tee -a "$out/summary.txt"
rm -f "$jobfile"

# ---- ppx: solo compilazione dei sorgenti con token PETSCII/varianti; un file NOME.expect indica un test
# ---- negativo: la compilazione deve fallire con un messaggio che contiene il testo di NOME.expect --------
for s in $suites; do [ $s = ppx ] || continue
  for m in $modes; do
    [ $m = nat ] && CC=$BCAMLOPT || CC=$BCAMLC
    w="$out/ppx/$m"; mkdir -p "$w"
    for f in "$HERE"/examples/ppx/*.ml "$HERE"/examples/ppx/*.ml.bz2; do
      [ -f "$f" ] || continue
      n=$(basename "$f"); n=${n%.bz2}; n=${n%.ml}; echo "$n" | grep -Eq "$pat" || continue
      src="$f"; case "$f" in *.bz2) src="$w/$n.ml"; bzcat "$f" > "$src";; esac
      (cd "$w" && $CC -c "$src" >"$n.build" 2>&1); rc=$?
      if [ -f "$HERE/examples/ppx/$n.expect" ]; then        # test negativo
        if [ $rc != 0 ] && grep -qF "$(cat "$HERE/examples/ppx/$n.expect")" "$w/$n.build"; then st=OK; else st=FAIL; fi
      else [ $rc = 0 ] && st=OK || st=BUILD-FAIL; fi
      x=$(awk -v k="ppx/$n" -v m="$m" '$1 !~ /^#/ && $1==k && ($2==m || $2=="*") {print "x"; exit}' "$HERE/expected.conf")
      [ -n "$x" ] && { case $st in OK) st=XPASS;; BUILD-FAIL) st=XBUILD;; *) st=XFAIL;; esac; }
      printf '%-10s %-3s %-26s %s\n' ppx $m "$n" "$st" | tee -a "$out/summary.txt"
    done
  done
done

# ---- heapsz: build-only. Lo stesso programma con 0..71 globali in piu' (2 byte ciascuno) per coprire tutte le
# ---- dimensioni del programma modulo 144 (heap mark&compact: la tabella BAM deve sempre stare nello heap) --
for s in $suites; do [ $s = heapsz ] || continue
  for m in $modes; do
    [ $m = nat ] && CC=$BCAMLOPT || CC=$BCAMLC
    w="$out/heapsz/$m"; mkdir -p "$w"; bad=0; tot=0
    for k in $(seq 0 71); do
      n=hs$k; echo "$n" | grep -Eq "$pat" || continue
      { echo 'let () = print_string "x"; print_newline ()'
        for i in $(seq 1 $k); do echo "let g$i = ref $i"; done; } > "$w/$n.ml"
      tot=$((tot+1))
      (cd "$w" && $CC -o $n.prg $n.ml >$n.build 2>&1) || { bad=$((bad+1)); echo "heapsz $m $n: $(grep -m1 -a Error "$w/$n.build")"; }
      rm -f "$w/$n.prg" "$w/$n.db"
    done
    [ $bad = 0 ] && st=OK || st=BUILD-FAIL
    [ $tot -gt 0 ] && printf '%-10s %-3s %-26s %s\n' heapsz $m "variants_$tot" "$st" | tee -a "$out/summary.txt"
  done
done

# ---- riepilogo -------------------------------------------------------------------------------
echo; echo "=== Riepilogo ($out/summary.txt) ==="
awk '{c[$4]++} END{for(k in c) printf "  %-11s %d\n", k, c[k]}' "$out/summary.txt" | sort
bad=$(awk '$4=="FAIL"||$4=="BUILD-FAIL"||$4=="NOVERDICT"' "$out/summary.txt")
xp=$(awk '$4=="XPASS"' "$out/summary.txt"); [ -n "$xp" ] && { echo "--- attesi in errore ma passano (togliere da expected.conf):"; echo "$xp"; }
[ -n "$bad" ] && { echo "--- esiti inattesi:"; echo "$bad"; }
# nat e interprete devono dare output identici
nd=0
if [ $mode = both ]; then
  for s in $suites; do [ $s = ppx ] && continue; [ $s = heapsz ] && continue
    for f in "$out/$s/nat"/*.txt; do [ -f "$f" ] || continue
      n=$(basename "$f"); g="$out/$s/bc/$n"; [ -f "$g" ] || continue
      if ! diff -q <(grep -avE '^(SEARCHING|LOADING|===)|^(r|re|rea|read|ready|ready\.|[[:space:]]*)$' "$f") <(grep -avE '^(SEARCHING|LOADING|===)|^(r|re|rea|read|ready|ready\.|[[:space:]]*)$' "$g") >/dev/null; then
        echo "differenza nat/bc: $s/${n%.txt}"; nd=$((nd+1)); fi
    done
  done
  echo "test con differenze nat/bc: $nd"
fi
[ -z "$bad" ] && [ $nd = 0 ]
