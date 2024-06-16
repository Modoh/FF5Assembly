if !_Fixes || !_Optimize || !_CombatTweaks 

incsrc "utility/damageutil.asm"

;Strong Fight Damage
;Tweaks: 	updated to work with power drink fix and optimized
;		Not likely to occur (impossible in vanilla?) 
;		but vanilla code would have worked so fixing it here
%subdef(StrongFightDamage)
	LDX AttackerOffset													
	LDA CharStruct.MonsterAttack,X
	JSR LoadAttackPower_DrinkOnly
	STA $0E	
	REP #$20						
	JSR ShiftMultiply_8					
	STA Attack    						
	TDC 							
	SEP #$20						
	LDA CharStruct.MonsterM,X				
	TAX 							
	STX M
	LDA $0E
	JSR ShiftDivide_8					
	LDX #$0000						
	JSR Random_X_A 						
	REP #$21			;also clears carry
	ADC Attack 						
	STA Attack    						
	JMP NormalDefense16
;

endif