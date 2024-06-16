if !_Optimize 

incsrc "utility/CalcDamageUtil.asm"


;Calculate Damage from % of Target Current MP

;**optimize: 	go to 16 bit mode earlier, remove unnecessary high byte OR
;		use utility routine

%subdef(CalcDamageTargetCurMP)
	LDA Param2					
	REP #$20 					
	STA $2C						
	LDX TargetOffset				
	LDA CharStruct.CurMP,X				
	STA $2A						
	JSR CalcDamagePercent			
	STX DamageToTargetMP				
	RTS 						
	
endif