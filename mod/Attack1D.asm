if !_Fixes

;Attack Type 1D (Scan Monster)
;Param1: 	80h miss vs bosses
;		40h scans level
;		20h scans current and max hp
;		08h scans element weakness (*fixed: no longer scans status effects 1 and 2)
;		04h scans status effects 1 and 2 (*fixed)
Attack1D:
	JSR SetupMsgBoxIndexes	;prepares things in case of x-magic	;C2/6C17: 20 65 99     JSR $9965
	STX $0E			;$7B2C*24				;C2/6C1A: 86 0E        STX $0E
	STY $10			;$7B2C*12, this saved var isn't used	;C2/6C1C: 84 10        STY $10
	LDA Param1							;C2/6C1E: A5 57        LDA $57
	BPL +	  							;C2/6C20: 10 08        BPL $6C2A    (If $57 < 80h)
	LDA BattleMonsterID+1						;C2/6C22: AD 21 40     LDA $4021
	BEQ +	  							;C2/6C25: F0 03        BEQ $6C2A    (If monster index < 255 (i.e. not a boss))
	JMP .Miss 							;C2/6C27: 4C E1 6C     JMP $6CE1    (Scan misses)
+	LDA Param1							;C2/6C2A: A5 57        LDA $57
	AND #$40							;C2/6C2C: 29 40        AND #$40
	BEQ +								;C2/6C2E: F0 16        BEQ $6C46
	LDA #$11		;message to display			;C2/6C30: A9 11        LDA #$11
	STA MessageBoxes,X						;C2/6C32: 9D 5F 3C     STA $3C5F,X
	INC $0E								;C2/6C35: E6 0E        INC $0E
	LDX TargetOffset						;C2/6C37: A6 49        LDX $49
	LDA CharStruct.Level,X						;C2/6C39: BD 02 20     LDA $2002,X  (Scan Level)
	STA MessageBoxData[0].0,Y	;numbers used in message box	;C2/6C3C: 99 BF 3C     STA $3CBF,Y
	TDC 								;C2/6C3F: 7B           TDC 
	STA MessageBoxData[0].1,Y	;these are each 3 bytes long	;C2/6C40: 99 C0 3C     STA $3CC0,Y
	STA MessageBoxData[0].2,Y					;C2/6C43: 99 C1 3C     STA $3CC1,Y
+	LDA Param1							;C2/6C46: A5 57        LDA $57
	AND #$20							;C2/6C48: 29 20        AND #$20
	BEQ +								;C2/6C4A: F0 45        BEQ $6C91
	LDX $0E								;C2/6C4C: A6 0E        LDX $0E
	LDA #$12		;message to display			;C2/6C4E: A9 12        LDA #$12
	STA MessageBoxes,X						;C2/6C50: 9D 5F 3C     STA $3C5F,X
	INC $0E								;C2/6C53: E6 0E        INC $0E
	LDX TargetOffset						;C2/6C55: A6 49        LDX $49
	LDA CharStruct.CmdImmunity,X					;C2/6C57: BD 66 20     LDA $2066,X
	BPL ++  							;C2/6C5A: 10 16        BPL $6C72     (If Target Immune to HP Scan)
	LDA #$FF		;fill results with $FF if scan immune	;C2/6C5C: A9 FF        LDA #$FF
	STA MessageBoxData[1].0,Y					;C2/6C5E: 99 C2 3C     STA $3CC2,Y
	STA MessageBoxData[1].1,Y					;C2/6C61: 99 C3 3C     STA $3CC3,Y
	STA MessageBoxData[1].2,Y					;C2/6C64: 99 C4 3C     STA $3CC4,Y
	STA MessageBoxData[2].0,Y					;C2/6C67: 99 C5 3C     STA $3CC5,Y
	STA MessageBoxData[2].1,Y					;C2/6C6A: 99 C6 3C     STA $3CC6,Y
	STA MessageBoxData[2].2,Y					;C2/6C6D: 99 C7 3C     STA $3CC7,Y
	BRA +								;C2/6C70: 80 1F        BRA $6C91
++	LDA CharStruct.CurHP,X						;C2/6C72: BD 06 20     LDA $2006,X
	STA MessageBoxData[1].0,Y					;C2/6C75: 99 C2 3C     STA $3CC2,Y
	LDA CharStruct.CurHP+1,X					;C2/6C78: BD 07 20     LDA $2007,X
	STA MessageBoxData[1].1,Y					;C2/6C7B: 99 C3 3C     STA $3CC3,Y
	LDA CharStruct.MaxHP,X						;C2/6C7E: BD 08 20     LDA $2008,X
	STA MessageBoxData[2].0,Y					;C2/6C81: 99 C5 3C     STA $3CC5,Y
	LDA CharStruct.MaxHP+1,X					;C2/6C84: BD 09 20     LDA $2009,X
	STA MessageBoxData[2].1,Y					;C2/6C87: 99 C6 3C     STA $3CC6,Y
	TDC 								;C2/6C8A: 7B           TDC 
	STA MessageBoxData[1].2,Y					;C2/6C8B: 99 C4 3C     STA $3CC4,Y
	STA MessageBoxData[2].2,Y					;C2/6C8E: 99 C7 3C     STA $3CC7,Y
+	LDA Param1							;C2/6C91: A5 57        LDA $57
	AND #$08							;C2/6C93: 29 08        AND #$08
	BEQ +								;C2/6C95: F0 1E        BEQ $6CB5
	LDX TargetOffset						;C2/6C97: A6 49        LDX $49
	LDA CharStruct.EWeak,X						;C2/6C99: BD 34 20     LDA $2034,X  (Scan Weakness)
	STA $12								;C2/6C9C: 85 12        STA $12
	LDX $0E								;C2/6C9E: A6 0E        LDX $0E
	TDC 								;C2/6CA0: 7B           TDC 
	TAY 								;C2/6CA1: A8           TAY 
	LDA #$12		;message to display (incremented later)	;C2/6CA2: A9 12        LDA #$12
.EleLoop				;loop through elements
	INC 								;C2/6CA4: 1A           INC 
	ASL $12								;C2/6CA5: 06 12        ASL $12
	BCC ++								;C2/6CA7: 90 06        BCC $6CAF
	STA MessageBoxes,X						;C2/6CA9: 9D 5F 3C     STA $3C5F,X
	INX 								;C2/6CAC: E8           INX 
	INC $0E								;C2/6CAD: E6 0E        INC $0E
++	INY 								;C2/6CAF: C8           INY 
	CPY #$0008							;C2/6CB0: C0 08 00     CPY #$0008
	BNE .EleLoop							;C2/6CB3: D0 EF        BNE $6CA4
+	LDA Param1							;C2/6CB5: A5 57        LDA $57
if !_Fixes			;fix: check correct byte for status reporting
	AND #$04
else
	AND #$08							;C2/6CB7: 29 08        AND #$08
endif
	BEQ .Ret							;C2/6CB9: F0 25        BEQ $6CE0
	LDX TargetOffset						;C2/6CBB: A6 49        LDX $49
	LDA CharStruct.Status1,X					;C2/6CBD: BD 1A 20     LDA $201A,X  (Scan Status Effect 1)
	STA $13								;C2/6CC0: 85 13        STA $13
	LDA CharStruct.Status2,X					;C2/6CC2: BD 1B 20     LDA $201B,X  (Scan Status Effect 2)
	STA $12								;C2/6CC5: 85 12        STA $12
	LDX $0E								;C2/6CC7: A6 0E        LDX $0E
	TDC 								;C2/6CC9: 7B           TDC 
	TAY 								;C2/6CCA: A8           TAY 
	LDA #$00		;message to display (incremented later)	;C2/6CCB: A9 00        LDA #$00
.StatusLoop			;loop through status effects (1 and 2)
	INC 								;C2/6CCD: 1A           INC 
	ASL $12								;C2/6CCE: 06 12        ASL $12
	ROL $13								;C2/6CD0: 26 13        ROL $13
	BCC +								;C2/6CD2: 90 06        BCC $6CDA
	STA MessageBoxes,X						;C2/6CD4: 9D 5F 3C     STA $3C5F,X
	INX 								;C2/6CD7: E8           INX 
	INC $0E								;C2/6CD8: E6 0E        INC $0E
+	INY 								;C2/6CDA: C8           INY 
	CPY #$0010							;C2/6CDB: C0 10 00     CPY #$0010
	BNE .StatusLoop							;C2/6CDE: D0 ED        BNE $6CCD
.Ret	RTS								;C2/6CE0: 60           RTS
									;
.Miss	INC AtkMissed							;C2/6CE1: E6 56        INC $56
	RTS								;C2/6CE3: 60           RTS

endif