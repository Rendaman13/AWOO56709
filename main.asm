; Epsilon, 2017
INCLUDE "header.asm"
INCLUDE "tileset.asm"
INCLUDE "hardware_constants.asm"
_oam EQU $FE00
_oamlength EQU $A0
_ram EQU $C000
_ramlength EQU $2000
_vram EQU $8000
_xlocation EQU _ram
_ylocation EQU _ram + 1
_srframecounter EQU _ram + 2
_joypad EQU _ram + 3
_justreleased EQU _ram + 4
_tilemap EQU _ram + 5 ; This is just where the tilemap starts
_b EQU 1
_a EQU 1 << 1
_select EQU 1 << 2
_start EQU 1 << 3
_right EQU 1 << 4
_left EQU 1 << 5
_up EQU 1 << 6
_down EQU 1 << 7 
_srcombo EQU _select | _b | _start
SECTION "Init",ROM0[$150] ; Here we go
start:
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
gametick: ; TIL RGBDS hates whitespace.
  halt ; Helps wth battery consumption
  nop ; Prevents a certain glith with halt
  call joypadpoll ; Polls joyinput
  call srsdetect ; Detects if SR inputs are being held down
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
vramwipe: ; Yeah basically the same as ramwipe except HL is VRAM
    ld hl,_vram ; Like I said, HL is vram
    ld bc,_ramlength ; 16 bit counter
.loop
    xor a ; a = 0
    ldi [hl],a ; Load a int HL, increment HL
    dec bc
    ld a,b
    or c 
    jr nz,.loop ; You're a mean one, Mr.LOOP
    ret
tilesetload: ; Lol I almost forgot this one
  ld hl,Tileset ; Load tileset location into hl
  ld de,_vram ; Vram is now in de
  ld bc,16*2 ; each tile is 16 bytes long, and I only have two of them.
.loop
  ldi a,[hl] ; Nab current tile byte
  ld [de],a ; Throw that shit into vram
  inc de ; Increment de
  dec bc ; Decrement counter
  ld a,b
  or c
  jr nz,.loop
  ret
joypadpoll: ;  MAI FAVORITE!!!
  xor a ; a = 0
  ld [_justreleased],a ; I only want justreleased to display for a frame or 2
  ld a,%11011111 ; Set all of A's bits except 5, we're polling for button inputs
  ld [rJOYP],a ; Tell the Joypad hardware register to wake the fuck up and poll for button inputs
  rept 5
  ld a,[rJOYP] ; Poll input, 5 times for accuracy
  endr
  cpl ; Need this because for some eason the GB's hardware resets bits if they are pressed instead of setting them. A set bit is much more convienent then a reset bit
  and %1111 ; Nab the lower four bits for input
  ld b,a ; Backup result, we'll need t later
  ld a,%11101111 ; Now we reset bit four to poll for directional inputs
  ld [rJOYP],a ; Sets the joypad hardware register to check for bit 4
  rept 5
  ld a,[rJOYP] ; Polls input, 5 times for accuracy
  endr
  cpl ; See above
  and %1111 ; See above
  swap a ; This is to make directional inputs distinguishable from button inputs
  or b ; Add polled button inputs. Result is now in a.
  ; Normally, we would be done here. But I wanted to take an extra step
  ld hl,_joypad ; Takes whatever the joypad value was at last
  cp [hl] ; Compares the current value with the current set joypad value
  call nz,releasedetected ; Not the same? User released a button. Act accordingly/
  ld [hl],a ; Put result into joypad address
  ret ; Done
releasedetected:
  push af ; I need that later
  ld a,[hl] ; Get last joypad input
  ld [_justreleased],a ; Move it into justreleased
  pop af ; I needed it
  ret ; Bye
srsdetect: ; With joypad inputs, we can now check if the user wants a soft reset. This is done with START+SELECT+B
  ld a,[_joypad]
  and _srcombo
  ret ; Too lezzeh
cursorupdate:
  ret ; Too lezzeh
mapupdate:
  ret ; Too lezzeh
  
