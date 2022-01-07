; ----------------------------------------------
;| Multi-Fonts Patch (Expanded ROM)				|
;| Version 1.4.1								|
;| Released on 03/17/2017						|
; ----------------------------------------------

hirom
;header

; Used for branching
brn_406B = $C1406B
brn_43C9 = $C143C9

;------------------------------------------------------------------------
; Bank $C1 VWF Offsets calculation function (Battle menu)
;------------------------------------------------------------------------

org $C1611B
JSL sub_611B        ; Set VWF offset (bank $C0)

;------------------------------------------------------------------------
; Bank $C1 FWF functions changes (Battle menu)
;------------------------------------------------------------------------

org $C14061         ; In $C1403F function
JSL sub_4061        ; Set Font graphic offset (bank $C0)
BRA brn_406B        ; Continue

org $C140D6         ; In $C1403F function
JSL sub_40D6        ; Set Font graphic offset low bytes (bank $C0)

org $C140E1         ; In $C1403F function
JSL sub_40E1        ; Set Font graphic offset bank byte (bank $C0)

org $C143BF         ; In $C143B9 function
JSL sub_43BF        ; Set Font graphic offset (bank $C0)
BRA brn_43C9        ; Continue

;------------------------------------------------------------------------
; Bank $C1 VWF functions changes (Battle dialogues and messages)
;------------------------------------------------------------------------

org $C16152         ; In $C16141 function
JSL load_VWF1       ; Load Font graphic Y (bank $C0)

org $C16158         ; In $C16158 function
JSL load_VWF1       ; Load Font graphic Y (bank $C0)

org $C161D9         ; In $C161C4 function
JSL load_VWF1       ; Load Font graphic Y (bank $C0)

org $C16231         ; In $C161C4 function
PHY                 ; Save Index
LDA $ECF0           ; ?
SEC                 ; Set Carry Flag for subtraction
SBC #$60
TAY                 ; Index subtraction result
LDA [$15],Y         ; Load VWF cell width Y
PLY                 ; Restore previous Index
NOP                 
NOP

org $C1628A         ; In $C16279 function
JSL load_VWF1       ; Load Font graphic Y (bank $C0)

org $C16290         ; In $C16290 function
JSL load_VWF1       ; Load Font graphic Y (bank $C0)

org $C1631C         ; In $C16307 function
JSL load_VWF1       ; Load Font graphic Y (bank $C0)

org $C1637E         ; In $C1637B function
PHY                 ; Save Index
LDA $ECF0           ; ?
SEC                 ; Set Carry Flag for subtraction
SBC #$60            ; ?
TAY                 ; Index subtraction result
LDA [$15],Y         ; Load VWF cell width Y
PLY                 ; Restore previous Index
NOP
NOP