if !_Fixes || !_Optimize || !_CombatTweaks 

incsrc "mod/utility/damageutil.asm"

;Swords damage formula
;Tweaks: Added Power Drink fix and refactored a bit for some code reuse
SwordDamage:
	JSR LoadAttackPower		;*Load Attack Power including Power Drinks
	TAX 	        		;
	STX $0E	        		;
	JSR ShiftDivide_8		;(Divide by 8)
	LDX #$0000			;
	JSR Random_X_A			;
	REP #$21			;
	ADC $0E    			;(Attack Power + (0..(Attack Power/8))
	STA Attack    			;
	JMP StrDamageCalc		;use standard strength damage routine to finish


endif
