#!/usr/bin/env bash
# Legge i risultati di un'esecuzione: una directory con un file NOME.txt per
# test (output catturato dall'emulatore). print_newline emette CR ('\013'),
# quindi i CR vengono convertiti in LF prima dell'analisi.
# Uso: ./check_results.sh DIR_RISULTATI
d=${1:?uso: check_results.sh DIR}
ok=0; ko=0; miss=0
for f in tests/t*.ml; do
  n=$(basename "$f" .ml); r="$d/$n.txt"
  if [ ! -s "$r" ]; then
    # nessun output: se esiste il log di build, mostra il primo errore
    l="$d/$n.log"; e=""
    [ -s "$l" ] && e=$(grep -m1 -E '^(Error|BreadCaml> Error)' "$l")
    if [ -n "$e" ]; then printf '%-22s ERRORE DI BUILD: %s\n' "$n" "$e"
    else printf '%-22s NESSUN OUTPUT\n' "$n"; fi
    miss=$((miss+1)); continue
  fi
  # Righe utili: CR -> LF, via righe vuote e il prompt del monitor ("ready.")
  body=$(tr '\r' '\n' <"$r" | sed -e '/^[[:space:]]*$/d' -e '/^ready\.$/d')
  # Riga di esito: "<etichetta> OK" o "<etichetta> FAIL" (T01A, d_cmp, 10_10, ...)
  last=$(printf '%s\n' "$body" | grep -E '^[A-Za-z0-9_]+ (OK|FAIL)$' | tail -n 1)
  if [[ "$last" =~ ^[A-Za-z0-9_]+\ OK$ ]]; then ok=$((ok+1))
  else
    ko=$((ko+1)); printf '%-22s %s\n' "$n" "${last:-$(printf '%s\n' "$body" | tail -n 1)}"
    printf '%s\n' "$body" | grep '^FAIL' | head -n "${MAXFAIL:-8}" | sed 's/^/        /'
  fi
done
echo "OK: $ok   FAIL/anomali: $ko   senza output: $miss"
