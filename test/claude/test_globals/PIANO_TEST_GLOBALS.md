# Piano di test — globals fuori dallo heap (strategia 2)

## Cosa verifica ciascun test

| File | Cosa isola |
|---|---|
| `test1_global_ref.ml` | Caso base: un `ref` globale riassegnato a un blocco dinamico, profondità 1. |
| `test2_global_record.ml` | Record globale con due campi; uno porta a un `ref` dinamico (profondità 2 — combina il nuovo passo sui globals con lo scan dinamico normale). |
| `test3_global_array.ml` | Array globale ordinario (non-float): verifica che blocchi con tag < `No_scan_tag` tra i globals vengano scansionati campo per campo. |
| `test4_global_floatarray.ml` | Array di float globale (`Double_array_tag` ≥ `No_scan_tag`): verifica che il fast-path "salta i campi" non corrompa i dati su molte GC ripetute. |
| `test5_chain_stress.ml` | Stress: il campo del global viene riassegnato ad ogni iterazione per 200 cicli — il pattern più comune nel codice OCaml reale (stato mutabile top-level aggiornato funzionalmente). |
| `test6_baseline.ml` | **Nessun global mutato.** Serve a isolare una regressione generale (bound dello heap ricalcolati male) da un bug specifico del nuovo passo di scansione. |

## Come compilarli

Testa **entrambi** i compilatori: il GC è condiviso tra `bcamlc` e `bcamlopt` (non è sotto `!ifdef caml_INTERP`), quindi un bug qui può manifestarsi in entrambi.

```sh
bcamlc   test1_global_ref.ml -o test1.prg
bcamlopt test1_global_ref.ml -o test1_native.prg
```
(ripeti per gli altri file)

**Consiglio pratico**: usa un `--top-of-mem`/`--stack-pages` che ti lasci uno heap volutamente piccolo, così le GC scattano presto e spesso senza dover alzare troppo i contatori `churn_count` nei sorgenti — rende i test più veloci da eseguire sia in emulatore (VICE) sia su hardware reale.

Se un test non triggera GC a sufficienza con lo heap che hai scelto, alza la costante `churn_count` (o il numero di iterazioni in `test4`/`test5`) in testa al file.

## Output atteso

Ogni test stampa una riga diagnostica con i valori intermedi, poi `TN OK` o `TN FAIL`:

```
T1 5050 5050
T1 OK
T2 1275 999 1275 999
T2 OK
T3 465 465
T3 OK
T4 OK
T5 20100 200
T5 OK
T6 2505000
T6 OK
```

Qualunque `FAIL`, o qualunque valore diagnostico diverso da quello atteso, indica che un campo dentro un blocco dei globals non è stato aggiornato correttamente (puntatore stantio dopo una GC) — esattamente il bug che la strategia 2 introdurrebbe senza il nuovo passo di scansione.

## Come leggere un fallimento

- **Solo T6 fallisce, gli altri passano**: non è un problema dei globals — rivedi `.heap_start`/`.halfsz`/`.CUR_START`/`.OTH_START` in `memory.asm`, probabilmente i bound della GC "normale" sono stati ricalcolati male.
- **T6 passa, uno o più tra T1–T5 falliscono**: il problema è nel nuovo passo di scansione dei campi dei globals — ricontrolla i bound di inizio/fine (`caml_glob_data`/`caml_glob_end`), l'inizializzazione di `@PTR`, e il salto per `No_scan_tag`.
- **T4 fallisce da solo** (gli altri passano): il fast-path "salta i campi" per i blocchi `No_scan_tag` nel nuovo passo ha probabilmente un bound sbagliato (es. l'`ASL`/`ADC` che calcola l'avanzamento in byte) — i dati del float array vengono scavalcati o letti/scritti nel posto sbagliato.
- **T2 fallisce ma T1 passa**: il problema è specifico della raggiungibilità a profondità 2 — il nuovo passo probabilmente forward-a correttamente il campo diretto del globals ma non fa scattare la copia/scan ricorsiva del blocco dinamico puntato (verifica che la copia avvenga *prima* che parta il loop dello step 3, così che il blocco appena copiato venga poi scansionato normalmente).
- **T5 fallisce ma T1 passa**: il problema emerge solo con *molte* GC consecutive sullo stesso campo — possibile un bug che si accumula (es. un puntatore non completamente "canonicalizzato" dopo il forwarding, che alla GC successiva punta a un indirizzo nella metà sbagliata).
- **Crash anziché FAIL** (reset, comportamento anomalo) su uno qualsiasi: utile anche compilare con `-Dcaml_INTERP=1 -Dcaml_DEBUG=1` per vedere la traccia dell'interprete bytecode istruzione per istruzione nell'intorno del crash, come già previsto dai commenti in `loader.asm`.

## Test 7 — dimostrare il guadagno di memoria (OOM con strategia 1, OK con strategia 2)

`test7_oom_boundary.ml` non verifica la correttezza del nuovo passo di scansione (come T1–T6), ma il **vantaggio quantitativo**: uno stesso blocco che la strategia 1 rifiuta con `Out_of_memory` e che la strategia 2 accetta, a parità di `top_of_mem`/`stack_pages`.

Il programma contiene 6 stringhe letterali da 508 caratteri ciascuna (il massimo esportabile in un singolo blocco: il campo `size` dell'header è un byte, quindi al più 255 parole) — questo rende l'area globals `G` grande di proposito (~3 KB), per rendere ben visibile il margine `G/2` guadagnato dalla strategia 2. Poi prova ad allocare un array dinamico di `n` interi, tenuto vivo, dentro un `try ... with Out_of_memory`.

**Come trovare il punto di rottura, senza calcolare i byte a mano:**

1. Compila `test7_oom_boundary.ml` con `bcamlc` usando il *memory.asm attuale* (strategia 1) e un `top_of_mem`/`stack_pages` di tua scelta (abbastanza stretto da lasciare poco heap libero, altrimenti serve una `n` enorme per saturarlo).
2. Esegui, parti da `n` piccolo (es. 50) e aumentalo per tentativi finché non vedi `OUT OF MEMORY n=...` invece di `ALLOC OK n=...`. Annota quella `n` come `n_rottura_1`.
3. Senza cambiare nient'altro nel sorgente né `top_of_mem`/`stack_pages`, ricompila lo **stesso identico file** con il *memory.asm patchato* (strategia 2). Esegui con `n = n_rottura_1`: deve stampare `ALLOC OK`, non `OUT OF MEMORY` — questa è la dimostrazione diretta.
4. Opzionale: continua ad aumentare `n` anche sulla build patchata finché non trovi il suo punto di rottura `n_rottura_2`. La differenza `n_rottura_2 - n_rottura_1`, moltiplicata per 2 byte/parola, dovrebbe avvicinarsi a `G/2` (il `G` stampato a video dal programma stesso, diviso 2) — una verifica indiretta che il guadagno misurato corrisponde a quello previsto dalla formula.

**Se preferisci calcolare invece di cercare per tentativi**, compila con `-Dcaml_SHOWMEM=1` (menzionato nei commenti in cima a `loader.asm`): l'assembler ti mostra gli indirizzi effettivi di `caml_glob_data`, `caml_glob_end`, `caml_stack_start` per la tua build. Da lì:
```
T = caml_stack_start - caml_glob_data
G = caml_glob_end - caml_glob_data
utilizzabile_1 = T/2 - G
utilizzabile_2 = T/2 - G/2
```
e scegli `n` tale che `2*n + 2` (byte del blocco, header incluso) cada tra `utilizzabile_1` e `utilizzabile_2`.

Se con la tua configurazione di memoria non riesci a far scattare la differenza con un solo `Array.make` (max 512 byte per blocco singolo, per lo stesso limite di 1 byte sul campo size), tieni vivi due `Array.make` consecutivi invece di uno solo, oppure riduci `top_of_mem` in compilazione per restringere lo heap totale e rendere il margine `G/2` proporzionalmente più significativo.

## Nota sui primitivi usati

I test usano solo `ref`, `Array.make`/accesso indicizzato, `List.fold_left`/`List.length`, `print_string`/`print_int`/`print_newline` — niente `Printf` o moduli pesanti, per non dipendere da parti dello stdlib che potresti non aver ancora portato. Se anche `print_int`/`string_of_int` non fossero disponibili nel tuo sottoinsieme, sostituiscili con una tua routine di stampa cifra-per-cifra: la logica di verifica (i confronti `if ... then OK else FAIL`) resta identica e indipendente dall'I/O.
