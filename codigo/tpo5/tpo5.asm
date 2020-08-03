.include "m328pdef.inc"

.dseg

.def conf = r16
.def output = r17
.def aux = r18
.equ led_port = PORTB
.equ led_reg = DDRB

.macro init_ports
	ldi conf, 0xff
	out DDRB, conf
	clr conf
	out PORTB, conf
	out DDRC, conf
.endmacro

.macro init_adc
// Vref = VCC, ajusto la conversion a izq
// pongo el mux en el ADC2
	ldi conf, 0x62
	sts ADMUX, conf
// adc enable, interrupt enable, prescale 128 por usar clock de 16MHz
	ldi conf, 0xAF
	sts ADCSRA, conf
// free running mode
	clr conf
	sts ADCSRB, conf
.endmacro


.macro init_sp
	ldi conf, low(RAMEND)
	out spl, conf
	ldi conf, high(RAMEND)
	out sph, conf
.endmacro

.cseg
.org 0x0000
	jmp main
.org 0x002A // no econtre esta etiqueta
    jmp adc_isr


.org INT_VECTORS_SIZE
main:

	init_sp
	init_ports
	init_adc
	sei
// 1era conversion
	lds conf, ADCSRA
	ori conf, 0x40
	sts ADCSRA, conf
	
here:
	nop
	nop
	rjmp here
	
adc_isr:
	lds output, ADCH
	lsr output
	lsr output
	out led_port, output
reti


