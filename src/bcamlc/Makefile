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

BIN    := ../../bin
TARGET := $(BIN)/bcamlc
VPATH  := ./ocamlclean
OCLEAN := step1 prim step2 step3 data cleanbra rmnop globalise cleanenvs
BCAMLC := config globals opcodes export cmdline bcamlc

# OCamlclean modules patched at build time: the distributed sources in
# ./ocamlclean stay untouched. For each module M listed in PATCHED, the
# file patches/ocamlclean-M.patch is applied to a copy of ocamlclean/M.ml
# in $(BUILD), and that copy is compiled instead of the original.
PATCHED   := globalise step2
BUILD     := patched
PATCHDIR  := ./patches
OCLEAN_ML := $(foreach m,$(OCLEAN),$(if $(filter $(m),$(PATCHED)),$(BUILD)/$(m).ml,$(m).ml))

SOURCE := $(OCLEAN_ML) $(BCAMLC:=.ml)
FLAGS  := -I +/../obytelib/ obytelib.cmxa -I $(VPATH) -I $(BUILD)

$(TARGET): $(SOURCE)
	@$(call message,COMPILE: ,BreadCaml compiler)
	$(OCAMLOPT) $(FLAGS) -o $@ $^

$(BUILD)/%.ml: ocamlclean/%.ml $(PATCHDIR)/ocamlclean-%.patch
	@mkdir -p $(BUILD)
	cp $< $@
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
	rm -rf $(BUILD)
