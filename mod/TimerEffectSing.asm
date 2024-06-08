if !_Fixes

TimerEffectSing:
	LDA #$01							
	STA EnableTimer.Sing,Y						
	LDA InitialTimer.Sing,Y						
	STA CurrentTimer.Sing,Y						
	TDC 								
	TAY 								
	LDX AttackerOffset						 
	LDA CharStruct.Song,X						 
	BEQ .Ret     							 
.FindSong		;Y = song stat index
	ASL 								
	BCS +								
	INY 								
	BRA .FindSong							
+	STY $12		;song stat index				
	TDC 								
	TAX 								
	STX $0E		;target						
	LDA #$04							
	STA $10		;after last target				
	LDA TimerReadyChar.Sing						
	CMP #$04	;monster check? monsters can sing?		
	BCC .ApplySong							
	LDA #$04							
	STA $0E		;target						
	LDA #$0C							
	STA $10		;last target +1					

if !_Fixes		;Fixed: first monster should be offset $200 not $180
	LDX #$0200      ;vanilla FF5 monsters don't sing, so 
else                    ;only matters if monsters are modded 
	LDX #$0180				
endif

.ApplySong
	STX $14		;char offset					
	REP #$20							
	TXA 								
	CLC 								
	ADC $12		;adjust offset by song stat			
	TAX 								
	TDC 								
	SEP #$20							
.CharLoop
	LDY $0E		;target						
	LDA ActiveParticipants,Y					
	BEQ .Next							
	CLC 								
	LDA CharStruct.BonusStr,X	;different stats depending on X	
	INC 								
	CMP #$64	;don't apply changes at 100 and up		
	BCS .Next							
	STA CharStruct.BonusStr,X					
.Next
	JSR NextCharOffset     						
	STX $14		;char offset					
	INC $0E		;next target					
	LDA $0E								
	CMP $10		;last target +1					
	BNE .CharLoop							
.Ret	RTS 	

endif