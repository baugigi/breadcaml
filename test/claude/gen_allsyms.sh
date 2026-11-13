#!/usr/bin/env bash
# Uso: gen_allsyms.sh dir_runtime > allsyms.asm
# Estrae da *.asm tutti i simboli caml_gen_/caml_PRIM__/caml_AUX__ usati in !ifdef/!ifndef.
d=${1:-.}
echo ";; allsyms.asm generato da gen_allsyms.sh - includere prima del runtime"
cat "$d"/*.asm | grep -oE '!(ifdef|ifndef)[[:space:]]+(caml_gen_|caml_PRIM__|caml_AUX__)[A-Za-z0-9_]*' \
  | awk '{print $2}' | sort -u | sed 's/.*/!set & = 1/'
