.include "m328pdef.inc"


.cseg 							; todo lo que viene a cont es codigo ejecutable (va en la flash program memory)
.org 0x0000						; todo lo que viene a cont ponelo a partir de 0x0000
			jmp		main		; main es una etiqueta
								; al hacer eso estoy pisando el reset con el jump

.org INT_VECTORS_SIZE			; los perifericos tienen asociada una dir de memoria a partir de la cual se ejecuta codigo especifico
main:							; INT_VECTOR_SIZE calcula la cantidad de memoria que hay que dejar para esos perifericos
								; la etiqueta esta definida en el include
 			ldi		r23,0xff
			out		DDRB,r23	; pongo el puerto en modo salida
		
led_on:		ldi		r23,0xff
			out		PORTB,r23 	; enciendo el led 
	

// inicializo los contadores
			ldi 	r20,0x00	;  4 * 255
			ldi 	r21,0x00	; (4 * 255 + 5) * 255
			ldi		r22,0x00	; (4 * 255 + 5) * 255 + 5) * 64 * 1/f = 1,5s

ciclo_encendido:
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
			brlo	ciclo_encendido ;    2  )) * 64
			
			clr		r23
			out		PORTB,r23		; apago el led

// inicializo los contadores
			ldi 	r20,0x00	;  4 * 255
			ldi 	r21,0x00	; (4 * 255 + 5) * 255
			ldi		r22,0x00	; (4 * 255 + 5) * 255 + 5) * 64 * 1/f = 1,5s

ciclo_apagado:
			inc		r20				;( 1 +
			cpi		r20,0xff		;  1 +
			brlo	ciclo_apagado	;  2  ) * 255

			ldi		r20,0x00		;( 1 +
			inc		r21				;  1 +
			cpi		r21,0xff		;  1 +
			brlo	ciclo_apagado	;  2  )* 255

			ldi		r21,0x00		;( 1 +
			inc		r22				;  1 +
			cpi		r22,0x40		;  1 +
			brlo	ciclo_apagado	;  2  )* 64


			RJMP	led_on		; vuelvo a arrancar
