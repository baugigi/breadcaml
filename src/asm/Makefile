SHELL := /bin/bash
CONF  := ../../etc/Makefile.conf
include $(if $(wildcard $(CONF)),$(CONF),$(error \
	Please run «./configure [options...]» from the main source directory))

.PHONY: asm
asm:
	@$(MAKE) -q stdlib.asm 2> /dev/null || \
	  $(call message,GENERATE:,Assembly routines)
	$(MAKE) stdlib.asm

# Assembly sources: the standard library ones, plus the C64 library ones
# (../../c64lib/asm/c64lib_*.asm), all installed in $(LIBDIR)
C64ASM := $(wildcard ../../c64lib/asm/c64lib_*.asm)
ASMSRC := $(wildcard stdlib_*.asm) $(C64ASM)

stdlib.asm: depends.asm $(ASMSRC)
	{ echo ';; AUTO-GENERATED FILE - DO NOT EDIT'; \
	  echo -n 'caml_stdlib'; \
	  echo -e '$(patsubst %,\n\t!source "$(LIBDIR)/%",$(notdir $^))'; \
	  echo 'caml_stdlib_end'; \
	} > $@

depends.asm: $(ASMSRC)
	../../tools/mkdepends $@ $^

.PHONY: clean
clean:
	rm -f stdlib.asm depends.asm
