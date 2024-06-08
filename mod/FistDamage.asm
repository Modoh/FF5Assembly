if !_Optimize || !_Fixes || !_CombatTweaks 

incsrc "mod/utility/damageutil.asm"

;Fists Damage Formula
;Tweaks: Power Drink fix and significant size optimization

;With Brawl:
;	Attack = Attack Power + Level*2 + 0..Level/4 + (50 with Kaiser Knuckles)
;	M = Level*Strength/256 + 2
;Without Brawl:
;	Attack = Attack Power + 0..Level/4
;	M = 2
;Defense = Target Defense
;
FistDamage:
	JSR LoadAttackPower	;includes power drinks if fixes are on
	TAX 							
	STX $0E			;Attack Power			
	TDC 							
	TAX 							
	LDA Level						
	JSR ShiftDivide_4					
	JSR Random_X_A						
	TAX 							
	STX $10			;0..Level/4			
	LDA Level   						
	JSR StatTimesLevel	;(Strength * Level), returns in 16 bit mode							
	JSR ShiftDivide_256	;/256
	INC
	INC			;+2
	STA M
	TDC
	SEP #$20
	LDX AttackerOffset					
	LDA CharStruct.Passives2,X				
	AND #$40    		;Brawl				
	BEQ .NoBrawl						
	LDA Level
	REP #$20		
	ASL			;Level *2, also clears carry since level*2 can't overflow
	ADC $10			;+0..Level/4			
	ADC $0E			;+Attack Power			
	STA Attack		;Attack Power + Level*2 + 0..Level/4
	TDC 							
	SEP #$20						
	LDX AttackerOffset					
	LDA CharStruct.ArmorProperties,X 			
	AND #$20    		;Improved Brawl			
	BEQ .Def						
	REP #$21		;also clears carry													
	LDA Attack						
	ADC #$0032		;+50				
	STA Attack									
	BRA .Def
	
.NoBrawl	
	REP #$21		;also clears carry				 							
	LDA $0E     		;Attack Power			
	ADC $10     		;+ 0..Level/4			
	STA Attack
	LDA #$0002
	STA M
	
.Def	JMP NormalDefense16							

endif






