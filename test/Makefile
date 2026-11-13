SHELL := /bin/bash
CONF  := ../etc/Makefile.conf
include $(if $(wildcard $(CONF)),$(CONF),$(error \
	Please run './configure [options...]' from the main source directory))

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
	@find . -type f '(' -name '*.cm?' -o -name '*.db' -o -name '*.prg' ')' \
	        -delete
