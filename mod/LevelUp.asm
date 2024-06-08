if !_Fixes

;**fix: updates stored max hp that's restored if giant drink was used

;Applies HP/MP and other changes for a character level up
LevelUp:
	LDX $10		;old level*2					;C2/56EC: A6 10        LDX $10
	LDA ROMLevelHP,X						;C2/56EE: BF 29 51 D1  LDA $D15129,X
	STA $0E								;C2/56F2: 85 0E        STA $0E
	STA $2A								;C2/56F4: 85 2A        STA $2A
	LDA ROMLevelHP+1,X						;C2/56F6: BF 2A 51 D1  LDA $D1512A,X
	STA $0F								;C2/56FA: 85 0F        STA $0F
	STA $2B								;C2/56FC: 85 2B        STA $2B
	LDX $3F		;char offset					;C2/56FE: A6 3F        LDX $3F
	LDA CharStruct.BaseVit,X					;C2/5700: BD 26 20     LDA $2026,X
	TAX 								;C2/5703: AA           TAX 
	STX $2C								;C2/5704: 86 2C        STX $2C
	JSR Multiply_16bit	;Rom HP * Vit				;C2/5706: 20 D2 00     JSR $00D2       
	LDX #$0005							;C2/5709: A2 05 00     LDX #$0005
-	;loop divides by 32
	LSR $31								;C2/570C: 46 31        LSR $31
	ROR $30								;C2/570E: 66 30        ROR $30
	ROR $2F								;C2/5710: 66 2F        ROR $2F
	ROR $2E								;C2/5712: 66 2E        ROR $2E
	DEX 								;C2/5714: CA           DEX 
	BNE -								;C2/5715: D0 F5        BNE $570C

	LDX $3F		;char offset					;C2/5717: A6 3F        LDX $3F
	REP #$20							;C2/5719: C2 20        REP #$20
	CLC 								;C2/571B: 18           CLC 
	LDA $0E		;rom hp						;C2/571C: A5 0E        LDA $0E
	ADC $2E		;+ (rom hp * vit)/32				;C2/571E: 65 2E        ADC $2E
	CMP #$270F							;C2/5720: C9 0F 27     CMP #$270F
	BCC +								;C2/5723: 90 03        BCC $5728
	LDA #$270F	;max 9999					;C2/5725: A9 0F 27     LDA #$270F
+	STA $08								;C2/5728: 85 08        STA $08
	LDA #$270F							;C2/572A: A9 0F 27     LDA #$270F
	STA $0A		;save 9999 cap for later routine		;C2/572D: 85 0A        STA $0A
	TDC 								;C2/572F: 7B           TDC 
	SEP #$20							;C2/5730: E2 20        SEP #$20
	TDC 								;C2/5732: 7B           TDC 
	TAY 								;C2/5733: A8           TAY 

.CheckHPCommands	;looks for HP up passives in command slots
	LDA CharStruct.BattleCommands,X					;C2/5734: BD 16 20     LDA $2016,X
	CMP #$8E	;after HP +30%					;C2/5737: C9 8E        CMP #$8E
	BCS .NextHPCommandCheck						;C2/5739: B0 0F        BCS $574A
	CMP #$8B	;HP +10%					;C2/573B: C9 8B        CMP #$8B
	BCC .NextHPCommandCheck						;C2/573D: 90 0B        BCC $574A
	PHX 								;C2/573F: DA           PHX 
	LDX $10		;old level*2					;C2/5740: A6 10        LDX $10
	PHX 								;C2/5742: DA           PHX 
	JSR ApplyHPMPPassives						;C2/5743: 20 C7 57     JSR $57C7
	PLX 								;C2/5746: FA           PLX 
	STX $10								;C2/5747: 86 10        STX $10
	PLX 								;C2/5749: FA           PLX 

.NextHPCommandCheck
	INX 								;C2/574A: E8           INX 
	INY 								;C2/574B: C8           INY 
	CPY #$0004							;C2/574C: C0 04 00     CPY #$0004
	BNE .CheckHPCommands						;C2/574F: D0 E3        BNE $5734

	LDX $3F		;char offset					;C2/5751: A6 3F        LDX $3F

if !_Fixes		;**fixed bug: updates max hp without updating the value saved if giant drink was used
	REP #$20
	LDA $3D		;char index
	ASL
	TAY
	LDA $08		;new hp
	STA CharStruct.MaxHP,X
	STA OriginalMaxHP,Y	;used to restore max hp value later if giant drink was used
	
	;Max MP
	;this part not strictly needed for the fix
	;but saves space by staying in 16 bit mode since we're already there
	LDX $10		;old level*2
	LDA ROMLevelMP,X	
	STA $0E
	STA $2A
	TDC
	SEP #$20
else	
	LDA $08		;new hp						;C2/5753: A5 08        LDA $08
	STA CharStruct.MaxHP,X						;C2/5755: 9D 08 20     STA $2008,X
	LDA $09								;C2/5758: A5 09        LDA $09
	STA CharStruct.MaxHP+1,X					;C2/575A: 9D 09 20     STA $2009,X

	;Max MP
	LDX $10		;old level*2					;C2/575D: A6 10        LDX $10
	LDA ROMLevelMP,X						;C2/575F: BF EF 51 D1  LDA $D151EF,X
	STA $0E								;C2/5763: 85 0E        STA $0E
	STA $2A								;C2/5765: 85 2A        STA $2A
	LDA ROMLevelMP+1,X						;C2/5767: BF F0 51 D1  LDA $D151F0,X
	STA $0F								;C2/576B: 85 0F        STA $0F
	STA $2B								;C2/576D: 85 2B        STA $2B
endif

	LDX $3F		;char offset					;C2/576F: A6 3F        LDX $3F
	LDA CharStruct.BaseMag,X					;C2/5771: BD 27 20     LDA $2027,X
	TAX 								;C2/5774: AA           TAX 
	STX $2C								;C2/5775: 86 2C        STX $2C
	JSR Multiply_16bit	;Rom MP * Mag				;C2/5777: 20 D2 00     JSR $00D2    
	LDX #$0005							;C2/577A: A2 05 00     LDX #$0005
-	;loop divides by 32
	LSR $31								;C2/577D: 46 31        LSR $31
	ROR $30								;C2/577F: 66 30        ROR $30
	ROR $2F								;C2/5781: 66 2F        ROR $2F
	ROR $2E								;C2/5783: 66 2E        ROR $2E
	DEX 								;C2/5785: CA           DEX 
	BNE -								;C2/5786: D0 F5        BNE $577D

	LDX $3F		;char offset					;C2/5788: A6 3F        LDX $3F
	REP #$20							;C2/578A: C2 20        REP #$20
	CLC 								;C2/578C: 18           CLC 
	LDA $0E		;rom mp						;C2/578D: A5 0E        LDA $0E
	ADC $2E		;+ (rom mp * mag)/32				;C2/578F: 65 2E        ADC $2E
	CMP #$03E7	;cap at 999					;C2/5791: C9 E7 03     CMP #$03E7
	BCC +								;C2/5794: 90 03        BCC $5799
	LDA #$03E7							;C2/5796: A9 E7 03     LDA #$03E7
+	STA $08								;C2/5799: 85 08        STA $08
	LDA #$03E7							;C2/579B: A9 E7 03     LDA #$03E7
	STA $0A		;save 999 cap for later routine			;C2/579E: 85 0A        STA $0A
	TDC 								;C2/57A0: 7B           TDC 
	SEP #$20							;C2/57A1: E2 20        SEP #$20
	TDC 								;C2/57A3: 7B           TDC 
	TAY 								;C2/57A4: A8           TAY 

.CheckMPCommands	
	LDA CharStruct.BattleCommands,X					;C2/57A5: BD 16 20     LDA $2016,X
	CMP #$90	;after mp +30%					;C2/57A8: C9 90        CMP #$90
	BCS .NextMPCommandCheck						;C2/57AA: B0 07        BCS $57B3
	CMP #$8E	;mp +10%					;C2/57AC: C9 8E        CMP #$8E
	BCC .NextMPCommandCheck						;C2/57AE: 90 03        BCC $57B3
	JSR ApplyHPMPPassives						;C2/57B0: 20 C7 57     JSR $57C7
.NextMPCommandCheck
	INX 								;C2/57B3: E8           INX 
	INY 								;C2/57B4: C8           INY 
	CPY #$0004							;C2/57B5: C0 04 00     CPY #$0004
	BNE .CheckMPCommands		 				;C2/57B8: D0 EB        BNE $57A5

	LDX $3F		;char offset					;C2/57BA: A6 3F        LDX $3F
	LDA $08		;new mp						;C2/57BC: A5 08        LDA $08
	STA CharStruct.MaxMP,X						;C2/57BE: 9D 0C 20     STA $200C,X
	LDA $09								;C2/57C1: A5 09        LDA $09
	STA CharStruct.MaxMP+1,X					;C2/57C3: 9D 0D 20     STA $200D,X
	RTS 								;C2/57C6: 60           RTS 

endif