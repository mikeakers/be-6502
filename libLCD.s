init_lcd:
  pha

  lda #%00000010  ; set 4 bit operation
  ; This is the only instruction we send to the LCD in 8-bit mode, so we just raw dog it instead of
  ; calling send_instruction
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

  ; move high nibble to low half
  lsr
  lsr
  lsr
  lsr

  ; toggle E to clock in high nibble
  sta PORTB
  ora #E
  sta PORTB
  and #%00001111
  sta PORTB

  pla             ; pop back full instruction
  and #%00001111  ; mask out high nibble (may not be strictly neccessary)

  ; toggle E to clock in low nibble
  sta PORTB
  ora #E
  sta PORTB
  and #%00001111
  sta PORTB

  pla
  rts

print_char:
  jsr lcd_wait
  pha
  pha             ; hold onto an extra copy of char to print

  ; Move high nibble to low half
  lsr
  lsr
  lsr
  lsr

  ; Send high nibble to LCD
  ora #RS
  sta PORTB
  ora #E
  sta PORTB
  and #%00001111
  ora #RS
  sta PORTB

  pla             ; Restore full char
  and #%00001111  ; mask out low nibble

  ; Send high nibble to LCD
  ora #RS
  sta PORTB
  ora #E
  sta PORTB
  and #%00001111
  ora #RS
  sta PORTB

  pla
  rts

clear_display:
  pha
  lda #%00000010  ; Clear display
  jsr send_instruction
  pla
  rts

lcd_wait:
  pha
  lda #%11110000  ; High nibble of PORTB to output, low nibble to input
  sta DDRB        ; Set DDRB
lcdbusy:
  ; Read high nibble
  lda #RW
  sta PORTB
  lda #(RW | E)
  sta PORTB
  lda PORTB

  pha             ; High nibble contains our busy flag, so stash it in the stack

  ; read low nibble
  lda #RW
  sta PORTB
  lda #(RW | E)
  sta PORTB
  lda PORTB

  pla             ; Bring back high nibble
  and #%00001000  ; Check busy flag
  bne lcdbusy     ; Repeat check if stil busy

  ; Clean up, restore port b to all outputs
  lda #RW
  sta PORTB
  lda #%11111111  ; Port b to output
  sta DDRB

  pla
  rts
