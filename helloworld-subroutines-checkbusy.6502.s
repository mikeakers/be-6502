PORTB = $6000
PORTA = $6001
DDRB =  $6002
DDRA =  $6003

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

  ldx #0
print_loop:
  lda message,x
  beq loop
  jsr send_char
  inx
  jmp print_loop
  
loop:
  jmp loop

message: .asciiz "Hello, Strings!" 

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

send_char:
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