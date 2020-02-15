; Created: 10/08/2017 17:58:15
; Author : Christian Arroyo
;

//Segmento de definicion de variables
.def Aux_1	   = r16
.def Aux_2     = r17
.def Aux_3     = r18
.def Aux_4     = r19
.def Aux_5     = r20
.def Aux_6     = r21
.def Aux_7     = r22
.def Aux_8     = r23
.def Apuesta   = r24
.def Contador  = r25
	
//Segmento de deficion en RAM		
.dseg
.org 0x100
BCD:		.BYTE 4
Digito:		.BYTE 4

//Segmento de codigo
.cseg
.org 0x00
rjmp  Programacion
.org 0x02
rjmp  Interrupcion_0
.org 0x04
rjmp  Interrupcion_1

//Inicio de la Programacion
Programacion:
	//Inicialización del stack
	ldi 	Aux_1, high(ramend)
	out 	sph, Aux_1
	ldi 	Aux_1, low(ramend)
	out 	spl, Aux_1
	//Programacion de las interrupciones externas 
	ldi     Aux_1, 0b00101010
	sts     eicra, Aux_1
	ldi     Aux_1, 0b0000_0011
	out     eimsk, Aux_1
	out     eifr, Aux_1
	//Configuracion de puertos D y B
	ldi     Aux_1, 0b1100_0011
	out		DDRD, Aux_1
	ldi		Aux_1, 0b0011_1100
	out     PORTD, Aux_1
	ldi		Aux_1, 0b1111_0000
	out		DDRB, Aux_1
	ldi		Aux_1, 0b0000_1111
	out		PORTB, Aux_1
	//Configuracion de puertos A y C
	ldi		Aux_1, 0b1111_1111
	out		DDRA, Aux_1
	out		DDRC, Aux_1
	//Apago todas las salidas
	ldi		Aux_1, 0b1111_1111
	out		PORTC, Aux_1
	out		PORTA, Aux_1
	rjmp	Habilitar

//Habilitación global de interrupciones 
Habilitar:
	sei
	clr		Aux_1
	clr		Aux_2
	clr		Aux_3
	clr		Aux_4
	clr		Aux_5
	inc		Aux_6
	clr		Aux_7
	clr		Aux_8
	clr		Apuesta
	clr		Contador
	rjmp	Inicio

//Inicio de los display
Inicio:
	rcall	Color_Seleccionado
	mov		Aux_3, Apuesta
	rcall	Binario_a_BCD
	rcall	BCD_a_7_Segmentos
	rcall	Barrido
	rjmp	Inicio

Color_Seleccionado:
	sbis	PINB, 0
	rjmp	Apuesta_Verde
	sbis	PINB, 1
	rjmp	Apuesta_Azul
	sbis	PINB, 2
	rjmp	Apuesta_Amarillo
	sbis	PINB, 3
	rjmp	Apuesta_Rojo
	sbis	PIND, 4
	rjmp	Sube_Apuesta
	sbis	PIND, 5
	rjmp	Baja_Apuesta
	ret

Apuesta_Verde:
	sbi		PORTB, 4
	cbi		PORTB, 5
	cbi		PORTB, 6
	cbi		PORTB, 7
	rjmp	Color_Seleccionado

Apuesta_Azul:
	sbi		PORTB, 5
	cbi		PORTB, 4
	cbi		PORTB, 6
	cbi		PORTB, 7
	rjmp	Color_Seleccionado

Apuesta_Amarillo:
	sbi		PORTB, 6
	cbi		PORTB, 4
	cbi		PORTB, 5
	cbi		PORTB, 7
	rjmp	Color_Seleccionado

Apuesta_Rojo:
	sbi		PORTB, 7
	cbi		PORTB, 4
	cbi		PORTB, 5
	cbi		PORTB, 6
	rjmp	Color_Seleccionado

Sube_Apuesta:
	inc		Apuesta
	rcall	Retardo_Apuesta
	rjmp	Color_Seleccionado

Baja_Apuesta:
	dec		Apuesta
	cpi		Apuesta, 0
	brlt	No_Menor_Cero
	rcall	Retardo_Apuesta
	rjmp	Color_Seleccionado

No_Menor_Cero:
	ldi		Apuesta, 0
	rcall	Retardo_Apuesta
	rjmp	Color_Seleccionado


Binario_a_BCD:
	clr		Aux_2
	ldi		Aux_1, 0b11101000
	ldi		Aux_5, 0b00000011
	rjmp	Miles

Miles:
	sub		Aux_3, Aux_1
	sbc		Aux_4, Aux_5
	brcs	Centenas
	inc		Aux_2 
	rjmp	Miles

Centenas:
	sts		BCD, Aux_2
	clr		Aux_2
	ldi		Aux_1, 0b11101000
	ldi		Aux_5, 0b00000011
	add		Aux_3, Aux_1
	adc		Aux_4, Aux_5
	rjmp	Centenas_1

Centenas_1:
	subi	Aux_3, 100
	clr		Aux_1
	sbc		Aux_4, Aux_1
	brcs	Decenas
	inc		Aux_2
	rjmp	Centenas_1

Decenas:
	sts		BCD+1, Aux_2
	clr		Aux_2
	subi	Aux_3, -100
	subi	Aux_4, -0b00000001
	rjmp	Decenas_1

Decenas_1:
	subi	Aux_3, 10
	clr		Aux_1
	sbc		Aux_4, Aux_1
	brcs	Unidades
	inc		Aux_2
	rjmp	Decenas_1

Unidades:
	sts		BCD+2, Aux_2
	subi	Aux_3, -10
	subi	Aux_4, -0b00000001
	sts		BCD+3, Aux_3
	ret

BCD_a_7_Segmentos:
	ldi		xh, high(BCD)
	ldi		xl, low(BCD)
	ldi		yh, high(Digito)
	ldi		yl, low(Digito)
	ldi		Aux_2, 4
	rjmp	Lazo_7_Segmentos
	
Lazo_7_Segmentos:
	ldi		zh, high(Tabla_BCD_7<<1)
	ldi		zl, low(Tabla_BCD_7<<1)
	ld		Aux_1, x+
	add		zl, Aux_1
	clr		Aux_1
	adc		zh, Aux_1
	lpm		Aux_1, z
	st		y+, Aux_1
	dec		Aux_2
	brne	Lazo_7_Segmentos
	ret

Barrido:
	ldi		Aux_1, 0b11111111
	out		PORTC, Aux_1
	lds		Aux_1, Digito+3
	out		PORTA, Aux_1
	ldi		Aux_1, 0b11111110
	out		PORTC, Aux_1
	call	Retardo
	ldi		Aux_1, 0b11111111
	out		PORTC, Aux_1
	lds		Aux_1, Digito+2
	out		PORTA, Aux_1
	ldi		Aux_1, 0b11111101
	out		PORTC, Aux_1
	call	Retardo 
	ldi		Aux_1, 0b11111111
	out		PORTC, Aux_1
	lds		Aux_1, Digito+1
	out		PORTA, Aux_1
	ldi		Aux_1, 0b11111011
	out		PORTC, Aux_1
	call	Retardo
	ldi		Aux_1, 0b11111111
	out		PORTC, Aux_1
	lds		Aux_1, Digito
	out		PORTA, Aux_1
	ldi		Aux_1, 0b11110111
	out		PORTC, Aux_1
	call	Retardo
	ldi		Aux_1, 0b11111111
	out		PORTC, Aux_1
	ret

//Subrutina de Retardo Apuesta
Retardo_Apuesta:   
	ldi		r29, 2
    ldi		r30, 69
    ldi		r31, 170
	Lazo_Retardo_Apuesta: 
		dec		r31
		brne	Lazo_Retardo_Apuesta
		dec		r30
		brne	Lazo_Retardo_Apuesta
		dec		r29
		brne	Lazo_Retardo_Apuesta
		ret

//Subrutina de Retardo Barrido
Retardo:   
	ldi		Contador, 255
	Retardo_Barrido_0:
		dec		Contador
		brne	Retardo_Barrido_0
		ret

//Seccion de Interrupciones externas
Interrupcion_0:
	clr		Aux_1
	clr		Aux_2
	clr		Aux_3
	ldi		Aux_1, 4
	cpi		Aux_6, 1
	breq	Saltos_Uno
	cpi		Aux_6, 2
	breq	Saltos_Dos
	cpi		Aux_6, 3
	breq	Saltos_Tres
	cpi		Aux_6, 4
	breq	Saltos_Cuatro
	cpi		Aux_6, 5
	breq	Saltos_Cinco
	rjmp	Coparador
	Coparador:
		cp		Aux_5, Aux_7
		breq	Parar
		cp		Aux_2, Aux_1
		brlt	Registro_Menor
		rjmp	Interrupcion_0
	Registro_Menor:
		cpi		Aux_2, 0
		breq	Primer_led
		cpi		Aux_2, 1
		breq	Segundo_Led
		cpi		Aux_2, 2
		breq	Tercer_Led
		cpi		Aux_2, 3
		breq	Cuarto_Led
		rjmp	Coparador
	Primer_Led:
		inc		Aux_2
		inc		Aux_5
		ldi		Aux_3, 0b0011_1101
		out		PORTD, Aux_3
		ldi		Aux_3, 0b0000_0010
		out		PORTA, Aux_3
		ldi		Aux_3, 0b0000_0111
		out		PORTC, Aux_3
		rcall	Retardo_Apuesta
		rjmp	Coparador
	Segundo_Led:
		inc		Aux_2
		inc		Aux_5
		ldi		Aux_3, 0b0011_1110
		out		PORTD, Aux_3
		ldi		Aux_3, 0b0100_0000
		out		PORTA, Aux_3
		ldi		Aux_3, 0b0000_1011
		out		PORTC, Aux_3
		rcall	Retardo_Apuesta
		rjmp	Coparador
	Tercer_Led:
		inc		Aux_2
		inc		Aux_5
		ldi		Aux_3, 0b0111_1100
		out		PORTD, Aux_3
		ldi		Aux_3, 0b0000_1000
		out		PORTA, Aux_3
		ldi		Aux_3, 0b0000_1101
		out		PORTC, Aux_3
		rcall	Retardo_Apuesta
		rjmp	Coparador
	Cuarto_Led:
		inc		Aux_2
		inc		Aux_5
		ldi		Aux_3, 0b1011_1100
		out		PORTD, Aux_3
		ldi		Aux_3, 0b0100_0111
		out		PORTA, Aux_3
		ldi		Aux_3, 0b0000_1110
		out		PORTC, Aux_3
		rcall	Retardo_Apuesta
		rjmp	Coparador
	Saltos_Uno:
		ldi		Aux_7, 23
		rjmp	Coparador
	Saltos_Dos:
		ldi		Aux_7, 20
		rjmp	Coparador
	Saltos_Tres:
		ldi		Aux_7, 26
		rjmp	Coparador
	Saltos_Cuatro:
		ldi		Aux_7, 25
		rjmp	Coparador
	Saltos_Cinco:
		ldi		Aux_7, 21
		ldi		Aux_6, 0
		rjmp	Coparador
	Parar:
		sbic	PIND, 0
		rjmp	Ganador_Verde
		sbic	PIND, 1
		rjmp	Ganador_Azul
		sbic	PIND, 6
		rjmp	Ganador_Amarillo
		sbic	PIND, 7
		rjmp	Ganador_Rojo
	Ganador_Verde:
		ldi		Aux_8, 10
		sbic	PINB, 4
		rjmp	Jugador_Gana
		rjmp	Jugador_Pierde
	Ganador_Azul:
		ldi		Aux_8, 20
		sbic	PINB, 5
		rjmp	Jugador_Gana
		rjmp	Jugador_Pierde
	Ganador_Amarillo:
		ldi		Aux_8, 50
		sbic	PINB, 6
		rjmp	Jugador_Gana
		rjmp	Jugador_Pierde
	Ganador_Rojo:
		ldi		Aux_8, 123
		sbic	PINB, 7
		rjmp	Jugador_Gana
		rjmp	Jugador_Pierde
	Jugador_Gana:
		mov		Aux_1, Aux_8
		mov		Aux_5, Apuesta
		mul		Aux_1, Aux_5
		mov		Aux_3, r0
		mov		Aux_4, r1
		rcall	Binario_a_BCD
		rcall	BCD_a_7_Segmentos
		rcall	Barrido
		rjmp	Salir
	Jugador_Pierde:
		ldi		Aux_1, 0
		ldi		Aux_5, 0
		mul		Aux_1, Aux_5
		mov		Aux_3, r0
		mov		Aux_4, r1
		rcall	Binario_a_BCD
		rcall	BCD_a_7_Segmentos
		rcall	Barrido
		ldi		Apuesta, 0
		mov		Aux_3, Apuesta
		reti
	Salir:
		sbis	PIND, 3
		reti
		rjmp	Seguir_Mostrando
	Seguir_Mostrando:
		mov		Aux_1, Aux_8
		mov		Aux_5, Apuesta
		mul		Aux_1, Aux_5
		mov		Aux_3, r0
		mov		Aux_4, r1
		rcall	Binario_a_BCD
		rcall	BCD_a_7_Segmentos
		rcall	Barrido
		rjmp	Salir

Interrupcion_1:
	rjmp	Programacion
	reti

Tabla_BCD_7:
	.db 0b01000000, 0b01111001, 0b00100100, 0b00110000, 0b00011001, 0b00010010, 0b00000010, 0b01111000, 0b00000000, 0b00010000