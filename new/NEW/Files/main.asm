;  ** ATmega103(L) Assembly Language File - IAR Assembler Syntax **
;  ** Author : C. Foudas
;  ** Company : Imperial College, High Energy Physics division
;  ** Comment : This is an example of using the LCD display
;
.DEVICE ATmega128
.include "m128def.inc"	
;
		.ORG	$0
                                       RJMP Init
Init:                
   
		; ************* Stack Pointer Setup Code   
		ldi r16, $0F		; Stack Pointer Setup to 0x0FFF
		out SPH,r16		; Stack Pointer High Byte 
		ldi r16, $FF		; Stack Pointer Setup 
		out SPL,r16		; Stack Pointer Low Byte 
   
		; ******* RAMPZ Setup Code ****  lower memory page arithmetic
		ldi  r16, $00		; 1 = EPLM acts on upper 64K
		out RAMPZ, r16		; 0 = EPLM acts on lower 64K
   
		; ******* Sleep Mode And SRAM  *******
		;			; tell it we want read and write activity on RE WR
		ldi r16, $C0		; Idle Mode - SE bit in MCUCR not set
		out MCUCR, r16		; External SRAM Enable Wait State Enabled
   
		; ******* Comparator Setup Code ****  
		ldi r16,$80		; Comparator Disabled, Input Capture Disabled 
		out ACSR, r16		; Comparator Settings
   
		; ******* Port A Setup Code ****  
		ldi r16, $FF		; Address AD7 to AD0
		out DDRA, r16		; Port A Direction Register
		ldi r16, $00		; Init value 
		out PORTA, r16		; Port A value
   
		; ******* Port B Setup Code ****  
		ldi r16, $FF		; will set to outputs so i cab use Leds for debugging
		out DDRB , r16		; Port B Direction Register
		ldi r16, $55		; Who cares what is it....
		out PORTB, r16		; Port B value
   
		; ******* Port C Setup Code ****  
		ldi r16, $00		; Address AD15 to AD8
		out PORTC, r16		; Port C value
		
		ldi r28,$01    ; to load key 1
		ldi r24,$FF
		ldi r27,$20
		
;
;
;   
; Make R23 our flag register
;
                                      CLR r23
                                      SBR r23, $1	   
/*
		; ************* Stack Pointer Setup Code   
		ldi r16, $0F		; Stack Pointer Setup to 0x0FFF
		out SPH,r16		; Stack Pointer High Byte 
		ldi r16, $FF		; Stack Pointer Setup 
		out SPL,r16		; Stack Pointer Low Byte 
   
		; ******* RAMPZ Setup Code ****  lower memory page arithmetic
		ldi  r16, $00		; 1 = EPLM acts on upper 64K
		out RAMPZ, r16		; 0 = EPLM acts on lower 64K
   
		; ******* Sleep Mode And SRAM  *******
		;			; tell it we want read and write activity on RE WR
		ldi r16, $C0		; Idle Mode - SE bit in MCUCR not set
		out MCUCR, r16		; External SRAM Enable Wait State Enabled
   
		; ******* Comparator Setup Code ****  
		ldi r16,$80		; Comparator Disabled, Input Capture Disabled 
		out ACSR, r16		; Comparator Settings
   
		; ******* Port A Setup Code ****  
		ldi r16, $FF		; Address AD7 to AD0
		out DDRA, r16		; Port A Direction Register
		ldi r16, $00		; Init value 
		out PORTA, r16		; Port A value
   
		; ******* Port B Setup Code ****  
		ldi r16, $FF		; will set to outputs so i cab use Leds for debugging
		out DDRB , r16		; Port B Direction Register
		ldi r16, $00		; Who cares what is it....
		out PORTB, r16		; Port B value
   
		; ******* Port C Setup Code ****  
		ldi r16, $00		; Address AD15 to AD8
		out PORTC, r16		; Port C value
*/


Main:
		; ~~~~~~~ r23 and r20 are my registers for key recognition
		ldi r24, $00 ; store key 1
		ldi r20, $00 ; store key 1+2
		ldi r28, $01   ;1st cycle, load 1, changes later if cuycle repeated?
		rcall waitforbuttonpress
		
		SBRC r23, 0
        rcall Idisp
        SBRC r23, 0
        CBR                                                                   r23, $1
;
        ldi r18, 0
		ldi r17, 0
		; r21 is result reading
		rcall translate_column_start ; translate the key
		
		rcall Mess1Out
        rcall BigDel
        rcall CLRDIS

		rjmp Main

translate_column_start:
	mov r26, r21
	com r26
	cpi r26, $0 ;check if r26 is 0 if it is then make it 16
	breq r26_To_10	
	ldi r17,$0 ; set for column
	rjmp translate_column

r26_To_10:
	ldi r26,$10
	ldi r17,$0 ; set for column
	rjmp translate_column

translate_row_start:	
	mov r26,r21
	com r26
	cpi r26, $0 ;check if r26 is 0 if it is then make it 16
	breq r26_To_10ii

	lsr r26
	lsr r26
	lsr r26
	lsr r26
	ldi r18, $0
	rjmp translate_row

r26_To_10ii:
    ldi r26,$01
	lsr r26
	lsr r26
	lsr r26
	lsr r26
	ldi r18, $0
	rjmp translate_row

translate_column: ;r17 counter for row
	sbrc r26,0
	rjmp translate_row_start; I want to leave this  somehow
	inc r17
	lsr r26
	rjmp translate_column
translate_row: ;r18 ciybter fir riw
	sbrc r26, 0
	rjmp translate_calculate;leave to calculate translate
  	inc r18
	lsr r26
	rjmp translate_row
translate_calculate: ; add r17 and r18 and get index number of key
	lsl r18
	lsl r18
	add r17,r18 ; r17 is the index of key
	;mov r21,r17 ; move r17 to r21 - this is to be desplayed on LED
	ret

waitforbuttonpress:


	ldi r21, $00   ;high 4-bit
	

	ldi r22, $00
	ldi r18, $00
	
	; set keayboard out in 
	; this sets port  4-7 as outputs and porte 0-3 imputs
	ldi r16, $F0		; load r16 with 0-3 input
	out DDRE , r16		; Direction register
	ldi r16, $0F		; 4-7 output
	out PORTE, r16		; 
	rcall BigDEL
	
	
	; reading whats oan the keaythobar
	in r21, PINE ;getting value from pinE
	


	                    
	;inverse the pin output input
	ldi r16, $0F		; load r16 with 0-3 input, reverse input and ouput
	out DDRE , r16		; Direction register
	ldi r16, $F0		; 4-7 output
	out PORTE, r16		; 
	rcall BigDEL
	;red PINE again
	in r18, PINE ;getting value from pinE

	;push r21 ~~~~~~~~~~~~~~~~~~ R21 is the result of reading the key
	add r21, r18 ;add 2 results
	
	;__________________ SAVE KEY 1 AND KEY 2



	; send if different
	;cp r24, r20 ;if same then start waitforbuttonpress again without exporting value
	;breq waitforbuttonpress ; if equal goes down, if not equal goes back to start of waitforbuttonpress
	
	; just send to led
	out PORTB, r21  ;ouput to LED R21 show
	

	




	cpi r21, $00
	breq waitforbuttonpress    ;leaves waiting for button, if value input is not $FF
	ret




savek1r21: ; let's swap iot to fight the increment in previous routuine
	mov r21,r27 ; key 2
	ret
savek2r21:
	mov r21,r24 ; key 1
	
;*******************************************************************************
;
Mess1:
.db 'I','m','p','e','r','i','a','l',' ','C','o','l','l','e','g','e'
Mess2:
.db 'I','m','p','e','r','i','a','l',' ','C','o','l','l','e','g','e'
;
Mess1Out:
              LDI ZH, HIGH(2*Mess1)
              LDI ZL, LOW(2*Mess1)
              LDI r18, 16 ;number of characters or bytes
Mess1More:

			  sts $C000, r17 ;was r21 - was old code, r27 is key 2
              rcall busylcd    ;wiat
              DEC r18     ;check that we have sent all bytes
 ;             BREQ Mess1End    ;if yes quit
   ;           ADIW ZL, $01     ;point to the next location in PM
              ;OUT PORTB, ZL
			  push r24
			  mov r24, r21
			  ;mov r24, r23
              rcall BigDEL
			  rcall BigDEL
			  rcall BigDEL
			  rcall BigDEL

			  ;rcall waitforbuttonpress
			  ;cp r21, r24
			  ;pop r24
			  ;cp r24, r23
			  ;brne Mess1More
			  ret
			  ;RJMP Mess1More    ;get the next byte
Mess1End:     ret
;             
Mess2Out:
              LDI ZH, HIGH(2*Mess2)
              LDI ZL, LOW(2*Mess2)
              LDI r18, 16   ;number of characters or bytes
Mess2More:
              LPM 
              MOV r17, r0
              sts $C000, r17
              rcall busylcd
              DEC r18
              BREQ Mess2End
              ADIW ZL, $01
             ;OUT PORTB, ZL
              RJMP Mess2More
Mess2End:     ret

;
;*******************************************************************************
; Display Initialization routine
;
; Since we cannot rely that that Power Supply will have on power up
; the required by Hitachi Specs.....we do the initialization 'by hand'.
; Follow Blindly the White-Red Book of Hitachi.
; Hitachi Liquid Crystal Disply LCD Initialization Sequence.
;
Idisp:		
		
		RCALL DEL15ms                ; wait 15ms for things to relax after power up           
		ldi r16,    $30	         ; Hitachi says do it...
		sts   $8000,r16                      ; so i do it....
		RCALL DEL4P1ms             ; Hitachi says wait 4.1 msec
		sts   $8000,r16	         ; and again I do what I'm told
		rcall Del49ms
		sts   $8000,r16	         ; here we go again folks
                rcall busylcd		
		ldi r16, $3F	         ; Function Set : 2 lines + 5x7 Font
		sts  $8000,r16
                rcall busylcd
		ldi r16,  $08	         ;display off
		sts  $8000, r16
                rcall busylcd		
		ldi r16,  $01	         ;display on
		sts  $8000,  r16
                rcall busylcd
                ldi r16, $38	        ;function set
		sts  $8000, r16
		rcall busylcd
		ldi r16, $0E	        ;display on
		sts  $8000, r16
		rcall busylcd
		ldi r16, $06                           ;entry mode set increment no shift
		sts  $8000,  r16
                rcall busylcd
                clr r16
                ret
;
;**********************************************************************************
; This clears the display so we can start all over again
;
CLRDIS:
	        ldi r16,$01	; Clear Display send cursor 
		sts $8000,r16   ; to the most left position
		rcall busylcd
                ret
;**********************************************************************************
; A routine the probes the display BUSY bit
;
   
busylcd:        
        lds r16, $8000   ;access 
        sbrc r16, 7      ;check busy bit  7
        rjmp busylcd
        rcall BigDEL

        ret              ;return if clear

;********************   DELAY ROUTINES ********************************************
BigDEL:
             ;rcall Del49ms
             ;rcall Del49ms
             ;rcall Del49ms
             ;rcall Del49ms
             ;rcall Del49ms
             ret
;
DEL15ms:
;
; This is a 15 msec delay routine. Each cycle costs
; rcall           -> 3 CC
; ret              -> 4 CC
; 2*LDI        -> 2 CC 
; SBIW         -> 2 CC * 19997
; BRNE        -> 1/2 CC * 19997
; 

            LDI XH, HIGH(19997)
            LDI XL, LOW (19997)
COUNT:  
            SBIW XL, 1
            BRNE COUNT
            RET
;
DEL4P1ms:
            LDI XH, HIGH(5464)
            LDI XL, LOW (5464)
COUNT1:
            SBIW XL, 1
            BRNE COUNT1
            RET 
;
DEL100mus:
            LDI XH, HIGH(131)
            LDI XL, LOW (131)
COUNT2:
            SBIW XL, 1
            BRNE COUNT2
            RET 
;
DEL49ms:
            LDI XH, HIGH(65535)
            LDI XL, LOW (65535)
COUNT3:
            SBIW XL, 1
            BRNE COUNT3
            RET 