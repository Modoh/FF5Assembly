if !_Optimize || !_CantEvade_Doubles_M	
;need to pull this in for the cantevade fix to prevent the code from being duplicated, even though this routine already worked

incsrc "mod/utility/CalcDamageUtil.asm"

;Calculate Final Damage w/Magic Sword
;Damage is returned in different addresses depending on what happens
;
;**optimize: 	used utility routines, shared with the other final damage routine
CalcFinalDamageMSword:
	JSR CalcBaseDamage								
	LDX BaseDamage									
	BNE .CheckCantEvade		
        STX DamageToTarget  	
        RTS 

.CheckCantEvade										
	JSR CantEvadeMod	;multiplies M by 2 if Can't Evade bit is set
	
.CheckDrain
	LDX AttackerOffset								
	LDA CharStruct.MSwordStatusSpecial,X						
	AND #$40   									
	BEQ .CheckPsyche								
	JMP DrainDamage									

.CheckPsyche
	LDA CharStruct.MSwordStatusSpecial,X						
	AND #$20   									
	BEQ .End									
	JMP MSwordPsyche								

.End	JMP CalcFinalDamageEnd								
	
endif