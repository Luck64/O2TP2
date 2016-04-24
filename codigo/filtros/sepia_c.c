
#include "../tp2.h"


void sepia_c    (
    unsigned char *src,
    unsigned char *dst,
    int cols,
    int filas,
    int src_row_size,
    int dst_row_size)
{
    unsigned char (*src_matrix)[src_row_size] = (unsigned char (*)[src_row_size]) src;
    unsigned char (*dst_matrix)[dst_row_size] = (unsigned char (*)[dst_row_size]) dst;

    for (int i = 0; i < filas; i++)
    {
        for (int j = 0; j < cols; j++)
        {
            bgra_t *p_d = (bgra_t*) &dst_matrix[i][j * 4];
            bgra_t *p_s = (bgra_t*) &src_matrix[i][j * 4];
   //         *p_d = *p_s;
            int suma = p_s->b + p_s->g + p_s->r;
            int b = 0.2*suma;
            int g = 0.3*suma;
            int r = 0.5*suma;

            if(b>255){
                b=255;
            };

            if(r>255){
                r=255;
            };

            if(g>255){
                g=255;
            };

            p_d->b = b;
            p_d->g = g;
            p_d->r = r;
            p_d->a = p_s->a;


        }
    }	//COMPLETAR
}



