; PROJECT:	KnightRider (shift register animations)
; PURPOSE:	To manipulate a shift register (SR) in AVR Assembly
; DEVICE:	Arduino (ATmega328p)
; AUTHOR:	Daniel Raymond
; DATE:		2019-02-01

.org		0x0000				; Tells PC that reset is the 1st instruction
	rjmp	reset

.equ DDR		=DDRD		
.equ POUT		=PORTD

.equ clock		=PD7
.equ latch		=PD6
.equ data		=PD5
.equ gnd		=PD4
.equ pwr		=PD3

.equ outPins	= (1<<clock | 1<<latch | 1<<data | 1<<gnd | 1<<pwr)

.equ swtchPwr	=PC0
.equ swtchRead	=PC1
.equ swtchGnd	=PC2
.equ DDRS		=DDRC
.equ POUTS		=PORTC
.equ PIN		=PINC
.equ outPinSwtch =(1<<swtchPwr | 1<<swtchGnd)
.equ onPos		=(1<<swtchPwr | 1<<swtchRead)

.def	util	= r16		; r16 is a general purpose register
.def	read	= r17		; Reading in the value of the switch port
.def	incr	= r18		; Incrementing register for the # of LEDs that are on
.def	leds	= r19		; The register that holds the final output of the SR
.def	mask	= r20		; Mask to isolate which LEDs need to be on
.def	bit		= r21		; The bit in focus (when shifting out)

reset:
	ldi util,	outPins		; Set pins on the SR to output
	out DDR,	util		; Change data direction to match outputPins
	ldi util,	outPinSwtch	; Sets up power and ground for the switch
	out DDRS,	util		; Makes data direction match
	sbi POUT,	pwr			; Set the power pin to high
	sbi	POUTS,	swtchPwr	; Give the switch power

	ldi incr,	1			; Set the first LED on
  loop:
   anim1:
	in	read,	PIN			; Read the switch
	cpi	read,	onPos		; If the read pin is high
   brne			anim2		; If the switch is low, go to the 2nd Animation
   ldi	incr,	1			; Revert the increment register
	clr	leds				; Turn off all LEDs (LSB will be turned on before it gets sent to SR)
   rcall		rowLEDs		; Otherwise, it will run the row animation
   rjmp			anim1		; Once it is done, it will run the row animation again
   anim2:
	ldi	leds,	0xFF		; Start the leds as all on
	rcall		decr		; Run the animation
  rjmp	loop
rjmp	reset

decr:
	dec	leds
    rcall		shiftOut	; Sending out the LED data
	rcall		delay250ms	; Wait
	in	read,	PIN			; Read the switch
	cpi	read,	onPos		; If the read pin is high	
	breq		loop		; If switch state has changed, it will go back to the loop
	rjmp		decr		; Otherwise, it will continue to flash
ret

rowLEDs:
	or	leds,	incr		; Set another LED high while keeping the others on
	rcall		shiftOut	; Shift out the data
	rcall		delay250ms
	rcall		delay250ms	; Wait for 1s
	rcall		delay250ms
	rcall		delay250ms

	in	read,	PIN			; Read the switch
	cpi	read,	onPos		; If the read pin is high	
	brne		anim2		; Go the other animation if it is low

	lsl	incr				; Move on to the next LED
	cpi leds,	0xFF		; See if we've reached all 8 LEDs
   brne			rowLEDs		; Continue the loop without reverting all the variables
   	ldi	incr,	1			; Revert the increment register
	clr	leds				; Turn off all LEDs (LSB will be turned on before it gets sent to SR)
ret

; Shiftout function
shiftOut:
	ldi mask,		1		; Dealing with the first bit
	cbi	POUT,	latch		; Pull latch low to be able to send in data
 cycle:						; Loop for all 8 bits
	cbi POUT,	clock		; Pull clock low
	mov	bit,	leds		; We're going to be destroying the info
	and bit,	mask		; Clear all except the bit in question
   breq			out0		; If mask is 0, set the data pin to 0, else it's 1
	sbi POUT,	data		; Setting the data pin
	rjmp		wrapUp		; jumping to the end
  out0:
	cbi POUT,	data		; Setting the data pin
  wrapUp:
	sbi	POUT,	clock		; Send out data by pulling the clock high
	lsl	mask				; Shift the bit in question over by 1
	cpi	mask,	0			; See if a full byte has passed
	breq		leave		; Get out if a full byte has been sent
 rjmp cycle					; Continue if it's not done
 leave:
	sbi POUT,	latch		; Release the data
ret

; A delay for 250ms
delay250ms:                                
	ldi  r29, 21
    ldi  r30, 75
    ldi  r31, 191
L1: dec  r31
    brne L1
    dec  r30
    brne L1
    dec  r29
    brne L1
    nop
ret