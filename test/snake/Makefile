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

PRG = snake
DEPENDS = iOtools
EXTERNS = iOtools.asm

SHELL = /bin/bash
SED_GENC = s/^[ \t]*\(IOtools_[a-zA-Z0-9_]*\)/void \1 () {}/p

CMO := $(DEPENDS:=.cmo)
CMI := $(DEPENDS:=.cmi)
C := $(EXTERNS:.asm=.c)

$(PRG:=.prg): $(CMO) $(EXTERNS) $(C) $(PRG:=.ml)
#	o64ml -interp -showmem $^ -- -r snake.txt
	o64ml -showmem $^ -- -r snake.txt

%.cmo: %.ml %.cmi
	o64ml -c $<

%.cmi: %.mli
	o64ml -c $<

%.o: %.c
	cc -o $@ -c $<

%.c: %.asm
	sed -n -e '$(SED_GENC)' $< > $@

.PHONY: clean
clean:
	rm snake.prg snake.asm snake.txt *.byte *.c* *.o &> /dev/null || true

.PHONY: merlin
merlin: $(CMI)
	@echo -ne "\
	STDLIB $(shell o64ml -where)\n\
	S .\n\
	B .\n\
	" > .$@
