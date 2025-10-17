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

  lda #"H" 
  jsr send_char

  lda #"e"        
  jsr send_char

  lda #"l"        
  jsr send_char

  lda #"l"        
  jsr send_char

  lda #"o"        
  jsr send_char

  lda #","        
  jsr send_char

  lda #" "        
  jsr send_char

  lda #"w"        
  jsr send_char

  lda #"o"        
  jsr send_char 

  lda #"r"        
  jsr send_char

  lda #"l"        
  jsr send_char

  lda #"d"        
  jsr send_char

  lda #"!"        
  jsr send_char

loop:
  jmp loop

send_instruction:
  sta PORTB
  lda #0          ; bits for setting control lines to set display type
  sta PORTA
  lda #E          ; send instruction
  sta PORTA
  lda #0          ; clear control bits
  sta PORTA
  jsr delay
  rts

send_char:
  sta PORTB
  lda #RS          ; clear control bits
  sta PORTA
  lda #(RS | E)   ; send char
  sta PORTA
  lda #RS          ; clear control bits
  sta PORTA
  jsr delay
  rts

delay:
  ldx #$ff
  ldy #$03
delay_loop:
  dex
  bne delay_loop
  ldx #$ff
  dey
  bne delay_loop
  rts
  
  .org $fffc
  .word reset
  .word $0000