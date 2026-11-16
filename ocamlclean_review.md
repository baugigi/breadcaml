# OCamlclean: static review


## 1. How the size reduction works (pipeline in `Export.OCamlclean.clean`)

Everything operates on the *main code* (the module initialisation code, executed
once, from instruction 0 up to STOP). Function bodies are never analysed; they
are only kept or dropped as a whole.

`compress_loop` (repeated until the code is stable):

1. `Step1.clean`: for each global with one SETGLOBAL and no whole-block read
   (only `GETGLOBAL g; GETFIELD f`), remove the (PUSH, ACC) pairs of the unused
   fields of the module block, shrink MAKEBLOCK (or turn it into ATOM) and
   renumber GETFIELD. This is what makes unused toplevel values of every stdlib
   module dead.
2. `Step2.clean`: `compute_deps` simulates the main code (accu producer + stack
   producers per instruction, with merging at joins) then removes instructions
   whose result is never used and which are side-effect free (`is_removable`,
   `Prim.no_side_effect`), cascading to their producers, and rewrites POP/ACC
   counts to match the removed pushes.
3. `Step3.clean`: reachability from 0; everything else (closure bodies of
   removed closures, dead code) becomes nop.
4. `Data.clean`: renumber used globals, drop unused ones, nop the SETGLOBAL of a
   never-read global.
5. `Cleanbra` (branch to next instruction), `Rmnop` (compaction + pointer remap).

Iteration matters: removing a CLOSURE makes its body unreachable, which frees
globals, which frees more block fields.

After the loop:

6. `Globalise.globalise_closures`: a module block whose global is read only
   through `GETGLOBAL g; GETFIELD f` is split into one global per field
   (`GETGLOBAL g'`), removing the block and the field accesses.
7. `Cleanenvs.clean_environments`: closures created in main code with an
   environment (`CLOSURE n>0`, `CLOSUREREC`) keep their free variables in new
   globals (SETGLOBAL at creation, ENVACC -> GETGLOBAL). Valid only for code
   that runs once (marks Valid = main code not in a cycle). `factor_globals`
   then shares globals that hold the same value.
8. A second `compress_loop`, and `Prim.clean` renumbers/prunes the primitive
   table (hard limit 256).

## 2. Findings

| # | Where | What | Confidence | Status |
|---|-------|------|-----------|--------|
| F1 | globalise.ml:30 | `POP (popn - nb_fields)` goes negative when two fields of the module block alias the same local (4 fields, 3 locals in t14b2p08). `compute_deps` then underflows -> `Error: tl`. The size-dependent behaviour is the number of toplevel values/aliases, not the function size. | Confirmed by the log (`POP -1` at instr 138); build fixed and tests pass in BC and NAT | Patched (clamped at 0) in `patches/ocamlclean-globalise.patch` |
| F2 | step2.ml, `CLOSURE`/`CLOSUREREC` in `compute_deps` | `use_stack_top n` / `use_stack_top cv` reads n stack slots but only n-1 are environment (the first is in the accu; the same line uses `pop s (n-1)`). Effects: (a) one unrelated slot is marked used (missed optimisation), (b) `List.nth` can raise `Failure "nth"` if the stack holds exactly n-1 entries. Also `if n > 0 then use_accu (); use_stack_top n` binds the `if` to `use_accu` only. | High (code reading) | Not patched; one-line fix `use_stack_top (n - 1)` (and `cv - 1`) |
| F3 | step2.ml, `PUSHTRAP` | The handler is analysed once with the stack as at PUSHTRAP. Stores done by `ASSIGN` inside the try body (mutable locals, i.e. `let r = ref ..` simplified by ocamlc) are invisible on the exception path. If an `ASSIGN` is observed only through the handler (e.g. `r := 1; maybe_raise; r := 2`, then `!r` after the `try`), its `used_by` is 0, `ASSIGN` is removable, and the handler sees the initial value. Main code only. | Confirmed: `oc03a_try_assign` failed in both BC and NAT before the fix, passes in both after it | Patched in `patches/ocamlclean-step2.patch` (`is_removable`: `ASSIGN _` is no longer removable) |
| F4 | data.ml | A SETGLOBAL of a never-read global becomes a nop, whereas `factor_globals` replaces SETGLOBAL by `CONSTINT 0` (SETGLOBAL leaves unit in the accu). Harmless unless the next instruction reads the accu. | Low | Not patched |
| F5 | step1.ml `prepare_code`/`compress_loop` | `prepare_code` mutates its input array (`old_code.(..) <- POP/ACC ..`), and `compress_loop` compares that same (mutated) array with the result to decide termination. Could stop one iteration early, never loop. | Low | Not patched |
| F6 | globalise.ml | The pattern (PUSH, ACC) used for the block fields includes, for the last field, the PUSH of the preceding local; this is why a block with duplicated/aliased fields breaks the counting (root cause of F1). `assert false` in `globalise` if the ACC pattern is not found. A cleaner fix would emit `POP popn`; the clamp keeps the author's convention and the later `compress_loop` removes the leftover pushes. | Medium | Documented |
| F7 | prim.ml / export.ml | `no_side_effect` is a whitelist of OCaml runtime names; BreadCaml-specific primitives are never removable (safe, only missed size). `Too many primitives` if > 256. | High | Information |
| F8 | step2.ml `is_removable` | `GETVECTITEM`, `GETSTRINGCHAR`, `GETBYTESCHAR` are removable although they may fault on a bad index; safe versions go through C primitives, so only unsafe accesses are affected. | High | By design |
| F9 | step2.ml `clean_code`, non-cleanable branch | `ACC n` and `POP n` offsets are recomputed with `compute_new_stack_top_size`, but `ASSIGN n` is not. Looks like an omission, only relevant if a slot below an `ASSIGN` target is removed. | Low (code reading, no test) | Not patched; to be checked |

Things checked and found consistent: stack effect of every instruction in
`compute_deps` against the real VM semantics (PUSH_RETADDR + APPLY n>3,
CLOSUREREC pushes, MAKEBLOCK/C_CALL n-1 pops, SETVECTITEM 2 pops);
`replace_envaccs` keeps the stack effect of `CLOSURE n` (SETGLOBAL + (ACC 0;
SETGLOBAL; POP 1)*(n-1)) and of `CLOSUREREC`; closures nested in function bodies
are never rewritten (the marks only follow main code), so per-call environments
are not globalised; `Rmnop` maps pointers that target a nop to the next live
instruction; `factor_globals` compares `data.(g) = Obj.repr 0` which is safe
(block vs immediate).

## 3. Tests

`ocamlclean_tests.zip` (10 programs, same prelude as the t14b tests, no
character literal compared with a raw code). Each prints `OCnn OK` / `FAIL`. All
checks are written at toplevel (main code) because function bodies are not
touched by the analysis.

| File | Probes |
|------|--------|
| oc01_alias | aliased toplevel values (F1/F6) |
| oc02_env | toplevel closures with env, CLOSUREREC with env (Cleanenvs) |
| oc03a_try_assign | F3: ASSIGN observed only on the exception path. A FAIL here confirms F3 |
| oc03b_loop_try | try inside a loop with mutable local |
| oc04_effects | DIV/MOD, bounds check, side effects must survive |
| oc05_closure_shallow | CLOSURE n at shallow stack (F2) |
| oc06_loops | main-code loops, local `let rec` with env |
| oc07_module | module block with unused/mixed fields, alias inside the module (Step1 + Globalise) |
| oc08_many | 14 toplevel functions + 7 aliases (the t14b2 shape) |
| oc09_exn | nested handlers and re-raise in main code |

Results (VICE, BC and NAT): oc01-oc09 all OK with patched `globalise` and
`step2`.

### Note:
The confirmation of the identified bugs, the patches to fix them, the testing,
and this report were all carried out with the help of Anthropic Claude.  As
things currently stand, no further miscompilations by OCamlclean have been
detected in the context of its use by BreadCaml.
