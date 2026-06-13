# ——————————————————————————————————————————————————————————————————————
# Progetto O64ml / The O64ml Project
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

TARGET	=  ../../bin/o64ml
O64ML 	= const.cmx globals.cmx opcodes.cmx export.cmx o64ml.cmx
VPATH 	= ocamlclean
OCAMLCLEAN = step1.cmx prim.cmx step2.cmx step3.cmx data.cmx cleanbra.cmx \
	rmnop.cmx globalise.cmx cleanenvs.cmx

$(TARGET): $(OCAMLCLEAN) $(O64ML)
	$(OCAMLOPT) -I +/../obytelib/ -I $(VPATH) -o $@ obytelib.cmxa $^

%.cmx: %.ml
	$(OCAMLOPT) -c -I +/../obytelib/ -I $(VPATH) $^

const.ml: const.ml.template
	cp $< $@
	echo 'let ocamlc  = "$(OCAMLC_UNSAFE)"' >> $@
	echo 'let libdir  = "$(LIBDIR)"'        >> $@
	echo 'let acme    = "$(ACME)"'          >> $@
	echo 'let version = "$(VERSION)"'       >> $@

.PHONY: clean
clean:
	rm -f $(TARGET) const.ml *.o *.cm?
	rm -f $(VPATH)/*.o $(VPATH)/*.cm?

.PHONY: distclean
distclean: clean
	rm -f *~ $(VPATH)/*~
