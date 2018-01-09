#include<stdio.h>
#include<stdlib.h>
#include<string.h>

int definirTipo(char * cadena){
	//regresa 
		// 0 -> entero
		// 1 -> flotante
		// 2 -> cadena
	int i;
	int punto=0; //punto es falso
	int entero=0;
	int cad=0;
	for(i=0;i<strlen(cadena);i++){
		// printf("%c\n",cadena[i] );
		if(cadena[i]<58 &&  cadena[i]>47 && cad==0)
			entero=1;
		else if(cadena[i]=='.' && entero==1)
			punto=1;
		else
			cad=1;
	}
	if(punto==1)
		return 1;
	else if (entero==1)
		return 0;
	else
		return 2;
}

int main(){
	char cadena[]="20";
	char cadena1[]="12";
	int aux1,aux2;
	printf("%f\n",1&4 );
	printf("%s es de largo %d\n",cadena,strlen(cadena) );
	printf("%d\n",definirTipo(cadena) );
	aux1=atoi(cadena);
	aux2=atoi(cadena1);
	printf("%d\n",aux1%aux2);
}