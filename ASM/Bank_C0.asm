; ----------------------------------------------
;| Multi-Fonts Patch							|
;| Version 1.4.1								|
;| Released on 03/17/2017						|
; ----------------------------------------------

hirom
;header         ;comment out if you have a header

!SRAM = $1E1F   ; Font SRAM value: #$00 or #$02

; Used for branching
brn_844B equ $C0844B
brn_8A56 equ $C08A56
rout_851A equ $C0851A
rout_898A equ $C0898A
rout_88D3 equ $C088D3
rout_8642 equ $C08642
rout_8967 equ $C08967

org $C47FB0
incbin originalfonts.bin
;C47FB0-C487AF      Normal Fixed-Width Font
;C487B0-C488AF      Normal Variable-Width Font Character Widths 
;C488B0-C49CAF      Normal Variable-Width Font
incbin gbafonts.bin
;C49CB0-C4A4AF      GBA Fixed-Width Font
;C4A4B0-C4A5AF      GBA Variable-Width Font Character Widths 
;C4A5B0-C4B9AF      GBA Variable-Width Font

org $C0BDF1
JSR init_font       ; Init Font memory byte to #$00

;------------------------------------------------------------------------
; Bank $C0 FWF functions changes (unknown usage)
;------------------------------------------------------------------------

org $C06AE1
LDA #$80
STA $2115
LDX #$7600
STX $2116
LDY $00
LDA !SRAM
TAX
LDA #$C4        
STA $1C
REP #$20
LDA FWF,X
STA $1A
TYX
.sub_loopC
PHX
LDX #$0007
.sub_loop
LDA [$1A],Y
INY
EOR [$1A],Y
STA $2118
LDA [$1A],Y
STA $2119
INY
DEX
BNE .sub_loop

LDA [$1A],Y
INY
EOR [$1A],Y
STA $2118
LDA [$1A],Y
STA $2119
LDY #$0018
.sub_loopB
STZ $2118
STZ $2119
DEY
BNE .sub_loopB

PLX
REP #$21
TXA
ADC #$0010
TAX
TAY
TDC
SEP #$20
CPX #$0080
BEQ rout_6B9C
JMP .sub_loopC

rout_6B9C:  
LDY #$0100
.sub_loop
STZ $2118
STZ $2119
DEY
BNE .sub_loop
TXY
.sub_loopB
PHX
LDX #$0007
.sub_loopC
LDA [$1A],Y
INY
EOR [$1A],Y
STA $2118
LDA [$1A],Y
STA $2119
INY
DEX
CPX #$0000
BNE .sub_loopC
LDA [$1A],Y
INY
EOR [$1A],Y
STA $2118
LDA [$1A],Y
STA $2119
LDY #$0018
.sub_loopD
STZ $2118
STZ $2119
DEY
BNE .sub_loopD
PLX
REP #$21
TXA
ADC #$0010
TAX
TAY
TDC
SEP #$20
CPX #$00A0
BEQ rout_6C56
JMP .sub_loopB

rout_6C56:      
REP #$20
LDA $1A
CLC
ADC #$00D0
STA $1A
SEP #$20
LDX #$0007
LDy $00
.sub_loop
LDA [$1A],Y
INY
EOR [$1A],Y
STA $2118
LDA [$1A],Y
STA $2119
INY
DEX
CPX #$0000
BNE .sub_loop
LDA [$1A],Y
INY
EOR [$1A],Y
STA $2118
LDA [$1A],Y
LDY #$01A0
.sub_loopB
STZ $2118
STZ $2119
DEY
BNE .sub_loopB
SEP #$20
RTS

;------------------------------------------------------------------------
; Bank $C3 FWF empty characters loops (fake beginning of FWF)
;------------------------------------------------------------------------

sub_FWF3:
TDC                 ; Clear Accumulator
.sub_loopB
LDX #$0008          ; 8-px rows: 8
.sub_loop
STA $2118           ; Save in VRAM
INY                 ; Index +1
INY                 ; Index +1
DEX                 ; One less row
BNE .sub_loop       ; Loop till last
STZ $2118           ; Planes 1C, 1D
STZ $2118           ; Planes 2C, 2D
STZ $2118           ; Planes 3C, 3D
STZ $2118           ; Planes 4C, 4D
STZ $2118           ; Planes 5C, 5D
STZ $2118           ; Planes 6C, 6D
STZ $2118           ; Planes 7C, 7D
STZ $2118           ; Planes 8C, 8D
CPY #$780           ; 248th tile?
BNE .sub_loopB      ; Loop if not
RTS

sub_FWF4:
TDC                 ; Clear Accumulator
.sub_loop
STA $2118           ; Save in VRAM
INY                 ; Index +1
INY                 ; Index +1
CPY #$0800          ; Check if 128th tile
BNE .sub_loop       ; Loop if not
RTS

;------------------------------------------------------------------------
; Bank $C0 Text and DTE decoding function
;------------------------------------------------------------------------

org $C08067
JSR get_vwf
LDA $CF
PHA
LDA $CB
LDX $C9
PHA
PHX
STZ $C0
brn_8072:
LDY $00
LDA [$C9],Y
BPL brn_80B0
AND #$7F
ASL A
TAX
LDA $CF
CMP #$80
BEQ brn_8088
LDA #$80
STA $CF
BRA brn_809C
brn_8088:
LDA $C0DFA0,X 
CMP #$7F
BEQ brn_80D2
TAY
LDA [$1A],Y
CLC
ADC $C0
STA $C0
brn_809C:
LDA $C0DFA1,X  
CMP #$7F
BEQ brn_80D2
TAY
LDA [$1A],Y
CLC
ADC $C0
STA $C0
BRA brn_80C6
brn_80B0:
LDY $00
LDA [$C9],Y
CMP #$20       
BCC brn_80DC
CMP #$7F
BEQ brn_80D2
TAY
LDA [$1A],Y
CLC
ADC $C0
STA $C0
brn_80C6:
INC $C9
BNE brn_8072
INC $CA
BNE brn_8072
INC $CB
BRA brn_8072
brn_80D2:
PLX
STX $C9
PLA
STA $CB
PLA
STA $CF
end_sub_8067:
RTS



brn_80DC:
CMP #$1A      
BEQ brn_8118   
CMP #$17
BEQ isCChar    
CMP #$02      
BCC brn_80D2 
CMP #$10       
BCS brn_80D2
DEC A          
DEC A          
STA $4202      
LDA #$25       
STA $4203      
LDA $CF 
BPL brn_80D2 
LDA #$06
STA $1D       
LDX $4216
brn_80FD:
LDA $1602,X    
CMP #$FF      
BEQ brn_80D2      
SEC            
SBC #$60       
TAY
LDA [$1A],Y
CLC            
ADC $C0        
STA $C0        
INX            
DEC $1D      
BNE brn_80FD   
BRA brn_80D2

isCChar:
JSR CChar
BRA brn_80D2

brn_8118:
LDA $0583     
STA $4202
LDA #$0D       
STA $4203
LDA $CF
BPL brn_80D2
LDA #$0C 
STA $1D
LDX $4216
brn_812E:
LDA $D2B301,X  
CMP #$FF   
BEQ brn_80D2 
SEC 
SBC #$60
TAY
LDA [$1A],Y
CLC
ADC $C0
STA $C0
INX
DEC $1D
BNE brn_812E
BRA brn_80D2

org $C0840F
CMP #$1B
BEQ brn_exitA
CMP #$17
BNE brn_844B
brn_exitA:
JMP $829D

org $C08274
JSR rout_84D0

org $C0827E
JSR rout_84D0

org $C08454
JSR rout_84D0

org $C08460
JSR rout_84D0

org $C0848A
rout_848A:
LDA #$7E                        
STA $2183
LDX #$9E00
STX $2181
LDY $00
JSR get_vwf
.sub_loopB
LDA [$1A],Y                     
STA $2180
INY
CPY #$0080
BNE .sub_loopB
LDX $00
TXY
.sub_loop
STZ $1D
LDA $C0DFA0,X
TAY
LDA [$1A],Y                     
STA $1D
INX 
LDA $C0DFA0,X
TAY
LDA [$1A],Y                     
CLC
ADC $1D
STA $2180
INX 
CPX #$0100
BNE .sub_loop
RTS

rout_84D0:
JSR get_vwf
TYX
LDY $CD                         
LDA [$1A],Y                     
CLC
TXY 
ADC $BF
CMP $C8                         
BCC rout_84E1
JMP rout_851A

rout_84E1:
JSR $898A           
JSR $88D3
JSR $8642
JSR get_vwf
LDX $C1
STX $C3
INC $C5
LDY $CD
LDA $BF
AND #$0F
CLC
ADC [$1A],Y                     
AND #$F0
BEQ brn_850E
JSR $8967
REP #$21
LDA $C1
ADC #$0020
STA $C1
TDC 
SEP #$20                        
brn_850E:
LDY $CD
LDA $BF
CLC
ADC [$1A],Y                     
STA $BF
RTS

org $C08A4E
JMP rout_8B23

org $C08A53
JMP rout_8B42

org $C08A56
rout_8A56:
EOR $02  
CLC
ADC #$05
STA $1E
STZ $1F
JSR get_vwf_B  
REP #$20  
TXY
LDX $00
PHX
.sub_loop
LDX $1E
LDA [$1A],Y 
.sub_loopB
ASL A
DEX 
BNE .sub_loopB
INY
INY
PLX
STA $9003,X
LSR A
STA $9045,X
INX
INX
PHX
CPX #$0016
BNE .sub_loop
PLX 
SEP #$20      
TDC            
PHA
PLB           
RTS

rout_8B23:
JSR get_vwf_B  
REP #$20   
TXY
LDX $00
.loop
LDA [$1A],Y 
STA $9003,X
LSR A
STA $9045,X
INX
INX
INY 
INY 
CPX #$0016
BNE .loop
TYA
TXY
TAX
TDC 
SEP #$20     
TDC          
PHA
PLB          
RTS

rout_8B42:
SEC 
SBC #$04
STA $1E
STZ $1F
JSR get_vwf_B
REP #$20     
TXY
LDX $00
.loop
LDA [$1A],Y 
PHY
LDY $1E
.loop_B
LSR A
ROR $9023,X 
DEY
BNE .loop_B
STA $9003,X
LSR A
STA $9045,X
LDA $9023,X
ROR A
STA $9065,X
PLY
INY
INY
INX
INX
CPX #$0016
BNE .loop
TDC 
SEP #$20      
TDC 
PHA
PLB
RTS

;------------------------------------------------------------------------
; Fonts Offsets tables
;------------------------------------------------------------------------

VWF:
dw $87B0
dw $A4B0

VWF2:
dw $88B0
dw $A5B0

FWF:
dw $82F0
dw $9FF0

FWF2:
dw $77B0
dw $94B0

FWF3:
dw $7FB0
dw $9CB0

;------------------------------------------------------------------------
; Centring Control Character code (OP#$17)
;------------------------------------------------------------------------

CChar:
LDA $BF         ; Load current line position
CMP #$04        ; Beginning of line
BNE brn_exitB   ; Branch if we are not at the start of a line
STZ $3F         ; Current word length: 0
sub_loop:
LDY $00         ; Current dialogue character: pointer + 0
LDA [$C9],Y     ; Load dialogue character
BPL notDTE      ; Branch if not DTE
AND #$7F        ; Isolate DTE ID
ASL A           ; Multiply by 2
TAX             ; Index it
LDA $CF         ; Load text buffer byte
CMP #$80        ; Check if buffer is empty
BEQ .sub_loopB  ; branch if buffer is empty
LDA #$80        ; 
STA $CF         ; Set buffer as not empty
BRA secondDTE   ; Verify second DTE character
.sub_loopB
LDA $C0DFA0,X	; Load DTE character 1 			
TAY             ; Transfer A to X
LDA [$1A],Y     ; Load width for variable font cell
CLC             ; Prepare addition (no carry)
ADC $3F         ; Add font cell width to sentence width
STA $3F         ; Save as sentence width
secondDTE:
LDA $C0DFA1,X   ; Load DTE character 2
TAY             ; Save character index
LDA [$1A],Y     ; Load width for variable font cell
CLC             ; Prepare addition (no carry)
ADC $3F         ; Add font cell width to sentence width
STA $3F         ; Save as sentence width
BRA checkEol    ; Check end of line an increment pointer if necessary

notDTE:
LDY $00         ; Clear Index
LDA [$C9],Y     ; Load dialogue character
CMP #$01        ; Is it new line character?
BEQ calcMiddle  ; branch if so (calculate center)
CMP #$11        ; Is it end parameter character?
BEQ calcMiddle  ; branch if so (calculate center)
CMP #$12        ; Is it end parameter character?
BEQ calcMiddle  ; branch if so (calculate center)
CMP #$13        ; Is it end of page character?
BEQ calcMiddle  ; branch if so (calculate center)
CMP #$20        ; Is the character a character code?
BCC incDialog   ; Branch if so (increment dialogue pointer and loop)
TAY             ; Save character index
LDA [$1A],Y     ; Load width for variable font cell
CLC             ; Prepare addition (no carry)
ADC $3F         ; Add font cell width to sentence width
STA $3F         ; Save as sentence width
checkEol:
CMP #$E0        ; Compare to line max width
BCS brn_exitB   ; we have ended the line, there's nothing to center...
incDialog:
INC $C9         ; Increment dialogue
BNE sub_loop
INC $CA
BNE sub_loop
INC $CB
BRA sub_loop
brn_exitB:      
RTS

calcMiddle:
LDA #$E0        ; Load line width
SBC $3F         ; Subtract sentence width
LSR A           ; Divide by 2
STA $BF         ; Store as position in line
TAY
STY $4204       ; Whatever is left, store as to be divided
LDA #$10 
STA $4206       ; Divide Y by 16
NOP
NOP
NOP
NOP
NOP
NOP
NOP
LDA $4214      ; Load the division result
STA $4202      ; Store as a multiplier
LDA #$20      
STA $4203      ; Multiply previous result by 32
NOP
NOP
NOP
LDA $4216      ; Get the multiplication result
ADC $C1
STA $C1
BRA brn_exitB      

;------------------------------------------------------------------------
; Bank $C0 Fonts offset calculation functions (used in bank $C0)
;------------------------------------------------------------------------

get_vwf:
PHX             ; Save X
LDA #$C4        ; Load Font bank
STA $1C         ; Store in temp RAM
TDC
LDA !SRAM       ; Load selected Font value; #$00 or #$02
REP #$20        ; 16-bit Accumulator
TAX             ; Index Font value          
LDA VWF,X       ; Load Font low bytes
STA $1A         ; Store in temp RAM
PLX             ; Restore X
SEP #$20        ; 8-bit Accumulator
TDC
RTS

get_vwf_B:
JSR get_vwf     ; Load selected VWF original offset
REP #$20        ; 16-bit Accumulator
LDA $1A         ; Load font low bytes
SEC             ; Set Carry Flag
SBC #$01C0      ; Adjust offset
STA $1A         ; Save as font L-M bytes
RTS

init_font:      ; From $C0BDF1
STZ $1E1F       ; Init font memory byte
STZ $1A69       ; Leftover code (set esper's collected byte 1 to 0)
RTS

;------------------------------------------------------------------------
; Bank $C1 FWF offset setting functions (Battle Menu)
;------------------------------------------------------------------------

sub_4061:       ; From $C14061
STX $36         ; Extra code we needed to make room for
JMP sub_FWF1    ; Load Font graphic offset X

sub_43BF:       ; From $C143BF
STX $10         ; Extra code we needed to make room for
JMP sub_FWF1    ; Load Font graphic offset X

sub_FWF1:       ; From sub_4061, sub_43BF 
TDC             ; Clear Accumulator
LDA !SRAM       ; Load Font memory byte (#$00 = default, #$02 = GBA)
REP #$20        ; 16-bit Accumulator
TAX             ; Index Font memory bytes
LDA FWF2,X      ; Load Font graphic offset low bytes
TAX             ; Index Font graphic offset low bytes
TDC             ; Clear Accumulator
SEP #$20        ; 8-bit Accumulator
RTL

sub_40D6:       ; From $C140D6
PHA             ; Save Accumulator (for future addition)
TDC             ; Clear Accumulator
SEP #$20        ; 8-bit Accumulator
LDA !SRAM       ; Load Font memory byte (#$00 = default, #$02 = GBA)
REP #$20        ; 16-bit Accumulator
TAX             ; Index Font memory bytes
LDA FWF2,X      ; Load Font graphic offset low bytes
STA $14         ; Store Font graphic offset low bytes in temp RAM
PLA             ; Restore Accumulator
CLC             ; Clear carry for addition
ADC $14         ; Add Font graphic offset
RTL

;------------------------------------------------------------------------
; Bank $C1 VWF offset setting functions (Battle dialogues and messages)
;------------------------------------------------------------------------

sub_611B:
PHX             ; Save Index
LDA #$C4        ; Load Font bank
STA $17         ; Save Font bank in temp RAM (for cell width offset)
STA $20         ; Save Font bank in temp RAM (for Font graphic offset)
TDC             ; Clear Accumulator
LDA !SRAM       ; Load Font memory byte (#$00 = default, #$02 = GBA)
REP #$20        ; 16-bit Accumulator
TAX             ; Index Font memory bytes   
LDA VWF,X       ; Load Font cell width offset low bytes
STA $15         ; Save Font cell width offset low bytes in temp RAM
LDA VWF2,X      ; Load Font graphic offset low bytes
STA $1E         ; Save Font graphic offset low bytes in temp RAM
SEP #$20        ; 8-bit Accumulator
PLX             ; Restore previous Index
LDA #$16        ; $C16117 leftover code 
STA $24
RTL

load_VWF1:      ; From $C16152, $C16158, $C161D9, $C1628A, $C16290, $C1631C
PHY             ; Save Index
TXY             ; Original code use Index X and we need Y
LDA [$1E],Y     ; Load Font graphic Y
PLY             ; Restore previous Index
RTL

;------------------------------------------------------------------------
; Bank $C3 FWF offset setting functions (Menus)
;------------------------------------------------------------------------

sub_6B1B:       ; From $C36B1B
JSR sub_FWF2    ; Set Font graphic offset
STA $E0         ; Save Font graphic offset low bytes in temp RAM
JSR sub_FWF4
RTL

sub_6B55:       ; From $C36B55
JSR sub_FWF2    ; Set Font graphic offset
CLC             ; Clear Carry for addition
ADC #$0080      ; Adjust FWF2 table offset 
STA $E0         ; Save Font graphic offset low bytes in temp RAM
JSR sub_FWF3
RTL

sub_FWF2:       ; From sub_6B1B, sub_6B55
TDC
SEP #$20        ; 8-bit Accumulator
LDA #$C4        ; Load Font bank
STA $E2         ; Save Font bank in temp RAM
TDC             ; Clear Accumulator
LDA !SRAM       ; Load Font memory byte (#$00 = default, #$02 = GBA)
REP #$20        ; 16-bit Accumulator
TAX             ; Index Font memory bytes           
LDA FWF2,X      ; Load font graphic offset low bytes
LDY $00
RTS

;------------------------------------------------------------------------
; Bank $C3 VWF offset setting functions (Menu descriptions)
;------------------------------------------------------------------------
 
sub_A8D5:       ; From $C3A8D5
PHA             ; Save Accumulator (continue operation later)
SEP #$20        ; 8-bit Accumulator
LDA #$C4        ; Load font bank
STA $E2         ; Save Font bank in temp RAM
TDC             ; Clear Accumulator
LDA !SRAM       ; Load Font memory byte (#$00 = default, #$02 = GBA)
REP #$20        ; 16-bit Accumulator
TAX             ; Index Font memory bytes           
LDA VWF2,X      ; Load font graphic offset low bytes
STA $E0         ; Save Font graphic offset low bytes in temp RAM
PLA             ; Restore Accumulator (continue previous operation)
CLC             ; Clear Carry for addition
RTL

sub_A945:       ; From $C3A945
LDA !SRAM       ; Load selected Font value; #$00 or #$02
REP #$20        ; 16-bit Accumulator
TAX             ; Index Font memory bytes           
LDA VWF,X       ; Load font cell width offset low bytes
STA $E0         ; Save Font cell width offset low bytes in temp RAM
SEP #$20        ; 8-bit Accumulator
LDA $8D         ; Line width (to be added to char width)
RTL