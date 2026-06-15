# Installing O64ml on a Linux machine

## PREREQUISITES

* The **Bash** shell, and some standard commands that the configuration script
  will check for.

    ---

* The **OCaml** LTS (Long Term Support) release **4.14.x**

    #### Case 1: $\textbf{\color{red}OCaml is not installed.}$

    Read the [OCaml Installation Guide](https://ocaml.org/docs/installing-ocaml)
    for information on installing OCaml.
  
    Then, **Install** it using Opam, the OCaml package manager, then **follow steps
    [a)](#a-create-a-new-switch-named-lts-with-the-right-ocaml-compiler-version)
    and [b)](#b-activate-the-newly-created-lts-switch)
    below** to create and activate a switch with the LTS compiler.

    #### Case 2: $\textbf{\color{YellowOrange}OCaml is installed, but you are missing the compiler's LTS release.}$

    ###### a) Create a new switch named `LTS` with the right OCaml compiler version:

    ```bash
    opam switch create --formula='["ocaml" {< "5.0.0"}]' LTS
    ```

    ###### b) Activate the newly created `LTS` switch:

    ```bash
    opam switch set LTS
    ```

    #### Case 3: $\textbf{\color{SeaGreen}OCaml 4.14.x is already installed.}$

    Great, just remember to **activate the Opam switch** with the compiler's LTS
    release, if it's not the default one:

    ```bash
    opam switch set <your_LTS_switch_name>
    ```

> [!TIP]
>> _If you want to avoid typing `opam switch set LTS` in every bash session, you
>> can add it to your `~/.bashrc` script._

---

* The **OByteLib** package

    Make sure that the Opam switch with the compiler's LTS release is the active
    one, then enter:
  
    ```bash
    opam update
    opam install obytelib
    ```

    ---

* The **ACME crossassembler**, release 0.97 ("Zem"), **16 Nov 2025** or newer

    You can **check** if it is installed and see its version by running:

    ```bash
    acme --version
    ```

    If it's not installed on your system or its version is obsolete, **the O64ml
    configuration script will propose to compile and install** a suitable release
    for you; or, if you prefer, you can download it from the
    [ACME Crossassembler SourceForge Project](https://sourceforge.net/projects/acme-crossass/)
    and install it manually.

> [!NOTE]
>> _Upgrading should not be an issue, as recent ACME releases have an option to
>> preserve the compatibility of code written for older ones (see the ACME
>> documentation); anyway, the O64ml script will preserve your old release._

---

## O64ml INSTALLATION

* **Download** the O64ml tarball and **extract** its contents, then **enter** the
  source tree top directory.

* Make sure that the **Opam switch** with the compiler's LTS release is the
  active one.

### A) QUICK AND (not so) DIRTY

At the shell prompt, type:

```bash
./configure -y && make install clean
```

O64ml should install with default options.

### B) THE NORMAL WAY

#### 1. Configure the system

```bash
./configure [OPTIONS]
```

| Option | Argument | Description |
| :--- | :--- | :--- |
| `-b`, `--bindir` | `<dir>` | Where the binaries will be installed |
| `-l`, `--libdir` | `<dir>` | Where the O64ml library will be installed |
| `-m`, `--mandir` | `<dir>` | Where the manual pages will be installed |
| `-p`, `--prefix` | `<dir>` | Shortcut for `-b <dir>/bin -l <dir>/lib/o64ml -m <dir>/man` |
| `-y`, `--yes` | _(none)_ | Assume that the answer to the question "install ACME?" is 'yes' |
| `-h`, `--help` | _(none)_ | Show help and default installation paths |

> [!IMPORTANT]
>> _Entering no options will cause the O64ml system to be installed
>> in the current Opam switch **(recommended)**, i.e. `~/.opam/<switch>/bin`,
>> `~/.opam/<switch>/lib/o64ml`, `~/.opam/<switch>/man`._
>
>> _If you need to customize the target directories, make sure you have
>> appropriate permissions on them. Also ensure that the O64ml final users
>> have appropriate permissions on all the installed files._

#### 2. Build the O64ml system

From the top directory, enter:

```bash
make
```

#### 3. Install the O64ml system

This will copy the `o64ml` command, the Standard Library files, and the man pages
into the directories selected in step 1. From the top directory, enter:

```bash
make install
```

If the ACME crossassembler is not installed on your system or is obsolete, the
configuration script will propose to install or upgrade it for you: just answer
**"Y"** (no question will be asked if you passed the `-y` option to `./configure`).

> [!IMPORTANT]
>> _If you have an obsolete ACME version in a directory other than the
>> O64ml binary installation directory, `./configure` will put the newer ACME
>> release in the latter, leaving the older version in its place; O64ml will use
>> the appropriate one._

#### 4. Clean up

Installation is complete, time to clean up. Enter:

```bash
make clean
```

---

## UNINSTALLATION

From the top directory, enter:

```bash
make uninstall
```

> [!WARNING]
>> _If the configuration file `./etc/Makefile.conf` is missing, the uninstallation
>> will fail. If so, re-run `./configure` with the same options you entered at
>> installation time, then try to uninstall O64ml again._
