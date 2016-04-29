global cropflip_asm

section .text
;void cropflip_asm(unsigned char *src,
;                  unsigned char *dst,
;		           int cols, int filas,
;                  int src_row_size,
;                  int dst_row_size,
;                  int tamx, int tamy,
;                  int offsetx, int offsety);

;--------------Convencion C---------------
;Preservar: rbx, r12, r13, r14, r15    
;Retorna rax o XMM0               
;Recibo en: rdi, rsi, rdx, rcx, r8, r9 
;Recibo en: XMM0 a XMM7                
;Recibo en Pila                        
;-----------------------------------------

	;RDI = *src
	;RSI = *dst
	;RDX = columnas
	;RCX = filas
	;R8 = source row
	;R9 = destination row
	;Pila = tamx, tamy, offsetx, offsety
	;
	;Pila =/ |RBP|RET|TAMX|TAMY|OFFSETX|OFFSETY 
	;

cropflip_asm:
	push rbp 
	mov rbp, rsp	;ALINEADO A 16
	push rbx		;ALINEADO A 8
	push r12		;ALINEADO A 16
	push r13		;ALINEADO A 8
	push r14		;ALINEADO A 16
	push r15		;ALINEADO A 8
	sub rsp, 8		;ALINEADO A 16

	xor rbx, rbx
	xor r8, r8 		;No uso src_row_size, y necesito el registro
	xor r9, r9   	;No uso dst_row_size, y necesito el registro
	xor r10, r10
	xor r12, r12
	xor r13, r13
	xor r14, r14
	xor r15, r15	
					;RDX = columnas
	mov ebx, [rbp+16] ;ebx = tamx
	mov r12d, [rbp+24] ; r12d = tamy
	mov r13d, [rbp+32] ; r13d = offsetx
	mov r14d, [rbp+40] ; r14d = offsety

	;primero tengo que posicionar el puntero a (offsetx,offsety), luego ponerlo en la primera celda superior izquierda.
	lea r15, [r12+r14]	;tamy+offsety
	dec r15				;tamy+offsety-1
	lea rdx, [rdx*4]	;COLS,
	mov rcx, rdx 		;me guardo COLS*4 en rcx, ya que lo va a pisar mult
	mov eax, r15d
	mul ecx				;me deja el resultado de [r15*rdx], o sea[(offsety+tamy-1)*(COLS*4)], en edx y eax
	add eax, edx
	mov r15, rax 
	
	lea r13, [r13*4]	;OFFSETX, lo veo de a 4
	;lea rbx, [rbx*4]	;TAMX, lo veo de a 4
	add r15, r13
	add r15, rdi
	mov rdi, r15      	;rdi esta apuntando a la primera celda de la fila mas alta 
	;add rdi, r13 		;desde (0,0) salto a (offsetx, 0)
	jmp .cicloX
    

	.cicloY:
	xor r9, r9 ; voy a usarlo como contador de columnas
	inc r10
	cmp r10, r12	;comparo si el contador llego a tamy
	je .fin
	sub r15, rcx

	mov rdi, r15

    .cicloX:
    movdqu xmm0, [rdi] 		 ; XMM0 = [ B1 | G1 | R1 | A1 | B2 | G2 | R2 | A2 | B3 | G3 | R3 | A3 | B4 | G4 | R4 | A4 ]
	movdqu [rsi], xmm0		 ; XMM0 = [ B1 | G1 | R1 | A1 | B2 | G2 | R2 | A2 | B3 | G3 | R3 | A3 | B4 | G4 | R4 | A4 ]
	lea rsi, [rsi + 16]
	lea rdi, [rdi + 16]
	add r9, 4
	;inc r9
	cmp r9, rbx ; comparo para ver si ya termine esta fila (con tamx)
	jge .cicloY
	;je .cicloY
	jmp .cicloX	

	.fin:
	add rsp, 8
	pop r15
	pop r14
	pop r13
	pop r12
	pop rbx
	pop rbp
    ret



; .primeraCeldaSupIzq:
; 	cmp r8, r15
; 	je .setOffsetX
; 	add rdi, rdx
; 	inc r8
; 	jmp .primeraCeldaSupIzq

; 	.setOffsetX:
; 	add rdi, r13
; 	jmp .cicloX
    

; 	.cicloY:
; 	xor r9, r9 ; voy a usarlo como contador de columnas
; 	inc r10
; 	cmp r10, r12	;comparo si el contador llego a tamy
; 	je .fin
; 	sub rdi, rdx ;Llegue al final de la fila. Ahora resto una tira de columnas entera (o sea, bajo de fila) 
; 	sub rdi, r13 ;y resto el tamx. entonces ahora estoy al principio de la fila de abajo, respetando el offset

;     .cicloX:
;     movdqu xmm0, [rdi] 		 ; XMM0 = [ B1 | G1 | R1 | A1 | B2 | G2 | R2 | A2 | B3 | G3 | R3 | A3 | B4 | G4 | R4 | A4 ]
; 	movdqu [rsi], xmm0		 ; XMM0 = [ B1 | G1 | R1 | A1 | B2 | G2 | R2 | A2 | B3 | G3 | R3 | A3 | B4 | G4 | R4 | A4 ]
; 	lea rsi, [rsi + 16]
; 	lea rdi, [rdi + 16]
; 	add r9, 4
; 	;inc r9
; 	cmp r9, rbx ; comparo para ver si ya termine esta fila (con tamx)
; 	jge .cicloY
; 	;je .cicloY
; 	jmp .cicloX	