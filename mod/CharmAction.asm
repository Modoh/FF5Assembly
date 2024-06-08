
if !_Optimize

incsrc mod/utility/ClearSecondAction.asm
incsrc mod/utility/SetupUncontrolledFight.asm


;Param X = Char Offset, $3D = Char index, $3F = Char Offset
;50% chance: 	sets up a fight command targetting a random party member
;		or picks a random known white/black/time spell and casts with inverted targetting
;
;optimized: 	use existing ROMTimes650w rom table instead of SNES HW multiplier
;		use utility routines to setup fight and clear action fields
CharmAction:
	LDA CharStruct.EnableSpells,X					;C2/1E62: BD 3D 20     LDA $203D,X
	AND #$0F			;white magic			;C2/1E65: 29 0F        AND #$0F
	ORA CharStruct.EnableSpells+1,X	;black and time magic		;C2/1E67: 1D 3E 20     ORA $203E,X
	BEQ .Fight							;C2/1E6A: F0 07        BEQ $1E73
	JSR Random_0_99							;C2/1E6C: 20 A2 02     JSR $02A2       
	CMP #$32	;50% chance of spell				;C2/1E6F: C9 32        CMP #$32
	BCC .Magic     							;C2/1E71: 90 35        BCC $1EA8       
.Fight
	LDX $3F		;char offset					;C2/1E73: A6 3F        LDX $3F
	PHX
	JSR SetupUncontrolledFight
									;*C2/1E75: A9 80        LDA #$80
									;*C2/1E77: 9D 56 20     STA $2056,X
									;*C2/1E7A: A9 05        LDA #$05
									;*C2/1E7C: 9D 57 20     STA $2057,X
									;*C2/1E7F: 9E 58 20     STZ $2058,X
									;*C2/1E82: 9E 5A 20     STZ $205A,X
									;*C2/1E85: 9E 5B 20     STZ $205B,X
									;*C2/1E88: 9E 5C 20     STZ $205C,X
									;*C2/1E8B: 9E 5D 20     STZ $205D,X
									;*C2/1E8E: 9E 5E 20     STZ $205E,X
									;*C2/1E91: 9E 5F 20     STZ $205F,X
	PHX 								;C2/1E94: DA           PHX 
	TDC 								;C2/1E95: 7B           TDC 
	TAX 								;C2/1E96: AA           TAX 
	LDA #$03							;C2/1E97: A9 03        LDA #$03
	JSR Random_X_A    ;0..3						;C2/1E99: 20 7C 00     JSR $007C       
	TAX 								;C2/1E9C: AA           TAX 
	TDC 								;C2/1E9D: 7B           TDC 
	JSR SetBit_X       						;C2/1E9E: 20 D6 01     JSR $01D6       
	PLX 								;C2/1EA1: FA           PLX 
	STA CharStruct.PartyTargets,X	;fight random party member	;C2/1EA2: 9D 59 20     STA $2059,X
	JMP .QueueUncontrolledAction					;C2/1EA5: 4C 7D 1F     JMP $1F7D

.Magic
	LDA $3D		;char index					;C2/1EA8: A5 3D        LDA $3D
	ASL
	TAX 								;C2/1EAA: AA           TAX 
	;opt: use rom table instead of snes multiply
	REP #$20							;*C2/1EAB: 86 2A        STX $2A
	LDA ROMTimes650w,X						;*C2/1EAD: A2 8A 02     LDX #$028A      
	TAX								;*C2/1EB0: 86 2C        STX $2C
	TDC								;*C2/1EB2: 20 D2 00     JSR $00D2       
	SEP #$20							;*C2/1EB5: A6 2E        LDX $2E
	STX SpellOffsetRandom						;C2/1EB7: 86 41        STX $41
	STZ $0E								;C2/1EB9: 64 0E        STZ $0E
.FindAnySpell		;checks if any spells are learned
	LDA CharSpells.ID+18,X	;starts at first white spell		;C2/1EBB: BD 46 2D     LDA $2D46,X
	CMP #$46		;Quick spell				;C2/1EBE: C9 46        CMP #$46
	BEQ .NextSpell							;C2/1EC0: F0 04        BEQ $1EC6
	CMP #$FF		;empty spell slot			;C2/1EC2: C9 FF        CMP #$FF
	BNE .TryRandomSpell						;C2/1EC4: D0 0B        BNE $1ED1
.NextSpell
	INX 								;C2/1EC6: E8           INX 
	INC $0E								;C2/1EC7: E6 0E        INC $0E
	LDA $0E								;C2/1EC9: A5 0E        LDA $0E
	CMP #$36							;C2/1ECB: C9 36        CMP #$36
	BNE .FindAnySpell						;C2/1ECD: D0 EC        BNE $1EBB
	BRA .Fight		;no spells, hit something instead	;C2/1ECF: 80 A2        BRA $1E73

.TryRandomSpell
	LDX #$0012		;first white spell			;C2/1ED1: A2 12 00     LDX #$0012
	LDA #$47		;last time spell			;C2/1ED4: A9 47        LDA #$47
	JSR Random_X_A  	;random white/black/time spell		;C2/1ED6: 20 7C 00     JSR $007C       
	REP #$20							;C2/1ED9: C2 20        REP #$20
	ADC SpellOffsetRandom						;C2/1EDB: 65 41        ADC $41
	TAX 								;C2/1EDD: AA           TAX 
	TDC 								;C2/1EDE: 7B           TDC 
	SEP #$20							;C2/1EDF: E2 20        SEP #$20
	LDA CharSpells.ID,X						;C2/1EE1: BD 34 2D     LDA $2D34,X
	CMP #$FF		;empty spell slot			;C2/1EE4: C9 FF        CMP #$FF
	BEQ .TryRandomSpell	;keep trying until we hit a known spell	;C2/1EE6: F0 E9        BEQ $1ED1
	CMP #$46		;quick spell				;C2/1EE8: C9 46        CMP #$46
	BEQ .TryRandomSpell	;is no good either			;C2/1EEA: F0 E5        BEQ $1ED1

	PHA 			;holds known random spell		;C2/1EEC: 48           PHA 
	REP #$20							;C2/1EED: C2 20        REP #$20
	JSR ShiftMultiply_8						;C2/1EEF: 20 B6 01     JSR $01B6       
	TAX 								;C2/1EF2: AA           TAX 
	TDC 								;C2/1EF3: 7B           TDC 
	SEP #$20							;C2/1EF4: E2 20        SEP #$20
	LDA ROMMagicInfo.Targetting,X					;C2/1EF6: BF 80 0B D1  LDA $D10B80,X
	STA TempTargetting	;temp area				;C2/1EFA: 8D A0 26     STA $26A0
	TDC 								;C2/1EFD: 7B           TDC 
	TAY 								;C2/1EFE: A8           TAY 
	STY $16			;target bits				;C2/1EFF: 84 16        STY $16
	LDA TempTargetting						;C2/1F01: AD A0 26     LDA $26A0
	BNE .CheckTargetting						;C2/1F04: D0 12        BNE $1F18
.TargetSelf
	REP #$20							;C2/1F06: C2 20        REP #$20
	LDA $3F			;Char Offset				;C2/1F08: A5 3F        LDA $3F
	JSR ShiftDivide_128	;char index (could've just loaded that)	;C2/1F0A: 20 BB 01     JSR $01BB       
	TAX 								;C2/1F0D: AA           TAX 
	TDC 								;C2/1F0E: 7B           TDC 
	SEP #$20							;C2/1F0F: E2 20        SEP #$20
	JSR SetBit_X     	;target self if no targetting info	;C2/1F11: 20 D6 01     JSR $01D6       
	STA $16								;C2/1F14: 85 16        STA $16
	BRA .TargetReady						;C2/1F16: 80 3C        BRA $1F54
.CheckTargetting
	AND #$40		;hits all 				;C2/1F18: 29 40        AND #$40
	BNE .TargetsAll							;C2/1F1A: D0 27        BNE $1F43
	LDA TempTargetting						;C2/1F1C: AD A0 26     LDA $26A0
	AND #$08		;targets enemy by default		;C2/1F1F: 29 08        AND #$08
	BNE .TargetsEnemy						;C2/1F21: D0 10        BNE $1F33
.TargetsOther			;assumed to normally target party, now targets monsters
	TDC 								;C2/1F23: 7B           TDC 
	TAX 								;C2/1F24: AA           TAX 
	LDA #$07							;C2/1F25: A9 07        LDA #$07
	JSR Random_X_A	     	;random monster 0..7			;C2/1F27: 20 7C 00     JSR $007C       
	TAX 								;C2/1F2A: AA           TAX 
	TDC 								;C2/1F2B: 7B           TDC 
	JSR SetBit_X   							;C2/1F2C: 20 D6 01     JSR $01D6       
	STA $17			;monster target				;C2/1F2F: 85 17        STA $17
	BRA .TargetReady						;C2/1F31: 80 21        BRA $1F54
.TargetsEnemy			;normally targets enemy, now targets party
	TDC 								;C2/1F33: 7B           TDC 
	TAX 								;C2/1F34: AA           TAX 
	LDA #$03							;C2/1F35: A9 03        LDA #$03
	JSR Random_X_A    	;random party 0..3			;C2/1F37: 20 7C 00     JSR $007C       
	TAX 								;C2/1F3A: AA           TAX 
	TDC 								;C2/1F3B: 7B           TDC 
	JSR SetBit_X    						;C2/1F3C: 20 D6 01     JSR $01D6       
	STA $16			;party target				;C2/1F3F: 85 16        STA $16
	BRA .TargetReady						;C2/1F41: 80 11        BRA $1F54
.TargetsAll			
	LDA TempTargetting						;C2/1F43: AD A0 26     LDA $26A0
	AND #$08		;targets enemy by default		;C2/1F46: 29 08        AND #$08
	BNE +								;C2/1F48: D0 06        BNE $1F50
	LDA #$FF							;C2/1F4A: A9 FF        LDA #$FF
	STA $17								;C2/1F4C: 85 17        STA $17
	BRA .TargetReady						;C2/1F4E: 80 04        BRA $1F54
+	LDA #$F0		;target all party members		;C2/1F50: A9 F0        LDA #$F0
	STA $16								;C2/1F52: 85 16        STA $16
.TargetReady
	LDX $3F			;char Offset				;C2/1F54: A6 3F        LDX $3F
	PLA 			;random known spell			;C2/1F56: 68           PLA 
	STA CharStruct.SelectedItem,X					;C2/1F57: 9D 5A 20     STA $205A,X
	LDA $16			;party targets				;C2/1F5A: A5 16        LDA $16
	STA CharStruct.PartyTargets,X					;C2/1F5C: 9D 59 20     STA $2059,X
	LDA $17			;monster targets			;C2/1F5F: A5 17        LDA $17
	STA CharStruct.MonsterTargets,X					;C2/1F61: 9D 58 20     STA $2058,X
	LDA #$21		;magic + costs mp			;C2/1F64: A9 21        LDA #$21
	STA CharStruct.ActionFlag,X					;C2/1F66: 9D 56 20     STA $2056,X
	LDA #$2C		;first magic command 			;C2/1F69: A9 2C        LDA #$2C
	STA CharStruct.Command,X					;C2/1F6B: 9D 57 20     STA $2057,X
	JSR ClearSecondAction
.QueueUncontrolledAction
	JMP QueueUncontrolledAction					;C2/1F7D: 4C B3 1F     JMP $1FB3		


endif