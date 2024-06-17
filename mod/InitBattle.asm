if !_Optimize

%subdef(InitBattle)
;opt: 	use loops and MVN to save some space
;	doesn't save as much as I expected

	LDX #$0067									;C2/4F0A: A2 67 00     LDX #$0067	
	TDC 										;C2/4F0D: 7B           TDC 		
-	STA $00,X	;Clears $00-67							;C2/4F0E: 95 00        STA $00,X	
	DEX 										;C2/4F10: CA           DEX 		
	BPL -										;C2/4F11: 10 FB        BPL $4F0E	
																
	LDX #$5CD7									;C2/4F13: A2 D7 5C     LDX #$5CD7	
	TDC 										;C2/4F16: 7B           TDC 		
																
-	STA $2000,X	;Clears all of the ram used in battle, except ResetBattle	;C2/4F17: 9D 00 20     STA $2000,X	
	DEX 										;C2/4F1A: CA           DEX 		
	BPL -										;C2/4F1B: 10 FA        BPL $4F17	
	TXA 		;A now $FF							;C2/4F1D: 8A           TXA 		

	LDX #$0004
-	STA ATBReadyQueue,X
	DEX
	BPL -
	
	STA DisplayInfo.CurrentChar							;C2/4F2D: 8D CC 41     STA $41CC		
	STA ReleasedMonsterID								;C2/4F30: 8D 4B 7C     STA $7C4B		

	LDX #$01FF									;C2/4F33: A2 FF 01     LDX #$01FF	
-	STA !GFXQueue,X		;Init gfx queue to $FF, which is considered empty	;C2/4F36: 9D 4C 38     STA $384C,X	
	DEX 										;C2/4F39: CA           DEX 		
	BPL -										;C2/4F3A: 10 FA        BPL $4F36	
																
	LDX #!FieldData		;copy data like Escape count and battle event flags	
	LDY #!BattleData        ;from field structure to battle structure		
	LDA #$1F		;32 bytes (minus 1 for MVN)
	MVN $7E,$7E		;moves all 32 bytes of data
	TDC			;need this so high byte of A is 0 instead of $FF
	
	LDX #FieldTimerEnable	;also copies 16-bit FieldTimer to BattleTimer
	LDY #BattleTimerEnable
	LDA #$02		;3 bytes to copy
	MVN $7E,$7E
	TDC			;need this so high byte of A is 0 instead of $FF

	INC MonsterNextForm

	LDA #$40			;set this bit for all monsters			;C2/4F5F: A9 40        LDA #$40		
	STA CharStruct[4].CharRow							;C2/4F61: 8D 00 22     STA $2200	
	STA CharStruct[5].CharRow							;C2/4F64: 8D 80 22     STA $2280	
	STA CharStruct[6].CharRow							;C2/4F67: 8D 00 23     STA $2300	
	STA CharStruct[7].CharRow							;C2/4F6A: 8D 80 23     STA $2380	
	STA CharStruct[8].CharRow							;C2/4F6D: 8D 00 24     STA $2400	
	STA CharStruct[9].CharRow							;C2/4F70: 8D 80 24     STA $2480	
	STA CharStruct[10].CharRow							;C2/4F73: 8D 00 25     STA $2500	
	STA CharStruct[11].CharRow							;C2/4F76: 8D 80 25     STA $2580	
	
	RTS 										;C2/4F79: 60           RTS 

endif

	;sets a flag in the CharStruct.CharRow bit for all monsters
	;probably works but is super ugly and complicated for just 2 bytes saved
;	TDC
;	TAX	
;	LDA #$40			;not in the team
;	TAY
;-	STA CharStruct[4].CharRow,X
;	REP #$21			;16 bit mode and clear carry
;	TXA
;	ADC #sizeof(CharStruct)		;next CharStruct Slot
;	TAX
;	TYA				;this includes setting the high byte of A to 0
;	SEP #$20
;	CPX #sizeof(CharStruct)*8	;8 monsters
;	BCS -
