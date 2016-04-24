global cropflip_asm

section .text
;void cropflip_asm(unsigned char *src,
;                  unsigned char *dst,
;		           int cols, int filas,
;                  int src_row_size,
;                  int dst_row_size,
;                  int tamx, int tamy,
;                  int offsetx, int offsety);

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
    ret
