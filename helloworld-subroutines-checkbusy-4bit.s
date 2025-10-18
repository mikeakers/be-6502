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
  jsr init_lcd

  ldx #0
print_loop:
  lda message,x
  beq halt 
  jsr send_char
  inx
  jmp print_loop

halt:
  stp

message: .asciiz "  Hello, 4-bit                            mode! :D" 

init_lcd:
  pha
  lda #%11111111  ; set all pins on port B to output
  sta DDRB
  lda #%11100000  ; set top 3 pins on port A to output
  sta DDRA

  lda #%00100000  ; set 4 bit operation
  jsr send_instruction

  lda #%00101000  ; 4 bit operation, 2 line display
  jsr send_instruction4

  lda #%00001110  ; turn on display and cursor
  jsr send_instruction4

  lda #%00000110  ; set mode to increment and shift cursor
  jsr send_instruction4

  pla
  rts

send_instruction4:
  pha
  jsr send_instruction
  rol
  rol
  rol
  rol
  jsr send_instruction
  pla
  rts

send_instruction:
  pha
  jsr lcd_wait
  sta PORTB
  lda #0          ; bits for setting control lines to set display type
  sta PORTA
  lda #E          ; send instruction
  sta PORTA
  lda #0          ; clear control bits
  sta PORTA
  pla
  rts

send_char:
  pha             ; push char to print onto stack
  jsr lcd_wait
  sta PORTB
  lda #RS          ; clear control bits
  sta PORTA
  lda #(RS | E)   ; send char
  sta PORTA
  lda #RS          ; clear control bits
  sta PORTA

  pla             ; pop char to print from stack
  pha             ; push char back to stack so it can be restored before rts
  rol             ; shift left 4 bits
  rol
  rol
  rol

  jsr lcd_wait
  sta PORTB
  lda #RS          ; clear control bits
  sta PORTA
  lda #(RS | E)   ; send char
  sta PORTA
  lda #RS          ; clear control bits
  sta PORTA
  pla
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
