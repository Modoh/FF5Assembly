if !_Fixes || !_Optimize || !_CombatTweaks 

incsrc "mod/utility/damageutil.asm"

;Brave Blade Damage formula
;tweaks: Adds a Vit/256 factor to M
BraveDamage:
	JSR LoadAttackPower	;*Load Attack Power including Power Drinks
	SEC 
	SBC BattleData.Escapes   		;(Attack = Attack - # times escaped)
	BCS +			;
	TDC 			;min 0
+	TAX          		
	STX Attack

if !_CombatTweaks
	LDA Vitality  		
	JSR StatTimesLevel 	;Stat * Level, returns in 16 bit mode
	JSR ShiftDivide_256	;/256
	STA M			;
endif

	JMP StrDamageCalc	;*add str and finish up in sword routine

	
endif