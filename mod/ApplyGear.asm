if !_Fix_Stat_Underflow || !_Optimize || !_CombatTweaks || !_ArmorEvade || !_StackingDefender

;Apply Stats and Status from gear ($7B7B: Character index 0-3)

;*optimize:	removed a bunch of strange hacks that tried and failed to prevent underflow
;*bugfix: 	fixed stat underflow from negative equipment
;			would need to be rewritten to handle base+equipment stats over 127 
;			but vanilla ff5 doesn't get close to that

%subdef(ApplyGear)
	LDA CurrentChar								;C2/9A6F: AD 7B 7B     LDA $7B7B	
	JSR CalculateCharOffset							;C2/9A72: 20 EC 01     JSR $01EC	
	REP #$20								;C2/9A75: C2 20        REP #$20		
	TXA 									;C2/9A77: 8A           TXA 
	CLC 									;C2/9A78: 18           CLC 
	ADC #CharStruct.Headgear						;C2/9A79: 69 0E 20     ADC #$200E	
	STA $0E			;pointer to equipment slot			;C2/9A7C: 85 0E        STA $0E		
	TDC 									;C2/9A7E: 7B           TDC 
	SEP #$20								;C2/9A7F: E2 20        SEP #$20		
	LDA CurrentChar								;C2/9A81: AD 7B 7B     LDA $7B7B	
	TAX 									;C2/9A84: AA           TAX 
	LDA ROMTimes84,X	;*84,  7*12 byte equipment slots		;C2/9A85: BF 85 ED D0  LDA $D0ED85,X	
	TAX 									;C2/9A89: AA           TAX 
	STX $10			;GearStats character offset			;C2/9A8A: 86 10        STX $10		
	STX $0A			;GearStats character offset			;C2/9A8C: 86 0A        STX $0A		
	TDC 									;C2/9A8E: 7B           TDC 		
	TAY 									;C2/9A8F: A8           TAY 		
	STY $14			;equipment slot index (0-6)			;C2/9A90: 84 14        STY $14		

.CopySevenItemsData:		;copy data for all 7 item slots from ROM
	LDY $14									;C2/9A92: A4 14        LDY $14		
	LDA ($0E),Y		;current equipment slot				;C2/9A94: B1 0E        LDA ($0E),Y	
	REP #$20								;C2/9A96: C2 20        REP #$20		
	JSR ShiftMultiply_4							;C2/9A98: 20 B7 01     JSR $01B7	
	STA $16			;current equipment *4				;C2/9A9B: 85 16        STA $16		
	ASL 			;current equipment *8				;C2/9A9D: 0A           ASL 		
	CLC 									;C2/9A9E: 18           CLC 
	ADC $16									;C2/9A9F: 65 16        ADC $16		
	TAX 			;equipment *12, offset into ROMItems data	;C2/9AA1: AA           TAX 		
	TDC 									;C2/9AA2: 7B           TDC 		
	SEP #$20								;C2/9AA3: E2 20        SEP #$20		
	STZ $18									;C2/9AA5: 64 18        STZ $18		
	LDY $10									;C2/9AA7: A4 10        LDY $10		

.CopyOneItemData		;copy 12 bytes of data for current item							
	LDA !ROMItems,X								;C2/9AA9: BF 00 00 D1  LDA $D10000,X	
	STA !GearStats,Y							;C2/9AAD: 99 49 40     STA $4049,Y	
	INX 									;C2/9AB0: E8           INX 		
	INY 									;C2/9AB1: C8           INY 
	INC $18									;C2/9AB2: E6 18        INC $18
	LDA $18									;C2/9AB4: A5 18        LDA $18
	CMP #$0C		;12 bytes per item				;C2/9AB6: C9 0C        CMP #$0C		
	BNE .CopyOneItemData							;C2/9AB8: D0 EF        BNE $9AA9
															
	REP #$20								;C2/9ABA: C2 20        REP #$20		
	CLC 									;C2/9ABC: 18           CLC 
	LDA $10									;C2/9ABD: A5 10        LDA $10		
	ADC #$000C		;next item in GearStats				;C2/9ABF: 69 0C 00     ADC #$000C
	STA $10									;C2/9AC2: 85 10        STA $10		
	TDC 									;C2/9AC4: 7B           TDC 
	SEP #$20								;C2/9AC5: E2 20        SEP #$20		
	INC $14			;next equipment slot index 			;C2/9AC7: E6 14        INC $14
	LDA $14									;C2/9AC9: A5 14        LDA $14
	CMP #$07		;7 slots					;C2/9ACB: C9 07        CMP #$07		
	BNE .CopySevenItemsData							;C2/9ACD: D0 C3        BNE $9A92
															
	TDC 									;C2/9ACF: 7B           TDC 		
;	we don't need to init these
;	TAX 									;C2/9AD0: AA           TAX 		
;	STX Temp		;scratch area					;C2/9AD1: 8E 20 26     STX $2620	
;	STX TempStats								;C2/9AD4: 8E 22 26     STX $2622	
;	STX TempStats+2								;C2/9AD7: 8E 24 26     STX $2624
;	STX TempStats+4								;C2/9ADA: 8E 26 26     STX $2626
;	STX TempStats+6								;C2/9ADD: 8E 28 26     STX $2628
;	STX $12									;C2/9AE0: 86 12        STX $12		
	TAY 									;C2/9AE2: A8           TAY 		
	STY Temp
	STZ $13
	LDX AttackerOffset							;C2/9AE3: A6 32        LDX $32		
															
-	LDA CharStruct.BaseStr,X						;C2/9AE5: BD 24 20     LDA $2024,X	
	STA TempStats,Y
	INX
	INY
	CPY #$0004
	BCC -
	
	LDY $0A			;GearStats character offset			;C2/9AFF: A4 0A        LDY $0A
.ApplyStatsElementUp		;adds stat and element up bonuses for all 7 item slots
	LDA GearStats.ElementOrStatsUp,Y					;C2/9B01: B9 4C 40     LDA $404C,Y	
	BMI .Stats								;C2/9B04: 30 0A        BMI $9B10	
	ORA Temp								;C2/9B06: 0D 20 26     ORA $2620	
	STA Temp								;C2/9B09: 8D 20 26     STA $2620	
	BRA .NextItemStats							;C2/9B0E: 80 35        BRA $9B45	
	
.Stats									
	PHA 									;C2/9B10: 48           PHA 		
	AND #$07		;stat bonus bits				;C2/9B11: 29 07	       AND #$07	
	ASL									;C2/9B13: 0A	       ASL		
	TAX 									;C2/9B14: AA           TAX 		
	LDA ROMStatBonuses,X							;C2/9B15: BF 80 28 D1  LDA $D12880,X	
	STA $14			;stat bonus 1					;C2/9B19: 85 14        STA $14		
	LDA ROMStatBonuses+1,X							;C2/9B1B: BF 81 28 D1  LDA $D12881,X	
	STA $16			;stat bonus 2					;C2/9B1F: 85 16        STA $16		
+	PLA 									;C2/9B21: 68           PLA 		
	ASL 									;C2/9B22: 0A           ASL 		
	STA $19			;stats to change				;C2/9B23: 85 19        STA $19		
	TDC 									;C2/9B25: 7B           TDC 		
	TAX 									;C2/9B26: AA           TAX 		

.AddBonusStats
	ASL $19			;shift stat bit into carry			;C2/9B2D: 06 18        ASL $18		
	BCS .Bonus2								;C2/9B2F: B0 04        BCS $9B35	
	LDA $14			;bonus 1 if bit unset				;C2/9B31: A5 14        LDA $14		
	BRA +									;C2/9B33: 80 02        BRA $9B37	
.Bonus2	LDA $16			;bonus 2 if bit set				;C2/9B35: A5 16        LDA $16
+	CLC 									;C2/9B37: 18           CLC 
	ADC TempStats,X		;adds Bonus					;C2/9B38: 7D 22 26     ADC $2622,X	
	STA TempStats,X								;C2/9B3B: 9D 22 26     STA $2622,X	
	INX 									;C2/9B3F: E8           INX 
	CPX #$0004		;4 stats					;C2/9B40: E0 08 00     CPX #$0008	
	BNE .AddBonusStats							;C2/9B43: D0 E8        BNE $9B2D
															
.NextItemStats
	REP #$21
	TYA 									;C2/9B45: 98           TYA 
	ADC #$000C		;next item slot in GearStats table		;C2/9B47: 69 0C 00     ADC #$000C	
	TAY 									;C2/9B4A: A8           TAY 		
	TDC 									;C2/9B4B: 7B           TDC 		
	SEP #$20								;C2/9B4C: E2 20        SEP #$20	
	INC $13			;item slot index				;C2/9B4E: E6 13        INC $13		
	LDA $13									;C2/9B50: A5 13        LDA $13		
	CMP #$07		;7 item slots					;C2/9B52: C9 07        CMP #$07	
	BNE .ApplyStatsElementUp						;C2/9B54: D0 AB        BNE $9B01	
															
	TDC 									;C2/9B6E: 7B           TDC 
	TAY
	SEP #$20		;copying just low bytes				;C2/9B6F: E2 20        SEP #$20	
	LDX AttackerOffset							;C2/9B73: A6 32        LDX $32		
	LDA Temp	;element up						;C2/9B75: AD 20 26     LDA $2620	
;			;vanilla clears high bit but it can't be set by code flow here
;	AND #$7F	;high bit used as stats flag, can't have +water on gear ;C2/9B78: 29 7F        AND #$7F	

if !_CombatTweaks	;sets water bit if all of the other bits are set (ignoring holy)
	AND #$6F
	CMP #$6F	
	BNE .Normal	;not all set, just apply normally
	LDA Temp	
	ORA #$80	;set water up bit
.Normal
endif

	STA CharStruct.ElementUp,X						;C2/9B7A: 9D 22 20     STA $2022,X	
	
.ApplyStatsLoop
	LDA TempStats,Y								;C2/9B7D: AD 22 26     LDA $2622
if !_Fix_Stat_Underflow		;zero out underflowed stats before applying
	BPL +
	TDC		
endif
+	STA CharStruct.EquippedStr,X						;C2/9B80: 9D 28 20     STA $2028,X	
	INY
	INX
	CPY #$0004
	BCC .ApplyStatsLoop

	LDX AttackerOffset							;C2/9B73: A6 32        LDX $32		
	STZ CharStruct.MSwordAnim,X						;C2/9BA7: 9E 7A 20     STZ $207A,X	

.ClearMSwordLoop
	LDY #$0005
-	STZ CharStruct.MSwordElemental1,X
	INX
	DEY
	BPL -

;replaced by loop	
;	STZ CharStruct.MSwordElemental1,X					;C2/9B95: 9E 50 20     STZ $2050,X
;	STZ CharStruct.MSwordElemental2,X					;C2/9B98: 9E 51 20     STZ $2051,X	
;	STZ CharStruct.MSwordElemental3,X					;C2/9B9B: 9E 52 20     STZ $2052,X	
;	STZ CharStruct.MSwordStatus1,X						;C2/9B9E: 9E 53 20     STZ $2053,X	
;	STZ CharStruct.MSwordStatus2,X						;C2/9BA1: 9E 54 20     STZ $2054,X	
;	STZ CharStruct.MSwordStatusSpecial,X					;C2/9BA4: 9E 55 20     STZ $2055,X	
	
	LDX AttackerOffset							;C2/9B73: A6 32        LDX $32		
	LDY $0A			;GearStats character offset			;C2/9B71: A4 0A        LDY $0A		
	LDA RHWeapon.Category,Y							;C2/9BAA: B9 86 40     LDA $4086,Y	
	STA CharStruct.RHCategory,X						;C2/9BAD: 9D 6C 20     STA $206C,X
	LDA LHWeapon.Category,Y							;C2/9BB0: B9 92 40     LDA $4092,Y	
	STA CharStruct.LHCategory,X						;C2/9BB3: 9D 6D 20     STA $206D,X
	LDA RHWeapon.AtkPower,Y							;C2/9BB6: B9 8C 40     LDA $408C,Y	
	STA CharStruct.MonsterAttack,X						;C2/9BB9: 9D 44 20     STA $2044,X
	LDA LHWeapon.AtkPower,Y							;C2/9BBC: B9 98 40     LDA $4098,Y	
	STA CharStruct.MonsterAttackLH,X					;C2/9BBF: 9D 45 20     STA $2045,X

if !_StackingDefender		;if 2 weapons with the same defense bit are set, set the extra bit #$10 so later code can stack the chance
	LDA RHWeapon.Properties,Y						;C2/9BC2: B9 8A 40     LDA $408A,Y	
	STA $0E
	ORA LHWeapon.Properties,Y						;C2/9BC5: 19 96 40     ORA $4096,Y	
	STA CharStruct.WeaponProperties,X					;C2/9BC8: 9D 38 20     STA $2038,X

	LDA LHWeapon.Properties,Y							
	BMI .SwordBlock
	AND #$40
	BEQ .ExitStackingDefender

	;knife block in lh, check rh
	BIT $0E
	BVS .SetExtraFlag
	BRA .ExitStackingDefender
	
.SwordBlock	;sword block in lh, check rh
	BIT $0E
	BMI .SetExtraFlag
	BRA .ExitStackingDefender
	
.SetExtraFlag	
	LDA CharStruct.WeaponProperties,X
	ORA #$10
	STA CharStruct.WeaponProperties,X
	
.ExitStackingDefender
else

	LDA RHWeapon.Properties,Y						;C2/9BC2: B9 8A 40     LDA $408A,Y	
	ORA LHWeapon.Properties,Y						;C2/9BC5: 19 96 40     ORA $4096,Y	
	STA CharStruct.WeaponProperties,X					;C2/9BC8: 9D 38 20     STA $2038,X
endif

	CLC 									;C2/9BCB: 18           CLC 
	LDA RHShield.ShieldEvade,Y						;C2/9BCC: B9 73 40     LDA $4073,Y	
	ADC LHShield.ShieldEvade,Y						;C2/9BCF: 79 7F 40     ADC $407F,Y	
if !_ArmorEvade			;vanilla doesn't add evade for armor slots, now we do
	ADC Headgear.ShieldEvade,Y
	ADC Bodywear.ShieldEvade,Y
        ADC Accessory.ShieldEvade,Y
endif
	CMP #$63								;C2/9BD2: C9 63        CMP #$63		
	BCC +									;C2/9BD4: 90 02        BCC $9BD8	
	LDA #$63	;99 cap	for Evade					;C2/9BD6: A9 63        LDA #$63		
+	STA CharStruct.Evade,X							;C2/9BD8: 9D 2C 20     STA $202C,X	
	CLC 									;C2/9BDB: 18           CLC 
	LDA Headgear.Defense,Y							;C2/9BDC: B9 50 40     LDA $4050,Y	
	ADC Bodywear.Defense,Y							;C2/9BDF: 79 5C 40     ADC $405C,Y	
	BCS +									;C2/9BE2: B0 0F        BCS $9BF3	
	ADC Accessory.Defense,Y							;C2/9BE4: 79 68 40     ADC $4068,Y	
	BCS +									;C2/9BE7: B0 0A        BCS $9BF3	
	ADC RHShield.Defense,Y							;C2/9BE9: 79 74 40     ADC $4074,Y	
	BCS +									;C2/9BEC: B0 05        BCS $9BF3	
	ADC LHShield.Defense,Y							;C2/9BEE: 79 80 40     ADC $4080,Y	
	BCC ++									;C2/9BF1: 90 02        BCC $9BF5	
+	LDA #$FF	;255 cap for Defense					;C2/9BF3: A9 FF        LDA #$FF		
++	STA CharStruct.Defense,X						;C2/9BF5: 9D 2D 20     STA $202D,X	
	CLC 									;C2/9BF8: 18           CLC 
	LDA Headgear.MEvade,Y							;C2/9BF9: B9 51 40     LDA $4051,Y	
	ADC Bodywear.MEvade,Y							;C2/9BFC: 79 5D 40     ADC $405D,Y	
	ADC Accessory.MEvade,Y							;C2/9BFF: 79 69 40     ADC $4069,Y	
	ADC RHShield.MEvade,Y							;C2/9C02: 79 75 40     ADC $4075,Y	
	ADC LHShield.MEvade,Y							;C2/9C05: 79 81 40     ADC $4081,Y	
	CMP #$63								;C2/9C08: C9 63        CMP #$63		
	BCC +									;C2/9C0A: 90 02        BCC $9C0E	
	LDA #$63	;99 cap	for MEvade					;C2/9C0C: A9 63        LDA #$63		
+	STA CharStruct.MEvade,X							;C2/9C0E: 9D 2E 20     STA $202E,X	
	CLC 									;C2/9C11: 18           CLC 
	LDA Headgear.MDefense,Y							;C2/9C12: B9 52 40     LDA $4052,Y	
	ADC Bodywear.MDefense,Y      						;C2/9C15: 79 5E 40     ADC $405E,Y      
	BCS +       								;C2/9C18: B0 0F        BCS $9C29        
	ADC Accessory.MDefense,Y      						;C2/9C1A: 79 6A 40     ADC $406A,Y      
	BCS +        								;C2/9C1D: B0 0A        BCS $9C29        
	ADC RHShield.MDefense,Y      						;C2/9C1F: 79 76 40     ADC $4076,Y      
	BCS +        								;C2/9C22: B0 05        BCS $9C29        
	ADC LHShield.MDefense,Y      						;C2/9C24: 79 82 40     ADC $4082,Y      
	BCC ++       								;C2/9C27: 90 02        BCC $9C2B        
+	LDA #$FF        ;255 cap for MDef					;C2/9C29: A9 FF        LDA #$FF         
++	STA CharStruct.MDefense,X						;C2/9C2B: 9D 2F 20     STA $202F,X
	LDA Headgear.Properties,Y						;C2/9C2E: B9 4E 40     LDA $404E,Y	
	ORA Bodywear.Properties,Y						;C2/9C31: 19 5A 40     ORA $405A,Y	
	ORA Accessory.Properties,Y						;C2/9C34: 19 66 40     ORA $4066,Y	
	ORA RHShield.Properties,Y						;C2/9C37: 19 72 40     ORA $4072,Y	
	ORA LHShield.Properties,Y						;C2/9C3A: 19 7E 40     ORA $407E,Y	
	STA CharStruct.ArmorProperties,X					;C2/9C3D: 9D 39 20     STA $2039,X	
	TDC 									;C2/9C40: 7B           TDC 		
	TAX 									;C2/9C41: AA           TAX 		
	STX Temp								;C2/9C42: 8E 20 26     STX $2620	
	STX Temp+2		;reusing memory that was TempStats		;C2/9C45: 8E 22 26     STX $2622	
	STX Temp+4								;C2/9C48: 8E 24 26     STX $2624	
	STX $0E			;armor slot index				;C2/9C4B: 86 0E        STX $0E		
	LDY $0A			;GearStats character offset			;C2/9C4D: A4 0A        LDY $0A		
	STY $10									;C2/9C4F: 84 10        STY $10

.CopyArmorElementDef													
	LDY $10			;item offset					;C2/9C51: A4 10        LDY $10		
	LDA GearStats.ElementDef,Y						;C2/9C53: B9 53 40     LDA $4053,Y	
	REP #$20								;C2/9C56: C2 20        REP #$20		
	STA $12									;C2/9C58: 85 12        STA $12		
	JSR ShiftMultiply_4							;C2/9C5A: 20 B7 01     JSR $01B7	
	CLC 									;C2/9C5D: 18           CLC 
	ADC $12			;ROMElementDef offset (ElementDef*5)		;C2/9C5E: 65 12        ADC $12		
	TAX 									;C2/9C60: AA           TAX 		
	TDC 									;C2/9C61: 7B           TDC 		
	SEP #$20								;C2/9C62: E2 20        SEP #$20		
	TAY 									;C2/9C64: A8           TAY 		

.CopyROMElementDef													
	LDA !ROMElementDef,X							;C2/9C65: BF 80 25 D1  LDA $D12580,X	
	ORA Temp,Y								;C2/9C69: 19 20 26     ORA $2620,Y	
	STA Temp,Y								;C2/9C6C: 99 20 26     STA $2620,Y	
	INX 									;C2/9C6F: E8           INX 		
	INY									;C2/9C70: C8           INY		
	CPY #$0005	;5 bytes absorb, evade, immunity, half, weakness	;C2/9C71: C0 05 00     CPY #$0005	
	BNE .CopyROMElementDef							;C2/9C74: D0 EF        BNE $9C65	

	REP #$20								;C2/9C76: C2 20        REP #$20	
	LDA $10		;item offset						;C2/9C78: A5 10        LDA $10		
	CLC									;C2/9C7A: 18           CLC
	ADC #$000C	;next item						;C2/9C7B: 69 0C 00     ADC #$000C	
	STA $10									;C2/9C7E: 85 10        STA $10		
	TDC									;C2/9C80: 7B           TDC
	SEP #$20								;C2/9C81: E2 20        SEP #$20		
	INC $0E		;armor slot index, next slot				;C2/9C83: E6 0E        INC $0E		
	LDA $0E									;C2/9C85: A5 0E        LDA $0E		
	CMP #$05	;5 armor slots						;C2/9C87: C9 05        CMP #$05		
	BNE .CopyArmorElementDef						;C2/9C89: D0 C6        BNE $9C51	
															
	TDC 									;C2/9C8B: 7B           TDC 
	TAY 									;C2/9C8C: A8           TAY 
	LDX AttackerOffset							;C2/9C8D: A6 32        LDX $32		

.ApplyElementDef													
	LDA Temp,Y								;C2/9C8F: B9 20 26     LDA $2620,Y	
	STA CharStruct.EAbsorb,X						;C2/9C92: 9D 30 20     STA $2030,X	
	INX 									;C2/9C95: E8           INX 		
	INY 									;C2/9C96: C8           INY 		
	CPY #$0005	;5 bytes absorb, evade, immunity, half, weakness	;C2/9C97: C0 05 00     CPY #$0005	
	BNE .ApplyElementDef							;C2/9C9A: D0 F3        BNE $9C8F	
															
	STZ Temp								;C2/9C9C: 9C 20 26     STZ $2620	
	STZ Temp+1								;C2/9C9F: 9C 21 26     STZ $2621	
	STZ Temp+2								;C2/9CA2: 9C 22 26     STZ $2622	
	STZ $0E									;C2/9CA5: 64 0E        STZ $0E		
	LDX $0A									;C2/9CA7: A6 0A        LDX $0A		
	STX $10		;GearStats character offset				;C2/9CA9: 86 10        STX $10		

.CopyROMStatusImmunities:												
	LDY $10									;C2/9CAB: A4 10        LDY $10
	LDA GearStats.Status,Y							;C2/9CAD: B9 54 40     LDA $4054,Y	
	STA $24									;C2/9CB0: 85 24        STA $24		
	LDA #$07								;C2/9CB2: A9 07        LDA #$07		
	STA $25									;C2/9CB4: 85 25        STA $25
	JSR Multiply_8bit							;C2/9CB6: 20 F1 00     JSR $00F1	
	TDC 									;C2/9CB9: 7B           TDC 		
	TAY 									;C2/9CBA: A8           TAY 		
	LDX $26		;ROMArmorStatus offset (GearStats.Status*7)		;C2/9CBB: A6 26        LDX $26		

.CopyROMImmunities													
	LDA ROMArmorStatus.Immune1,X						;C2/9CBD: BF C4 26 D1  LDA $D126C4,X	
	ORA Temp,Y								;C2/9CC1: 19 20 26     ORA $2620,Y	
	STA Temp,Y								;C2/9CC4: 99 20 26     STA $2620,Y	
	INX 									;C2/9CC7: E8           INX 		
	INY 									;C2/9CC8: C8           INY 		
	CPY #$0003	;3 bytes of immunities					;C2/9CC9: C0 03 00     CPY #$0003	
	BNE .CopyROMImmunities							;C2/9CCC: D0 EF        BNE $9CBD	
															
	LDA $0E		;armor slot index					;C2/9CCE: A5 0E        LDA $0E		
	PHA									;C2/9CD0: 48           PHA
	JSR ApplyEquipmentStatus						;C2/9CD1: 20 01 9D     JSR $9D01	
	PLA 									;C2/9CD4: 68           PLA 
	STA $0E									;C2/9CD5: 85 0E        STA $0E		
	REP #$20								;C2/9CD7: C2 20        REP #$20		
	LDA $10		;GearStats offset					;C2/9CD9: A5 10        LDA $10		
	CLC 									;C2/9CDB: 18           CLC 		
	ADC #$000C	;next item						;C2/9CDC: 69 0C 00     ADC #$000C	
	STA $10									;C2/9CDF: 85 10        STA $10		
	TDC 									;C2/9CE1: 7B           TDC 		
	SEP #$20								;C2/9CE2: E2 20        SEP #$20		
	INC $0E		;armor slot index, next slot				;C2/9CE4: E6 0E        INC $0E		
	LDA $0E									;C2/9CE6: A5 0E        LDA $0E		
	CMP #$05	;5 armor slots						;C2/9CE8: C9 05        CMP #$05		
	BNE .CopyROMStatusImmunities						;C2/9CEA: D0 BF        BNE $9CAB	
															
	TDC 									;C2/9CEC: 7B           TDC 		
	TAY 									;C2/9CED: A8           TAY 		
	LDX AttackerOffset							;C2/9CEE: A6 32        LDX $32		

.ApplyImmunities													
	LDA CharStruct.StatusImmune1,X						;C2/9CF0: BD 35 20     LDA $2035,X	
	ORA Temp,Y								;C2/9CF3: 19 20 26     ORA $2620,Y	
	STA CharStruct.StatusImmune1,X						;C2/9CF6: 9D 35 20     STA $2035,X	
	INX 									;C2/9CF9: E8           INX 		
	INY 									;C2/9CFA: C8           INY 		
	CPY #$0003	;Status 1-3 immunity					;C2/9CFB: C0 03 00     CPY #$0003	
	BNE .ApplyImmunities							;C2/9CFE: D0 F0        BNE $9CF0	
															
	RTS	 


endif