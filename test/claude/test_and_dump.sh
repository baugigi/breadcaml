#!/usr/bin/env bash
# Esegue tutti i .prg di una directory su VICE (x64sc), registra le chiamate a CHROUT ($F1CA)
# e le decodifica in testo (<test>.txt) con decode_trace.py.
# Uso: test_and_dump.sh <test_dir>      Variabili: X64 (default x64sc), TMO (timeout in s, default 120)
[ -n "$1" ] || { echo "Usage: $0 <test_dir>" >&2; exit 1; }
HERE="$(cd "$(dirname "$0")" && pwd)"
X64="${X64:-x64sc}"
TMO="${TMO:-120}"
MON="$HERE/test_init.mon"
for test in "$1"/*.prg; do
    base="${test%.prg}"
    echo "Esecuzione di: $test..."
    rm -f "${base}_raw.log"
    # test_init.mon ferma il programma al ritorno a BASIC ($A480, dopo READY), chiude il log
    # (log off => flush) ed esce da VICE (quit). Il timeout e' solo una rete di sicurezza:
    # se scatta, VICE viene ucciso senza flush e il log risulta TRONCATO.
    timeout -k 5s "${TMO}s" "$X64" -warp -autostart "$test" -minimized \
            -moncommands "$MON" -monlogname "${base}_raw.log"
    rc=$?
    [ $rc -eq 124 ] && echo "  ATTENZIONE: timeout (${TMO}s): log probabilmente troncato (hang o test lento?)"
    if [ -f "${base}_raw.log" ]; then
        python3 "$HERE/decode_trace.py" "${base}_raw.log" > "${base}.txt"
        # sintesi: ultima riga non vuota dell'ultima esecuzione + verdetto
        tail -n 3 "${base}.txt" | sed 's/^/  | /'
    else
        echo "  nessun log prodotto"
    fi
done
