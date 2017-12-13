; I fucking hate restart vectors. If the program hits one for some reason, make the game hang itself
SECTION "Restart1",HOME[$00]
rst $38
SECTION "Restart2",HOME[$08]
rst $38
SECTION "Restart3",HOME[$10]
rst $38
SECTION "Restart4",HOME[$18]
rst $38
SECTION "Restart5",HOME[$20]
rst $38
SECTION "Restart6",HOME[$28]
rst $38
SECTION "Restart7",HOME[$30]
rst $38
SECTION "Restart8",HOME[$38]
rst $38 ; lol
SECTION "VblankJump",HOME[$40] ; Used for Vblank int
jp vblank ; Jump to Vblank handler
SECTION "GameBoot",HOME[$100] ; Game jumps here on boot
di ; ewwwwwwww interupts before init
jp start ; Jump to init
rept $150 - $104
db $00 ; RGBFIX likes header to be zero.
endr
SECTION "VblankHandler",HOME ; Handle VBLANK
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
