SHELL := /usr/bin/env bash
CONF  := ../../etc/Makefile.conf
TOOLS := ../../tools
include $(if $(wildcard $(CONF)),$(CONF),$(error \
	Please run «./configure [options...]» from the main source directory))

lcase = $(shell echo $(1)|sed -Ee "s/([A-Z])(.*)/\l\1\2/")
ucase = $(shell echo $(1)|sed -Ee "s/([a-z])(.*)/\u\1\2/")

# Original list of module basenames for the OCaml standard library
# (SORTED BY DEPENDENCIES)
STDLIB_MODULE_BASENAMES := camlinternalFormatBasics camlinternalAtomic stdlib \
  pervasives either sys obj camlinternalLazy lazy seq option result bool char \
  uchar list int bytes string unit marshal array float int32 int64 nativeint  \
  lexing parsing set map stack queue stream buffer camlinternalFormat printf  \
  arg atomic printexc fun gc digest random hashtbl weak format scanf callback \
  camlinternalOO oo camlinternalMod genlex ephemeron filename complex         \
  arrayLabels listLabels bytesLabels stringLabels moreLabels stdLabels        \
  bigarray in_channel out_channel std_exit

# Modules removed in BreadCaml
REMOVED := arg atomic bigarray callback camlinternalAtomic camlinternalFormat \
  camlinternalFormatBasics camlinternalOO digest ephemeron filename format    \
  fun gc genlex in_channel lexing marshal nativeint oo out_channel parsing    \
  pervasives printexc printf scanf stream uchar weak

BASENAMES := $(filter-out $(REMOVED),$(STDLIB_MODULE_BASENAMES))

PFX := stdlib__
NOPFX := camlinternal% stdlib std_exit
LIB := $(foreach F,$(BASENAMES),$(if $(filter $(NOPFX),$(F)),,$(PFX))$(F))

CMI := $(LIB:=.cmi)
CMO := $(LIB:=.cmo)

# Prototypes of non-standard primitives (auto-generated)
CPROTO := stdlib__nonstd.c

# Add here other stuff to be archived into libcamlrun.a
LIBRUN := $(CPROTO:.c=.o)

.PHONY: all
all: lib man doc

.PHONY: lib
lib_tgt := $(CMI) $(CMO) stdlib.cma libcamlrun.a 
lib:
	@$(MAKE) -q $(lib_tgt) 2> /dev/null || \
	  $(call message,COMPILE: ,Standard library)
	$(MAKE) $(lib_tgt)

stdlib.cma: $(CMO)
	$(OCAMLC) -nostdlib -a $^ -o $@

stdlib.cmo: stdlib.ml stdlib.cmi
	$(OCAMLC) -absname -no-alias-deps -nostdlib -nopervasives -c -w -49 $<

stdlib.cmi: stdlib.mli #camlinternalFormatBasics.cmi
	$(OCAMLC) -absname -no-alias-deps -nostdlib -nopervasives -c -w -49 $<

libcamlrun.a: $(CMI) $(CMO) $(LIBRUN) stdlib.cma
	cp $(OCAMLSTDLIB)/$@ .
	ar rs $@ $^

#camlinternalFormatBasics.cmo: camlinternalFormatBasics.ml camlinternalFormatBasics.cmi
#	$(OCAMLC) -nostdlib -nopervasives -c $<

#camlinternalFormatBasics.cmi: camlinternalFormatBasics.mli
#	$(OCAMLC) -nostdlib -nopervasives -c $<

camlinternal%.cmo: camlinternal%.ml camlinternal%.cmi
	$(OCAMLC_UNSAFE) -absname -nostdlib -c $<

camlinternal%.cmi: camlinternal%.mli
	$(OCAMLC_UNSAFE) -absname -nostdlib -c $<

std_exit.cmo: std_exit.ml std_exit.cmi
	$(OCAMLC_UNSAFE) -absname -nostdlib -c $<

std_exit.cmi: std_exit.mli
	$(OCAMLC_UNSAFE) -absname -nostdlib -c $<

$(PFX)%Labels.cmo: %Labels.ml $(PFX)%Labels.cmi
	$(OCAMLC_UNSAFE) -nostdlib -nolabels -c -w -3 $< -o $@

$(PFX)%Labels.cmi: %Labels.mli
	$(OCAMLC_UNSAFE) -nostdlib -nolabels -c $< -o $@

$(PFX)float.cmo: float.ml $(PFX)float.cmi
	$(OCAMLC_UNSAFE) -absname -nostdlib -nolabels -c $< -o $@

$(PFX)float.cmi: float.mli
	$(OCAMLC_UNSAFE) -absname -nostdlib -nolabels -c $< -o $@

$(PFX)%.cmo: %.ml $(PFX)%.cmi
	$(OCAMLC_UNSAFE) -absname -nostdlib -c $< -o $@

$(PFX)%.cmi: %.mli
	$(OCAMLC_UNSAFE) -absname -nostdlib -c $< -o $@

# C prototypes for non-standard primitives
$(CPROTO): ../asm/stdlib_*.asm
	{ echo '// AUTO GENERATED FILE - DO NOT EDIT'; \
	  echo '// Generated $(shell date) by $(TOOLS)/mkproto'; \
	  for f in $^; do $(TOOLS)/mkproto -p caml_nonstd_ "$$f"; done; \
	} > $@
# Interface generation for unlabeled modules and MoreLabels
TPL     := templates
SIMPLE  := bytes.mli list.mli string.mli array.mli
FUNCTOR := hashtbl.mli map.mli set.mli

#.INTERMEDIATE: $(SIMPLE) $(FUNCTOR) float.mli moreLabels.mli
$(SIMPLE): %.mli: %Labels.mli
	$(TOOLS)/sync_stdlib_docs $@

$(FUNCTOR): %.mli: $(TPL)/%.template.mli
	$(TOOLS)/sync_stdlib_docs $@

float.mli: $(TPL)/floatarraylabeled.template.mli $(TPL)/float.template.mli
	$(TOOLS)/sync_stdlib_docs $@

moreLabels.mli: $(patsubst %.mli,$(TPL)/%.template.mli,$@ $(FUNCTOR)) \
		$(patsubst %,$(TPL)/%.mli,1 2 3 4)
	$(TOOLS)/sync_stdlib_docs $@

.PHONY: man
man: .man_timestamp

.man_timestamp: $(BASENAMES:=.mli)
	@$(call message,GENERATE:,Man pages)
	$(OCAMLDOC) -hide-warnings -t "The BreadCaml Project" \
	  -man -man-mini -man-suffix $(MAN3EXT) -man-section $(MAN3EXT) $^
	touch $@

.PHONY: doc
doc: .doc_timestamp

.doc_timestamp: $(BASENAMES:=.mli)
	@$(call message,GENERATE:,HTML documentation)
	$(OCAMLDOC) -hide-warnings -html -charset utf-8 -colorize-code \
	  -sort -t "The BreadCaml Project" $^
	touch $@

.PHONY: clean
clean:
	rm -f *.{cm{i,o,a},html,$(MAN3EXT),o} $(CPROTO) libcamlrun.a stdlib.db
	rm -f .{man,doc}_timestamp
