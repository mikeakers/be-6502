  .org $8000

  include "libVIA.s"
  include "libLCD.s"

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

  .org $fffc
  .word reset
  .word $0000
