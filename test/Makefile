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

SUB_MAKEDIRS := $(dir $(shell find . -mindepth 2 -name "Makefile"))

.PHONY: test
test:
	@for dir in $(SUB_MAKEDIRS); do \
		echo "--- Makefile in: $$dir"; \
		$(MAKE) -C $$dir; \
	done
	@for file in $(shell find . -mindepth 2 -name "*.ml"); do \
		dir_of_file="$$(dirname "$$file")/"; \
		if ! echo "$(SUB_MAKEDIRS)" | grep -q "$$dir_of_file"; then \
			echo "--- Compiling: $$file"; \
			breadcaml "$$file"; \
		fi; \
	done

.PHONY: clean
clean:
	rm -f *.{cm?,prg,byte}
	rm -f */*.{cm?,prg,byte}

.PHONY: gitclean
gitclean: clean
	rm -f *~ */*~
