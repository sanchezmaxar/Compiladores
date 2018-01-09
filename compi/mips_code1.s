.data
string0	.asciiz "Soy una cadena"
string1	.asciiz 'c'
string2	.asciiz "Estoy en un main"
string3	.asciiz "hola"
string4	.asciiz "adios"
string5	.asciiz "default"
global: .word 0
.text
mi_funcion:
	li $v0, 1
	li $a0, 1000000
	syscall
	li $v0, 4
	la $a0, string0
	syscall
	li $v0, 4
	la $a0, string1
	syscall
	li $v1,0
	jr $ra
otra_funcion:
	li g.a,1
	move g.a,1
	li a.d,2
	move a.d,2
	li t0,1
	MFHI t0
	move $v1,
	jr $ra
pues_otra:
	li t1,0
	li t2,1
	move car[0][0],car[t1][t2]
	li t3,0
	li t4,1
	move car[t3][t4],car[0][0]
	li t5,0
	li t6,1
	li t7,0
	li t8,1
	move car[t5][t6],car[t7][t8]
	li t9,0
	li t10,1
	move $v1,
	jr $ra
prueba_bool:
	li t11,1
	#No se que hacer con un if :(
	goto L0
	goto L1
L0:
	li d,10
	move d,10
	li t12,1
	andi t13,t12,1
	#No se que hacer con un if :(
	goto L1
	goto L2
L1:
	move $v1,
	jr $ra
L2:
L3:
main:
	li a,1
	move a,1
	li b,2.0000
	li t14,4.0000
	move c,t14
	move j[0][1],'a'
	li t15,2.0000
	li $v0, 4
	la $a0, string2
	syscall
L3:
	#No se que hacer con un if :(
	goto L4
	li $v0, 4
	la $a0, string3
	syscall
L4:
	#No se que hacer con un if :(
	goto L5
	li $v0, 4
	la $a0, string4
	syscall
	goto default_L5
L5:
	goto default_L6
	li $v0, 4
	la $a0, string5
	syscall
	li $v1,0
	jr $ra
