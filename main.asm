; Epsilon, 2017
INCLUDE "header.asm"
INCLUDE "tileset.asm"
INCLUDE "hardware_constants.asm"
_oam EQU $FE00
_oamlength EQU $A0
_ram EQU $C000
_ramlength EQU $2000
_vram EQU $8000
SECTION "Init",HOME[$150] ; Here we go
Init:
.wait
  ld a,[rSTAT] ; Gets current LCD statistics
  and %11 ; I only care about the mode
  cp 1 ; Mode 1?
  jr nz,.wait ; No? Then keep waiting
  xor a ; a = 0
  ld [rLCDC],a ; Shuts off screen for init
  call oamwipe ; Wipes oam
  call ramwipe ; Wipes ram
  call vramwipe ; Wipes vram
  call tilesetload ; Loads Tileset
  ld a,%11100100 ; Loads desired pallete into a
  ld [rBGP],a
  ld [rOBP0],a
  ld [rOBP1],a ; Sets background and sprite pallete
  xor a ; a = 0
  ld [rNR52],a ; Fuck sound for consuming battery
  ld a,%1 ; Enable only Vblank int
  ld [rIE],a ; Enable Vblank int
  ld a,%10010011 ; Sets certain bits for LCDC
  ld [rLCDC],a ; Turns screen back on
  ei ; Enables Vblank int
 gametick:
  halt ; Helps wth battery consumption
  nop ; Prevents a certain glith with halt
  call joypadpoll ; Polls joyinput
  call srsetect ; Detects if SR inputs are being held down
  call cursorupdate ; Updates cursor accordingly
  jr gametick ; LOOOOOOOOP
 oamwipe:
  ld hl,_oam ; Load OAM location into HL
  ld c,_oamlength ; Used as an 8-bit counter
 .loop
  xor a ; a = 0
  ldi [hl],a ; Load a into HL, increments HL
  dec c ; Decrement counter
  jr nz,.loop ; Counter isn't zero? LOOOOOP
  ret ; We're done here
  ramwipe:
    ld hl,_ram ; Loads RAM location into HL
    ld bc,_ramlength ; 16 bit counter
.loop
    xor a ; a = 0
    ldi [hl],a ; Load a into HL
    dec bc ; Decrement counter
    ld a,b ; Since gbz80 is too fucking stupid to update the z flag in accordance into 16 bit registers, we must compare both registers manually
    or c ; Check if both b and c are zero
    jr nz,.loop ; If they aren't,keep LOOOOPing
    ret ; Dunzo
   vramwipe: ; Yeah basically the same as ramwipe except hL is VRAM
    ld hl,_vram ; Like I said, HL is vram
    ld bc,_ramlength ; 16 bit counter
.loop
    xor a ; a = 0
    ldi [hl],a ; Load a int HL, increment HL
    dec bc
    ld a,b
    or c
    jr nz,.loop ; You're a mean one, Mr.LOOP
 ; Github is shaking the screen and it's triggering me
