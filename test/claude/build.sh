#!/usr/bin/env bash
# Compila ogni test con bcamlopt (nativo) e bcamlc (bytecode+interprete).
# Uso: ./build.sh [dir_tests] [dir_out]
# Variabili d'ambiente (adattare ai flag reali del progetto):
#   BCAMLOPT / BCAMLC   eseguibili        (default: bcamlopt / bcamlc)
#   OPTFLAGS / BCFLAGS  flag aggiuntivi
#   OPTOUT / BCOUT      come passare il nome di output (default "-o"); va PRIMA del sorgente
#   EXT_NAT / EXT_BC    estensione dei risultati (default prg)
#   STACKCONF           file con righe "nome_test [flag extra]" (default stack.conf, accanto a build.sh):
#                       i flag (es. -stack 16) sono aggiunti a bcamlopt e bcamlc per quel test
tests=${1:-tests}; out=${2:-build}
: "${BCAMLOPT:=bcamlopt}" "${BCAMLC:=bcamlc}" "${OPTOUT:=-o}" "${BCOUT:=-o}"
: "${EXT_NAT:=prg}" "${EXT_BC:=prg}"
mkdir -p "$out/nat" "$out/bc"
: "${STACKCONF:=$(dirname "$0")/stack.conf}"
fail=0
for f in "$tests"/t*.ml; do
  n=$(basename "$f" .ml)
  extra=""
  [ -f "$STACKCONF" ] && extra=$(awk -v n="$n" '$1 !~ /^#/ && $1 == n { $1=""; print }' "$STACKCONF")
  if ! $BCAMLOPT $OPTFLAGS $extra $OPTOUT "$out/nat/$n.$EXT_NAT" "$f" >"$out/nat/$n.log" 2>&1; then
    echo "NAT BUILD FAIL: $n   (vedi $out/nat/$n.log)"; fail=$((fail+1)); fi
  if ! $BCAMLC   $BCFLAGS  $extra $BCOUT  "$out/bc/$n.$EXT_BC" "$f"  >"$out/bc/$n.log"  2>&1; then
    echo "BC  BUILD FAIL: $n   (vedi $out/bc/$n.log)"; fail=$((fail+1)); fi
done
echo "build terminata: $fail errori"
