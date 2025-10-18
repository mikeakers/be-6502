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

init_via:
  pha
  lda #%11111111  ; set all pins on port B to output
  sta DDRB
  lda #%11100000  ; set top 3 pins on port A to output
  sta DDRA
  pla
  rts

init_lcd:
  pha

  lda #%00000010  ; set 4 bit operation
  sta PORTB
  ora #E
  sta PORTB
  and #%00001111
  sta PORTB


  lda #%00101000  ; 4 bit operation, 2 line display
  jsr send_instruction

  lda #%00001110  ; turn on display and cursor
  jsr send_instruction

  lda #%00000110  ; set mode to increment and shift cursor
  jsr send_instruction

  pla
  rts

send_instruction:
  jsr lcd_wait
  pha
  pha             ; stash away full instruction for later
  lsr             ; move high nibble to low half
  lsr
  lsr
  lsr

  sta PORTB       ; toggle E to clock in high nibble
  ora #E
  sta PORTB
  and #%00001111
  sta PORTB

  pla             ; pop back full instruction
  and #%00001111  ; mask out high nibble (may not be strictly neccessary)

  sta PORTB       ; toggle E to clock in low nibble
  ora #E
  sta PORTB
  and #%00001111
  sta PORTB

  pla
  rts

send_char:
  jsr lcd_wait
  pha
  pha             ; hold onto an extra copy of char to print

  lsr             ; Move high nibble to low half
  lsr
  lsr
  lsr

  ora #RS
  sta PORTB
  ora #E
  sta PORTB
  and #%00001111
  ora #RS
  sta PORTB

  pla
  and #%00001111

  ora #RS
  sta PORTB
  ora #E
  sta PORTB
  and #%00001111
  ora #RS
  sta PORTB

  pla
  rts

lcd_wait:
  pha
  lda #%11110000  ; High nibble of PORTB to output, low nibble to input
  sta DDRB        ; Set DDRB
lcdbusy:
  lda #RW
  sta PORTB
  lda #(RW | E)
  sta PORTB
  lda PORTB       ; Read high nibble
  pha             ; High nibble contains our busy flag, so stash it in the stack
  lda #RW
  sta PORTB
  lda #(RW | E)
  sta PORTB
  lda PORTB       ; read low nibble

  pla
  and #%00001000
  bne lcdbusy

  lda #RW
  sta PORTB
  lda #%11111111  ; Port b to output
  sta DDRB
  pla
  rts
  
  .org $fffc
  .word reset
  .word $0000
