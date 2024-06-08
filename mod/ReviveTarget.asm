if !_Optimize 

incsrc "mod/utility/CalcDamageUtil.asm"

;Revive Target
;Param3/$59 is fraction/16 of max hp to restore

;**optimize: 	use utility routine

ReviveTarget:
	LDA TargetIndex							
	CMP #$04							
	BCC .Revive			;<4 is party			
	SEC 								
	SBC #$04							
	TAX 				;now monster index(0-7)		
	LDA InactiveMonsters						
	JSR SelectBit_X							
	BEQ .Revive			;check if monster is revivable	
.Miss
	INC AtkMissed							
	RTS 								

.Revive									
	LDX TargetOffset						
	LDA CharStruct.Status1,X					
	AND #$02			;zombie				
	BNE .Miss							
	LDA CharStruct.Status1,X					
	AND #$7F			;clear dead			
	STA CharStruct.Status1,X					
	LDA Param3							
	REP #$20							
	STA $2C								
	LDX TargetOffset						
	LDA CharStruct.MaxHP,X						
	STA $2A								
	JSR CalcDamagePercent		;calculates hp * fraction / 16, result in X and $2E
	LDX TargetOffset						
	REP $21
	LDA CharStruct.CurHP,X						
	ADC $2E								
	BCS +				;check for overflow		
	CMP CharStruct.MaxHP,X		 				
	BCC ++								
+	LDA CharStruct.MaxHP,X						
++	STA CharStruct.CurHP,X		;set hp to max			
	TDC 								
	SEP #$20							
	LDA TargetIndex						
	TAX 								
	INC ActiveParticipants,X					
	RTS 								


endif