PORTB = $6000
PORTA = $6001
DDRB =  $6002
DDRA =  $6003

E =   %10000000
RW =  %01000000
RS =  %00100000

  .org $8000

reset:
  lda #%11111111  ; set all pins on port B to output
  sta DDRB
  lda #%11100000  ; set top 3 pins on port A to output
  sta DDRA

  lda #%00111000  ; data for setting up display
  sta PORTB
  lda #0          ; bits for setting control lines to set display type
  sta PORTA
  lda #E          ; send instruction
  sta PORTA
  lda #0          ; clear control bits
  sta PORTA

  lda #%00001110  ; display on, cursor on, blink on
  sta PORTB
  lda #0          ; clear control bits
  sta PORTA
  lda #E          ; send instruction
  sta PORTA
  lda #0          ; clear control bits
  sta PORTA

  lda #%00000110  ; increment and shift cursor, don't scroll display
  sta PORTB
  lda #0          ; clear control bits
  sta PORTA
  lda #E          ; send instruction
  sta PORTA
  lda #0          ; clear control bits
  sta PORTA

  lda #"H"        
  sta PORTB
  lda #RS          ; clear control bits
  sta PORTA
  lda #(RS | E)   ; send char
  sta PORTA
  lda #RS          ; clear control bits
  sta PORTA

  lda #"e"        
  sta PORTB
  lda #RS          ; clear control bits
  sta PORTA
  lda #(RS | E)   ; send char
  sta PORTA
  lda #RS          ; clear control bits
  sta PORTA

  lda #"l"        
  sta PORTB
  lda #RS          ; clear control bits
  sta PORTA
  lda #(RS | E)   ; send char
  sta PORTA
  lda #RS          ; clear control bits
  sta PORTA

  lda #"l"        
  sta PORTB
  lda #RS          ; clear control bits
  sta PORTA
  lda #(RS | E)   ; send char
  sta PORTA
  lda #RS          ; clear control bits
  sta PORTA

  lda #"o"        
  sta PORTB
  lda #RS          ; clear control bits
  sta PORTA
  lda #(RS | E)   ; send char
  sta PORTA
  lda #RS          ; clear control bits
  sta PORTA

  lda #","        
  sta PORTB
  lda #RS          ; clear control bits
  sta PORTA
  lda #(RS | E)   ; send char
  sta PORTA
  lda #RS          ; clear control bits
  sta PORTA

  lda #" "        
  sta PORTB
  lda #RS          ; clear control bits
  sta PORTA
  lda #(RS | E)   ; send char
  sta PORTA
  lda #RS          ; clear control bits
  sta PORTA

  lda #"w"        
  sta PORTB
  lda #RS          ; clear control bits
  sta PORTA
  lda #(RS | E)   ; send char
  sta PORTA
  lda #RS          ; clear control bits
  sta PORTA

  lda #"o"        
  sta PORTB
  lda #RS          ; clear control bits
  sta PORTA
  lda #(RS | E)   ; send char
  sta PORTA
  lda #RS          ; clear control bits
  sta PORTA 

  lda #"r"        
  sta PORTB
  lda #RS          ; clear control bits
  sta PORTA
  lda #(RS | E)   ; send char
  sta PORTA
  lda #RS          ; clear control bits
  sta PORTA

  lda #"l"        
  sta PORTB
  lda #RS          ; clear control bits
  sta PORTA
  lda #(RS | E)   ; send char
  sta PORTA
  lda #RS          ; clear control bits
  sta PORTA

  lda #"d"        
  sta PORTB
  lda #RS          ; clear control bits
  sta PORTA
  lda #(RS | E)   ; send char
  sta PORTA
  lda #RS          ; clear control bits
  sta PORTA

  lda #"!"        
  sta PORTB
  lda #RS          ; clear control bits
  sta PORTA
  lda #(RS | E)   ; send char
  sta PORTA
  lda #RS          ; clear control bits
  sta PORTA

loop:
  jmp loop

  .org $fffc
  .word reset
  .word $0000