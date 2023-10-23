;LIT SOLDER OVEN CONTROLLER -- BONUS: 7SEG LED DISPLAY
; AUTHOR:	GEOFF GOODWIN
;			MUCHEN HE
;			WENOA TEVES
; VERSION:	0
; LAST REVISION:	2017-02-05
; http: i.imgur.com/7wOfG4U.gif

org 0x0000
    ljmp    setup
; org 0x000B
;     ljmp    T0_ISR
org 0x002B
    ljmp    T2_ISR

; standard library
$NOLIST
$MODLP52
$LIST
$include(macros.inc)
$include(LCD_4bit.inc)

; Preprocessor constants
CLK         equ     22118400

; pins for shift register
LED_DATA    equ     P0.0
LED_LATCH   equ     P0.1
LED_CLK     equ     P0.2
LED_CLR     equ     P0.3

; digits
d1          equ     1
d2          equ     2
d3          equ     3
d4          equ     4

; 7seg display
; "datasheet": http://haneefputtur.com/7-segment-4-digit-led-display-sma420564-using-arduino.html
;                   ABCDEFG.
O           equ     11111100
P           equ     11001110
E           equ     10011110
N           equ     11101100
