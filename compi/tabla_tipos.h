#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define NUM_TIPOS 100
#define NUM_TABLAS_TIPOS 10

typedef struct _TIPO{
    char tipo[20];
    int dimension;
    int base;
}TIPO;

typedef struct _TABLA_TIPOS{
    TIPO tipos[NUM_TIPOS];                  //void tipo 0, char tipo 1, int tipo 2, float 3, double 4
    int pos;
}TABLA_TIPOS;

typedef struct _PILA_TABLA_TIPOS{
    TABLA_TIPOS tablas[NUM_TABLAS_TIPOS];
    int sp;
    int max;
}PILA_TABLA_TIPOS;

PILA_TABLA_TIPOS pila_tt;

void init_tt();
int insertar_tipo(TIPO t);
void imprimir_tabla_tipos(int tabla);
int obtener_dimension(int tipo, int tabla);
int obtener_tipo_base(int tipo, int tabla);
int es_arreglo(int tipo, int tabla);
int es_estructura(int tipo, int tabla);
int obtener_numero_dim(int tipo, int tabla);
void crear_tabla_tipos();
void eliminar_tabla_tipos();
