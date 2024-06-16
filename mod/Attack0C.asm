includeonce

if !_Optimize

;Attack Type 0C (Flare w/HP Leak)
;Param1: Element
;Param2: Spell Power
;Param3: HP Leak Duration
%subdef(Attack0C)
	JSR CheckAegis 						;C2/6A07: 20 97 7C     JSR $7C97    (Aegis Shield Check)
	LDA AtkMissed						;C2/6A0A: A5 56        LDA $56
	BNE .CheckNull						;C2/6A0C: D0 26        BNE $6A34
	LDA Param1						;C2/6A0E: A5 57        LDA $57
.Element
	STA AtkElement						;C2/6A10: 85 4D        STA $4D
	JSR FlareMagicDamage					;C2/6A12: 20 6A 7F     JSR $7F6A    (Flare Magic Damage Formula)
	JSR MultiTargetMod 					;C2/6A15: 20 66 83     JSR $8366    (Multitargetting modifier to Damage)
	JSR TargetStatusModMag					;C2/6A18: 20 F3 84     JSR $84F3    (Target Status Effect Modifiers to Magic Damage)
	JSR ElementUpMod					;C2/6A1B: 20 6D 86     JSR $866D    (Magic Element Up Modifier to Damage)
	JSR ElementDamageModMag					;C2/6A1E: 20 6E 87     JSR $876E    (Magic Element Modifier to Damage)
	LDA AtkMissed						;C2/6A21: A5 56        LDA $56
	BNE .CheckNull						;C2/6A23: D0 0F        BNE $6A34
	JSR CalcFinalDamage					;C2/6A25: 20 05 8A     JSR $8A05    (Calculate Magic Final Damage)
	LDA Param3						;C2/6A28: A5 59        LDA $59
	BEQ .CheckNull			;skip status if duration is 0
	STA StatusDuration					;C2/6A2A: 8D D8 3E     STA $3ED8    (Status Duration = Parameter 3)
	LDA #$08			;HP Leak		;C2/6A2D: A9 08        LDA #$08
	STA Param3						;C2/6A2F: 85 59        STA $59
	JSR ApplyStatus4					;C2/6A31: 20 05 8E     JSR $8E05    (Apply Status Effect 4)
.CheckNull
	LDA MagicNull						;C2/6A34: AD 97 7C     LDA $7C97
	BEQ .Ret						;C2/6A37: F0 02        BEQ $6A3B
	STZ AtkMissed						;C2/6A39: 64 56        STZ $56
.Ret	RTS 							;C2/6A3B: 60           RTS 


endif
