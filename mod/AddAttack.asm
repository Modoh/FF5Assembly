if !_Fixes || !_CombatTweaks 

incsrc "mod/utility/damageutil.asm"

;Increase Attack (Power Drink)
;Changing it from updating $2044 and $2045 which are only used by goblin punch
;Instead it now updates $2079 which seems is unused and initialized to zero 
AddAttack:
	LDX TargetOffset
	CLC 
	LDA CharStruct.DrinkAtk_Bugfix,X	;*new memory location for power drinks
	ADC Param3
	BCC +
	LDA #$FF    			;max 255
+	STA CharStruct.DrinkAtk_Bugfix,X
	RTS		


endif