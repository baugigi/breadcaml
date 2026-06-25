# The BreadCaml Project / *Progetto BreadCaml*
**Piero Furiesi** <p.furiesi@tiscali.it>

### Unreleased Alpha version
### Please wait for a stable release

| **OCaml for the Commodore 64** | ***OCaml per il Commodore 64*** |
| :--- | :--- |
| BreadCaml allows you to compile OCaml programs on Linux systems and generate native code for Commodore 64. | *BeadCaml consente di compilare su sistemi Linux programmi OCaml e generare codice nativo per Commodore 64.* |
| **Overview** | ***In breve*** |
| The BreadCaml Project's main application is the `breadcaml` cross-compiler, specifically for GNU/Linux systems. It compiles OCaml source files into native code for the Commodore 64. The compiler can also generate bytecode files with the associated interpreter, thus giving the developer the freedom to choose between faster (but larger) executable files, or smaller executable files (at the expense of interpretation overhead). In both cases, breadcaml generates .PRG files containing a BASIC loader at the beginning, which can then be simply loaded and run with the usual `LOAD "MYPROG.PRG",8` and `RUN` commands. In addition to the compiler, the BreadCaml Project includes a specially modified distribution of the OCaml Standard Library and (coming soon) libraries dedicated to graphics and sound. | *L'applicazione principale del Progetto BreadCaml è il cross-compilatore `breadcaml`, specifico per sistemi GNU/Linux, che compila file sorgenti OCaml in codice nativo per il Commodore 64. Il compilatore è in grado anche di generare file di bytecode con l'interprete associato, rendendo così lo sviluppatore libero di scegliere tra file eseguibili con maggiore velocità di esecuzione (e occupazione di memoria) o file eseguibili di dimensione più ridotta (al prezzo del sovraccarico dovuto all'interpretazione). In entrambi i casi, breadcaml genera file .PRG contenenti un caricatore in BASIC all'inizio e quindi semplicemente caricabili ed avviabili con i consueti `LOAD "MIOPROG.PRG",8` e `RUN`. Oltre al compilatore, il Progetto BreadCaml comprende una distribuzione della Standard Library di OCaml appositamente modificata e (prossimamente) delle librerie dedicate alla grafica e al suono.* |
| **Installation** | ***Installazione*** |
| See [INSTALL.md](INSTALL.md). | *Vedere [INSTALL.md](INSTALL.md) (in inglese).* |
| **Documentation** | ***Documentazione*** |
| The installation procedure generates manual pages for the `breadcaml` compiler (readable with the `man breadcaml` command) and for the StdLib modules (`man 3bc module-name`). Please read also [CAVEATS-LIMITATIONS-NOTES.md](CAVEATS-LIMITATIONS-NOTES.md) and [BUGS](BUGS). | *La procedura di installazione genera le pagine di manuale per il compilatore `breadcaml` (leggibile con il comando `man breadcaml`) e per i moduli della StdLib (`man 3bc nome-modulo`). Si consiglia di leggere anche [CAVEATS-LIMITATIONS-NOTES.md](CAVEATS-LIMITATIONS-NOTES.md) e [BUGS](BUGS).* |
| **License:** see [LICENSE-en](LICENSE-en) | ***Licenza:*** *vedere [LICENZA-it](LICENZA-it).* |
