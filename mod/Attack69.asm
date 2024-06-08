if !_Optimize


;Attack Type 69 (Control)
;**optimize: rearranged routine to use branches instead of jumps, saves a few bytes
Attack69:
	JSR SetupMsgBoxIndexes	;sets Y=MessageBoxData index		;C2/77E9: 20 65 99     JSR $9965
	STX $14			;MessageBoxes index			;C2/77EC: 86 14        STX $14
	LDX TargetOffset						;C2/77EE: A6 49        LDX $49
	LDA CharStruct.Status2,X					;C2/77F0: BD 1B 20     LDA $201B,X
	AND #$18     		;Charm/Berserk				;C2/77F3: 29 18        AND #$18     (Can't Control if Target Status2 = Charm or Berserk)
	BNE .Immune							;C2/77F5: F0 03        BEQ $77FA
									;C2/77F7: 4C AE 78     JMP $78AE
	LDA CharStruct.Status4,X					;C2/77FA: BD 1D 20     LDA $201D,X
	AND #$20     		;Controlled				;C2/77FD: 29 20        AND #$20     (Can't Control if Target Status4 = Control)
	BNE .Already							;C2/77FF: F0 03        BEQ $7804
									;C2/7801: 4C B2 78     JMP $78B2
	LDA CharStruct.CmdImmunity,X  					;C2/7804: BD 66 20     LDA $2066,X  (Check for Immunity to Control)
	AND #$10		;Control Immunity			;C2/7807: 29 10        AND #$10
	BNE .Immune							;C2/7809: F0 03        BEQ $780E
									;C2/780B: 4C AE 78     JMP $78AE
	JSR Random_0_99   						;C2/780E: 20 A2 02     JSR $02A2   (0..99)
	STA $0E			;0..99					;C2/7811: 85 0E        STA $0E
	LDX AttackerOffset						;C2/7813: A6 32        LDX $32
	LDA CharStruct.Headgear,X					;C2/7815: BD 0E 20     LDA $200E,X
	CMP #$CB    		;Hardcoded Coronet id   		;C2/7818: C9 CB        CMP #$CB    (If Attacker is wearing Coronet)
	BNE .NoCoronet							;C2/781A: D0 08        BNE $7824

	LDA #$4B		;75% with coronet
	BRA .CheckSuccess
.NoCoronet
	LDA #$28		;40% without
.CheckSuccess
	CMP $0E
	BCC .Miss
	BRA .Success
	
.Immune								
	LDA #$4E		;can't control message		
	BRA +							
.Already
	LDA #$4C		;already controlled message	
+	LDX $14							
	STA MessageBoxes,X					
.Miss	INC AtkMissed						
	RTS 							

.Success
	LDX TargetOffset						;C2/782D: A6 49        LDX $49
	LDA #$80							;C2/782F: A9 80        LDA #$80
	STA CharStruct.ActionFlag,X					;C2/7831: 9D 56 20     STA $2056,X
	STZ CharStruct.Command,X					;C2/7834: 9E 57 20     STZ $2057,X
	LDA CharStruct.Status4,X					;C2/7837: BD 1D 20     LDA $201D,X
	ORA #$20     		;Controlled				;C2/783A: 09 20        ORA #$20     (Inflict Control Status4 on target)
	STA CharStruct.Status4,X					;C2/783C: 9D 1D 20     STA $201D,X
	LDA AttackerIndex						;C2/783F: A5 47        LDA $47
	TAX 								;C2/7841: AA           TAX 
	STZ ControlCommand,X						;C2/7842: 9E 3E 7C     STZ $7C3E,X
	LDA TargetIndex							;C2/7845: A5 48        LDA $48
	STA ControlTarget,X						;C2/7847: 9D 3A 7C     STA $7C3A,X
	LDA AttackerIndex						;C2/784A: A5 47        LDA $47
	TAX 								;C2/784C: AA           TAX 
	LDA ROMTimes20,X	;*20					;C2/784D: BF DB EE D0  LDA $D0EEDB,X
	TAY 								;C2/7851: A8           TAY 
	STY $10			;attacker index * structure size	;C2/7852: 84 10        STY $10
	SEC 								;C2/7854: 38           SEC 
	LDA TargetIndex							;C2/7855: A5 48        LDA $48
	SBC #$04		;now monster index			;C2/7857: E9 04        SBC #$04
	ASL 								;C2/7859: 0A           ASL 
	TAX 								;C2/785A: AA           TAX 
	REP #$20							;C2/785B: C2 20        REP #$20
	LDA BattleMonsterID,X						;C2/785D: BD 20 40     LDA $4020,X
	JSR ShiftMultiply_4						;C2/7860: 20 B7 01     JSR $01B7
	TAX 								;C2/7863: AA           TAX 
	TDC 								;C2/7864: 7B           TDC 
	SEP #$20							;C2/7865: E2 20        SEP #$20
	STZ $0E			;loop index				;C2/7867: 64 0E        STZ $0E

.CopyActionsLoop
	LDA ROMControlActions,X						;C2/7869: BF 00 56 D0  LDA $D05600,X
	STA CharControl.Actions,Y					;C2/786D: 99 DC 37     STA $37DC,Y
	CMP #$FF							;C2/7870: C9 FF        CMP #$FF
	BNE +								;C2/7872: D0 04        BNE $7878
	LDA #$80							;C2/7874: A9 80        LDA #$80
	BRA ++								;C2/7876: 80 01        BRA $7879
+	TDC 								;C2/7878: 7B           TDC 
++	STA CharControl.Flags,Y						;C2/7879: 99 EC 37     STA $37EC,Y
	INX 								;C2/787C: E8           INX 
	INY 								;C2/787D: C8           INY 
	INC $0E								;C2/787E: E6 0E        INC $0E
	LDA $0E								;C2/7880: A5 0E        LDA $0E
	CMP #$04							;C2/7882: C9 04        CMP #$04
	BNE .CopyActionsLoop						;C2/7884: D0 E3        BNE $7869

	STZ $0E			;loop index				;C2/7886: 64 0E        STZ $0E
	LDY $10			;attacker index * structure size	;C2/7888: A4 10        LDY $10

.CopyTargettingLoop
	LDA CharControl.Actions,Y					;C2/788A: B9 DC 37     LDA $37DC,Y
	REP #$20							;C2/788D: C2 20        REP #$20
	JSR ShiftMultiply_8						;C2/788F: 20 B6 01     JSR $01B6
	TAX 								;C2/7892: AA           TAX 
	TDC 								;C2/7893: 7B           TDC 
	SEP #$20							;C2/7894: E2 20        SEP #$20
	LDA ROMMagicInfo.Targetting,X					;C2/7896: BF 80 0B D1  LDA $D10B80,X
	STA CharControl.Targetting,Y					;C2/789A: 99 E8 37     STA $37E8,Y
	INY 								;C2/789D: C8           INY 
	INC $0E								;C2/789E: E6 0E        INC $0E
	LDA $0E								;C2/78A0: A5 0E        LDA $0E
	CMP #$04							;C2/78A2: C9 04        CMP #$04
	BNE .CopyTargettingLoop						;C2/78A4: D0 E4        BNE $788A

	LDX $14			;MessageBoxes index			;C2/78A6: A6 14        LDX $14
	LDA #$24		;success message			;C2/78A8: A9 24        LDA #$24
	STA MessageBoxes,X						;C2/78AA: 9D 5F 3C     STA $3C5F,X
	RTS 								;C2/78AD: 60           RTS 

endif