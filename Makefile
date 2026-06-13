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
CONF = etc/Makefile.conf

include $(if $(wildcard $(CONF)),$(CONF),$(error \
	Please run «./configure [options...]» from the main source directory))

.PHONY: all
all:
	$(MAKE) -C src/o64ml
	$(MAKE) -C src/stdlib
	$(MAKE) -C src/asm

.PHONY: install
install: all
	mkdir -p "$(LIBDIR)" "$(BINDIR)" "$(MAN1DIR)" "$(MAN3DIR)"
	cp src/asm/*.asm "$(LIBDIR)"
	cp bin/o64ml "$(BINDIR)/o64ml"
	cp man/o64ml.1.gz "$(MAN1DIR)"/o64ml.1.gz
	cp src/stdlib/{stdlib.cma,libcamlrun.a,*.{ml,mli,cmo,cmi}} "$(LIBDIR)"
	cp src/stdlib/*.$(MAN3EXT) "$(MAN3DIR)"

.PHONY: uninstall
uninstall:
	rm -fr "$(LIBDIR)"
	rm -f "$(BINDIR)"/o64ml
	rm -f "$(BINDIR)"/acme
	rm -f "$(MAN1DIR)"/o64ml.1.gz
	rm -f "$(MAN3DIR)"/*.$(MAN3EXT)

.PHONY: clean
clean:
	$(MAKE) -C src/o64ml $@
	$(MAKE) -C src/stdlib $@
	$(MAKE) -C src/asm $@
	$(MAKE) -C test $@

.PHONY: dist
dist: distclean
	dist/distgen

.PHONY: distclean
distclean:
	$(MAKE) -C src/o64ml $@
	$(MAKE) -C src/stdlib $@
	$(MAKE) -C src/asm $@
	$(MAKE) -C test $@
	rm -f *~
	rm -f etc/Makefile.conf
