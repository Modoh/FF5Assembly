if !_Fixes

;Checks for Reflect and Cover and changes target if needed
;
;fixes: repairs check for always charm status (which doesn't exist, but they tried)
CheckTargetRedirect:
	LDA AttackerOffset2						;C2/9561: A5 39        LDA $39
	TAX 								;C2/9563: AA           TAX 
	LDA AttackInfo.Category,X					;C2/9564: BD FD 79     LDA $79FD,X
	AND #$0F		;Time/Black/White/Blue Magic		;C2/9567: 29 0F        AND #$0F
	BNE .Magic							;C2/9569: D0 02        BNE $956D
	BRA .Bypass							;C2/956B: 80 11        BRA $957E

.Magic	LDA AttackInfo.MPCost,X	;high bit is reflect			;C2/956D: BD FF 79     LDA $79FF,X
	BPL .CheckReflect						;C2/9570: 10 02        BPL $9574
	BRA .Bypass							;C2/9572: 80 0A        BRA $957E

.CheckReflect
	LDX TargetOffset						;C2/9574: A6 49        LDX $49
	LDA CharStruct.Status3,X					;C2/9576: BD 1C 20     LDA $201C,X
	ORA CharStruct.AlwaysStatus3,X					;C2/9579: 1D 72 20     ORA $2072,X
	BMI .Reflected							;C2/957C: 30 03        BMI $9581
.Bypass	JMP .DoneReflect						;C2/957E: 4C 14 96     JMP $9614

.Reflected
	LDA CharStruct.CharRow,X					;C2/9581: BD 00 20     LDA $2000,X
	AND #$40		;not on the team? 			;C2/9584: 29 40        AND #$40
	BNE .Bypass							;C2/9586: D0 F6        BNE $957E
	LDA CharStruct.Status4,X					;C2/9588: BD 1D 20     LDA $201D,X
	AND #$C1		;Erased/False Image/Hidden		;C2/958B: 29 C1        AND #$C1
	BNE .Bypass							;C2/958D: D0 EF        BNE $957E
	LDA CharStruct.CmdStatus,X					;C2/958F: BD 1E 20     LDA $201E,X
	AND #$10		;Jumping				;C2/9592: 29 10        AND #$10
	BNE .Bypass							;C2/9594: D0 E8        BNE $957E
	INC Reflected							;C2/9596: EE 46 7B     INC $7B46
	STZ $0E			;0					;C2/9599: 64 0E        STZ $0E
	LDA #$03							;C2/959B: A9 03        LDA #$03
	STA $0F			;3 by default reflecting to party 0-3	;C2/959D: 85 0F        STA $0F
	LDA TargetIndex							;C2/959F: A5 48        LDA $48
	STA $10			;Target Index				;C2/95A1: 85 10        STA $10
	CMP #$04		;monster check				;C2/95A3: C9 04        CMP #$04
	BCS +								;C2/95A5: B0 08        BCS $95AF
	LDA #$04							;C2/95A7: A9 04        LDA #$04
	STA $0E			;4					;C2/95A9: 85 0E        STA $0E
	LDA #$0B							;C2/95AB: A9 0B        LDA #$0B
	STA $0F			;11	reflecting to monsters 4-11	;C2/95AD: 85 0F        STA $0F

+	LDA $10			;Target Index				;C2/95AF: A5 10        LDA $10
	CMP #$04							;C2/95B1: C9 04        CMP #$04
	BCC +								;C2/95B3: 90 03        BCC $95B8
	SEC 								;C2/95B5: 38           SEC 
	SBC #$04							;C2/95B6: E9 04        SBC #$04
+	TAX 			;now either party or monster index	;C2/95B8: AA           TAX 
	TDC 								;C2/95B9: 7B           TDC 
	JSR SetBit_X							;C2/95BA: 20 D6 01     JSR $01D6
	STA ReflectorBitmask						;C2/95BD: 8D 42 7B     STA $7B42
	JSR CheckValidTargetsExist2					;C2/95C0: 20 28 97     JSR $9728
	LDA $11			;no valid targets if set		;C2/95C3: A5 11        LDA $11
	BEQ .PickRandomTarget						;C2/95C5: F0 08        BEQ $95CF
	TDC 								;C2/95C7: 7B           TDC 
	STA TargetIndex							;C2/95C8: 85 48        STA $48
	TAX 								;C2/95CA: AA           TAX 
	STX TargetOffset	;give up and zap the first party member	;C2/95CB: 86 49        STX $49
	BRA .DoneReflect						;C2/95CD: 80 45        BRA $9614

.PickRandomTarget
	LDA $0E			;min target index			;C2/95CF: A5 0E        LDA $0E
	TAX 								;C2/95D1: AA           TAX 
	LDA $0F			;max target index			;C2/95D2: A5 0F        LDA $0F
	JSR Random_X_A							;C2/95D4: 20 7C 00     JSR $007C
	STA $10			;new target index			;C2/95D7: 85 10        STA $10
	TAY 								;C2/95D9: A8           TAY 
	LDA ActiveParticipants,Y					;C2/95DA: B9 C2 3E     LDA $3EC2,Y
	BEQ .PickRandomTarget						;C2/95DD: F0 F0        BEQ $95CF
	LDA $10								;C2/95DF: A5 10        LDA $10
	REP #$20							;C2/95E1: C2 20        REP #$20
	JSR ShiftMultiply_128						;C2/95E3: 20 B2 01     JSR $01B2
	TAX 								;C2/95E6: AA           TAX 
	STX TargetOffset						;C2/95E7: 86 49        STX $49
	TDC 								;C2/95E9: 7B           TDC 
	SEP #$20							;C2/95EA: E2 20        SEP #$20
	LDA CharStruct.Status1,X					;C2/95EC: BD 1A 20     LDA $201A,X
	AND #$C0		;Stone or Dead				;C2/95EF: 29 C0        AND #$C0
	BNE .PickRandomTarget						;C2/95F1: D0 DC        BNE $95CF
	LDA CharStruct.Status4,X					;C2/95F3: BD 1D 20     LDA $201D,X
	AND #$81		;Erased or Hidden			;C2/95F6: 29 81        AND #$81
	BNE .PickRandomTarget						;C2/95F8: D0 D5        BNE $95CF
	LDA CharStruct.CmdStatus,X					;C2/95FA: BD 1E 20     LDA $201E,X
	AND #$10		;Jumping				;C2/95FD: 29 10        AND #$10
	BNE .PickRandomTarget						;C2/95FF: D0 CE        BNE $95CF
	LDA $10								;C2/9601: A5 10        LDA $10
	STA TargetIndex		;new target index			;C2/9603: 85 48        STA $48
	CMP #$04		;monster check				;C2/9605: C9 04        CMP #$04
	BCC +								;C2/9607: 90 03        BCC $960C
	SEC 								;C2/9609: 38           SEC 
	SBC #$04		;now party or monster index		;C2/960A: E9 04        SBC #$04
+	TAX 								;C2/960C: AA           TAX 
	TDC 								;C2/960D: 7B           TDC 
	JSR SetBit_X							;C2/960E: 20 D6 01     JSR $01D6
	STA ReflecteeBitmask						;C2/9611: 8D 43 7B     STA $7B43

.DoneReflect
	LDA AttackerIndex						;C2/9614: A5 47        LDA $47
	CMP #$04		;monster check				;C2/9616: C9 04        CMP #$04
	BCS .MonAttacker						;C2/9618: B0 01        BCS $961B
	RTS 								;C2/961A: 60           RTS 
									;
.MonAttacker								
	LDA TargetIndex							;C2/961B: A5 48        LDA $48
	CMP #$04		;monster check				;C2/961D: C9 04        CMP #$04
	BCC .MonVsParty							;C2/961F: 90 01        BCC $9622
	RTS 								;C2/9621: 60           RTS 

.MonVsParty
	LDA MultiCommand						;C2/9622: AD 2C 7B     LDA $7B2C
	TAX 								;C2/9625: AA           TAX 
	LDA AtkType,X							;C2/9626: BD 2D 7B     LDA $7B2D,X
	CMP #$01		;Monster Fight				;C2/9629: C9 01        CMP #$01
	BEQ .CheckCoverTarget						;C2/962B: F0 05        BEQ $9632
	CMP #$02		;Monster Specialty			;C2/962D: C9 02        CMP #$02
	BEQ .CheckCoverTarget						;C2/962F: F0 01        BEQ $9632
	RTS 								;C2/9631: 60           RTS 

.CheckCoverTarget
	LDX TargetOffset						;C2/9632: A6 49        LDX $49
	LDA CharStruct.CmdStatus,X					;C2/9634: BD 1E 20     LDA $201E,X
	AND #$10		;Jumping				;C2/9637: 29 10        AND #$10
	BNE .EarlyRet		;don't cover jumpers			;C2/9639: D0 11        BNE $964C
	LDA CharStruct.Status4,X					;C2/963B: BD 1D 20     LDA $201D,X
	AND #$02		;Critical (return if not)		;C2/963E: 29 02        AND #$02
	BEQ .EarlyRet		;only cover critical health		;C2/9640: F0 0A        BEQ $964C
	LDA CharStruct.Status2,X					;C2/9642: BD 1B 20     LDA $201B,X
	ORA CharStruct.AlwaysStatus2,X	;*was a  duplicate of above 	;C2/9645: 1D 1B 20     ORA $201B,X
	AND #$10		;Charm					;C2/9648: 29 10        AND #$10
	BEQ .Cover		;don't cover charmed targets		;C2/964A: F0 01        BEQ $964D
.EarlyRet
	RTS 								;C2/964C: 60           RTS 

.Cover
	LDA EarthWallHP							;C2/964D: AD 1E 7C     LDA $7C1E
	ORA EarthWallHP+1						;C2/9650: 0D 1F 7C     ORA $7C1F
	BNE .EarlyRet		;don't cover if earth wall is doing it	;C2/9653: D0 F7        BNE $964C
	TDC 								;C2/9655: 7B           TDC 
	TAX 								;C2/9656: AA           TAX 
	STX $0E			;index for search loop			;C2/9657: 86 0E        STX $0E
	STX $10			;number of found members that can cover	;C2/9659: 86 10        STX $10

.FindCoverLoop	;searches for party members that can cover, stores their indexes at $2620
	LDY $0E								;C2/965B: A4 0E        LDY $0E
	LDA ActiveParticipants,Y					;C2/965D: B9 C2 3E     LDA $3EC2,Y
	BEQ .Next							;C2/9660: F0 3B        BEQ $969D
	LDA CharStruct.Passives2,X					;C2/9662: BD 21 20     LDA $2021,X
	BPL .Next  		;80h is Cover 				;C2/9665: 10 36        BPL $969D    
	LDA CharStruct.Status1,X					;C2/9667: BD 1A 20     LDA $201A,X  
	ORA CharStruct.AlwaysStatus1,X					;C2/966A: 1D 70 20     ORA $2070,X
	AND #$42		;Stone or Zombie			;C2/966D: 29 42        AND #$42
	BNE .Next							;C2/966F: D0 2C        BNE $969D
	LDA CharStruct.Status2,X					;C2/9671: BD 1B 20     LDA $201B,X
	ORA CharStruct.AlwaysStatus2,X					;C2/9674: 1D 71 20     ORA $2071,X
	AND #$78   		;Sleep/Paralyze/Charm/Berserk		;C2/9677: 29 78        AND #$78     
	BNE .Next							;C2/9679: D0 22        BNE $969D
	LDA CharStruct.Status3,X					;C2/967B: BD 1C 20     LDA $201C,X  
	AND #$10   		;Stop					;C2/967E: 29 10        AND #$10     
	BNE .Next							;C2/9680: D0 1B        BNE $969D
	LDA CharStruct.Status4,X					;C2/9682: BD 1D 20     LDA $201D,X
	AND #$81   		;Erased or Hidden			;C2/9685: 29 81        AND #$81     
	BNE .Next							;C2/9687: D0 14        BNE $969D
	LDA CharStruct.CmdStatus,X					;C2/9689: BD 1E 20     LDA $201E,X
	AND #$10   		;Jumping				;C2/968C: 29 10        AND #$10     
	BNE .Next							;C2/968E: D0 0D        BNE $969D
	LDY $10								;C2/9690: A4 10        LDY $10
	LDA $0E								;C2/9692: A5 0E        LDA $0E
	CMP TargetIndex		;can't cover yourself			;C2/9694: C5 48        CMP $48
	BEQ .Next							;C2/9696: F0 05        BEQ $969D
	STA Temp,Y		;temp area, store coverer's index	;C2/9698: 99 20 26     STA $2620,Y
	INC $10								;C2/969B: E6 10        INC $10
.Next	JSR NextCharOffset						;C2/969D: 20 E0 01     JSR $01E0
	INC $0E								;C2/96A0: E6 0E        INC $0E
	LDA $0E								;C2/96A2: A5 0E        LDA $0E
	CMP #$04							;C2/96A4: C9 04        CMP #$04
	BNE .FindCoverLoop						;C2/96A6: D0 B3        BNE $965B

	LDA $10			;number of found members that can cover	;C2/96A8: A5 10        LDA $10
	BEQ .Ret							;C2/96AA: F0 7B        BEQ $9727
	LDX AttackerOffset						;C2/96AC: A6 32        LDX $32
	PHX 								;C2/96AE: DA           PHX 
	TDC 								;C2/96AF: 7B           TDC 
	TAX 								;C2/96B0: AA           TAX 
	STX $0E			;loop index, 				;C2/96B1: 86 0E        STX $0E
	STX $12			;offset into health storage		;C2/96B3: 86 12        STX $12

.CopyCoverHP
	LDX $0E								;C2/96B5: A6 0E        LDX $0E
	LDA Temp,X		;coverer's index			;C2/96B7: BD 20 26     LDA $2620,X
	JSR CalculateCharOffset						;C2/96BA: 20 EC 01     JSR $01EC
	LDY $12								;C2/96BD: A4 12        LDY $12
	REP #$20							;C2/96BF: C2 20        REP #$20
	LDA CharStruct.CurHP,X						;C2/96C1: BD 06 20     LDA $2006,X
	STA $262A,Y		;temp area, now holds current hp	;C2/96C4: 99 2A 26     STA $262A,Y
	TDC 								;C2/96C7: 7B           TDC 
	SEP #$20							;C2/96C8: E2 20        SEP #$20
	INC $12								;C2/96CA: E6 12        INC $12
	INC $12								;C2/96CC: E6 12        INC $12
	INC $0E								;C2/96CE: E6 0E        INC $0E
	LDA $0E								;C2/96D0: A5 0E        LDA $0E
	CMP $10			;number of members that can cover	;C2/96D2: C5 10        CMP $10
	BNE .CopyCoverHP						;C2/96D4: D0 DF        BNE $96B5
	
	ASL $10			;number of members that can cover * 2	;C2/96D6: 06 10        ASL $10
	TDC 								;C2/96D8: 7B           TDC 
	TAX 								;C2/96D9: AA           TAX 
	STX $0E			;offset into temp health storage	;C2/96DA: 86 0E        STX $0E
	STX $12			;highest found hp 			;C2/96DC: 86 12        STX $12
	STX $14			;index of coverer with highest found hp	;C2/96DE: 86 14        STX $14

.FindHighestHP	;finds the covering party member with the highest health, stores their index in $14
	REP #$20							;C2/96E0: C2 20        REP #$20
	LDX $0E								;C2/96E2: A6 0E        LDX $0E
	LDA $262A,X		;current hp				;C2/96E4: BD 2A 26     LDA $262A,X
	CMP $12			;highest found hp 			;C2/96E7: C5 12        CMP $12
	BCC .NextHP							;C2/96E9: 90 10        BCC $96FB
	STA $12			;highest found hp 			;C2/96EB: 85 12        STA $12
	TDC 								;C2/96ED: 7B           TDC 
	SEP #$20							;C2/96EE: E2 20        SEP #$20
	LDA $0E								;C2/96F0: A5 0E        LDA $0E
	LSR 								;C2/96F2: 4A           LSR 
	TAX 								;C2/96F3: AA           TAX 
	LDA Temp,X		;coverer's index			;C2/96F4: BD 20 26     LDA $2620,X
	STA $14			;index of coverer with highest found hp	;C2/96F7: 85 14        STA $14
	BRA .NextHP8b							;C2/96F9: 80 03        BRA $96FE
.NextHP
	TDC 								;C2/96FB: 7B           TDC 
	SEP #$20							;C2/96FC: E2 20        SEP #$20
.NextHP8b
	INC $0E								;C2/96FE: E6 0E        INC $0E
	INC $0E								;C2/9700: E6 0E        INC $0E
	LDA $0E								;C2/9702: A5 0E        LDA $0E
	CMP $10			;number of members that can cover * 2	;C2/9704: C5 10        CMP $10
	BNE .FindHighestHP						;C2/9706: D0 D8        BNE $96E0

	LDA TargetIndex							;C2/9708: A5 48        LDA $48
	TAX 								;C2/970A: AA           TAX 
	TDC 								;C2/970B: 7B           TDC 
	JSR SetBit_X							;C2/970C: 20 D6 01     JSR $01D6
	STA CoveredBitmask						;C2/970F: 8D 44 7B     STA $7B44
	LDA $14			;index of coverer with highest found hp	;C2/9712: A5 14        LDA $14
	STA TargetIndex		;now the new target			;C2/9714: 85 48        STA $48
	STA AnotherTargetIndex						;C2/9716: 8D 45 7B     STA $7B45
	REP #$20							;C2/9719: C2 20        REP #$20
	JSR ShiftMultiply_128						;C2/971B: 20 B2 01     JSR $01B2
	TAX 								;C2/971E: AA           TAX 
	STX TargetOffset						;C2/971F: 86 49        STX $49
	TDC 								;C2/9721: 7B           TDC 
	SEP #$20							;C2/9722: E2 20        SEP #$20
	PLX 			;Restore attacker offset, though	;C2/9724: FA           PLX 
	STX AttackerOffset	; not sure if it was ever changed?	;C2/9725: 86 32        STX $32
.Ret	RTS 								;C2/9727: 60           RTS 
	
endif