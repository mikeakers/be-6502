PORTB = $6000
PORTA = $6001
DDRB =  $6002
DDRA =  $6003

value = $00 ; 2 bytes
mod10 = $02 ; 2 bytes
message = $04 ; 6 bytes

E  = %01000000
RW = %00100000
RS = %00010000

  .org $8000

reset:
  ldx #$ff         ; Set stack pointer to top of the stack range 
  tsx
  jsr init_via
  jsr init_lcd

  lda #0
  sta message     ; initialize message string with NULL in first location

  lda number      ; Copy number from ROM to ram
  sta value
  lda number + 1
  sta value + 1

divide:
  lda #0          ; initialize remainder
  sta mod10
  sta mod10 + 1

  ldx #16
  clc
divloop:
  ; Rotate quotient and remainder
  rol value       ; value << 1
  rol value + 1
  rol mod10       ; mod10 << 1 with carry from shifting value
  rol mod10 + 1

  ; a,y = dividend - divisor
  sec
  lda mod10
  sbc #10
  tay             ; save low byte in Y
  lda mod10 + 1
  sbc #0
  bcc ignore_result ; branch if dividend < divisor
  sty mod10
  sta mod10 + 1
  
ignore_result:
  dex
  bne divloop
  rol value
  rol value + 1

  lda mod10
  clc
  adc  #"0"
  jsr push_char

  ; if value != 0, then continue dividing
  lda value
  ora value + 1
  bne divide      ; branch if value not 0

  ; prints the null terminated string at message to the lcd
  ldx #0
print:
  lda message,x
  beq end_loop
  jsr print_char
  inx
  jmp print

; inifinite loop to end program
end_loop:
  jmp end_loop

number: .word 31337

; pushes a char to the front of the null terminated string at message
push_char:
  pha
  ldy #0
char_loop:
  lda message,y
  tax
  pla
  sta message,y
  iny
  txa
  pha
  bne char_loop
  pla
  sta message,y
  rts

init_via:
  pha
  lda #%11111111  ; set all pins on port A to output
  sta DDRA
  lda #%11111111  ; set all pins on port B to output
  sta DDRB
  pla
  rts

  include "libLCD.s"

  .org $fffc
  .word reset
  .word $0000
