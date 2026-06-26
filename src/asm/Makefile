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

SHELL = /bin/bash
CONF = ../../etc/Makefile.conf

include $(if $(wildcard $(CONF)),$(CONF),$(error \
	Please run «./configure [options...]» from the main source directory))

stdlib.asm: depends.asm stdlib_*.asm
	echo -e "\
	;; AUTO-GENERATED FILE - DO NOT EDIT\n\
	caml_stdlib\n\
	 $(patsubst %,!source \"$(LIBDIR)/%\"\n,$^)\
	caml_stdlib_end" > $@

.PHONY: clean
clean:
	rm -f stdlib.asm

.PHONY: gitclean
gitclean: clean
	rm -f *~

