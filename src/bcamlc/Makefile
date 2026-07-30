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

BIN = ../../bin
TARGET = $(BIN)/bcamlc
OCAMLCLEAN = step1 prim step2 step3 data cleanbra rmnop globalise cleanenvs
BCAMLC = $(OCAMLCLEAN) config globals opcodes export cmdline
VPATH = ./ocamlclean

$(TARGET): $(BCAMLC:=.ml) bcamlc.ml
	$(OCAMLOPT) -I +/../obytelib/ -I $(VPATH) obytelib.cmxa $^ -o $@

config.ml: config.ml.tpl $(CONF)
	cp $@.tpl $@
	echo 'let ocamlc  = "$(OCAMLC_UNSAFE)"' >> $@
	echo 'let libdir  = "$(LIBDIR)"'        >> $@
	echo 'let bindir  = "$(BINDIR)"'        >> $@
	echo 'let acme    = "$(ACME)"'          >> $@
	echo 'let version = "$(VERSION)"'       >> $@

.PHONY: clean
clean:
	rm -f $(TARGET) *.o *.cm?
	rm -f $(VPATH)/*.o $(VPATH)/*.cm?

.PHONY: gitclean
gitclean: clean
	rm -f *~ $(VPATH)/*~
