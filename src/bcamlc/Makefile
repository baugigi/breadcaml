SHELL := /bin/bash
CONF  := ../../etc/Makefile.conf
include $(if $(wildcard $(CONF)),$(CONF),$(error \
	Please run «./configure [options...]» from the main source directory))

BIN    := ../../bin
TARGET := $(BIN)/bcamlc
VPATH  := ./ocamlclean
OCLEAN := step1 prim step2 step3 data cleanbra rmnop globalise cleanenvs
BCAMLC := config globals opcodes export cmdline bcamlc
SOURCE := $(OCLEAN) $(BCAMLC)
FLAGS  := -I +/../obytelib/ obytelib.cmxa -I $(VPATH)

$(TARGET): $(SOURCE:=.ml)
	@echo '$(call message,COMPILE: ,BreadCaml compiler)'
	$(OCAMLOPT) $(FLAGS) -o $@ $^

config.ml: config.ml.tpl $(CONF)
	cp $@.tpl $@
	{ echo 'let ocamlc  = "$(OCAMLC_UNSAFE)"'; \
	  echo 'let libdir  = "$(LIBDIR)"'; \
	  echo 'let bindir  = "$(BINDIR)"'; \
	  echo 'let acme    = "$(ACME)"'; \
	  echo 'let version = "$(VERSION)"'; \
	} >> $@

.PHONY: clean
clean:
	rm -f $(TARGET) {.,$(VPATH)}/*.{o,cm?} config.ml
