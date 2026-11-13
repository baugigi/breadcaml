SHELL := /bin/bash
CONF  := etc/Makefile.conf
include $(if $(wildcard $(CONF)),$(CONF),$(error \
	Please run './configure [options...]' from the main source directory))

# Path for uninstaller script
UNINST := etc/uninstall.sh

# Install file $(1) in dir $(2) with permissions $(3) and record it into the
# uninstaller script
define	inst_and_rec
	[ -d "$(2)" ] || mkdir -p "$(2)"; \
	echo "DIR:$(2)" >> "$(UNINST)"; \
	for f in $(1); do \
	  [ -f "$$f" ] && { \
	    cp -f "$$f" "$(2)/"; \
	    chmod $(3) "$(2)/$$(basename "$$f")"; \
	    echo "FILE:$(2)/$$(basename "$$f")" >> "$(UNINST)"; \
	  }; \
	done
endef

.PHONY: all
all:
	$(MAKE) -C src/bcamlc
	$(MAKE) -C src/bcamlppx
	$(MAKE) -C src/stdlib
	$(MAKE) -C src/asm

.PHONY: install
install: all
	@$(call message,GENERATE:,Uninstaller script)
	{ echo '#!/bin/bash'; \
	  echo '# AUTO-GENERATED FILE - DO NOT EDIT'; \
	  echo 'sed -nE "s/^FILE:(.+)$$/\1/p" "$$0"|while read -r f; do'; \
	  echo '  rm -f "$$f"'; \
	  echo 'done'; \
	  echo 'sed -nE "s/^DIR:(.+)$$/\1/p" "$$0"|tac|while read -r d; do'; \
	  echo '  rmdir "$$d" 2>/dev/null'; \
	  echo 'done'; \
	  echo 'rm -f "$$0"'; \
	  echo 'exit 0'; \
	  echo '# --- MANIFEST ---'; \
	} > $(UNINST)
	chmod +x "$(UNINST)"
	@$(call message,INSTALL: ,Binaries)
	$(call inst_and_rec,bin/bcamlc,$(BINDIR),755)
	$(call inst_and_rec,bin/bcamlppx,$(BINDIR),755)
	strip bin/bcaml{c,ppx}
	ln -fsT $(BINDIR)/bcamlc $(BINDIR)/bcamlopt
	echo "FILE:$(BINDIR)/bcamlopt" >> "$(UNINST)"
	@$(call message,INSTALL: ,Assembly routines)
	$(call inst_and_rec,src/asm/*.asm,$(LIBDIR),755)
	@$(call message,INSTALL: ,Standard Library)
	$(call inst_and_rec,src/stdlib/stdlib.cma,$(LIBDIR),755)
	$(call inst_and_rec,src/stdlib/libcamlrun.a,$(LIBDIR),755)
	$(call inst_and_rec,src/stdlib/*.ml,$(LIBDIR),755)
	$(call inst_and_rec,src/stdlib/*.mli,$(LIBDIR),755)
	$(call inst_and_rec,src/stdlib/*.cmo,$(LIBDIR),755)
	$(call inst_and_rec,src/stdlib/*.cmi,$(LIBDIR),755)
	@$(call message,INSTALL: ,Man pages)
	$(call inst_and_rec,man/*,$(MAN1DIR),644)
	$(call inst_and_rec,src/stdlib/*.$(MAN3EXT),$(MAN3DIR),644)
	@$(call message,INSTALL: ,HTML documentation)
	$(call inst_and_rec,src/stdlib/*.html,$(DOCDIR),644)
	$(call inst_and_rec,src/stdlib/*.css,$(DOCDIR),644)

.PHONY: uninstall
uninstall:
	@if [ -f "$(UNINST)" ]; then "$(UNINST)"; else \
	  echo "Cannot uninstall BreadCaml: '$(UNINST)' not found." 1>&2; \
	fi

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
gitclean: clean
	rm -f etc/Makefile.conf etc/$(UNINST)
