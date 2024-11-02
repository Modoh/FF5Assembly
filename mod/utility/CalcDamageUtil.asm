includeonce

incsrc "ShiftDivide32b.asm"

;params:
;$2C: fraction (/16)
;$2A: damage base (generally a hp total)
;ok to call in either 8 or 16 bit mode (multiply immediately goes to 16 bit)
;returns X = base * fraction / 16
%subdef(CalcDamagePercent)
	JSR Multiply_16bit					
	REP #$20						
	JSR ShiftDivide32b_16	;divide result by 16 via shifts	
	LDA $30							
	BNE .Cap						
	LDA $2E							
	CMP #$270F	;9999					
	BCC +							
.Cap	LDA #$270F	;cap at 9999				
	STA $2E							
	BNE +							
	INC $2E		;min 1					
+	TDC 							
	SEP #$20						
	LDX $2E							
	RTS 	

;end portion of CalcFinalDamage and CalcFinalDamageMSword (which is the same)
%subdef(CalcFinalDamageEnd)
	LDX BaseDamage									
	LDA AtkHealed 									
	BNE .ApplyDamage	;skip attacker damage check if we're healing target						

.CheckAttackerDamage		;Unsure what this section is for, attacker takes damage but no target healing
	LDA AttackerDamaged								
	BEQ .ApplyDamage								
	JMP ApplyAttackerDamage						
							
.ApplyDamage
	JMP ApplyHPDamage 	;handles standard damage and healing, from X	

;Doubles M if can't evade bit is set
;used in both CalcFinalDamage routines, but is skipped by a bug most of the time normally
%subdef(CantEvadeMod)
	LDA AttackerOffset2							
	TAX 									
	LDA AttackInfo.Category,X						
	LDX TargetOffset							
	AND CharStruct.CantEvade,X						
	BEQ .Ret								
	ASL M   								
	ROL M+1
.Ret	RTS
	
;Normal damage or healing application, from X
%subdef(ApplyHPDamage)
	LDA AtkHealed						
	BNE .Heal						
	STX DamageToTarget					
	RTS 							
								
.Heal	STX HealingToTarget					
	RTS

;Strange flag where attacker is damaged, and uses their defense
%subdef(ApplyAttackerDamage)
	LDX AttackerOffset			;uses attacker's defense instead	
	LDA CharStruct.Defense,X							
	TAX 										
	STX Defense   									
	JSR CalcBaseDamage								
	LDX BaseDamage									
	STX DamageToAttacker 								
	RTS 										

