#include "tabla_tipos.h"

//Inicializa pila
void init_tt()
{
    pila_tt.max = -1;
    pila_tt.sp = -1;
}

//Inserta nuevo tipo en tabla de tipos actual
//Recibe variable de tipo TIPO
//Devuelve posición en la cual fue insertado el nuevo tipo
int insertar_tipo(TIPO t)
{
    int sp = pila_tt.sp;
    int pos = pila_tt.tablas[sp].pos;
    
    strcpy(pila_tt.tablas[sp].tipos[pos].tipo, t.tipo);
    pila_tt.tablas[sp].tipos[pos].dimension = t.dimension;
    pila_tt.tablas[sp].tipos[pos].base = t.base;
    pila_tt.tablas[sp].pos++;
    return pos;
}

//Imprime tabla de tipos indicada mediante un identificador numérico llamado 'tabla'
void imprimir_tabla_tipos(int tabla)
{
    int i;
    printf("////////////////////////////////////////////////////////////////////////////////\n");
    printf("Pos\t Tipo\t Dim\t Base\n");
    for(i=0; i<pila_tt.tablas[tabla].pos; i++)
    {
        printf("%d\t %s\t %d\t %d\n", i, pila_tt.tablas[tabla].tipos[i].tipo,
               pila_tt.tablas[tabla].tipos[i].dimension, pila_tt.tablas[tabla].tipos[i].base);
    }
}

int obtener_dimension(int tipo, int tabla)
{
    int dimension, i;
    for(i=0; i<pila_tt.tablas[tabla].pos; i++)
    {
        if(i==tipo)
        {
            dimension=pila_tt.tablas[tabla].tipos[i].dimension;
            break;
        }
    }
    
    return dimension;
}

int obtener_tipo_base(int tipo, int tabla)
{
    int tipo_base, i;
    for(i=0; i<pila_tt.tablas[tabla].pos; i++)
    {
        if(i==tipo)
        {
            tipo_base=pila_tt.tablas[tabla].tipos[i].base;
            break;
        }
    }
    
    return tipo_base;
}

int es_arreglo(int tipo, int tabla)
{
    int i;
    for(i=0; i<pila_tt.tablas[tabla].pos; i++)
        if(i==tipo)
            if(!strcmp(pila_tt.tablas[tabla].tipos[i].tipo, "array"))
                return 1;
    
    return 0;
}

int es_estructura(int tipo, int tabla)
{
    int i;
    for(i=0; i<pila_tt.tablas[tabla].pos; i++)
        if(i==tipo)
            if(!strcmp(pila_tt.tablas[tabla].tipos[i].tipo, "struct"))
                return 1;
    
    return 0;
}

int obtener_numero_dim(int tipo, int tabla)
{
    int base, dim;
    dim=0;
    base=obtener_tipo_base(tipo, tabla);
    while(base!=-1)
    {
        dim++;
        base=obtener_tipo_base(base, tabla);
    }
    
    return dim;
}

//Crea tabla de tipos con sus respectivas primitivas
void crear_tabla_tipos()
{
    pila_tt.max++;
    pila_tt.sp = pila_tt.max;
    int sp = pila_tt.sp;
    pila_tt.tablas[sp].pos = 0;
    
    strcpy(pila_tt.tablas[sp].tipos[0].tipo, "void");
    pila_tt.tablas[sp].tipos[0].dimension = 0;
    pila_tt.tablas[sp].tipos[0].base = -1;
    pila_tt.tablas[sp].pos++;
    
    strcpy(pila_tt.tablas[sp].tipos[1].tipo, "char");
    pila_tt.tablas[sp].tipos[1].dimension = 2;
    pila_tt.tablas[sp].tipos[1].base = -1;
    pila_tt.tablas[sp].pos++;
    
    strcpy(pila_tt.tablas[sp].tipos[2].tipo, "int");
    pila_tt.tablas[sp].tipos[2].dimension = 4;
    pila_tt.tablas[sp].tipos[2].base = -1;
    pila_tt.tablas[sp].pos++;
    
    strcpy(pila_tt.tablas[sp].tipos[3].tipo, "float");
    pila_tt.tablas[sp].tipos[3].dimension = 8;
    pila_tt.tablas[sp].tipos[3].base = -1;
    pila_tt.tablas[sp].pos++;
    
    strcpy(pila_tt.tablas[sp].tipos[4].tipo, "double");
    pila_tt.tablas[sp].tipos[4].dimension = 16;
    pila_tt.tablas[sp].tipos[4].base = -1;
    pila_tt.tablas[sp].pos++;
    
    
}

//Cambia apuntador a pila anterior
void eliminar_tabla_tipos()
{
    pila_tt.tablas[pila_tt.max].pos = 0;
    pila_tt.max--;
    pila_tt.sp = pila_tt.max;
    
}

