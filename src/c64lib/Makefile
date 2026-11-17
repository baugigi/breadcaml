SHELL := /usr/bin/env bash
CONF  := ../etc/Makefile.conf
TOOLS := ../tools
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
PPX   := -ppx '$(abspath ../bin/bcamlppx) $(abspath $(PPXDB))'

OCFLAGS := -absname -nostdlib -I $(STDLIBDIR)

ASMSRC := $(wildcard asm/c64lib_*.asm)

# Prototypes of non-standard primitives (auto-generated), archived into
# libc64lib.a. c64lib.cma records "-cclib -lc64lib", so linking the library
# pulls them in.
CPROTO := c64lib__nonstd.c
LIBRUN := $(CPROTO:.c=.o)

.PHONY: all
all: lib man doc

.PHONY: lib
lib_tgt := c64.cmi c64.cmo c64lib.cma libc64lib.a
lib:
	@$(MAKE) -q $(lib_tgt) 2> /dev/null || \
	  echo '$(call message,COMPILE: ,C64 library)'
	$(MAKE) $(lib_tgt)

c64.cmi: c64.mli
	$(OCAMLC_UNSAFE) $(OCFLAGS) -c $<

c64.cmo: c64.ml c64.cmi
	$(OCAMLC_UNSAFE) $(PPX) $(OCFLAGS) -c $<

c64lib.cma: c64.cmo
	$(OCAMLC) -nostdlib -I $(STDLIBDIR) -a -cclib -lc64lib $^ -o $@

libc64lib.a: $(LIBRUN)
	rm -f $@
	ar rs $@ $^

# C prototypes for non-standard primitives
$(CPROTO): $(ASMSRC)
	{ echo '// AUTO GENERATED FILE - DO NOT EDIT'; \
	  echo '// Generated $(shell date) by $(TOOLS)/mkproto'; \
	  for f in $^; do $(TOOLS)/mkproto -p caml_nonstd_ "$$f"; done; \
	} > $@

.PHONY: man
man: .man_timestamp

.man_timestamp: c64.mli
	@echo '$(call message,GENERATE:,C64 library man pages)'
	mkdir -p man3
	$(OCAMLDOC) -hide-warnings -nostdlib -I $(STDLIBDIR) -d man3 \
	  -t "The BreadCaml Project" -man -man-mini -man-suffix $(MAN3EXT) \
	  -man-section $(MAN3EXT) $^
	touch $@

.PHONY: doc
doc: .doc_timestamp

.doc_timestamp: c64.mli
	@echo '$(call message,GENERATE:,C64 library HTML documentation)'
	mkdir -p html
	$(OCAMLDOC) -hide-warnings -nostdlib -I $(STDLIBDIR) -d html \
	  -html -charset utf-8 -colorize-code -sort \
	  -t "The BreadCaml Project" $^
	touch $@

.PHONY: clean
clean:
	rm -f *.{cmi,cmo,cma,o,a} $(CPROTO) $(PPXDB) .{man,doc}_timestamp
	rm -rf man3 html
