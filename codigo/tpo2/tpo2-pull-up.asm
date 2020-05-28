.include "m328pdef.inc"

.dseg

.EQU IN_PORT = PINB
.EQU OUT_PORT = PORTB
.EQU PULSE_PIN = 0
.EQU LED_PIN = 5

.cseg
.org 0x0000
	jmp main

.org INT_VECTORS_SIZE
main:
	ldi R20,(0<<PULSE_PIN | 1<<LED_PIN)
	out DDRB,R20

	sbi OUT_PORT,PULSE_PIN	; pull-up enabled


led_on:
	sbi OUT_PORT,LED_PIN	; prender led

no_pulse:
	sbic IN_PORT,PULSE_PIN	; si se apreta el boton va a apagar el led
	rjmp no_pulse


led_off:
	cbi OUT_PORT,LED_PIN	; apagar led

pulse:
	sbis IN_PORT,PULSE_PIN	; si se suelta el boton va a prender el led
	rjmp pulse

	rjmp led_on
