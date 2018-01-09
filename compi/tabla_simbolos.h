/*
 * Archivo: tabla_simbolos.h
 * Autor: Equipo Maravilla
 * Basado en symbol_table3.h perteneciente al profesor
 * 
*/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define NUM_SIMBOLOS 50
#define NUM_TABLAS_SIMBOLOS 20

//Creamos estructura para cada símbolo
typedef struct _SIMBOLO{
    char id[20];                //Lexema, identificadores no mayores a cadenas de 20
    int tipo;                   //void tipo 0, char tipo 1, int tipo 2, float 3, double 4 
    int tipo_variable;          //0=var, 1=func
    int dir;                    //En donde empieza su posición
    int num_args;               //Número de argumentos que posee
    int tipo_args[30];          //Tipo de argumentos que recibe
    int ptr_tt;                 //Usada para estructuras y funciones
}SIMBOLO;

//Creamos estructura para la tabla de símbolos
typedef struct _TABLA_SIMBOLOS{
    SIMBOLO simbolos[NUM_SIMBOLOS];
    int pos;                    //Indice
}TABLA_SIMBOLOS;

//Creamos pila para tabla de símbolos
typedef struct _PILA_TABLA_SIMBOLOS{
    TABLA_SIMBOLOS tablas[NUM_TABLAS_SIMBOLOS];
    int sp;
    int max;
}PILA_TABLA_SIMBOLOS;

//Inicializamos la pila para la tabla de símbolos
PILA_TABLA_SIMBOLOS pila_ts;

//Declaramos funciones que utilizaremos más adelante

void init_ts();
int insertar_simbolo(SIMBOLO sim, int tabla);
int buscar_simbolo(char* id, int tabla);
int obtener_tipo(char* id, int tabla);
int obtener_tt(char* id, int tabla);
int es_funcion(char* id, int tabla);
int obtener_argumentos(char* id, int tabla, int elemento);
int obtener_num_argumentos(char* id, int tabla);
void imprimir_tabla_simbolos(int tabla, char* nombre);
void crear_tabla_simbolos();
void eliminar_tabla_simbolos();
