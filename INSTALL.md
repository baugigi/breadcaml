# Installing O64ml on Linux
## Prerequisites
* **Bash** shell, and standard system commands (verified automatically by the configuration script).

    ---

* **OCaml LTS (Long Term Support) release 4.14.x**
    #### Case 1: OCaml is not installed
    Please refer to the [OCaml Installation Guide](https://ocaml.org/docs/installing-ocaml)
    to install OCaml on your system. Once installed, use Opam (the OCaml package manager)
    and follow **steps a) and b)** below to set up the LTS compiler switch.

    #### Case 2: OCaml is installed, but the LTS release is missing
    **a) Create a new Opam switch named `LTS` with the correct OCaml compiler version:**
    ```bash
    opam switch create --formula='["ocaml" {< "5.0.0"}]' LTS
    ```

    **b) Activate the newly created `LTS` switch:**
    ```bash
    opam switch set LTS
    ```

    #### Case 3: OCaml 4.14.x is already installed
    Ensure the Opam switch with the LTS compiler release is active before proceeding.
    If it is not your default switch, activate it manually:
    ```bash
    opam switch set <your_LTS_switch_name>
    ```

> [!TIP]
> To avoid running `opam switch set LTS` in every new terminal session, you can
> append the command to your `~/.bashrc` file.

---

* **OByteLib package**
1. Ensure that the **Opam switch** with the compiler's LTS release is active
   before proceeding. If it is not your default switch, activate it manually.
2. Install OBytelib:
    ```bash
    opam update
    opam install obytelib
    ```

    ---

* **ACME crossassembler (release 0.97 "Zem", 16 Nov 2025 or newer)**

    Verify your current installation and version by running:
    ```bash
    acme --version
    ```

    If ACME is missing or obsolete, the O64ml configuration script will offer to
    automatically compile and install a compatible release. Alternatively, you
    can download and install it manually from the
    [ACME Crossassembler SourceForge Project](https://sourceforge.net/projects/acme-crossass/).
    
> [!NOTE]
> Upgrading will not cause compatibility issues. Recent ACME releases include
> options to preserve backwards compatibility for older codebases (see the ACME
> documentation). Furthermore, the O64ml script will keep your existing release
> intact.

---

## O64ml INSTALLATION
1. **Download and extract** the O64ml tarball, then navigate into the root directory of the source tree.
2. Ensure that the **Opam switch** running the LTS compiler release is currently active.

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
| :--- | :--- | :--- |
| `-b`, `--bindir` | `<dir>` | Target directory for binaries |
| `-l`, `--libdir` | `<dir>` | Target directory for the O64ml library  |
| `-m`, `--mandir` | `<dir>` | Target directory for manual pages |
| `-p`, `--prefix` | `<dir>` | Shortcut for `-b <dir>/bin -l <dir>/lib/o64ml -m <dir>/man` |
| `-y`, `--yes` | _(none)_ | Automatically accept the ACME installation prompt |
| `-h`, `--help` | _(none)_ | Display the help message and default installation paths |

> [!IMPORTANT]
> * Omitting options installs O64ml into the current Opam switch **(recommended)**. This
>   defaults to the following directories: `~/.opam/<switch>/bin`, `~/.opam/<switch>/lib/o64ml`,
>   and `~/.opam/<switch>/man`.
> * If you need to customize the target directories, ensure you have the necessary write
>   permissions. Additionally, make sure that end users have the required permissions to access
>   and execute all installed files.
> * If an obsolete ACME version is detected, the configuration script prompts for an upgrade.
>   Upon confirmation (or if the `-y` option was passed), `./configure` will keep the old
>   release intact if it resides outside the O64ml binary directory, and O64ml will use the new
>   one.

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
> Uninstallation will fail if the configuration file `./etc/Makefile.conf` is missing. If this
> occurs, re-run `./configure` using the same options specified during installation, then
> attempt to uninstall again.
