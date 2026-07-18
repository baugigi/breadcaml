#!/bin/bash
for (( i = 0; i <= 32768; i++ )); do
  echo "let pv$i = \`tag$i"
done > ppx_too_many_tags.ml


