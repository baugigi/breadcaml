# Installing O64ml on Linux

## Prerequisites:
1. [Bash shell](#1-bash-shell)
2. [OCaml LTS (Long Term Support) release 4.14.x](#2-ocaml-lts-long-term-support-release-414x)
3. [OByteLib package](#3-obytelib-package)
4. [ACME crossassembler (release 0.97 "Zem", 16 Nov 2025 or newer)](#4-acme-crossassembler-release-097-zem-16-nov-2025-or-newer)

### Installing/Configuring prerequisites:

#### **1) Bash** shell
and standard system commands are verified automatically by the configuration script.

#### **2) OCaml LTS (Long Term Support) release 4.14.x** 
* **Case 1: _OCaml is not installed_**

  Please refer to the [OCaml Installation Guide](https://ocaml.org/docs/installing-ocaml)
  to install OCaml on your system. Once installed, use Opam (the OCaml package manager)
  and follow **steps a) and b)** below to set up the LTS compiler switch.

* **Case 2: _OCaml is installed, but the LTS release is missing_**
      
  **a)** Create a new Opam switch (e.g., LTS) with the correct OCaml compiler version:
  ```bash
  opam switch create --formula='["ocaml" {< "5.0.0"}]' LTS
  ```
  **b)** Activate the newly created LTS switch:
  ```bash
  opam switch set LTS
  ```

* **Case 3: _OCaml 4.14.x is already installed_**
    
  Ensure the Opam switch with the LTS compiler release is active before proceeding.
  If it is not your default switch, activate it manually:
  ```bash
  opam switch set <your_LTS_switch_name>
  ```

> [!TIP]
> _To avoid running `opam switch set LTS` in every new terminal session, you can
> append the command to your `~/.bashrc` file._

#### **3) OByteLib package**
* Ensure that the **Opam switch** with the compiler's LTS release is active
  before proceeding. If it is not your default switch, activate it manually.
* Install OBytelib:
  ```bash
  opam update
  opam install obytelib
  ```

#### **4) ACME crossassembler (release 0.97 "Zem", 16 Nov 2025 or newer)**
* Verify your current installation and version by running:
  ```bash
  acme --version
  ```
* If ACME is missing or obsolete, the O64ml configuration script will offer to
  automatically compile and install a compatible release. Alternatively, you
  can download and install it manually from the
  [ACME Crossassembler SourceForge Project](https://sourceforge.net/projects/acme-crossass/).

> [!NOTE] 
> _Upgrading will not cause compatibility issues. Recent ACME releases include
> options to preserve backwards compatibility for older codebases (see the ACME
> documentation). Furthermore, the O64ml script will keep your existing release
> intact._

---

## O64ml INSTALLATION

* **Download and extract** the O64ml tarball, then navigate into the root directory of the source tree.
* Ensure that the **Opam switch** running the LTS compiler release is currently active.

### Option A: Quick and (not so) dirty
To install O64ml immediately using the default options, run:
```bash
./configure -y && make install clean
```

### Option B: Custom Installation
#### 1. Configure the system
```bash
./configure [OPTIONS]
```
| Option | Argument | Description |
| :--- | :---: | :--- |
| `-b`, `--bindir` | `<dir>` | Target directory for binaries |
| `-l`, `--libdir` | `<dir>` | Target directory for the O64ml library  |
| `-m`, `--mandir` | `<dir>` | Target directory for manual pages |
| `-p`, `--prefix` | `<dir>` | Shortcut for `-b <dir>/bin -l <dir>/lib/o64ml -m <dir>/man` |
| `-y`, `--yes`    |         | Automatically accept the ACME installation prompt |
| `-h`, `--help`   |         | Display the help message and default installation paths |

> [!IMPORTANT]
> _Omitting target directory options installs O64ml into the current Opam switch **(recommended)**.
> This defaults to the following directories: `~/.opam/<switch>/bin`, `~/.opam/<switch>/lib/o64ml`,
> and `~/.opam/<switch>/man`._  
> _If you need to customize the target directories, ensure you have the necessary write
> permissions. Additionally, make sure that end users have the required permissions to access
> and execute all installed files._

> [!NOTE]
> _If an obsolete ACME version is detected, the configuration script prompts for an upgrade.
> Upon confirmation (or if the `-y` option was passed), `./configure` will keep the old
> release intact if it resides outside the O64ml binary directory, and O64ml will use the new
> one._

#### 2. Build the system
Run the following command from the root directory:
```bash
make
```
#### 3. Install the system
This copies the `o64ml` binary, the O64ml Library files, and the man pages into your selected
target directories:
```bash
make install
```
#### 4. Clean up
Remove temporary build files to complete the installation:
```bash
make clean
```

---

## Uninstallation

To remove O64ml, run the following command from the root directory:
```bash
make uninstall
```

> [!WARNING]
>
> _Uninstallation will fail if the configuration file `./etc/Makefile.conf` is missing. If this
> occurs, re-run `./configure` using the same options specified during installation, then
> attempt to uninstall again._
