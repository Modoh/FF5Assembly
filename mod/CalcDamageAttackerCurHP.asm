if !_Optimize 

incsrc "utility/CalcDamageUtil.asm"

;Calculate Damage from % of Attacker Current HP
;
;**optimize: 	go to 16 bit mode earlier, remove unnecessary high byte OR
;		use utility routines
%subdef(CalcDamageAttackerCurHP)
	LDA Param2						
	REP #$20
	STA $2C							
	LDX TargetOffset					
	LDA CharStruct.CurHP,X					
	STA $2A							
	JSR CalcDamagePercent
	JMP ApplyHPDamage

endif