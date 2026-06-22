# ——————————————————————————————————————————————————————————————————————
# Progetto BreadCaml / The BreadCaml Project
# Copyright (C) 2026 Piero Furiesi
#
# Questo  programma è  software  libero; è  possibile ridistribuirlo  e/o
# modificarlo secondo  i termini della  GNU General Public  License (GPL)
# versione  2,  come  specificato  nel file  LICENZA-it  nella  directory
# principale del progetto.
#
# This program is  free software; you can redistribute  it and/or modify
# it under the terms of the  GNU General Public License (GPL) version 2,
# as specified in the LICENSE-en file in the project root.
# ——————————————————————————————————————————————————————————————————————

FILES := largeArray.asm largeArray.c largeArray.mli largeArray.ml test.ml

.PHONY: all
all:	clean
	o64ml $(FILES)

.PHONY: interp
interp:	clean
	o64ml $(FILES) -- -Dcaml_INTERP=1

.PHONY: debug
debug:	clean
	o64ml $(FILES) -- -Dcaml_INTERP=1 -Dcaml_DEBUG=1

.PHONY: clean
clean:
	rm -f test.asm *.prg *.cmi *.cmo *.o *.byte


