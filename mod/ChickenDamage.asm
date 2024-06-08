if !_Fixes || !_Optimize || !_CombatTweaks 

incsrc "mod/utility/damageutil.asm"

;Chicken Knife Damage Formula
;Power Drink fix and refactoring to free space
ChickenDamage:
	LDA BattleData.Escapes		;Flee Count
	LSR				;divide by 2
	JSR LoadAttackPower_DrinkOnly	;*add Power Drink effects (only)
	TAX 
	STX Attack
	LDA Agility			;(Agility)
	JSR StatTimesLevel		;(Level * Agility) 
	JSR ShiftDivide_128    		;(Level * Agility)/128
	STA M      			;
	JMP StrDamageCalc		;*add str and finish up in shared routine
		

endif