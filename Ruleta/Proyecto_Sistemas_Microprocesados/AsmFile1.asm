.dseg
	BCD:     .byte 4
	Digito:     .byte 4

.cseg
.org 0x00
	ldi r16,0b00000000
	out ddrb,r16
	out ddrd,r16
	ldi r16,0b01111111
	out ddra,r16
	out ddrc,r16
	ldi r16,0b11111111
	out porta,r16
	out portb,r16
	out portd,r16
	out portc,r16
	ldi r16,high(ramend)
	out sph,r16
	ldi r16,low(ramend)
	out spl,r16
	rjmp Inicio

Inicio:
	rcall multiplicacion
	rcall bin_bcd
	rcall bcd_7seg
	rcall barrido
	jmp inicio

multiplicacion:
	ldi r16,123
	ldi r20,11
	mul r16,r20
	mov r18,r0
	mov r19,r1
	ret

bin_bcd:
	clr r17
	ldi r16,0b11101000
	ldi r20,0b00000011
	rjmp	miles

miles:
	sub r18,r16
	sbc r19,r20
	brcs centenas
	inc r17 
	rjmp miles

centenas:
	sts BCD,r17
	clr r17
	ldi r16,0b11101000
	ldi r20,0b00000011
	add r18,r16
	adc r19,r20
	rjmp centenas1

centenas1:
	subi r18,100
	clr r16
	sbc r19,r16
	brcs decenas
	inc r17
	rjmp centenas1

decenas:
	sts BCD+1,r17
	clr r17
	subi r18,-100
	subi r19,-0b00000001
	rjmp decenas1

decenas1:
	subi r18,10
	clr r16
	sbc r19,r16
	brcs unidades
	inc r17
	rjmp decenas1

unidades:
	sts BCD+2,r17
	subi r18,-10
	subi r19,-0b00000001
	sts BCD+3,r18
	ret

bcd_7seg:
	ldi xh,high(BCD)
	ldi xl,low(BCD)
	ldi yh,high(Digito)
	ldi yl,low(Digito)
	ldi r17,4
	rjmp	lazo_7seg
	
lazo_7seg:
	ldi zh,high(tabla7seg<<1)
	ldi zl,low(tabla7seg<<1)
	ld r16,x+
	add zl,r16
	clr r16
	adc zh,r16
	lpm r16,z
	st y+,r16
	dec r17
	brne lazo_7seg
	ret

barrido:
	ldi r16,0b11111111
	out portc,r16
	lds r16,Digito+3
	out porta,r16
	ldi r16,0b11111110
	out portc,r16
	call retardo
	ldi r16,0b11111111
	out portc,r16
	lds r16,Digito+2
	out porta,r16
	ldi r16,0b11111101
	out portc,r16
	call retardo 
	ldi r16,0b11111111
	out portc,r16
	lds r16,Digito+1
	out porta,r16
	ldi r16,0b11111011
	out portc,r16
	call retardo
	ldi r16,0b11111111
	out portc,r16
	lds r16,Digito
	out porta,r16
	ldi r16,0b11110111
	out portc,r16
	call retardo
	ldi r16,0b11111111
	out portc,r16
	ret

retardo:
	ldi r18,5
lazoret:
	dec r18
	brne lazoret
	ret

tabla7seg:
	.db 0b01000000, 0b01111001, 0b00100100, 0b00110000, 0b00011001, 0b00010010, 0b00000010, 0b01111000, 0b00000000, 0b00010000