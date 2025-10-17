  .org $8000

reset:
  lda #$FF
  sta $6002

loop:
  lda #$01
  sta $6000

  lda #$00
  sta $6000

  jmp loop

  .org $fffc
  .word reset
  .word $0000