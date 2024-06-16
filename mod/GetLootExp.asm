if !_Fixes

;Fixes: ensures that the blue magic learning loop doesn't go out of range when 8 spells are learned

;Adds Gil, Exp and AP from monsters
;queues up any item drops to be collected later
;applies level and job level ups
%subdef(GetLootExp)
	LDA MonsterKillTracker							;C2/52A2: AD 09 7C     LDA $7C09
	EOR #$FF								;C2/52A5: 49 FF        EOR #$FF
	STA MonsterKillTracker	;inverted, anything killed is now set		;C2/52A7: 8D 09 7C     STA $7C09
	JSR CountSetBits     							;C2/52AA: 20 C3 01     JSR $01C3      
	REP #$20								;C2/52AD: C2 20        REP #$20
	TXA 									;C2/52AF: 8A           TXA 
	CLC 									;C2/52B0: 18           CLC 
	ADC MonsterKillCount							;C2/52B1: 6D 4E 09     ADC $094E
	BCC +									;C2/52B4: 90 03        BCC $52B9
	LDA #$FFFF		;max 65535 tracked kills			;C2/52B6: A9 FF FF     LDA #$FFFF
+	STA MonsterKillCount							;C2/52B9: 8D 4E 09     STA $094E
	TDC 									;C2/52BC: 7B           TDC 
	SEP #$20								;C2/52BD: E2 20        SEP #$20
	TDC 									;C2/52BF: 7B           TDC 
	TAX 									;C2/52C0: AA           TAX 
	STX VictoryGil								;C2/52C1: 8E 0B 7C     STX $7C0B
	STX VictoryGil+2	;also clears first byte of VictoryExp		;C2/52C4: 8E 0D 7C     STX $7C0D
	STX VictoryExp+1							;C2/52C7: 8E 0F 7C     STX $7C0F
	STX TempMonsterIndex							;C2/52CA: 86 3D        STX $3D
	LDY #$0200		;first monster offset				;C2/52CC: A0 00 02     LDY #$0200
	STY TempMonsterOffset							;C2/52CF: 84 3F        STY $3F

.TallyLoot	;gil, exp and drops
	LDX TempMonsterIndex	;monster index					;C2/52D1: A6 3D        LDX $3D
	LDA MonsterKillTracker							;C2/52D3: AD 09 7C     LDA $7C09
	JSR SelectBit_X    							;C2/52D6: 20 DB 01     JSR $01DB      
	BEQ .NextLoot								;C2/52D9: F0 39        BEQ $5314
	CLC 									;C2/52DB: 18           CLC 
	LDA VictoryGil								;C2/52DC: AD 0B 7C     LDA $7C0B
	ADC CharStruct.RewardGil,Y						;C2/52DF: 79 69 20     ADC $2069,Y
	STA VictoryGil								;C2/52E2: 8D 0B 7C     STA $7C0B
	LDA VictoryGil+1							;C2/52E5: AD 0C 7C     LDA $7C0C
	ADC CharStruct.RewardGil+1,Y						;C2/52E8: 79 6A 20     ADC $206A,Y
	STA VictoryGil+1							;C2/52EB: 8D 0C 7C     STA $7C0C
	LDA VictoryGil+2							;C2/52EE: AD 0D 7C     LDA $7C0D
	ADC #$00		;for carry					;C2/52F1: 69 00        ADC #$00
	STA VictoryGil+2							;C2/52F3: 8D 0D 7C     STA $7C0D
	CLC 									;C2/52F6: 18           CLC 
	LDA VictoryExp								;C2/52F7: AD 0E 7C     LDA $7C0E
	ADC CharStruct.RewardExp,Y						;C2/52FA: 79 67 20     ADC $2067,Y
	STA VictoryExp								;C2/52FD: 8D 0E 7C     STA $7C0E
	LDA VictoryExp+1							;C2/5300: AD 0F 7C     LDA $7C0F
	ADC CharStruct.RewardExp+1,Y						;C2/5303: 79 68 20     ADC $2068,Y
	STA VictoryExp+1							;C2/5306: 8D 0F 7C     STA $7C0F
	LDA VictoryExp+2							;C2/5309: AD 10 7C     LDA $7C10
	ADC #$00		;for carry					;C2/530C: 69 00        ADC #$00
	STA VictoryExp+2							;C2/530E: 8D 10 7C     STA $7C10
	JSR DropMonsterLoot							;C2/5311: 20 9A 56     JSR $569A
.NextLoot
	LDY TempMonsterOffset							;C2/5314: A4 3F        LDY $3F
	REP #$20								;C2/5316: C2 20        REP #$20
	TYA 									;C2/5318: 98           TYA 
	CLC 									;C2/5319: 18           CLC 
	ADC #$0080		;next monster offset				;C2/531A: 69 80 00     ADC #$0080
	TAY 									;C2/531D: A8           TAY 
	TDC 									;C2/531E: 7B           TDC 
	SEP #$20								;C2/531F: E2 20        SEP #$20
	STY TempMonsterOffset							;C2/5321: 84 3F        STY $3F
	INC TempMonsterIndex	;monster index					;C2/5323: E6 3D        INC $3D
	LDA TempMonsterIndex							;C2/5325: A5 3D        LDA $3D
	CMP #$08		;8 monsters					;C2/5327: C9 08        CMP #$08
	BNE .TallyLoot								;C2/5329: D0 A6        BNE $52D1

	CLC 									;C2/532B: 18           CLC 
	LDA Gil									;C2/532C: AD 47 09     LDA $0947
	ADC VictoryGil								;C2/532F: 6D 0B 7C     ADC $7C0B
	STA Gil									;C2/5332: 8D 47 09     STA $0947
	LDA Gil+1								;C2/5335: AD 48 09     LDA $0948
	ADC VictoryGil+1							;C2/5338: 6D 0C 7C     ADC $7C0C
	STA Gil+1								;C2/533B: 8D 48 09     STA $0948
	LDA Gil+2								;C2/533E: AD 49 09     LDA $0949
	ADC VictoryGil+2							;C2/5341: 6D 0D 7C     ADC $7C0D
	STA Gil+2								;C2/5344: 8D 49 09     STA $0949
	SEC 			;cap gil at 9999999				;C2/5347: 38           SEC 
	LDA Gil									;C2/5348: AD 47 09     LDA $0947
	SBC #$7F								;C2/534B: E9 7F        SBC #$7F
	LDA Gil+1								;C2/534D: AD 48 09     LDA $0948
	SBC #$96								;C2/5350: E9 96        SBC #$96
	LDA Gil+2								;C2/5352: AD 49 09     LDA $0949
	SBC #$98								;C2/5355: E9 98        SBC #$98
	BCC .AddAP								;C2/5357: 90 0F        BCC $5368
	LDA #$7F								;C2/5359: A9 7F        LDA #$7F
	STA Gil									;C2/535B: 8D 47 09     STA $0947
	LDA #$96								;C2/535E: A9 96        LDA #$96
	STA Gil+1								;C2/5360: 8D 48 09     STA $0948
	LDA #$98								;C2/5363: A9 98        LDA #$98
	STA Gil+2								;C2/5365: 8D 49 09     STA $0949

.AddAP
	LDA EncounterInfo.AP							;C2/5368: AD F1 3E     LDA $3EF1
	TAX 									;C2/536B: AA           TAX 
	STX $0E			;encounter ap					;C2/536C: 86 0E        STX $0E
	TDC 									;C2/536E: 7B           TDC 
	TAX 									;C2/536F: AA           TAX 
	STX $10									;C2/5370: 86 10        STX $10
	STX $12									;C2/5372: 86 12        STX $12
.APLoop
	LDA $12			;char index					;C2/5374: A5 12        LDA $12
	TAY 									;C2/5376: A8           TAY 
	LDA ActiveParticipants,Y						;C2/5377: B9 C2 3E     LDA $3EC2,Y
	BEQ .NextAP								;C2/537A: F0 15        BEQ $5391
	INC $10			;count of active chars				;C2/537C: E6 10        INC $10
	REP #$20								;C2/537E: C2 20        REP #$20
	CLC 									;C2/5380: 18           CLC 
	LDA CharStruct.AP,X							;C2/5381: BD 3B 20     LDA $203B,X
	ADC $0E			;encounter ap					;C2/5384: 65 0E        ADC $0E
	BCC +									;C2/5386: 90 03        BCC $538B
	LDA #$FFFF		;cap at 65535					;C2/5388: A9 FF FF     LDA #$FFFF
+	STA CharStruct.AP,X							;C2/538B: 9D 3B 20     STA $203B,X
	TDC 									;C2/538E: 7B           TDC 
	SEP #$20								;C2/538F: E2 20        SEP #$20
.NextAP
	JSR NextCharOffset							;C2/5391: 20 E0 01     JSR $01E0      
	INC $12			;char index					;C2/5394: E6 12        INC $12
	LDA $12									;C2/5396: A5 12        LDA $12
	CMP #$04		;4 chars					;C2/5398: C9 04        CMP #$04
	BNE .APLoop								;C2/539A: D0 D8        BNE $5374

	LDA VictoryExp								;C2/539C: AD 0E 7C     LDA $7C0E
	ORA VictoryExp+1							;C2/539F: 0D 0F 7C     ORA $7C0F
	ORA VictoryExp+2							;C2/53A2: 0D 10 7C     ORA $7C10
	BEQ +									;C2/53A5: F0 03        BEQ $53AA
	JSR DivideExp								;C2/53A7: 20 E6 57     JSR $57E6
+	LDA MonsterKillTracker							;C2/53AA: AD 09 7C     LDA $7C09
	BNE .AddExp								;C2/53AD: D0 09        BNE $53B8
	STZ VictoryExp		;didn't kill anything, so no exp		;C2/53AF: 9C 0E 7C     STZ $7C0E
	STZ VictoryExp+1							;C2/53B2: 9C 0F 7C     STZ $7C0F
	STZ VictoryExp+2							;C2/53B5: 9C 10 7C     STZ $7C10

.AddExp
	TDC 									;C2/53B8: 7B           TDC 
	TAX 									;C2/53B9: AA           TAX 
	STX $0E									;C2/53BA: 86 0E        STX $0E
.ExpLoop
	LDA $0E				;char index				;C2/53BC: A5 0E        LDA $0E
	TAY 									;C2/53BE: A8           TAY 
	LDA ActiveParticipants,Y						;C2/53BF: B9 C2 3E     LDA $3EC2,Y
	BEQ .NextExp								;C2/53C2: F0 3D        BEQ $5401
	CLC 									;C2/53C4: 18           CLC 
	LDA CharStruct.Exp,X							;C2/53C5: BD 03 20     LDA $2003,X
	ADC VictoryExp								;C2/53C8: 6D 0E 7C     ADC $7C0E
	STA CharStruct.Exp,X							;C2/53CB: 9D 03 20     STA $2003,X
	LDA CharStruct.Exp+1,X							;C2/53CE: BD 04 20     LDA $2004,X
	ADC VictoryExp+1							;C2/53D1: 6D 0F 7C     ADC $7C0F
	STA CharStruct.Exp+1,X							;C2/53D4: 9D 04 20     STA $2004,X
	LDA CharStruct.Exp+2,X							;C2/53D7: BD 05 20     LDA $2005,X
	ADC VictoryExp+2							;C2/53DA: 6D 10 7C     ADC $7C10
	STA CharStruct.Exp+2,X							;C2/53DD: 9D 05 20     STA $2005,X
	SEC 									;C2/53E0: 38           SEC 
	LDA CharStruct.Exp,X		;cap exp at 9999999			;C2/53E1: BD 03 20     LDA $2003,X
	SBC #$7F								;C2/53E4: E9 7F        SBC #$7F
	LDA CharStruct.Exp+1,X							;C2/53E6: BD 04 20     LDA $2004,X
	SBC #$96								;C2/53E9: E9 96        SBC #$96
	LDA CharStruct.Exp+2,X							;C2/53EB: BD 05 20     LDA $2005,X
	SBC #$98								;C2/53EE: E9 98        SBC #$98
	BCC .NextExp								;C2/53F0: 90 0F        BCC $5401
	LDA #$7F								;C2/53F2: A9 7F        LDA #$7F
	STA CharStruct.Exp,X							;C2/53F4: 9D 03 20     STA $2003,X
	LDA #$96								;C2/53F7: A9 96        LDA #$96
	STA CharStruct.Exp+1,X							;C2/53F9: 9D 04 20     STA $2004,X
	LDA #$98								;C2/53FC: A9 98        LDA #$98
	STA CharStruct.Exp+2,X							;C2/53FE: 9D 05 20     STA $2005,X
.NextExp
	JSR NextCharOffset  							;C2/5401: 20 E0 01     JSR $01E0      
	INC $0E				;char index				;C2/5404: E6 0E        INC $0E
	LDA $0E									;C2/5406: A5 0E        LDA $0E
	CMP #$04								;C2/5408: C9 04        CMP #$04
	BNE .ExpLoop			;4 members				;C2/540A: D0 B0        BNE $53BC

;Display exp/gil/ap message boxes
	LDA #$FF			;flag for unused message box		;C2/540C: A9 FF        LDA #$FF
	STA MessageBoxes							;C2/540E: 8D 5F 3C     STA $3C5F
	LDA #$01								;C2/5411: A9 01        LDA #$01
	JSR GFXCmdMessageClearAnim						;C2/5413: 20 47 58     JSR $5847
	TDC 									;C2/5416: 7B           TDC 
	TAX 									;C2/5417: AA           TAX 
	LDA VictoryGil								;C2/5418: AD 0B 7C     LDA $7C0B
	STA MessageBoxData[0].0							;C2/541B: 8D BF 3C     STA $3CBF
	LDA VictoryGil+1							;C2/541E: AD 0C 7C     LDA $7C0C
	STA MessageBoxData[0].1							;C2/5421: 8D C0 3C     STA $3CC0
	LDA VictoryGil+2							;C2/5424: AD 0D 7C     LDA $7C0D
	STA MessageBoxData[0].2							;C2/5427: 8D C1 3C     STA $3CC1
	LDA VictoryGil								;C2/542A: AD 0B 7C     LDA $7C0B
	ORA VictoryGil+1							;C2/542D: 0D 0C 7C     ORA $7C0C
	ORA VictoryGil+2							;C2/5430: 0D 0D 7C     ORA $7C0D
	BEQ +									;C2/5433: F0 06        BEQ $543B
	LDA #$2C			;gil message				;C2/5435: A9 2C        LDA #$2C
	STA MessageBoxes,X							;C2/5437: 9D 5F 3C     STA $3C5F,X
	INX 				;increment message box slot if used	;C2/543A: E8           INX 
+	LDA VictoryExp								;C2/543B: AD 0E 7C     LDA $7C0E
	STA MessageBoxData[1].0		;data slots are hardcoded tho		;C2/543E: 8D C2 3C     STA $3CC2
	LDA VictoryExp+1		;..maybe they fix it later		;C2/5441: AD 0F 7C     LDA $7C0F
	STA MessageBoxData[1].1							;C2/5444: 8D C3 3C     STA $3CC3
	LDA VictoryExp+2							;C2/5447: AD 10 7C     LDA $7C10
	STA MessageBoxData[1].2							;C2/544A: 8D C4 3C     STA $3CC4
	LDA VictoryExp								;C2/544D: AD 0E 7C     LDA $7C0E
	ORA VictoryExp+1							;C2/5450: 0D 0F 7C     ORA $7C0F
	ORA VictoryExp+2							;C2/5453: 0D 10 7C     ORA $7C10
	BEQ +									;C2/5456: F0 06        BEQ $545E
	LDA #$2D			;exp message				;C2/5458: A9 2D        LDA #$2D
	STA MessageBoxes,X							;C2/545A: 9D 5F 3C     STA $3C5F,X
	INX 									;C2/545D: E8           INX 
+	LDA EncounterInfo.AP							;C2/545E: AD F1 3E     LDA $3EF1
	BEQ +									;C2/5461: F0 15        BEQ $5478
	STA MessageBoxData[2].0							;C2/5463: 8D C5 3C     STA $3CC5
	STZ MessageBoxData[2].1							;C2/5466: 9C C6 3C     STZ $3CC6
	STZ MessageBoxData[2].2							;C2/5469: 9C C7 3C     STZ $3CC7

	JSR CheckHideAP								;C2/546C: 20 74 56     JSR $5674
	LDA $0E				;result, 1 to hide AP			;C2/546F: A5 0E        LDA $0E
	BNE +									;C2/5471: D0 05        BNE $5478
	LDA #$2E			;ap message				;C2/5473: A9 2E        LDA #$2E
	STA MessageBoxes,X							;C2/5475: 9D 5F 3C     STA $3C5F,X
+	LDA MessageBoxes							;C2/5478: AD 5F 3C     LDA $3C5F
	CMP #$FF			;flag for unused message box		;C2/547B: C9 FF        CMP #$FF
	BEQ .Blue								;C2/547D: F0 0A        BEQ $5489
	LDA #$0A			;C1 routine: exec graphics script	;C2/547F: A9 0A        LDA #$0A
	JSR CallC1     								;C2/5481: 20 69 00     JSR $0069      
	LDA #$FF								;C2/5484: A9 FF        LDA #$FF
	STA MessageBoxes+1							;C2/5486: 8D 60 3C     STA $3C60

.Blue
	LDA BlueLearnedCount							;C2/5489: AD 20 7C     LDA $7C20
	BEQ .CheckLevelUp							;C2/548C: F0 52        BEQ $54E0
	TDC 									;C2/548E: 7B           TDC 
	TAX 									;C2/548F: AA           TAX 
	STX $3D									;C2/5490: 86 3D        STX $3D
.BlueLoop
	LDX $3D				;learned blue index			;C2/5492: A6 3D        LDX $3D
	LDA BlueLearned,X							;C2/5494: BD 21 7C     LDA $7C21,X
	BEQ .CheckLevelUp							;C2/5497: F0 47        BEQ $54E0
	CMP #$82			;first blue spell			;C2/5499: C9 82        CMP #$82
	BCC .CheckLevelUp							;C2/549B: 90 43        BCC $54E0
	CMP #$A0			;after blue spells			;C2/549D: C9 A0        CMP #$A0
	BCS .CheckLevelUp							;C2/549F: B0 3F        BCS $54E0
	STA MessageBoxData[0].0							;C2/54A1: 8D BF 3C     STA $3CBF
	STZ MessageBoxData[0].1							;C2/54A4: 9C C0 3C     STZ $3CC0
	STZ MessageBoxData[0].2							;C2/54A7: 9C C1 3C     STZ $3CC1
	STZ $0E									;C2/54AA: 64 0E        STZ $0E
	LSR 									;C2/54AC: 4A           LSR 
	ROR $0E									;C2/54AD: 66 0E        ROR $0E
	LSR 									;C2/54AF: 4A           LSR 
	ROR $0E									;C2/54B0: 66 0E        ROR $0E
	LSR 									;C2/54B2: 4A           LSR 
	ROR $0E									;C2/54B3: 66 0E        ROR $0E
	TAY 				;MagicBits offset			;C2/54B5: A8           TAY 
	LDA $0E									;C2/54B6: A5 0E        LDA $0E
	JSR ShiftDivide_32							;C2/54B8: 20 BD 01     JSR $01BD      
	TAX 				;MagicBits spell			;C2/54BB: AA           TAX 
	LDA MagicBits,Y   							;C2/54BC: B9 50 09     LDA $0950,Y    
	JSR SelectBit_X     							;C2/54BF: 20 DB 01     JSR $01DB      
	BNE .NextBlue			;already know this one			;C2/54C2: D0 18        BNE $54DC
	LDA MagicBits,Y								;C2/54C4: B9 50 09     LDA $0950,Y
	JSR SetBit_X    							;C2/54C7: 20 D6 01     JSR $01D6      
	STA MagicBits,Y								;C2/54CA: 99 50 09     STA $0950,Y
	LDA #$01								;C2/54CD: A9 01        LDA #$01
	JSR GFXCmdMessageClearAnim						;C2/54CF: 20 47 58     JSR $5847
	LDA #$32			;learned blue message			;C2/54D2: A9 32        LDA #$32
	STA MessageBoxes							;C2/54D4: 8D 5F 3C     STA $3C5F
	LDA #$0A			;C1 routine: exec graphics script	;C2/54D7: A9 0A        LDA #$0A
	JSR CallC1    								;C2/54D9: 20 69 00     JSR $0069      
.NextBlue
	INC $3D				;learned blue index			;C2/54DC: E6 3D        INC $3D
if !_Fixes				;**bug: no range check	
	LDA BlueLearnedCount
	DEC
	CMP $3D
	BCS .BlueLoop
else					;..relies on the next byte never being a valid blue spell if 8 blue spells were used
					;..fortunately it seems to always be 0 or 1
	BRA .BlueLoop								;C2/54DE: 80 B2        BRA $5492
endif

.CheckLevelUp
	TDC 									;C2/54E0: 7B           TDC 
	TAX 									;C2/54E1: AA           TAX 
	STX $3D									;C2/54E2: 86 3D        STX $3D
	STX $3F									;C2/54E4: 86 3F        STX $3F
.LevelLoop		;will run multiple times for a single character if they gain multiple levels at once
	LDA $3D				;char index				;C2/54E6: A5 3D        LDA $3D
	TAY 									;C2/54E8: A8           TAY 
	LDA ActiveParticipants,Y						;C2/54E9: B9 C2 3E     LDA $3EC2,Y
	BEQ .NextChar								;C2/54EC: F0 5E        BEQ $554C
	LDX $3F				;char offset				;C2/54EE: A6 3F        LDX $3F
	LDA CharStruct.Level,X							;C2/54F0: BD 02 20     LDA $2002,X
	CMP #$63			;skip check if already 99		;C2/54F3: C9 63        CMP #$63
	BCS .NextChar								;C2/54F5: B0 55        BCS $554C
	TAX 									;C2/54F7: AA           TAX 
	STX $0E				;current level				;C2/54F8: 86 0E        STX $0E
	REP #$20								;C2/54FA: C2 20        REP #$20
	LDA $0E									;C2/54FC: A5 0E        LDA $0E
	ASL 									;C2/54FE: 0A           ASL 
	STA $10				;level *2				;C2/54FF: 85 10        STA $10
	CLC 									;C2/5501: 18           CLC 
	ADC $0E				;level *3				;C2/5502: 65 0E        ADC $0E
	TAX 									;C2/5504: AA           TAX 
	LDA ROMLevelExp,X							;C2/5505: BF 00 50 D1  LDA $D15000,X
	STA $0E				;required exp (low bytes)		;C2/5509: 85 0E        STA $0E
	TDC 									;C2/550B: 7B           TDC 
	SEP #$20								;C2/550C: E2 20        SEP #$20
	LDA ROMLevelExp+2,X							;C2/550E: BF 02 50 D1  LDA $D15002,X
	STA $12				;required exp (high byte)		;C2/5512: 85 12        STA $12
	LDX $3F				;char offset				;C2/5514: A6 3F        LDX $3F
	SEC 				;subtract requirement from current exp	;C2/5516: 38           SEC 
	LDA CharStruct.Exp,X							;C2/5517: BD 03 20     LDA $2003,X
	SBC $0E									;C2/551A: E5 0E        SBC $0E
	LDA CharStruct.Exp+1,X							;C2/551C: BD 04 20     LDA $2004,X
	SBC $0F									;C2/551F: E5 0F        SBC $0F
	LDA CharStruct.Exp+2,X							;C2/5521: BD 05 20     LDA $2005,X
	SBC $12									;C2/5524: E5 12        SBC $12
	BCC .NextChar			;not enough exp				;C2/5526: 90 24        BCC $554C
	JSR LevelUp								;C2/5528: 20 EC 56     JSR $56EC
	LDX $3F				;char offset				;C2/552B: A6 3F        LDX $3F
	INC CharStruct.Level,X							;C2/552D: FE 02 20     INC $2002,X
	LDX $3F				;still char offset			;C2/5530: A6 3F        LDX $3F
	LDA CharStruct.CharRow,X						;C2/5532: BD 00 20     LDA $2000,X
	AND #$07			;character bits				;C2/5535: 29 07        AND #$07
	STA MessageBoxData[0].0							;C2/5537: 8D BF 3C     STA $3CBF
	STZ MessageBoxData[0].1							;C2/553A: 9C C0 3C     STZ $3CC0
	STZ MessageBoxData[0].2							;C2/553D: 9C C1 3C     STZ $3CC1
	LDA #$2F			;level up message			;C2/5540: A9 2F        LDA #$2F
	STA MessageBoxes							;C2/5542: 8D 5F 3C     STA $3C5F
	LDA #$0A			;C1 routine: exec graphics command	;C2/5545: A9 0A        LDA #$0A
	JSR CallC1     								;C2/5547: 20 69 00     JSR $0069      
	BRA .LevelLoop								;C2/554A: 80 9A        BRA $54E6

.NextChar
	LDX $3F				;char offset				;C2/554C: A6 3F        LDX $
	JSR NextCharOffset							;C2/554E: 20 E0 01     JSR $01E0      
	STX $3F									;C2/5551: 86 3F        STX $3F
	INC $3D				;char index				;C2/5553: E6 3D        INC $3D
	LDA $3D									;C2/5555: A5 3D        LDA $3D
	CMP #$04			;4 chars to check			;C2/5557: C9 04        CMP #$04
	BNE .LevelLoop								;C2/5559: D0 8B        BNE $54E6

	TDC 									;C2/555B: 7B           TDC 
	TAX 									;C2/555C: AA           TAX 
	STX $3D									;C2/555D: 86 3D        STX $3D
	STX $3F									;C2/555F: 86 3F        STX $3F

.JobUpLoop
	LDA #$FF								;C2/5561: A9 FF        LDA #$FF
	STA MessageBoxes+1							;C2/5563: 8D 60 3C     STA $3C60
	STA MessageBoxes+2							;C2/5566: 8D 61 3C     STA $3C61
	LDA $3D									;C2/5569: A5 3D        LDA $3D
	TAY 									;C2/556B: A8           TAY 
	LDA ActiveParticipants,Y						;C2/556C: B9 C2 3E     LDA $3EC2,Y
	BNE .JobLevelLoop							;C2/556F: D0 03        BNE $5574
	JMP .NextJobCheck							;C2/5571: 4C 61 56     JMP $5661

.JobLevelLoop	;run multiple times in case we gained more than 1 job level
	LDX $3F				;char offset				;C2/5574: A6 3F        LDX $3F
	LDA CharStruct.JobLevel,X						;C2/5576: BD 3A 20     LDA $203A,X
	STA $10									;C2/5579: 85 10        STA $10
	LDA CharStruct.Job,X							;C2/557B: BD 01 20     LDA $2001,X
	CMP #$15			;freelancer/normal			;C2/557E: C9 15        CMP #$15
	BEQ .GoNextJobCheck							;C2/5580: F0 0C        BEQ $558E
	TAX 									;C2/5582: AA           TAX 
	ASL 									;C2/5583: 0A           ASL 
	STA $0E									;C2/5584: 85 0E        STA $0E
	LDA $10									;C2/5586: A5 10        LDA $10
	CMP ROMJobLevels,X							;C2/5588: DF EA 52 D1  CMP $D152EA,X
	BNE +									;C2/558C: D0 03        BNE $5591

.GoNextJobCheck 
	JMP .NextJobCheck							;C2/558E: 4C 61 56     JMP $5661

+	LDA $0E									;C2/5591: A5 0E        LDA $0E
	TAX 									;C2/5593: AA           TAX 
	LDA ROMJobPointers,X							;C2/5594: BF C0 52 D1  LDA $D152C0,X
	STA $12									;C2/5598: 85 12        STA $12
	LDA ROMJobPointers+1,X							;C2/559A: BF C1 52 D1  LDA $D152C1,X
	STA $13									;C2/559E: 85 13        STA $13
	LDA.b #bank(ROMJobPointers)						;C2/55A0: A9 D1        LDA #$D1
	STA $14									;C2/55A2: 85 14        STA $14
	LDA $10			;job level					;C2/55A4: A5 10        LDA $10
	ASL 									;C2/55A6: 0A           ASL 
	CLC 									;C2/55A7: 18           CLC 
	ADC $10			;job level*3					;C2/55A8: 65 10        ADC $10
	TAY 									;C2/55AA: A8           TAY 
	LDA [$12],Y								;C2/55AB: B7 12        LDA [$12],Y
	STA $10			;ap cost (low)					;C2/55AD: 85 10        STA $10
	INY 									;C2/55AF: C8           INY 
	LDA [$12],Y								;C2/55B0: B7 12        LDA [$12],Y
	STA $11			;ap cost (hi)					;C2/55B2: 85 11        STA $11
	INY 									;C2/55B4: C8           INY 
	LDA [$12],Y								;C2/55B5: B7 12        LDA [$12],Y
	STA $12			;ability					;C2/55B7: 85 12        STA $12
	LDX $3F			;char offset					;C2/55B9: A6 3F        LDX $3F
	SEC 									;C2/55BB: 38           SEC 
	LDA CharStruct.AP,X 							;C2/55BC: BD 3B 20     LDA $203B,X    
	SBC $10									;C2/55BF: E5 10        SBC $10
	LDA CharStruct.AP+1,X							;C2/55C1: BD 3C 20     LDA $203C,X
	SBC $11									;C2/55C4: E5 11        SBC $11
	BCS +									;C2/55C6: B0 03        BCS $55CB
	JMP .NextJobCheck	;not enough ap					;C2/55C8: 4C 61 56     JMP $5661
+	SEC 									;C2/55CB: 38           SEC 
	LDA CharStruct.AP,X							;C2/55CC: BD 3B 20     LDA $203B,X
	SBC $10									;C2/55CF: E5 10        SBC $10
	STA CharStruct.AP,X							;C2/55D1: 9D 3B 20     STA $203B,X
	LDA CharStruct.AP+1,X							;C2/55D4: BD 3C 20     LDA $203C,X
	SBC $11									;C2/55D7: E5 11        SBC $11
	STA CharStruct.AP+1,X							;C2/55D9: 9D 3C 20     STA $203C,X
	INC CharStruct.JobLevel,X						;C2/55DC: FE 3A 20     INC $203A,X
	LDA $3D			;char index					;C2/55DF: A5 3D        LDA $3D
	ASL 									;C2/55E1: 0A           ASL 
	TAX 									;C2/55E2: AA           TAX 
	LDA ROMAbilityListPointers,X						;C2/55E3: BF D3 EE D0  LDA $D0EED3,X   
	STA $0E			;now holds address of char's FieldAbilityList	;C2/55E7: 85 0E        STA $0E
	LDA ROMAbilityListPointers+1,X						;C2/55E9: BF D4 EE D0  LDA $D0EED4,X
	STA $0F									;C2/55ED: 85 0F        STA $0F
	LDA $12			;ability learned				;C2/55EF: A5 12        LDA $12
	BPL +     								;C2/55F1: 10 05        BPL $55F8       
	AND #$7F		;passive, this clears the passive flag bit	;C2/55F3: 29 7F        AND #$7F
	CLC 									;C2/55F5: 18           CLC 
	ADC #$4E      		;start at slot after the last active ability	;C2/55F6: 69 4E        ADC #$4E        
+	ASL 									;C2/55F8: 0A           ASL 
	TAX 									;C2/55F9: AA           TAX 
	LDA RomAbilityBitInfo,X 						;C2/55FA: BF 00 EC D0  LDA $D0EC00,X   
	TAY 			;offset of byte containing ability in list	;C2/55FE: A8           TAY 
	LDA RomAbilityBitInfo+1,X						;C2/55FF: BF 01 EC D0  LDA $D0EC01,X   
	TAX 			;bit number of ability				;C2/5603: AA           TAX 
	LDA ($0E),Y								;C2/5604: B1 0E        LDA ($0E),Y
	JSR SetBit_X   								;C2/5606: 20 D6 01     JSR $01D6       
	STA ($0E),Y		;ability now in known list			;C2/5609: 91 0E        STA ($0E),Y
	LDA $3D			;char index					;C2/560B: A5 3D        LDA $3D
	TAX 									;C2/560D: AA           TAX 
	INC FieldAbilityCount,X   						;C2/560E: FE F3 08     INC $08F3,X     
	LDX $3F			;char offset					;C2/5611: A6 3F        LDX $3F
	LDA CharStruct.CharRow,X						;C2/5613: BD 00 20     LDA $2000,X
	AND #$07		;character bits					;C2/5616: 29 07        AND #$07
	STA MessageBoxData[0].0							;C2/5618: 8D BF 3C     STA $3CBF
	STZ MessageBoxData[0].1							;C2/561B: 9C C0 3C     STZ $3CC0
	STZ MessageBoxData[0].2							;C2/561E: 9C C1 3C     STZ $3CC1
	LDA #$30		;job level up message				;C2/5621: A9 30        LDA #$30
	STA MessageBoxes							;C2/5623: 8D 5F 3C     STA $3C5F
	LDA #$0A		;c1 routine					;C2/5626: A9 0A        LDA #$0A
	JSR CallC1     								;C2/5628: 20 69 00     JSR $0069       
	LDA #$31		;ability learned message			;C2/562B: A9 31        LDA #$31
	STA MessageBoxes							;C2/562D: 8D 5F 3C     STA $3C5F
	LDA $12			;ability learned				;C2/5630: A5 12        LDA $12
	STA MessageBoxData[0].0							;C2/5632: 8D BF 3C     STA $3CBF
	CMP #$2C		;first normal magic command			;C2/5635: C9 2C        CMP #$2C
	BCC +									;C2/5637: 90 14        BCC $564D
	CMP #$4C		;end of normal magic commands			;C2/5639: C9 4C        CMP #$4C
	BCS +									;C2/563B: B0 10        BCS $564D
	SEC 									;C2/563D: 38           SEC 
	SBC #$2C		;adjust first magic command to start at 0	;C2/563E: E9 2C        SBC #$2C
	TAX 									;C2/5640: AA           TAX 
	LDA ROMJobMagicLevels,X	;look up table for magic level			;C2/5641: BF 06 EF D0  LDA $D0EF06,X
	STA MessageBoxData[1].0							;C2/5645: 8D C2 3C     STA $3CC2
	LDA #$33		;alternate ability learned message 		;C2/5648: A9 33        LDA #$33
	STA MessageBoxes	;..which shows magic level			;C2/564A: 8D 5F 3C     STA $3C5F
+	STZ MessageBoxData[0].1	;clear high bytes of message box data		;C2/564D: 9C C0 3C     STZ $3CC0
	STZ MessageBoxData[0].2							;C2/5650: 9C C1 3C     STZ $3CC1
	STZ MessageBoxData[1].1							;C2/5653: 9C C3 3C     STZ $3CC3
	STZ MessageBoxData[1].2							;C2/5656: 9C C4 3C     STZ $3CC4
	LDA #$0A		;c1 routine					;C2/5659: A9 0A        LDA #$0A
	JSR CallC1     								;C2/565B: 20 69 00     JSR $0069       
	JMP .JobLevelLoop							;C2/565E: 4C 74 55     JMP $5574

.NextJobCheck
	LDX $3F			;char offset					;C2/5661: A6 3F        LDX $3F
	JSR NextCharOffset    							;C2/5663: 20 E0 01     JSR $01E0       
	STX $3F									;C2/5666: 86 3F        STX $3F
	INC $3D			;next char index				;C2/5668: E6 3D        INC $3D
	LDA $3D									;C2/566A: A5 3D        LDA $3D
	CMP #$04		;4 chars to check				;C2/566C: C9 04        CMP #$04
	BEQ .Ret								;C2/566E: F0 03        BEQ $5673
	JMP .JobUpLoop								;C2/5670: 4C 61 55     JMP $5561
.Ret	RTS 									;C2/5673: 60           RTS 

endif