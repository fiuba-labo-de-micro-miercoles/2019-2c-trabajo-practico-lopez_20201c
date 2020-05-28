.include "m328pdef.inc"

.dseg

.EQU LED_PORT = 5				; led en PORTB 5
								; se que el led esta ahi por la hoja de datos

.cseg 							; todo lo que viene a cont es codigo ejecutable
								; (va en la flash program memory)

.org 0x0000						; escribo a continuacion de 0x0000
			jmp		main		; el programa se va a donde arranca mi codigo

.org INT_VECTORS_SIZE
main:
			sbi		DDRB,LED_PORT	; pongo en modo salida el FF que se comunica
			 						; con el puerto del led

led_on:		sbi		PORTB,LED_PORT 	; enciendo el led

// inicializo los contadores		; cuento los ciclos de maquina que quiero
			ldi 	r20,0x00		;  4 * 255
			ldi 	r21,0x00		; (4 * 255 + 5) * 255
			ldi		r22,0x00		; (4 * 255 + 5) * 255 + 5) * 64 * 1/f = 1s

ciclo_encendido:					; chequeo los ciclos de maquina paso a paso
			inc		r20				;((( 1 +
			cpi		r20,0xff		;    1 +
			brlo	ciclo_encendido	;    2  )  * 255 +

			ldi		r20,0x00		;  ( 1 +
			inc		r21				;    1 +
			cpi		r21,0xff		;    1 +
			brlo	ciclo_encendido	;    2  )) * 255 +

			ldi		r21,0x00		;  ( 1 +
			inc		r22				;    1 +
			cpi		r22,0x40		;    1 +
			brlo	ciclo_encendido ;    2  )) * 64 ; 64 pues voy hasta 0x40


			cbi		PORTB,5			; apago el led

// inicializo los contadores		; cuento los ciclos de maquina que quiero
			ldi 	r20,0x00		;  4 * 255
			ldi 	r21,0x00		; (4 * 255 + 5) * 255
			ldi		r22,0x00		; (4 * 255 + 5) * 255 + 5) * 64 * 1/f = 1s

ciclo_apagado:						; cheque los ciclos de maquina paso a paso
			inc		r20				;((( 1 +
			cpi		r20,0xff		;    1 +
			brlo	ciclo_apagado	;    2  )  * 255 +

			ldi		r20,0x00		;  ( 1 +
			inc		r21				;    1 +
			cpi		r21,0xff		;    1 +
			brlo	ciclo_apagado	;    2  )) * 255 +

			ldi		r21,0x00		;  ( 1 +
			inc		r22				;    1 +
			cpi		r22,0x40		;    1 +
			brlo	ciclo_apagado 	;    2  )) * 64


			RJMP	led_on			; vuelvo a arrancar
