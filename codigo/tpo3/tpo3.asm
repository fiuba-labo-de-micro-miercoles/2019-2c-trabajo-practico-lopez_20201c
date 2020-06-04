.include "m328pdef.inc"

.dseg


.macro ROR_LED
    ror @0
    out @1,@0
.endm

.macro ROL_LED
    rol @0
    out @1,@0
.endm



.EQU LIMITE_DER = 0
.EQU LIMITE_IZQ = 5
.EQU LEDS = PORTB

.cseg
.org 0x0000
    jmp main


.org INT_VECTORS_SIZE
main:

    ldi r20,0xff
    out DDRB,r20

    ldi r21,0x80    ; prendo el bit 7
    out LEDS,r21

barrer_der:
    call delay
    call correr_derecha
    sbis LEDS,LIMITE_DER
    rjmp barrer_der 

barrer_izq:
    call delay
    call correr_izquierda
    sbis LEDS,LIMITE_IZQ
    rjmp barrer_izq

    rjmp barrer_der


//subrutinas

correr_derecha:
    ROR_LED r21,LEDS
    ret

correr_izquierda:
    ROL_LED r21,LEDS
    ret


delay:
    ldi  r22,0x00
    ldi  r23,0x00
    ldi  r24,0x00
ciclo_encendido:
    inc  r22            
    cpi  r22,0xff       
    brlo ciclo_encendido

    ldi  r22,0x00       
    inc  r23            
    cpi  r23,0xff       
    brlo ciclo_encendido

    ldi  r23,0x00       
    inc  r24            
    cpi  r24,0x04       
    brlo ciclo_encendido

    ret
