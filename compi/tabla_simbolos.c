#include "tabla_simbolos.h"

void init_ts()
{
    pila_ts.max=-1;
    pila_ts.sp = -1;
}

//Recibe variable de tipo SIMBOLO, identificador numérico de tabla
//Devuelve 1 si termina exitoso, 0 si no
int insertar_simbolo(SIMBOLO sim, int tabla)
{
    int pos = pila_ts.tablas[tabla].pos;
    if(buscar_simbolo(sim.id, tabla)==0 && pila_ts.tablas[tabla].pos<NUM_SIMBOLOS+1)
    {
        pila_ts.tablas[tabla].simbolos[pos] = sim;
        pila_ts.tablas[tabla].pos++;
        return 1;
    }
    return 0;
}

//Recibe apuntador a id, identificador numérico de tabla
//Devuelve 1 si termina exitoso, 0 sino
int buscar_simbolo(char* id, int tabla)
{
    int i;
    for(i=0; i<pila_ts.tablas[tabla].pos+1; i++)
    {
        if(strcmp(pila_ts.tablas[tabla].simbolos[i].id, id) == 0)
        {
            return 1;
        }
    }
    return 0;
}

//Recibe apuntador a id, identificador numérico de tabla
//Devuelve tipo si está basado en alguno, -1 si es primitiva
int obtener_tipo(char* id, int tabla)
{
    int i;
    int pos = pila_ts.tablas[tabla].pos;
    for(i=0; i<pos+1; i++)
    {
        if(strcmp(pila_ts.tablas[tabla].simbolos[i].id, id) == 0)
        {
            return pila_ts.tablas[tabla].simbolos[i].tipo;
        }
    }
    return -1;
}

int obtener_tt(char* id, int tabla)
{
    int i;
    for(i=0; i<pila_ts.tablas[tabla].pos+1; i++)
    {
        if(!strcmp(pila_ts.tablas[tabla].simbolos[i].id, id))
        {
            return pila_ts.tablas[tabla].simbolos[i].ptr_tt;
        }
    }
    return 0;
}

int es_funcion(char* id, int tabla)
{
    int i;
    for(i=0; i<pila_ts.tablas[tabla].pos+1; i++)
    {
        if(!strcmp(pila_ts.tablas[tabla].simbolos[i].id, id))
        {
            if(pila_ts.tablas[tabla].simbolos[i].tipo_variable==1)
                return 1;
        }
    }
    return 0;
}

int obtener_num_argumentos(char* id, int tabla)
{
    int i;
    for(i=0; i<pila_ts.tablas[tabla].pos+1; i++)
    {
        if(!strcmp(pila_ts.tablas[tabla].simbolos[i].id, id))
            return pila_ts.tablas[tabla].simbolos[i].num_args;
    }
    return 0; //No puede haber 0 elementos por lo que se usa para error
}

int obtener_argumentos(char* id, int tabla, int elemento)
{
    int i;
    for(i=0; i<pila_ts.tablas[tabla].pos+1; i++)
    {
        if(!strcmp(pila_ts.tablas[tabla].simbolos[i].id, id))
            return pila_ts.tablas[tabla].simbolos[i].tipo_args[elemento];
    }
    return 0;//No puede haber parametros de tipo void, por lo que se utilizara para error
}

//Recibe un identificador numérico de tabla, apuntador a cadena que de usuario para nombrar tabla
void imprimir_tabla_simbolos(int tabla, char* nombre)
{
    int i, j;
    printf("////////////////////////////////////////////////////////////////////////////////\n");
    printf("Tabla de Simbolos %s\n", nombre);
    printf("Pos\t Id\t\t Tipo\t Tipo Variable\t Dir\t Num Args\t Tipo Args\t \n");
    for(i=0; i<pila_ts.tablas[tabla].pos; i++)
    {
        printf("%d\t %s\t\t %d ", i, pila_ts.tablas[tabla].simbolos[i].id, pila_ts.tablas[tabla].simbolos[i].tipo);
        if(pila_ts.tablas[tabla].simbolos[i].tipo_variable==0)
            printf("\tvariable\t%d\t ", pila_ts.tablas[tabla].simbolos[i].dir);
        else
            printf("\tfuncion\t-1\t ");
        
        printf("%d\t\t", pila_ts.tablas[tabla].simbolos[i].num_args);
        
        if(pila_ts.tablas[tabla].simbolos[i].num_args==-1)
            printf("-1");
        else
            for(j=0; j<pila_ts.tablas[tabla].simbolos[i].num_args; j++)
            {
                printf("%d ",pila_ts.tablas[tabla].simbolos[i].tipo_args[j]);
            }
        printf("\n");
    }
        
}

void crear_tabla_simbolos()
{
    pila_ts.max++;
    pila_ts.sp=pila_ts.max;
    pila_ts.tablas[pila_ts.sp].pos = 0;
}

void eliminar_tabla_simbolos()
{
    pila_ts.tablas[pila_ts.max].pos = 0;
    pila_ts.max--;
    pila_ts.sp=pila_ts.max;
}
