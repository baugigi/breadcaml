# Batteria di test BreadCaml: casi limite sui blocchi (0 / 127 / 128 / 255)

**Stato**: i 86 file in `tests/` sono generati da `gen/gen_tests.py`. **Non sono mai stati compilati**
(nel sandbox non c'è `ocamlc`) **né eseguiti sul C64**. Ho controllato:

- la sintassi in modo approssimativo (`gen/lint_ml.py`: bilanciamento di parentesi, `begin/end`, `do/done`, stringhe, commenti);
- i valori attesi, cioè il modello Python di interi a 15 bit, Int32 e Int64, confrontato con la semantica C reale (`ctypes`), con 0 discordanze.

Al primo giro aspettatevi qualche errore di battitura OCaml nei file generati. Si correggono nel generatore e si rigenera.

## Come si usa

```
python3 gen/gen_tests.py tests        # rigenera i .ml
./build.sh tests build                # compila nat + bc (adattare BCAMLOPT/BCAMLC/flag)
# eseguire ogni programma nell'emulatore e salvare l'output in risultati_nat/NOME.txt e risultati_bc/NOME.txt
./check_results.sh risultati_nat      # elenca i test che non finiscono con "Txx OK" + le righe FAIL
./diff_modes.sh risultati_nat risultati_bc   # nat e interprete devono dare output identici
```

Ogni programma stampa solo `FAIL <nome>` per le verifiche sbagliate (`EXN` = eccezione inattesa, `NOEXN` = eccezione attesa non sollevata)
e, in coda, `Txx OK` oppure `Txx FAIL`. `print_newline` emette CR (`\013`): gli script lo convertono.

## Cosa copre il "0 / 127 / 128 / 255"

Ho letto "byte" come campo *size* dell'header, in parole. Il campo è a 8 bit, quindi i punti critici sono:
`caml_alloc` con X=0 (atomo), 126→127→128 (riporto dell'`ASL` nel calcolo di `HEAP`), 254, e 255 (ramo speciale `INX → 0`).
Per le stringhe corrispondono a 0, 253/254/255 e 508/509 caratteri.

| File | Cosa esercita | Dimensioni usate |
|---|---|---|
| `t01a…e` | record di N campi: `MAKEBLOCK`, `GETFIELD n`, `SETFIELD n`, `Obj.size/tag`; varianti con tag≠size; tuple | 1–10, 126, 127, 128, 129, 254, 255 |
| `t01f,g` | record/array di soli float (`MAKEFLOATBLOCK`, `GETFLOATFIELD/SETFLOATFIELD`); letture ripetute che allocano (GC dentro `GETFFLDN`) | 1–4, 10, 84, 85 (85×3 = 255 parole) |
| `t02` | array di 127/128/255 puntatori vivi attraverso ~150 iterazioni di garbage da 255 parole; sharing fisico preservato | 127, 128, 255 |
| `t03a,b` | `Array.make/get/set/init/copy` e bounds, int e float; indici 0,1,126–129,253–256 | 0, 1, 2, 3, 126–129, 253–255 (float: 84, 85; 86 e 128 devono sollevare) |
| `t03c,d` | `sub/append/concat/blit` int e float, incluse sovrapposizioni e totali 255/256 | somme = 255 |
| `t03e` | stress: 150–250 iterazioni di `append/sub/concat/make/blit`, così il GC scatta dentro le primitive (puntatori interni / TMP non radici) | 200+55, 40+45 float |
| `t03f` | **blocchi di size 0**: `Array.make 0`, `sub _ _ 0`, `concat []`, `append [||] [||]`, `Obj.new_block 0 0`, atomi che sopravvivono al GC, stringhe vuote | 0 |
| `t04` | stringhe `make/get/set/to_string/^/sub`, tutti i confronti (anche tra blocchi distinti e uguali), padding `\000\001`, caratteri ≥128, `string_of_int` formato C64 | 27 lunghezze fino a 509; 510 deve sollevare |
| `t05a…d,f…h` | `CLOSURE n`, `ENVACC n` fino a 125, `CLOSUREREC` con v fino a 124 variabili libere, fino a 128 funzioni (2f−1 = 255), `OFFSETCLOSURE` ±254 | k 1…126; v 3…124; f fino a 128 |
| `t06a…r` | `SWITCH` con n costanti e/o blocchi, `match` su interi densi, `BEQ/BNEQ/BLT/BLE/BGT/BGE` con costanti ai bordi di byte (5, 133, 261, −123 hanno lo stesso byte basso), range di char | fino a 255 costanti |
| `t07a…n` | `ACC n` fino a ~250 (letterale array che spinge k−1 valori sopra k locali), `ASSIGN n`, `APPLY n`, `GRAB/RESTART`, `APPTERM n` con 300 iterazioni, ricorsione non in coda | fino a 126 locali, 125 argomenti APPLY, 63 argomenti APPTERM |
| `t07d,d2` | **sonda**: 200 / 260 locali in un'espressione non in coda (pulizia con `POP`, non `RETURN`); un errore `caml_range` qui indica il limite di POP/ACC, non un bug dei test | 200, 260 |
| `t08` | interi a 15 bit: wrap, `/` e `mod` con segni, shift, offset ±5/±300 (checksum per riga, 22 operatori × 28 valori) | −16384…16383 |
| `t09a,b` | eccezioni: `RAISE` da frame con 110/126 locali, trap bilanciati, payload, eccezioni dalle primitive | |
| `t10a,b` | Int32/Int64 (`stdlib_integers.asm`): 16 operatori × 19/13 valori di bordo (checksum per riga a chunk di 14 bit), `of_int/of_int32/to_int32`, `to_string`, `of_float` | min/max, 2³¹, 2³², ±1 |
| `t11a…d` | `compare` polimorfico: tuple (differenza in ogni posizione), liste fino a 200, array fino a 255, varianti, albero, Int32/Int64 (custom), float array | |
| `t12` | float: confronti con valori uguali in blocchi distinti, trunc verso zero, floor/ceil, frexp/ldexp, funzioni matematiche (tolleranza relativa 1e−6) | |
| `t13` | stress GC con alberi (255 nodi), liste, stringhe fino a 500, closure, matrici, catene di record | |
| `t14a…d` | `List`, `Array.sort`, `Buffer` (limite 509), `Map.Make` (c), `Set.Make` (d; separati perché in nativo la memoria per la pila non bastava), `Queue`, `Stack`, `String` | |
| `t90…t95` | **sonde di primitive mancanti o dubbie, un file ciascuno**: `Array.fill`, `Hashtbl.hash`, `Lazy`, `Hashtbl.Make`, `Float.Array`, `Obj` | |

I file sono piccoli di proposito (ogni programma deve stare nella RAM del C64, codice nativo incluso). Se uno è ancora troppo grande,
spezzare le liste in `gen/gen_tests.py` e rigenerare.

## Limiti del compilatore rispettati (da `caml_range` in `codegen.asm`)

Dal primo giro di build: `RETURN n` n ≤ 127 (n = argomenti + locali del frame), `MAKEBLOCK t s` s ≤ 255, `APPTERM n s` s ≤ 127
(per una chiamata ricorsiva in coda con p parametri s = 2p, quindi p ≤ 63). I generatori ora li rispettano:
le variabili locali non superano 124–126, i tipi misti hanno nc+nb ≤ 255, `lp` in coda arriva a 63 argomenti.
Rimossi i vecchi t05e, t07d (250), t09c (200). Restano non compilabili per primitive assenti: t10a,b, t11d, t14b, t90…t94 (attesi).

## Fallimenti che mi aspetto (dalla lettura dei sorgenti, non verificati)

| Test | Difetto sospetto |
|---|---|
| `t01a` varianti/tuple (solo interp) | `MAKEBLOCK n t` con n>3: ordine size/tag in `i3e` (se il fix non è nel file in uso) |
| `t01f,g`, `t03d` | `caml_MKFBLK` con s≥2 (avanzamento di BLK di 3 invece di 6 byte); `GETFFLDN` e `floatarray_get` con puntatore interno dopo `caml_alloc` |
| `t03a,b,e` | `caml_make_vect`: dopo `LDA ACCU; ROR` c'è `BEQ @noflo / JMP caml_mkatom0`. Mi sembra invertito (con lunghezza 0 si alloca, con lunghezza>0 si restituisce l'atomo). **Da controllare subito** |
| `t03c,e`, `t03f` | `array_sub/append/concat` con puntatori in TMP/ACCU interni (GC); `array_sub` con len 0 (`caml_alloc` con X=0, che richiede X>0, e `caml_blkcpy` con Y=0 che copierebbe 256 byte) |
| `t04` pool, `t12` t_cmp | confronti `<=`/`>` con valori uguali in blocchi distinti (`le_float`, `gt_float`, `string_lessequal`, `string_greaterthan`) |
| `t05a…e` (solo interp) | `ENVACC1-4`/`PUSHENVACC1-4` (base $2A invece di $28) e `ENVACC n` (operando n invece di 2n) |
| `t05f…h` (nativo) | `OFFSETCLOSURE n>0`: `caml_OFSCLN` usa `TXA` ma X non è inizializzato |
| `t06` (solo interp) | `SWITCH` senza indirezione sulla tabella; `BNEQ` (confronto del byte alto saltato se i byte bassi coincidono: usate 5 / 133 / 261 / −123) |
| `t07` (nativo) | `RETURN 0` con carry non azzerato |
| `t11b,c` | `compare_val`, ramo `.next_item`: dopo `LDA counter` c'è `BEQ +` che salta il pop dello stack quando il contatore è 0, e lo esegue quando è ≠0. Sembra invertito, **da verificare** con le tuple a 2–8 campi |
| `t11d` | `caml_compare_val_custom_tag` solleva `Not_found`; `double_array_tag` idem (TODO noti) |
| `t12` t_trunc | `int_of_float` con negativi: FACINX/QINT arrotondano verso −∞ (−2.9 → −3), OCaml tronca verso zero |
| `t90…t93` | primitive assenti: `caml_array_fill`, `caml_hash`, `caml_obj_make_forward` (Lazy) → errore di assemblaggio/link, non di esecuzione |
| `t94` | `caml_floatarray_blit` assente |
| `t10a,b` | `Int32.to_string`/`Int64.to_string` ecc. dipendono dal blocco OCaml attivo di `int32.ml/int64.ml` |

## Lettura dei risultati

- Un test **nativo OK / interprete FAIL** (o viceversa) è una divergenza tra i due runtime: `diff_modes.sh` le mette in evidenza.
- Se `t03a` fallisce subito con `EXN`, partire da `caml_make_vect`: molti altri test di array dipendono da `Array.make`/`init`.
- `t90…t95` vanno letti singolarmente: un errore di build lì indica la primitiva mancante, non un bug di runtime.
- I checksum di `t08` e `t10` segnalano la **riga** (`row i`, cioè il valore `vals.(i)` come primo operando) e l'operatore. Per localizzare la coppia
  basta stampare `vals.(i)` e ripetere l'operazione con gli `vals.(j)`.

## Limiti

- La memoria dell'emulatore non è modellata: `t13` e `t02` assumono una semi-area di almeno ~16 KB. Con meno memoria il parametro `150` (iterazioni) si abbassa nel generatore.
- `t11d` e `t10` usano letterali Int32/Int64 costanti: se `export.ml` non li supporta, l'errore sarà nella compilazione, non nel runtime.
- Per `t07`, `cnt 400` e `evn 300` assumono ~4 KB di pila disponibili.

## Esiti del primo giro (nativo, screenshot VICE)

OK: t01a–e, t01g, t03a, t05a–d,f–h, t06a–n, t07a–h,k–m, t07d (pop 200), t09b, t14c, t14d, t95.
Corretti nel generatore dopo il giro (errori dei test, non del runtime): confronti `bits` e `cls` (t06: le stringhe/char sono convertiti
in PETSCII, ora i valori attesi sono array di interi e le classi di char sono quelle PETSCII), pool di t04 (elemento 18 con maiuscole),
profondità di ricorsione di cnt/down/evn (t07n, t09a), limitate a 50–100 per la pila nativa.

## Aggiornamento dopo il primo giro nativo

- **Pila**: default 4 pagine (1 KB). `build.sh` legge `stack.conf` (righe `nome_test -stack N`) e passa i flag a `bcamlopt`/`bcamlc`.
  Ho messo `-stack 16` per t13, t14a, t14b, t11c e `-stack 8` per t07n, t09a; tarare in base ai risultati.
- **t07i** (probabile hang) diviso in `t07i1_apply_full_100` (solo `APPLY` con 100 argomenti), `t07i2_papply_100` (applicazione parziale 50+50),
  `t07i3_papply2_100` (1 argomento, poi 1, poi 98). `t07j1_apply_full_125` isola l'`APPLY` totale di t07j. Tempo atteso: pochi secondi in warp;
  oltre 1–2 minuti = hang. Se un file si blocca, il suo nome indica quale delle tre forme va in loop.
- **Diagnostici** (`t96…t9a`): stampano `nome got=X exp=Y` solo per i valori sbagliati, quindi mostrano che cosa restituisce il runtime.
  - `t96_diag_cmp`: `compare` su interi (versione specializzata `ci` e polimorfica `pc`), float, stringhe, tuple, liste, varianti, array
  - `t97_diag_float`: array di float di taglia 1,2,3,10,84,85 (make/get/set/oob/init/sub/append, letterali di 1–3 elementi)
  - `t98_diag_gc`: le quattro componenti di `garbage` di t02 e il totale con `land 16383` (atteso 11373)
  - `t99_diag_blit`: `Array.blit` stesso array e array diversi, con indice e valore del primo elemento errato
  - `t9a_diag_atoms`: uguaglianza fisica di atomi, `Obj.size/tag`, `blit` con n=0, atomi dopo GC

## Secondo giro (nativo)

- `t03a/b`: ora controllano il valore di riempimento subito dopo `Array.make` (prima veniva sovrascritto senza essere letto).
- `t9b_diag_make`: `Array.make` con costante, zero, variabile, negativo, float, tupla e stringa; per ogni taglia stampa quanti elementi sono errati e il primo indice.
- `t96_diag_cmp`: ogni confronto è protetto da `ex`, così uno `Stack_overflow` non interrompe i successivi.
- `stack.conf`: aggiunti `-stack 16` per t07i2, t07i3 e t07j.
