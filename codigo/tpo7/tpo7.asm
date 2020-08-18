.include "m328pdef.inc"

.dseg

.def conf = r16
.def intensity = r17
.equ vmed = OCR2A
.equ vinit = 0x0f
.equ led_port = ddrb
.equ led = 3

.macro init_sp
	ldi conf, low (RAMEND)
	out spl, conf
	ldi conf, high(RAMEND)
	out sph, conf
.endmacro

.macro enable_pull_up_resistor
	ldi conf, 0x0c ; pins pd2 y pd3 en salida
	out DDRD, conf
	ldi conf, 0x0c
	out PIND, conf
.endmacro

.cseg

.org 0x0000
	jmp main
.org INT0addr
	jmp	isr_int0
.org INT1addr
	jmp	isr_int1

.org INT_VECTORS_SIZE
main:

	init_sp
	call setup_timer
	enable_pull_up_resistor
	sbi led_port, led
	call setup_interruption

loop:	
	nop
	nop
	nop
	jmp loop


// subrutinas	

setup_timer:
	ldi intensity, vinit
	sts vmed, intensity
// wmg 011 -> modo de op fast PWM, tope en MAX
// com2A 10 -> clr OC2a en cmp, set OC2a en 0x00
// com2B 00 -> OC2b desconectado
// cs2 001 -> ck = 16MHz / 1
	ldi conf, 0x83
	sts TCCR2A, conf
	ldi conf, 0x01
	sts TCCR2B, conf
ret

setup_interruption:
	ldi conf, 0x0a	; flanco descendente para int0 e int1
	sts eicra, conf
	ldi conf, 0x03	; habilito interrupciones 0 y 1
	out eimsk, conf
	sei
ret


// interrupciones

isr_int0:
	cpi intensity, 0xff
	breq end0
	inc intensity
	sts vmed, intensity
end0:
reti

isr_int1:
	cpi intensity, 0x00
	breq end1
	dec intensity
	sts vmed, intensity
end1:
reti