all:
	yacc -d -v parser.y
	lex lexer.l
	gcc lex.yy.c y.tab.c tabla_simbolos.c tabla_tipos.c codigo_intermedio.c -lfl -o ulises.o

clean:
	rm *.o
	rm y.tab.c lex.yy.c y.output y.tab.h
