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

TARGET := printf_test.prg
SOURCE := printf_test
COMP = bcamlopt #bcamlc
FLAGS = -verbose -db printf_test.db
ASMFLAGS =

$(TARGET): $(SOURCE:=.cmo)
	$(COMP) $(FLAGS) -o $@ $^ -- $(ASMFLAGS)

%.cmo: %.ml $(SOURCE:=.cmi)
	$(COMP) $(FLAGS) -c $<

%.cmi: %.mli
	$(COMP) $(FLAGS) -c $<

.INTERMEDIATE: $(SOURCE:=.mli)
%.mli: %.ml
	$(COMP) -c -i $< > $@
