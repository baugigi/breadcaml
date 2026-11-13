# Writing BreadCaml primitives: heap allocation and GC safety

**Audience:** authors of custom primitives (6502 assembly, ACME). Applies to
both back-ends (native code and bytecode interpreter).

BreadCaml uses a **stop-and-copy (Cheney) garbage collector**[^1]. Any call to
`caml_alloc` may trigger a collection, and a collection **moves every live
block**. A primitive is GC-safe if, at the moment of each `caml_alloc` call, it
follows the rules below.

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
  an infix block[^2]), which will be copied and updated.

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

* It clobbers the 8 zero-page bytes starting at `GC` ($3E-$45).
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
primitive returns. `Y = 0` on entry and on exit.

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
                                ;  the array is not forwarded correctly.
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

[^1]: See the [Cheney's algorithm](https://en.wikipedia.org/wiki/Cheney%27s_algorithm)
page on Wikipedia.

[^2]: `CLOSUREREC` creates a single block containing several functions; a
pointer to the *k*-th function is an *infix pointer*, i.e., a pointer to an
*infix block* (tag `Infix_tag`, whose size field is the offset in words from the
start of the closure block). Such pointers may appear in `ENV`, `ACCU` and on
the stack. The collector copies the main block and recomputes the infix pointer.
