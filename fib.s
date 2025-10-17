  .org $8000
reset:  
  lda #$FF
  sta $6002

  lda #$01
  tax

  lda #$01
  tay

loop:
  sta $6000

  





  lda $6000
  adc $6001
  tax

  lda $6000
  sta $6001
  txa
  sta $6000

  jmp loop

  .org $fffc
  .word reset
  .word $0000