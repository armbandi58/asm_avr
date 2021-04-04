; ledblink.asm
;
; Created: 2021. 04. 03. 20:05:53
; Author : borsa
;
; Replace with your application code
.include "m328pdef.inc"
.DSEG

.CSEG
.DEF tmp = r16
.DEF led = r17
.DEF time0 = r18
.DEF time1 = r19
.DEF time2 = r20

.DEF time3 = r21
.DEF time4 = r22
.DEF time5 = r23

.DEF tmp_led = r24
.DEF i = r25
.DEF j = r0
.DEF k = r1
; ===================== CIMEK =====================

.org 0x00
	rjmp start

.org 0x20
	rjmp TIM0_OVF_IT

.org 0x1A
	rjmp TIM1_OVF_IT

.org 0x100

;PB5 - PC7/6/5/4
; =========== MACRO ===========
.macro PORT_init
	ldi tmp,0x20
	out DDRB, tmp
	ldi tmp, 0xFF
	out DDRC,tmp
	ldi tmp, 0x10
	out DDRD, tmp
.endmacro

.macro STACK_init
	ldi tmp, high(RAMEND)
	out sph, tmp 
	ldi tmp, low(RAMEND)
	out spl, tmp 
.endmacro

.macro DELAY
	ldi time0,0xF0
	ldi time1,0xF0
	ldi time2,0xF0
	delay_loop:
		dec time0
		brne delay_loop
		dec time1
		brne delay_loop
		dec time2
		brne delay_loop
.endmacro

.macro TIM0_init
	ldi tmp,0xFF
	sts TIMSK0, tmp
	;out TOIE0, tmp
	ldi tmp, 0x00
	out TCCR0A, tmp
	ldi tmp, 0x05
	out TCCR0B, tmp
.endmacro

.macro TIM1_init
	ldi tmp, 0x01
	sts TIMSK1, tmp
	ldi tmp, 0x00
	sts TCCR1A, tmp
	ldi tmp, 0x05
	sts TCCR1B, tmp
.endmacro

start:
	STACK_init
	PORT_init
	TIM0_init
	TIM1_init
	clr i
	ldi tmp, 0x0F
	mov j, tmp
	ldi tmp, 0x00
	mov k, tmp
	;out PORTD, tmp
	sei

loop:
	call LED_test
	;call LED_blink
	;call DELAY_sub
	;call LED_blink
	;call DELAY_sub
	;eor led, tmp
	;out PORTB,led
	;DELAY
	rjmp loop

; ==============  SUBrutins  ==============
LED_blink:
	cpi i, 0x01
	breq as1
	ldi i,0x01
	sbi PORTD,4
	 ret
	as1:
		clr i
		cbi PORTD,4
		ret

blink:
	ldi tmp, 0x01
	cp k, tmp
	breq nas
	mov k, tmp
	sbi PORTB,5
	 ret
	nas:
		ldi tmp, 0x00
		mov k, tmp
		cbi PORTB,5
		ret

DELAY_sub:
	ldi time3,0xF0
	ldi time4,0xF0
	ldi time5,0xF0
	loopocska:
		dec time3
		brne loopocska
		dec time4
		brne loopocska
		dec time5
		brne loopocska
 ret

LED_test:
	ldi tmp_led, 0x01
	loop_LEDtest:
		out PORTC, tmp_led
		lsl tmp_led
		call DELAY_sub
		cpi tmp_led, 0x08
		brne loop_LEDtest
 ret

TIM0_OVF_IT:
	dec j
	ldi tmp, 0x01
	cp j, tmp 
	breq veg
	 reti
	veg:
	call LED_blink
	 reti

TIM1_OVF_IT:
	call blink
 reti
