#include "codigo_intermedio.h"
#include "cMips.c"

void init_cuadrupla(void)
{
    cuadruplas.pos=0;
}

void insertar_instruccion(char* res, char* operador, char* op1, char* op2)
{
    int pos=cuadruplas.pos;
    strcpy(cuadruplas.instrucciones[pos].res, res);
    strcpy(cuadruplas.instrucciones[pos].op1, op1);
    strcpy(cuadruplas.instrucciones[pos].operador, operador);
    strcpy(cuadruplas.instrucciones[pos].op2, op2);
    cuadruplas.pos++;
}

void imprimir_cuadruplas(void)
{
    int i;
    int contador=0;
    char espacio=' ';
    FILE *fp,*encabezado;
    fp = fopen("mips_code2.s","w");
    encabezado=fopen("mips_code1.s","w");
    fprintf(encabezado,".data\n");
    fprintf(fp,"global: .word 0\n");
    fprintf(fp,".text\n");
    printf("//////////////////////////////////////\n");
    printf("Pos\tRes\tOperador\tOp1\t%c\t%c\tOp2\n",espacio,espacio);
    for(i=0; i<cuadruplas.pos; i++)
    {
        printf(" %d\t %s\t %s\t %c\t %s\t %c\t %c\t %s\n", i, cuadruplas.instrucciones[i].res, cuadruplas.instrucciones[i].operador, espacio, cuadruplas.instrucciones[i].op1, espacio, espacio, cuadruplas.instrucciones[i].op2);
        genCod(cuadruplas.instrucciones[i].res,cuadruplas.instrucciones[i].operador,cuadruplas.instrucciones[i].op1,cuadruplas.instrucciones[i].op2,fp,encabezado,&contador);
    }
    fclose(fp);
    fclose(encabezado);
    system("cat mips_code2.s >> mips_code1.s");
    system("rm mips_code2.s");
}
