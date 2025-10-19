PORTB = $6000
PORTA = $6001
DDRB =  $6002
DDRA =  $6003

E  = %01000000
RW = %00100000
RS = %00010000

  .org $8000

reset:
  ldx #$ff         ; Set stack pointer to top of the stack range 
  tsx
  jsr init_via
  jsr init_lcd

  ; Print our message
  ldx #0
print_loop:
  lda message,x
  beq halt 
  jsr print_char
  inx
  jmp print_loop

halt:
  stp

message: .asciiz "  Hello, 4-bit                            mode! :D" 

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
