PORTB = $6000
PORTA = $6001
DDRB =  $6002
DDRA =  $6003

value = $00 ; 2 bytes
mod10 = $02 ; 2 bytes
message = $04 ; 6 bytes

E  = %01000000
RW = %00100000
RS = %00010000

  .org $8000

reset:
  ldx #$ff         ; Set stack pointer to top of the stack range 
  tsx
  jsr init_via
  jsr init_lcd

  lda #0
  sta message     ; initialize message string with NULL in first location

  lda number      ; Copy number from ROM to ram
  sta value
  lda number + 1
  sta value + 1

divide:
  lda #0          ; initialize remainder
  sta mod10
  sta mod10 + 1

  ldx #16
  clc
divloop:
  ; Rotate quotient and remainder
  rol value       ; value << 1
  rol value + 1
  rol mod10       ; mod10 << 1 with carry from shifting value
  rol mod10 + 1

  ; a,y = dividend - divisor
  sec
  lda mod10
  sbc #10
  tay             ; save low byte in Y
  lda mod10 + 1
  sbc #0
  bcc ignore_result ; branch if dividend < divisor
  sty mod10
  sta mod10 + 1
  
ignore_result:
  dex
  bne divloop
  rol value
  rol value + 1

  lda mod10
  clc
  adc  #"0"
  jsr push_char

  ; if value != 0, then continue dividing
  lda value
  ora value + 1
  bne divide      ; branch if value not 0

  ; prints the null terminated string at message to the lcd
  ldx #0
print:
  lda message,x
  beq end_loop
  jsr print_char
  inx
  jmp print

; inifinite loop to end program
end_loop:
  jmp end_loop

number: .word 31337

; pushes a char to the front of the null terminated string at message
push_char:
  pha
  ldy #0
char_loop:
  lda message,y
  tax
  pla
  sta message,y
  iny
  txa
  pha
  bne char_loop
  pla
  sta message,y
  rts

init_via:
  pha
  lda #%11111111  ; set all pins on port A to output
  sta DDRA
  lda #%11111111  ; set all pins on port B to output
  sta DDRB
  pla
  rts

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
  
  .org $fffc
  .word reset
  .word $0000
