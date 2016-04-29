global ldr_asm

%define NULL				0
%define PIXEL_SIZE	4

section .data
section .rodata
quitarBasura: db 0xFF, 0xFF, 0x00, 0x00, 0x00, 0x00, 0xFF, 0xFF, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
mascSuma1: db 0x00, 0xFF, 0x01, 0xFF, 0x02, 0xFF, 0xFF, 0xFF, 0x04, 0xFF, 0X05, 0XFF, 0x06, 0xFF, 0xFF, 0xFF
mascSuma2: dq 0x08, 0xFF, 0x09, 0xFF, 0x0A, 0xFF, 0xFF, 0xFF, 0x0C, 0xFF, 0X0D, 0XFF, 0x0E, 0xFF, 0xFF, 0xFF

section .text
;void ldr_asm    (
	;unsigned char *src,
	;unsigned char *dst,
	;int filas,
	;int cols,
	;int src_row_size,
	;int dst_row_size,
	;int alpha)

;--------------Convencion C---------------
;- Preservar: RBX, R12, R13, R14, R15    -
;- Retornar en: RAX o XMM0               -
;- Recibo en: RDI, RSI, RDX, RCX, R8, R9 -
;- Recibo en: XMM0 a XMM7                -
;- Recibo en Pila                        - 
;-----------------------------------------

;RDI = puntero a src
;RSI = puntero a dst
;RDX = filas
;RCX = cols
;R8 = src_row_size
;R9 = dst_row_size
;Pila = alpha
ldr_asm:
	push RBP				;Alineada
	mov RBP, RSP		;Se crea el Stack F
	push R12				;Desalineada
	push R13				;Alineada
	push R14				;Desalineada
	push RBX				;Alineada

	xor r14, r14								; R14 = iterador de pixeles
	add r14, rcx
	add r14, rcx
	add r14, 2									; R14 = 2*cols + 2 (inicio)
	xor r13, r13
	mov r13B, [RBP + 16]				; R13 = alpha

.vecinos:
	xor r10, r10								; R10 iteracion de vecinos 
	xor r12, r12								; R12 = iterador de vecinos
;CORREGIR	lea r12, [r14-rcx-rcx-2]		; posicion inicial de it e vecinos
	JMP .vecinosUp

.incItPixeli:
;Corregir	CMP r14, 0												; ¿Llegue al margen derecho?
	add r14, 4
	JMP .vecinos 

.vecinosUp:

	CMP r10, 5									; 5 es la cant de filas vecinas a tomar
;CRREGIR	JE .incItPixel
;vecinos:           pixeles:
;|U|V|W|X|Y|				| | | | | | | | |
;|P|Q|R|S|T|				| | | | | | | | |
;|K|L|*|N|O|				| | |1|2|3|4| | |
;|F|G|H|I|J|				| | | | | | | | |
;|A|B|C|D|E|				| | | | | | | | |
;										
;XMM0 = A 
;XMM0 = [    A1     |    A2     |    A3     |     A4    ]
;XMM0 = [B1|G1|R1|a1|B2|G2|R2|a2|B3|G3|R3|a3|B4|G4|R4|a4]
	movdqu xmm0, [rdi + PIXEL_SIZE*r12]	
	movdqu xmm10, xmm0
	inc r12
;XMM1 = B
;XMM1 = [    B1     |    B2     |    B3     |     B4    ]
;XMM1 = [B2|G2|R2|a2|B3|G3|R3|a3|B4|G4|R4|a4|B5|G5|R5|a5]
	movdqu xmm1, [rdi + PIXEL_SIZE*r12]
	inc r12
;XMM2 = C
;XMM2 = [    C1     |    C2     |    C3     |     C4    ]
;XMM2 = [B3|G3|R3|a3|B4|G4|R4|a4|B5|G5|R5|a5|B6|G6|R6|a6]
	movdqu xmm2, [rdi + PIXEL_SIZE*r12]
	inc r12
;XMM3 = D
;XMM3 = [    D1     |    D2     |    D3     |     D4    ]
;XMM3 = [B4|G4|R4|a4|B5|G5|R5|a5|B6|G6|R6|a6|B7|G7|R7|a7]
	movdqu xmm3, [rdi + PIXEL_SIZE*r12]
	inc r12
;XMM4 = E
;XMM4 = [    E1     |    E2     |    E3     |     E4    ]
;XMM4 = [B5|G5|R5|a5|B6|G6|R6|a6|B7|G7|R7|a7|B8|G8|R8|a8]
	movdqu xmm4, [rdi + PIXEL_SIZE*r12]
.suma:
	movdqu xmm15, [mascSuma1]
	
	movdqu xmm5, xmm0
	movdqu xmm6, xmm1
	movdqu xmm7, xmm2
	movdqu xmm8, xmm3
	movdqu xmm9, xmm4

;xmm0 = [A1|A2]
	pshufb xmm0, xmm15		; [B1|00|G1|00|R1|00|00|00|B2|00|G2|00|R2|00|00|00]
;xmm1 = [B1|B2]
	pshufb xmm1, xmm15		; [B2|00|G2|00|R2|00|00|00|B3|00|G3|00|R3|00|00|00]
;xmm2 = [C1|C2]
	pshufb xmm2, xmm15		; [B3|00|G3|00|R3|00|00|00|B4|00|G4|00|R4|00|00|00]
;xmm3 = [D1|D2]
	pshufb xmm3, xmm15		; [B4|00|G4|00|R4|00|00|00|B5|00|G5|00|R5|00|00|00]
;xmm4 = [E1|E2]
	pshufb xmm4, xmm15		; [B5|00|G5|00|R5|00|00|00|B6|00|G6|00|R6|00|00|00]

	movdqu xmm15, [mascSuma2]
;xmm5 = [A3|A4]
	pshufb xmm5, xmm15		; [B3|00|G3|00|R3|00|00|00|B4|00|G4|00|R4|00|00|00]
;xmm6 = [B3|B4]
	pshufb xmm6, xmm15		; [B4|00|G4|00|R4|00|00|00|B5|00|G5|00|R5|00|00|00]
;xmm7 = [C3|C4]
	pshufb xmm7, xmm15		; [B5|00|G5|00|R5|00|00|00|B6|00|G6|00|R6|00|00|00]
;xmm8 = [D3|D4]
	pshufb xmm8, xmm15		; [B6|00|G6|00|R6|00|00|00|B7|00|G7|00|R7|00|00|00]
;xmm9 = [E3|E4]
	pshufb xmm9, xmm15		; [B7|00|G7|00|R7|00|00|00|B8|00|G8|00|R8|00|00|00]
	
; --SUMA PiXELES--
; XMM0 = [A1+B1+C1+D1+E1 | A2+B2+C2+D2+E2]
; XMM0 = [Sb1|Sg1|Sr1|0|Sb2|Sg2|Sr2|0]
	paddd xmm0, xmm1
	paddd xmm0, xmm2
	paddd xmm0, xmm3
	paddd xmm0, xmm4

; XMM5 = [A3+B3+C3+D3+E3 | A4+B4+C4+D4+E4]
; XMM5 = [Sb3|Sg3|Sr3|0|Sb4|Sg4|Sr4|0]
	paddd xmm5, xmm6
	paddd xmm5, xmm7
	paddd xmm5, xmm8
	paddd xmm5, xmm9

; --SUMA COLORES--
	
; XMM0 = [Sumargb1|Sumargb2]
	movdqu xmm1, xmm0		; XMM0 = [Sb1|Sg1|Sr1| 0 |Sb2|Sg2|Sr2| 0 ]
	pslldq xmm1, 2			; XMM1 = [Sg1|Sr1| 0 |Sb2|Sg2|Sr2| 0 | 0 ]
	movdqu xmm2, xmm1
	pslldq xmm2,2				; XMM2 = [Sr1| 0 |Sb2|Sg2|Sr2| 0 | 0 | 0 ]
	movdqu xmm15, [quitarBasura]
	pand xmm0, xmm15		; XMM0 = [Sb1| 0 | 0 | 0 |Sb2| 0 | 0 | 0 ]
	pand xmm1, xmm15		; XMM1 = [Sg1| 0 | 0 | 0 |Sg2| 0 | 0 | 0 ]
	pand xmm2, xmm15		; XMM2 = [Sr1| 0 | 0 | 0 |Sr2| 0 | 0 | 0 ]
	;suma:
	paddd xmm0, xmm1		; XMM0 = [Sumargb1|0|Sumargb2|0] 
	paddd xmm0, xmm2

; XMM5 = [Sumargb3|Sumargb4]
	movdqu xmm6, xmm5		; XMM5 = [Sb3|Sg3|Sr3| 0 |Sb4|Sg4|Sr4| 0 ]
	pslldq xmm6, 2			; XMM6 = [Sg3|Sr3| 0 |Sb4|Sg4|Sr4| 0 | 0 ]
	movdqu xmm7, xmm6
	pslldq xmm7,2				; XMM7 = [Sr3| 0 |Sb4|Sg4|Sr4| 0 | 0 | 0 ]
	paddd xmm5, xmm15		; XMM5 = [Sb3| 0 | 0 | 0 |Sb4| 0 | 0 | 0 ]
	paddd xmm6, xmm15		; XMM6 = [Sg3| 0 | 0 | 0 |Sg4| 0 | 0 | 0 ]
	paddd xmm7, xmm15		; XMM7 = [Sr3| 0 | 0 | 0 |Sr4| 0 | 0 | 0 ]
	; suma:
	paddd xmm5, xmm6		; XMM5 = [Sumargb3|0|Sumargb4|0]
	paddd xmm5, xmm7
	
; XMM5 = [Sumargb1|Sumargb3|Sumargb2|Sumargb4]
	psrldq xmm5,4
	pand xmm5, xmm0
	
;Sube una fila el indice
	lea r12, [r12 + rcx - 4]
	inc r10 
	JMP .vecinosUp
;convertir: 
;shit derecho y pand para pasar todo a un registro
; -- Convertir a float --
	cvtps2dq xmm1, xmm0
	cvtps2dq xmm2, xmm5

.multiplicacion:
; --alpha--
	xorps xmm0, xmm0
	pinsrb xmm0, R13B, 0
	pinsrb xmm0, R13B, 8
	cvtps2dq xmm3, xmm0			; XMM3 = [alpha|0|alpha|0]
; --pixel--
;usar backup xmm10, xmm11,xmm12,xmm13,xmm14	

.fin:
	pop R12
	pop RBX
	pop RBP
	ret
 
