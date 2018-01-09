#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "cMips.h"

#define NUM_INST 1000

typedef struct _INSTRUCCION{
    char op1[20];
    char op2[20];
    char operador[20];
    char res[20];
}INSTRUCCION;

typedef struct _CUADRUPLA{
    INSTRUCCION instrucciones[NUM_INST];
    int pos;
}CUADRUPLA;

CUADRUPLA cuadruplas;

void init_cuadrupla(void);
void insertar_instruccion(char* res, char* op1, char* operador, char* op2);
void imprimir_cuadruplas(void);
