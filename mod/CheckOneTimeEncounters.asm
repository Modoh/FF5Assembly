if !_Optimize

;set up sandworm and one-time encounters
;opt: 	remove unused support for more than 1 byte of encounter replacement flags
;	also saves space by using 16 bit mode
CheckOneTimeEncounters:
	LDA EncounterInfo.Flags							;C2/4E25: AD FE 3E     LDA $3EFE	
	AND #$10	;sandworm						;C2/4E28: 29 10        AND #$10		
	BEQ .OneTimeEncounters							;C2/4E2A: F0 04        BEQ $4E30	
	INC SandwormBattle							;C2/4E2C: EE 4C 7C     INC $7C4C	
	RTS									;C2/4E2F: 60           RTS		

.OneTimeEncounters
	TDC 									;C2/4E30: 7B           TDC 		
	TAX 									;C2/4E31: AA           TAX 		
	STX $10									;C2/4E32: 86 10        STX $10		

.CheckEncountersLoop													
	LDX $10									;C2/4E34: A6 10        LDX $10		
	REP #$20
	LDA EncounterIndex
	CMP ROMOneTime.Encounter,X
	BNE .Next
	LDA ROMOneTime.Replacement,X
	STA $12
	TXA			;transferring before mode switch also clears high byte
	SEP #$20		
	
	JSR ShiftDivide_4	;0-7						;C2/4E55: 20 C0 01     JSR $01C0	
	TAX 									;C2/4E69: AA           TAX 		
	LDA BattleData.EventFlags+1						;C2/4E6A: B9 85 7C     LDA $7C85,Y	
	JSR SelectBit_X			;selects event flag for this fight	;C2/4E6D: 20 DB 01     JSR $01DB	
	BNE .ChangeEncounter		;change the fight if we've done it	;C2/4E70: D0 0F        BNE $4E81	

.Next	TDC
	SEP #$20			;harmless if already in 8 bit mode
	CLC
	LDA $10
	ADC #$04			;next 4 byte entry in replacement table
	STA $10
	CMP #$20			;8 total replacements in table		;C2/4E7C: C9 20        CMP #$20		
	BNE .CheckEncountersLoop						;C2/4E7E: D0 B4        BNE $4E34	
	RTS 									;C2/4E80: 60           RTS 

.ChangeEncounter
	REP #$20								;C2/4E81: C2 20        REP #$20		
	LDA $12			;replacement encounter				;C2/4E83: A5 12        LDA $12		
	STA EncounterIndex							;C2/4E85: 8D F0 04     STA $04F0	
	JSR ShiftMultiply_16							;C2/4E88: 20 B5 01     JSR $01B5	
	TAX 									;C2/4E8B: AA           TAX 		
	TDC 									;C2/4E8C: 7B           TDC 		
	SEP #$20								;C2/4E8D: E2 20        SEP #$20		
	TAY 									;C2/4E8F: A8           TAY 		
															
-	LDA !ROMEncounterInfo,X							;C2/4E90: BF 00 30 D0  LDA $D03000,X	
	STA !EncounterInfo,Y							;C2/4E94: 99 EF 3E     STA $3EEF,Y	
	INY 									;C2/4E97: C8           INY 		
	INX 									;C2/4E98: E8           INX 		
	CPY #$0010		;16 byte struct					;C2/4E99: C0 10 00     CPY #$0010	
	BNE -									;C2/4E9C: D0 F2        BNE $4E90	
															
	RTS									;C2/4E9E: 60           RTS

endif