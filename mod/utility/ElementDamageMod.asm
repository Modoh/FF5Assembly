includeonce

;Elemental Modifiers for Physical
;
;optimizations: uses shared routine
ElementDamageModPhys:
	JSR ElementDamageMod
	STZ MagicNull		;clear a magic-only flag that could be set in shared routine if enemy was immune

.Ret	RTS 								

;Elemental Damage Modifiers for Magic
;
;optimizations: uses shared routine
;this one only differs from the shared version in that it checks for EBlock
;so we do some checks after the fact to fix things up, unless the attack was absorbed
;there are some side effects to attack/defense that go through even if blocked, but attack is flagged as a miss anyway
ElementDamageModMag:
	JSR ElementDamageMod

	LDA AtkHealed		;only check for EBlock if attack didn't heal
	BNE .Ret
	
	;check for Eblock
	LDA CharStruct.EBlock,X						
	AND AtkElement							
	BEQ .Ret								
	
	;Blocked 
	INC AtkMissed      						
	STZ MagicNull		;another possible side effect of shared routine to undo
	RTS 								

.Ret	RTS

;Elemental Modifiers to Magic
;
;optimizations: uses shared routine

;this one modifies Param2 instead of Attack, but percent damage attacks don't use Attack so we can just patch it
;doesn't clear defense on absorb/weak either but that doesn't matter for percent damage, so we ignore the side effect
ElementDamageModPercent:
	LDA Param2
	TAX
	STX Attack
	
	JSR ElementDamageMod
	
	LDA Attack	;won't ever be near overflowing so 8 bit is fine
	STA Param2

.Ret	RTS 								


ElementDamageMod:
	LDA MagicSword		;ok if magic because won't be loaded	
	BNE .Ret		;Magic Sword Elements handled elsewhere	
	LDX TargetOffset						
	LDA CharStruct.EAbsorb,X 					
	AND AtkElement							
	BEQ .CheckImmune						
	INC AtkHealed							
	STZ Defense   							
	STZ Defense+1 							
	RTS 								
.CheckImmune								
	LDA CharStruct.EImmune,X 					
	AND AtkElement							
	BEQ .CheckHalf							
	INC AtkMissed   						
	INC MagicNull
	RTS 								
.CheckHalf								
	LDA CharStruct.EHalf,X						
	AND AtkElement							
	BEQ .CheckWeak							
	LSR Attack+1     						
	ROR Attack    							
	RTS 								
.CheckWeak								
	LDA CharStruct.EWeak,X 						
	AND AtkElement							
	BEQ .Ret							
	ASL Attack    							
	ROL Attack+1							
	STZ Defense   							
	STZ Defense+1							
.Ret	RTS 								
