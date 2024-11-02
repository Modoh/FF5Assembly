if !_Fixes || !_Optimize || !_CombatTweaks 

incsrc "utility/damageutil.asm"

;Monster damage formula
;Tweaks: 	Just updating to work with power drink fix.  
;		Not likely to occur, but it worked for them in vanilla if you used some chemistry on them
;		and needs changes to work with the new power drink 

%subdef(MonsterDamage)
	LDX AttackerOffset						
	LDA CharStruct.MonsterAttack,X					
	JSR LoadAttackPower_DrinkOnly
	TAX
	STX $0E
	JSR ShiftDivide_8  						
	LDX #$0000							
	JSR Random_X_A 							
	REP #$21				;also clears carry 								
	ADC $0E    							
	STA Attack
	TDC
	SEP #$20
	LDX AttackerOffset						
	LDA CharStruct.MonsterM,X					
	TAY 								
	STY M								
	JMP NormalDefense					

endif