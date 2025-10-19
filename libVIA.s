PORTB = $6000
PORTA = $6001
DDRB =  $6002
DDRA =  $6003

E  = %01000000
RW = %00100000
RS = %00010000

init_via:
  pha
  lda #%11111111  ; set all pins on port A to output
  sta DDRA
  lda #%11111111  ; set all pins on port B to output
  sta DDRB
  pla
  rts

