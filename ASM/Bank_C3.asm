; ----------------------------------------------
;| Multi-Fonts Patch							|
;| Version 1.4.1								|
;| Released on 03/17/2017						|
; ----------------------------------------------

hirom
;header

;------------------------------------------------------------------------
; Bank $C3 FWF functions changes (Menus)
;------------------------------------------------------------------------

org $C36B1B         ; In $C36B13 function (Upload BG3 font graphics)
JSL sub_6B1B        ; Set Font graphic offset (bank $C0)
brn_6B1F:
LDA [$E0],Y         ; Font graphics
STA $2118           ; Save in VRAM
INY                 ; Index +1
INY                 ; Index +1
CPY #$1000          ; Check if 256th tile
BNE brn_6B1F        ; Loop if not
brn_6B2B:
STA $2118           ; Clear desc GFX
INY                 ; Index +1
CPY #$1400          ; Check if 128th tile
BNE brn_6B2B        ; Loop if not

org $C36B55         ; In $C36B37 function (Upload BG1 font graphics)
JSL sub_6B55        ; Set Font graphic offset (bank $C0)
brn_6B5A:
LDX #$0008          ; 8-px rows: 8
brn_6B5C:
LDA [$E0],Y         ; Font GFX row
STA $2118           ; Save in VRAM
INY                 ; Index +1
INY                 ; Index +1
DEX                 ; One less row
BNE brn_6B5C        ; Loop till last

org $C36B7E         ; In $C36B37 function (Upload BG1 font graphics)
CPY #$0F80          ; Check if 248th tile
BNE brn_6B5A        ; Loop if not

;------------------------------------------------------------------------
; Bank $C3 VWF functions changes (Menu descriptions)
;------------------------------------------------------------------------

org $C3A8D5         ; In $C3A8B1 function (Load VWF character's graphics into string)
JSL sub_A8D5        ; Set Font graphic offset (bank $C0)
ADC $ED             ; Add VRAM index
TAX                 ; Set RAM index
brn_A8DB:
REP #$20            ; 16-bit Accumulator
PHX                 ; Save RAM index
LDA [$E0],Y         ; 12-px row GFX
org $C3A93D
BNE brn_A8DB        ; Loop value adjustment

org $C3A944         ; In $C3A8B1 function (Add character's width to line total)
TAY                 ; Index Text character
JSL sub_A945        ; Set Font cell width offset (bank $C0)
CLC                 ; Clear Carry for addition
ADC [$E0],Y         ; Add char width

;------------------------------------------------------------------------
; Bank $C3 Font menu option code
;------------------------------------------------------------------------

org $C322D0         ; In $C322C5 function (Sustain Config menu)
CMP #$09            ; Row 9 will now indicate if a down press trigger Config 2 screen

org $C3386B         ; In navigation data table for Config 1
db $0A              ; We now have 10 rows instead of 9

org $C33A40         ; In $C33A21 function (Scroll to Config 1)
LDA #$09            ; New row we are landing on in Config 1 when coming from Config 2

org $C32347         ; In $C32342 function (handle clicks on Config 2)
JMP (ClickTable,X)  ; Use relocated table (to make room for an extra Config 1 click)

org $C33861         ; In $C3385E function (Handle D-Pad for Config 1)
LDY #CursorTable    ; Use relocated table

org $C349A1         ; In positioned text table for Config page 1
                    ; Use relocated "Config" space to put two new text pointers
dw FontString       ; "Font" text pointer
dw DefaultString    ; "Default" text pointer
dw AdvanceString        ; "Advance" text pointer

org $C34993         ; In Text pointer table for Config page 1
dw BatModeString    ; "Bat.Mode" string pointer

org $C338CD         ; In $C3389E function (Draw Config menu)
LDY #ConfigString   ; Load relocated text pointer

org $C3393B         ; In $C3389E function (Draw Config menu)
JSR DrawNewStrings  ; Draw "Config", "Font", "Default", "Advance"

org $C33D3D         ; In $C33D2F function (Handle Config changes with D-Pad)
JMP (Config2Opt,X)  ; Handle Config 2 options
JMP (Config1Opt,X)  ; Handle Config 1 options

;------------------------------------------------------------------------
; Bank $C3 Font menu option code Extra space used
;------------------------------------------------------------------------

org $C3F091         ; This could be moved elsewhere in bank $C3
ClickTable:         ; Table that handle clicks on Config 2
dw $2341            ; Mag.Order  (NOP)
dw $2341            ; Window     (NOP)
dw $2388            ; Color
dw $2388            ; R
dw $2388            ; G
dw $2388            ; B

CursorTable:        ; Cursor position table for Config 1
dw $2960            ; Bat.Mode
dw $3960            ; Bat.Speed
dw $4960            ; Msg.Speed  
dw $5960            ; Cmd.Set
dw $6960            ; Gauge
dw $7960            ; Sound
dw $8960            ; Cursor
dw $9960            ; Reequip
dw $A960            ; Controller
dw $B960            ; Font (new entry)

Config1Opt:         ; Jump table for Config 1 options
dw $3D61            ; Bat.Mode
dw $3D7A            ; Bat.Speed
dw $3DAB            ; Msg.Speed
dw $3DE8            ; Cmd.Set
dw $3E01            ; Gauge
dw $3E1A            ; Sound
dw $3E4E            ; Cursor
dw $3E6D            ; Reequip
dw $3E86            ; Controller
dw FontOption       ; Font (new entry)

Config2Opt:         ; Jump table for Config 2 options
dw $3E9F            ; Mag.Order
dw $3ECD            ; Window
dw $3F01            ; Viewed color
dw $3F3C            ; R
dw $3F5B            ; G
dw $3F7A            ; B

ConfigString:
dw $78F9            ; "Config" position
db $82,$A8,$A7,$9F  ; "Config"
db $A2,$A0,$00

BatModeString:
dw $398F            ; "Bat.Mode" position
db $81,$9A,$AD,$C5  ; "Bat.Mode"
db $8C,$A8,$9D,$9E
db $00        

FontString:
dw $3E0F            ; "Font" position
db $85,$A8,$A7      ; "Font"
db $AD,$00

DefaultString:
dw $3E25            ; "Normal" position
db $8D,$A8,$AB,$A6  ; "Normal"
db $9A,$A5,$00    

AdvanceString:
dw $3E35            ; "Advance" position
db $80,$9D,$AF,$9A  ; "Advance"
db $A7,$9C,$9E,$00  

DrawNewStrings:     ; From $C3393B
JSR $41C3           ; Draw RGB info
LDA #$24            ; Palette 1
STA $29             ; Color: Blue
LDY #FontString     ; Text pointer
JSR $02F9           ; Draw "Font"
JMP DrawFontOpt     ; Draw "Normal", "Advance"

FontOption:         ; From jump table Config1Opt, JMP at $C33D40
JSR $0EA3           ; Sound: Cursor
LDA $0B             ; Semi-auto keys
BIT #$01            ; Pushing right?
BNE .sub_loop       ; Branch if so
LDA #$00            ; Font: Normal
JMP ReloadFont      ; Load new Font and redraw text
.sub_loop
LDA #$02            ; Font: Advance
JMP ReloadFont      ; Load new Font and redraw text

ReloadFont:         ; From tag FontOption
STA !SRAM           ; Set option
LDA #$8F            ; BRT: 15 and OFF    
STA $2100           ; Force V-Blank
JSR $6B13           ; BG3 font GFX
JSR $6B37           ; BG1 font GFX
JSR $40EA           ; Redraw wallpaper values
JSR $3A87           ; Refresh skin
JMP DrawFontOpt     ; Draw "Normal", "Advance" when changing option

DrawFontOpt:        ; From tag DrawNewStrings, ReloadFont
LDA !SRAM           ; Load current Font value
BEQ DefaultMode     ; Branch if Normal Font
LDA #$28            ; Color: Gray
JSR DrawDefault     ; Draw "Normal"
LDA #$20            ; Color: User's
BRA DrawAdvance     ; Draw "Advance"

DefaultMode:        ; From tag DrawFontOpt
LDA #$20            ; Color: User's
JSR DrawDefault     ; Draw "Normal"
LDA #$28            ; Color: Gray
BRA DrawAdvance     ; Draw "Advance"

DrawDefault:        ; From tag DefaultMode
STA $29             ; Set palette
LDY #DefaultString  ; Text pointer
JSR $02F9           ; Draw "Normal"
RTS

DrawAdvance:        ; From tag DrawFontOpt, DefaultMode
STA $29             ; Set palette
LDY #AdvanceString  ; Text pointer
JSR $02F9           ; Draw "Advance"
RTS