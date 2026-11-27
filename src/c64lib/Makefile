#  ——————————————————————————————————————————————————————————————————————
#  The BreadCaml Project / Progetto BreadCaml
#  Copyright (C) 21-Apr-2026 Piero Furiesi
#  
#  This program is  free software; you can redistribute  it and/or modify
#  it under the terms of the  GNU GENERAL PUBLIC LICENSE (GPL) version 2,
#  as specified in the LICENSE-en file in the project root folder.
#  
#  Questo  programma  è software  libero;  può  essere ridistribuito  e/o
#  modificato nei termini della GNU GENERAL PUBLIC LICENSE (GPL) versione
#  2, come specificato nel file  LICENZA-it nella cartella principale del
#  progetto.
#  ——————————————————————————————————————————————————————————————————————
SHELL := /bin/bash
CONF  := ../../etc/Makefile.conf
TOOLS := ../../tools
include $(if $(wildcard $(CONF)),$(CONF),$(error \
	Please run «./configure [options...]» from the main source directory))

# C64.* : the Commodore 64 specific library (NOT part of the OCaml standard
# library, hence not in src/stdlib). Programs link it explicitly:
#       bcamlopt c64lib.cma prog.ml        (or bcamlc ...)
# The Assembly primitives are in asm/c64lib_*.asm; src/asm/Makefile merges
# them into stdlib.asm, so that the dependency resolution works across files.

STDLIBDIR := ../stdlib

# The BreadCaml preprocessor translates char and string literals to PETSCII
# (see src/stdlib/Makefile).
PPXDB := c64lib.db
PPX   := -ppx '$(abspath ../../bin/bcamlppx) $(abspath $(PPXDB))'

OCFLAGS := -absname -nostdlib -I $(STDLIBDIR)

ASMSRC := $(wildcard asm/c64lib_*.asm)

# Prototypes of non-standard primitives (auto-generated), archived into
# libc64lib.a. c64lib.cma records "-cclib -lc64lib", so linking the library
# pulls them in.
CPROTO := c64lib__nonstd.c
LIBRUN := $(CPROTO:.c=.o)

.PHONY: all
all: lib man doc

# One compilation unit per submodule (C64_hw, C64_screen, ...): ocamlclean
# works on whole units, so a program that uses a single function of C64.Screen
# does not carry along the other submodules. C64 itself (c64.ml/c64.mli) is
# only a facade made of module aliases: C64.Screen is C64_screen.
UNITS := c64_hw c64_key c64_screen c64_gfx c64_sprite c64_sound c64_mcu \
         c64_disk c64_sd2iec c64
MLIS  := $(UNITS:=.mli)

.PHONY: lib
lib_tgt := $(UNITS:=.cmi) $(UNITS:=.cmo) c64lib.cma libc64lib.a
lib:
	@$(MAKE) -q $(lib_tgt) 2> /dev/null || \
	  $(call message,COMPILE: ,C64 library)
	$(MAKE) $(lib_tgt)

%.cmi: %.mli
	$(OCAMLC_UNSAFE) $(OCFLAGS) -c $<

%.cmo: %.ml %.cmi
	$(OCAMLC_UNSAFE) $(PPX) $(OCFLAGS) -c $<

# dependencies among the units (aliases need the .cmi of the target)
c64_screen.cmo c64_screen.cmi c64_gfx.cmo c64_gfx.cmi c64_sound.cmo \
  c64_sound.cmi c64_mcu.cmo c64_mcu.cmi c64_disk.cmo c64_disk.cmi: c64_hw.cmi
c64_sprite.cmo c64_sprite.cmi: c64_hw.cmi c64_gfx.cmi
c64_sd2iec.cmo c64_sd2iec.cmi: c64_hw.cmi c64_disk.cmi
c64.cmo c64.cmi: $(filter-out c64.cmi,$(UNITS:=.cmi))
c64_sprite.cmo: c64_gfx.cmo
c64_screen.cmo c64_gfx.cmo c64_sound.cmo c64_mcu.cmo c64_disk.cmo: c64_hw.cmo
c64_sd2iec.cmo: c64_disk.cmo

c64lib.cma: $(UNITS:=.cmo)
	$(OCAMLC) -nostdlib -I $(STDLIBDIR) -a -cclib -lc64lib $^ -o $@

libc64lib.a: $(LIBRUN)
	rm -f $@
	ar rsc $@ $^

# C prototypes for non-standard primitives
$(CPROTO): $(ASMSRC)
	{ echo '// AUTO GENERATED FILE - DO NOT EDIT'; \
	  echo '// Generated $(shell date) by $(TOOLS)/mkproto'; \
	  for f in $^; do $(TOOLS)/mkproto -p caml_nonstd_ "$$f"; done; \
	} > $@

.PHONY: man
man: .man_timestamp

.man_timestamp: $(MLIS)
	@$(call message,GENERATE:,C64 library man pages)
	mkdir -p man3
	$(OCAMLDOC) -hide-warnings -nostdlib -I $(STDLIBDIR) -d man3 \
	  -t "The BreadCaml Project" -man -man-mini -man-suffix $(MAN3EXT) \
	  -man-section $(MAN3EXT) $^
	touch $@

.PHONY: doc
doc: .doc_timestamp

.doc_timestamp: $(MLIS)
	@$(call message,GENERATE:,C64 library HTML documentation)
	mkdir -p html
	$(OCAMLDOC) -hide-warnings -nostdlib -I $(STDLIBDIR) -d html \
	  -html -charset utf-8 -colorize-code -sort \
	  -t "The BreadCaml Project" $^
	touch $@

.PHONY: clean
clean:
	rm -f *.{cmi,cmo,cma,o,a} $(CPROTO) $(PPXDB) .{man,doc}_timestamp
	rm -rf man3 html
