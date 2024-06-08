if !_Fixes


;Advances ATB so that the lowest ATB gets their turn immediately
;also applies Masamune's Initiative effect but it's buggy
AdvanceStartingATB:
	LDA #$FF								;C2/4E9F: A9 FF        LDA #$FF	
	STA $0E									;C2/4EA1: 85 0E        STA $0E	
	TDC 									;C2/4EA3: 7B           TDC 	
	TAX 									;C2/4EA4: AA           TAX 	
	TAY 									;C2/4EA5: A8           TAY 	

.FindLowestATB													
	LDA ActiveParticipants,Y						;C2/4EA6: B9 C2 3E     LDA $3EC2,Y
	BEQ .NextLowestATB							;C2/4EA9: F0 09        BEQ $4EB4
	LDA CurrentTimer.ATB,X							;C2/4EAB: BD 7F 3D     LDA $3D7F,X
	CMP $0E									;C2/4EAE: C5 0E        CMP $0E	
	BCS .NextLowestATB							;C2/4EB0: B0 02        BCS $4EB4
	STA $0E			;current lowest					;C2/4EB2: 85 0E        STA $0E	

.NextLowestATB													
	TXA 									;C2/4EB4: 8A           TXA 	
	CLC 									;C2/4EB5: 18           CLC 	
	ADC #$0B	;next char timer offset					;C2/4EB6: 69 0B        ADC #$0B	
	TAX 									;C2/4EB8: AA           TAX 	
	INY 									;C2/4EB9: C8           INY 	
	CPY #$000C	;12 participants					;C2/4EBA: C0 0C 00     CPY #$000C
	BNE .FindLowestATB							;C2/4EBD: D0 E7        BNE $4EA6
														
	SEC									;C2/4EBF: 38           SEC	
	LDA $0E		;lowest atb						;C2/4EC0: A5 0E        LDA $0E	
	SBC #$02	;-2							;C2/4EC2: E9 02        SBC #$02	
	BCS +									;C2/4EC4: B0 01        BCS $4EC7
	TDC		;min 0							;C2/4EC6: 7B           TDC	
+	STA $0E									;C2/4EC7: 85 0E        STA $0E	
	TDC 									;C2/4EC9: 7B           TDC 	
	TAX 									;C2/4ECA: AA           TAX 	
	TAY 									;C2/4ECB: A8           TAY 	

.SubtractLowestATB
	LDA ActiveParticipants,Y						;C2/4ECC: B9 C2 3E     LDA $3EC2,Y
	BEQ .NextSubtractLowest							;C2/4ECF: F0 09        BEQ $4EDA
	SEC 									;C2/4ED1: 38           SEC 	
	LDA CurrentTimer.ATB,X							;C2/4ED2: BD 7F 3D     LDA $3D7F,X
	SBC $0E		;lowest ATB -2						;C2/4ED5: E5 0E        SBC $0E	
	STA CurrentTimer.ATB,X							;C2/4ED7: 9D 7F 3D     STA $3D7F,X

.NextSubtractLowest
	TXA 									;C2/4EDA: 8A           TXA 	
	CLC 									;C2/4EDB: 18           CLC 
	ADC #$0B	;next char timer offset					;C2/4EDC: 69 0B        ADC #$0B	
	TAX           								;C2/4EDE: AA           TAX           
	INY           								;C2/4EDF: C8           INY           
	CPY #$000C    	;12 participants					;C2/4EE0: C0 0C 00     CPY #$000C    
	BNE .SubtractLowestATB							;C2/4EE3: D0 E7        BNE $4ECC
														
	TDC									;C2/4EE5: 7B           TDC	
	TAX 									;C2/4EE6: AA           TAX 	
	TAY 									;C2/4EE7: A8           TAY 	

	;**bug: they forgot to init $0E to zero here,
	;so this writes 1 to random timer values after setting up initiative
	;luckily, the range it can reach is all within CurrentTimer and InitialTimer
	;and the 1s written there seem fairly harmless
	
if !_Fixes
	STZ $0E
endif
	
.CheckInitiative					   
	LDA EncounterInfo.IntroFX						;C2/4EE8: AD EF 3E     LDA $3EEF
	BMI .NextInitiative	;80h: credits demo battle			;C2/4EEB: 30 0C        BMI $4EF9
	LDA CharStruct.WeaponProperties,X					;C2/4EED: BD 38 20     LDA $2038,X
	AND #$20      		;initiative					;C2/4EF0: 29 20        AND #$20    
	BEQ .NextInitiative							;C2/4EF2: F0 05        BEQ $4EF9
	LDA #$01								;C2/4EF4: A9 01        LDA #$01	
	STA CurrentTimer.ATB,Y							;C2/4EF6: 99 7F 3D     STA $3D7F,Y

.NextInitiative													
	TYA 								 	;C2/4EF9: 98           TYA 	
	CLC           								;C2/4EFA: 18           CLC         
	ADC #$0B      	;next char timer offset					;C2/4EFB: 69 0B        ADC #$0B    
	TAY           								;C2/4EFD: A8           TAY         
	JSR NextCharOffset							;C2/4EFE: 20 E0 01     JSR $01E0
	INC $0E		;should be char index, but is likely >4			;C2/4F01: E6 0E        INC $0E	
	LDA $0E									;C2/4F03: A5 0E        LDA $0E	
	CMP #$04	;4 characters, will loop until the byte wraps around	;C2/4F05: C9 04        CMP #$04	
	BNE .CheckInitiative							;C2/4F07: D0 DF        BNE $4EE8
	RTS 									;C2/4F09: 60           RTS 

endif