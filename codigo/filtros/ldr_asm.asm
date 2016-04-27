global ldr_asm

%define NULL				0
%define PIXEL_SIZE	4

section .data
section .rodata
quitarBasura: db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xFF, 0x00, 0x00, 0x00, 0xFF, 0x00, 0x00, 0x00, 0xFF
;mascSuma1: db 0xFF, 0xFF, 0xFF, 0x06, 0xFF, 0x05, 0xFF, 0x04, 0xFF, 0xFF, 0XFF, 0X02, 0xFF, 0x01, 0xFF, 0x00
;mascSuma2: dq 0xFF, 0xFF, 0xFF, 0x0E, 0xFF, 0x0D, 0xFF, 0x0C, 0xFF, 0xFF, 0XFF, 0X0A, 0xFF, 0x09, 0xFF, 0x08
mascSuma2: db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x0, 0X00, 0X00, 0x00, 0x00, 0x00, 0x00

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
	push RBX				;Desalineada
	push R12				;Alineada

	xor r12, r12		; r12 = i0
	movdqu xmm15, [quitarBasura]

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
; XMM10 = [A1+B1+C1+D1+E1]
; XMM11 = [A2+B2+C2+D2+E2]
; XMM12 = [A3+B3+C3+D3+E3]
; XMM13 = [A4+B4+C4+D4+E4]

	movdqu xmm10, xmm0
	movdqu xmm5, xmm0
	pshufb xmm10, xmm15
	pshufb xmm5, [mascSuma2]	
	
	movdqu xmm11, xmm1
	movdqu xmm6, xmm1
	movdqu xmm12, xmm2
	movdqu xmm7, xmm2
	movdqu xmm13, xmm3
	movdqu xmm8, xmm3
	movdqu xmm14, xmm4
	
	
.fin:
	pop R12
	pop RBX
	pop RBP
	ret
 
