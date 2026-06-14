# Advanced Encryption Standard — AES-128 in Intel 8086 Assembly

> A bare-metal, cycle-conscious implementation of the AES-128 symmetric block cipher written entirely in **Intel 8086 Assembly** for the EMU8086 environment.

[![Language](https://img.shields.io/badge/Language-Assembly%20(8086)-red?style=flat-square)](https://en.wikipedia.org/wiki/Intel_8086)
[![Standard](https://img.shields.io/badge/Standard-FIPS--197-blue?style=flat-square)](https://csrc.nist.gov/publications/detail/fips/197/final)
[![Environment](https://img.shields.io/badge/Environment-EMU8086-orange?style=flat-square)](http://www.emu8086.com/)

---

## Overview

This project provides a bare-metal, cycle-conscious implementation of the **AES-128 symmetric block cipher** written in **Intel 8086 Assembly**. Designed for the EMU8086 environment, this implementation bypasses high-level abstractions to execute the Rijndael algorithm at the instruction level.

By managing the 128-bit state matrix within the 8086's 16-bit register constraints, the project demonstrates advanced systems programming, manual memory mapping, and the implementation of finite field arithmetic (GF(2⁸)) required for cryptographic primitives.

---

## Technical Highlights

### Macro-Inlined Pipeline
Implemented the full AES round structure (`SubBytes`, `ShiftRows`, `MixColumns`, `AddRoundKey`) using a macro-assembler approach. This design choice eliminates the overhead of `CALL/RET` stack frame management, optimizing execution speed within the 8086's limited register set.

### Galois Field GF(2⁸) Arithmetic
Engineered a custom `MixColumns` routine that performs matrix multiplication over GF(2⁸). The implementation handles polynomial reduction by `0x1Bh` via bitwise XOR and conditional branching, ensuring strict adherence to FIPS-197 mathematical specifications.

### Dynamic Key Expansion
Developed a robust key schedule module that derives **10 round keys** from a 128-bit master key. The routine utilizes a hardcoded `RCON` (Round Constant) table and cyclic word rotation to generate round keys in-place, minimizing memory footprint.

### Memory-Optimized State Handling
Managed the 16-byte state matrix using direct memory addressing (`[si+offset]`). A temporary buffer (`x`) facilitates cyclic row shifts, ensuring data integrity during `ShiftRows` without requiring additional segment registers.

### FIPS-197 Compliance
Orchestrates the encryption loop to execute **10 full rounds**, with `MixColumns` conditionally omitted in the final round as mandated by the AES standard.

---

## Architecture

The system processes a 128-bit plaintext block through a sequential, round-based pipeline:

```
[128-bit Input Block]
        |
        v
 [Initial AddRoundKey]          <- XOR with Round Key 0
        |
        v
 [Round 1–9]:
   SubBytes  -> ShiftRows -> MixColumns -> AddRoundKey
        |
        v
 [Round 10 (Final)]:
   SubBytes  -> ShiftRows -> AddRoundKey  (NO MixColumns)
        |
        v
[128-bit Ciphertext Block]
```

**Data structure:** The 16-byte state is stored in a flat memory array within the `.data` segment, mapped for efficient access via the `SI` and `DI` index registers.

**I/O interface:** Utilizes DOS `INT 21h` (Function `01h`/`02h`) for character-based input/output within the EMU8086 DOS-emulated environment.

**Constraint management:** Optimized for the 8086's limited general-purpose registers (AX, BX, CX, DX, SI, DI), utilizing stack-free operations to maintain execution throughput.

---

## Key Transformations

| Transformation | Description | 8086 Implementation |
|---|---|---|
| `SubBytes` | Non-linear S-box substitution of each byte | Lookup table in `.data`, indexed via `XLAT` / `BX` register |
| `ShiftRows` | Cyclic row shifts of the 4×4 state matrix | Byte-level `MOV` with temp buffer `x` |
| `MixColumns` | GF(2⁸) matrix multiplication | XOR + conditional `0x1B` polynomial reduction |
| `AddRoundKey` | XOR state with current round key | Byte-by-byte XOR via `[SI+offset]` |
| `KeyExpansion` | Derive 10 round keys from 128-bit master key | `RCON` table + cyclic left-rotation of word |

---

## Skills Demonstrated

- **Cryptographic Engineering:** AES-128 block cipher, S-Box substitution, GF(2⁸) linear transformations, FIPS-197 compliance
- **Assembly Programming:** Intel 8086 ISA, macro-assembler directives, manual memory segment management
- **Systems Optimization:** Minimizing instruction cycles in a 16-bit environment, complex algorithms without high-level libraries
- **Debugging & Verification:** Validating cryptographic correctness through manual state-trace analysis and carry/overflow flag handling

---

## Getting Started

### Prerequisites
- [EMU8086](http://www.emu8086.com/) emulator (v4.x recommended)

### Running
1. Open `code.asm` in EMU8086
2. Assemble (`F5` or **Compile**)
3. Run (`F9` or **Run**)
4. Follow on-screen prompts to enter the plaintext and key

---

## ⚠️ Security Notice

> This implementation is for **educational purposes only**.
> - Vulnerable to **timing attacks** due to conditional branching in `MixColumns` and `SubBytes`
> - Does **not** implement padding or modes of operation (CBC, GCM, CTR) required for production security
> - Do **not** use this implementation to protect real sensitive data

---

## References

- [FIPS 197 — AES Standard](https://csrc.nist.gov/publications/detail/fips/197/final)
- [The Design of Rijndael — Daemen & Rijmen](https://link.springer.com/book/10.1007/978-3-662-04722-4)
- [Intel 8086 Programmer's Reference Manual](https://edge.edx.org/c4x/BITSPilani/EEE231/asset/8086_family_Users_Manual_1_.pdf)
