section .data
DEFAULT REL

section .rodata
saturacion:
quitarBasura: db 0xFF, 0x00, 0x00, 0x00, 0xFF, 0x00, 0x00, 0x00, 0xFF, 0x00, 0x00, 0x00, 0xFF, 0x00, 0x00, 0x00
multiplic: dd 0.2, 0.3, 0.5, 1.0
multB: dd 0.2, 0.2, 0.2, 0.2
multG: dd 0.2, 0.3, 0.3, 0.3
multR: dd 0.5, 0.5, 0.5, 0.5
harveyDent: db 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
removerCuarto: db 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x00, 0x00, 0x00, 0x00
dejarAlpha: db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xFF, 0x00, 0x00, 0x00

section .text
global sepia_asm
;void sepia_asm    (unsigned char *src, unsigned char *dst, int cols, int filas,
;                     int src_row_size, int dst_row_size, int alfa);
sepia_asm:
;RDI = *src
;RSI = *dst
;RDX = columnas
;RCX = filas
;R8 = source row
;R9 = destination row
;PILA = alfa

push rbp ;alineada
mov rbp, rsp
push r12 ;desalinada
push r13 ;alineada
xor r12, r12; voy a guardar X
xor r13, r13; voy a guardar Y
 
movdqu xmm12, [multB]
movdqu xmm13, [multG]
movdqu xmm14, [multR]
movdqu xmm15, [quitarBasura]
jmp .cicloX

.cicloY:
xor r12, r12
add r13, 1
cmp r13, rcx
je .terminar
jmp .cicloX

.cicloX:
movdqu xmm0, [rdi] 		 ; XMM0 = [ B1 | G1 | R1 | A1 | B2 | G2 | R2 | A2 | B3 | G3 | R3 | A3 | B4 | G4 | R4 | A4 ]
movdqu xmm1, xmm0
movdqu xmm2, xmm0
movdqu xmm10, xmm0		 ; save
psrldq xmm1, 1			 ; XMM1 = [ G1 | R1 | A1 | B2 | G2 | R2 | A2 | B3 | G3 | R3 | A3 | B4 | G4 | R4 | A4 | 00 ]
psrldq xmm2, 2			 ; XMM2 = [ R1 | A1 | B2 | G2 | R2 | A2 | B3 | G3 | R3 | A3 | B4 | G4 | R4 | A4 | 00 | 00 ]

pand xmm0, xmm15 		 ; XMM0 = [ B1 | 00 | 00 | 00 | B2 | 00 | 00 | 00 | B3 | 00 | 00 | 00 | B4 | 00 | 00 | 00 ]
pand xmm1, xmm15 		 ; XMM1 = [ G1 | 00 | 00 | 00 | G2 | 00 | 00 | 00 | G3 | 00 | 00 | 00 | G4 | 00 | 00 | 00 ]
pand xmm2, xmm15 		 ; XMM2 = [ R1 | 00 | 00 | 00 | R2 | 00 | 00 | 00 | R3 | 00 | 00 | 00 | R4 | 00 | 00 | 00 ]

paddd xmm0, xmm1 ; sumo SIN saturacion
paddd xmm0, xmm2

; XMM0 = [ S1 | S2 | S3 | S4 ]

pshufd xmm6, xmm0, 0x00
pshufd xmm7, xmm0, 0x55
pshufd xmm8, xmm0, 0xAA
pshufd xmm9, xmm0, 0xFF

movdqu xmm14, [removerCuarto]

pand xmm6, xmm14
pand xmm7, xmm14
pand xmm8, xmm14
pand xmm9, xmm14

; XMM6 = [ S1 | S1 | S1 | 00 ]
; XMM7 = [ S2 | S2 | S2 | 00 ]
; XMM8 = [ S3 | S3 | S3 | 00 ]
; XMM9 = [ S4 | S4 | S4 | 00 ]

movdqu xmm0, xmm10
movdqu xmm1, xmm10
movdqu xmm2, xmm10
movdqu xmm3, xmm10

psrldq xmm0, 3
pslldq xmm1, 1
pslldq xmm2, 5
pslldq xmm3, 9

movdqu xmm14, [dejarAlpha]
pand xmm0, xmm14
pand xmm1, xmm14
pand xmm2, xmm14
pand xmm3, xmm14

; XMM0 = [ 00 | 00 | 00 | A1 ]
; XMM1 = [ 00 | 00 | 00 | A2 ]
; XMM2 = [ 00 | 00 | 00 | A3 ]
; XMM3 = [ 00 | 00 | 00 | A4 ]

por xmm0, xmm6
por xmm1, xmm7
por xmm2, xmm8
por xmm3, xmm9

; XMM0 = [ S1 | S1 | S1 | A1 ] con integers
; XMM1 = [ S2 | S2 | S2 | A2 ]
; XMM2 = [ S3 | S3 | S3 | A3 ]
; XMM3 = [ S4 | S4 | S4 | A4 ]

cvtdq2ps xmm0, xmm0 ; los convierto en floats
cvtdq2ps xmm1, xmm1
cvtdq2ps xmm2, xmm2
cvtdq2ps xmm3, xmm3

; XMM0 = [ S1 | S1 | S1 | A1 ] con floats
; XMM1 = [ S2 | S2 | S2 | A2 ]
; XMM2 = [ S3 | S3 | S3 | A3 ]
; XMM3 = [ S4 | S4 | S4 | A4 ]

movdqu xmm14, [multiplic]

mulps xmm0, xmm14
mulps xmm1, xmm14
mulps xmm2, xmm14
mulps xmm3, xmm14

cvtps2dq xmm0, xmm0 ; paso de float a integer
cvtps2dq xmm1, xmm1
cvtps2dq xmm2, xmm2
cvtps2dq xmm3, xmm3

; XMM0 = [ S1*0.2 | S1*0.3 | S1*0.5 | A1 ] con integers
; XMM1 = [ S2*0.2 | S2*0.3 | S2*0.5 | A2 ]
; XMM2 = [ S3*0.2 | S3*0.3 | S3*0.5 | A3 ]
; XMM3 = [ S4*0.2 | S4*0.3 | S4*0.5 | A4 ]

packssdw xmm0, xmm1
packssdw xmm2, xmm3
packuswb xmm0, xmm2

movdqu [rsi], xmm0
lea rsi, [rsi + 16]
lea rdi, [rdi + 16]
add r12, 4
cmp r12, rdx ; comparo para ver si ya termine esta fila
je .cicloY
jmp .cicloX

.terminar:
pop r13
pop r12
pop rbp
ret