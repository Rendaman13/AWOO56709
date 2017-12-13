; I fucking hate restart vectors. If the program hits one for some reason, make the game hang itself
SECTION "Restart1",ROM0[$00]
rst $38
SECTION "Restart2",ROM0[$08]
rst $38
SECTION "Restart3",ROM0[$10]
rst $38
SECTION "Restart4",ROM0[$18]
rst $38
SECTION "Restart5",ROM0[$20]
rst $38
SECTION "Restart6",ROM0[$28]
rst $38
SECTION "Restart7",ROM0[$30]
rst $38
SECTION "Restart8",ROM0[$38]
rst $38 ; lol
SECTION "VblankJump",ROM0[$40] ; Used for Vblank int
jp vblank ; Jump to Vblank handler
SECTION "GameBoot",HOME[$100] ; Game jumps here on boot
di ; ewwwwwwww interupts before init
jp start ; Jump to init
rept $150 - $104
db $00 ; RGBFIX likes header to be zero.
endr
SECTION "VblankHandler",ROM0 ; Handle VBLANK
push af
push bc
push de
push hl ; Preserve everything. Don't want any unexpected register changes
call mapupdate ; Update dat shit
pop hl
pop de
pop bc
pop af
reti ; Return w/ints
