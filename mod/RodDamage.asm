if !_Fixes || !_Optimize || !_CombatTweaks 

incsrc "utility/damageutil.asm"

;Rods damage formula
;Attack = (0..Attack Power)*2
;M = Level*MagicPower/256 + 2
;Defense = Target Magic Defense

;combat tweaks changes:
;Attack = (1..Attack Power)*2
;M = Level*MagicPower/256 + 2
;Defense = Target Magic Defense/2
;goal is to make rods hit for 0 less often, but still not overshadow actual spells

%subdef(RodDamage)
	JSR LoadAttackPower	;*Load Attack Power including Power Drinks
	TAX	
	STX $0E			

if !_CombatTweaks
	LDX #$0001
else
	LDX #$0000
endif

	JSR Random_X_A 		;(X..AP)
	REP #$21		;*saves a byte by clearing carry alongside M
	ASL			;(X..AP)*2
	STA Attack		
	TDC 		
	SEP #$20     		
	LDA MagicPower    	
	JSR StatTimesLevel	;Stat * Level, returns in 16 bit mode
	JSR ShiftDivide_256	;/256
	INC
	INC			;+2
	STA M
	
if !_CombatTweaks
	JSR NormalMDefense16
	LSR Defense
	RTS
else	
	JMP NormalMDefense16	
endif


endif