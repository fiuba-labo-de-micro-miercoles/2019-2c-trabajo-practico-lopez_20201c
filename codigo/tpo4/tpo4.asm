.include "m328pdef.inc"

.def conf = r16
.def count = r17
.def count1 = r18
.def count2 = r19
.def count3 = r20
.equ max_twinkle = 5
.equ int_led = 1
.equ main_led = 0
.equ led_port = PORTB

.macro INIT_SP
	ldi @0,low(RAMEND)
	out SPL,@0
	ldi @0,high(RAMEND)
	out SPH,@0
.endmacro

.macro SETUP_LED_PORT
	ldi @0,0x03
	out DDRB,@0
.endmacro

.macro SETUP_INTERRUPT
	ldi @0,0x03			; seteo las interrupciones sobre int0 como flanco ascendente
	sts EICRA,@0
	ldi @0,(1<<INT0)	; habilito las interrupciones en el pin INT0
	out EIMSK,@0
	sei
.endmacro

.cseg
.org 0x0000
	jmp main

.org INT0addr
	jmp	isr_int0

.org INT_VECTORS_SIZE
main:

// configuracion de SP
	INIT_SP conf

// configuro el puerto que maneja los leds
	SETUP_LED_PORT conf
	
// configuracion de interrupciones
	SETUP_INTERRUPT conf
	
	cbi led_port,int_led
	sbi led_port,main_led
	
here:
	nop
	nop
	nop
	rjmp here

// interrupciones
isr_int0:
	cbi led_port,main_led
	
	clr count

twinkle:
	inc count
	sbi led_port,int_led
	call delay
	cbi led_port,int_led	
	call delay
	cpi count,max_twinkle
	brlo twinkle

	sbi led_port,main_led
	reti

// subrutinas
delay:
	// inicializo los contadores
	clr count1	;  4 * 255
	clr count2	; (4 * 255 + 5) * 255
	clr	count3	; (4 * 255 + 5) * 255 + 5) * 32 * 1/f = 0,5s
loop:
	inc	count1
	cpi	count1,0xff
	brlo loop

	clr	count1
	inc	count2
	cpi	count2,0xff
	brlo loop

	clr	count2
	inc	count3
	cpi	count3,0x20
	brlo loop

	ret
