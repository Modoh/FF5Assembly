if !_Optimize

incsrc "mod/utility/damageutil.asm"

;Physical attack but with attack power loaded like a spell
;Attack = Param2 + 0..Param2
;M = Strength*Level/128 + 1
;Defense = Target Defense
;
;**optimize: use 16 bit mode and utility routines
PhysicalParamDamage:
	TDC 							;C2/8261: 7B           TDC 
	TAX 							;C2/8262: AA           TAX 
	LDA Param2   						;C2/8263: A5 58        LDA $58      (Spell Power)
	TAY
	STY Attack
	JSR Random_X_A						
	REP #$21
	ADC Attack						
	STA Attack		;Param2 + 0..Param2			

	JSR StrDamageCalc	;finish calculations as a standard strength attack
	DEC M			;but 1 less M
	RTS

endif