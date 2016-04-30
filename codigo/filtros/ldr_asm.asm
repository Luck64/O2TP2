global ldr_asm

%define NULL 0
%define PIXEL_SIZE	4

section .data
section .rodata
quitarBasura: db 0xFF, 0xFF, 0x00, 0x00, 0x00, 0x00, 0xFF, 0xFF, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
mascSuma1: db 0x00, 0xFF, 0x01, 0xFF, 0x02, 0xFF, 0xFF, 0xFF, 0x04, 0xFF, 0x05, 0xFF, 0x06, 0xFF, 0xFF, 0xFF
mascSuma2: db 0x08, 0xFF, 0x09, 0xFF, 0x0A, 0xFF, 0xFF, 0xFF, 0x0C, 0xFF, 0x0D, 0xFF, 0x0E, 0xFF, 0xFF, 0xFF
dejarPrimero: db 0xFF, 0xFF, 0xFF, 0xFF, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
dejarPrimero2: db 0xFF, 0xFF, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
dejarCuarto: db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xFF, 0xFF, 0xFF, 0x00
maximoConstante: dd 4876875.0, 4876875.0, 4876875.0, 0.0
saturacion: db 0xFF, 0x00, 0x00, 0x00, 0xFF, 0x00, 0x00, 0x00, 0xFF, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
mascPixel: db 0x00, 0xFF, 0xFF, 0xFF, 0x01, 0xFF, 0xFF, 0xFF, 0x02, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF
mascFloat: db 0x00, 0X01, 0x02, 0x03, 0X00, 0X01, 0x02, 0x03, 0X00, 0X01, 0x02, 0x03, 0XFF, 0xFF, 0xFF, 0XFF


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

	push rbp	;alineada
	mov rbp, rsp
	push r12	;desalinada
	push r13	;alineada
	push rbx	;desalineada
	push r15	;alineada

	mov rbx, rdi	; save rdi
	mov r12, r8		; save r8
	add r12, r12	; duplico r12 (son dos filas)
	xor r10, r10	; R10 = contador
	xor r11, r11	; R11 = intermediario memoria-registro de 8 bytes

;Copiar primeras dos filas:
.copiarDosPrimerasF:
	movdqu xmm0, [rdi]
	movdqu [rsi], xmm0
	lea rdi, [rdi + 16]
	lea rsi, [rsi + 16]
	add r10, 16						; R10 = R10 + 4 pixels
	cmp r10, r12
	JNE .copiarDosPrimerasF

	mov rdi, rbx
	xor r12, r12; voy a guardar X
	xor r13, r13; voy a guardar Y
	mov r13, 4; tiene que empezar dos columnas despues y terminar dos filas antes
	mov r12, 4
;vecinos:           pixeles: _ _ _ _ _ _ _ _
;|U|V|W|X|Y|				|R|S|T|U|V|_|_|_|
;|P|Q|R|S|T|				|M|N|O|P|Q|_|_|_|
;|K|L|*|N|O|				|K|L|1|2|3|4|_|_|
;|F|G|H|I|J|				|F|G|H|I|J|_|_|_|
;|A|B|C|D|E|				|A|B|C|D|E|_|_|_|


mov rax, rdi 	;hago un save de rax, pues lo voy a modificar

					     ; XMM0 = [         A         |         B         |         C         |         D         ]
movdqu xmm0, [rax] 		 ; XMM0 = [ B1 | G1 | R1 | A1 | B2 | G2 | R2 | A2 | B3 | G3 | R3 | A3 | B4 | G4 | R4 | A4 ]

lea rax, [rax + r8] 	 ; ahora rax apunta al inicio de la SEGUNDA fila (contando desde abajo hacia arriba)

					     ; XMM2 = [         F         |         G         |         H         |         I         ]
movdqu xmm2, [rax] 		 ; XMM2 = [ B1 | G1 | R1 | A1 | B2 | G2 | R2 | A2 | B3 | G3 | R3 | A3 | B4 | G4 | R4 | A4 ]

lea rax, [rax + r8] 	 ; ahora rax apunta al inicio de la TERCERA fila (contando desde abajo hacia arriba)

					     ; XMM4 = [         K         |         L         |         1         |         2         ]
movdqu xmm4, [rax] 		 ; XMM4 = [ B1 | G1 | R1 | A1 | B2 | G2 | R2 | A2 | B3 | G3 | R3 | A3 | B4 | G4 | R4 | A4 ]

lea rax, [rax + r8] 	 ; ahora rax apunta al inicio de la CUARTA fila (contando desde abajo hacia arriba)

					     ; XMM6 = [         M         |         N         |         O         |         P         ]
movdqu xmm6, [rax] 		 ; XMM6 = [ B1 | G1 | R1 | A1 | B2 | G2 | R2 | A2 | B3 | G3 | R3 | A3 | B4 | G4 | R4 | A4 ]

lea rax, [rax + r8] 	 ; ahora rax apunta al inicio de la QUINTA fila (contando desde abajo hacia arriba)

					     ; XMM8 = [         R         |         S         |         T         |         U         ]
movdqu xmm8, [rax] 		 ; XMM8 = [ B1 | G1 | R1 | A1 | B2 | G2 | R2 | A2 | B3 | G3 | R3 | A3 | B4 | G4 | R4 | A4 ]

;La idea principal es que cada pixel "recicle". Es decir, cada pixel necesita 5 pixeles (por fila), para hacer eso necesita
;hacer dos accesos a memoria, uno para traer del primero al cuarto y otro para traer del segundo al quinto. Sin embargo,
;el siguiente pixel va a necesitar hacer lo mismo, traer de memoria del primero al cuarto y despues del segundo al quinto
;pero "del primero al cuarto" del segundo pixel es lo mismo que "del segundo al quinto" del primero. Entonces el pixel, una
;vez que hizo sus accesos, le puede dejar en xmm0, xmm2, xmm4, xmm6 y xmm0 la segunda tanda de pixeles que tuvo recolecto
;(es decir, "del segundo al quinto"), el siguiente pixel ya va a tener la mitad de los accesos a memoria hechos, ahora solo
;necesita conseguir sus pixeles "del segundo al quinto" (que se los va a dejar al siguiente pixel en los registros xmm(Pares)
;asi sabe donde encontrarlos). Un ejemplo facil: la funcion inicia recolectando ABCD, FGHI, KL12, MNOP y RSTU y los deja en 
;los registros xmm0, xmm2, xmm4, xmm6 y xmm8 respetivamente. Inicia el ciclo para el pixel 1, ahi va a recolectar BCDE, GHIJ,
;L123, NOPQ y STUV en los registros xmm1, xmm3, xmm5, xmm7 y xmm9 respectivamente. Cuando termine de hacer todas las operaciones,
;va a dejar en los registros xmm0, xmm2, xmm4, xmm6 y xmm8 lo que levanto de memoria en los registros xmm1, xmm3, xmm5, xmm7 y xmm9
;se itera asi sucesivamente. Por cada pixel se hacen 5 accesos a memoria + el acceso "incial" que hay que hacer al principio de
;cada fila.
;Esto quiere decir que si la imagen es ancha y baja va a trabajar mejor. Sin embargo, si es alta y angosta va a tener que hacer mas
;accesos a memoria por menos pixeles. EXPERIMENTO!

;xmm(Pares) = xmm0, xmm2, xmm4, xmm6 y xmm8

lea rdi, [rdi+4]		; rdi ++
jmp .cicloX

.cicloY:
xor r12, r12
mov r12, 4 ;el contador de X empieza con 4 porque los primeros dos pixeles y los dos ultimos no tienen que figurar en la cuenta
add r13, 1
cmp r13, rcx
je .terminar
lea rdi, [rdi+16] ;que saltee los ultimos 2 pixeles de la fila actual y los dos primeros de la siguiente fila 
jmp .cicloX

.cicloX:
mov rax, rdi

					     ; XMM1 = [         B         |         C         |         D         |         E         ]
movdqu xmm1, [rax] 		 ; XMM1 = [ B2 | G2 | R2 | A2 | B3 | G3 | R3 | A3 | B4 | G4 | R4 | A4 | B5 | G5 | R5 | A5 ]

lea rax, [rax + r8] 	 ; ahora rax apunta al inicio de la SEGUNDA fila (contando desde abajo hacia arriba)

					     ; XMM3 = [         G         |         H         |         I         |         F         ]
movdqu xmm3, [rax] 		 ; XMM3 = [ B2 | G2 | R2 | A2 | B3 | G3 | R3 | A3 | B4 | G4 | R4 | A4 | B5 | G5 | R5 | A5 ]

lea rax, [rax + r8] 	 ; ahora rax apunta al inicio de la TERCERA fila (contando desde abajo hacia arriba)

					     ; XMM5 = [         L         |         1         |         2         |         3         ]
movdqu xmm5, [rax] 		 ; XMM5 = [ B2 | G2 | R2 | A2 | B3 | G3 | R3 | A3 | B4 | G4 | R4 | A4 | B5 | G5 | R5 | A5 ]

lea rax, [rax + r8] 	 ; ahora rax apunta al inicio de la CUARTA fila (contando desde abajo hacia arriba)

					     ; XMM7 = [         N         |         O         |         P         |         V         ]
movdqu xmm7, [rax] 		 ; XMM7 = [ B2 | G2 | R2 | A2 | B3 | G3 | R3 | A3 | B4 | G4 | R4 | A4 | B5 | G5 | R5 | A5 ]

lea rax, [rax + r8] 	 ; ahora rax apunta al inicio de la QUINTA fila (contando desde abajo hacia arriba)

					     ; XMM9 = [         S         |         T         |         U         |         V         ]
movdqu xmm9, [rax] 		 ; XMM9 = [ B2 | G2 | R2 | A2 | B3 | G3 | R3 | A3 | B4 | G4 | R4 | A4 | B5 | G5 | R5 | A5 ]

;voy a cuidar de no modificar los xmm(noPares) asi al terminar los paso a los xmm(Pares)

;hago la suma:
movdqu xmm15, [mascSuma1]
movdqu xmm10, xmm0
movdqu xmm11, xmm2
movdqu xmm12, xmm4
movdqu xmm13, xmm6
movdqu xmm14, xmm8

pshufb xmm0, xmm15 ; [B1|00|G1|00|R1|00|00|00|B2|00|G2|00|R2|00|00|00]
pshufb xmm2, xmm15 ; [B1|00|G1|00|R1|00|00|00|B2|00|G2|00|R2|00|00|00]
pshufb xmm4, xmm15 ; [B1|00|G1|00|R1|00|00|00|B2|00|G2|00|R2|00|00|00]
pshufb xmm6, xmm15 ; [B1|00|G1|00|R1|00|00|00|B2|00|G2|00|R2|00|00|00]
pshufb xmm8, xmm15 ; [B1|00|G1|00|R1|00|00|00|B2|00|G2|00|R2|00|00|00]

movdqu xmm15, [mascSuma2]
pshufb xmm10, xmm15		; [B3|00|G3|00|R3|00|00|00|B4|00|G4|00|R4|00|00|00]
pshufb xmm11, xmm15		; [B3|00|G3|00|R3|00|00|00|B4|00|G4|00|R4|00|00|00]
pshufb xmm12, xmm15		; [B3|00|G3|00|R3|00|00|00|B4|00|G4|00|R4|00|00|00]
pshufb xmm13, xmm15		; [B3|00|G3|00|R3|00|00|00|B4|00|G4|00|R4|00|00|00]
pshufb xmm14, xmm15		; [B3|00|G3|00|R3|00|00|00|B4|00|G4|00|R4|00|00|00]

paddw xmm0, xmm2
paddw xmm0, xmm4
paddw xmm0, xmm6
paddw xmm0, xmm8
paddw xmm0, xmm10
paddw xmm0, xmm11
paddw xmm0, xmm12
paddw xmm0, xmm13
paddw xmm0, xmm14

;me falta sumar lo que seria E, J, 3, Q, V

movdqu xmm10, xmm1
movdqu xmm11, xmm3
movdqu xmm12, xmm5
movdqu xmm13, xmm7
movdqu xmm14, xmm9

movdqu xmm15, [dejarCuarto]
pand xmm10, xmm15
pand xmm11, xmm15
pand xmm12, xmm15
pand xmm13, xmm15
pand xmm14, xmm15

movdqu xmm15, [mascSuma2]
pshufb xmm10, xmm15		; [00|00|00|00|00|00|00|00|B5|00|G5|00|R5|00|00|00]
pshufb xmm11, xmm15		; [00|00|00|00|00|00|00|00|B5|00|G5|00|R5|00|00|00]
pshufb xmm12, xmm15		; [00|00|00|00|00|00|00|00|B5|00|G5|00|R5|00|00|00]
pshufb xmm13, xmm15		; [00|00|00|00|00|00|00|00|B5|00|G5|00|R5|00|00|00]
pshufb xmm14, xmm15		; [00|00|00|00|00|00|00|00|B5|00|G5|00|R5|00|00|00]

paddw xmm0, xmm10
paddw xmm0, xmm11
paddw xmm0, xmm12
paddw xmm0, xmm13
paddw xmm0, xmm14

; XMM0 = [SB1|SG1|SR1|000|SB2|SG2|SR2|000]
; ahora tengo que sumar las sumas parciales

phaddw xmm0, xmm0
phaddw xmm0, xmm0
phaddw xmm0, xmm0

; XMM0 = [SUMATOTAL|SUMATOTAL|SUMATOTAL|SUMATOTAL|SUMATOTAL|SUMATOTAL|SUMATOTAL|SUMATOTAL]
; (es el mismo valor 8 veces)

movdqu xmm15, [dejarPrimero2]
pand xmm0, xmm15

; XMM0 = [SUMATOTAL|00|00|00|00|00|00|00]

movdqu xmm2, xmm5 ; XMM2 = [         L         |         1         |         2         |         3         ]
				  ; XMM2 = [ B2 | G2 | R2 | A2 | B3 | G3 | R3 | A3 | B4 | G4 | R4 | A4 | B5 | G5 | R5 | A5 ]

psrldq xmm2, 4    
				  ; XMM2 = [         1         |         0         |         0         |         0         ]
pand xmm2, xmm15  ; XMM2 = [ B3 | G3 | R3 | A3 | 00 | 00 | 00 | 00 | 00 | 00 | 00 | 00 | 00 | 00 | 00 | 00 ]

; XMM2 = [PIXELACTUAL|00|00|00]
movdqu xmm15, [mascPixel]
pshufb xmm2, xmm15	;XMM2 = [B|0|0|0|G|0|0|0|R|0|0|0|0|0|0|0]


xorps xmm4, xmm4
movq xmm4, [RBP + 16]; xmm4 = alpha ?????
movdqu xmm15, [dejarPrimero]
pand xmm4, xmm15
movdqu xmm6, [maximoConstante]

; XMM0 = SUMABGR
; XMM2 = Ikij
; XMM4 = ALPHA
; XMM6 = MAX (ya es un float )

; los convierto en floats

;movdqu xmm15, [mascFloat]
pshufd xmm0, 0x03	;[SUMARGB|SUMARGB|SUMARGB|0]
pshufd xmm4, 0x03	;[ Alpha | Alpha | Alpha |0]

cvtdq2ps xmm0, xmm0 ; [SUMARGB|SUMARGB|SUMARGB|0] con floats
cvtdq2ps xmm2, xmm2 ; [   B   |   G   |   R   |0]
cvtdq2ps xmm4, xmm4 ; [ Alpha | Alpha | Alpha |0]

mulps xmm0, xmm2 ; SUMABGR*Ikij       -> [ S*I | S*I | S*I |0]
mulps xmm0, xmm4 ; SUMABGR*Ikij*ALPHA -> [S*I*A|S*I*A|S*I*A|0]

divps xmm0, xmm6 ; (SUMABGR*Ikij*ALPHA)/MAX	-> [SumaB/max|SumaG/Max|SumaR/Max|0/Max]
addps xmm0, xmm2 ; Ikij + (SUMABGR*Ikij*ALPHA)/MAX -> [FINAL-B|FINAL-G|FINAL-R|0]

xorps xmm2, xmm2
cvtps2dq xmm2, xmm0 ;lo convierto en integer

packusdw xmm2, xmm2
packuswb xmm2, xmm2

movdqu [rsi], xmm2
lea rsi, [rsi + 4]
lea rdi, [rdi + 4]
add r12, 4
movdqu xmm0, xmm1
movdqu xmm2, xmm3
movdqu xmm4, xmm5
movdqu xmm6, xmm7
movdqu xmm8, xmm9
cmp r12, rdx ; comparo para ver si ya termine esta fila
je .cicloY
jmp .cicloX

.terminar:
	pop r15
	pop rbx
	pop r13
	pop r12
	pop rbp
	ret
