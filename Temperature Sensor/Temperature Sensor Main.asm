$MODLP51RC2
org 0000H
    ljmp    setup

; imports
$include(math32.inc)
;$include(macros.inc)
$include(LCD_4bit.inc)

CLK     equ     22118400
BAUD    equ     115200
T1LOAD  equ     (0x100-CLK/(16*BAUD))
FREQ    EQU     22118400
BRG_VAL EQU     256-(FREQ/(16*BAUD))
T0LOAD  equ     ((65536-(CLK/4096)))





; pins for ADCs
ADC_CE      equ     P2.0
MY_MOSI    equ     P2.1
MY_MISO    equ     P2.2
MY_SCLK    equ     P2.3

LCD_RS equ P1.2
LCD_RW equ P1.3
LCD_E  equ P1.4
LCD_D4 equ P3.2
LCD_D5 equ P3.3
LCD_D6 equ P3.4
LCD_D7 equ P3.5

Temperature: db 'Temperature:', 0

DSEG at 30H
    result: ds 		2
    bcd:	ds 		5
    x:		ds 		4
    y:		ds		4
    buffer: ds      30
    result_1: ds    2

BSEG
	mf:		dbit 	1

CSEG

;---------------------------------;
; Routine to initialize the ISR   ;
; for timer 0                     ;
;---------------------------------;

Read_ADC_Channel Mac
	mov b,#%0
	lcall loop
ENDMAC

timer0_init:
    ; clear bits for the timer
    mov a,      TMOD
    anl a,      #0xF0
    orl a,      #0x01
    mov TMOD,   a

    ; set reload value
    mov TH0,    #high(T0LOAD)
    mov TL0,    #low(T0LOAD)

    ; enable interrupts
    setb    ET0
    setb    TR0
    ret

;---------------------------------;
; ISR for timer 0.  Set to execute;
; every 1/4096Hz to generate a    ;
; 2048 Hz square wave at pin P3.7 ;
;---------------------------------;
timer0_ISR:
    ; operating in mode 1, reload the timer
    clr     TR0
    mov     TH0,    #high(T0LOAD)
    mov     TL0,    #low(T0LOAD)
    setb    TR0
    reti
    
InitSerialPort:
    mov     R1,     #222
    mov     R0,     #166
    djnz    R0,     $
    djnz    R1,     $-4
    orl	    PCON,   #0x80
    mov	    SCON,   #0x52
    mov BDRCON, #0X00
    mov BRL,#BRG_VAL
    mov BDRCON,#0x1E
    ret
    
putChar:
    jnb     TI,     putchar
    clr     TI
    mov     SBUF,   a
    ret
    
SendString:
	CLR a
	MOVC a, @a+DPTR
	JZ SSDone
	LCALL putchar
	INC DPTR
	SJMP SendString
SSDone:
	ret

getchar:
	jnb RI, getchar
	clr RI
	mov a, SBUF
	ret
	
GeString:
	mov R0,#buffer
	
GSLoop:
	lcall getchar
	push acc
	clr c
	subb a,#10H
	pop acc
	jc GSDone
	MOV @R0, A
	inc R0
	sjmp GSLoop
GSDone:
	clr a
	mov @R0,a
	ret
    
putString_done:
    ret
INI_SPI:
    setb    MY_MISO
    clr     MY_SCLK
    ret
DO_SPI_G:
	push    acc
    mov     R1,     #0
    mov     R2,     #8
SPI_loop:
    mov     a,          R0
    rlc     a
    mov     R0,         a
    mov     MY_MOSI,   c
    setb    MY_SCLK
    mov     c,          MY_MISO
    mov     a,          R1
    rlc     a
    mov     R1,         a
    clr     MY_SCLK
    djnz    R2, SPI_loop
    pop     acc
    ret
    

; main program
setup:
    mov     SP,     #7FH
;    mov     PMOD,   #0

    ; initialize MCP3008
    setb    ADC_CE
    lcall   INI_SPI
    lcall   InitSerialPort

    ; timer initialization
    lcall   timer0_init

    ; enable global interrupts
    setb    EA

; loops forever

loop:
    clr     ADC_CE
    mov     R0,         #00000001B
    lcall   DO_SPI_G
    mov     R0,         #10000000B
    lcall   DO_SPI_G
    mov     a,          R1
    anl     a,          #00000011B
    mov     result+1,   a
    mov     R0,         #055H
    lcall   DO_SPI_G
    mov     result,     R1
    setb    ADC_CE
    lcall   delay
    
    mov     x,      result+0
    mov     x+1,    result+1
    mov     x+2,    #0x00
    mov     x+3,    #0x00
    lcall   hex2bcd
    mov     result,     bcd
    mov     result+1,   bcd+1
   	lcall Do_something
   	ljmp	loop
    
Do_something:
    ; Multiply by 410
load_Y(410)
lcall mul32
; Divide result by 1023
load_Y(1023)
lcall div32
; Subtract 273 from result
load_Y(273)
lcall sub32
    ;Display_BCD(result)
    lcall   hex2bcd
    
    Send_BCD(bcd)
    mov     a,  #'\r'
    lcall   putChar
    mov     a,  #'\n'
    lcall   putChar


delay:
DJNZ R0, delay ; Decrement R0 and jump if not zero
RET ; Return from the delay routine

