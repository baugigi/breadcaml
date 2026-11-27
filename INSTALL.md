# Installing BreadCaml on Linux

## Quick install

**Download and extract** the BreadCaml tarball, navigate into the root
directory of the source tree, and run:

```bash
./quickinstall
```

It runs the environment configuration script using default options and
automatically accepts  every installation proposed by  it: opam, OCaml
4.14.x, OByteLib, and ACME are installed  if they are missing.  In the
event of  a failure, or if  a configuration other than  the default is
required,  please  refer   to  the  [Manual  install](#manual-install)
section below for further details.

---

## Manual install

### Prerequisites
1. [System Requirements](#1-system-requirements)
2. [OCaml LTS (Long Term Support) release 4.14.x](#2-ocaml-lts-long-term-support-release-414x)
3. [OByteLib package](#3-obytelib-package)
4. [ACME crossassembler (release 0.97 "Zem", 16 Nov 2025 or newer)](#4-acme-crossassembler-release-097-zem-16-nov-2025-or-newer)

> [!TIP]
> _If opam, OCaml  4.14.x or OByteLib are missing, you  do not need to
> install them by hand: the_ `./configure` _script proposes to install
> them (see  below), as it  does for  ACME. The manual  procedures are
> described here for those who prefer them._

**Installing/Configuring prerequisites:**

#### **1) System Requirements**

A Bash  shell, the GNU coreutils  and standard commands as  `date` and
`which` are assumed to be installed on your system.

The configuration script  also requires and checks  for `ar`, `bzip2`,
`gcc`, `make`, `sed`, and `tar`.

#### **2) OCaml LTS (Long Term Support) release 4.14.x** 

* **Automatic installation:** `./configure`  checks for `opam`, for an
  `opam` switch with  OCaml 4.14.x,  and  for OByteLib.  For what  is
  missing, it proposes (or, with `-y`, just does) the following:
  - if  `opam`  is  not  installed, it  runs  the  official  installer
    (`https://opam.ocaml.org/install.sh`,  which  requires  `curl`  or
    `wget`): the  installer asks where to  put the binary and  may ask
    for your password;
  - if `opam`  has not  been initialised, it  runs `opam  init --bare`
    (without touching your shell configuration files);
  - if the active switch has no OCaml 4.14.x, it uses another existing
    switch that  has it (the default  switch is not changed),  or else
    creates the  switch `LTS` _(this  compiles OCaml and  takes several
    minutes);_
  - if OByteLib is not installed in that switch, it installs it.

  The environment of the chosen switch  (`eval $(opam env)`) is set up
  inside the script, and BreadCaml  is installed in that switch unless
  a target directory option is given.

* **Manual installation and set-up:**

  * **Case 1: _OCaml is not installed_**
    
	Please refer to the [OCaml Installation Guide](https://ocaml.org/docs/installing-ocaml)
    to install  `opam` (the OCaml  package manager) and OCaml  on your
    system. Once installed, use `opam`  and follow **steps a) and b)**
    below to set up the LTS compiler switch.

  * **Case 2: _OCaml is installed, but the LTS release is missing_**
      
    **a)**  **Create** a  new  `opam` switch  (e.g.,  `LTS`) with  the
    correct OCaml compiler version:
  
    ```bash
    opam switch create --formula='["ocaml" {>= "4.14.0" & < "5.0.0"}]' LTS
    ```

    **b)** **Select** the newly created LTS switch:
  
    ```bash
    opam switch set LTS
    eval $(opam env)
    ```
  
  * **Case 3: _OCaml 4.14.x is already installed_**
    
    Ensure that the  `opam` switch with the compiler's  LTS release is
    **selected** before proceeding.  If it is not your default switch,
    select it manually:
  
    ```bash
    opam switch set your_LTS_switch_name
    eval $(opam env)
    ```

> [!IMPORTANT]
> _The_  `eval $(opam  env)`  _step  is important  -  it updates  your
> shell's PATH and  other environment variables so  that the BreadCaml
> installation script uses_  `ocaml` _and other tools  pointing to the
> right  switch. Without  it, the  BreadCaml installation  process may
> fail._

> [!TIP]
> _Opam can register a shell hook that will automatically keep the
> shell environment up-to-date at every prompt. Please refer to the
> Opam documentation._

#### **3) OByteLib package**

* Ensure  that the `opam`  switch with  the compiler's LTS  release is
  **selected** before  proceeding. If it  is not your  default switch,
  select it manually.

* Install OByteLib:

  ```bash
  opam update
  opam install obytelib
  ```

#### **4) ACME crossassembler (release 0.97 "Zem", 16 Nov 2025 or newer)**

* Verify your current installation and version by running:

  ```bash
  acme --version
  ```

* If ACME  is missing or obsolete, the  BreadCaml configuration script
  will  offer  to  automatically  compile  and  install  a  compatible
  release.  
  Alternatively, you can download and install it manually from the
  [ACME Crossassembler SourceForge Project](https://sourceforge.net/projects/acme-crossass/).

> [!TIP] 
> _Upgrading will not cause compatibility issues. Recent ACME releases
> include  options  to  preserve  backwards  compatibility  for  older
> codebases (see the ACME  documentation).  Furthermore, the BreadCaml
> script will keep your existing release intact._

---

### BreadCaml installation

* **Download and  extract** the BreadCaml tarball,  then navigate into
  the root directory of the source tree.
* Ensure  that the `opam` switch  running the LTS compiler  release is
  currently **selected**.

#### 1. Configure the system

```bash
./configure [OPTIONS]
```

| Option | Argument | Description |
| :----- | :------: | :---------- |
| `-b`, `--bindir` | `<dir>` | Target directory for Breadcaml binaries |
| `-l`, `--libdir` | `<dir>` | Target directory for the BreadCaml Stdlib files |
| `-m`, `--mandir` | `<dir>` | Target directory for manual pages |
| `-d`, `--docdir` | `<dir>` | Target directory for HTML documentation |
| `-p`, `--prefix` | `<dir>` | Shortcut for `-b <dir>/bin -l <dir>/lib/breadcaml -m <dir>/man -d <dir>/doc/bcaml` |
| `-y`, `--yes`    |         | Automatically accept the installation proposals (ACME, opam, OCaml 4.14.x, OByteLib) |
| `-s`, `--silent` |         | Like `-y`, also do not display messages (except errors) |
| `-h`, `--help`   |         | Display the help message and default installation paths |

> [!IMPORTANT]
> _Omitting  target  directory  options installs  BreadCaml  into  the
> current  Opam  switch  **(recommended)**.    This  defaults  to  the
> following directories:_  
> `~/.opam/<switch>/bin`, `~/.opam/<switch>/lib/breadcaml`, `~/.opam/<switch>/man`.  
> _If you  need to customize  the target directories, ensure  you have
> the necessary  write permissions.  Additionally, make  sure that end
> users  have  the required  permissions  to  access and  execute  all
> installed files._

> [!NOTE]
> _If an obsolete  ACME version is detected,  the configuration script
> prompts for an upgrade.  Upon  confirmation (or if the_ `-y` _option
> was passed),_ `./configure` _will keep  the old release intact if it
> resides outside  the BreadCaml  binary directory, otherwise  it will
> rename it._

#### 2. Build the system

Run the following command from the root directory of the source tree:

```bash
make
```

#### 3. Install the system

This  copies the  `bcamlc`  and `bcamlopt`  compilers, the  `bcamlppx`
preprocessor, the BreadCaml library files, the man pages, and the HTML
documentation into your selected target directories:

```bash
make install
```

#### 4. Clean up

Remove temporary build files to complete the installation:

```bash
make clean
```

**Have fun with BreadCaml! :-)**

---

## Uninstallation

To remove BreadCaml **:'(** run the following command from the root directory
of the source tree:

```bash
make uninstall
```
