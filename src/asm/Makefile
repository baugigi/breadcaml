SHELL := /bin/bash
CONF  := ../../etc/Makefile.conf
include $(if $(wildcard $(CONF)),$(CONF),$(error \
	Please run «./configure [options...]» from the main source directory))

.PHONY: asm
asm:
	@$(MAKE) -q stdlib.asm 2> /dev/null || \
	  echo '$(call message,GENERATE:,Assembly routines)'
	$(MAKE) stdlib.asm

stdlib.asm: depends.asm stdlib_*.asm
	{ echo ';; AUTO-GENERATED FILE - DO NOT EDIT'; \
	  echo -n 'caml_stdlib'; \
	  echo -e '$(patsubst %,\n\t!source "$(LIBDIR)/%",$^)'; \
	  echo 'caml_stdlib_end'; \
	} > $@

depends.asm: stdlib_*.asm
	../../tools/mkdepends $@ $^

.PHONY: clean
clean:
	rm -f stdlib.asm depends.asm
