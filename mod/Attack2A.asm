if !_Optimize


;Attack Type 2A (% of Max HP)
;Param1: Element
;Param2: Fraction/16
;Param3: HP Leak Duration
;
;**optimize: remove Second Param3 load
Attack2A:
	LDA Param1						;C2/6E2D: A5 57        LDA $57
	STA AtkElement						;C2/6E2F: 85 4D        STA $4D
	JSR ElementDamageModMag2				;C2/6E31: 20 B5 87     JSR $87B5  (Magic Attack Element Modifiers (ii))
	LDA AtkMissed						;C2/6E34: A5 56        LDA $56
	BNE .Ret						;C2/6E36: D0 13        BNE $6E4B
	JSR CalcDamageMaxHP					;C2/6E38: 20 4E 8A     JSR $8A4E  (Calculate Damage from % of Target Max HP)
	LDA Param3						;C2/6E3B: A5 59        LDA $59
	BEQ .Ret						;C2/6E3D: F0 0C        BEQ $6E4B
if not(!_Optimize)
	LDA Param3						;C2/6E3F: A5 59        LDA $59
endif
	STA StatusDuration					;C2/6E41: 8D D8 3E     STA $3ED8   (Status Duration = Parameter 3)
	LDA #$08		;HP Leak			;C2/6E44: A9 08        LDA #$08
	STA Param3						;C2/6E46: 85 59        STA $59
	JSR ApplyStatus4					;C2/6E48: 20 05 8E     JSR $8E05   (Apply Status Effect 4)
.Ret	RTS 							;C2/6E4B: 60           RTS 

endif