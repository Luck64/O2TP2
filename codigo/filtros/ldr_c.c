
#include "../tp2.h"

#define MIN(x,y) ( x < y ? x : y )
#define MAX(x,y) ( x > y ? x : y )

#define P 2
#define max (5.0*5.0*255.0*3.0*255.0)


void ldr_c    (
    unsigned char *src,
    unsigned char *dst,
    int cols,
    int filas,
    int src_row_size,
    int dst_row_size,
	int alpha)
{
    unsigned char (*src_matrix)[src_row_size] = (unsigned char (*)[src_row_size]) src;
    unsigned char (*dst_matrix)[dst_row_size] = (unsigned char (*)[dst_row_size]) dst;

    int i;
		for (i = 2; i < filas-2; i++)
    {
	int j;
        for (j = 2; j < cols-2; j++)
        {
            bgra_t *p_d = (bgra_t*) &dst_matrix[i][j*4];
            bgra_t *p_s = (bgra_t*) &src_matrix[i][j*4];
            *p_d = *p_s;
						
					int suma_r = (int)((bgra_t*) &src_matrix[i-2][(j-2)*4])->r - (int)((bgra_t*) &src_matrix[i-2][(j-1)*4])->r - 
								(int)((bgra_t*) &src_matrix[i-2][(j*4)])->r - (int)((bgra_t*) &src_matrix[i-2][(j+1)*4])->r - 
								(int)((bgra_t*) &src_matrix[i-2][(j+2)*4])->r - (int)((bgra_t*) &src_matrix[i-1][(j-2)*4])->r	- 
								(int)((bgra_t*) &src_matrix[i-1][(j-1)*4])->r - (int)((bgra_t*) &src_matrix[i-1][(j*4)])->r 	-
								(int)((bgra_t*) &src_matrix[i-1][(j+1)*4])->r - (int)((bgra_t*) &src_matrix[i-1][(j+2)*4])->r 	-
								(int)((bgra_t*) &src_matrix[i][(j-2)*4])->r 	- (int)((bgra_t*) &src_matrix[i][(j-1)*4])->r	 	-
								(int)((bgra_t*) &src_matrix[i][(j*4)])->r - (int)((bgra_t*) &src_matrix[i][(j+1)*4])->r		-
								(int)((bgra_t*) &src_matrix[i][(j+2)*4])->r - (int)((bgra_t*) &src_matrix[i+1][(j-2)*4])->r - 
								(int)((bgra_t*) &src_matrix[i+1][(j-1)*4])->r - (int)((bgra_t*) &src_matrix[i+1][(j*4)])->r - 
								(int)((bgra_t*) &src_matrix[i+1][(j+1)*4])->r - (int)((bgra_t*) &src_matrix[i+1][(j+2)*4])->r - 
								(int)((bgra_t*) &src_matrix[i+2][(j-2)*4])->r - (int)((bgra_t*) &src_matrix[i+2][(j-1)*4])->r - 
								(int)((bgra_t*) &src_matrix[i+2][(j*4)])->r - (int)((bgra_t*) &src_matrix[i+2][(j+1)*4])->r - 
								(int)((bgra_t*) &src_matrix[i+2][(j+2)*4])->r;
					int suma_g = (int)((bgra_t*) &src_matrix[i-2][(j-2)*4])->g- (int)((bgra_t*) &src_matrix[i-2][(j-1)*4])->g- 
								(int)((bgra_t*) &src_matrix[i-2][(j*4)])->g- (int)((bgra_t*) &src_matrix[i-2][(j+1)*4])->g- 
								(int)((bgra_t*) &src_matrix[i-2][(j+2)*4])->g- (int)((bgra_t*) &src_matrix[i-1][(j-2)*4])->g	- 
								(int)((bgra_t*) &src_matrix[i-1][(j-1)*4])->g- (int)((bgra_t*) &src_matrix[i-1][(j*4)])->g	-
								(int)((bgra_t*) &src_matrix[i-1][(j+1)*4])->g- (int)((bgra_t*) &src_matrix[i-1][(j+2)*4])->g	-
								(int)((bgra_t*) &src_matrix[i][(j-2)*4])->g	- (int)((bgra_t*) &src_matrix[i][(j-1)*4])->g	 	-
								(int)((bgra_t*) &src_matrix[i][(j*4)])->g- (int)((bgra_t*) &src_matrix[i][(j+1)*4])->g		-
								(int)((bgra_t*) &src_matrix[i][(j+2)*4])->g- (int)((bgra_t*) &src_matrix[i+1][(j-2)*4])->g- 
								(int)((bgra_t*) &src_matrix[i+1][(j-1)*4])->g- (int)((bgra_t*) &src_matrix[i+1][(j*4)])->g- 
								(int)((bgra_t*) &src_matrix[i+1][(j+1)*4])->g- (int)((bgra_t*) &src_matrix[i+1][(j+2)*4])->g- 
								(int)((bgra_t*) &src_matrix[i+2][(j-2)*4])->g- (int)((bgra_t*) &src_matrix[i+2][(j-1)*4])->g- 
								(int)((bgra_t*) &src_matrix[i+2][(j*4)])->g- (int)((bgra_t*) &src_matrix[i+2][(j+1)*4])->g- 
								(int)((bgra_t*) &src_matrix[i+2][(j+2)*4])->g;
					int suma_b = (int)((bgra_t*) &src_matrix[i-2][(j-2)*4])->b- (int)((bgra_t*) &src_matrix[i-2][(j-1)*4])->b- 
								(int)((bgra_t*) &src_matrix[i-2][(j*4)])->b- (int)((bgra_t*) &src_matrix[i-2][(j+1)*4])->b- 
								(int)((bgra_t*) &src_matrix[i-2][(j+2)*4])->b- (int)((bgra_t*) &src_matrix[i-1][(j-2)*4])->b	- 
								(int)((bgra_t*) &src_matrix[i-1][(j-1)*4])->b- (int)((bgra_t*) &src_matrix[i-1][(j*4)])->b	-
								(int)((bgra_t*) &src_matrix[i-1][(j+1)*4])->b- (int)((bgra_t*) &src_matrix[i-1][(j+2)*4])->b	-
								(int)((bgra_t*) &src_matrix[i][(j-2)*4])->b	- (int)((bgra_t*) &src_matrix[i][(j-1)*4])->b	 	-
								(int)((bgra_t*) &src_matrix[i][(j*4)])->b- (int)((bgra_t*) &src_matrix[i][(j+1)*4])->b		-
								(int)((bgra_t*) &src_matrix[i][(j+2)*4])->b- (int)((bgra_t*) &src_matrix[i+1][(j-2)*4])->b- 
								(int)((bgra_t*) &src_matrix[i+1][(j-1)*4])->b- (int)((bgra_t*) &src_matrix[i+1][(j*4)])->b- 
								(int)((bgra_t*) &src_matrix[i+1][(j+1)*4])->b- (int)((bgra_t*) &src_matrix[i+1][(j+2)*4])->b- 
								(int)((bgra_t*) &src_matrix[i+2][(j-2)*4])->b- (int)((bgra_t*) &src_matrix[i+2][(j-1)*4])->b- 
								(int)((bgra_t*) &src_matrix[i+2][(j*4)])->b- (int)((bgra_t*) &src_matrix[i+2][(j+1)*4])->b- 
								(int)((bgra_t*) &src_matrix[i+2][(j+2)*4])->b;

					int sumargb = suma_r - suma_g - suma_b;

						float r = (float)alpha * (float)sumargb * (float)p_s->r;
		 				float g = (float)alpha * (float)sumargb * (float)p_s->g;
						float b = (float)alpha * (float)sumargb * (float)p_s->b;
						r = r/max; 
						g = g/max;
						b = b/max;
						
						p_d->r = (unsigned char)MIN(MAX((float)p_s->r + r,(float)0),(float)255); 
						p_d->g = (unsigned char)MIN(MAX((float)p_s->g + g,(float)0),(float)255); 
						p_d->b = (unsigned char)MIN(MAX((float)p_s->b + b,(float)0),(float)255); 
							
								
        }
    }
}



