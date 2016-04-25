global ldr_asm

section .data
section .rodata
quitarBasura: db 0xFF, 0x00, 0x00, 0x00, 0xFF, 0x00, 0x00, 0x00, 0xFF, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00

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

	movdqu XMM15, [quitarBasura]
	xor R10, R10								; R10 = corrimiento de memoria
	xor R11, R11								; R11 = Ciclo para tomar los vecinos [0-4]  
	xorp XMM0, XMM0
	mov RBX, RCX
	sub RBX, 5									; RBX = corrimiento en la imagen para tomar los 5 proximos pix vecinos

.cicloVecinos:
movdqu XMM10, XMM0						; XMM10 = Acum de la sumatoria de vecinos 
CMP R11, 5										; Maximo de vecionos 4
JE .siguiente

;Obtenemos los primeros 5 pixeles sin su alpha
xorps XMM0, XMM0							; XMM0 = 0
PINSRB xmm0, [RDI + R10], 15	; [B1|00|00|00|00|00|00|00|00|00|00|00|00|00|00|00]
ADD R10, 8										; CHAR SIZE ; G1
PINSRB xmm0, [RDI + R10], 14	; [B1|G1|00|00|00|00|00|00|00|00|00|00|00|00|00|00]
ADD R10, 8										; CHAR SIZE ; R1
PINSRB xmm0, [RDI + R10], 13	; [B1|G1|R1|00|00|00|00|00|00|00|00|00|00|00|00|00]
ADD R10, 8										; CHAR SIZE ; A1
ADD R10, 8										; CHAR SIZE ; B2
PINSRB xmm0, [RDI + R10], 12	; [B1|G1|R1|B2|00|00|00|00|00|00|00|00|00|00|00|00]
ADD R10, 8										; CHAR SIZE ; G2
PINSRB xmm0, [RDI + R10], 11	; [B1|G1|R1|B2|G2|00|00|00|00|00|00|00|00|00|00|00]
ADD R10, 8										; CHAR SIZE ; R2
PINSRB xmm0, [RDI + R10], 10	; [B1|G1|R1|B2|G2|R2|00|00|00|00|00|00|00|00|00|00]
ADD R10, 8										; CHAR SIZE ; A2
ADD R10, 8										; CHAR SIZE ; B3
PINSRB xmm0, [RDI + R10], 9		; [B1|G1|R1|B2|G2|R2|B3|00|00|00|00|00|00|00|00|00]
ADD R10, 8										; CHAR SIZE ; G3
PINSRB xmm0, [RDI + R10], 8		; [B1|G1|R1|B2|G2|R2|B3|G3|00|00|00|00|00|00|00|00]
ADD R10, 8										; CHAR SIZE ; R3
PINSRB xmm0, [RDI + R10], 7		; [B1|G1|R1|B2|G2|R2|B3|G3|R3|00|00|00|00|00|00|00]
ADD R10, 8										; CHAR SIZE ; A3
ADD R10, 8										; CHAR SIZE ; B4
PINSRB xmm0, [RDI + R10], 6		; [B1|G1|R1|B2|G2|R2|B3|G3|R3|B4|00|00|00|00|00|00]
ADD R10, 8										; CHAR SIZE ; G4
PINSRB xmm0, [RDI + R10], 5		; [B1|G1|R1|B2|G2|R2|B3|G3|R3|B4|G4|00|00|00|00|00]
ADD R10, 8										; CHAR SIZE ; R4
PINSRB xmm0, [RDI + R10], 4		; [B1|G1|R1|B2|G2|R2|B3|G3|R3|B4|G4|R4|00|00|00|00]
ADD R10, 8										; CHAR SIZE ; A4
ADD R10, 8										; CHAR SIZE ; B5
PINSRB xmm0, [RDI + R10], 3		; [B1|G1|R1|B2|G2|R2|B3|G3|R3|B4|G4|R4|B5|00|00|00]
ADD R10, 8										; CHAR SIZE ; G5
PINSRB xmm0, [RDI + R10], 2		; [B1|G1|R1|B2|G2|R2|B3|G3|R3|B4|G4|R4|B5|G5|00|00]	
ADD R10, 8										; CHAR SIZE ; R5
PINSRB xmm0, [RDI + R10], 1		; [B1|G1|R1|B2|G2|R2|B3|G3|R3|B4|G4|R4|B5|G5|R5|00]
ADD R10, 8										; CHAR SIZE ; A5
ADD R10, 8										; CHAR SIZE ; B6

;Copiamos en otros registros para sumar
movdqu XMM0, XMM1
movdqu XMM0, XMM2
movdqu XMM0, XMM3
movdqu XMM0, XMM4
movdqu XMM0, XMM5
movdqu XMM0, XMM6

;Se ordenan los xmm para poder sumar
															; [B1|G1|R1|B2|G2|R2|B3|G3|R3|B4|G4|R4|B5|G5|R5|00]
PSLLDQ XMM1,3									; [B2|G2|R2|B3|G3|R3|B4|G4|R4|B5|G5|R5|00|00|00|00]
PSLLDQ XMM2,6									; [B3|G3|R3|B4|G4|R4|B5|G5|R5|00|00|00|00|00|00|00]
PSLLDQ XMM3,9									; [B4|G4|R4|B5|G5|R5|00|00|00|00|00|00|00|00|00|00]
PSLLDQ XMM4,12								; [B5|G5|R5|00|00|00|00|00|00|00|00|00|00|00|00|00]
PSRLDQ XMM5,3									; [00|00|00|B1|G1|R1|B2|G2|R2|B3|G3|R3|B4|G4|R4|B5]
PSRLDQ XMM6,6									; [00|00|00|00|00|00|B1|G1|R1|B2|G2|R2|B3|G3|R3|B4]

;XXXX - REVISAR SI ESTA LIMPIEZA HACE FALTA
pand XMM1, XMM15							; [B1|00|00|00|G2|00|00|00|R3|00|00|00|00|00|00|00]	
pand XMM2, XMM15							; [B2|00|00|00|G3|00|00|00|R4|00|00|00|00|00|00|00]	
pand XMM3, XMM15							; [B3|00|00|00|G4|00|00|00|R5|00|00|00|00|00|00|00]	
pand XMM4, XMM15							; [B4|00|00|00|G5|00|00|00|00|00|00|00|00|00|00|00]	
pand XMM5, XMM15							; [00|00|00|00|00|00|00|00|R2|00|00|00|00|00|00|00]	
pand XMM6, XMM15							; [00|00|00|00|G1|00|00|00|R1|00|00|00|00|00|00|00]	

;sumamos y acumulamos en XMM0
padd XMM0,XMM1								; Suma sin saturacion
padd XMM0,XMM2
padd XMM0,XMM3
padd XMM0,XMM4
padd XMM0,XMM5
padd XMM0,XMM6								; [Sb|**|**|**|Sg|**|**|**|Sr|**|**|**|**|**|**|**]

inc R11												; R11 ++ (itera en la cantidad de vecinos)
ADD R10, RBX									; Sube una fila en la imagen
JMP .cicloVecinos

.siguiente:
.desempaquetado:
;Pasar a float. ¿Se pasa solo agrandando los bytes o hay que configurarlo como float?
;AND with a mask to zero out the odd bytes (PAND)
;Unpack from 16 bits to 32 bits (PUNPCKLWD with a zero vector)
;Convert 32 bit ints to floats (CVTDQ2PS)

;FLOAT 32bit
;[0 | 0|1|1|1|1|1|0|0 | 0|1|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0|0] = 0.15625
;sign | exponent(8b)   | fraction(23b)
; +      (124-127 = -3) 
;1.01 * 2⁻³
;0.00101 = 2⁻³ + 2⁻⁵ = 0.15625

;notacion: (m,e) = m * b^e
; m = mantisa
; b = base
; e = exponente


;1 ciclo para recorrer toda la matriz
;1 ciclo para recorrer los pixeles vecinos

.empaquetado:		

.fin:
	pop RBP
	ret
 
