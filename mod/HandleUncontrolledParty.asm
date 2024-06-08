if !_Fixes || !_Optimize

;Fixes:  adds check for death (fixes berserker atb progressing while dead)
;Optimizations: use some 1 byte addresses instead of 2

;Manage the ATB timer used for zombie/charm/berserk party members
;and set up their action when it is ready
HandleUncontrolledParty:
	TDC 								
	TAX         							
	STX $3D		;char index, used in subroutines also		
	STX $3F		;char offset					
.Loop
	LDX $3D								
	LDA UncontrolledATB,X						
	BEQ .ActionReady						
	LDX $3F								
	LDA CharStruct.Status3,X 					
	AND #$10	;stop						
	BNE .Next   							
	LDA CharStruct.Status2,X 					
	ORA CharStruct.AlwaysStatus2,X					
	AND #$60	;sleep/paralyze					
	BNE .Next   			

if !_Fixes	
	;adds check for death (fixes berserker atb progressing while dead)
	LDA CharStruct.Status1,X
	BMI .Next	;80h, dead
endif

	LDX $3D								
	DEC UncontrolledATB,X						
	BRA .Next							

.ActionReady
	LDX $3F		;char offset					
	LDA #$01							
	STA CharStruct.CmdCancelled,X					
	LDA CharStruct.Status1,X 					 
	ORA CharStruct.AlwaysStatus1,X					
	AND #$02	;zombie						
	BEQ +   							 
	JSR ZombieAction						
	BRA .Next							
+	LDA CharStruct.Status2,X					
	ORA CharStruct.AlwaysStatus2,X					
	AND #$10	;charm						
	BEQ +								
	JSR CharmAction							
	BRA .Next							
+	LDA CharStruct.Status2,X					
	ORA CharStruct.AlwaysStatus2,X					
	AND #$08	;berserk					
	BEQ .Next							
	JSR BerserkAction						
.Next
	LDX $3F		;char offset					
	JSR NextCharOffset   						
	STX $3F								

if !_Optimize		;use 1 byte addresses instead of 2
	INC $3D		;char index					
	LDA $3D							
else
	INC $003D	;char index					
	LDA $003D			
endif

	CMP #$04	;4 characters					
	BNE .Loop							
	RTS 								

endif