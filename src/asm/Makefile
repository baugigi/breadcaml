#  ——————————————————————————————————————————————————————————————————————
#  Progetto BreadCaml / The BreadCaml Project
#  Copyright (C) 21-Apr-2026 Piero Furiesi
#  
#  Questo  programma  è software  libero;  può  essere ridistribuito  e/o
#  modificato nei termini della GNU GENERAL PUBLIC LICENSE (GPL) versione
#  2, come specificato nel file  LICENZA-it nella cartella principale del
#  progetto.
#  
#  This program is  free software; you can redistribute  it and/or modify
#  it under the terms of the  GNU GENERAL PUBLIC LICENSE (GPL) version 2,
#  as specified in the LICENSE-en file in the project root folder.
#  ——————————————————————————————————————————————————————————————————————
SHELL := /bin/bash
CONF  := ../../etc/Makefile.conf
include $(if $(wildcard $(CONF)),$(CONF),$(error \
	Please run «./configure [options...]» from the main source directory))

.PHONY: asm
asm:
	@$(MAKE) -q stdlib.asm 2> /dev/null || \
	  $(call message,GENERATE:,Assembly routines)
	$(MAKE) stdlib.asm

# Assembly sources: the standard library ones, plus the C64 library ones
# (../../c64lib/asm/c64lib_*.asm), all installed in $(LIBDIR)
C64ASM := $(wildcard ../../c64lib/asm/c64lib_*.asm)
ASMSRC := $(wildcard stdlib_*.asm) $(C64ASM)

stdlib.asm: depends.asm $(ASMSRC)
	{ echo ';; AUTO-GENERATED FILE - DO NOT EDIT'; \
	  echo -n 'caml_stdlib'; \
	  echo -e '$(patsubst %,\n\t!source "$(LIBDIR)/%",$(notdir $^))'; \
	  echo 'caml_stdlib_end'; \
	} > $@

depends.asm: $(ASMSRC)
	../../tools/mkdepends $@ $^

.PHONY: clean
clean:
	rm -f stdlib.asm depends.asm
