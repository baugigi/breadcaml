# Batteria di test BreadCaml

Compila ogni test con `bcamlopt` (nativo) e `bcamlc` (bytecode + interprete), lo esegue su VICE
(x64sc, warp) e verifica l'esito. Aggiornata dopo le patch 42–46 (primitive dirette di c64lib,
saturazione degli argomenti, c64lib in una compilation unit per sottomodulo, fix tabella GC).

## Requisiti
`bcamlopt`/`bcamlc` nel `PATH`, VICE 3.10 (`x64sc`, con le ROM C64), `python3`, `stdbuf` (coreutils).
In ambiente senza display: `VICE_OPTS="-console"` oppure un X virtuale (`xvfb-run`).

## Uso
```
./run_tests.sh                       # tutto, nat + bc
./run_tests.sh -m nat -s core,bank   # solo nativo, solo alcune suite
./run_tests.sh -k '^t06' -j 4        # solo i test che iniziano per t06, 4 VICE in parallelo
./run_tests.sh -l                    # elenca i test
```
Opzioni: `-i` (VICE ridotto a icona), `-m nat|bc|both`, `-s suite,...`, `-k regex`, `-o dir_risultati` (default `./results`), `-j N`, `-l`.
Variabili: `X64` (default `x64sc`), `VICE_OPTS`, `BCAMLOPT`, `BCAMLC`, `STALL` (secondi senza output prima
di dichiarare un hang, default 90).

Per ogni test, in `results/<suite>/<nat|bc>/`: `NOME.prg`, `NOME.build` (log di compilazione),
`NOME.raw` (traccia CHROUT), `NOME.txt` (output decodificato), `NOME.status`. Riepilogo in `results/summary.txt`.

Esiti: `OK`, `FAIL`, `BUILD-FAIL`, `NOVERDICT` (nessun "<etichetta> OK/FAIL": hang o timeout),
`XFAIL`/`XBUILD` (fallimento atteso, vedi `expected.conf`), `XPASS` (atteso in errore ma passa: togliere da `expected.conf`).
Al termine il driver confronta le uscite nat e bc (devono coincidere) ed esce con codice ≠ 0 se ci sono
`FAIL`, `BUILD-FAIL`, `NOVERDICT` o differenze nat/bc.

Ogni programma stampa `FAIL <nome>` per ogni verifica sbagliata (`EXN` = eccezione inattesa,
`NOEXN` = eccezione attesa non sollevata) e in coda `<etichetta> OK|FAIL`. Il verdetto è letto dalla traccia
delle chiamate a CHROUT ($F1CA) con il monitor di VICE; il test termina appena il verdetto compare.

## Contenuto
| Dir | Suite | Contenuto |
|---|---|---|
| `core/tests` | `core` | t01–t20: blocchi 0/127/128/255, array, stringhe, chiusure, switch, ACC/APPLY/APPTERM, interi a 15 bit, eccezioni, Int32/Int64, compare, float, stress GC, List/Map/Set/Buffer…; **t20_c64lib_sat**: c64lib (saturazione degli argomenti di Screen/Sprite/Sound, conversioni PETSCII/screen code) |
| `core/diag` | `diag` | sonde diagnostiche (matrici, float, liste, memoria) |
| `core/ocamlclean` | `ocamlclean` | oc01–oc09: alias, ambienti, try/assign, cicli, moduli (riduzione del bytecode) |
| `bank` | `bank` | heap e pila oltre $A000 (`-mem 0xCFFF`), primitiva custom `bk_addr` |
| `petscii` | `petscii` | stdlib con testo PETSCII (Int32/Int64.of_string, Buffer, Char.Ascii, messaggi di errore) |
| `examples` | `examples` | arg, disk, fos, funpexc, lazy, ppx, printf, streamgenlex: **solo compilazione** (`make COMP=…`); non hanno un verdetto automatico |
| `core/gen` | – | generatore dei test t01–t19 (`gen_tests.py`); t20 e oc* sono scritti a mano |
| `tools` | – | `vrun.py` (esegue su VICE e legge la traccia), `decode_trace.py`, `test_init.mon` |

`stack.conf` (per suite): `nome_test  flag extra` (es. `-stack 16 -mem 0xCFFF`). I test che fanno `open C64`
sono collegati automaticamente con `c64lib.cma`. Nota: con `-o` va usato un percorso relativo (un percorso assoluto
rompe il nome del file temporaneo di bcamlopt); il driver compila dentro la directory dei risultati.

## Stato (VICE 3.10, toolchain con le patch fino alla 49)
Su 112 test × 2 modalità: 220 OK e 20 errori di build attesi (`expected.conf`), nessun FAIL; le uscite nat e bc coincidono.
Primitive assenti dal runtime (errore di assemblaggio): `caml_int64_to_float` (t10b, petscii), `caml_array_fill` (t90),
`caml_hash` (t91, t93), `caml_floatarray_blit` (t94). Esempi lazy, ppx, printf, streamgenlex: non compilano col sorgente
usato per la verifica (Lazy assente, `caml_hash` assente, il ppx PETSCII altera i formati `%d`).
Bug trovati dalla batteria e corretti con le patch 47 (`add_float`: FADDT riceveva Z=1), 48 (mkdepends e parentesi annidate:
`float_of_string` senza `caml_float_alloc_result`) e 49 (`float_of_string` con stringhe sopra $A000).
