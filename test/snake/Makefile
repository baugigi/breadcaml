#  ——————————————————————————————————————————————————————————————————————
#  The BreadCaml Project / Progetto BreadCaml
#  Copyright (C) 21-Apr-2026 Piero Furiesi
#  
#  This program is  free software; you can redistribute  it and/or modify
#  it under the terms of the  GNU GENERAL PUBLIC LICENSE (GPL) version 2,
#  as specified in the LICENSE-en file in the project root folder.
#  
#  Questo  programma  è software  libero;  può  essere ridistribuito  e/o
#  modificato nei termini della GNU GENERAL PUBLIC LICENSE (GPL) versione
#  2, come specificato nel file  LICENZA-it nella cartella principale del
#  progetto.
#  ——————————————————————————————————————————————————————————————————————

SHELL := /bin/bash

TARGET := snake.prg
SOURCE := iOtools snake
EXTLIB := iOtools
COMP = bcamlopt #bcamlc
FLAGS = -otime -verbose -db snake.db
ASMFLAGS = #-r snake.rep -Dcaml_globals_on_heap=1

$(TARGET): $(EXTLIB:=.asm) $(EXTLIB:=.c) $(SOURCE:=.cmo)
	$(COMP) $(FLAGS) -o $@ $^ -- $(ASMFLAGS)

%.cmo: %.ml $(SOURCE:=.cmi)
	$(COMP) $(FLAGS) -c $<

%.cmi: %.mli
	$(COMP) $(FLAGS) -c $<

.INTERMEDIATE: $(SOURCE:=.mli)
%.mli: %.ml
	$(COMP) -c -i $< > $@

.INTERMEDIATE: $(SOURCE:=.c)
%.c: %.asm
	../../tools/mkproto -p IOtools_ $< > $@

.PHONY: clean
clean:
	rm -f *.{cm?,o,prg,db,rep}

.PHONY: .merlin
.merlin:
	echo -ne "\
	STDLIB $$($(COMP) -where)\n\
	S .\n\
	B .\n\
	" > $@
