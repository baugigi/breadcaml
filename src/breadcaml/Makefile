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

TARGET = ../../bin/breadcaml
BREADCAML = config globals opcodes export breadcaml
OCAMLCLEAN = step1 prim step2 step3 data cleanbra rmnop globalise cleanenvs
VPATH = ./ocamlclean

$(TARGET): $(OCAMLCLEAN:=.cmx) $(BREADCAML:=.cmx)
	$(OCAMLOPT) -I +/../obytelib/ -I $(VPATH) -o $@ obytelib.cmxa $^

config.cmx: ../../etc/config.ml
	$(OCAMLOPT) -c $^
	mv ../../etc/config.{cm?,o} .

%.cmx: %.ml
	$(OCAMLOPT) -c -I +/../obytelib/ -I $(VPATH) $^

.PHONY: clean
clean:
	rm -f $(TARGET) *.o *.cm?
	rm -f $(VPATH)/*.o $(VPATH)/*.cm?

.PHONY: gitclean
gitclean: clean
	rm -f *~ $(VPATH)/*~
