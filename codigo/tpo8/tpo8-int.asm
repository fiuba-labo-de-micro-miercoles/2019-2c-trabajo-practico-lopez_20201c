.include "m328pdef.inc"

.dseg

.def conf = r16
.def read = r17
.def aux = r18
.def led = r19
.def write = r20
.equ led_port = portb

.macro init_sp
	ldi conf, low (RAMEND)
	out spl, conf
	ldi conf, high(RAMEND)
	out sph, conf
.endmacro


.macro setup_output_port
	ldi conf, 0xff
	out @0, conf
.endmacro

.macro init_zp
	ldi zl, low (@0 << 1)
	ldi zh, high(@0 << 1)
.endmacro

.cseg

.org 0x0000
	jmp main
.org 0x0020
	jmp timer_isr
.org 0x0024
	jmp recieve_isr

.org INT_VECTORS_SIZE

main:

	init_sp
	
	call setup_baudrate

	call setup_serial_port

	setup_output_port ddrb
	
	sei
	
	init_zp welcome_message
	call transmit_message

	init_zp query_message
	call transmit_message

loop:
	jmp loop



//subrutinas


// BAUDRATE

// UBRRn = 16Meg / 9600 - 1 = 103 = 0x0067
// UBRR0L <- 0x67
// UBRR0H <- 0x00

setup_baudrate:
	ldi conf, 0x67
	sts UBRR0L, conf
	ldi conf, 0x00
	sts UBRR0H, conf
ret


// CONFIGURACION PUERTO SERIE

// UCSZ0  <- 011 ; 8 bits
// UPM0   <-  00 ; sin paridad
// UMSEL0 <-  00 ; USART asincronico
// USBS0  <-   0 ; 1 stop bit
// RXEN0 enable
// TXEN0 enable
// sin 9eno bit
// interrupciones por recepcion
setup_serial_port:
	ldi conf, 0x98 ; 0b10011000
	sts UCSR0B, conf
	ldi conf, 0x06 ; 0b00000110
	sts UCSR0C, conf
ret


// rutina de transmision

transmit_message:

transmit_next:
	lpm write, z+
	sts UDR0, write

	call delay

sending:
	lds aux, UCSR0A
	sbrs aux, UDRE0	; itero hasta vaciar el buffer
	rjmp sending

	cpi write, 0x00
	brne transmit_next
ret

// rutina de recepcion

recieve_message:

reading:
	lds aux, UCSR0A
	sbrs aux, RXC0	; espero a recibir la data
	rjmp reading
	
	lds read, UDR0
ret


// DELAY PARA DAR TIEMPO AL BUFFER

delay:
	ldi conf, 0x01
	sts timsk0, conf
	ldi conf, 0x01
	out tccr0b, conf
	sei
here:	; termina la rutina luego de la interrupcion
	cpi conf, 0x00	
	brne here
ret		


// toggle

toggle_leds:
	ldi led, 0x01
	init_zp compare_table

cmp:
	lpm aux, z+		; recorro la tabla para setear que led toca
	cp read, aux
	breq toggle

	lsl led
	jmp cmp

toggle:
	in aux, led_port
	and aux, led
	cpi aux, 0x00
	brne turn_off
	in aux, led_port	; vuelvo a leer para no perder el resto de los estados
	or aux, led			; or para imponer 1
	out led_port, aux

	ret
turn_off:
	in aux, led_port
	com led
	and aux, led		; and negada para imponer 0
	out led_port, aux
ret


timer_isr:
	clr conf
	out tccr0b, conf
reti

recieve_isr:
	lds aux, UCSR0A
	sbrs aux, RXC0	; espero a recibir la data
	rjmp reading
	
	lds read, UDR0

	call toggle_leds
reti

//TABLAS

.org 0x0500

welcome_message: .db "*** Hola Labo de Micros ***", 0x0d, 0x0a, 0x00

query_message: .db "Escriba 1, 2, 3 o 4 para controlar los LEDs", 0x0d, 0x0a, 0x00

//welcome_message: .db 0x2a, 0x2a, 0x2a, 0x20, 0x48, 0x6f, 0x6c, 0x61, 0x20, 0x4c, 0x61, 0x62, 0x6f, 0x20, 0x64, 0x65, 0x20, 0x4d, 0x69, 0x63, 0x72, 0x6f, 0x20, 0x2a, 0x2a, 0x2a, 0x0d, 0x0a, 0x00

//query_message: .db 0x45, 0x73, 0x63, 0x72, 0x69, 0x62, 0x61, 0x20, 0x31, 0x2c, 0x20, 0x32, 0x2c, 0x20, 0x33, 0x20, 0x6f, 0x20, 0x34, 0x20, 0x70, 0x61, 0x72, 0x61, 0x20, 0x63, 0x6f, 0x6e, 0x74, 0x72, 0x6f, 0x6c, 0x61, 0x72, 0x20, 0x6c, 0x6f, 0x73, 0x20, 0x4c, 0x45, 0x44, 0x73, 0x0d, 0x0a, 0x00

compare_table: .db '1', '2', '3', '4'
