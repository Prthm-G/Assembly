$MODLP51RC2
org 0000H
    ljmp    setup

$include(math32.inc)

CLK         equ     22118400
BAUD        equ     115200
T1LOAD      equ     (0x100-CLK/(16*BAUD))
CE_ADC      equ     P2.0
MY_MOSI    equ     P2.1
MY_MISO    equ     P2.2
MY_SCLK    equ     P2.3
DSEG        at      30H
    result: ds 		2
    bcd:	ds 		5
    x:		ds 		4
    y:		ds		4
BSEG
	mf:		dbit 	1
CSEG
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
    clr     a
    movc    a,          @a+dptr
    jz      putString_done
    lcall   putChar
    inc     dptr
    sjmp    SendString
    
putString_done:
    ret
INI_SPI:
    setb    MY_MISO
    clr     MY_SCLK
    ret
DO_SPI_G:
    mov     R1,     #0
    mov     R2,     #8
SPI_loop:
    mov     a,          R0
    rlc     a
    mov     R0,         a
    mov     MY_MOSI,   c
    setb    MY_SCLK
    mov     c,          ADC_MISO
    mov     a,          R1
    rlc     a
    mov     R1,         a
    clr     MY_SCLK
    djnz    R2, SPI_loop
    ret

; main program
setup:
    mov     SP,         #7FH
    mov     PMOD,       #0
    setb    ADC_CE
    lcall   INI_SPI
    lcall   InitSerialPort
loop:
    clr     ADC_CE
    mov     R0,         #0x01
    lcall   SPi_loop
    mov     R0,         #0x80
    lcall   SPIcomm
    mov     a,          R1
    anl     a,          #0x03
    mov     result+1,   a
    mov     R0,         #0x55
    lcall   SPIcomm
    mov     result,     R1
    setb    ADC_CE
    sleep(#50)
    mov     x,          result
    mov     x+1,        result+1
    mov     x+2,        #0x00
    mov     x+3,        #0x00
    Load_y(49500)
    lcall   mul32
    Load_y(1023)
    lcall   div32
    Load_y(27300)
    lcall	sub32
    lcall   hex2bcd
    putBCD(bcd+1)
    putBCD(bcd)
    mov     a,          #'\r'
    lcall   putChar
    mov     a,          #'\n'
    lcall   putChar
    ljmp    loop
END
