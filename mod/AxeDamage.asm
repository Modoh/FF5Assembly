if !_Fixes || !_Optimize || !_CombatTweaks 

incsrc "mod/utility/damageutil.asm"

;Axes Damage formula
;Tweaks: Power Drink fix, size optimization

;Attack = Attack Power / 2 + 0..Attack Power
;M = Level*Strength/128 + 2
;Defense = Target Defense / 4
AxeDamage:
	JSR LoadAttackPower	;*Load Attack Power including Power Drinks
	TAX 
	STX $0E
	LSR $0E      		;(Attack Power/2)
	LDX #$0000		;
	JSR Random_X_A		;(0..Attack Power)
	REP #$21		;also clears carry
	ADC $0E      		;(Attack Power/2) + (0..Attack Power)
	STA Attack		
	JSR StrDamageCalc	;use standard strength damage routine
	LSR Defense
	LSR Defense 		;Defense/4
	RTS 	
	
endif