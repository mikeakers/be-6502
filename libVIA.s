PORTB = $6000
PORTA = $6001
DDRB =  $6002
DDRA =  $6003
ACR =   $600b
PCR =   $600c
IFR =   $600d
IER =   $600e

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

init_interrupts:
  pha
  lda #%10000010
  sta IER
  lda #%00000000
  sta PCR
  pla
  rts
