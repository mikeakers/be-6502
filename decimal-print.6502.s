PORTB = $6000
PORTA = $6001
DDRB =  $6002
DDRA =  $6003

value = $00 ; 2 bytes
mod10 = $02 ; 2 bytes
message = $04 ; 6 bytes

E =   %10000000
RW =  %01000000
RS =  %00100000

  .org $8000

reset:
  ldx #$ff         ; Set stack pointer to top of the stack range 
  tsx

  lda #%11111111  ; set all pins on port B to output
  sta DDRB
  lda #%11100000  ; set top 3 pins on port A to output
  sta DDRA
  lda #%00111000  ; data for setting up display
  jsr send_instruction
  lda #%00001110  ; display on, cursor on, blink on
  jsr send_instruction
  lda #%00000110  ; increment and shift cursor, don't scroll display
  jsr send_instruction
  lda #%00000001  ; Clear display
  jsr send_instruction

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

send_instruction:
  jsr lcd_wait
  sta PORTB
  lda #0          ; bits for setting control lines to set display type
  sta PORTA
  lda #E          ; send instruction
  sta PORTA
  lda #0          ; clear control bits
  sta PORTA
  rts

print_char:
  jsr lcd_wait
  sta PORTB
  lda #RS          ; clear control bits
  sta PORTA
  lda #(RS | E)   ; send char
  sta PORTA
  lda #RS          ; clear control bits
  sta PORTA
  rts

lcd_wait:
  pha
  lda #%00000000  ; Port B to input
  sta DDRB
lcdbusy:
  lda #RW
  sta PORTA
  lda #(RW | E)
  sta PORTA
  lda PORTB
  and #%10000000
  bne lcdbusy

  lda #RW
  sta PORTA
  lda #%11111111  ; Port b to output
  sta DDRB
  pla
  rts
  
  .org $fffc
  .word reset
  .word $0000