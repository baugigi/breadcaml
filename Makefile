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
CONF  = etc/Makefile.conf
include $(if $(wildcard $(CONF)),$(CONF),$(error \
	Please run «./configure [options...]» from the main source directory))

.PHONY: all
all:
	$(MAKE) -C src/bcamlc
	$(MAKE) -C src/bcamlppx
	$(MAKE) -C src/stdlib
	$(MAKE) -C src/asm

.PHONY: install
install: all
	mkdir -p $(LIBDIR) $(LIBDIR)/c64lib $(BINDIR) $(MAN1DIR) $(MAN3DIR)
	cp src/asm/*.asm $(LIBDIR)
	strip bin/bcaml{c,ppx}
	cp bin/bcaml{c,ppx} $(BINDIR)
	ln -f -s -T $(BINDIR)/bcamlc $(BINDIR)/bcamlopt
	cp man/* $(MAN1DIR)
	cp src/stdlib/{stdlib.cma,libcamlrun.a,*.{ml,mli,cmo,cmi}} $(LIBDIR)
	cp src/stdlib/*.$(MAN3EXT) $(MAN3DIR)

.PHONY: uninstall
uninstall:
	rm -fr $(LIBDIR)
	rm -f $(BINDIR)/bcaml{c,opt,ppx}
	rm -f $(BINDIR)/acme
	rm -f $(MAN1DIR)/bcaml{c,opt,ppx}.1.gz
	rm -f $(MAN3DIR)/*.$(MAN3EXT)

.PHONY: clean
clean:
	$(MAKE) -C src/bcamlc $@
	$(MAKE) -C src/bcamlppx $@
	$(MAKE) -C src/stdlib $@
	$(MAKE) -C src/asm $@
	$(MAKE) -C test $@

.PHONY: fullinstall
fullinstall: install clean

.PHONY: gitclean
gitclean:
	$(MAKE) -C src/bcamlc $@
	$(MAKE) -C src/bcamlppx $@
	$(MAKE) -C src/stdlib $@
	$(MAKE) -C src/asm $@
	$(MAKE) -C test $@
	rm -f etc/Makefile.conf
	rm -f etc/config.ml
	rm -f *~
