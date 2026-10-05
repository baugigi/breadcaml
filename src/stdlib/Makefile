SHELL = /usr/bin/env bash
CONF = ../../etc/Makefile.conf
include $(if $(wildcard $(CONF)),$(CONF),$(error \
	Please run «./configure [options...]» from the main source directory))

lcase = $(shell echo $(1)|sed -Ee "s/([A-Z])(.*)/\l\1\2/")
ucase = $(shell echo $(1)|sed -Ee "s/([a-z])(.*)/\u\1\2/")

# Original list of module basenames for the OCaml standard library
# (SORTED BY DEPENDENCIES)
STDLIB_MODULE_BASENAMES = camlinternalFormatBasics camlinternalAtomic	\
  stdlib pervasives either sys obj camlinternalLazy lazy seq option	\
  result bool char uchar list int bytes string unit marshal array	\
  float int32 int64 nativeint lexing parsing set map stack queue	\
  stream buffer camlinternalFormat printf arg atomic printexc fun gc	\
  digest random hashtbl weak format scanf callback camlinternalOO oo	\
  camlinternalMod genlex ephemeron filename complex arrayLabels		\
  listLabels bytesLabels stringLabels moreLabels stdLabels bigarray	\
  in_channel out_channel std_exit

# Modules removed in BreadCaml
REMOVED = camlinternalFormatBasics camlinternalAtomic pervasives	\
  uchar marshal nativeint lexing parsing stream camlinternalFormat	\
  printf arg atomic printexc fun gc digest weak format scanf callback	\
  camlinternalOO oo genlex ephemeron filename bigarray in_channel	\
  out_channel

BASENAMES = $(filter-out $(REMOVED),$(STDLIB_MODULE_BASENAMES))

PFX = stdlib__
NOPFX = camlinternal% stdlib std_exit
LIB = $(foreach F,$(BASENAMES),$(if $(filter $(NOPFX),$(F)),,$(PFX))$(F))

CMI := $(LIB:=.cmi)
CMO := $(LIB:=.cmo)

# Prototypes of non-standard primitives (auto-generated)
CPROTO := stdlib__nonstd.c

# Add here other stuff to be archived into libcamlrun.a
LIBRUN := $(CPROTO:.c=.o)

# Preprocessor
#PPX := -ppx "../../bin/bcamlppx stdlib.db"

.PHONY: all
all: lib man

.PHONY: lib
lib: $(CMI) $(CMO) stdlib.cma libcamlrun.a

.PHONY: man
man: $(foreach l,$(BASENAMES),$(call ucase,$(l)).$(MAN3EXT)) Stdlib.$(MAN3EXT)

$(CPROTO): ../asm/stdlib_*.asm
	sed -nE \
	's/^[^;]*[ \t]+caml_PRIM__(caml_nonstd_[a-zA-Z0-9_]+).*/void \1(){}/p' \
	$^ > $@

libcamlrun.a: $(CMI) $(CMO) $(LIBRUN) stdlib.cma
	cp $(OCAMLSTDLIB)/$@ .
	ar rs $@ $^

stdlib.cma: $(CMO)
	$(OCAMLC) $(PPX) -nostdlib -a $^ -o $@

stdlib.cmo: stdlib.ml stdlib.cmi
	$(OCAMLC) $(PPX) -absname -no-alias-deps -nostdlib -nopervasives -c -w -49 $<

stdlib.cmi: stdlib.mli #camlinternalFormatBasics.cmi
	$(OCAMLC) $(PPX) -absname -no-alias-deps -nostdlib -nopervasives -c -w -49 $<

#camlinternalFormatBasics.cmo: camlinternalFormatBasics.ml camlinternalFormatBasics.cmi
#	$(OCAMLC) -nostdlib -nopervasives -c $<

#camlinternalFormatBasics.cmi: camlinternalFormatBasics.mli
#	$(OCAMLC) -nostdlib -nopervasives -c $<

camlinternal%.cmo: camlinternal%.ml camlinternal%.cmi
	$(OCAMLC_UNSAFE) $(PPX) -absname -nostdlib -c $<

camlinternal%.cmi: camlinternal%.mli
	$(OCAMLC_UNSAFE) $(PPX) -absname -nostdlib -c $<

std_exit.cmo: std_exit.ml std_exit.cmi
	$(OCAMLC_UNSAFE) $(PPX) -absname -nostdlib -c $<

std_exit.cmi: std_exit.mli
	$(OCAMLC_UNSAFE) $(PPX) -absname -nostdlib -c $<

$(PFX)%Labels.cmo: %Labels.ml $(PFX)%Labels.cmi
	$(OCAMLC_UNSAFE) $(PPX) -nostdlib -nolabels -c -w -3 $< -o $@

$(PFX)%Labels.cmi: %Labels.mli
	$(OCAMLC_UNSAFE) $(PPX) -nostdlib -nolabels -c $< -o $@

$(PFX)float.cmo: float.ml $(PFX)float.cmi
	$(OCAMLC_UNSAFE) $(PPX) -absname -nostdlib -nolabels -c $< -o $@

$(PFX)float.cmi: float.mli
	$(OCAMLC_UNSAFE) $(PPX) -absname -nostdlib -nolabels -c $< -o $@

$(PFX)%.cmo: %.ml $(PFX)%.cmi
	$(OCAMLC_UNSAFE) $(PPX) -absname -nostdlib -c $< -o $@

$(PFX)%.cmi: %.mli
	$(OCAMLC_UNSAFE) $(PPX) -absname -nostdlib -c $< -o $@


# Automatic (re)generation of unlabeled modules and MoreLabels
TPL  := templates
SYNC := ../../tools/sync_stdlib_docs
bytes.mli list.mli string.mli array.mli: %.mli: %Labels.mli
	$(SYNC) $@
hashtbl.mli map.mli set.mli: %.mli: $(TPL)/%.template.mli
	$(SYNC) $@
float.mli: $(TPL)/floatarraylabeled.template.mli $(TPL)/float.template.mli
	$(SYNC) $@
moreLabels.mli: $(TPL)/moreLabels.template.mli $(TPL)/hashtbl.template.mli \
		$(TPL)/map.template.mli $(TPL)/set.template.mli \
		$(TPL)/1.mli $(TPL)/2.mli $(TPL)/3.mli $(TPL)/4.mli
	$(SYNC) $@


%.$(MAN3EXT):
	$(OCAMLDOC) -hide-warnings -man -man-mini -man-suffix $(MAN3EXT) \
	-man-section $(MAN3EXT) -t "The BreadCaml Project" $(call lcase,$*).mli

.PHONY: clean
clean:
	rm -f *.{cmi,cmo,cma,o,$(MAN3EXT)} $(CPROTO) libcamlrun.a stdlib.db
