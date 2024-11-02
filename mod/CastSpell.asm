if !_Optimize

incsrc utility/CalcBitfieldIndexes.asm
incsrc utility/CopyTempMagicInfo.asm
incsrc utility/GFXCmd.asm

;Casts a Magic Spell!
;
;does everything needed to cast a spell or use a magic-like ability:
;loads spell data into attack info structures and other variables
;fixes up targetting as needed
;displays needed messages and animations
;
;optimizations:
;uses a bunch of utility routines to save space
;saves a few bytes with a switch to 16 bit mode
;removes some double TDCs
%subdef(CastSpell)
	LDA TempIsEffect						;C2/5CE1: AD 23 27     LDA $2723
	BNE .LoadEffect							;C2/5CE4: D0 24        BNE $5D0A
	LDA TempSpell							;C2/5CE6: AD 22 27     LDA $2722
	CMP #$F1	;Spell $F1 pulls data for $78 instead		;C2/5CE9: C9 F1        CMP #$F1
	BNE +								;C2/5CEB: D0 02        BNE $5CEF
	LDA #$78							;C2/5CED: A9 78        LDA #$78
+	REP #$20							;C2/5CEF: C2 20        REP #$20
	JSR ShiftMultiply_8       					;C2/5CF1: 20 B6 01     JSR $01B6      
	TAX 								;C2/5CF4: AA           TAX 
	TDC 								;C2/5CF5: 7B           TDC 
	SEP #$20							;C2/5CF6: E2 20        SEP #$20
	 								;C2/5CF8: 7B           TDC 
	TAY 								;C2/5CF9: A8           TAY 
-	LDA !ROMMagicInfo,X						;C2/5CFA: BF 80 0B D1  LDA $D10B80,X
	STA !TempMagicInfo,Y						;C2/5CFE: 99 2A 26     STA $262A,Y
	INX 								;C2/5D01: E8           INX 
	INY 								;C2/5D02: C8           INY 
	CPY #$0008	;8 bytes in magic info struct			;C2/5D03: C0 08 00     CPY #$0008
	BNE -								;C2/5D06: D0 F2        BNE $5CFA
	BRA .DataLoaded							;C2/5D08: 80 1C        BRA $5D26

.LoadEffect
	LDA TempSpell							;C2/5D0A: AD 22 27     LDA $2722
	REP #$20							;C2/5D0D: C2 20        REP #$20
	JSR ShiftMultiply_8       					;C2/5D0F: 20 B6 01     JSR $01B6      
	TAX 								;C2/5D12: AA           TAX 
	TDC 								;C2/5D13: 7B           TDC 
	SEP #$20							;C2/5D14: E2 20        SEP #$20
	 								;C2/5D16: 7B           TDC 
	TAY 								;C2/5D17: A8           TAY 
-	LDA !ROMEffectInfo,X						;C2/5D18: BF B1 6A D1  LDA $D16AB1,X
	STA !TempMagicInfo,Y						;C2/5D1C: 99 2A 26     STA $262A,Y
	INX 								;C2/5D1F: E8           INX 
	INY 								;C2/5D20: C8           INY 
	CPY #$0008	;8 bytes in magic info struct			;C2/5D21: C0 08 00     CPY #$0008
	BNE -								;C2/5D24: D0 F2        BNE $5D18

.DataLoaded
	LDA TempIsEffect						;C2/5D26: AD 23 27     LDA $2723
	BNE .CopyMagicInfo						;C2/5D29: D0 0E        BNE $5D39
	LDA TempSpell							;C2/5D2B: AD 22 27     LDA $2722
	CMP #$48	;first summon spell				;C2/5D2E: C9 48        CMP #$48
	BCC .CopyMagicInfo						;C2/5D30: 90 07        BCC $5D39
	CMP #$57	;after last summon spell			;C2/5D32: C9 57        CMP #$57
	BCS .CopyMagicInfo						;C2/5D34: B0 03        BCS $5D39
	JSR PrepSummon							;C2/5D36: 20 A3 60     JSR $60A3

.CopyMagicInfo
	JSR SelectCurrentProcSequence	;Y = ProcSequence*12		;C2/5D39: 20 23 99     JSR $9923
	JSR CopyTempMagicInfo						;*C2/5D3C: 7B           TDC 
									;*C2/5D3D: AA           TAX 
									;*C2/5D3E: BD 2A 26     LDA $262A,X
									;*C2/5D41: 99 FC 79     STA $79FC,Y
									;*C2/5D44: E8           INX 
									;*C2/5D45: C8           INY 
									;*C2/5D46: E0 05 00     CPX #$0005
									;*C2/5D49: D0 F3        BNE $5D3E
									;*C2/5D4B: C8           INY 
									;*C2/5D4C: C8           INY 
									;*C2/5D4D: C8           INY 
									;*C2/5D4E: C8           INY 
									;*C2/5D4F: BD 2A 26     LDA $262A,X
									;*C2/5D52: 99 FC 79     STA $79FC,Y
									;*C2/5D55: E8           INX 
									;*C2/5D56: C8           INY 
									;*C2/5D57: E0 08 00     CPX #$0008
									;*C2/5D5A: D0 F3        BNE $5D4F
	LDA TempMagicInfo.Misc						;C2/5D5C: AD 2C 26     LDA $262C
	AND #$07	;number of hits -1				;C2/5D5F: 29 07        AND #$07
	BEQ .SingleHit							;C2/5D61: F0 04        BEQ $5D67
	JSR CastMultiHitSpell						;C2/5D63: 20 75 5F     JSR $5F75
	RTS 								;C2/5D66: 60           RTS 

.SingleHit
	JSR CheckMultiTarget						;C2/5D67: 20 C2 02     JSR $02C2
	BNE .MultiTarget						;C2/5D6A: D0 3F        BNE $5DAB
	LDA TempMagicInfo.AtkType					;C2/5D6C: AD 2E 26     LDA $262E
	BPL .CheckSpecialVars						;C2/5D6F: 10 0B        BPL $5D7C
.HitsInactive
	LDA ProcSequence						;C2/5D71: AD FA 79     LDA $79FA
	TAX 								;C2/5D74: AA           TAX 
	LDA #$01							;C2/5D75: A9 01        LDA #$01
	STA HitsInactive,X						;C2/5D77: 9D EB 7B     STA $7BEB,X
	BRA .BuildTargetBitmask						;C2/5D7A: 80 4A        BRA $5DC6

.CheckSpecialVars
	LDA SpellCheckDeath						;C2/5D7C: AD 99 7C     LDA $7C99
	BNE .CheckDeath							;C2/5D7F: D0 13        BNE $5D94
	LDA SpellCheckStone						;C2/5D81: AD 98 7C     LDA $7C98
	BEQ .CheckTarget						;C2/5D84: F0 16        BEQ $5D9C
.CheckStone
	JSR GetPartyTargetOffset					;C2/5D86: 20 4E 61     JSR $614E
	LDA CharStruct.Status1,X					;C2/5D89: BD 1A 20     LDA $201A,X
	BMI .CheckTarget	;if dead				;C2/5D8C: 30 0E        BMI $5D9C
	AND #$40							;C2/5D8E: 29 40        AND #$40
	BNE .HitsInactive	;if stone				;C2/5D90: D0 DF        BNE $5D71
	BRA .CheckTarget						;C2/5D92: 80 08        BRA $5D9C

.CheckDeath
	JSR GetPartyTargetOffset					;C2/5D94: 20 4E 61     JSR $614E
	LDA CharStruct.Status1,X					;C2/5D97: BD 1A 20     LDA $201A,X
	BMI .HitsInactive						;C2/5D9A: 30 D5        BMI $5D71

.CheckTarget
	JSR CheckRetarget						;C2/5D9C: 20 FE 4A     JSR $4AFE
	LDA NoValidTargets						;C2/5D9F: AD 29 7C     LDA $7C29
	BEQ .BuildTargetBitmask						;C2/5DA2: F0 22        BEQ $5DC6
.NoTargets
	LDA #$F1							;C2/5DA4: A9 F1        LDA #$F1
	STA TempSpell							;C2/5DA6: 8D 22 27     STA $2722
	BRA .BuildTargetBitmask						;C2/5DA9: 80 1B        BRA $5DC6

.MultiTarget
	LDA TempMagicInfo.AtkType					;C2/5DAB: AD 2E 26     LDA $262E
	BPL .RemoveInactive						;C2/5DAE: 10 0B        BPL $5DBB
	LDA ProcSequence						;C2/5DB0: AD FA 79     LDA $79FA
	TAX 								;C2/5DB3: AA           TAX 
	LDA #$01							;C2/5DB4: A9 01        LDA #$01
	STA HitsInactive,X						;C2/5DB6: 9D EB 7B     STA $7BEB,X
	BRA .BuildTargetBitmask						;C2/5DB9: 80 0B        BRA $5DC6
.RemoveInactive
	JSR RemoveInactiveTargets					;C2/5DBB: 20 CF 02     JSR $02CF
	LDA NoValidTargets						;C2/5DBE: AD 29 7C     LDA $7C29
	BNE .NoTargets							;C2/5DC1: D0 E1        BNE $5DA4
	JSR CheckMultiTarget						;C2/5DC3: 20 C2 02     JSR $02C2

.BuildTargetBitmask
	JSR BuildTargetBitmask						;C2/5DC6: 20 A9 02     JSR $02A9
	LDA TempIsEffect						;C2/5DC9: AD 23 27     LDA $2723
	BNE .CheckMagicAnimTable					;C2/5DCC: D0 31        BNE $5DFF
	LDA TempSpell							;C2/5DCE: AD 22 27     LDA $2722
	CMP #$80	;monster fight					;C2/5DD1: C9 80        CMP #$80
	BEQ .Fight							;C2/5DD3: F0 04        BEQ $5DD9
	CMP #$DE	;strong fight?	vacuum wave?			;C2/5DD5: C9 DE        CMP #$DE
	BNE .NotFight							;C2/5DD7: D0 1C        BNE $5DF5

.Fight	LDA #$04		       					;C2/5DD9: 20 FA 98     JSR $98FA       
	JSR GFXCmdAbilityAnim						;*C2/5DDC: 9E 4C 38     STZ $384C,X
									;*C2/5DDF: A9 FC        LDA #$FC
									;*C2/5DE1: 9D 4D 38     STA $384D,X
									;*C2/5DE4: A9 01        LDA #$01
									;*C2/5DE6: 9D 4E 38     STA $384E,X
									;*C2/5DE9: A9 04        LDA #$04
									;*C2/5DEB: 9D 4F 38     STA $384F,X
									;*C2/5DEE: 7B           TDC 
									;*C2/5DEF: 9D 50 38     STA $3850,X
	JMP .TargettingStatus						;C2/5DF2: 4C BE 5E     JMP $5EBE

.NotFight
	LDA TempSpell							;C2/5DF5: AD 22 27     LDA $2722
	CMP #$F1							;C2/5DF8: C9 F1        CMP #$F1
	BNE .CheckMagicAnimTable					;C2/5DFA: D0 03        BNE $5DFF
	JMP .TargettingStatus						;C2/5DFC: 4C BE 5E     JMP $5EBE

.CheckMagicAnimTable
	LDA TempSkipNaming						;C2/5DFF: A5 21        LDA $21
	BNE .MagicAnim							;C2/5E01: D0 2C        BNE $5E2F
	LDA TempIsEffect						;C2/5E03: AD 23 27     LDA $2723
	BNE .CheckType							;C2/5E06: D0 47        BNE $5E4F
	LDA TempSpell							;C2/5E08: AD 22 27     LDA $2722
	CMP #$82	;first blue spell				;C2/5E0B: C9 82        CMP #$82
	BCC .CheckType	 						;C2/5E0D: 90 40        BCC $5E4F
	STZ $0E								;C2/5E0F: 64 0E        STZ $0E
	SEC 								;C2/5E11: 38           SEC 
	SBC #$80	;high bit always 0 now				;C2/5E12: E9 80        SBC #$80
	JSR CalcBitfieldIndexes						;*C2/5E14: 4A           LSR 
									;*C2/5E15: 66 0E        ROR $0E
									;*C2/5E17: 4A           LSR 
									;*C2/5E18: 66 0E        ROR $0E
									;*C2/5E1A: 4A           LSR 
									;*C2/5E1B: 66 0E        ROR $0E
									;*C2/5E1D: AA           TAX 
	LDA ROMMagicAnim,X						;C2/5E1E: BF 81 29 D1  LDA $D12981,X
	TYX								;*C2/5E22: 48           PHA 
									;*C2/5E23: A5 0E        LDA $0E
									;*C2/5E25: 20 BD 01     JSR $01BD       
									;*C2/5E28: AA           TAX 
									;*C2/5E29: 68           PLA 
	JSR SelectBit_X       						;C2/5E2A: 20 DB 01     JSR $01DB       
	BEQ .CheckType							;C2/5E2D: F0 20        BEQ $5E4F

.MagicAnim	;rom has this spell flagged for animation type 7 (most magic spells)
	LDA TempIsEffect						;C2/5E2F: AD 23 27     LDA $2723
	BNE .CheckType							;C2/5E32: D0 1B        BNE $5E4F
									;*C2/5E34: 20 FA 98     JSR $98FA       
									;*C2/5E37: 9E 4C 38     STZ $384C,X
									;*C2/5E3A: 9E 50 38     STZ $3850,X
									;*C2/5E3D: A9 FC        LDA #$FC
									;*C2/5E3F: 9D 4D 38     STA $384D,X
									;*C2/5E42: A9 07        LDA #$07
									;*C2/5E44: 9D 4E 38     STA $384E,X
	LDA TempSpell							;C2/5E47: AD 22 27     LDA $2722
	JSR GFXCmdMagicAnim						;*C2/5E4A: 9D 4F 38     STA $384F,X
	BRA .TargettingStatus						;C2/5E4D: 80 6F        BRA $5EBE

.CheckType
	LDA #$00							;C2/5E4F: A9 00        LDA #$00
	STA $0E								;C2/5E51: 85 0E        STA $0E
	LDA TempSpell							;C2/5E53: AD 22 27     LDA $2722
	STA Temp+1							;C2/5E56: 8D 21 26     STA $2621
	LDA TempIsEffect						;C2/5E59: AD 23 27     LDA $2723
	BNE .AttackOrEffect						;C2/5E5C: D0 32        BNE $5E90
	LDA TempSpell							;C2/5E5E: AD 22 27     LDA $2722
	CMP #$81	;monster specialty				;C2/5E61: C9 81        CMP #$81
	BNE .AttackOrEffect						;C2/5E63: D0 2B        BNE $5E90

.Specialty
	LDA #$03							;C2/5E65: A9 03        LDA #$03
	STA Temp							;C2/5E67: 8D 20 26     STA $2620
	LDX AttackerOffset						;C2/5E6A: A6 32        LDX $32         
	LDA CharStruct.SpecialtyName,X					;C2/5E6C: BD 7F 20     LDA $207F,X
	STA Temp+1							;C2/5E6F: 8D 21 26     STA $2621
	JSR GFXCmdAttackNameFromTemp					;C2/5E72: 20 2F 99     JSR $992F
	LDA #$04							;*C2/5E75: 20 FA 98     JSR $98FA       
	JSR GFXCmdAbilityAnim						;*C2/5E78: 9E 4C 38     STZ $384C,X
									;*C2/5E7B: A9 FC        LDA #$FC
									;*C2/5E7D: 9D 4D 38     STA $384D,X
									;*C2/5E80: A9 01        LDA #$01
									;*C2/5E82: 9D 4E 38     STA $384E,X
									;*C2/5E85: A9 04        LDA #$04
									;*C2/5E87: 9D 4F 38     STA $384F,X
									;*C2/5E8A: 7B           TDC 
									;*C2/5E8B: 9D 50 38     STA $3850,X
	BRA .TargettingStatus						;C2/5E8E: 80 2E        BRA $5EBE

.AttackOrEffect:
	LDA TempIsEffect						;C2/5E90: AD 23 27     LDA $2723
	BEQ +								;C2/5E93: F0 06        BEQ $5E9B
	LDA #$02							;C2/5E95: A9 02        LDA #$02
	STA $0E								;C2/5E97: 85 0E        STA $0E
	LDA #$02							;C2/5E99: A9 02        LDA #$02
+	STA Temp							;C2/5E9B: 8D 20 26     STA $2620
	LDA TempSkipNaming						;C2/5E9E: A5 21        LDA $21
	BNE +		;skips naming the attack a second time		;C2/5EA0: D0 03        BNE $5EA5
	JSR GFXCmdAttackNameFromTemp					;C2/5EA2: 20 2F 99     JSR $992F
+	LDA $0E	    	;attack or special ability effect, depending						;C2/5EA5: 20 FA 98     JSR $98FA       
	TAX								;C2/5EA8: 9E 4C 38     STZ $384C,X
	LDA Temp+1							;C2/5EAB: 9E 50 38     STZ $3850,X
	JSR GFXCmdAnim							;*C2/5EAE: A9 FC        LDA #$FC
									;*C2/5EB0: 9D 4D 38     STA $384D,X
									;*C2/5EB3: A5 0E        LDA $0E
									;*C2/5EB5: 9D 4E 38     STA $384E,X
									;*C2/5EB8: AD 21 26     LDA $2621
									;*C2/5EBB: 9D 4F 38     STA $384F,X

.TargettingStatus
	LDA ProcSequence						;C2/5EBE: AD FA 79     LDA $79FA
	TAX 								;C2/5EC1: AA           TAX 
	LDA TempMagicInfo.AtkType					;C2/5EC2: AD 2E 26     LDA $262E
	AND #$7F							;C2/5EC5: 29 7F        AND #$7F
	STA AtkType,X							;C2/5EC7: 9D 2D 7B     STA $7B2D,X
	LDA TempTargetting						;C2/5ECA: AD A0 26     LDA $26A0
	STA MultiTarget,X						;C2/5ECD: 9D 1C 7B     STA $7B1C,X
	BEQ +								;C2/5ED0: F0 05        BEQ $5ED7
	INC MultiTarget,X						;C2/5ED2: FE 1C 7B     INC $7B1C,X
	LDA #$80							;C2/5ED5: A9 80        LDA #$80
+	STA TargetType,X						;C2/5ED7: 9D CC 7A     STA $7ACC,X
	LDA ProcSequence						;C2/5EDA: AD FA 79     LDA $79FA
	ASL 								;C2/5EDD: 0A           ASL 
	TAX 								;C2/5EDE: AA           TAX 
	REP #$20
	LDA TempTargetBitmask						;C2/5EDF: AD 20 27     LDA $2720
	STA CommandTargetBitmask,X					;C2/5EE2: 9D DC 7A     STA $7ADC,X
	STA TargetBitmask,X						;C2/5EE5: 9D FC 7A     STA $7AFC,X
									;C2/5EE8: AD 21 27     LDA $2721
	TDC								;C2/5EEB: 9D DD 7A     STA $7ADD,X
	SEP #$20							;C2/5EEE: 9D FD 7A     STA $7AFD,X
	INC ProcSequence						;C2/5EF1: EE FA 79     INC $79FA
	LDA TempIsEffect						;C2/5EF4: AD 23 27     LDA $2723
	BNE .DisplayDamage						;C2/5EF7: D0 61        BNE $5F5A
	LDA TempSpell							;C2/5EF9: AD 22 27     LDA $2722
	CMP #$F1							;C2/5EFC: C9 F1        CMP #$F1
	BEQ .IsToadOK							;C2/5EFE: F0 25        BEQ $5F25
	LDX AttackerOffset						;C2/5F00: A6 32        LDX $32        
	CMP #$82	;first blue magic				;C2/5F02: C9 82        CMP #$82
	BCS .CheckToad							;C2/5F04: B0 15        BCS $5F1B
	CMP #$80	;monster fight or specialty			;C2/5F06: C9 80        CMP #$80
	BCS .DisplayDamage						;C2/5F08: B0 50        BCS $5F5A
	LDA CharStruct.Status2,X					;C2/5F0A: BD 1B 20     LDA $201B,X
	ORA CharStruct.AlwaysStatus2,X					;C2/5F0D: 1D 71 20     ORA $2071,X
	AND #$04	;mute						;C2/5F10: 29 04        AND #$04
	BNE .Ineffective						;C2/5F12: D0 31        BNE $5F45
	LDA Void							;C2/5F14: AD E6 7B     LDA $7BE6
	AND #$40	;void						;C2/5F17: 29 40        AND #$40
	BNE .Ineffective						;C2/5F19: D0 2A        BNE $5F45

.CheckToad
	LDA CharStruct.Status1,X					;C2/5F1B: BD 1A 20     LDA $201A,X
	ORA CharStruct.AlwaysStatus1,X					;C2/5F1E: 1D 70 20     ORA $2070,X
	AND #$20	;toad						;C2/5F21: 29 20        AND #$20
	BEQ .DisplayDamage						;C2/5F23: F0 35        BEQ $5F5A

.IsToadOK	;spell is F1, or (spell is >$82 AND we're a frog), or (spell is <$80, and not muted, and we're a frog)
	LDA TempSpell							;C2/5F25: AD 22 27     LDA $2722
	JSR CalcBitfieldIndexes						;*C2/5F28: 64 0E        STZ $0E
									;*C2/5F2A: 4A           LSR 
									;*C2/5F2B: 66 0E        ROR $0E
									;*C2/5F2D: 4A           LSR 
									;*C2/5F2E: 66 0E        ROR $0E
									;*C2/5F30: 4A           LSR 
									;*C2/5F31: 66 0E        ROR $0E
									;*C2/5F33: AA           TAX 
									;*C2/5F34: A5 0E        LDA $0E
									;*C2/5F36: 20 BD 01     JSR $01BD       
									;*C2/5F39: A8           TAY 
									;*C2/5F3A: 5A           PHY 
	LDA ROMToadOK,X							;C2/5F3B: BF 58 EF D0  LDA $D0EF58,X
	TYX 								;C2/5F3F: FA           PLX 
	JSR SelectBit_X      						;C2/5F40: 20 DB 01     JSR $01DB       
	BNE .DisplayDamage						;C2/5F43: D0 15        BNE $5F5A

.Ineffective
	LDA MessageBoxOffset						;C2/5F45: AD EF 3C     LDA $3CEF
	TAX 								;C2/5F48: AA           TAX 
	LDA #$1D        ;ineffective					;C2/5F49: A9 1D        LDA #$1D        
	STA MessageBoxes,X						;C2/5F4B: 9D 5F 3C     STA $3C5F,X
	LDA ProcSequence						;C2/5F4E: AD FA 79     LDA $79FA
	DEC 	;Procsequence already advanced, rolling back 		;C2/5F51: 3A           DEC 
	TAX 								;C2/5F52: AA           TAX 
	LDA #$7E	;always miss attack type			;C2/5F53: A9 7E        LDA #$7E
	STA AtkType,X							;C2/5F55: 9D 2D 7B     STA $7B2D,X
	BRA .Finish							;C2/5F58: 80 17        BRA $5F71

.DisplayDamage
	JSR GFXCmdDamageNumbers						;C2/5F5A: 20 E3 98     JSR $98E3
	LDA MessageBoxOffset						;C2/5F5D: AD EF 3C     LDA $3CEF
	TAY 								;C2/5F60: A8           TAY 
	REP #$20							;C2/5F61: C2 20        REP #$20
	LDA TempSpell							;C2/5F63: AD 22 27     LDA $2722
	TAX 								;C2/5F66: AA           TAX 
	TDC 								;C2/5F67: 7B           TDC 
	SEP #$20							;C2/5F68: E2 20        SEP #$20
	LDA ROMBattleMessageOffsets,X   				;C2/5F6A: BF 40 38 D1  LDA $D13840,X   
	STA MessageBoxes,Y						;C2/5F6E: 99 5F 3C     STA $3C5F,Y

.Finish	JSR GFXCmdMessage						;C2/5F71: 20 4C 99     JSR $994C
	RTS 								;C2/5F74: 60           RTS 

endif