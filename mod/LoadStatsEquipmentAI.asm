if !_Fixes

;Fixes: Monsters that start with HP leak only have their HP leak timer started if they are hasted (wrong status byte checked)

;Loads stats and status for all characters, including party equipment and monster AI
LoadStatsEquipmentAI:
	TDC 									;C2/3EA2: 7B           TDC 		
	TAX 									;C2/3EA3: AA           TAX 		
	TAY 									;C2/3EA4: A8           TAY 		
	LDA #$04		;4 characters					;C2/3EA5: A9 04        LDA #$04		
	STA $10									;C2/3EA7: 85 10        STA $10		
.CopyCharStatsLoop
	LDA #$50		;80 bytes per character				;C2/3EA9: A9 50        LDA #$50		
	STA $0E									;C2/3EAB: 85 0E        STA $0E		
;Checks for fight $1F7, which is the Galuf Exdeath battle
	LDA EncounterIndex							;C2/3EAD: AD F0 04     LDA $04F0	
	CMP #$F7								;C2/3EB0: C9 F7        CMP #$F7		
	BNE .CopyOneChar							;C2/3EB2: D0 0C        BNE $3EC0	
	LDA EncounterIndex+1							;C2/3EB4: AD F1 04     LDA $04F1	
	CMP #$01								;C2/3EB7: C9 01        CMP #$01		
	BNE .CopyOneChar							;C2/3EB9: D0 05        BNE $3EC0	
	LDA #$08		;Set Always HP Leak				;C2/3EBB: A9 08        LDA #$08		
	STA CharStruct.AlwaysStatus4,Y						;C2/3EBD: 99 73 20     STA $2073,Y

.CopyOneChar
	LDA !FieldChar,X								;C2/3EC0: BD 00 05     LDA $0500,X
	STA !CharStruct,Y							;C2/3EC3: 99 00 20     STA $2000,Y
	INX 									;C2/3EC6: E8           INX 		
	INY 									;C2/3EC7: C8           INY 		
	DEC $0E									;C2/3EC8: C6 0E        DEC $0E		
	LDA $0E									;C2/3ECA: A5 0E        LDA $0E		
	BNE .CopyOneChar							;C2/3ECC: D0 F2        BNE $3EC0	
	
	REP #$20								;C2/3ECE: C2 20        REP #$20	
	TYA 									;C2/3ED0: 98           TYA 		
	CLC 									;C2/3ED1: 18           CLC 		
	ADC #$0030		;advance CharStruct index to next character	;C2/3ED2: 69 30 00     ADC #$0030
	TAY 									;C2/3ED5: A8           TAY 		
	TDC 									;C2/3ED6: 7B           TDC 		
	SEP #$20								;C2/3ED7: E2 20        SEP #$20	
	DEC $10			;next character					;C2/3ED9: C6 10        DEC $10		
	LDA $10									;C2/3EDB: A5 10        LDA $10		
	BNE .CopyCharStatsLoop							;C2/3EDD: D0 CA        BNE $3EA9	
	
	LDA EncounterIndex+1	;1 for boss fights				;C2/3EDF: AD F1 04     LDA $04F1	
	BEQ .DoneLenna								;C2/3EE2: F0 2D        BEQ $3F11	
	LDA EncounterIndex							;C2/3EE4: AD F0 04     LDA $04F0	
	CMP #$BA		;Forza/Magisa					;C2/3EE7: C9 BA        CMP #$BA	
	BNE .DoneLenna								;C2/3EE9: D0 26        BNE $3F11	
	TDC 									;C2/3EEB: 7B           TDC 		
	TAX 									;C2/3EEC: AA           TAX 
	TAY 									;C2/3EED: A8           TAY 
	
.PoisonLenna
	LDA CharStruct.CharRow,X						;C2/3EEE: BD 00 20     LDA $2000,X
	AND #$07		;character bits					;C2/3EF1: 29 07        AND #$07	
	CMP #$01		;Lenna						;C2/3EF3: C9 01        CMP #$01	
	BNE .Next								;C2/3EF5: D0 11        BNE $3F08	
	LDA CharStruct.Status1,X						;C2/3EF7: BD 1A 20     LDA $201A,X
	AND #$C6		;if Dead/Stone/Zombie/Poison, abort 		;C2/3EFA: 29 C6        AND #$C6		
	BNE .DoneLenna								;C2/3EFC: D0 13        BNE $3F11	
	LDA CharStruct.Status1,X						;C2/3EFE: BD 1A 20     LDA $201A,X
	ORA #$04		;set poison					;C2/3F01: 09 04        ORA #$04		
	STA CharStruct.Status1,X						;C2/3F03: 9D 1A 20     STA $201A,X
	BRA .DoneLenna								;C2/3F06: 80 09        BRA $3F11	
.Next	JSR NextCharOffset							;C2/3F08: 20 E0 01     JSR $01E0	
	INY 									;C2/3F0B: C8           INY 
	CPY #$0004								;C2/3F0C: C0 04 00     CPY #$0004
	BNE .PoisonLenna							;C2/3F0F: D0 DD        BNE $3EEE

.DoneLenna
	JSR StartPartyPoisonTimers						;C2/3F11: 20 D5 45     JSR $45D5	
	JSR ApplyPartyGear							;C2/3F14: 20 5E 9A     JSR $9A5E	
	TDC									;C2/3F17: 7B           TDC		
	TAX 									;C2/3F18: AA           TAX 		
	STX $0E			;MonsterStats offset				;C2/3F19: 86 0E        STX $0E		
	STX $10			;Monster CharStruct offset			;C2/3F1B: 86 10        STX $10		
	STX $12			;current monster index				;C2/3F1D: 86 12        STX $12		
	LDA #$D0								;C2/3F1F: A9 D0        LDA #$D0		
	STA $22									;C2/3F21: 85 22        STA $22		
	STA $1E									;C2/3F23: 85 1E        STA $1E		
	LDX #$9C00								;C2/3F25: A2 00 9C     LDX #$9C00
	STX $20			;$D09C00, ROMAIScriptOffsets			;C2/3F28: 86 20        STX $20		
										;:					
.LoadMonsterStatsAI
	LDX #$0000								;C2/3F2A: A2 00 00     LDX #$0000
	LDA #$02								;C2/3F2D: A9 02        LDA #$02		
	JSR Random_X_A								;C2/3F2F: 20 7C 00     JSR $007C	
	CMP #$02								;C2/3F32: C9 02        CMP #$02		
	BNE +									;C2/3F34: D0 02        BNE $3F38	
	LDA #$FF		;-1						;C2/3F36: A9 FF        LDA #$FF		
+	STA $16			;randomly 0, +1 or -1 ($FF)			;C2/3F38: 85 16        STA $16		
	LDX $0E			;MonsterStats offset				;C2/3F3A: A6 0E        LDX $0E		
	LDY $10			;Monster CharStruct offset			;C2/3F3C: A4 10        LDY $10		
	CLC 									;C2/3F3E: 18           CLC 		
	LDA MonsterStats.Speed,X						;C2/3F3F: BD FF 3E     LDA $3EFF,X
	ADC $16			;randomly 0, +1 or -1				;C2/3F42: 65 16        ADC $16		
	STA CharStruct[4].BaseAgi,Y	;CharStruct[4] is the first monster	;C2/3F44: 99 25 22     STA $2225,Y	
	STA CharStruct[4].EquippedAgi,Y						;C2/3F47: 99 29 22     STA $2229,Y
	LDA MonsterStats.AttackPower,X						;C2/3F4A: BD 00 3F     LDA $3F00,X
	STA CharStruct[4].MonsterAttack,Y					;C2/3F4D: 99 44 22     STA $2244,Y
	LDA MonsterStats.AttackMult,X						;C2/3F50: BD 01 3F     LDA $3F01,X
	STA CharStruct[4].MonsterM,Y						;C2/3F53: 99 62 22     STA $2262,Y
	LDA MonsterStats.Evade,X						;C2/3F56: BD 02 3F     LDA $3F02,X
	STA CharStruct[4].Evade,Y						;C2/3F59: 99 2C 22     STA $222C,Y
	LDA MonsterStats.Defense,X						;C2/3F5C: BD 03 3F     LDA $3F03,X
	STA CharStruct[4].Defense,Y						;C2/3F5F: 99 2D 22     STA $222D,Y
	LDA MonsterStats.MagicPower,X						;C2/3F62: BD 04 3F     LDA $3F04,X
	STA CharStruct[4].BaseMag,Y						;C2/3F65: 99 27 22     STA $2227,Y
	STA CharStruct[4].EquippedMag,Y						;C2/3F68: 99 2B 22     STA $222B,Y
	LDA MonsterStats.MDefense,X						;C2/3F6B: BD 05 3F     LDA $3F05,X
	STA CharStruct[4].MDefense,Y						;C2/3F6E: 99 2F 22     STA $222F,Y
	LDA MonsterStats.MEvade,X						;C2/3F71: BD 06 3F     LDA $3F06,X
	STA CharStruct[4].MEvade,Y						;C2/3F74: 99 2E 22     STA $222E,Y
	REP #$20								;C2/3F77: C2 20        REP #$20		
	LDA MonsterStats.HP,X							;C2/3F79: BD 07 3F     LDA $3F07,X
	STA CharStruct[4].CurHP,Y						;C2/3F7C: 99 06 22     STA $2206,Y
	STA CharStruct[4].MaxHP,Y						;C2/3F7F: 99 08 22     STA $2208,Y
	LDA MonsterStats.MP,X							;C2/3F82: BD 09 3F     LDA $3F09,X
	STA CharStruct[4].CurMP,Y						;C2/3F85: 99 0A 22     STA $220A,Y
	LDA #$270F			;monsters always have 9999 Max MP	;C2/3F88: A9 0F 27     LDA #$270F
	STA CharStruct[4].MaxMP,Y						;C2/3F8B: 99 0C 22     STA $220C,Y
	LDA MonsterStats.Exp,X							;C2/3F8E: BD 0B 3F     LDA $3F0B,X
	STA CharStruct[4].RewardExp,Y						;C2/3F91: 99 67 22     STA $2267,Y
	LDA MonsterStats.Gil,X							;C2/3F94: BD 0D 3F     LDA $3F0D,X
	STA CharStruct[4].RewardGil,Y						;C2/3F97: 99 69 22     STA $2269,Y
	LDA MonsterStats.StatusImmune1,X	;also copies StatusImmune2	;C2/3F9A: BD 11 3F     LDA $3F11,X
	STA CharStruct[4].StatusImmune1,Y					;C2/3F9D: 99 35 22     STA $2235,Y
	TDC 									;C2/3FA0: 7B           TDC 
	SEP #$20								;C2/3FA1: E2 20        SEP #$20		
	STA CharStruct[4].CharRow,Y						;C2/3FA3: 99 00 22     STA $2200,Y
	LDA MonsterStats.StatusImmune3,X					;C2/3FA6: BD 13 3F     LDA $3F13,X
	STA CharStruct[4].StatusImmune3,Y					;C2/3FA9: 99 37 22     STA $2237,Y
	LDA MonsterStats.AttackFX,X						;C2/3FAC: BD 0F 3F     LDA $3F0F,X
	STA CharStruct[4].RHWeapon,Y						;C2/3FAF: 99 13 22     STA $2213,Y
	LDA MonsterStats.EAbsorb,X						;C2/3FB2: BD 14 3F     LDA $3F14,X
	STA CharStruct[4].EAbsorb,Y						;C2/3FB5: 99 30 22     STA $2230,Y
	LDA MonsterStats.EImmune,X						;C2/3FB8: BD 10 3F     LDA $3F10,X
	STA CharStruct[4].EImmune,Y						;C2/3FBB: 99 32 22     STA $2232,Y
	LDA MonsterStats.CantEvade,X						;C2/3FBE: BD 15 3F     LDA $3F15,X
	STA CharStruct[4].CantEvade,Y						;C2/3FC1: 99 64 22     STA $2264,Y
	LDA MonsterStats.EWeak,X						;C2/3FC4: BD 16 3F     LDA $3F16,X
	STA CharStruct[4].EWeak,Y						;C2/3FC7: 99 34 22     STA $2234,Y
	LDA MonsterStats.CreatureType,X						;C2/3FCA: BD 17 3F     LDA $3F17,X
	STA CharStruct[4].CreatureType,Y					;C2/3FCD: 99 65 22     STA $2265,Y
	LDA MonsterStats.CmdImmunity,X						;C2/3FD0: BD 18 3F     LDA $3F18,X
	STA CharStruct[4].CmdImmunity,Y						;C2/3FD3: 99 66 22     STA $2266,Y
	LDA MonsterStats.Level,X						;C2/3FD6: BD 1E 3F     LDA $3F1E,X
	STA CharStruct[4].Level,Y						;C2/3FD9: 99 02 22     STA $2202,Y
	STA CharStruct[4].EquippedVit,Y		;vit = level for monsters	;C2/3FDC: 99 2A 22     STA $222A,Y
	PHY 									;C2/3FDF: 5A           PHY 		
	LDA MonsterStats.Status1,X						;C2/3FE0: BD 19 3F     LDA $3F19,X
	BPL .ApplyStatus							;C2/3FE3: 10 0B        BPL $3FF0	

.AlwaysStatus										
	REP #$20								;C2/3FE5: C2 20        REP #$20		
	TYA 									;C2/3FE7: 98           TYA 		
	CLC 									;C2/3FE8: 18           CLC 		
	ADC #$0056	;Shift offset so regular status points to always status ;C2/3FE9: 69 56 00     ADC #$0056
	TAY 									;C2/3FEC: A8           TAY 		
	TDC 									;C2/3FED: 7B           TDC 		
	SEP #$20								;C2/3FEE: E2 20        SEP #$20		

.ApplyStatus														
	LDA MonsterStats.Status1,X						;C2/3FF0: BD 19 3F     LDA $3F19,X
	AND #$7F	;clear high bit since it also means death		;C2/3FF3: 29 7F        AND #$7F		
	STA CharStruct[4].Status1,Y						;C2/3FF5: 99 1A 22     STA $221A,Y
	LDA MonsterStats.Status2,X						;C2/3FF8: BD 1A 3F     LDA $3F1A,X
	STA CharStruct[4].Status2,Y						;C2/3FFB: 99 1B 22     STA $221B,Y
	LDA MonsterStats.Status3,X						;C2/3FFE: BD 1B 3F     LDA $3F1B,X
	STA CharStruct[4].Status3,Y						;C2/4001: 99 1C 22     STA $221C,Y
	LDA MonsterStats.Status4,X						;C2/4004: BD 1C 3F     LDA $3F1C,X
	STA CharStruct[4].Status4,Y						;C2/4007: 99 1D 22     STA $221D,Y
	LDA $12			;current monster index				;C2/400A: A5 12        LDA $12		
	ASL 									;C2/400C: 0A           ASL 		
	TAY 									;C2/400D: A8           TAY 		
	LDA MonsterStats.EnemyNameID,X						;C2/400E: BD 1D 3F     LDA $3F1D,X
	STA MonsterNameID,Y							;C2/4011: 99 08 40     STA $4008,Y
	LDA BattleMonsterID+1							;C2/4014: AD 21 40     LDA $4021	
	STA MonsterNameID+1,Y							;C2/4017: 99 09 40     STA $4009,Y
	LDA $12			;current monster index				;C2/401A: A5 12        LDA $12		
	ASL 									;C2/401C: 0A           ASL 		
	TAX 									;C2/401D: AA           TAX 		
	REP #$20								;C2/401E: C2 20        REP #$20		
	LDA BattleMonsterID,X							;C2/4020: BD 20 40     LDA $4020,X
	ASL 									;C2/4023: 0A           ASL 		
	TAX 									;C2/4024: AA           TAX 		
	TDC 									;C2/4025: 7B           TDC 		
	SEP #$20								;C2/4026: E2 20        SEP #$20		
	LDA ROMSpecialtyData.Properties,X					;C2/4028: BF 00 99 D0  LDA $D09900,X
	STA $1C									;C2/402C: 85 1C        STA $1C		
	LDA ROMSpecialtyData.Name,X						;C2/402E: BF 01 99 D0  LDA $D09901,X
	STA $1D									;C2/4032: 85 1D        STA $1D		
	PLY 									;C2/4034: 7A           PLY 		
	LDA $1C									;C2/4035: A5 1C        LDA $1C
	STA CharStruct[4].Specialty,Y						;C2/4037: 99 6E 22     STA $226E,Y
	LDA $1D									;C2/403A: A5 1D        LDA $1D		
	STA CharStruct[4].SpecialtyName,Y						;C2/403C: 99 7F 22     STA $227F,Y
	LDA $12			;current monster index				;C2/403F: A5 12        LDA $12		
	ASL 									;C2/4041: 0A           ASL 		
	TAX 									;C2/4042: AA           TAX 		
	REP #$20								;C2/4043: C2 20        REP #$20		
	LDA BattleMonsterID,X							;C2/4045: BD 20 40     LDA $4020,X
	ASL 									;C2/4048: 0A           ASL 		
	TAY 									;C2/4049: A8           TAY 		
	TDC 									;C2/404A: 7B           TDC 		
	SEP #$20								;C2/404B: E2 20        SEP #$20		
	LDA [$20],Y		;$D09C00, ROMAIScriptOffsets			;C2/404D: B7 20        LDA [$20],Y
	STA $1C									;C2/404F: 85 1C        STA $1C
	INY 									;C2/4051: C8           INY 
	LDA [$20],Y								;C2/4052: B7 20        LDA [$20],Y
	STA $1D									;C2/4054: 85 1D        STA $1D
	LDX #$0654								;C2/4056: A2 54 06     LDX #$0654
	STX $2A									;C2/4059: 86 2A        STX $2A		
	LDX $12			;current monster index				;C2/405B: A6 12        LDX $12		
	STX $2C									;C2/405D: 86 2C        STX $2C
	JSR Multiply_16bit	;current monster index * 1620			;C2/405F: 20 D2 00     JSR $00D2	
	LDX $2E			;which is MonsterAI offset 			;C2/4062: A6 2E        LDX $2E		
	STX $08			; there's a table for *1620 in the rom		;C2/4064: 86 08        STX $08		
	STX $0A			; not sure why it's not being used		;C2/4066: 86 0A        STX $0A		
	PHX 									;C2/4068: DA           PHX 		
	TDC 									;C2/4069: 7B           TDC 		
	TAY 									;C2/406A: A8           TAY 		
	STY $0C			;condition/action index				;C2/406B: 84 0C        STY $0C		

.CopyAI															
	LDX $08			;Current MonsterAI Condition offset		;C2/406D: A6 08        LDX $08		
.CopyAIConditions													
	LDA [$1C],Y		;AI script offset in ROM			;C2/406F: B7 1C        LDA [$1C],Y
	STA MonsterAI.Conditions,X						;C2/4071: 9D 59 47     STA $4759,X
	INX 									;C2/4074: E8           INX 
	INY 									;C2/4075: C8           INY 
	CMP #$FE		;end of condition entry				;C2/4076: C9 FE        CMP #$FE		
	BNE .CopyAIConditions							;C2/4078: D0 F5        BNE $406F	

	LDX $0A			;Current MonsterAI Action offset 			;C2/407A: A6 0A        LDX $
.CopyAIActions														
	LDA [$1C],Y		;AI script offset in ROM, Y is kept from above	;C2/407C: B7 1C        LDA [$1C],Y
	STA MonsterAI.Actions,X							;C2/407E: 9D 03 48     STA $4803,X
	INX 									;C2/4081: E8           INX 		
	INY 									;C2/4082: C8           INY 		
	CMP #$FF		;end of AI script				;C2/4083: C9 FF        CMP #$FF		
	BEQ .AICounters								;C2/4085: F0 21        BEQ $40A8	
	CMP #$FE		;end of action entry				;C2/4087: C9 FE        CMP #$FE		
	BNE .CopyAIActions							;C2/4089: D0 F1        BNE $407C	

	REP #$20								;C2/408B: C2 20        REP #$20		
	CLC 									;C2/408D: 18           CLC 		
	LDA $08			;MonsterAI Condition offset 			;C2/408E: A5 08        LDA $08		
	ADC #$0011		;next condition					;C2/4090: 69 11 00     ADC #$0011
	STA $08									;C2/4093: 85 08        STA $08		
	CLC 									;C2/4095: 18           CLC 		
	LDA $0A			;MonsterAI Action offset 				;C2/4096: A5 0A        LDA $
	ADC #$0040		;next action 					;C2/4098: 69 40 00     ADC #$0040
	STA $0A									;C2/409B: 85 0A        STA $0A		
	TDC 									;C2/409D: 7B           TDC 		
	SEP #$20								;C2/409E: E2 20        SEP #$20		
	INC $0C			;next condition/action index			;C2/40A0: E6 0C        INC $0C		
	LDA $0C									;C2/40A2: A5 0C        LDA $0C		
	CMP #$0A		;max 10 condition/action pairs			;C2/40A4: C9 0A        CMP #$0A		
	BNE .CopyAI								;C2/40A6: D0 C5        BNE $406D	
	
.AICounters
	PLX 			;MonsterAI offset 				;C2/40A8: FA           PLX 		
	STX $08									;C2/40A9: 86 08        STX $08		
	STX $0A									;C2/40AB: 86 0A        STX $0A		
	STX $0C									;C2/40AD: 86 0C        STX $0C		

.CopyAIReact								
	LDX $08			;Current MonsterAI Condition offset		;C2/40AF: A6 08        LDX $08		
.CopyAIReactConditions													
	LDA [$1C],Y		;AI script offset in ROM, Y is kept from above	;C2/40B1: B7 1C        LDA [$1C],Y
	STA MonsterAI.ReactConditions,X						;C2/40B3: 9D 83 4A     STA $4A83,X
	INX 									;C2/40B6: E8           INX 
	INY 									;C2/40B7: C8           INY 
	CMP #$FF		;end of AI script				;C2/40B8: C9 FF        CMP #$FF		
	BEQ .NextMonster        						;C2/40BA: F0 37        BEQ $40F3    
	CMP #$FE         	;end of condition entry				;C2/40BC: C9 FE        CMP #$FE     
	BNE .CopyAIReactConditions       					;C2/40BE: D0 F1        BNE $40B1    
	
	LDX $12			;current monster index				;C2/40C0: A6 12        LDX $12		
	INC MonsterReactions,X							;C2/40C2: FE 30 40     INC $4030,X

	LDX $0A									;C2/40C5: A6 0A        LDX $0A		
.CopyAIReactActions													
	LDA [$1C],Y		;AI script offset in ROM, Y is kept from above	;C2/40C7: B7 1C        LDA [$1C],Y
	STA MonsterAI.ReactActions,X						;C2/40C9: 9D 2D 4B     STA $4B2D,X
	INX 									;C2/40CC: E8           INX 
	INY 									;C2/40CD: C8           INY 
	CMP #$FF		;end of AI script				;C2/40CE: C9 FF        CMP #$FF		
	BEQ .NextMonster        						;C2/40D0: F0 21        BEQ $40F3    
	CMP #$FE		;end of action entry				;C2/40D2: C9 FE        CMP #$FE		
	BNE .CopyAIReactActions							;C2/40D4: D0 F1        BNE $40C7	

	REP #$20								;C2/40D6: C2 20        REP #$20		
	CLC 									;C2/40D8: 18           CLC 		
	LDA $08			;MonsterAI Condition offset 			;C2/40D9: A5 08        LDA $08		
	ADC #$0011       	;next react condition				;C2/40DB: 69 11 00     ADC #$0011   
	STA $08          							;C2/40DE: 85 08        STA $08      
	CLC              							;C2/40E0: 18           CLC          
	LDA $0A          	;MonsterAI Action offset			;C2/40E1: A5 0A        LDA $0A
	ADC #$0040       	;next react action				;C2/40E3: 69 40 00     ADC #$0040   
	STA $0A          							;C2/40E6: 85 0A        STA $0A      
	TDC              							;C2/40E8: 7B           TDC          
	SEP #$20         							;C2/40E9: E2 20        SEP #$20     
	INC $0C          	;next condition/action index			;C2/40EB: E6 0C        INC $0C      
	LDA $0C          							;C2/40ED: A5 0C        LDA $0C      
	CMP #$0A         	;max 10 condition/action pairs			;C2/40EF: C9 0A        CMP #$0A     
	BNE .CopyAIReact        						;C2/40F1: D0 BC        BNE $40AF    

.NextMonster
	LDX $10			;Monster CharStruct offset			;C2/40F3: A6 10        LDX $10		
	JSR NextCharOffset							;C2/40F5: 20 E0 01     JSR $01E0	
	STX $10									;C2/40F8: 86 10        STX $10
	CLC 									;C2/40FA: 18           CLC 		
	LDA $0E			;MonsterStats offset				;C2/40FB: A5 0E        LDA $0E		
	ADC #$20		;next monster					;C2/40FD: 69 20        ADC #$20		
	STA $0E									;C2/40FF: 85 0E        STA $0E
	INC $12			;next monster index				;C2/4101: E6 12        INC $12		
	LDA $12									;C2/4103: A5 12        LDA $12
	CMP #$08		;8 monsters					;C2/4105: C9 08        CMP #$08		
	BEQ .MonsterStatusTimers						;C2/4107: F0 03        BEQ $410C	
	JMP .LoadMonsterStatsAI							;C2/4109: 4C 2A 3F     JMP $3F2A	
								
.MonsterStatusTimers
	TDC 									;C2/410C: 7B           TDC 		
	TAX 									;C2/410D: AA           TAX 		
	LDA #$04								;C2/410E: A9 04        LDA #$04		
	STA Temp								;C2/4110: 8D 20 26     STA $2620	

.MonStatusLoop														
	LDA Temp								;C2/4113: AD 20 26     LDA $2620	
	JSR CalculateCharOffset							;C2/4116: 20 EC 01     JSR $01EC	
	LDA CharStruct.Status1,X						;C2/4119: BD 1A 20     LDA $201A,X
	AND #$04		;poison						;C2/411C: 29 04        AND #$04		
	BEQ +									;C2/411E: F0 05        BEQ $4125	
	LDA #$01		;poison timer					;C2/4120: A9 01        LDA #$01		
	JSR StartTimerFromTemp							;C2/4122: 20 A3 41     JSR $41A3	
										
+	LDX AttackerOffset							;C2/4125: A6 32        LDX $32		
	LDA CharStruct.Status2,X						;C2/4127: BD 1B 20     LDA $201B,X	
	AND #$80		;old						;C2/412A: 29 80        AND #$80		
	BEQ +									;C2/412C: F0 05        BEQ $4133	
	LDA #$06		;old timer					;C2/412E: A9 06        LDA #$06		
	JSR StartTimerFromTemp							;C2/4130: 20 A3 41     JSR $41A3	
										
+	LDX AttackerOffset							;C2/4133: A6 32        LDX $32		
	LDA CharStruct.Status2,X						;C2/4135: BD 1B 20     LDA $201B,X	
	AND #$20		;paralyze					;C2/4138: 29 20        AND #$20		
	BEQ +									;C2/413A: F0 05        BEQ $4141	
	LDA #$09		;paralyze timer					;C2/413C: A9 09        LDA #$09		
	JSR StartTimerFromTemp							;C2/413E: 20 A3 41     JSR $41A3	
										
+	LDX AttackerOffset							;C2/4141: A6 32        LDX $32		
	LDA CharStruct.Status2,X						;C2/4143: BD 1B 20     LDA $201B,X	
	AND #$04		;mute						;C2/4146: 29 04        AND #$04		
	BEQ +									;C2/4148: F0 05        BEQ $414F	
	LDA #$04		;mute timer					;C2/414A: A9 04        LDA #$04		
	JSR StartTimerFromTemp							;C2/414C: 20 A3 41     JSR $41A3	
										
+	LDX AttackerOffset							;C2/414F: A6 32        LDX $32		
	LDA CharStruct.Status3,X						;C2/4151: BD 1C 20     LDA $201C,X	
	AND #$80		;reflect					;C2/4154: 29 80        AND #$80		
	BEQ +									;C2/4156: F0 05        BEQ $415D	
	LDA #$02		;reflect timer					;C2/4158: A9 02        LDA #$02		
	JSR StartTimerFromTemp							;C2/415A: 20 A3 41     JSR $41A3	
										
+	LDX AttackerOffset							;C2/415D: A6 32        LDX $32		
	LDA CharStruct.Status3,X						;C2/415F: BD 1C 20     LDA $201C,X	
	AND #$10		;stop						;C2/4162: 29 10        AND #$10		
	BEQ +									;C2/4164: F0 05        BEQ $416B	
	LDA #$00		;stop timer					;C2/4166: A9 00        LDA #$00		
	JSR StartTimerFromTemp							;C2/4168: 20 A3 41     JSR $41A3	
										
+	LDX AttackerOffset							;C2/416B: A6 32        LDX $32		
	LDA CharStruct.Status3,X						;C2/416D: BD 1C 20     LDA $201C,X	
	AND #$01		;regen						;C2/4170: 29 01        AND #$01		
	BEQ +									;C2/4172: F0 05        BEQ $4179	
	LDA #$07		;regen timer					;C2/4174: A9 07        LDA #$07		
	JSR StartTimerFromTemp							;C2/4176: 20 A3 41     JSR $41A3	
										
+	LDX AttackerOffset							;C2/4179: A6 32        LDX $32		
	LDA CharStruct.Status4,X						;C2/417B: BD 1D 20     LDA $201D,X	
	AND #$10		;countdown					;C2/417E: 29 10        AND #$10		
	BEQ +									;C2/4180: F0 05        BEQ $4187	
	LDA #$03		;countdown timer				;C2/4182: A9 03        LDA #$03		
	JSR StartTimerFromTemp							;C2/4184: 20 A3 41     JSR $41A3	
										
+	LDX AttackerOffset							;C2/4187: A6 32        LDX $32		
if !_Fixes			;**bug: checks wrong status byte
	LDA CharStruct.Status4,X
else
	LDA CharStruct.Status3,X						;C2/4189: BD 1C 20     LDA $201C,X	
endif
	AND #$08		;Haste due to bug, should be HP leak		;C2/418C: 29 08        AND #$08		
	BEQ +									;C2/418E: F0 05        BEQ $4195	
	LDA #$05		;HP leak timer					;C2/4190: A9 05        LDA #$05		
	JSR StartTimerFromTemp							;C2/4192: 20 A3 41     JSR $41A3	
								
+	INC Temp								;C2/4195: EE 20 26     INC $2620	
	LDA Temp								;C2/4198: AD 20 26     LDA $2620	
	CMP #$0C		;doing slots 4-11 for monsters, 12 is too far	;C2/419B: C9 0C        CMP #$0C		
	BEQ .Ret								;C2/419D: F0 03        BEQ $41A2	
	JMP .MonStatusLoop							;C2/419F: 4C 13 41     JMP $4113	
.Ret	RTS 									;C2/41A2: 60           RTS 


endif