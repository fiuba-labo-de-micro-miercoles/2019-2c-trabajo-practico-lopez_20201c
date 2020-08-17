.include "m328pdef.inc"

.dseg

.def conf = r16
.def freq = r17
.def aux = r18
.def aux1 = r19
.equ input = pind
.equ A = 0	;pins de entrada
.equ B = 1
.equ led_port = portb
.equ led = 0
.equ len = 4


.macro init_sp
	ldi conf, low(RAMEND)
	out spl, conf
	ldi conf, high(RAMEND)
	out sph, conf
.endmacro


.macro init_xp
	ldi xl, low (tccr1b)
	ldi xh, high(tccr1b)
.endmacro


.cseg
.org 0x0000
	jmp main
.org 0x001A
	jmp timer_isr



.org INT_VECTORS_SIZE

main:
	init_sp
	init_xp
	call setup_ports

	call interrupt_enable
	sbi led_port, led

here:
	call init_zp		; apunto z al vector de prescales
	call set_frequency
	cpi freq, 0x00
	brne here
	sbi led_port, led	; si no setee prescale dejo me aseguro que quede prendido el led
	jmp here


set_frequency:
	clr aux1
	in aux, input
	add zl, aux
	adc zh, aux1
	lpm freq, z		; cargo el valor del vector
	st x, freq
ret

interrupt_enable:
	ldi conf, 0x01
	sts timsk1, conf ; interrupcion en V
	sei
ret

setup_ports:
	clr conf
	out input, conf	; PIND como entrada
	ldi conf, 0x01
	out ddrb, conf	; PB0 como salida
ret

init_zp:
	ldi zl, low (vector << 1)
	ldi zh, high(vector << 1)
ret

timer_isr:
	sbic led_port, led	; si no esta apagado, lo apago
	rjmp turn_off

	sbi led_port, led	; si no, lo prendo y salgo
reti ; 1

turn_off:
	cbi led_port, led
reti ; 0

vector: .db 0x00, 0x03, 0x04, 0x05
