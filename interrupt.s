value = $0200 ; 2 bytes
mod10 = $0202 ; 2 bytes
message = $0204 ; 6 bytes
counter = $020a ; 2 bytes

  .org $8000

  include "libVIA.s"
  include "libLCD.s"

reset:
  ldx #$ff
  txs
  cli

  jsr init_via
  jsr init_lcd

  lda #0
  sta counter
  lda #0
  sta counter + 1

loop:
  jsr clear_display

  lda #0
  sta message

  ; Initialize value to be the number to convert
  ; sei
  lda counter
  sta value
  lda counter + 1
  sta value + 1
  ; cli

divide:
  ; Initialize the remainder to zero
  lda #0
  sta mod10
  sta mod10 + 1
  clc

  ldx #16

divloop:
  ; Rotate quotient and remainder
  rol value
  rol value + 1
  rol mod10
  rol mod10 + 1

  ; a,y = dividend - devisor
  sec
  lda mod10
  sbc #10
  tay ; save low byte in Y
  lda mod10+1
  sbc #0
  bcc ignore_result ; branch if dividend < devisor
  sty mod10
  sta mod10 + 1

ignore_result:
  dex
  bne divloop
  rol value ; shift in the last bit of the quotient
  rol value + 1

  lda mod10
  clc
  adc #"0"
  jsr  push_char

  ; if value != 0, then continue dividing
  lda value
  ora value + 1
  bne divide ; branch if value not equal to 0

  ldx #0
print:
  lda message,x
  beq loop
  jsr print_char
  inx
  jmp print

; Add the character in the A register to the beginning of the 
; null-terminated string `message`
push_char:
  pha ; Push new first char onto stack
  ldy #0

char_loop:
  lda message,y ; Get char on the string and put into X
  tax
  pla
  sta message,y ; Pull char off stack and add it to the string
  iny
  txa
  pha           ; Push char from string onto stack
  bne char_loop

  pla
  sta message,y ; Pull the null off the stack and add to the end of the string

  rts

nmi:
irq:

  inc counter
  bne exit_irq
  inc counter + 1
exit_irq:  
  rti

  .org $fffa
  .word nmi
  .word reset
  .word irq
