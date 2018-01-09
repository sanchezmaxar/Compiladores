%{
#include "tabla_simbolos.h"
#include "tabla_tipos.h"
#include "codigo_intermedio.h"

extern int yylineno;
extern char* yytext;
extern FILE* yyin;
extern int yylex();
extern FILE* yyout;
//simbolo que va entrar a la tabla de simbolos
SIMBOLO s;
//tipo que va a entrar a la tabla de tipos 
TIPO t;

void nuevo_ambito(void);
void imprimir_tablas(char* s);
void previo_ambito(void);
void ambito_mas_uno(void);
void ambito_menos_uno(void);
void insertar_s(char *id, int tipo, int tipo_variable, int dir, int num_args, int tipo_args[]);
void expresion_tipo(int* t0, char* e0, char* ci, int t1, char* e1, int t2, char* e2, int op);
void realizar_bool(int* op0, char* ci, char* op1, int t1, char* op2, int t2, int operador);

/*
void newTemp(char *dir);
void newLabel(char *label);
*/
void yyerror(char* s);

// globales para no terminal 'tipo', w es dimension, t es tipo
int w_b, t_b;

//auxiliares para dimensiones en definicion de funcion, usados en lugar de struc arg_list y otros
int n_dimensiones;
int countA;
int arrayA[30];
int aux_ptr_tt;
char aux_id[20];
char aux_func[20];
char aux_array[20];
int sp;
int temporales;
char num[5];
char aux_e0[5];
char aux_ci[20];
int n_etiquetas;
char aux_etiquetas[20];
int aux_case[20];

int dir = 0;

int tipo_func;

typedef struct _DIR_PILA{
    int dir[20];
    int pos;
}DIR_PILA;

DIR_PILA dirPila;
int index_temp = 0;
int index_label = 0;
%}

%union{
    struct{
        int ival;
        float fval;
        double dval;
        char sval[20];
        int tipo; //2 para int, 3 para float, 4 para double
    } num;
    
    struct{
        char ci[20];
        char dir[20];
        int tipo;        
    }exp;
    
    struct{
        int tipo;
        int dim;        
    } tipo;
    
    struct{
        int args[30];
        int count;
    } arg_list;
    
    struct{
        char next[20];  
        int tipo;
    } sent;
    
    struct{
        int val;            //false : 0, true : 1
        char ci[20];
    } exp_log;
    
    int op_rel;     //< : 0, > : 1, >= : 3, <= : 4, != : 5, == : 6
    
    int line;
    
    char sval[20];
}

%token<sval> ID CARACTER CADENA
%token<num> NUMERO
%token VOID INT FLOAT DOUBLE CHAR STRUCT
%token FUNC 
%token IF WHILE DO FOR RETURN SWITCH BREAK PRINT
%token CASE DEFAULT
%token PYC DP PUNTO
%token TRUE FALSE
%token LKEY RKEY

/* Precedencia de Operadores*/
%left COMA
%right ASIG
%left OP_OR
%left OP_AND
%left EQ_OP NE_OP
%left GT_OP LT_OP GE_OP LE_OP
%left MAS MEN
%left MUL DIV MOD
%left OP_NOT
%nonassoc LPAR RPAR LCOR RCOR
%left IFX
%left ELSE

%start programa


/* Declaracion del tipo de los no terminales */
%type <tipo> tipo lista_identificadores tipo_arreglo
%type <exp> expresion identificadores arreglos
%type <op_rel> operadores_relacionales
%type <exp_log> expresion_logica
%type <sent> sentencias
%%

/* P -> D F */
programa
            : {
                
                init_tt();
                init_ts();
                init_cuadrupla();
                temporales=0;
                n_etiquetas=0;
                dirPila.pos = 0;
                nuevo_ambito();
                } declaracion definicion_funciones {
                                                    imprimir_tablas("global");
                                                    imprimir_cuadruplas();
                                                    }
            ;

/* D -> T L | epsilon */
declaracion
            : tipo {
                if($1.tipo==0)
                {
                    yyerror("Tipo de variable no permitido");
                }
                else
                {
                    t_b = $1.tipo;
                    w_b = $1.dim;
                }
                } lista_identificadores { /* Usando método del profesor, ya no es necesario código aquí */}
            | /* %empty */ {}
            ;

/* T -> int | float | double | char | void | struct { D } */
tipo
            : INT {$$.tipo = 2; $$.dim = 4;}
            | FLOAT {$$.tipo = 3; $$.dim = 8;}
            | DOUBLE {$$.tipo = 4; $$.dim = 16;}
            | CHAR {$$.tipo = 1; $$.dim = 2;}
            | VOID {$$.tipo = 0; $$.dim = 0;}
            | STRUCT LKEY {
                            nuevo_ambito();
                            } declaracion RKEY { 
                                                            imprimir_tablas("Nuevo Ambito de Estructura");
                                                            previo_ambito();
                                                            strcpy(t.tipo,"struct");
                                                            t.dimension=dir; 
                                                            t.base=-1;
                                                            $$.tipo=insertar_tipo(t);
                                                            $$.dim=dir; 
                                                            dir=dirPila.pos;
                                                            }
            ;
            
/* L -> L1 , id C | id C */
lista_identificadores
            : lista_identificadores COMA ID tipo_arreglo {
                                                            if(!buscar_simbolo($3,pila_ts.sp))
                                                            {
                                                                insertar_s($3, $4.tipo, 0, $4.dim, -1, NULL);
                                
                                                            }
                                                            else
                                                            {
                                                                yyerror("El simbolo ya existe en este ambito");
                                                            }
                                                        }
            | ID tipo_arreglo {
                                if(!buscar_simbolo($1,pila_ts.sp))
                                {
                                    insertar_s($1, $2.tipo, 0, $2.dim, -1, NULL);
                                }
                                else
                                {
                                    yyerror("El simbolo ya existe en este ambito");
                                }
                            }
            ;
            
/* C -> [ numero ] C1 | epsilon */
tipo_arreglo
            : LCOR NUMERO RCOR tipo_arreglo {
                                                if($2.tipo==2 && $2.ival>0)
                                                {
                                                    strcpy(t.tipo,"array");
                                                    t.dimension=$2.ival;
                                                    t.base=$4.tipo;
                                                    $$.tipo=insertar_tipo(t);
                                                    $$.dim=$4.dim*$2.ival;
                                                }
                                                else
                                                {
                                                    yyerror("La dimensión debe ser un valor entero mayor a cero");
                                                }
                                            }
            | /* %empty */ {
                            $$.tipo=t_b;
                            $$.dim=w_b;
                            }
            ;
            
/* F -> func T id ( A ) { D S } F1 | epsilon */
definicion_funciones
            : FUNC tipo ID LPAR{
                                nuevo_ambito();
                                countA=0;
                                } lista_definicion_parametros RPAR{
                                                                    previo_ambito();
                                                                    if(!buscar_simbolo($3,pila_ts.sp))
                                                                    {
                                                                        insertar_s($3, $2.tipo, 1, 0, countA, arrayA);
                                                                        strcpy(aux_func, $3);
                                                                        insertar_instruccion("", "label", $3, "");
                                                                        fprintf(yyout, "\n%s:", $3);
                                                                    }
                                                                    else
                                                                    {
                                                                        yyerror("El simbolo ya existe en este ambito");
                                                                    }
                                                                    previo_ambito();
                                                                } LKEY declaracion sentencias {
                                                                                                if($2.tipo!=$11.tipo)
                                                                                                {
                                                                                                    if($2.tipo)
                                                                                                    {
                                                                                                        yyerror("Tipo de la funcion y tipo del valor de retorno incompatibles");
                                                                                                    }
                                                                                                    else
                                                                                                    {
                                                                                                        yyerror("Las funciones tipo void no pueden retornar valores");
                                                                                                    }
                                                                                                }
                                                                                                } RKEY {
                                                                                                    imprimir_tablas("Nuevo Ambito de Funcion");
                                                                                                    previo_ambito();
                                                                                                    } definicion_funciones {}
            | /* %empty */ {
                            if(strcmp(aux_func,"main"))
                            {
                                yyerror("Falta funcion main");
                            }
                        }
            ;
            
/* A -> G | epsilon */
lista_definicion_parametros
            : lista_parametros {}
            |  /* %empty */ {}
            ;
            
/* G -> G1 , T id I | T id I */
lista_parametros
            : lista_parametros COMA tipo ID {
                                            if($3.tipo==0)
                                            {
                                                yyerror("Tipo de parametro no valido");
                                            }
                                            else
                                            {
                                                n_dimensiones=0;
                                            }
                                            } parametro_tipo_arreglo {
                                                                        if(n_dimensiones>0)
                                                                        {
                                                                            strcpy(t.tipo,"array");
                                                                            t.dimension=n_dimensiones;
                                                                            t.base=$3.tipo;
                                                                            t_b=insertar_tipo(t);
                                                                            w_b=0;
                                                                        }
                                                                        else
                                                                        {
                                                                            t_b=$3.tipo;
                                                                            w_b=$3.dim;
                                                                        }
                                                                        if(!buscar_simbolo($4,pila_ts.sp)){
                                                                            insertar_s($4, t_b, 0, w_b, -1, NULL);
                                                                            arrayA[countA]=t_b;
                                                                            countA++;
                                                                        }
                                                                        else
                                                                        {
                                                                            yyerror("El simbolo ya existe en este ambito");
                                                                        }
                                                                    }
            | tipo ID {
                        n_dimensiones=0;
                    } parametro_tipo_arreglo {
                                                if(n_dimensiones>0)
                                                {
                                                    strcpy(t.tipo,"array");
                                                    t.dimension=n_dimensiones;
                                                    t.base=$1.tipo;
                                                    t_b=insertar_tipo(t); w_b=0;
                                                }
                                                else
                                                {
                                                    t_b=$1.tipo;
                                                    w_b=$1.dim;
                                                }
                                                if(!buscar_simbolo($2,pila_ts.sp))
                                                {
                                                    insertar_s($2, t_b, 0, w_b, -1, NULL);
                                                    arrayA[countA]=t_b; countA++;
                                                }
                                                else
                                                {
                                                    yyerror("El simbolo ya existe en este ambito");
                                                }
                                            }
            ;
            
/* I -> [ ] I1 | epsilon */ /* Se da una dimension por default de 100, cuando el parametro se pasa esta es actualizada? */
parametro_tipo_arreglo
            : LCOR RCOR {
                        n_dimensiones++;
                        } parametro_tipo_arreglo  
            | /* %empty */ {}
            ;
            
/* S -> S1 S2 | if ( B ) S1 | if ( B ) S1 else S2| while ( B ) S1 | do S1 while ( B ) ; | for ( S1 ; B; S2) S3 | U = E ;
        | return E ; | return ; | { S } | switch ( E ) { J K } | break ; | print E ; */
sentencias
            : sentencias sentencias {
                                    $$.tipo=$2.tipo;
                                    if($$.tipo)
                                    {
                                        strcpy($$.next,$2.next);
                                    }
                                    }
            | IF LPAR expresion_logica RPAR
                                            {
                                                sprintf(aux_etiquetas, "%d", n_etiquetas);
                                                strcpy(aux_ci,"L");
                                                strcat(aux_ci, aux_etiquetas);
                                                n_etiquetas++;
                                                insertar_instruccion("", "if", $3.ci, "");
                                                insertar_instruccion("", "goto", aux_ci, "");
                                                fprintf(yyout, "if %s goto %s\n", $3.ci, aux_ci);
                                                
                                                sprintf(aux_etiquetas, "%d", n_etiquetas);
                                                strcpy(aux_ci,"L");
                                                strcat(aux_ci, aux_etiquetas);
                                                n_etiquetas--;
                                                insertar_instruccion("", "goto", aux_ci, "");
                                                fprintf(yyout, "goto %s\n", aux_ci);
                                                
                                                sprintf(aux_etiquetas, "%d", n_etiquetas);
                                                strcpy(aux_ci,"L");
                                                strcat(aux_ci, aux_etiquetas);
                                                n_etiquetas++;
                                                insertar_instruccion("", "label", aux_ci, "");
                                                fprintf(yyout, "\n%s:", aux_ci);
                                                
                                            }
                                            sentencias %prec IFX 
                                                                {
                                                                    $$.tipo=0;
                                                                    sprintf(aux_etiquetas, "%d", n_etiquetas);
                                                                    strcpy(aux_ci,"L");
                                                                    strcat(aux_ci, aux_etiquetas);
                                                                    n_etiquetas++;
                                                                    insertar_instruccion("", "label", aux_ci, "");
                                                                    fprintf(yyout, "\n%s:", aux_ci);
                                            
                                                                }
            | IF LPAR expresion_logica RPAR
                                            {
                                            sprintf(aux_etiquetas, "%d", n_etiquetas);
                                            strcpy(aux_ci,"L");
                                            strcat(aux_ci, aux_etiquetas);
                                            n_etiquetas++;
                                            insertar_instruccion("", "if", $3.ci, "");
                                            insertar_instruccion("", "goto", aux_ci, "");
                                            fprintf(yyout, "if %s goto %s\n", $3.ci, aux_ci);
                                            
                                            sprintf(aux_etiquetas, "%d", n_etiquetas);
                                            strcpy(aux_ci,"L");
                                            strcat(aux_ci, aux_etiquetas);
                                            n_etiquetas--;      
                                            insertar_instruccion("", "goto", aux_ci, "");
                                            fprintf(yyout, "goto %s\n", aux_ci);
                                            
                                            sprintf(aux_etiquetas, "%d", n_etiquetas);
                                            strcpy(aux_ci,"L");
                                            strcat(aux_ci, aux_etiquetas);
                                            n_etiquetas+=2;
                                            insertar_instruccion("", "label", aux_ci, "");
                                            fprintf(yyout, "\n%s:", aux_ci);
                                            }
                                            sentencias {
                                                        sprintf(aux_etiquetas, "%d", n_etiquetas);
                                                        strcpy(aux_ci,"L");
                                                        strcat(aux_ci, aux_etiquetas);
                                                        n_etiquetas--;      
                                                        insertar_instruccion("", "goto", aux_ci, "");
                                                        fprintf(yyout, "goto %s\n", aux_ci);
                                                        
                                                        sprintf(aux_etiquetas, "%d", n_etiquetas);
                                                        strcpy(aux_ci,"L");
                                                        strcat(aux_ci, aux_etiquetas);
                                                        n_etiquetas++;
                                                        insertar_instruccion("", "label", aux_ci, "");
                                                        fprintf(yyout, "\n%s:", aux_ci);
                                        
                                                        } ELSE sentencias {
                                                                        $$.tipo=0;
                                                                        sprintf(aux_etiquetas, "%d", n_etiquetas);
                                                                        strcpy(aux_ci,"L");
                                                                        strcat(aux_ci, aux_etiquetas);
                                                                        n_etiquetas++;
                                                                        insertar_instruccion("", "label", aux_ci, "");
                                                                        fprintf(yyout, "\n%s:", aux_ci);
                                        
                                                                        }
            | WHILE LPAR expresion_logica RPAR 
                                                {
                                                sprintf(aux_etiquetas, "%d", n_etiquetas);
                                                strcpy(aux_ci,"L");
                                                strcat(aux_ci, aux_etiquetas);
                                                n_etiquetas++;
                                                insertar_instruccion("", "label", aux_ci, "");
                                                fprintf(yyout, "\n%s:", aux_ci);
                                                
                                                sprintf(aux_etiquetas, "%d", n_etiquetas);
                                                strcpy(aux_ci,"L");
                                                strcat(aux_ci, aux_etiquetas);
                                                n_etiquetas++;
                                                insertar_instruccion("", "if", $3.ci, "");
                                                insertar_instruccion("", "goto", aux_ci, "");
                                                fprintf(yyout, "if %s goto %s\n", $3.ci, aux_ci);
                                            
                                                sprintf(aux_etiquetas, "%d", n_etiquetas);
                                                strcpy(aux_ci,"L");
                                                strcat(aux_ci, aux_etiquetas);
                                                n_etiquetas--;
                                                insertar_instruccion("", "goto", aux_ci, "");
                                                fprintf(yyout, "goto %s\n", aux_ci);
                                                
                                                sprintf(aux_etiquetas, "%d", n_etiquetas);
                                                strcpy(aux_ci,"L");
                                                strcat(aux_ci, aux_etiquetas);
                                                n_etiquetas--;
                                                insertar_instruccion("", "label", aux_ci, "");
                                                fprintf(yyout, "\n%s:", aux_ci);
                                            
                                                }sentencias {
                                                            $$.tipo=0;
                                                            sprintf(aux_etiquetas, "%d", n_etiquetas);
                                                            strcpy(aux_ci,"L");
                                                            strcat(aux_ci, aux_etiquetas);
                                                            n_etiquetas+=2;
                                                            insertar_instruccion("", "goto", aux_ci, "");
                                                            fprintf(yyout, "goto %s\n", aux_ci);
                                                            
                                                            sprintf(aux_etiquetas, "%d", n_etiquetas);
                                                            strcpy(aux_ci,"L");
                                                            strcat(aux_ci, aux_etiquetas);
                                                            n_etiquetas++;
                                                            insertar_instruccion("", "label", aux_ci, "");
                                                            fprintf(yyout, "%s:\n", aux_ci);
                                                            
                                                            }
            | DO {
                    sprintf(aux_etiquetas, "%d", n_etiquetas);
                    strcpy(aux_ci,"L");
                    strcat(aux_ci, aux_etiquetas);
                    insertar_instruccion("", "label", aux_ci, "");
                    fprintf(yyout, "\n%s:", aux_ci);
                                                
                    } sentencias WHILE LPAR expresion_logica RPAR PYC {
                                                                        $$.tipo=0;
                                                                        n_etiquetas++;
                                                                        insertar_instruccion("", "if", $6.ci, "");
                                                                        insertar_instruccion("", "goto", aux_ci, "");
                                                                        fprintf(yyout, "if %s goto %s\n", $6.ci, aux_ci);
                                                                        
                                                                        sprintf(aux_etiquetas, "%d", n_etiquetas);
                                                                        strcpy(aux_ci,"L");
                                                                        strcat(aux_ci, aux_etiquetas);
                                                                        insertar_instruccion("", "goto", aux_ci, "");
                                                                        fprintf(yyout, "goto %s\n:", aux_ci);
                                                                        
                                                                        n_etiquetas++;
                                                                        insertar_instruccion("", "label", aux_ci, "");
                                                                        fprintf(yyout, "\n%s:", aux_ci);
                                                                        
                    
                                                                    }
            | FOR LPAR sentencias PYC expresion_logica PYC {
                                                            sprintf(aux_etiquetas, "%d", n_etiquetas);
                                                            strcpy(aux_ci,"L");
                                                            strcat(aux_ci, aux_etiquetas);
                                                            n_etiquetas++;
                                                            insertar_instruccion("", "label", aux_ci, "");
                                                            fprintf(yyout, "\n%s:", aux_ci);
                                                                    
                                                            sprintf(aux_etiquetas, "%d", n_etiquetas);
                                                            strcpy(aux_ci,"L");
                                                            strcat(aux_ci, aux_etiquetas);
                                                            n_etiquetas++;
                                                            insertar_instruccion("", "if", $5.ci, "");
                                                            insertar_instruccion("", "goto", aux_ci, "");
                                                            fprintf(yyout, "if %s goto %s\n", $5.ci, aux_ci);
                                                            
                                                            sprintf(aux_etiquetas, "%d", n_etiquetas);
                                                            strcpy(aux_ci,"L");
                                                            strcat(aux_ci, aux_etiquetas);
                                                            n_etiquetas++;
                                                            insertar_instruccion("", "goto", aux_ci, "");
                                                            fprintf(yyout, "goto %s\n", aux_ci);
                                                            
                                                            sprintf(aux_etiquetas, "%d", n_etiquetas);
                                                            strcpy(aux_ci,"L");
                                                            strcat(aux_ci, aux_etiquetas);
                                                            n_etiquetas-=3;
                                                            insertar_instruccion("", "label", aux_ci, "");
                                                            fprintf(yyout, "\n%s:", aux_ci);
                                                            
                                                            } sentencias {
                                                                            sprintf(aux_etiquetas, "%d", n_etiquetas);
                                                                            strcpy(aux_ci,"L");
                                                                            strcat(aux_ci, aux_etiquetas);
                                                                            n_etiquetas++;
                                                                            insertar_instruccion("", "goto", aux_ci, "");
                                                                            fprintf(yyout, "goto %s\n", aux_ci);
                                                                            
                                                                            sprintf(aux_etiquetas, "%d", n_etiquetas);
                                                                            strcpy(aux_ci,"L");
                                                                            strcat(aux_ci, aux_etiquetas);
                                                                            n_etiquetas+=2;
                                                                            insertar_instruccion("", "label", aux_ci, "");
                                                                            fprintf(yyout, "\n%s:", aux_ci);
                                                            
                                                                            } RPAR sentencias {
                                                                                            $$.tipo=0;
                                                                                            sprintf(aux_etiquetas, "%d", n_etiquetas);
                                                                                            strcpy(aux_ci,"L");
                                                                                            strcat(aux_ci, aux_etiquetas);
                                                                                            n_etiquetas--;
                                                                                            insertar_instruccion("", "goto", aux_ci, "");
                                                                                            fprintf(yyout, "goto %s\n", aux_ci);
                                                                                            
                                                                                            sprintf(aux_etiquetas, "%d", n_etiquetas);
                                                                                            strcpy(aux_ci,"L");
                                                                                            strcat(aux_ci, aux_etiquetas);
                                                                                            n_etiquetas+=2;
                                                                                            insertar_instruccion("", "label", aux_ci, "");
                                                                                            fprintf(yyout, "\n%s:", aux_ci);
                                                                            
                                                                                        }
            | identificadores ASIG expresion PYC {
                                                    if($1.tipo==$3.tipo)
                                                    {
                                                        $$.tipo=0;
                                                        insertar_instruccion($1.dir, "=", $3.ci, "");
                                                        fprintf(yyout, "%s = %s\n", $1.dir, $3.ci);
                                                    }
                                                    else
                                                    {
                                                        yyerror("Los tipos no coinciden");
                                                    }
                                                } 
            | RETURN expresion PYC {
                                    strcpy($$.next,$2.dir);
                                    $$.tipo=$2.tipo;
                                    insertar_instruccion("", "return", $2.ci, "");
                                    fprintf(yyout, "return %s\n", $2.ci);
                                    }
            | RETURN PYC {
                            $$.tipo=0;
                            insertar_instruccion("", "return", "", "");/*Si es necesario generar siempre la etiqueta poner al nivel de definicion_funciones*/
                            fprintf(yyout, "return\n");
                            }
            | LKEY sentencias RKEY {
                                    $$.tipo=$2.tipo;
                                    }
            | SWITCH  LPAR expresion RPAR {
                                            strcpy(aux_case, $3.ci);
                                            } LKEY casos caso_predeterminado RKEY {
                                                                                $$.tipo=0;
                                                                                }
            | BREAK PYC { 
                        $$.tipo=0;
                        /*añadir etiquetas adecuadas en mips y código intermedio*/

                        }
            | PRINT expresion PYC {
                                    $$.tipo=0;
                                    /*añadir etiquetas adecuadas en mips y código intermedio*/
                                    insertar_instruccion("", "print", $2.ci, "");
                                    fprintf(yyout, "print %s\n", $2.ci);
                                }
            ; 
            
/* J -> case : numero S J1 | epsilon */
casos
            : CASE DP NUMERO {
                                                if($3.tipo==2)
                                                {
                                                    insertar_instruccion("", "label", aux_ci, "");
                                                    fprintf(yyout, "\n%s:", aux_ci);
                                                    
                                                    sprintf(aux_etiquetas, "%d", n_etiquetas);
                                                    strcpy(aux_ci,"L");
                                                    strcat(aux_ci, aux_etiquetas);
                                                    n_etiquetas++;
                                                    strcpy(aux_array,aux_case);
                                                    strcat(aux_array,"!=");
                                                    strcat(aux_array, $3.sval);
                                                    insertar_instruccion("", "if", aux_array, "");
                                                    insertar_instruccion("", "goto", aux_ci, "");
                                                    fprintf(yyout, "if %s goto %s\n", aux_array, aux_ci);
                                                            
                                                }
                                                else
                                                {
                                                    yyerror("Numero no valido");
                                                }
                                            } sentencias casos
            | /* %empty */ {
                            strcpy(aux_array,"default_");
                            strcat(aux_array, aux_ci);
                            insertar_instruccion("", "goto", aux_array, "");
                            fprintf(yyout, "goto %s\n", aux_ci);
                            }
            ;
            
/* K -> default : S | epsilon */
caso_predeterminado
            : DEFAULT DP {
                                    insertar_instruccion("", "label", aux_ci, "");
                                    fprintf(yyout, "\n%s:", aux_ci);
                                    
                                    sprintf(aux_etiquetas, "%d", n_etiquetas);
                                    strcpy(aux_ci,"L");
                                    strcat(aux_ci, aux_etiquetas);
                                    strcpy(aux_array,"default_");
                                    strcat(aux_array, aux_ci);
                                    insertar_instruccion("", "goto", aux_array, "");
                                    fprintf(yyout, "goto %s\n", aux_ci);                
                                    }sentencias
            | /* %empty */ {}
            ;
            
/* U -> id | M | id . id */
identificadores
            : ID {
                    if(buscar_simbolo($1,pila_ts.sp))
                    {
                        $$.tipo=obtener_tipo($1,pila_ts.sp);
                        strcpy($$.dir,$1);
                    }
                    else if(buscar_simbolo($1,0))
                    {
                        $$.tipo=obtener_tipo($1,0);
                        strcpy($$.dir,$1);
                    }
                    else
                    {
                        yyerror("El simbolo NO existe en este ambito");
                    }
                }
            | arreglos {
                        strcpy($$.dir,aux_id);
                        $$.tipo=$1.tipo;
                        }
            | ID PUNTO ID {
                                if(buscar_simbolo($1,pila_ts.sp))
                                {
                                    if(es_estructura(obtener_tipo($1,pila_ts.sp), pila_tt.sp))
                                    {
                                        strcpy($$.dir, $1);
                                        strcat($$.dir, ".");
                                        ambito_mas_uno();         //Toda variable de tipo string genera nuevos ambitos, buscar en el inmediato siguiente es lo adecuado
                                        if(buscar_simbolo($3,pila_ts.sp))
                                        {
                                            $$.tipo=obtener_tipo($3,pila_ts.sp);
                                            strcat($$.dir, $3);
                                        }
                                        else
                                        {
                                            yyerror("El simbolo NO pertenece a la estructura");
                                        }
                                        ambito_menos_uno();            //Dejamos las cosas como estaban
                                    }
                                    else
                                    {
                                        yyerror("No es de tipo estructura");
                                    }
                                }
                                else if(buscar_simbolo($1,0))
                                {
                                    if(es_estructura(obtener_tipo($1,0), 0))
                                    {
                                        strcpy($$.dir, $1);
                                        strcat($$.dir, ".");
                                        if(buscar_simbolo($3,1))
                                        {
                                            $$.tipo=obtener_tipo($3,1);
                                            strcat($$.dir, $3);
                                        }
                                        else
                                        {
                                            yyerror("El simbolo NO pertenece a la estructura");
                                        }
                                    }
                                    else
                                    {
                                        yyerror("No es de tipo estructura");
                                    }
                                }
                                else
                                {
                                    yyerror("El simbolo NO existe en este ambito");
                                }
                            }
            ;
            
/* M -> id [ E ] | M1 [ E ] */
arreglos
            : ID LCOR expresion RCOR {
                                    if(buscar_simbolo($1,pila_ts.sp))
                                    {
                                        if(es_arreglo(obtener_tipo($1,pila_ts.sp), pila_tt.sp))
                                        {
                                            if($3.tipo==2 & atoi($3.dir)>-1 && atoi($3.dir)<obtener_dimension(obtener_tipo($1,pila_ts.sp), pila_tt.sp))
                                            {
                                                $$.tipo=obtener_tipo_base(obtener_tipo($1,pila_ts.sp), pila_tt.sp);
                                                sprintf($$.dir,"%d", obtener_dimension($$.tipo, pila_tt.sp));
                                                aux_ptr_tt=obtener_tt($1, pila_ts.sp);
                                                strcpy(aux_id, $1);
                                                strcat(aux_id, "[");
                                                strcat(aux_id, $3.ci);
                                                strcat(aux_id, "]");
                                                /* Generar etiqueta para arreglo*/
                                            }
                                            else
                                            {
                                                yyerror("Indice no valido");
                                            }
                                        }
                                        else
                                        {
                                            yyerror("No es una variable de tipo array");
                                        }
                                    }
                                    else if(buscar_simbolo($1,0))
                                    {
                                        if(es_arreglo(obtener_tipo($1,0), 0))
                                        {
                                            if($3.tipo==2 & atoi($3.dir)>-1 && atoi($3.dir)<obtener_dimension(obtener_tipo($1,0), 0))
                                            {
                                                $$.tipo=obtener_tipo_base(obtener_tipo($1,0), 0);
                                                sprintf($$.dir,"%d", obtener_dimension($$.tipo, 0));
                                                aux_ptr_tt=obtener_tt($1, 0);
                                                strcpy(aux_id, $1);
                                                strcat(aux_id, "[");
                                                strcat(aux_id, $3.ci);
                                                strcat(aux_id, "]");
                                                /* Generar etiqueta para arreglo */
                                            }
                                            else
                                            {
                                                yyerror("Indice no valido");
                                            }
                                        }
                                        else
                                        {
                                            yyerror("No es una variable de tipo array");
                                        }
                                    }
                                    else
                                    {
                                        yyerror("El simbolo NO existe en este ambito");
                                    }
                                }
            | arreglos LCOR expresion RCOR {
                                            if(es_arreglo($1.tipo, aux_ptr_tt))
                                            {
                                                if($3.tipo==2 & atoi($3.dir)>-1 && atoi($3.dir)<obtener_dimension($1.tipo, aux_ptr_tt))
                                                {
                                                    $$.tipo=obtener_tipo_base($1.tipo, aux_ptr_tt);
                                                    sprintf($$.dir,"%d", obtener_dimension($$.tipo, aux_ptr_tt));
                                                    strcat(aux_id, "[");
                                                    strcat(aux_id, $3.ci);
                                                    strcat(aux_id, "]");
                                                }
                                                else
                                                {
                                                    yyerror("Indice no valido");
                                                }
                                            }
                                            else
                                            {
                                                yyerror("No es una variable de tipo array");
                                            }
                                        }
            ;

/* E -> E1 + E2 | E1 - E2 | E1 * E2 | E1 / E2 | E1 % E2| U | cadena | numero | caracter | id ( H ) */
expresion
            : expresion MAS expresion {
                                        expresion_tipo(&$$.tipo, $$.dir, $$.ci, $1.tipo, $1.dir, $3.tipo, $3.dir, 0);
                                        }
            | expresion MEN expresion {
                                        expresion_tipo(&$$.tipo, $$.dir, $$.ci, $1.tipo, $1.dir, $3.tipo, $3.dir, 1);
                                        }
            | expresion MUL expresion {
                                        expresion_tipo(&$$.tipo, $$.dir, $$.ci, $1.tipo, $1.dir, $3.tipo, $3.dir, 2);
                                        }
            | expresion DIV expresion {
                                        expresion_tipo(&$$.tipo, $$.dir, $$.ci, $1.tipo, $1.dir, $3.tipo, $3.dir, 3);
                                        }
            | expresion MOD expresion {
                                        expresion_tipo(&$$.tipo, $$.dir, $$.ci, $1.tipo, $1.dir, $3.tipo, $3.dir, 4);
                                        }
            | identificadores {
                                $$.tipo=$1.tipo;
                                strcpy($$.dir, $1.dir);
                                strcpy($$.ci, $$.dir);
                            }
            | CADENA {
                                        $$.tipo=-2; 
                                        strcpy($$.dir, $1);
                                        strcpy($$.ci, $$.dir);
                    }             //La cadena será representada por el indice -2
            | NUMERO {
                    $$.tipo=$1.tipo;
                    strcpy($$.dir, $1.sval);
                    strcpy($$.ci, $$.dir);
                    }
            | CARACTER {
                    $$.tipo=1;
                    strcpy($$.dir, $1);
                    strcpy($$.ci, $$.dir);
                    }
            | ID {
                    if(buscar_simbolo($1, 0)) 
                    {
                        if(es_funcion($1, 0))
                        {
                            strcpy(aux_array,$1);
                            /* Generar la etiqueta correspondiente */
                        }
                        else
                        {
                            yyerror("El identificador no corresponde a una funcion");
                        }
                    }
                    else
                    {
                        yyerror("Funcion no declarada");
                    }
                }
                LPAR {countA=0;} lista_paso_de_parametros RPAR {
                                                                if(countA!=obtener_num_argumentos($1, 0))
                                                                {
                                                                    yyerror("El numero de elementos no concide con el previamente declarado");
                                                                }
                                                                else
                                                                {
                                                                    insertar_instruccion("", "call", $1, countA);
                                                                    fprintf(yyout, "call %s, %d\n", $1, countA);
                                                                }
                                                            }
            ;
            
/* H -> H1 , E |  E */
lista_paso_de_parametros
            : lista_paso_de_parametros COMA expresion {
                                                        if(es_arreglo(obtener_argumentos(aux_array, 0, countA), obtener_tt(aux_array, 0)))
                                                        {
                                                            if(es_arreglo($3.tipo, pila_tt.sp))
                                                            {
                                                                /*Si ambos tienen la misma densidad de dimensión esta bien, sino me pongo de payaso*/
                                                                if(obtener_dimension(obtener_argumentos(aux_array, 0, countA), obtener_tt(aux_array, 0))==obtener_numero_dim($3.tipo, pila_tt.sp))
                                                                {
                                                                    /* Generar etiqueta correspondiente */
                                                                    insertar_instruccion("", "param", $3.ci, "");
                                                                    fprintf(yyout, "param %s\n", $3.ci);
                                                    
                                                                }
                                                                else
                                                                {
                                                                    yyerror("Las dimensiones del arreglo no corresponden a las declaradas previamente");
                                                                }
                                                            }
                                                            else
                                                            {
                                                                yyerror("Se esperaba un arreglo como argumento");
                                                            }
                                                        }
                                                        else
                                                        {
                                                            if($3.tipo!=obtener_argumentos(aux_array, 0, countA))
                                                            {
                                                                yyerror("El tipo de variable no coincide con la declarada previamente");
                                                            }
                                                            else
                                                            {
                                                                insertar_instruccion("", "param", $3.ci, "");
                                                                fprintf(yyout, "param %s\n", $3.ci);
                                                            }
                                                        }
                                                        countA++;
                                                    }
            | expresion {
                        if(es_arreglo(obtener_argumentos(aux_array, 0, countA), obtener_tt(aux_array, 0)))
                        {
                            if(es_arreglo($1.tipo, pila_tt.sp))
                            {
                                if(obtener_dimension(obtener_argumentos(aux_array, 0, countA), obtener_tt(aux_array, 0))==obtener_numero_dim($1.tipo, pila_tt.sp))
                                {
                                    /* Generar etiqueta correspondiente */
                                    insertar_instruccion("", "param", $1.ci, "");
                                    fprintf(yyout, "param %s\n", $1.ci);
                                }
                                else
                                {
                                    yyerror("Las dimensiones del arreglo no corresponden a las declaradas previamente");
                                }
                            }
                            else
                            {
                                yyerror("Se esperaba un arreglo como argumento");
                            }
                        }
                        else
                        {
                            if($1.tipo!=obtener_argumentos(aux_array, 0, countA))
                            {
                                yyerror("El tipo de variable no coincide con la declarada previamente");
                            }
                            else
                            {
                                insertar_instruccion("", "param", $1.ci, "");
                                fprintf(yyout, "param %s\n", $1.ci);
                            }
                        }
                        countA++;
                    }
            ;
            
/* B -> B1 || B2 | B1 && B2 | !B1 | ( B1 ) | E1 R E2 | true | false */
expresion_logica
            : expresion_logica OP_OR expresion_logica {
                                                        if($1.val || $3.val)
                                                        {
                                                            $$.val=1;
                                                        }
                                                        else
                                                        {
                                                            $$.val=0;
                                                        }
                                                        sprintf(num, "%d", temporales);
                                                        strcpy(aux_ci,"t");
                                                        strcat(aux_ci, num);
                                                        temporales++;
                                                        strcpy($$.ci, aux_ci);
                                                        insertar_instruccion(aux_ci, "||", $1.ci, $3.ci);
                                                        fprintf(yyout, "%s = %s || %s\n", aux_ci, $1.ci, $3.ci);
                                                    }
            | expresion_logica OP_AND expresion_logica {
                                                        if($1.val && $3.val)
                                                        {
                                                            $$.val=1;
                                                        }
                                                        else
                                                        {
                                                            $$.val=0;
                                                        }
                                                        sprintf(num, "%d", temporales);
                                                        strcpy(aux_ci,"t");
                                                        strcat(aux_ci, num);
                                                        temporales++;
                                                        strcpy($$.ci, aux_ci);
                                                        insertar_instruccion(aux_ci, "&&", $1.ci, $3.ci);
                                                        fprintf(yyout, "%s = %s && %s\n", aux_ci, $1.ci, $3.ci);
                                                    }
            | OP_NOT expresion_logica {
                                        if($2.val)
                                        {
                                            $$.val=0;
                                        }
                                        else
                                        {
                                            $$.val=1;
                                        }
                                        sprintf(num, "%d", temporales);
                                        strcpy(aux_ci,"t");
                                        strcat(aux_ci, num);
                                        temporales++;
                                        strcpy($$.ci, aux_ci);
                                        insertar_instruccion(aux_ci, "!", $2.ci, "");
                                        fprintf(yyout, "%s = ! %s\n", aux_ci, $2.ci);
                                    }
            | LPAR expresion_logica RPAR {
                                            $$.val=$2.val;
                                            strcpy($$.ci, $2.ci);
                                        }
            | expresion operadores_relacionales expresion {
                                                            realizar_bool(&$$.val, $$.ci, $1.dir, $1.tipo, $3.dir, $3.tipo, $2);
                                                            }
            | TRUE {
                    $$.val=1;
                    strcpy($$.ci, "1");
                    }
            | FALSE {
                    $$.val=0;
                    strcpy($$.ci, "0");
                    }
            ;
            
/* R -> < | > | >= | <= | != | == */
operadores_relacionales
            : LT_OP {$$=0;}
            | GT_OP {$$=1;} 
            | GE_OP {$$=2;}
            | LE_OP {$$=3;}
            | NE_OP {$$=4;}
            | EQ_OP {$$=5;}
            ;
%%

void yyerror(char* s)
{
    printf("\n%s\nError en línea %d con %s\n", s, yylineno, yytext);
}

void nuevo_ambito(void)
{
    dirPila.pos=dir;
    dir=0;
    sp=pila_ts.sp;
    crear_tabla_simbolos();
    crear_tabla_tipos();
}

void imprimir_tablas(char* s)
{
    imprimir_tabla_simbolos(pila_ts.sp, s);
    imprimir_tabla_tipos(pila_tt.sp);
}

void previo_ambito(void)
{
    pila_tt.sp=sp;
    sp=pila_ts.sp;
    pila_ts.sp=pila_tt.sp;
}

void ambito_mas_uno(void)
{   
    pila_tt.sp++;
    pila_ts.sp++;
}

void ambito_menos_uno(void)
{   
    pila_tt.sp--;
    pila_ts.sp--;
}

void insertar_s(char *id, int tipo, int tipo_variable, int dim, int num_args, int tipo_args[])
{
    //La variable dir depende del ambito actual, es una variable global
    strcpy(s.id,id);
    s.tipo=tipo;
    s.tipo_variable=tipo_variable;
    s.dir=dir;
    dir+=dim;
    s.num_args=num_args;
    for(int i=0;i<num_args;i++)
        s.tipo_args[i]=tipo_args[i];
    if(s.tipo>4)
        s.ptr_tt=pila_tt.sp;                   //Ligada siempre a la tabla tipos actual si es array o struct, en caso de struct considerar el nuevo ambito(+1)
    insertar_simbolo(s,pila_ts.sp);
    if(s.tipo_variable==1)
        s.ptr_tt=pila_tt.sp+1;                   //Ligada siempre a la tabla de tipos creada para el ambito de la funcion
}

void expresion_tipo(int* t0, char* e0, char* ci, int t1, char* e1, int t2, char* e2, int op)
{
    sprintf(num, "%d", temporales);
    strcpy(ci,"t");
    strcat(ci, num);
    temporales++;
    
    if(t1==t2)
    {
        *t0=t1;
        switch(op)
        {
            case 0:
                insertar_instruccion(ci, "+", e1, e2);
                fprintf(yyout, "%s = %s + %s\n", ci, e1, e2);
                if(*t0==2)
                    sprintf(e0, "%d", (atoi(e1)+atoi(e2))); 
                else if(*t0==3 || *t0==4)
                    sprintf(e0, "%f", (atof(e1)+atof(e2)));
                else 
                    yyerror("Operacion no valida para los tipos de variables utilizadas");
                break;
            case 1:
                insertar_instruccion(ci, "-", e1, e2);
                fprintf(yyout, "%s = %s - %s\n", ci, e1, e2);
                if(*t0==2)
                    sprintf(e0, "%d", (atoi(e1)-atoi(e2))); 
                else if(*t0==3 || *t0==4)
                    sprintf(e0, "%f", (atof(e1)-atof(e2)));
                else 
                    yyerror("Operacion no valida para los tipos de variables utilizadas");
                break;
            case 2:
                insertar_instruccion(ci, "*", e1, e2);
                fprintf(yyout, "%s = %s * %s\n", ci, e1, e2);
                if(*t0==2)
                    sprintf(e0, "%d", (atoi(e1)*atoi(e2))); 
                else if(*t0==3 || *t0==4)
                    sprintf(e0, "%f", (atof(e1)*atof(e2)));
                else 
                    yyerror("Operacion no valida para los tipos de variables utilizadas");
                break;
            case 3:
                insertar_instruccion(ci, "/", e1, e2);
                fprintf(yyout, "%s = %s / %s\n", ci, e1, e2);
                if(*t0==2)
                    sprintf(e0, "%d", (atoi(e1)/atoi(e2))); 
                else if(*t0==3 || *t0==4)
                    sprintf(e0, "%f", (atof(e1)/atof(e2)));
                else 
                    yyerror("Operacion no valida para los tipos de variables utilizadas");
                break;
            case 4:
                insertar_instruccion(ci, "%", e1, e2);
                fprintf(yyout, "%s = %s %% %s\n", ci, e1, e2);
                if(*t0==2)
                    sprintf(e0, "%d", (atoi(e1)%atoi(e2))); 
                else 
                    yyerror("Operacion no valida para los tipos de variables utilizadas");
                break;
        }
        if(t1==3)
            strcat(e0,"f");
    }
    else
    {
        if(t1==3 && t2==4)
        {
            *t0=t2;
            //e1[strlen(e1)-1]='0';
            switch(op)
            {
                case 0:
                    insertar_instruccion(ci, "+", e1, e2);
                    fprintf(yyout, "%s = %s + %s\n", ci, e1, e2);
                    sprintf(e0, "%f", (atof(e1)+atof(e2)));
                    break;
                case 1:
                    insertar_instruccion(ci, "-", e1, e2);
                    fprintf(yyout, "%s = %s - %s\n", ci, e1, e2);
                    sprintf(e0, "%f", (atof(e1)-atof(e2)));
                    break;
                case 2:
                    insertar_instruccion(ci, "*", e1, e2);
                    fprintf(yyout, "%s = %s * %s\n", ci, e1, e2);
                    sprintf(e0, "%f", (atof(e1)*atof(e2)));
                    break;
                case 3:
                    insertar_instruccion(ci, "/", e1, e2);
                    fprintf(yyout, "%s = %s / %s\n", ci, e1, e2);
                    sprintf(e0, "%f", (atof(e1)/atof(e2)));
                    break;
                case 4:
                    yyerror("Operacion no valida para los tipos de variables utilizadas");
                    break;
            }
        }
        else if (t1==4 && t2==3)
        {
            *t0=t1;
            //e2[strlen(e2)-1]='0';
            switch(op)
            {
                case 0:
                    insertar_instruccion(ci, "+", e1, e2);
                    fprintf(yyout, "%s = %s + %s\n", ci, e1, e2);
                    sprintf(e0, "%f", (atof(e1)+atof(e2)));
                    break;
                case 1:
                    insertar_instruccion(ci, "-", e1, e2);
                    fprintf(yyout, "%s = %s - %s\n", ci, e1, e2);
                    sprintf(e0, "%f", (atof(e1)-atof(e2)));
                    break;
                case 2:
                    insertar_instruccion(ci, "*", e1, e2);
                    fprintf(yyout, "%s = %s * %s\n", ci, e1, e2);
                    sprintf(e0, "%f", (atof(e1)*atof(e2)));
                    break;
                case 3:
                    insertar_instruccion(ci, "/", e1, e2);
                    fprintf(yyout, "%s = %s / %s\n", ci, e1, e2);
                    sprintf(e0, "%f", (atof(e1)/atof(e2)));
                    break;
                case 4:
                    yyerror("Operacion no valida para los tipos de variables utilizadas");
                    break;
            }
        }
        else
        {
            yyerror("Error Semántico. Tipos de datos incompatibles.");
        }
    }
}

void realizar_bool(int* op0, char* ci, char* op1, int t1, char* op2, int t2, int operador)
{
    sprintf(num, "%d", temporales);
    strcpy(ci,"t");
    strcat(ci, num);
    temporales++;
    
    if(t1==2 || t1==3 || t1==4 || t2==2 || t2==3 || t2==4)
    {
        switch(operador)
        {
            case 0:
                if(atof(op1) < atof(op2))
                {
                    *op0=1;
                }
                else
                {
                    *op0=0;
                }
                insertar_instruccion(ci, "<", op1, op2);
                fprintf(yyout, "%s = %s < %s\n", ci, op1, op2);
                break;
            case 1:
                if(atof(op1) > atof(op2))
                    *op0=1;
                else
                    *op0=0;
                insertar_instruccion(ci, ">", op1, op2);
                fprintf(yyout, "%s = %s > %s\n", ci, op1, op2);
                break;
            case 2:
                if(atof(op1) >= atof(op2))
                    *op0=1;
                else
                    *op0=0;
                insertar_instruccion(ci, ">=", op1, op2);
                fprintf(yyout, "%s = %s >= %s\n", ci, op1, op2);
                break;
            case 3:
                if(atof(op1) <= atof(op2))
                    *op0=1;
                else
                    *op0=0;
                insertar_instruccion(ci, "<", op1, op2);
                fprintf(yyout, "%s = %s < %s\n", ci, op1, op2);
                break;
            case 4:
                if(atof(op1) != atof(op2))
                    *op0=1;
                else
                    *op0=0;
                insertar_instruccion(ci, "!=", op1, op2);
                fprintf(yyout, "%s = %s != %s\n", ci, op1, op2);
                break;
            case 5:
                if(atof(op1) == atof(op2))
                    *op0=1;
                else
                    *op0=0;
                insertar_instruccion(ci, "==", op1, op2);
                fprintf(yyout, "%s = %s == %s\n", ci, op1, op2);
                break;
        }
    }
    else
    {
        yyerror("Expresion no valida");
    }
}

int main(int argc, char** argv){
    FILE* file;
    if(argc >1){
        file = fopen(argv[1], "r");
        if(file==NULL){
            printf("no existe el fichero %s\n", argv[1]);
            exit(1);
        }
        char nombre[50];
        strcpy(nombre, argv[1]);
        strcat(nombre, ".ci");
        yyout = fopen(nombre, "w");
        yyin = file;
        yyparse();
        fclose(yyin);
        fclose(yyout);
    }
    
    return 1;
}
