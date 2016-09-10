// Copyright (c) 2016 Andreas Auernhammer. All rights reserved.
// Use of this source code is governed by a license that can be
// found in the LICENSE file.

// +build amd64, !gccgo, !appengine

#include "textflag.h"

DATA constants<>+0x00(SB)/4, $0x61707865
DATA constants<>+0x04(SB)/4, $0x3320646e
DATA constants<>+0x08(SB)/4, $0x79622d32
DATA constants<>+0x0c(SB)/4, $0x6b206574
GLOBL constants<>(SB), (NOPTR+RODATA), $16

DATA one<>+0x00(SB)/8, $1
DATA one<>+0x08(SB)/8, $0
GLOBL one<>(SB), (NOPTR+RODATA), $16

DATA rol16<>+0x00(SB)/8, $0x0504070601000302
DATA rol16<>+0x08(SB)/8, $0x0D0C0F0E09080B0A
GLOBL rol16<>(SB), (NOPTR+RODATA), $16

DATA rol8<>+0x00(SB)/8, $0x0605040702010003
DATA rol8<>+0x08(SB)/8, $0x0E0D0C0F0A09080B
GLOBL rol8<>(SB), (NOPTR+RODATA), $16

#define ROTL_SSE2(n, t, v) \
 	MOVO v, t; \
	PSLLL $n, t; \
	PSRLL $(32-n), v; \
	PXOR t, v

#define ROTL_SSSE3(c, v) \
	PSHUFB c, v

#define SHUFFLE_64(a, b, c) \
	PSHUFL $0x39, a, a; \
	PSHUFL $0x4E, b, b; \
	PSHUFL $0x93, c, c

#define SHUFFLE_128(a0, a1, b0, b1, c0, c1) \
	PSHUFL $0x39, a0, a0; \
	PSHUFL $0x39, a1, a1; \
	PSHUFL $0x4E, b0, b0; \
	PSHUFL $0x4E, b1, b1; \
	PSHUFL $0x93, c0, c0; \
	PSHUFL $0x93, c1, c1

#define SHUFFLE_256(a0, a1, a2, a3, b0, b1, b2, b3, c0, c1, c2, c3) \
	PSHUFL $0x39, a0, a0; \
	PSHUFL $0x39, a1, a1; \
	PSHUFL $0x39, a2, a2; \
	PSHUFL $0x39, a3, a3; \
	PSHUFL $0x4E, b0, b0; \
	PSHUFL $0x4E, b1, b1; \
	PSHUFL $0x4E, b2, b2; \
	PSHUFL $0x4E, b3, b3; \
	PSHUFL $0x93, c0, c0; \
	PSHUFL $0x93, c1, c1; \
	PSHUFL $0x93, c2, c2; \
	PSHUFL $0x93, c3, c3

#define HALF_ROUND_64_SSE2(v0 , v1 , v2 , v3 , t0) \
	PADDL v1, v0; \
	PXOR v0, v3; \
	ROTL_SSE2(16, t0, v3); \
	PADDL v3, v2; \
	PXOR v2, v1; \
	ROTL_SSE2(12, t0, v1); \
	PADDL v1, v0; \
	PXOR v0, v3; \
	ROTL_SSE2(8, t0, v3); \
	PADDL v3, v2; \
	PXOR v2, v1; \
	ROTL_SSE2(7, t0, v1)

#define HALF_ROUND_64_SSSE3(v0 , v1 , v2 , v3 , t0, c16, c8) \
	PADDL v1, v0; \
	PXOR v0, v3; \
	ROTL_SSSE3(c16, v3); \
	PADDL v3, v2; \
	PXOR v2, v1; \
	ROTL_SSE2(12, t0, v1); \
	PADDL v1, v0; \
	PXOR v0, v3; \
	ROTL_SSSE3(c8, v3); \
	PADDL v3, v2; \
	PXOR v2, v1; \
	ROTL_SSE2(7, t0, v1)

#define HALF_ROUND_128_SSE2(v0, v1, v2, v3, v4, v5, v6, v7, t0) \
	PADDL v1, v0; \
	PADDL v5, v4; \
	PXOR v0, v3; \
	PXOR v4, v7; \
	ROTL_SSE2(16, t0, v3); \
	ROTL_SSE2(16, t0, v7); \
	PADDL v3, v2; \
	PADDL v7, v6; \
	PXOR v2, v1; \
	PXOR v6, v5; \
	ROTL_SSE2(12, t0, v1); \
	ROTL_SSE2(12, t0, v5); \
	PADDL v1, v0; \
	PADDL v5, v4; \
	PXOR v0, v3; \
	PXOR v4, v7; \
	ROTL_SSE2(8, t0, v3); \
	ROTL_SSE2(8, t0, v7); \
	PADDL v3, v2; \
	PADDL v7, v6; \
	PXOR v2, v1; \
	PXOR v6, v5; \
	ROTL_SSE2(7, t0, v1); \
	ROTL_SSE2(7, t0, v5)
	
#define HALF_ROUND_128_SSSE3(v0, v1, v2, v3, v4, v5, v6, v7, t0, c16, c8) \
	PADDL v1, v0; \
	PADDL v5, v4; \
	PXOR v0, v3; \
	PXOR v4, v7; \
	ROTL_SSSE3(c16, v3); \
	ROTL_SSSE3(c16, v7); \
	PADDL v3, v2; \
	PADDL v7, v6; \
	PXOR v2, v1; \
	PXOR v6, v5; \
	ROTL_SSE2(12, t0, v1); \
	ROTL_SSE2(12, t0, v5); \
	PADDL v1, v0; \
	PADDL v5, v4; \
	PXOR v0, v3; \
	PXOR v4, v7; \
	ROTL_SSSE3(c8, v3); \
	ROTL_SSSE3(c8, v7); \
	PADDL v3, v2; \
	PADDL v7, v6; \
	PXOR v2, v1; \
	PXOR v6, v5; \
	ROTL_SSE2(7, t0, v1); \
	ROTL_SSE2(7, t0, v5)

#define HALF_ROUND_256_SSE2(v0, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, t0) \
	PADDL v1, v0; \
	PADDL v5, v4; \
	PADDL v9, v8; \
	PADDL v13, v12; \
	PXOR v0, v3; \
	PXOR v4, v7; \
	PXOR v8, v11; \
	PXOR v12, v15; \
	MOVO v12, t0; \
	ROTL_SSE2(16, v12, v3); \
	ROTL_SSE2(16, v12, v7); \
	ROTL_SSE2(16, v12, v11); \
	ROTL_SSE2(16, v12, v15); \
	PADDL v3, v2; \
	PADDL v7, v6; \
	PADDL v11, v10; \
	PADDL v15, v14; \
	PXOR v2, v1; \
	PXOR v6, v5; \
	PXOR v10, v9; \
	PXOR v14, v13; \
	ROTL_SSE2(12, v12, v1); \
	ROTL_SSE2(12, v12, v5); \
	ROTL_SSE2(12, v12, v9); \
	ROTL_SSE2(12, v12, v13); \
	MOVO t0, v12; \
	PADDL v1, v0; \
	PADDL v5, v4; \
	PADDL v9, v8; \
	PADDL v13, v12; \
	PXOR v0, v3; \
	PXOR v4, v7; \
	PXOR v8, v11; \
	PXOR v12, v15; \
	MOVO v12, t0; \
	ROTL_SSE2(8, v12, v3); \
	ROTL_SSE2(8, v12, v7); \
	ROTL_SSE2(8, v12, v11); \
	ROTL_SSE2(8, v12, v15); \
	PADDL v3, v2; \
	PADDL v7, v6; \
	PADDL v11, v10; \
	PADDL v15, v14; \
	PXOR v2, v1; \
	PXOR v6, v5; \
	PXOR v10, v9; \
	PXOR v14, v13; \
	ROTL_SSE2(7, v12, v1); \
	ROTL_SSE2(7, v12, v5); \
	ROTL_SSE2(7, v12, v9); \
	ROTL_SSE2(7, v12, v13); \
	MOVO t0, v12
	
#define HALF_ROUND_256_SSSE3(v0, v1, v2, v3, v4, v5, v6, v7, v8, v9, v10, v11, v12, v13, v14, v15, t0, c16, c8) \
	PADDL v1, v0; \
	PADDL v5, v4; \
	PADDL v9, v8; \
	PADDL v13, v12; \
	PXOR v0, v3; \
	PXOR v4, v7; \
	PXOR v8, v11; \
	PXOR v12, v15; \
	ROTL_SSSE3(c16, v3); \
	ROTL_SSSE3(c16, v7); \
	ROTL_SSSE3(c16, v11); \
	ROTL_SSSE3(c16, v15); \
	PADDL v3, v2; \
	PADDL v7, v6; \
	PADDL v11, v10; \
	PADDL v15, v14; \
	PXOR v2, v1; \
	PXOR v6, v5; \
	PXOR v10, v9; \
	PXOR v14, v13; \
	MOVO v12, t0; \
	ROTL_SSE2(12, v12, v1); \
	ROTL_SSE2(12, v12, v5); \
	ROTL_SSE2(12, v12, v9); \
	ROTL_SSE2(12, v12, v13); \
	MOVO t0, v12; \
	PADDL v1, v0; \
	PADDL v5, v4; \
	PADDL v9, v8; \
	PADDL v13, v12; \
	PXOR v0, v3; \
	PXOR v4, v7; \
	PXOR v8, v11; \
	PXOR v12, v15; \
	ROTL_SSSE3(c8, v3); \
	ROTL_SSSE3(c8, v7); \
	ROTL_SSSE3(c8, v11); \
	ROTL_SSSE3(c8, v15); \
	PADDL v3, v2; \
	PADDL v7, v6; \
	PADDL v11, v10; \
	PADDL v15, v14; \
	PXOR v2, v1; \
	PXOR v6, v5; \
	PXOR v10, v9; \
	PXOR v14, v13; \
	MOVO v12, t0; \
	ROTL_SSE2(7, v12, v1); \
	ROTL_SSE2(7, v12, v5); \
	ROTL_SSE2(7, v12, v9); \
	ROTL_SSE2(7, v12, v13); \
	MOVO t0, v12

#define XOR_64(dst, src, off, v0 , v1 , v2 , v3 , t0) \
	MOVOU 0+off(src), t0; \
	PXOR v0, t0; \
	MOVOU t0, 0+off(dst); \
	MOVOU 16+off(src), t0; \
	PXOR v1, t0; \
	MOVOU t0, 16+off(dst); \
	MOVOU 32+off(src), t0; \
	PXOR v2, t0; \
	MOVOU t0, 32+off(dst); \
	MOVOU 48+off(src), t0; \
	PXOR v3, t0; \
	MOVOU t0, 48+off(dst)

// func coreSSE2(dst *[64]byte, state *[16]uint32, rounds int)
TEXT ·coreSSE2(SB),4,$0-24
	MOVQ state+8(FP), AX
	MOVQ dst+0(FP), BX
	MOVQ rounds+16(FP), CX
	MOVOU 0(AX), X0
	MOVOU 16(AX), X1
	MOVOU 32(AX), X2
	MOVOU 48(AX), X3
	MOVOU one<>(SB), X15
	MOVO X0, X4
	MOVO X1, X5
	MOVO X2, X6
	MOVO X3, X7
	loop:
		HALF_ROUND_64_SSE2(X4, X5, X6, X7, X8)
		SHUFFLE_64(X5, X6, X7)
		HALF_ROUND_64_SSE2(X4, X5, X6, X7, X8)
		SHUFFLE_64(X7, X6, X5)
		SUBQ $2, CX
		JA loop
	PADDL X0, X4
	PADDL X1, X5
	PADDL X2, X6
	PADDL X3, X7
	PADDQ X15, X3
	MOVOU X4, 0(BX)
	MOVOU X5, 16(BX)
	MOVOU X6, 32(BX)
	MOVOU X7, 48(BX)
	MOVOU X3, 48(AX)
	RET
	
// func coreSSSE3(dst *[64]byte, state *[16]uint32, rounds int)
TEXT ·coreSSSE3(SB),4,$0-24
	MOVQ state+8(FP), AX
	MOVQ dst+0(FP), BX
	MOVQ rounds+16(FP), CX
	MOVOU 0(AX), X0
	MOVOU 16(AX), X1
	MOVOU 32(AX), X2
	MOVOU 48(AX), X3
	MOVOU one<>(SB), X15
	MOVOU rol16<>(SB), X9
	MOVOU rol8<>(SB), X10
	MOVO X0, X4
	MOVO X1, X5
	MOVO X2, X6
	MOVO X3, X7
	loop:
		HALF_ROUND_64_SSSE3(X4, X5, X6, X7, X8, X9, X10)
		SHUFFLE_64(X5, X6, X7)
		HALF_ROUND_64_SSSE3(X4, X5, X6, X7, X8, X9, X10)
		SHUFFLE_64(X7, X6, X5)
		SUBQ $2, CX
		JA loop
	PADDL X0, X4
	PADDL X1, X5
	PADDL X2, X6
	PADDL X3, X7
	PADDQ X15, X3
	MOVOU X4, 0(BX)
	MOVOU X5, 16(BX)
	MOVOU X6, 32(BX)
	MOVOU X7, 48(BX)
	MOVOU X3, 48(AX)
	RET

// func xorBlocksSSE2(dst, src []byte, state *[64]byte, rounds int)
TEXT ·xorBlocksSSE2(SB),4,$0-64
	MOVQ state+48(FP), AX
	MOVQ dst_base+0(FP), BX
	MOVQ src_base+24(FP), CX
	MOVQ src_len+32(FP), DX
	MOVQ rounds+56(FP), BP
	
	MOVOU 0(AX), X0
	MOVOU 16(AX), X1
	MOVOU 32(AX), X2
	MOVOU 48(AX), X3
	MOVOU one<>(SB), X15

	CMPQ DX, $256
	JB BYTES_BETWEEN_0_AND_255
	
	MOVQ SP, SI
	ANDQ $0XFFFFFFFFFFFFFFF0, SP
	SUBQ $16+96, SP

	MOVO X0, 16(SP)
	MOVO X1, 32(SP)
	MOVO X2, 48(SP)
	MOVO X15, 80(SP)
	
BYTES_AT_LEAST_256:
	MOVO X3, 64(SP)
	MOVO X0, X4
	MOVO X1, X5
	MOVO X2, X6
	MOVO X3, X7
	PADDQ X15, X7
	MOVO X0, X8
	MOVO X1, X9
	MOVO X2, X10
	MOVO X7, X11
	PADDQ X15, X11
	MOVO X0, X12
	MOVO X1, X13
	MOVO X2, X14
	MOVO X11, X15
	PADDQ 80(SP), X15
	MOVQ BP, R9
	CHACHA_LOOP_256:
		HALF_ROUND_256_SSE2(X0, X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12, X13, X14, X15, 0(SP))
		SHUFFLE_256(X1, X5, X9, X13, X2, X6, X10, X14, X3, X7, X11, X15)
		HALF_ROUND_256_SSE2(X0, X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12, X13, X14, X15, 0(SP))
		SHUFFLE_256(X3, X7, X11, X15, X2, X6, X10, X14, X1, X5, X9, X13)
		SUBQ $2, R9
		JA CHACHA_LOOP_256
	MOVO X12, 0(SP)
	PADDL 16(SP), X0
	PADDL 32(SP), X1
	PADDL 48(SP), X2
	PADDL 64(SP), X3
	XOR_64(BX, CX, 0, X0, X1, X2, X3, X12)
	MOVO 16(SP), X0
	MOVO 32(SP), X1
	MOVO 48(SP), X2
	MOVO 64(SP), X3
	PADDQ 80(SP), X3
	PADDL X0, X4
	PADDL X1, X5
	PADDL X2, X6
	PADDL X3, X7
	XOR_64(BX, CX, 64, X4, X5, X6, X7, X12)
	PADDQ 80(SP), X3
	PADDL X0, X8
	PADDL X1, X9
	PADDL X2, X10
	PADDL X3, X11
	XOR_64(BX, CX, 128, X8, X9, X10, X11, X12)
	PADDQ 80(SP), X3
	MOVO 0(SP), X12
	PADDL X0, X12
	PADDL X1, X13
	PADDL X2, X14
	PADDL X3, X15		
	XOR_64(BX, CX, 192, X12, X13, X14, X15, X11)
	MOVO 80(SP), X15
	PADDQ X15, X3
	LEAQ 256(CX), CX
	LEAQ 256(BX), BX
	SUBQ $256, DX
	CMPQ DX, $256
	JAE BYTES_AT_LEAST_256
	
	MOVQ SI, SP
	
BYTES_BETWEEN_0_AND_255:
	CMPQ DX, $128
	JB BYTES_BETWEEN_0_AND_127
	
	MOVO X0, X4
	MOVO X1, X5
	MOVO X2, X6
	MOVO X3, X7
	MOVO X0, X8
	MOVO X1, X9
	MOVO X2, X10
	MOVO X3, X11
	PADDQ X15, X11
	MOVQ BP, R9
	CHACHA_LOOP_128:
		HALF_ROUND_128_SSE2(X4, X5, X6, X7, X8, X9, X10, X11, X12)
		SHUFFLE_128(X5, X9, X6, X10, X7, X11)
		HALF_ROUND_128_SSE2(X4, X5, X6, X7, X8, X9, X10, X11, X12)
		SHUFFLE_128(X7, X11, X6, X10, X5, X9)
		SUBQ $2, R9
		JA CHACHA_LOOP_128
	PADDL X0, X4
	PADDL X1, X5
	PADDL X2, X6
	PADDL X3, X7
	XOR_64(BX, CX, 0, X4, X5, X6, X7, X12)
	PADDQ X15, X3
	PADDL X0, X8
	PADDL X1, X9
	PADDL X2, X10
	PADDL X3, X11
	XOR_64(BX, CX, 64, X8, X9, X10, X11, X12)
	PADDQ X15, X3
	LEAQ 128(CX), CX
	LEAQ 128(BX), BX
	SUBQ $128, DX
	
BYTES_BETWEEN_0_AND_127:
	CMPQ DX, $64
	JB DONE
	
	MOVO X0, X4
	MOVO X1, X5
	MOVO X2, X6
	MOVO X3, X7
	MOVQ BP, R9
	CHACHA_LOOP_64:
		HALF_ROUND_64_SSE2(X4, X5, X6, X7, X8)
		SHUFFLE_64(X5, X6, X7)
		HALF_ROUND_64_SSE2(X4, X5, X6, X7, X8)
		SHUFFLE_64(X7, X6, X5)
		SUBQ $2, R9
		JA CHACHA_LOOP_64
	PADDL X0, X4
	PADDL X1, X5
	PADDL X2, X6
	PADDL X3, X7
	XOR_64(BX, CX, 0, X4, X5, X6, X7, X8)
	PADDQ X15, X3
DONE:
	MOVOU X3, 48(AX)
	RET

// func xorBlocksSSSE3(dst, src []byte, state *[64]byte, rounds int)
TEXT ·xorBlocksSSSE3(SB),4,$0-64
	MOVQ state+48(FP), AX
	MOVQ dst_base+0(FP), BX
	MOVQ src_base+24(FP), CX
	MOVQ src_len+32(FP), DX
	MOVQ rounds+56(FP), BP
	
	MOVOU 0(AX), X0
	MOVOU 16(AX), X1
	MOVOU 32(AX), X2
	MOVOU 48(AX), X3
	MOVOU rol16<>(SB), X13
	MOVOU rol8<>(SB), X14
	MOVOU one<>(SB), X15

	CMPQ DX, $256
	JB BYTES_BETWEEN_0_AND_255
	
	MOVQ SP, SI
	ANDQ $0XFFFFFFFFFFFFFFF0, SP
	SUBQ $16+128, SP

	MOVO X0, 16(SP)
	MOVO X1, 32(SP)
	MOVO X2, 48(SP)
	MOVO X15, 80(SP)
	MOVO X13, 96(SP)
	MOVO X14, 112(SP)
	
BYTES_AT_LEAST_256:
	MOVO X3, 64(SP)
	MOVO X0, X4
	MOVO X1, X5
	MOVO X2, X6
	MOVO X3, X7
	PADDQ X15, X7
	MOVO X0, X8
	MOVO X1, X9
	MOVO X2, X10
	MOVO X7, X11
	PADDQ X15, X11
	MOVO X0, X12
	MOVO X1, X13
	MOVO X2, X14
	MOVO X11, X15
	PADDQ 80(SP), X15
	MOVQ BP, R9
	CHACHA_LOOP_256:
		HALF_ROUND_256_SSSE3(X0, X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12, X13, X14, X15, 0(SP), rol16<>(SB), rol8<>(SB))
		SHUFFLE_256(X1, X5, X9, X13, X2, X6, X10, X14, X3, X7, X11, X15)
		HALF_ROUND_256_SSSE3(X0, X1, X2, X3, X4, X5, X6, X7, X8, X9, X10, X11, X12, X13, X14, X15, 0(SP), rol16<>(SB), rol8<>(SB))
		SHUFFLE_256(X3, X7, X11, X15, X2, X6, X10, X14, X1, X5, X9, X13)
		SUBQ $2, R9
		JA CHACHA_LOOP_256
	MOVO X12, 0(SP)
	PADDL 16(SP), X0
	PADDL 32(SP), X1
	PADDL 48(SP), X2
	PADDL 64(SP), X3
	XOR_64(BX, CX, 0, X0, X1, X2, X3, X12)
	MOVO 16(SP), X0
	MOVO 32(SP), X1
	MOVO 48(SP), X2
	MOVO 64(SP), X3
	PADDQ 80(SP), X3
	PADDL X0, X4
	PADDL X1, X5
	PADDL X2, X6
	PADDL X3, X7
	XOR_64(BX, CX, 64, X4, X5, X6, X7, X12)
	PADDQ 80(SP), X3
	PADDL X0, X8
	PADDL X1, X9
	PADDL X2, X10
	PADDL X3, X11
	XOR_64(BX, CX, 128, X8, X9, X10, X11, X12)
	PADDQ 80(SP), X3
	MOVO 0(SP), X12
	PADDL X0, X12
	PADDL X1, X13
	PADDL X2, X14
	PADDL X3, X15		
	XOR_64(BX, CX, 192, X12, X13, X14, X15, X11)
	MOVO 80(SP), X15
	PADDQ X15, X3
	LEAQ 256(CX), CX
	LEAQ 256(BX), BX
	SUBQ $256, DX
	CMPQ DX, $256
	JAE BYTES_AT_LEAST_256
	
	MOVO 96(SP), X13
	MOVO 112(SP), X14
	MOVQ SI, SP
	
BYTES_BETWEEN_0_AND_255:
	CMPQ DX, $128
	JB BYTES_BETWEEN_0_AND_127
	
	MOVO X0, X4
	MOVO X1, X5
	MOVO X2, X6
	MOVO X3, X7
	MOVO X0, X8
	MOVO X1, X9
	MOVO X2, X10
	MOVO X3, X11
	PADDQ X15, X11
	MOVQ BP, R9
	CHACHA_LOOP_128:
		HALF_ROUND_128_SSSE3(X4, X5, X6, X7, X8, X9, X10, X11, X12, X13, X14)
		SHUFFLE_128(X5, X9, X6, X10, X7, X11)
		HALF_ROUND_128_SSSE3(X4, X5, X6, X7, X8, X9, X10, X11, X12, X13, X14)
		SHUFFLE_128(X7, X11, X6, X10, X5, X9)
		SUBQ $2, R9
		JA CHACHA_LOOP_128
	PADDL X0, X4
	PADDL X1, X5
	PADDL X2, X6
	PADDL X3, X7
	XOR_64(BX, CX, 0, X4, X5, X6, X7, X12)
	PADDQ X15, X3
	PADDL X0, X8
	PADDL X1, X9
	PADDL X2, X10
	PADDL X3, X11
	XOR_64(BX, CX, 64, X8, X9, X10, X11, X12)
	PADDQ X15, X3
	LEAQ 128(CX), CX
	LEAQ 128(BX), BX
	SUBQ $128, DX
	
BYTES_BETWEEN_0_AND_127:
	CMPQ DX, $64
	JB DONE
	
	MOVO X0, X4
	MOVO X1, X5
	MOVO X2, X6
	MOVO X3, X7
	MOVQ BP, R9
	CHACHA_LOOP_64:
		HALF_ROUND_64_SSSE3(X4, X5, X6, X7, X8, X13, X14)
		SHUFFLE_64(X5, X6, X7)
		HALF_ROUND_64_SSSE3(X4, X5, X6, X7, X8, X13, X14)
		SHUFFLE_64(X7, X6, X5)
		SUBQ $2, R9
		JA CHACHA_LOOP_64
	PADDL X0, X4
	PADDL X1, X5
	PADDL X2, X6
	PADDL X3, X7
	XOR_64(BX, CX, 0, X4, X5, X6, X7, X8)
	PADDQ X15, X3
DONE:
	MOVOU X3, 48(AX)
	RET

// func supportSSSE3() bool
TEXT ·supportSSSE3(SB),4,$0-1
	XORQ CX, CX
	MOVL $1, AX
	CPUID
	MOVQ CX, BX
	ANDL $0x1, BX	// BX != 0 if support SSE3
	CMPL BX, $0
	JE FALSE
	ANDL $0x200, CX // CX != 0 if support SSSE3
	CMPL CX, $0
	JE FALSE
	MOVB $1, ret+0(FP)
	JMP DONE
FALSE:
	MOVB $0, ret+0(FP)
DONE:
	RET

// func setState(state *[64]byte, key *[32]byte, nonce *[12]byte, counter uint32)
TEXT ·setState(SB),4,$0-28
	MOVQ state+0(FP), AX
	MOVQ key+8(FP), BX
	MOVQ nonce+16(FP), CX
	MOVL counter+24(FP), DX
	
	MOVOU constants<>(SB), X0
	MOVOU 0(BX), X1
	MOVOU 16(BX), X2
	MOVL 0(CX), BP
	MOVQ 4(CX), R8
	MOVOU X0, 0(AX)
	MOVOU X1, 16(AX)
	MOVOU X2, 32(AX)
	MOVL DX, 48(AX)
	MOVL BP, 52(AX)
	MOVQ R8, 56(AX)
	RET
