# The BreadCaml Project / *Progetto BreadCaml*
**Piero Furiesi** <p.furiesi@tiscali.it>

### Unreleased Alpha version
### Please wait for a stable release

| **OCaml for the Commodore 64** | ***OCaml per il Commodore 64*** |
| :--- | :--- |
| BreadCaml allows you to compile OCaml programs on Linux systems and generate native code for Commodore 64. | *BreadCaml consente di compilare su sistemi Linux programmi OCaml e generare codice nativo per Commodore 64.* |
| **Overview** | ***In breve*** |
| The BreadCaml Project's provides the `bcamlopt` and `bcamlc` cross-compilers for GNU/Linux systems.  `bcamlopt` compiles OCaml source files into standalone native code executables for the Commodore 64, while `bcamlc` generates standalone bytecode files with the associated interpreter, thus giving the developer the freedom to choose to optimize the executable for speed or file size. In both cases, the generated .PRG files contain a BASIC loader at the beginning, so that they can be simply loaded and run with the usual `LOAD "MYPROG.PRG",8` and `RUN` commands. In addition to the compilers, the BreadCaml Project includes a specially modified distribution of the OCaml Standard Library, the `bcamlppx` preprocessor, and (coming soon) libraries dedicated to graphics and sound. | *Il Progetto BreadCaml fornisce i cross-compilatori `bcamlopt` e `bcamlc` specifici per sistemi GNU/Linux. `bcamlopt` compila file sorgenti OCaml in codice nativo per il Commodore 64, mentre `bcamlc` genera file di bytecode con l'interprete associato, rendendo così lo sviluppatore libero di scegliere tra un file eseguibile più veloce o uno di dimensione inferiore. In entrambi i casi, i file .PRG generati contengono un caricatore in BASIC all'inizio e quindi sono semplicemente caricabili ed avviabili con i consueti `LOAD "MIOPROG.PRG",8` e `RUN`. Oltre ai compilatori, il Progetto BreadCaml comprende una distribuzione della Standard Library di OCaml appositamente modificata, il preprocessore `bcamlppx` e (prossimamente) delle librerie dedicate alla grafica e al suono.* |
| **Installation** | ***Installazione*** |
| See [INSTALL.md](INSTALL.md). | *Vedere [INSTALL.md](INSTALL.md) (in inglese).* |
| **Documentation** | ***Documentazione*** |
| The installation procedure generates manual pages for the `bcamlopt` and `bcamlc` compilers, the StdLib modules (`man 3bc module-name`), and for the `bcamlppx` preprocessor. Please read also [CAVEATS-LIMITATIONS-NOTES.md](CAVEATS-LIMITATIONS-NOTES.md) and [BUGS](BUGS). | *La procedura di installazione genera le pagine di manuale per i compilatori `bcamlopt` e `bcamlc`, i moduli della StdLib (`man 3bc nome-modulo`) e il preprocessore `bcamlppx`. Si consiglia di leggere anche [CAVEATS-LIMITATIONS-NOTES.md](CAVEATS-LIMITATIONS-NOTES.md) e [BUGS](BUGS).* |
| **License:** see [LICENSE-en](LICENSE-en) | ***Licenza:*** *vedere [LICENZA-it](LICENZA-it).* |
