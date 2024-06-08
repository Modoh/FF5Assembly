if !_Optimize || !_Fixes || !_CombatTweaks || !_Overpowered_Knife_Fix

incsrc "mod/utility/damageutil.asm"

;Knives damage formula
;Tweaks:
;Power Drink fix and related changes to account for possible attack power overflow
;Fixes agi bug where it ignored high byte of result
;Reduced stat scaling to /256 instead of /128 and changes static value to 3 to offset rounding loss
;Goal is to restore bugged str/agi scaling without also making them too good and overshadow str weapons for str classes

;Fixes:
;Simply fixing the obvious knife bug makes them very overpowered with the attack values the game uses
;so I'm making the judgement call of using the combat tweaks formula as a fix

;optimizations:
;uses utility routines to save space over original
;if not using fixes, a shorter method is used to get the original bugged agi behavior

;Attack = Attack Power + 0..3
;M = Level*Strength/256 + Level*Agility/256 + 3
;Defense = Target Defense

KnifeDamage:
	JSR LoadAttackPower	;*Load Attack Power including Power Drinks
	TAX
	STX Attack		
	TDC
	TAX 		
	LDA #$03		
	JSR Random_X_A 		;(0..3)
	REP #$21 		;*saves a byte by clearing carry alongside m flag
	ADC Attack    		;(Attack Power + (0..3))
	STA Attack
	TDC
	SEP #$20
	LDA Strength  		
	JSR StatTimesLevel	;Stat * Level, returns in 16 bit mode

;calculate strength component of M depending on which fixes we're using
;janky checks because Asar can't combine different logical ops together in one if statement
if !_Overpowered_Knife_Fix	
	JSR ShiftDivide_128
elseif !_Fixes || !_CombatTweaks 
	JSR ShiftDivide_256    	;Divide by 256 instead of 128
else
	JSR ShiftDivide_128
endif

	STA $0E		
	TDC 		
	SEP #$20		
	LDA Agility   		
	JSR StatTimesLevel	;Stat * Level, returns in 16 bit mode

;calculates agility component of M depending on which fixes we're using
;then adds it to the strength component and the static component
if !_Overpowered_Knife_Fix
	JSR ShiftDivide_128	
	CLC
	ADC $0E
	INC
	INC

elseif !_Fixes || !_CombatTweaks 
	JSR ShiftDivide_256	;Divide by 256 instead of 128
	CLC 		
	ADC $0E      		;(Level*Strength)/256 + (Level*Agility)/256
	ADC #$0003		;+3

else				;shorter method to retain bugged behavior
	XBA			;swap bytes in accumulator
	ASL			;carry is set if agi is in the range that gives +1 to M
	LDA #$0002		
	ADC $0E			;2 + (Level*Strength)/128 + 0 or 1 depending on Agi

endif

	STA M		
	JMP NormalDefense16 			
	
endif

	