# AES-128 in 8086 Assembly — Bare-Metal Cryptography

> **Full FIPS-197 AES-128 implementation in Intel 8086 Assembly — no libraries, no external dependencies. Exceptionally rare on GitHub.**

[![Assembly](https://img.shields.io/badge/Language-8086_Assembly-blue.svg)]()
[![Standard](https://img.shields.io/badge/Standard-FIPS--197-red.svg)](https://csrc.nist.gov/publications/detail/fips/197/final)
[![Emulator](https://img.shields.io/badge/Emulator-EMU8086-green.svg)]()

---

## Overview

This project implements the complete **AES-128 encryption algorithm** (FIPS-197) from scratch in **Intel 8086 Assembly language**, running on the EMU8086 emulator. Every AES operation is implemented at the byte level without any library support — demonstrating mastery of both low-level systems programming and cryptographic mathematics.

This is one of the **rarest implementations on GitHub**: AES-128 typically requires GF(2⁸) polynomial arithmetic which is extremely challenging to implement in the 16-bit 8086 instruction set.

---

## AES-128 Operations Implemented

### SubBytes
```nasm
; Uses XLAT instruction with S-box lookup table
; BX = S-box base address, AL = input byte
XLAT    ; AL = S-box[AL] — single instruction substitution
```

### ShiftRows
```nasm
; Byte-level MOV operations on the 4×4 state matrix
; Row 0: unchanged
; Row 1: cyclic left shift by 1
; Row 2: cyclic left shift by 2
; Row 3: cyclic left shift by 3
```

### MixColumns
- Full **GF(2⁸) polynomial arithmetic** with irreducible polynomial `x⁸ + x⁴ + x³ + x + 1`
- `xtime()` implemented via left shift + conditional XOR with `0x1B`
- Matrix multiplication over GF(2⁸) for all four state columns

### Key Schedule
- 10-round key expansion from 128-bit master key
- **RCON table** embedded in data segment
- PC-1/PC-2 permutation tables for SubWord/RotWord operations

### Round Structure
- All **10 rounds macro-inlined** to eliminate CALL/RET overhead — maximizes throughput
- Round 10 omits MixColumns per FIPS-197 specification

---

## Why 8086 Assembly?

The Intel 8086 is a **16-bit processor** with:
- No hardware multiply/divide for GF arithmetic
- No byte-swap instructions
- Only 8 general-purpose registers (AX, BX, CX, DX, SI, DI, SP, BP)
- Segment:Offset memory model

Implementing AES-128's field arithmetic in this environment requires:
1. Manual GF(2⁸) multiplication via repeated shift-and-XOR
2. Careful register allocation for the 4×4 state matrix
3. Lookup table optimization to avoid repeated field calculations

---

## Files

| File | Description |
|---|---|
| `aes.asm` | Main AES-128 implementation |
| `sbox.asm` | S-box and inverse S-box lookup tables |
| `rcon.asm` | Round constant table |

---

## Running

1. Install [EMU8086](http://www.emu8086.com/) emulator
2. Open `aes.asm` in EMU8086
3. Assemble and run (F5)
4. Inspect memory dump to verify ciphertext

**Test vector (FIPS-197 Appendix B):**
```
Key:       2b 7e 15 16 28 ae d2 a6 ab f7 15 88 09 cf 4f 3c
Plaintext: 32 43 f6 a8 88 5a 30 8d 31 31 98 a2 e0 37 07 34
Cipher:    39 25 84 1d 02 dc 09 fb dc 11 85 97 19 6a 0b 32
```

---

## Skills & Concepts

`x86 Assembly` `AES-128` `GF(2⁸) Arithmetic` `FIPS-197` `Cryptographic Engineering` `Intel 8086` `EMU8086` `Low-Level Systems Programming` `Block Ciphers` `Lookup Table Optimization`

---

## Author

**Ahmed Tamer Assy** — [GitHub](https://github.com/tamer017) | Machine Learning Researcher @ Volkswagen AG
