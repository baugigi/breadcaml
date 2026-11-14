#!/usr/bin/env bash
# Confronta le uscite native e interpretate dello stesso test (devono coincidere
# riga per riga, FAIL compresi: una differenza = divergenza tra i due runtime).
# Uso: ./diff_modes.sh DIR_RIS_NATIVO DIR_RIS_INTERPRETE
a=${1:?}; b=${2:?}; diffs=0
for f in "$a"/t*.txt; do
  n=$(basename "$f")
  [ -f "$b/$n" ] || { echo "$n: manca nell'altra directory"; diffs=$((diffs+1)); continue; }
  if ! diff -q <(tr '\r' '\n' <"$f") <(tr '\r' '\n' <"$b/$n") >/dev/null; then
    echo "== $n"; diff <(tr '\r' '\n' <"$f") <(tr '\r' '\n' <"$b/$n") | head -n 12; diffs=$((diffs+1))
  fi
done
echo "test con differenze nat/interp: $diffs"
