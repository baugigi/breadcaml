# Writing BreadCaml primitives: guidelines

**Audience:** authors of custom primitives (6502 assembly, ACME). Applies to
both back-ends (native code and bytecode interpreter). Sections 1-7 are about
heap allocation and GC safety; section 8 is about calling BASIC ROM routines
(including where to copy the data passed to them, and its checklist); section 9
collects the remaining conventions (integers, primitive table, purity, exit).

BreadCaml has two garbage collectors, chosen when the program is built with
`-gc`: **mark-and-compact** (the default; `memory_mc.asm`) and **stop-and-copy**
(Cheney[^1]; `memory_sc.asm`). Any call to `caml_alloc` may trigger a
collection, and with either collector a collection **moves every live block**.
A primitive is GC-safe if, at the moment of each `caml_alloc` call, it follows
the rules below, which hold for both collectors: they have the same roots and
the same view of the values in them, and differ only in how they work:

| | mark-and-compact (default) | stop-and-copy |
|---|---|---|
| heap | one space, about 8/9 of the area between the globals and the stack holds data (the rest is the block map and a table)[^3] | two semi-spaces: only half of the area is usable |
| moving | live blocks slide down, **keeping their order** in memory | live blocks are copied to the other half in the order they are reached |
| zero page used by the collector | `GC`..`GC+8` (`$3E-$46`), `$47-$48`, `BLK`, `HEAP` (restored) | `GC`..`GC+7` (`$3E-$45`), `BLK`, `HEAP` |

Do not rely on the order of blocks in memory after an allocation, even though
mark-and-compact preserves it: the program may be built with the other
collector. `TMP` is never touched by either of them.

## 1. The root set

The collector updates the following locations (the *roots*):

| Root                                   | Notes                                       |
|----------------------------------------|---------------------------------------------|
| `ACCU`                                 | the accumulator                             |
| `ENV`                                  | the current environment / closure           |
| Caml stack, from `SP` up to `caml_stack_end` | the **live** part only (see 4)        |
| Global table and global data           | scanned block by block                      |

Everything else is **not** a root and is **not updated**: `TMP`, `BLK`, `HEAP`,
the A/X/Y registers, other zero-page cells, the hardware stack (page 1), `PC`,
`XARGS`, `TRAPSP`, and any pointer you copied somewhere.

A 16-bit word in a root is interpreted by the collector as follows:

* **lsb = 1**: tagged integer, ignored;
* **lsb = 0** and **outside** the heap: ignored (code, static data, atoms, stack
  addresses such as `TRAPSP` frames);
* **lsb = 0** and **inside** the heap: pointer to **field 0** of a block (or to
  an infix block[^2]), which will be moved and updated.

So a root must never hold an arbitrary even value that happens to fall in the
heap range.

## 2. Rules, in short

1. **Before `caml_alloc`, every heap value you will still need afterwards must
   be reachable from a root**, and every root must hold a *valid value*: a
   tagged integer, or a pointer to field 0 of a block, or `caml_atom0`.
2. **Never keep, across a `caml_alloc`, a heap pointer in `TMP`, `BLK`, A/X/Y,
   another zero-page cell, or on the hardware stack** (`PHA`...). After the call
   it may be stale. `C = 1` on return means a GC happened. Reload such pointers
   from `ACCU`, `ENV` or `SP[i]` after the call.  (Non-pointer data in `TMP`
   survives: the collector does not use `TMP`.)
3. **`ACCU` must hold a valid value at the call.** In particular it must not be
   an *interior* pointer (e.g. to any *n*th field in a block, *n > 0*), nor a
   pointer whose high byte you decremented to access the block header (`DEC
   ACCU+1` `LDY #$FE` `LDA (ACCU),Y`...).  Restore it **before** `JSR
   caml_alloc`.
4. **Do not pop the primitive's arguments before allocating and then use them.**
   Arguments stay on the Caml stack until the primitive returns (`CCALL` pops
   them afterwards). A slot popped with `INC SP` lies *below* `SP`: it is dead,
   not scanned, not updated. Read `SP[i]` again **after** the allocation if you
   need the pointer. The same holds for any value you push: it is live only
   while it is at an address >= `SP`.
5. **The new block must be initialised with valid values before the next
   `caml_alloc`** if its tag is `< No_scan_tag` (251): the collector scans its
   fields. A tagged integer (e.g. `Val_zero`) is enough. Blocks with a
   non-scanned tag (`String_tag`, `Double_tag`, `Custom_tag`, ...) need only a
   correct size; their contents are not read.
6. **The new block must be reachable from a root before the next `caml_alloc`**
   *if you still need it*: `JSR caml_load_newblk` (ACCU := BLK) or store it into
   a stack slot. `BLK` is **not** a root. A block that is not reachable is
   simply collected.
7. **Size**: `X = 1..255` words. For zero-size use the atom (`caml_mkatom0`);
   never call `caml_alloc` with `X = 0`. Strings: at most 509 bytes.
8. **Pointers kept in roots must point to field 0** of a block. The only allowed
   exception is an *infix* pointer produced by `CLOSUREREC`

## 3. What `caml_alloc` does and returns

```asm
        ;; in:  A = tag, X = size (words, > 0)
        JSR caml_alloc
        ;; out: BLK = &Field(new,0),  A = X = size,  Y = 0,
        ;;      C = 1 iff a garbage collection took place,
        ;;      the header (tag, size) is written; the fields are NOT initialised.
```

* It clobbers the zero-page bytes starting at `GC` ($3E-$45; mark-and-compact
  also uses `$46-$48`, see the table in the introduction).
* `Y` is **not** required to be 0 on entry (e.g. `CLOSURE` calls it with `Y` =
  high byte of the code pointer): `caml_alloc` loads `Y = 0` before starting a
  collection, because the collector's loops rely on it. Anything *you* call
  that is not `caml_alloc` follows its own contract.
* If there is no room even after a collection it raises `Out_of_memory` (it does
  not return).
* There is no write barrier: the collector is not generational, so storing into
  a field of an old block needs no special action.

## 4. Why only the live stack counts

The collector scans the stack from `SP` to `caml_stack_end` (exclusive). The
area below `SP` is **dead** and is neither scanned nor updated. Never rely on
it, and never leave in the live area a word that is neither a tagged integer, a
valid pointer, nor an out-of-heap value.

## 5. Examples

Each example is a small, self-contained primitive. In all of them the Caml
arguments follow the usual convention: first argument in `ACCU`, the others on
the Caml stack (`SP[0]`, `SP[1]`, ...), popped by `CCALL` **after** the
primitive returns. `Y = 0` on entry; on exit `Y` can have any value: `CCALL`
resets it (and clears the decimal flag).

### 5.1: clone a block (header access via hi-byte decrement of `ACCU`)

`caml_clone`: `ACCU` = a block with at least one field (not an atom); returns a
shallow copy. The size and tag live in the two bytes just before field 0, which
the code reaches with `(ACCU),Y` and `Y = $FF/$FE` after decrementing `ACCU+1`.

**Wrong**

```
caml_clone
        LDY # -1                ;Y = $FF
        DEC ACCU + 1            ;ACCU+1 decremented: (ACCU),Y with Y = $FF/$FE
        LDA (ACCU),Y            ;  reaches the header (access to the size field)
        TAX                     ;X := size
        DEY
        LDA (ACCU),Y            ;A := tag
        LDY # 0
        JSR caml_alloc          ;WRONG: ACCU still has its hi byte decremented,
                                ;  so it is NOT a pointer to field 0 of a block.
                                ;  If a GC runs, the collector follows a bogus
                                ;  pointer (or misses the source block).
        TXA
        ASL
        TAY
        JSR caml_blkcpy         ;(Copies from ACCU: also wrong after the GC)
        JMP caml_load_newblk
```

**Right**

```
caml_clone
        LDY # -1
        DEC ACCU + 1            ;Temporary hi-byte decrement, only to read the
        LDA (ACCU),Y            ;  header: size...
        TAX                     ;X := size
        DEY
        LDA (ACCU),Y            ;...and tag, A := tag
        INC ACCU + 1            ;RESTORE ACCU before allocating (INC does not
        LDY # 0                 ;  change A): ACCU = pointer to field 0 again
        JSR caml_alloc          ;ACCU is a valid root: updated if a GC runs
        TXA                     ;A := size (caml_alloc returns A = X = size)
        ASL
        TAY                     ;C:Y := 2 * size = no. of bytes to copy
        JSR caml_blkcpy         ;Copy from ACCU (post-GC address) to BLK
        JMP caml_load_newblk    ;ACCU := the copy
```

### 5.2: box element 1 of a float array (internal pointer to field n, n > 0)

`caml_second_float`: `ACCU` = float array (at least 2 elements); returns a new
boxed float holding element 1. Element 1 starts at `Field(ACCU, 3)`, i.e. 6
bytes (`2 * Double_wosize`) after the start of the block.

**Wrong**

```
caml_second_float
        LDA ACCU
        CLC
        ADC # 2 * Double_wosize ;ACCU := &Field(ACCU,3): the pointer is used as
        STA ACCU                ;  an internal pointer to field n, n > 0
        BCC +
        INC ACCU + 1
+       LDX # Double_wosize
        LDA # Double_tag
        JSR caml_alloc          ;WRONG: ACCU does not point to field 0 of a
                                ;  block. If a GC runs, it treats ACCU as the
                                ;  start of a block (reads a bogus header) and
                                ;  the array is not updated correctly.
        +caml_move_float ACCU, BLK
        JMP caml_load_newblk
```

**Right**

```
caml_second_float
        LDX # Double_wosize
        LDA # Double_tag
        JSR caml_alloc          ;ACCU = start of the array: valid root,
                                ;  updated by the GC if one runs
        LDA ACCU                ;Only NOW build the internal pointer to
        CLC                     ;  Field(ACCU,3): no allocation follows
        ADC # 2 * Double_wosize
        STA ACCU
        BCC +
        INC ACCU + 1
+       +caml_move_float ACCU, BLK  ;Float(BLK) := Float(&Field(ACCU,3))
        JMP caml_load_newblk    ;ACCU := the new box (overwrites the internal
                                ;  pointer)
```

### 5.3: build a pair (argument pointer cached in `TMP`, argument slot popped)

`caml_pair`: `ACCU` = `a`, `SP[0]` = `b`; returns the pair `(a, b)`.

**Wrong**

```
caml_pair
        LDA (SP),Y              ;1) b is copied into TMP before the
        STA TMP                 ;   allocation: TMP is not a root, so it
        INY                     ;   is stale if a GC runs
        LDA (SP),Y
        STA TMP + 1
        LDA SP                  ;2) The primitive pops b's slot itself: the
        CLC                     ;   slot is now below SP (dead, not scanned
        ADC # 2                 ;   nor updated), and CCALL will pop it AGAIN
        STA SP                  ;   after the return, corrupting the stack
        BCC +
        INC SP + 1
+       LDX # 2
        LDA # 0
        LDY # 0
        JSR caml_alloc          ;WRONG: b may have moved; TMP keeps the old
		                        ;  address.
        ...                     ;Store ACCU and TMP in the new block
```

**Right**

```
caml_pair
        LDX # 2
        LDA # 0
        JSR caml_alloc          ;a is in ACCU and b is in SP[0] (a live stack
                                ;  slot): both are roots, both are updated
        LDA ACCU                ;Field(new,0) := a  (read after the allocation)
        STA (BLK),Y             ;Y = 0 after caml_alloc
        INY
        LDA ACCU + 1
        STA (BLK),Y
        LDY # 0
        LDA (SP),Y              ;Field(new,1) := b, read from the stack AFTER
        LDY # 2                 ;  the allocation (post-GC address)
        STA (BLK),Y
        LDY # 1
        LDA (SP),Y
        LDY # 3
        STA (BLK),Y
        LDY # 0
        JMP caml_load_newblk    ;ACCU := (a, b); CCALL pops b's slot afterwards
```

### 5.4: build the list `[x; y]` (new block only in `TMP`, uninitialised field across a second allocation)

`caml_two_list`: `ACCU` = x, `SP[0]` = y; returns `[x; y]` (two cons cells,
tag 0, size 2;`[]` is `Val_zero`).

**Wrong**

```
caml_two_list
        LDX # 2
        LDA # 0
        JSR caml_alloc          ;cell1
        LDA BLK
        STA TMP                 ;1) cell1 addr. kept only in TMP/BLK: not roots!
        LDA BLK + 1
        STA TMP + 1
        LDA ACCU                ;Field(cell1,0) := x
        STA (BLK),Y
        INY
        LDA ACCU + 1
        STA (BLK),Y             ;2) Field(cell1,1) left uninitialised!
        LDX # 2
        LDA # 0
        LDY # 0
        JSR caml_alloc          ;WRONG: 1) cell1 is not reachable from any root,
                                ;  so a GC discards it and TMP becomes stale;
                                ;  2) even if it were reachable, the collector
                                ;  would scan its uninitialised Field(1) as if
                                ;  it were a pointer.
```

**Right**

```
caml_two_list
        LDX # 2
        LDA # 0
        JSR caml_alloc          ;cell1 (fields not yet valid, but no allocation
                                ;  happens before they are filled)
        LDA ACCU                ;Field(cell1,0) := x
        STA (BLK),Y
        INY
        LDA ACCU + 1
        STA (BLK),Y
        INY
        LDA # <Val_zero         ;Field(cell1,1) := [] : a valid placeholder
        STA (BLK),Y             ;  (tagged integer) until the real tail exists
        INY
        LDA # >Val_zero
        STA (BLK),Y
        LDY # 0
        JSR caml_load_newblk    ;ACCU := cell1: now a root (and fully valid)
        LDX # 2
        LDA # 0
        JSR caml_alloc          ;cell2. A GC may run: ACCU (cell1) is updated
        LDY # 0
        LDA (SP),Y              ;Field(cell2,0) := y, read from SP[0] after
        STA (BLK),Y             ;  the allocation
        INY
        LDA (SP),Y
        STA (BLK),Y
        INY
        LDA # <Val_zero         ;Field(cell2,1) := []
        STA (BLK),Y
        INY
        LDA # >Val_zero
        STA (BLK),Y
        LDY # 2                 ;Field(cell1,1) := cell2, with cell1 reloaded
        LDA BLK                 ;  from ACCU (updated by the GC)
        STA (ACCU),Y
        INY
        LDA BLK + 1
        STA (ACCU),Y
        LDY # 0
        RTS                     ;ACCU = cell1 = [x;y]
```

### 5.5: wrap a value (pointer saved on the 6502 hardware stack)

`caml_wrap`: `ACCU` = v;returns a new 1-field block (tag 0) containing v.

**Wrong**

```
caml_wrap
        LDA ACCU
        PHA                     ;v saved on the hardware stack (page 1):
        LDA ACCU + 1            ;  not a root, never updated by the GC
        PHA
        LDX # 1
        LDA # 0
        JSR caml_alloc          ;WRONG: if a GC runs, the saved copy of v
        PLA                     ;  is stale (old address)
        STA (BLK),Y             ;(Y = 0: this stores the hi byte first: also a
        ...                     ;  bug, kept here only for brevity)
```

**Right**

```
caml_wrap
        LDX # 1
        LDA # 0
        JSR caml_alloc          ;ACCU = v is a root: updated if a GC runs
        LDA ACCU                ;Read v AFTER the allocation
        STA (BLK),Y             ;Field(new,0) := v   (Y = 0)
        INY
        LDA ACCU + 1
        STA (BLK),Y
        LDY # 0
        JMP caml_load_newblk    ;ACCU := the new block
```

## 6. Checklist before each `JSR caml_alloc`

- [ ] `ACCU` and `ENV` hold valid values (integers or pointers to field 0).
- [ ] No `DEC ACCU+1`-style shifted or interior pointer is in any root.
- [ ] Every argument I still need is still on the stack at an address >= `SP`.
- [ ] No heap pointer is cached in `TMP`, `BLK`, A/X/Y, other zero-page cells or
      on the hardware stack.
- [ ] If a block I allocated earlier is still needed, it is in `ACCU` or on the
      stack, and its fields (tag < 251) already hold valid values.
- [ ] `X` is in `1..255`.

## 7. Checklist after `JSR caml_alloc`

- [ ] Reload every needed heap pointer from `ACCU`, `ENV` or `SP[i]` (the cached
      copies may be stale; `C = 1` tells you a GC ran).
- [ ] Initialise the new block's fields before any further allocation.
- [ ] Put the new block in `ACCU` (`caml_load_newblk`) or on the stack as soon
      as it must survive another allocation.

## 8. Calling BASIC ROM routines (floating point and others)

The floating point primitives rely on the routines of the C64 BASIC ROM
(`C64_FADDT`, `C64_FMULT`, `C64_EXP`, `C64_FCOMP`, `C64_GIVAYF`, `C64_FOUT`...,
see `c64defs.asm`). A custom primitive may call them too, but the following
rules must be observed. (KERNAL routines, e.g. `C64_CHROUT`, are always visible
and are called with a plain `JSR`: the rules below concern the BASIC ROM only.)

### 8.1 Always call them through `+caml_JSR_BASROM`

```
        +caml_JSR_BASROM C64_EXP        ;never: JSR C64_EXP
```

If the program, stack included, reaches `$A000` (`caml_stack_end > C64_BASROM`,
flag `caml_basic_rom_overlap` set by the loader), the BASIC ROM is kept
*switched off* and the RAM under it is visible. The macro switches the ROM on
around the call, using a wrapper in safe memory if the calling code itself
lies in `$A000-$BFFF`. If there is no overlap it expands to a plain `JSR`.
In every case `A` and the status flags returned by the ROM routine reach the
caller unchanged, and `X`, `Y` are not touched by the wrapper. The expansion
has a size which depends on the address where it is assembled (3, 9 or 15
bytes): do not assume it in branch distances.

### 8.2 Operands read by the ROM must not be in `$A000-$BFFF`

With the ROM switched on, a ROM routine that *reads* an address in
`$A000-$BFFF` reads the ROM, not the RAM under it. A float block, or a string,
passed by address (`MOVFM`, `FADD`/`FSUB`/`FMUL`/`FDIV`/`FCOMP`/`FPWRT` with
`A`/`Y` = address, `FIN`, `STROUT`...) may be there. Under
`!ifdef caml_basic_rom_overlap`, copy the operand to the zero page first and
pass the address of the copy (as `caml_compare_val_double_tag` does for
`FCOMP`):

```
!ifdef caml_basic_rom_overlap {
        LDY # 4                         ;copy the 5 bytes of the float
-       LDA (.V2),Y                     ; to TMP + 8 .. TMP + 12
        STA TMP + 8,Y
        DEY
        BPL -
        LDA # TMP + 8                   ;A/Y = address of the copy
        LDY # 0
} else {
        LDY .V2 + 1                     ;A/Y = address of the float
        LDA .V2
}
        +caml_JSR_BASROM C64_FCOMP
```

Writing is not a problem: stores always go to the RAM (`MOVMF` into a heap block
is fine). Remember that the GC may move the block: the copy must be made from
a pointer reloaded from `ACCU`/`SP[i]` (see sections 2-7). Where to put the
copy is the subject of 8.6.

### 8.3 Float operands: use `caml_float_unop` / `caml_float_binop`

A float block is 6 bytes: the 5 bytes of the C64 MFLPT number and a *flag byte*
(`Float_flag`): 0 finite, `Fl_pinf`, `Fl_ninf`, `Fl_nan` (see `loader.asm`).
The ROM knows nothing of infinity and nan, so `caml_float_unop` (copy `ACCU` to
FAC) and `caml_float_binop` (copy `SP[0]` to FAC and `ACCU` to ARG) return
`C = 1` if an operand is special: the primitive must then handle that case
without calling the ROM (`JMP caml_float_special1` / `caml_float_special2` for
the standard operations, or its own code). Skeleton of a unary primitive:

```
!ifdef caml_PRIM__caml_nonstd_my_exp {
caml_nonstd_my_exp
        JSR caml_float_unop             ;FAC := ACCU; C=1 if inf or nan
        BCC @fin
        LDX # Fu_EXP                    ;special value: standard behaviour of exp
        JMP caml_float_special1         ; (or write your own code and RTS)
@fin    LDX # Fo_EXP                    ;if the ROM overflows: return +infinity
        STX caml_float_overflow__op
        +caml_JSR_BASROM C64_EXP
        JMP caml_float_alloc_result     ;new float := FAC, ACCU := new float
}
```

`caml_float_alloc_result` allocates the result and copies FAC into it; the GC
does not touch FAC/ARG, so allocating between the ROM operation and `MOVMF` is
safe. Both `unop` and `binop` must be called **directly** from the primitive
(one `JSR` level): they save the CPU stack pointer that the overflow handler
will restore (see 8.5), so nothing may be left on the hardware stack between
that call and the ROM call.

### 8.4 Zero page used by the ROM routines

The FP routines of the ROM clobber, besides FAC/ARG: `$12`, `$22-$2A`, `$47`
(`FOUT` overwrites it, and `$48`), and the whole area from `TMP + 9` (`$56`)
to `TMP + 37` (`$72`): `FAC` is at `TMP + 20 .. TMP + 26`, `ARG` at
`TMP + 28 .. TMP + 34`. The table at the top of `stdlib_floats.asm` lists every
location. Consequently:

- do not keep anything across a ROM call in `TMP + 9 ... TMP + 37`: `TMP + 0 .. 8`
  and `TMP + 10 .. 14` are not touched by the arithmetic routines (the
  PETSCII conversion routines, `FIN`/`FOUT`, use `TMP + 15 .. 19`);
- the runtime registers (`ACCU`, `SP`, `ENV`, `TRAPSP`, `XARGS`, `GC`, `HEAP`,
  `BLK`) are not used by the ROM FP routines, with the sole exception of
  `FOUT`, which overwrites `$47-$48`.
- the ROM does not preserve `Y`: a primitive does not need to restore it, as
  `CCALL` sets `Y = 0` when the primitive returns (but see `Y = 0` where you
  *use* it as an offset after a call: reload it).

### 8.5 Errors raised by the ROM never come back

The loader redirects the BASIC error vector (`C64_IERROR`) to `caml_syserr`.
If a ROM routine fails, control goes to `caml_syserr` with the error number in
`X`, and **does not return to the primitive**:

| BASIC error | Result |
|---|---|
| DIVISION BY ZERO | `Division_by_zero` |
| ILLEGAL QUANTITY | `Invalid_argument "ILLEGAL QUANTITY"` |
| OUT OF MEMORY | `Out_of_memory` |
| OVERFLOW | see below |
| any other | `Sys_error` with the BASIC message |

The exception is raised with the CPU stack reset to its value at program start
(`caml_hw_stack_ptr`): so, before a ROM call, do not leave anything that must be
undone on the hardware stack or in memory (e.g. an `SEI`, a modified vector, a
bank switch...).

**OVERFLOW.** If `caml_float_overflow__op` holds a known operation (`Fo_ADD`,
`Fo_MUL`, `Fo_POW`, `Fo_EXP`, `Fo_STR`), `caml_float_overflow` computes the
infinity with the right sign, restores the CPU stack pointer saved by
`caml_float_unop`/`binop` and returns +-infinity *to the caller of the
primitive*. With `Fo_NONE` it returns to `caml_syserr`, which raises
`Sys_error "OVERFLOW"`. The contract is:

- `caml_float_unop` and `caml_float_binop` set `caml_float_overflow__op` to
  `Fo_NONE` and save the stack pointer: a primitive whose operation has no
  rule for the sign of infinity just calls the ROM (the error is raised);
- a primitive whose operation matches one of the `Fo_*` rules sets
  `caml_float_overflow__op` after `unop`/`binop`, as in the skeleton above;
- a primitive that calls a ROM routine which may overflow **without** going
  through `unop`/`binop` (nor `float_of_string`) MUST set both
  `caml_float_overflow__op` (to `Fo_NONE`, normally) and `caml_float_overflow__sp`
  (`TSX : STX caml_float_overflow__sp`, executed in the primitive itself: the
  `INX : INX` in `unop`/`binop` account for their own return address).
  `caml_float_overflow__op` is reset only after an overflow has been handled,
  not after a normal return: a stale value would make the handler use a stale
  stack pointer.

### 8.6 Where to copy the data passed to ROM routines

Never leave a ROM operand, or the buffer a ROM routine writes to, in the
primitive's own code or data area (`!fill`, `!byte`...: if the program reaches
`$A000` they may lie under the ROM, and the ROM would read itself), nor in the
heap or the global data (same problem, and the GC moves them). Use a scratch
area in RAM that is always visible and that satisfies all of the following:

1. it is **below `$A000`** and outside the program: zero page and pages 1-3
   qualify, the program starts at `$0801`;
2. it is **not written by the ROM routine** you are about to call (8.4);
3. it is **not in use** by the runtime, the standard library or data that must
   survive the call.

The areas, from the smallest:

| Area | Size | Use and caveats |
|---|---|---|
| zero page cells of `TMP` that the FP routines leave alone (8.4) | a few bytes | enough for one 5-byte float operand. |
| low page 1, above the ROM's own output | 10-16 bytes | the ROM builds the `FOUT` result at `$0100` and uses the area above it for conversions: use it only when no `FOUT` result is needed (`stdlib_format.asm` keeps two 5-byte floats at `$0110` and `$0115`). This relies on the CPU stack, which grows down from the top of the page, not reaching it: keep `JSR` nesting shallow. |
| BASIC input buffer, `C64_BUF` (`$0200-$0258`) | 89 bytes | the natural place for strings passed to `FIN`/`STROUT`-like routines (up to 88 characters + the terminating 0). It holds the command line read by `Sys.argv` until module `Sys` is initialised (`caml_nonstd_sys_argv`), so do not overwrite it before that; the float conversions in `stdlib_floats.asm` already use it. |
| cassette buffer, `C64_TBUFFR` (`$033C-$03FB`) | 192 bytes | not used by the runtime, the standard library or c64lib; free unless the program does tape I/O. The best choice for large or long-lived scratch data. |

Procedure: reload the source pointer from a root (`ACCU`, `SP[i]`) *after* any
`caml_alloc`, copy to the scratch area, pass its address (`A`/`Y`, or `$7A/$7B`
for `FIN`), call the ROM routine with `+caml_JSR_BASROM`. If the routine writes
a result into the area, allocate the heap block **first**, then copy the result
into it with the pointer reloaded again.

### 8.7 Checklist for ROM calls

- [ ] `+caml_JSR_BASROM`, never a bare `JSR`, for BASIC ROM routines.
- [ ] Memory operands copied to a scratch area (8.6) under
      `caml_basic_rom_overlap`, from pointers reloaded after any `caml_alloc`;
      never to the primitive's own code/data area, the heap or the globals.
- [ ] Float arguments loaded with `caml_float_unop`/`caml_float_binop`, called
      directly from the primitive; special values handled when `C = 1`.
- [ ] `caml_float_overflow__op` set for the operation (or left `Fo_NONE`).
- [ ] Nothing kept in `TMP + 9 .. TMP + 37`, `$12`, `$22-$2A`, `$47-$48` across
      the call; nothing on the hardware stack to be undone after it.

## 9. Other conventions

**Integers are 15 bits.** `Val_int` values range from -16384 to 16383. A raw
16-bit quantity (a cycle count, an address, a word read from the hardware) that
is shifted into `Val_int` silently wraps if it exceeds that range: return a
scaled value (e.g. `Sound.frame_cycles` returns half of the cycles of a frame,
at most 10140) or split it into two results. In OCaml code the assembler
rejects literals out of range (`BGTINT n p: n out of range`).

**At most 256 primitives per program.** `CCALL` receives the primitive's index
in a single byte and uses it to read the low/high address tables. The primitives
declared with `external` in the linked modules count, plus those that the
compiler generates itself (string and array accessors, polymorphic comparison,
...). The `Prim.jumptbl` line of `-showmem` is the table (two bytes per entry).

**Purity and `ocamlclean`.** `ocamlclean` may delete a call whose result is not
used, only for the primitives listed as free of side effects
(`Prim.no_side_effect`, see `ocamlclean-prim.patch`). Add a new primitive there
only if it neither changes memory or hardware state nor *consumes* anything
(keyboard, input stream, collision registers that clear when read), and does not
raise exceptions the program could depend on.

**Polymorphic comparison is expensive.** `<`, `=`, `compare`... on a type the
compiler does not know to be `int`/`char` call `caml_compare_val`, about 1 KB of
code. Annotate the types (`(x : int)`) in library code; `tools/polycmp` lists the
places where the compiler generates a generic comparison.

**Primitives that do not return.** `caml_sys_exit` shows the pattern: put the
exit code in `C64_SAREG/C64_SXREG`, restore the CPU stack pointer
(`LDX caml_hw_stack_ptr : TXS`) and `JMP caml_end`. Do the same for a primitive
that must abandon the current computation; anything left on the hardware stack
is discarded.

[^1]: See the [Cheney's algorithm](https://en.wikipedia.org/wiki/Cheney%27s_algorithm)
page on Wikipedia.

[^3]: Mark-and-compact marks the live blocks by pointer reversal
(Deutsch-Schorr-Waite, no stack), builds a bit map with one bit per 2-byte
word of data, and slides the live blocks down, updating every pointer. Its
header comment in `memory_mc.asm` describes the phases and the heap layout.

[^2]: `CLOSUREREC` creates a single block containing several functions; a
pointer to the *k*-th function is an *infix pointer*, i.e., a pointer to an
*infix block* (tag `Infix_tag`, whose size field is the offset in words from the
start of the closure block). Such pointers may appear in `ENV`, `ACCU` and on
the stack. The collector moves the main block and recomputes the infix pointer.
