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
include $(if $(wildcard $(CONF)),$(CONF),$(error \
	Please run «./configure [options...]» from the main source directory))

BIN    := ../../bin
TARGET := $(BIN)/bcamlc
VPATH  := ./ocamlclean
OCLEAN := step1 prim step2 step3 data cleanbra rmnop globalise cleanenvs
BCAMLC := config globals opcodes export cmdline bcamlc

# OCamlclean modules patched at build time: the distributed sources in
# ./ocamlclean stay untouched. For each module M listed in $(PATCH), the file
# patches/ocamlclean-M.patch is applied to a copy of ocamlclean/M.ml in
# $(PATCHED), and that copy is compiled instead of the original.
PATCH     := globalise step2 prim
PATCHED   := ./patched
PATCHDIR  := ./patches
OCLEAN_ML := $(foreach m,$(OCLEAN),$(if \
		$(filter $(m),$(PATCH)),$(PATCHED)/$(m).ml,$(m).ml))

SOURCE := $(OCLEAN_ML) $(BCAMLC:=.ml)
FLAGS  := -I +/../obytelib/ obytelib.cmxa -I $(VPATH) -I $(PATCHED)

$(TARGET): $(SOURCE)
	@$(call message,COMPILE: ,BreadCaml compiler)
	$(OCAMLOPT) $(FLAGS) -o $@ $^

$(PATCHED)/%.ml: ocamlclean/%.ml $(PATCHDIR)/ocamlclean-%.patch
	@mkdir -p $(PATCHED)
	LINE="$$(printf '%.s—' {1..70})"; sed "/$$LINE/,/$$LINE/d" $< > $@
	patch -s $@ < $(PATCHDIR)/ocamlclean-$*.patch

config.ml: config.ml.tpl $(CONF)
	cp $@.tpl $@
	{ echo 'let ocamlc  = "$(OCAMLC_UNSAFE)"'; \
	  echo 'let libdir  = "$(LIBDIR)"'; \
	  echo 'let bindir  = "$(BINDIR)"'; \
	  echo 'let acme    = "$(ACME)"'; \
	  echo 'let version = "$(VERSION)"'; \
	} >> $@

.PHONY: clean
clean:
	rm -f $(TARGET) {.,$(VPATH)}/*.{o,cm?} config.ml
	rm -rf $(PATCHED)
