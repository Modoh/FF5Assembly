if !_Fixes || !_Optimize || !_CombatTweaks 

incsrc "utility/damageutil.asm"

;Bells Damage formula

%subdef(BellDamage)

if !_CombatTweaks
;Overrides Attack Power with Param 1 (for harp magic mod, but applies to bells too if data is changed)
	LDA Param1		;*param 1						
	BNE .SkipBP		;*if set, use Param 1 instead of BP			
endif


;this code raises bell damage to 75-125%
;seemed too strong in testing, considering the attack is 100% accurate/unavoidable
;	TAX
;	STX $0E		;AP
;	LDX #$0000
;	JSR Random_X_A	;0..AP
;	REP #$21	
;	ADC $0E		;AP..AP*2 (100..200%)			
;	LSR $0E		;AP/2 (50%)
;	ADC $0E		;AP+AP/2..AP*2+AP/2	(150%..250%) 	;sometimes adds carry, that's fine 
;	LSR		;AP/2+AP/4..AP+AP/4	(75%..125%)
;	STA Attack

;Standard Bell Damage
;Attack = Attack Power / 2 + 0..(Attack Power / 2)
;M = Level*Agility/128 + 2 + Level*MagicPower/128
;Defense = Target Magic Defense 
	JSR LoadAttackPower
.SkipBP	LSR
	TAX
	STX $0E		;AP/2
	LDX #$0000
	JSR Random_X_A	;0..AP/2
	REP #$21
	ADC $0E		;AP/2 + 0..AP/2 (50%..100%)
	STA Attack
	
	TDC 		
	SEP #$20		
	LDA Agility    	
	JSR StatTimesLevel	;returns in 16 bit mode					
	JSR ShiftDivide_128	
	STA $0E		
	TDC 		
	SEP #$20		
	LDA MagicPower							
	JSR StatTimesLevel	;returns in 16 bit mode
	JSR ShiftDivide_128	
	CLC 		
	ADC $0E      		;(Level*Agility)/128 + (Level*Magic Power)/128
	INC
	INC			;+2
	STA M		
	JMP NormalMDefense16	;returns in 8 bit mode
	
endif
