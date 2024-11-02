if !_Optimize 

incsrc "utility/CalcDamageUtil.asm"

;Calculate Damage from % of Target Max HP

;**optimize: 	go to 16 bit mode earlier, remove unnecessary high byte OR
;		use utility routines
%subdef(CalcDamageMaxHP)
	LDA Param2						
	REP #$20
	STA $2C							
	LDX TargetOffset					
	LDA CharStruct.MaxHP,X					
	STA $2A							
	JSR CalcDamagePercent
	JMP ApplyHPDamage

endif