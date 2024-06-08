if !_Optimize

;optimizations: 	
;		optimize inventory setup, removing a second loop through the inventory	

;sets up inventory and magic lists
SetupInventoryMagic:
	TDC 										;C2/41AF: 7B           TDC 		
	TAX 										;C2/41B0: AA           TAX 		
	LDA #$80									;C2/41B1: A9 80        LDA #$80		
											;:					
-	STA InventoryFlags,X								;C2/41B3: 9D 34 2B     STA $2B34,X	
	INX										;C2/41B6: E8           INX		
	CPX #$0100									;C2/41B7: E0 00 01     CPX #$0100	
	BNE -										;C2/41BA: D0 F7        BNE $41B3	
											;.					
	TDC 										;C2/41BC: 7B           TDC 		
	TAX 										;C2/41BD: AA           TAX 		
	STX $0E										;C2/41BE: 86 0E        STX $0E		
											;:					
.InitSpells
	TDC 										;C2/41C0: 7B           TDC 		
	TAY 										;C2/41C1: A8           TAY 		
	LDA #$81									;C2/41C2: A9 81        LDA #$81		
											;:					
-	STA CharSpells.Flags,X								;C2/41C4: 9D 3C 2F     STA $2F3C,X	
	STA CharSpells.Level,X								;C2/41C7: 9D B6 2D     STA $2DB6,X	
	INX 										;C2/41CA: E8           INX 		
	INY 										;C2/41CB: C8           INY 		
	CPY #$0082									;C2/41CC: C0 82 00     CPY #$0082	
	BNE -										;C2/41CF: D0 F3        BNE $41C4	
											;.					
	REP #$20									;C2/41D1: C2 20        REP #$20		
	TXA										;C2/41D3: 8A           TXA		
	CLC										;C2/41D4: 18           CLC		
	ADC #$0208	;next CharSpells struct						;C2/41D5: 69 08 02     ADC #$0208	
	TAX										;C2/41D8: AA           TAX		
	TDC 										;C2/41D9: 7B           TDC 		
	SEP #$20									;C2/41DA: E2 20        SEP #$20		
	INC $0E		;next char index						;C2/41DC: E6 0E        INC $0E		
	LDA $0E										;C2/41DE: A5 0E        LDA $0E		
	CMP #$04	;4 chars							;C2/41E0: C9 04        CMP #$04		
	BNE .InitSpells									;C2/41E2: D0 DC        BNE $41C0	
											;.					
	TDC 										;C2/41E4: 7B           TDC 		
	TAX 										;C2/41E5: AA           TAX 		
	STX $0E										;C2/41E6: 86 0E        STX $0E		
											;:					
.InitCmdFlags	
	TDC 										;C2/41E8: 7B           TDC 		
	TAY 										;C2/41E9: A8           TAY 		
	LDA #$80									;C2/41EA: A9 80        LDA #$80		
											;:					
-	STA CharCommands.Flags,X							;C2/41EC: 9D 6C 37     STA $376C,X	
	INX										;C2/41EF: E8           INX		
	INY 										;C2/41F0: C8           INY 		
	CPY #$0004	;4 bytes of command data					;C2/41F1: C0 04 00     CPY #$0004	
	BNE -										;C2/41F4: D0 F6        BNE $41EC	
											;.					
	TXA										;C2/41F6: 8A           TXA		
	CLC 										;C2/41F7: 18           CLC 		
	ADC #$10	;next CharCommands Struct					;C2/41F8: 69 10        ADC #$10		
	TAX 										;C2/41FA: AA           TAX 		
	INC $0E		;next char index						;C2/41FB: E6 0E        INC $0E
	LDA $0E										;C2/41FD: A5 0E        LDA $0E
	CMP #$04	;4 chars							;C2/41FF: C9 04        CMP #$04
	BNE .InitCmdFlags								;C2/4201: D0 E5        BNE $41E8	

	TDC 										;C2/4203: 7B           TDC 		
	TAX              								;C2/4204: AA           TAX              
	STX $0E          								;C2/4205: 86 0E        STX $0E          

.InitHandItemFlags									;:				
	TDC 										;C2/4207: 7B           TDC 		
	TAY              								;C2/4208: A8           TAY              
	LDA #$80									;C2/4209: A9 80        LDA #$80		
	
-	STA HandItems.Flags,X								;C2/420B: 9D B4 37     STA $37B4,X
	INX 										;C2/420E: E8           INX 
	INY 										;C2/420F: C8           INY 
	CPY #$0002	;structure has room for 4 values but only 2 hands are used	;C2/4210: C0 02 00     CPY #$0002
	BNE -										;C2/4213: D0 F6        BNE $420B
	
	TXA										;C2/4215: 8A           TXA
	CLC 										;C2/4216: 18           CLC 
	ADC #$0A	;next charcter in HandItems					;C2/4217: 69 0A        ADC #$0A		
	TAX 										;C2/4219: AA           TAX 
	INC $0E		;next char index						;C2/421A: E6 0E        INC $0E
	LDA $0E										;C2/421C: A5 0E        LDA $0E
	CMP #$04	;4 chars							;C2/421E: C9 04        CMP #$04
	BNE .InitHandItemFlags								;C2/4220: D0 E5        BNE $4207
	
	TDC 										;C2/4222: 7B           TDC 		
	TAY 										;C2/4223: A8           TAY 		
	TAX 										;C2/4224: AA           TAX 		
	STY $0E										;C2/4225: 84 0E        STY $0E	
	
.CopyEquipInfo
	STZ $0E										;C2/4227: 64 0E        STZ $0E		
	PHX 										;C2/4229: DA           PHX 		
											;:					
-	LDA CharStruct.EquipWeapons,X							;C2/422A: BD 40 20     LDA $2040,X	
	STA CharEquippable.Weapons,Y							;C2/422D: 99 99 41     STA $4199,Y
	INX 										;C2/4230: E8           INX 
	INY 										;C2/4231: C8           INY 
	INC $0E		;next byte							;C2/4232: E6 0E        INC $0E
	LDA $0E										;C2/4234: A5 0E        LDA $0E
	CMP #$04	;4 bytes of weapon/armor equip data				;C2/4236: C9 04        CMP #$04
	BNE -										;C2/4238: D0 F0        BNE $422A
											;.					
	PLX 										;C2/423A: FA           PLX 		
	JSR NextCharOffset								;C2/423B: 20 E0 01     JSR $01E0	
	INC $0F		;next char index						;C2/423E: E6 0F        INC $0F
	LDA $0F										;C2/4240: A5 0F        LDA $0F
	CMP #$04	;4 chars							;C2/4242: C9 04        CMP #$04
	BNE .CopyEquipInfo								;C2/4244: D0 E1        BNE $4227
											;.					
	JSL CleanupFieldItems_D0	;wtf, code in the data bank			;C2/4246: 22 78 EF D0  JSL $D0EF78	
	TDC 			;it sets items with qty 0 to id 0			;C2/424A: 7B           TDC 		
	TAX 			;and sets items with id 0 to qty 0			;C2/424B: AA           TAX 		
	TAY 										;C2/424C: A8           TAY 		
											;:					
-	LDA FieldItems,X								;C2/424D: BD 40 06     LDA $0640,X	
	STA InventoryItems,X								;C2/4250: 9D 34 27     STA $2734,X
	INX 										;C2/4253: E8           INX 
	CPX #$0200		;512, includes item quantities				;C2/4254: E0 00 02     CPX #$0200
	BNE -										;C2/4257: D0 F4        BNE $424D	
											;.					
-	LDA InventoryItems,Y								;C2/4259: B9 34 27     LDA $2734,Y	
	JSR SetupInventoryInfo	;sets InventoryFlags and Temp (equipment type)		;C2/425C: 20 FA 03     JSR $03FA	
	INY 										;C2/425F: C8           INY 
	CPY #$0100									;C2/4260: C0 00 01     CPY #$0100	
	BNE -										;C2/4263: D0 F4        BNE $4259
											;.					
	TDC										;C2/4265: 7B           TDC		
	TAY										;C2/4266: A8           TAY		
	STY $08										;C2/4267: 84 08        STY $08		
if !_Optimize			;**optimize: 	bypass temp and just save to proper place,
				;		removing a secondary loop
-	JSR GetItemUsableY	;after, A holds byte for InventoryUsable			
	LDY $08										
	STA InventoryUsable,Y		
	INY
	STY $08
	TYA			;transfers Y to A to crop it to low 8 bits
	BNE -			;loop ends after it wraps back to 0 (256 item slots)			
else	
-	LDY $08										;C2/4269: A4 08        LDY $08		
	JSR GetItemUsableY	;after, A now holds byte for InventoryUsable		;C2/426B: 20 69 03     JSR $0369	
	LDY $08										;C2/426E: A4 08        LDY $08		
	STA Temp,Y									;C2/4270: 99 20 26     STA $2620,Y	
	INC $08										;C2/4273: E6 08        INC $08		
	LDA $08										;C2/4275: A5 08        LDA $08		
	BNE -										;C2/4277: D0 F0        BNE $4269	
											;.					
	TDC 										;C2/4279: 7B           TDC 		
	TAX										;C2/427A: AA           TAX		
											;: 					
-	LDA Temp,X									;C2/427B: BD 20 26     LDA $2620,X	
	STA InventoryUsable,X								;C2/427E: 9D 34 2C     STA $2C34,X
	INX 										;C2/4281: E8           INX 
	CPX #$0100									;C2/4282: E0 00 01     CPX #$0100
	BNE -										;C2/4285: D0 F4        BNE $427B
endif
	TAX 										;C2/4288: AA           TAX 		
	STX $0E		;MagicBits Index						;C2/4289: 86 0E        STX $0E		
	STX $10		;finished spell count						;C2/428B: 86 10        STX $10		
	STX $18		;blue magic flag						;C2/428D: 86 18        STX $18		
	INX 										;C2/428F: E8           INX 		
	STX $14		;current spell level 1-6					;C2/4290: 86 14        STX $14		

.MagicBitsLoop															
	LDA $0E		;MagicBits Index						;C2/4292: A5 0E        LDA $0E		
	CMP #$0C	;12 bytes of non-blue magic					;C2/4294: C9 0C        CMP #$0C		
	BCC +										;C2/4296: 90 0B        BCC $42A3	
	SEC 										;C2/4298: 38           SEC 		
	LDA $0E										;C2/4299: A5 0E        LDA $0E		
	SBC #$0C	;-12	back to start						;C2/429B: E9 0C        SBC #$0C		
	CLC 										;C2/429D: 18           CLC 		
	ADC #$10	;+16	start of blue magic					;C2/429E: 69 10        ADC #$10		
	TAX 										;C2/42A0: AA           TAX 		
	BRA ++										;C2/42A1: 80 02        BRA $42A5	

+	LDX $0E		;MagicBits Index						;C2/42A3: A6 0E        LDX $0E		

++	LDA MagicBits,X									;C2/42A5: BD 50 09     LDA $0950,X	
	STA $12		;current byte of MagicBits					;C2/42A8: 85 12        STA $12		
	LDY #$0008	;bit counter							;C2/42AA: A0 08 00     LDY #$0008	
																
.ProcessMagicBit
	LDX $10										;C2/42AD: A6 10        LDX $10		
	CPX #$0081									;C2/42AF: E0 81 00     CPX #$0081	
	BNE .CheckMagicBit								;C2/42B2: D0 03        BNE $42B7
	JMP .EnableSpells								;C2/42B4: 4C 67 43     JMP $4367	

.CheckMagicBit
	ASL $12		;current byte of MagicBits					;C2/42B7: 06 12        ASL $12		
	BCS .CheckBlue									;C2/42B9: B0 10        BCS $42CB	
	LDA #$FF									;C2/42BB: A9 FF        LDA #$FF		
	STA CharSpells[0].ID,X								;C2/42BD: 9D 34 2D     STA $2D34,X
	STA CharSpells[1].ID,X								;C2/42C0: 9D BE 2F     STA $2FBE,X
	STA CharSpells[2].ID,X								;C2/42C3: 9D 48 32     STA $3248,X
	STA CharSpells[3].ID,X								;C2/42C6: 9D D2 34     STA $34D2,X
	BRA .NextSpell									;C2/42C9: 80 6B        BRA $4336

.CheckBlue									
	TXA 										;C2/42CB: 8A           TXA 		
	CMP #$5F	;end of non-blue magic						;C2/42CC: C9 5F        CMP #$5F		
	BCC .SetupSpell									;C2/42CE: 90 18        BCC $42E8	
	SEC 										;C2/42D0: 38           SEC 
	SBC #$5F	;remove offset from other spells so first blue is 0		;C2/42D1: E9 5F        SBC #$5F		
	CLC 										;C2/42D3: 18           CLC 
	ADC #$80	;first blue now $80						;C2/42D4: 69 80        ADC #$80		
	PHA 										;C2/42D6: 48           PHA 		
	LDA #$FF	;clear the "original" blue magic position			;C2/42D7: A9 FF        LDA #$FF		
	STA CharSpells[0].ID,X								;C2/42D9: 9D 34 2D     STA $2D34,X
	STA CharSpells[1].ID,X								;C2/42DC: 9D BE 2F     STA $2FBE,X
	STA CharSpells[2].ID,X								;C2/42DF: 9D 48 32     STA $3248,X
	STA CharSpells[3].ID,X								;C2/42E2: 9D D2 34     STA $34D2,X
	PLA 										;C2/42E5: 68           PLA 		
	DEX 		;blue spells offset the whole structure by -2			;C2/42E6: CA           DEX 		
	DEX		;because there's 2 empty bits in the first blue byte		;C2/42E7: CA           DEX		

.SetupSpell									
	STX $20		;temp index							;C2/42E8: 86 20        STX $20		
	STA CharSpells[0].ID,X								;C2/42EA: 9D 34 2D     STA $2D34,X
	STA CharSpells[1].ID,X								;C2/42ED: 9D BE 2F     STA $2FBE,X
	STA CharSpells[2].ID,X								;C2/42F0: 9D 48 32     STA $3248,X
	STA CharSpells[3].ID,X								;C2/42F3: 9D D2 34     STA $34D2,X
	LDA $14		;current spell level						;C2/42F6: A5 14        LDA $14		
	STA CharSpells[0].Level,X							;C2/42F8: 9D B6 2D     STA $2DB6,X
	STA CharSpells[1].Level,X							;C2/42FB: 9D 40 30     STA $3040,X
	STA CharSpells[2].Level,X							;C2/42FE: 9D CA 32     STA $32CA,X
	STA CharSpells[3].Level,X							;C2/4301: 9D 54 35     STA $3554,X
	LDA CharSpells[0].ID,X								;C2/4304: BD 34 2D     LDA $2D34,X	
	REP #$20									;C2/4307: C2 20        REP #$20		
	JSR ShiftMultiply_8								;C2/4309: 20 B6 01     JSR $01B6	
	TAX 										;C2/430C: AA           TAX 		
	TDC 										;C2/430D: 7B           TDC 		
	SEP #$20									;C2/430E: E2 20        SEP #$20		
	LDA ROMMagicInfo.Targetting,X							;C2/4310: BF 80 0B D1  LDA $D10B80,X	
	PHA 										;C2/4314: 48           PHA 		
	LDA ROMMagicInfo.MPCost,X							;C2/4315: BF 83 0B D1  LDA $D10B83,X	
	AND #$7F	;just MP Cost							;C2/4319: 29 7F        AND #$7F		
	LDX $20										;C2/431B: A6 20        LDX $20		
	STA CharSpells[0].MP,X								;C2/431D: 9D 38 2E     STA $2E38,X	
	STA CharSpells[1].MP,X								;C2/4320: 9D C2 30     STA $30C2,X
	STA CharSpells[2].MP,X								;C2/4323: 9D 4C 33     STA $334C,X
	STA CharSpells[3].MP,X								;C2/4326: 9D D6 35     STA $35D6,X
	PLA 										;C2/4329: 68           PLA 
	STA CharSpells[0].Targetting,X							;C2/432A: 9D BA 2E     STA $2EBA,X
	STA CharSpells[1].Targetting,X							;C2/432D: 9D 44 31     STA $3144,X
	STA CharSpells[2].Targetting,X							;C2/4330: 9D CE 33     STA $33CE,X
	STA CharSpells[3].Targetting,X							;C2/4333: 9D 58 36     STA $3658,X

.NextSpell	
	INC $15		;counter for spells in a spell Level				;C2/4336: E6 15        INC $15		
	LDA $15										;C2/4338: A5 15        LDA $15
	CMP #$03	;max 3								;C2/433A: C9 03        CMP #$03		
	BNE .NextSpellCount								;C2/433C: D0 0E        BNE $434C	
	STZ $15										;C2/433E: 64 15        STZ $15		
	INC $14		;next spell level						;C2/4340: E6 14        INC $14		
	LDA $14										;C2/4342: A5 14        LDA $14
	CMP #$07	;only 6 spell levels						;C2/4344: C9 07        CMP #$07		
	BNE .NextSpellCount								;C2/4346: D0 04        BNE $434C	
	LDA #$01	;reset to spell level 1						;C2/4348: A9 01        LDA #$01		
	STA $14										;C2/434A: 85 14        STA $14		

.NextSpellCount
	INC $10		;finished spell count						;C2/434C: E6 10        INC $10
	LDA $18		;blue magic flag						;C2/434E: A5 18        LDA $18		
	BNE .NextSpellBit								;C2/4350: D0 0A        BNE $435C	
	LDA $10										;C2/4352: A5 10        LDA $10
	CMP #$5F	;last non-blue magic spell					;C2/4354: C9 5F        CMP #$5F		
	BCC .NextSpellBit								;C2/4356: 90 04        BCC $435C	
	INC $18		;blue magic flag						;C2/4358: E6 18        INC $18		
	BRA .NextSpellByte								;C2/435A: 80 06        BRA $4362

.NextSpellBit									
	DEY 		;bit counter							;C2/435C: 88           DEY 		
	BEQ .NextSpellByte								;C2/435D: F0 03        BEQ $4362
	JMP .ProcessMagicBit								;C2/435F: 4C AD 42     JMP $42AD

.NextSpellByte															
	INC $0E		;MagicBits Index (next)						;C2/4362: E6 0E        INC $0E		
	JMP .MagicBitsLoop								;C2/4364: 4C 92 42     JMP $4292	

.EnableSpells															
	TDC 										;C2/4367: 7B           TDC 		
	TAY 										;C2/4368: A8           TAY 		
	TAX 										;C2/4369: AA           TAX 		

.UnpackEnableSpells											;:			
	STZ $0E										;C2/436A: 64 0E        STZ $0E		
	PHX 										;C2/436C: DA           PHX 		

.UnpackOne											;:				
	LDA CharStruct.EnableSpells,X							;C2/436D: BD 3D 20     LDA $203D,X	
	PHA 										;C2/4370: 48           PHA 		
	JSR ShiftDivide_16								;C2/4371: 20 BE 01     JSR $01BE	
	INC 										;C2/4374: 1A           INC 		
	STA Temp,Y	;high 4 bits to first temp byte					;C2/4375: 99 20 26     STA $2620,Y	
	PLA 										;C2/4378: 68           PLA 		
	AND #$0F									;C2/4379: 29 0F        AND #$0F		
	INC 										;C2/437B: 1A           INC 		
	STA Temp+1,Y	;low 4 bits to second temp byte					;C2/437C: 99 21 26     STA $2621,Y	
	INY 										;C2/437F: C8           INY 		
	INY 										;C2/4380: C8           INY 		
	INX 										;C2/4381: E8           INX 		
	INC $0E										;C2/4382: E6 0E        INC $0E		
	LDA $0E										;C2/4384: A5 0E        LDA $0E
	CMP #$03	;3 bytes for 6 magic types					;C2/4386: C9 03        CMP #$03		
	BNE .UnpackOne									;C2/4388: D0 E3        BNE $436D	
											;.					
	PLX 										;C2/438A: FA           PLX 		
	JSR NextCharOffset								;C2/438B: 20 E0 01     JSR $01E0	
	CPY #$0018	;6 bytes * 4 characters						;C2/438E: C0 18 00     CPY #$0018	
	BNE .UnpackEnableSpells								;C2/4391: D0 D7        BNE $436A	
											;.					
	TDC										;C2/4393: 7B           TDC		
	TAX 										;C2/4394: AA           TAX 		
	TAY 										;C2/4395: A8           TAY 		
	STY $12		;character index						;C2/4396: 84 12        STY $12		
	STY HalfMP	;								;C2/4398: 84 3D        STY $3D		
	STY HalfMP+2									;C2/439A: 84 3F        STY $3F		

.AllCharSpellConditions											;:			
	STZ $1A		;half mp for current character					;C2/439C: 64 1A        STZ $1A		
	PHX 										;C2/439E: DA           PHX 		
	LDA $12		;character index						;C2/439F: A5 12        LDA $12		
	REP #$20									;C2/43A1: C2 20        REP #$20		
	JSR ShiftMultiply_128								;C2/43A3: 20 B2 01     JSR $01B2	
	TAX 										;C2/43A6: AA           TAX 		
	TDC 										;C2/43A7: 7B           TDC 		
	SEP #$20									;C2/43A8: E2 20        SEP #$20		
	LDA CharStruct.ArmorProperties,X						;C2/43AA: BD 39 20     LDA $2039,X	
	AND #$08	;half mp cost							;C2/43AD: 29 08        AND #$08		
	BEQ +										;C2/43AF: F0 07        BEQ $43B8	
	LDA $12		;character index						;C2/43B1: A5 12        LDA $12		
	TAX 										;C2/43B3: AA           TAX 		
	INC HalfMP,X									;C2/43B4: F6 3D        INC $3D,X	
	INC $1A		;half mp for current character					;C2/43B6: E6 1A        INC $1A		
	
+	PLX 										;C2/43B8: FA           PLX 		
	STZ $10			;spell type counter					;C2/43B9: 64 10        STZ $10		
	STZ $14			;spell counter						;C2/43BB: 64 14        STZ $14		

.CheckAllSpellConditions											;:		
	STZ $0E										;C2/43BD: 64 0E        STZ $0E		

.CheckSpellCond										;:					
	LDA $14			;spell counter						;C2/43BF: A5 14        LDA $14		
	CMP #$57		;stop at 87 spells					;C2/43C1: C9 57        CMP #$57		
	BEQ .NextSpellType								;C2/43C3: F0 34        BEQ $43F9	
	LDA CharSpells.Level,X								;C2/43C5: BD B6 2D     LDA $2DB6,X	
	CMP Temp,Y		;magic level enabled for current Type			;C2/43C8: D9 20 26     CMP $2620,Y
	BCS .LevelFail									;C2/43CB: B0 18        BCS $43E5
	LDA EncounterInfo.Flags								;C2/43CD: AD FE 3E     LDA $3EFE
	AND #$04	;Always Void							;C2/43D0: 29 04        AND #$04
	BNE .NextSpellCond								;C2/43D2: D0 1A        BNE $43EE
	STZ CharSpells.Flags,X								;C2/43D4: 9E 3C 2F     STZ $2F3C,X
	LDA $1A		;half mp for current character					;C2/43D7: A5 1A        LDA $1A
	BEQ .NextSpellCond								;C2/43D9: F0 13        BEQ $43EE
	LSR CharSpells.MP,X								;C2/43DB: 5E 38 2E     LSR $2E38,X
	BCC .NextSpellCond								;C2/43DE: 90 0E        BCC $43EE
	INC CharSpells.MP,X	;min 1							;C2/43E0: FE 38 2E     INC $2E38,X
	BRA .NextSpellCond								;C2/43E3: 80 09        BRA $43EE

.LevelFail
	LDA #$FF									;C2/43E5: A9 FF        LDA #$FF
	STA CharSpells.ID,X								;C2/43E7: 9D 34 2D     STA $2D34,X
	INC 										;C2/43EA: 1A           INC 
	STA CharSpells.MP,X								;C2/43EB: 9D 38 2E     STA $2E38,X

.NextSpellCond
	INC $14			;spell counter						;C2/43EE: E6 14        INC $14
	INX 										;C2/43F0: E8           INX 
	INC $0E										;C2/43F1: E6 0E        INC $0E
	LDA $0E										;C2/43F3: A5 0E        LDA $0E
	CMP #$12		;18 spells per type					;C2/43F5: C9 12        CMP #$12		
	BNE .CheckSpellCond								;C2/43F7: D0 C6        BNE $43BF

.NextSpellType									
	INY 			;index for magic level enabled table at Temp		;C2/43F9: C8           INY 
	INC $10			;spell type counter					;C2/43FA: E6 10        INC $10
	LDA $10										;C2/43FC: A5 10        LDA $10
	CMP #$05		;checking first 5 types 				;C2/43FE: C9 05        CMP #$05		
	BNE .CheckAllSpellConditions							;C2/4400: D0 BB        BNE $43BD
																
	REP #$20									;C2/4402: C2 20        REP #$20
	TXA 										;C2/4404: 8A           TXA 
	CLC 										;C2/4405: 18           CLC 
	ADC #$0233		;$57 + $233 is the size of the CharSpells Struct	;C2/4406: 69 33 02     ADC #$0233
	TAX 			;next character in CharSpells				;C2/4409: AA           TAX 
	TDC 										;C2/440A: 7B           TDC 
	SEP #$20									;C2/440B: E2 20        SEP #$20
	INY 										;C2/440D: C8           INY 
	INC $12			;character index					;C2/440E: E6 12        INC $12
	LDA $12										;C2/4410: A5 12        LDA $12
	CMP #$04		;4 characters						;C2/4412: C9 04        CMP #$04		
	BNE .AllCharSpellConditions							;C2/4414: D0 86        BNE $439C
											;.					
	LDA EncounterInfo.Flags								;C2/4416: AD FE 3E     LDA $3EFE	
	AND #$04		;always void						;C2/4419: 29 04        AND #$04		
	BNE .DoneSongBlue								;C2/441B: D0 46        BNE $4463	
	STZ $0E			;character index					;C2/441D: 64 0E        STZ $0E		
	LDX #$0057		;first spell after summons (songs then blue)		;C2/441F: A2 57 00     LDX #$0057	
	STX $12			;first song offset					;C2/4422: 86 12        STX $12		
											;:					
.AllSongBlue
	LDA $0E			;character index					;C2/4424: A5 0E        LDA $0E		
	TAX 										;C2/4426: AA           TAX 
	LDA HalfMP,X									;C2/4427: B5 3D        LDA $3D,X	
	STA $1A			;half mp for current character				;C2/4429: 85 1A        STA $1A
	STZ $10			;spell counter						;C2/442B: 64 10        STZ $10		
	LDX $12			;first song offset					;C2/442D: A6 12        LDX $12		

.SongBlue										;:					
	LDA CharSpells.ID,X								;C2/442F: BD 34 2D     LDA $2D34,X
	CMP #$FF									;C2/4432: C9 FF        CMP #$FF
	BEQ .NextSongBlue								;C2/4434: F0 0F        BEQ $4445
	STZ CharSpells.Flags,X								;C2/4436: 9E 3C 2F     STZ $2F3C,X
	LDA $1A			;half mp for current character				;C2/4439: A5 1A        LDA $1A
	BEQ .NextSongBlue								;C2/443B: F0 08        BEQ $4445
	LSR CharSpells.MP,X								;C2/443D: 5E 38 2E     LSR $2E38,X
	BCC .NextSongBlue								;C2/4440: 90 03        BCC $4445
	INC CharSpells.MP,X	;min 1							;C2/4442: FE 38 2E     INC $2E38,X

.NextSongBlue
	INX 			;charspell index					;C2/4445: E8           INX 
	INC $10			;spell counter						;C2/4446: E6 10        INC $10
	LDA $10										;C2/4448: A5 10        LDA $10
	CMP #$28		;40 spells (total of 128)				;C2/444A: C9 28        CMP #$28		
	BNE .SongBlue									;C2/444C: D0 E1        BNE $442F
					
	REP #$20									;C2/444E: C2 20        REP #$20		
	CLC 										;C2/4450: 18           CLC 
	LDA $12			;first song offset					;C2/4451: A5 12        LDA $12
	ADC #$028A		;size of CharSpells struct				;C2/4453: 69 8A 02     ADC #$028A	
	STA $12			;first song offset for next character			;C2/4456: 85 12        STA $12		
	TDC 										;C2/4458: 7B           TDC 
	SEP #$20									;C2/4459: E2 20        SEP #$20		
	INC $0E			;character index					;C2/445B: E6 0E        INC $0E
	LDA $0E										;C2/445D: A5 0E        LDA $0E		
	CMP #$04		;4 characters						;C2/445F: C9 04        CMP #$04		
	BNE .AllSongBlue								;C2/4461: D0 C1        BNE $4424	
				
.DoneSongBlue															
	TDC 										;C2/4463: 7B           TDC 		
	TAX 										;C2/4464: AA           TAX 		
	TAY 										;C2/4465: A8           TAY 		
	STY $0E										;C2/4466: 84 0E        STY $0E		
	STY $10			;character counter					;C2/4468: 84 10        STY $10		
											;:					
.AllSetupCmds
	STZ $11			;command counter					;C2/446A: 64 11        STZ $11		
	LDX $0E			;CharStruct offset					;C2/446C: A6 0E        LDX $0E		
											;:					
.SetupCmds
	PHX 										;C2/446E: DA           PHX 		
	LDA CharStruct.BattleCommands,X							;C2/446F: BD 16 20     LDA $2016,X	
	BEQ .NextCmd									;C2/4472: F0 2A        BEQ $449E	
	CMP #$50		;there are no commands $50 or higher			;C2/4474: C9 50        CMP #$50		
	BCS .NextCmd									;C2/4476: B0 26        BCS $449E	
	CMP #$1D		;Catch Command						;C2/4478: C9 1D        CMP #$1D		
	BNE .OtherCmd									;C2/447A: D0 0F        BNE $448B	
	LDX $0E										;C2/447C: A6 0E        LDX $0E		
	LDA CharStruct.CaughtMonster,X							;C2/447E: BD 15 20     LDA $2015,X	
	CMP #$FF		;no monster caught					;C2/4481: C9 FF        CMP #$FF		
	BEQ .Catch									;C2/4483: F0 04        BEQ $4489	
	LDA #$1E		;Release Command					;C2/4485: A9 1E        LDA #$1E		
	BRA .OtherCmd									;C2/4487: 80 02        BRA $448B

.Catch
	LDA #$1D									;C2/4489: A9 1D        LDA #$1D		
.OtherCmd	
	STA CharCommands.ID,Y								;C2/448B: 99 5C 37     STA $375C,Y	
	REP #$20									;C2/448E: C2 20        REP #$20		
	JSR ShiftMultiply_8								;C2/4490: 20 B6 01     JSR $01B6	
	TAX 										;C2/4493: AA           TAX 		
	TDC 										;C2/4494: 7B           TDC 		
	SEP #$20									;C2/4495: E2 20        SEP #$20		
	LDA ROMAbilityInfo.Targetting,X							;C2/4497: BF E0 59 D1  LDA $D159E0,X	
	STA CharCommands.Targetting,Y							;C2/449B: 99 68 37     STA $3768,Y	

.NextCmd
	PLX 			;CharStruct offset					;C2/449E: FA           PLX 		
	INY 			;next command id slot					;C2/449F: C8           INY 		
	INX 			;next command byte in CharStruct			;C2/44A0: E8           INX 
	INC $11			;command counter					;C2/44A1: E6 11        INC $11		
	LDA $11										;C2/44A3: A5 11        LDA $11		
	CMP #$04		;4 commands						;C2/44A5: C9 04        CMP #$04		
	BNE .SetupCmds									;C2/44A7: D0 C5        BNE $446E	
											;.					
	LDX $0E										;C2/44A9: A6 0E        LDX $0E		
	JSR NextCharOffset								;C2/44AB: 20 E0 01     JSR $01E0	
	STX $0E										;C2/44AE: 86 0E        STX $0E		
	TYA 										;C2/44B0: 98           TYA 		
	CLC 										;C2/44B1: 18           CLC 		
	ADC #$10		;next CharCommands character				;C2/44B2: 69 10        ADC #$10		
	TAY 										;C2/44B4: A8           TAY 		
	INC $10			;character counter					;C2/44B5: E6 10        INC $10		
	LDA $10										;C2/44B7: A5 10        LDA $10
	CMP #$04		;4 characters						;C2/44B9: C9 04        CMP #$04		
	BNE .AllSetupCmds								;C2/44BB: D0 AD        BNE $446A	
	
	TDC 										;C2/44BD: 7B           TDC 		
	TAX 										;C2/44BE: AA           TAX 		
	TAY 										;C2/44BF: A8           TAY 		
	STY $0E										;C2/44C0: 84 0E        STY $0E		
	STY $10			;character counter					;C2/44C2: 84 10        STY $10
	
.AllSetupHandItems
	STZ $11			;hand counter						;C2/44C4: 64 11        STZ $11		
	LDX $0E			;charstruct offset					;C2/44C6: A6 0E        LDX $0E

.SetupHandItems													
	PHX 										;C2/44C8: DA           PHX 		
	LDA CharStruct.RHWeapon,X							;C2/44C9: BD 13 20     LDA $2013,X	
	BNE +										;C2/44CC: D0 03        BNE $44D1	
	LDA CharStruct.RHShield,X							;C2/44CE: BD 11 20     LDA $2011,X	
+	CMP #$01									;C2/44D1: C9 01        CMP #$01		
	BNE +										;C2/44D3: D0 01        BNE $44D6	
	TDC 			;item 1 -> 0						;C2/44D5: 7B           TDC 		
+	STA HandItems.ID,Y								;C2/44D6: 99 AC 37     STA $37AC,Y	
	PHA 										;C2/44D9: 48           PHA 		
	CMP #$80									;C2/44DA: C9 80        CMP #$80		
	BCC .Weapon									;C2/44DC: 90 1D        BCC $44FB	
	SEC 										;C2/44DE: 38           SEC 		
	SBC #$80		;remove armor offset					;C2/44DF: E9 80        SBC #$80		
	REP #$20									;C2/44E1: C2 20        REP #$20		
	JSR ShiftMultiply_4								;C2/44E3: 20 B7 01     JSR $01B7	
	STA $12										;C2/44E6: 85 12        STA $12		
	ASL 										;C2/44E8: 0A           ASL 		
	CLC 										;C2/44E9: 18           CLC 
	ADC $12										;C2/44EA: 65 12        ADC $12		
	TAX 			;Armor ID *12						;C2/44EC: AA           TAX 		
	TDC 										;C2/44ED: 7B           TDC 		
	SEP #$20									;C2/44EE: E2 20        SEP #$20		
	LDA #$5A									;C2/44F0: A9 5A        LDA #$5A		
	STA HandItems.Flags,Y								;C2/44F2: 99 B4 37     STA $37B4,Y	
	LDA !ROMArmor.EquipmentType,X							;C2/44F5: BF 02 06 D1  LDA $D10602,X	
	BRA .SetHandUsable								;C2/44F9: 80 32        BRA $452D		

.Weapon
	REP #$20									;C2/44FB: C2 20        REP #$20		
	JSR ShiftMultiply_4        							;C2/44FD: 20 B7 01     JSR $01B7    
	STA $12          								;C2/4500: 85 12        STA $12      
	ASL              								;C2/4502: 0A           ASL          
	CLC              								;C2/4503: 18           CLC          
	ADC $12          								;C2/4504: 65 12        ADC $12      
	TAX              	;Weapon ID *12						;C2/4506: AA           TAX          
	TDC              								;C2/4507: 7B           TDC          
	SEP #$20         								;C2/4508: E2 20        SEP #$20     
	LDA !ROMWeapons.Targetting,X							;C2/450A: BF 00 00 D1  LDA $D10000,X
	STA HandItems.Targetting,Y							;C2/450E: 99 B2 37     STA $37B2,Y
	LDA !ROMWeapons.DoubleGrip,X							;C2/4511: BF 04 00 D1  LDA $D10004,X
	AND #$80		;double grip bit					;C2/4515: 29 80        AND #$80		
	JSR ShiftDivide_32	;shift to 3rd bit					;C2/4517: 20 BD 01     JSR $01BD	
	STA HandItems.Flags,Y								;C2/451A: 99 B4 37     STA $37B4,Y
	LDA !ROMWeapons.EquipmentType,X							;C2/451D: BF 02 00 D1  LDA $D10002,X
	PHA 										;C2/4521: 48           PHA 		
	AND #$C0			;usable? and throwable				;C2/4522: 29 C0        AND #$C0		
	ORA #$1A			;set some more bits ?				;C2/4524: 09 1A        ORA #$1A		
	ORA HandItems.Flags,Y	;double grip bit from before				;C2/4526: 19 B4 37     ORA $37B4,Y
	STA HandItems.Flags,Y								;C2/4529: 99 B4 37     STA $37B4,Y
	PLA 			;equipment type						;C2/452C: 68           PLA 		
	
.SetHandUsable
	JSR GetItemUsableA								;C2/452D: 20 5E 45     JSR $455E	
	STA HandItems.Usable,Y								;C2/4530: 99 B6 37     STA $37B6,Y
	PLA 			;current hand's item id					;C2/4533: 68           PLA 		
	BEQ .NextHand									;C2/4534: F0 05        BEQ $453B	
	TDC 										;C2/4536: 7B           TDC 		
	INC 										;C2/4537: 1A           INC 		
	STA HandItems.Level,Y								;C2/4538: 99 AE 37     STA $37AE,Y

.NextHand
	PLX 										;C2/453B: FA           PLX 		
	INY 			;structure offsets increase to left hand		;C2/453C: C8           INY 
	INX 										;C2/453D: E8           INX 
	INC $11			;hand counter						;C2/453E: E6 11        INC $11
	LDA $11										;C2/4540: A5 11        LDA $11
	CMP #$02		;2 hands to process					;C2/4542: C9 02        CMP #$02
	BNE .SetupHandItems								;C2/4544: D0 82        BNE $44C8
											;.					
	LDX $0E			;charstruct offset					;C2/4546: A6 0E        LDX $0E		
	JSR NextCharOffset								;C2/4548: 20 E0 01     JSR $01E0	
	STX $0E										;C2/454B: 86 0E        STX $0E		
	TYA 										;C2/454D: 98           TYA 
	CLC 										;C2/454E: 18           CLC 
	ADC #$0A		;next HandItems character				;C2/454F: 69 0A        ADC #$0A
	TAY 										;C2/4551: A8           TAY 
	INC $10			;character counter					;C2/4552: E6 10        INC $10
	LDA $10										;C2/4554: A5 10        LDA $10
	CMP #$04		;4 characters						;C2/4556: C9 04        CMP #$04
	BEQ .Ret									;C2/4558: F0 03        BEQ $455D
	JMP .AllSetupHandItems								;C2/455A: 4C C4 44     JMP $44C4	
	
.Ret	RTS 										;C2/455D: 60           RTS 

endif