# ARMv7 Instruction Reference

CS 2400 · MSU Denver · GNU assembler syntax (CPUlator)

> `OP{cond}{S}   Rd, Rn, Operand2        @ comment`

- `Rd` is the destination and always comes first. `Operand2` may be a register, a shifted register (`R2, LSL #3`), or an immediate (`#42`).
- `{cond}` runs the instruction only if the flags match.
- `{S}` updates the flags from the result.
- Registers: R0–R12 general purpose (R0–R3 hold arguments, R0 holds the return value) · R13 = SP · R14 = LR · R15 = PC.
- Flags in CPSR: N negative · Z zero · C carry / unsigned borrow · V signed overflow.

## Data Movement

| Instruction        | Effect                    | Notes                                               | High-Level C Idiom             |
| :----------------- | :------------------------ | :-------------------------------------------------- | :----------------------------- |
| `MOV Rd, Operand2` | Rd := Operand2            | Register to register, or a small constant.          | `x = y;` or `x = 42;`          |
| `MVN Rd, Operand2` | Rd := NOT Operand2        | Bitwise complement.                                 | `x = ~y;`                      |
| `LDR Rd, =value`   | Rd := any 32-bit constant | Use whenever MOV rejects the constant as too large. | `x = 1000000;` (large literal) |
| `LDR Rd, =label`   | Rd := address of label    | How you get the address of a variable or array.     | `ptr = &arr;`                  |

## Arithmetic

| Instruction                | Effect                      | Notes                                                             | High-Level C Idiom                                                                                                       |
| :------------------------- | :-------------------------- | :---------------------------------------------------------------- | :----------------------------------------------------------------------------------------------------------------------- |
| `ADD Rd, Rn, Operand2`     | Rd := Rn + Operand2         |                                                                   | `x = a + b;`                                                                                                             |
| `ADC Rd, Rn, Operand2`     | Rd := Rn + Operand2 + C     | Multi-word addition.                                              | No single-instruction idiom — this is what the compiler emits for one limb of a `uint64_t`/wider add on a 32-bit target. |
| `SUB Rd, Rn, Operand2`     | Rd := Rn − Operand2         |                                                                   | `x = a - b;`                                                                                                             |
| `SBC Rd, Rn, Operand2`     | Rd := Rn − Operand2 − NOT C | Multi-word subtraction.                                           | Same caveat as `ADC` — one limb of a wide subtract.                                                                      |
| `RSB Rd, Rn, Operand2`     | Rd := Operand2 − Rn         | Reverse subtract. `RSB Rd, Rn, #0` negates Rn.                    | `x = -a;` (via `RSB Rd, Rn, #0`)                                                                                         |
| `MUL Rd, Rm, Rs`           | Rd := Rm × Rs               | Low 32 bits only. Both operands must be registers — no immediate. | `x = a * b;`                                                                                                             |
| `MLA Rd, Rm, Rs, Rn`       | Rd := (Rm × Rs) + Rn        | Multiply-accumulate.                                              | `x = a * b + c;`                                                                                                         |
| `UMULL RdLo, RdHi, Rm, Rs` | 64-bit product              | SMULL for signed operands.                                        | `uint64_t x = (uint64_t)a * b;`                                                                                          |

`SDIV` and `UDIV` exist in ARMv7, but integer divide is optional in the A profile and our Cortex-A9 does not implement it — it is mandatory only in ARMv7-M and in ARMv7-A with the Virtualization Extensions. Divide by a power of two with `ASR` or `LSR`; anything else needs a loop or a library routine.

## Logical and Shifts

| Instruction            | Effect                    | Notes                                        | High-Level C Idiom                                            |
| :--------------------- | :------------------------ | :------------------------------------------- | :------------------------------------------------------------ |
| `AND Rd, Rn, Operand2` | Rd := Rn AND Operand2     | Masking: keep selected bits.                 | `x = a & b;`                                                  |
| `ORR Rd, Rn, Operand2` | Rd := Rn OR Operand2      | Set selected bits.                           | `x = a \| b;`                                                 |
| `EOR Rd, Rn, Operand2` | Rd := Rn XOR Operand2     | Toggle bits. `EOR Rd, Rd, Rd` clears Rd.     | `x = a ^ b;`                                                  |
| `BIC Rd, Rn, Operand2` | Rd := Rn AND NOT Operand2 | Bit clear: clear selected bits.              | `x = a & ~b;`                                                 |
| `LSL Rd, Rm, #n`       | Rd := Rm << n             | Multiply by 2ⁿ.                              | `x = a << n;`                                                 |
| `LSR Rd, Rm, #n`       | Rd := Rm >> n, zero fill  | Unsigned divide by 2ⁿ.                       | `x = (unsigned)a >> n;`                                       |
| `ASR Rd, Rm, #n`       | Rd := Rm >> n, sign fill  | Signed divide by 2ⁿ.                         | `x = a >> n;` (`a` a signed type)                             |
| `ROR Rd, Rm, #n`       | Rotate right by n         | Bits leaving the bottom re-enter at the top. | No native C operator — typically `(x >> n) \| (x << (32-n))`. |

A shift can ride inside `Operand2` rather than being a separate instruction: `ADD R0, R1, R2, LSL #2` computes `R0 = R1 + 4×R2` in one instruction.

## Comparison — Sets Flags, Produces No Result

| Instruction        | Effect                                                                         |
| :----------------- | :----------------------------------------------------------------------------- |
| `CMP Rn, Operand2` | Computes Rn − Operand2 and keeps only the flags. The one you will use most.    |
| `CMN Rn, Operand2` | Computes Rn + Operand2 and keeps only the flags.                               |
| `TST Rn, Operand2` | Computes Rn AND Operand2 and keeps only the flags. Tests whether bits are set. |
| `TEQ Rn, Operand2` | Computes Rn XOR Operand2 and keeps only the flags. Tests equality.             |

## Branching

| Instruction     | Effect                                                                                        |
| :-------------- | :-------------------------------------------------------------------------------------------- |
| `B label`       | Jump to label. Unconditional.                                                                 |
| `B{cond} label` | Jump only if the flags satisfy cond — `BEQ`, `BNE`, `BLT`, `BGT`, `BGE`, `BLE`, `BHI`, `BLO`. |
| `BL label`      | Branch with link: LR := return address, then jump. This is a subroutine call.                 |
| `BX LR`         | Return from a subroutine.                                                                     |
| `BLX Rm`        | Call the subroutine whose address is in Rm.                                                   |

## Condition Codes

| Code    | Meaning                  | Flags           |
| :------ | :----------------------- | :-------------- |
| EQ      | equal                    | Z = 1           |
| NE      | not equal                | Z = 0           |
| HS / CS | higher or same, unsigned | C = 1           |
| LO / CC | lower, unsigned          | C = 0           |
| MI      | negative                 | N = 1           |
| PL      | zero or positive         | N = 0           |
| VS / VC | overflow set / clear     | V = 1 / 0       |
| HI      | higher, unsigned         | C = 1 and Z = 0 |
| LS      | lower or same, unsigned  | C = 0 or Z = 1  |
| GE      | greater or equal, signed | N = V           |
| LT      | less than, signed        | N ≠ V           |
| GT      | greater than, signed     | Z = 0 and N = V |
| LE      | less or equal, signed    | Z = 1 or N ≠ V  |
| AL      | always — the default     | —               |

Signed comparisons use GT / LT / GE / LE. Unsigned comparisons use HI / LO / HS / LS. Picking the wrong family is the most common silent bug in ARM code.

## Memory Access

These are the only instructions that touch memory — everything above works on registers. That is what load/store architecture means.

| Instruction      | Effect                                                    | High-Level C Idiom                                                                                         |
| :--------------- | :-------------------------------------------------------- | :--------------------------------------------------------------------------------------------------------- |
| `LDR Rd, [Rn]`   | Load the 32-bit word at address Rn into Rd.               | `x = *ptr;`                                                                                                |
| `STR Rd, [Rn]`   | Store the word in Rd to address Rn.                       | `*ptr = x;`                                                                                                |
| `LDRB / STRB`    | Byte transfer. `LDRB` zero-extends, `LDRSB` sign-extends. | `x = *(uint8_t*)ptr;` / `*(uint8_t*)ptr = x;`                                                              |
| `LDRH / STRH`    | Halfword transfer. `LDRSH` sign-extends.                  | `x = *(uint16_t*)ptr;` / `*(uint16_t*)ptr = x;`                                                            |
| `PUSH {reglist}` | Push registers onto the stack, e.g. `PUSH {R4, LR}`.      | Not written directly in C — the compiler emits this for function prologues to save callee-saved registers. |
| `POP {reglist}`  | Pop registers off the stack.                              | Compiler-generated function epilogue counterpart to `PUSH`.                                                |

## Addressing Modes

| Form               | Address used | Effect on Rn                                      |
| :----------------- | :----------- | :------------------------------------------------ |
| `[Rn]`             | Rn           | unchanged                                         |
| `[Rn, #offset]`    | Rn + offset  | unchanged                                         |
| `[Rn, Rm, LSL #2]` | Rn + 4×Rm    | unchanged — this is `arr[i]` for 32-bit elements  |
| `[Rn, #offset]!`   | Rn + offset  | Rn := Rn + offset (pre-indexed)                   |
| `[Rn], #offset`    | Rn           | Rn := Rn + offset (post-indexed, walks a pointer) |

## Common Patterns

| In a high-level language  | In ARM assembly                                                                    |
| :------------------------ | :--------------------------------------------------------------------------------- |
| `if (a == b) { ... }`     | `CMP R0, R1` / `BNE skip` / ... / `skip:`                                          |
| `while (i <= 10) { ... }` | `loop: CMP R1, #10` / `BGT done` / ... / `B loop` / `done:`                        |
| `for (i = 0; i < n; i++)` | `MOV R1, #0` / `loop: CMP R1, R2` / `BGE done` / ... / `ADD R1, R1, #1` / `B loop` |
| `x = arr[i]`              | `LDR R0, =arr` / `LDR R2, [R0, R1, LSL #2]`                                        |
| `arr[i] = x`              | `LDR R0, =arr` / `STR R2, [R0, R1, LSL #2]`                                        |
| `p++` (int pointer)       | `ADD R1, R1, #4`                                                                   |
| `f(a, b);`                | `MOV R0, a` / `MOV R1, b` / `BL f`                                                 |
| `return x;`               | `MOV R0, x` / `BX LR`                                                              |

The branch condition is the opposite of the source condition: "while i <= 10" becomes "branch out if greater than."

## Directives — Messages to the Assembler, Not the Processor

| Directive         | Meaning                                                                 |
| :---------------- | :---------------------------------------------------------------------- |
| `.global _start`  | Make the symbol visible outside this file. `_start` is the entry point. |
| `.text` / `.data` | Code section / writable data section.                                   |
| `.word 4, 8, 15`  | Place 32-bit values in memory. `.byte` for 8-bit values.                |
| `.asciz "hi"`     | String with a terminating zero byte. `.ascii` omits it.                 |
| `.space 40`       | Reserve 40 zero-filled bytes for an uninitialized array.                |
| `.equ SIZE, 6`    | Define a named constant; refer to it as `#SIZE`.                        |
| `.balign 4`       | Align the next item to a 4-byte boundary. Word access requires this.    |

## Things That Will Bite You

| Symptom                            | Cause and fix                                                                                                                                      |
| :--------------------------------- | :------------------------------------------------------------------------------------------------------------------------------------------------- |
| "Invalid constant" on MOV          | An immediate must be an 8-bit value rotated by an even number of positions. `MOV R0, #255` works; `MOV R0, #1000` does not. Write `LDR R0, =1000`. |
| Comparison backwards on big values | `0xFFFFFFFF` is −1 to `BLT` and about four billion to `BLO`. Match the branch family to the data.                                                  |
| Loop never ends                    | Stale flags. `CMP` sets them; `ADD` does not unless you write `ADDS`.                                                                              |
| Program runs into garbage          | No infinite loop at the end. There is no operating system to return to — finish with `stop: B stop`.                                               |
| Subroutine returns to nowhere      | A nested `BL` overwrote LR. `PUSH {LR}` before calling, `POP {LR}` before returning.                                                               |
