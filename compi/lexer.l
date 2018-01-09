%{
#include "y.tab.h"
#include "tabla_simbolos.h"
#include "tabla_tipos.h"
#include "codigo_intermedio.h"

void comentario(void);
%}

%option yylineno
%option noyywrap

id              [a-zA-Z_][a-zA-Z0-9_]*
entero          [0-9]+
flotante        [0-9]+("."[0-9]+)?([Ee][+-]?[0-9]+)?[fF]
doble           [0-9]+("."[0-9]+)?([Ee][+-]?[0-9]+)?
caracter        \'(\\.|[^\\'])\'
cadena          \"(\\.|[^\\"])*\"
espacio         [ \n\t]

%%
"/*"            { comentario(); }
void            {  yylval.line = yylineno; return(VOID); }
int             {  yylval.line = yylineno; return(INT); }
float           {  yylval.line = yylineno; return(FLOAT); }
double          {  yylval.line = yylineno; return(DOUBLE); }
char            {  yylval.line = yylineno; return(CHAR); }
struct          {  yylval.line = yylineno; return(STRUCT); }
func            {  yylval.line = yylineno; return(FUNC);}
if              {  yylval.line = yylineno; return(IF); }
else            {  yylval.line = yylineno; return(ELSE); }
while           {  yylval.line = yylineno; return(WHILE); }
do              {  yylval.line = yylineno; return(DO); }
for             {  yylval.line = yylineno; return(FOR); }
return          {  yylval.line = yylineno; return(RETURN); }	
switch          {  yylval.line = yylineno; return(SWITCH); }
break           {  yylval.line = yylineno; return(BREAK); }
print           {  yylval.line = yylineno; return(PRINT);}
case            {  yylval.line = yylineno; return(CASE);}
default         {  yylval.line = yylineno; return(DEFAULT);}
true			{  yylval.line = yylineno; return(TRUE); }
false			{  yylval.line = yylineno; return(FALSE); }
{id}            {  yylval.line = yylineno; strcpy(yylval.sval, yytext); return(ID); }
{entero}        {  yylval.line = yylineno; yylval.num.tipo = 2; strcpy(yylval.num.sval, yytext); yylval.num.ival = atoi(yytext); return(NUMERO); }
{doble}         {  yylval.line = yylineno; yylval.num.tipo = 4; strcpy(yylval.num.sval, yytext); yylval.num.dval = atof(yytext); return(NUMERO); }
{flotante}      {  yylval.line = yylineno; yylval.num.tipo = 3; strcpy(yylval.num.sval, yytext); yylval.num.dval = atof(yytext); return(NUMERO); }
{caracter}      {  yylval.line = yylineno; strcpy(yylval.sval, yytext); return(CARACTER); }
{cadena}        {  yylval.line = yylineno; strcpy(yylval.sval, yytext); return(CADENA); }
";"             {  yylval.line = yylineno; return(PYC); }
"{"             {  yylval.line = yylineno; return(LKEY); }
"}"             {  yylval.line = yylineno; return(RKEY); }
","             {  yylval.line = yylineno; return(COMA); }
"."             {  yylval.line = yylineno; return(PUNTO); }
"["             {  yylval.line = yylineno; return(LCOR); }
"]"             {  yylval.line = yylineno; return(RCOR); }
"("             {  yylval.line = yylineno; return(LPAR); }
")"             {  yylval.line = yylineno; return(RPAR); }
"="             {  yylval.line = yylineno; return(ASIG); }
":"             {  yylval.line = yylineno; return(DP); }
"-"             {  yylval.line = yylineno; return(MEN); }
"+"             {  yylval.line = yylineno; return(MAS); }
"*"             {  yylval.line = yylineno; return(MUL); }
"/"             {  yylval.line = yylineno; return(DIV); }
"%"             {  yylval.line = yylineno; return(MOD); }
"&&"            {  yylval.line = yylineno; return(OP_AND); }
"||"            {  yylval.line = yylineno; return(OP_OR); }
"!"             {  yylval.line = yylineno; return(OP_NOT); }
"<"             {  yylval.line = yylineno; return(LT_OP); }
">"             {  yylval.line = yylineno; return(GT_OP); }
"<="            {  yylval.line = yylineno; return(LE_OP); }
">="            {  yylval.line = yylineno; return(GE_OP); }
"=="            {  yylval.line = yylineno; return(EQ_OP); }
"!="            {  yylval.line = yylineno; return(NE_OP); }
{espacio}       {}
.               {printf("Error Lexico en la linea %d con %s\n", yylineno,yytext); }

%%

void comentario(void)
{
	char c, c1;

	c=input();
	while(1){
		c1=input();
		if(c=='*' && c1=='/')
            break;
		c=c1;
		if(c==EOF)
		{
            printf("Error en la linea %d. Falta cerrar comentario\n", yylineno);
            break;
        }
	}
}
