if !_Optimize


;Command $17 (X-Fight)
;**optimize: 	lots to trim in the targetting code
;		could also use BuildTargetBitmask instead of duplicating all its code here	
%subdef(CommandTable16)
	LDA #$17		;ability name				;C2/0C6F: A9 17        LDA #$17
	JSR GFXCmdAttackNameA						;C2/0C71: 20 FA 16     JSR $16FA
	STZ $22			;index for attack loop			;C2/0C74: 64 22        STZ $22
.AttackLoop
	TDC 								;C2/0C76: 7B           TDC 
	TAX 								;C2/0C77: AA           TAX 
	LDA #$07							;C2/0C78: A9 07        LDA #$07
	JSR Random_X_A 		;0..7 random monster			;C2/0C7A: 20 7C 00     JSR $007C      
	TAX 								;C2/0C7D: AA           TAX 
	TDC 								;C2/0C7E: 7B           TDC 
	JSR SetBit_X							;C2/0C7F: 20 D6 01     JSR $01D6      
	LDX AttackerOffset						;C2/0C82: A6 32        LDX $32        
	STA CharStruct.MonsterTargets,X					;C2/0C84: 9D 58 20     STA $2058,X
	STA MonsterTargets
	STZ CharStruct.PartyTargets,X					;*C2/0C87: 9E 59 20     STZ $2059,X
	;opt: removed duplicate loads					;*C2/0C8A: A6 32        LDX $32        
									;*C2/0C8C: BD 58 20     LDA $2058,X
									;*C2/0C8F: 85 65        STA $65
									;*C2/0C91: BD 59 20     LDA $2059,X
	STZ PartyTargets						;*C2/0C94: 85 66        STA $66
	JSR CheckRetarget						;C2/0C96: 20 FE 4A     JSR $4AFE      
	LDX AttackerOffset      					;C2/0C99: A6 32        LDX $32        
	LDA PartyTargets						;C2/0C9B: A5 66        LDA $66
	STA CharStruct.PartyTargets,X					;C2/0C9D: 9D 59 20     STA $2059,X
	LDA MonsterTargets						;C2/0CA0: A5 65        LDA $65
	STA CharStruct.MonsterTargets,X					;C2/0CA2: 9D 58 20     STA $2058,X
	JSR BuildTargetBitmask						;*C2/0CA5: 48           PHA 
	;opt: call routine instead of duplicating bitmask code		;*C2/0CA6: 29 F0        AND #$F0
									;*C2/0CA8: 4A           LSR 
									;*C2/0CA9: 4A           LSR 
									;*C2/0CAA: 4A           LSR 
									;*C2/0CAB: 4A           LSR 
									;*C2/0CAC: 1D 59 20     ORA $2059,X
									;*C2/0CAF: 8D 20 27     STA $2720
									;*C2/0CB2: 68           PLA 
									;*C2/0CB3: 29 0F        AND #$0F
									;*C2/0CB5: 0A           ASL 
									;*C2/0CB6: 0A           ASL 
									;*C2/0CB7: 0A           ASL 
									;*C2/0CB8: 0A           ASL 
									;*C2/0CB9: 8D 21 27     STA $2721
	LDA AttackerIndex						;C2/0CBC: A5 47        LDA $47        
	TAX 								;C2/0CBE: AA           TAX 
	LDA ROMTimes84,X	;combined size of gearstats structs	;C2/0CBF: BF 85 ED D0  LDA $D0ED85,X
	TAX 								;C2/0CC3: AA           TAX 
	STX $0E			;gearstats offset			;C2/0CC4: 86 0E        STX $0E
	LDX AttackerOffset						;C2/0CC6: A6 32        LDX $32        
	LDA CharStruct.RHWeapon,X					;C2/0CC8: BD 13 20     LDA $2013,X
	BEQ .LH								;*C2/0CCB: D0 03        BNE $0CD0
									;*C2/0CCD: 4C 2C 0D     JMP $0D2C

.RH	LDA RHWeapon.AtkType,X						;*C2/0CD0: 20 23 99     JSR $9923
	STA $11			;attack type				;*C2/0CD3: 84 14        STY $14
	LDY #!RHWeapon							;*C2/0CD5: 64 12        STZ $12
	STY $14			;weapon info pointer			;*C2/0CD7: A6 0E        LDX $0E
	STZ $16			;flag for hand anim			;*C2/0CD9: BD 85 40     LDA $4085,X    
	JSR SimpleOneHand						;*C2/0CDC: 99 FC 79     STA $79FC,Y
	;opt: call routine instead of duplicating code for hands	;*C2/0CDF: E8           INX 
									;*C2/0CE0: C8           INY 
									;*C2/0CE1: E6 12        INC $12
									;*C2/0CE3: A5 12        LDA $12
									;*C2/0CE5: C9 0C        CMP #$0C
									;*C2/0CE7: D0 F0        BNE $0CD9
									;*C2/0CE9: 20 FA 98     JSR $98FA      
									;*C2/0CEC: 9E 4C 38     STZ $384C,X
									;*C2/0CEF: A9 FC        LDA #$FC
									;*C2/0CF1: 9D 4D 38     STA $384D,X
									;*C2/0CF4: A9 01        LDA #$01
									;*C2/0CF6: 9D 4E 38     STA $384E,X
									;*C2/0CF9: A9 04        LDA #$04
									;*C2/0CFB: 9D 4F 38     STA $384F,X
									;*C2/0CFE: 9E 50 38     STZ $3850,X
									;*C2/0D01: A6 0E        LDX $0E
									;*C2/0D03: BD 8D 40     LDA $408D,X
									;*C2/0D06: 48           PHA 
									;*C2/0D07: AD FA 79     LDA $79FA
									;*C2/0D0A: AA           TAX 
									;*C2/0D0B: 68           PLA 
									;*C2/0D0C: 9D 2D 7B     STA $7B2D,X
									;*C2/0D0F: 9E 1C 7B     STZ $7B1C,X
									;*C2/0D12: 9E CC 7A     STZ $7ACC,X
									;*C2/0D15: AD FA 79     LDA $79FA
									;*C2/0D18: 0A           ASL 
									;*C2/0D19: AA           TAX 
									;*C2/0D1A: AD 20 27     LDA $2720
									;*C2/0D1D: 9D DC 7A     STA $7ADC,X
									;*C2/0D20: AD 21 27     LDA $2721
									;*C2/0D23: 9D DD 7A     STA $7ADD,X
									;*C2/0D26: EE FA 79     INC $79FA
									;*C2/0D29: 20 E3 98     JSR $98E3

.LH	LDX AttackerOffset						;C2/0D2C: A6 32        LDX $32        
	LDA CharStruct.LHWeapon,X					;C2/0D2E: BD 14 20     LDA $2014,X
	BEQ .Next							;*C2/0D31: D0 03        BNE $0D36
	LDA LHWeapon.AtkType,X						;*C2/0D33: 4C 96 0D     JMP $0D96
	STA $11			;attack type				;*C2/0D36: 20 23 99     JSR $9923
	LDY #!LHWeapon							;*C2/0D39: 84 12        STY $12
	STY $14			;weapon info pointer			;*C2/0D3B: 64 14        STZ $14
	LDA #$80							;*C2/0D3D: A6 0E        LDX $0E
	STA $16			;flag for hand anim			;*C2/0D3F: BD 91 40     LDA $4091,X    
	JSR SimpleOneHand						;*C2/0D42: 99 FC 79     STA $79FC,Y
	;opt: call routine instead of duplicating code for hands	;*C2/0D45: E8           INX 
									;*C2/0D46: C8           INY 
									;*C2/0D47: E6 14        INC $14
									;*C2/0D49: A5 14        LDA $14
									;*C2/0D4B: C9 0C        CMP #$0C
									;*C2/0D4D: D0 F0        BNE $0D3F
									;*C2/0D4F: A6 0E        LDX $0E
									;*C2/0D51: AD FA 79     LDA $79FA
									;*C2/0D54: A8           TAY 
									;*C2/0D55: BD 99 40     LDA $4099,X
									;*C2/0D58: 99 2D 7B     STA $7B2D,Y
									;*C2/0D5B: 20 FA 98     JSR $98FA      
									;*C2/0D5E: 9E 4C 38     STZ $384C,X
									;*C2/0D61: A9 FC        LDA #$FC
									;*C2/0D63: 9D 4D 38     STA $384D,X
									;*C2/0D66: A9 01        LDA #$01
									;*C2/0D68: 9D 4E 38     STA $384E,X
									;*C2/0D6B: A9 04        LDA #$04
									;*C2/0D6D: 9D 4F 38     STA $384F,X
									;*C2/0D70: A9 80        LDA #$80
									;*C2/0D72: 9D 50 38     STA $3850,X
									;*C2/0D75: AD FA 79     LDA $79FA
									;*C2/0D78: AA           TAX 
									;*C2/0D79: 9E 1C 7B     STZ $7B1C,X
									;*C2/0D7C: 9E CC 7A     STZ $7ACC,X
									;*C2/0D7F: AD FA 79     LDA $79FA
									;*C2/0D82: 0A           ASL 
									;*C2/0D83: AA           TAX 
									;*C2/0D84: AD 20 27     LDA $2720
									;*C2/0D87: 9D DC 7A     STA $7ADC,X
									;*C2/0D8A: AD 21 27     LDA $2721
									;*C2/0D8D: 9D DD 7A     STA $7ADD,X
									;*C2/0D90: EE FA 79     INC $79FA
									;*C2/0D93: 20 E3 98     JSR $98E3
.Next	INC $22			;attack loop index			;C2/0D96: E6 22        INC $22
	LDA $22								;C2/0D98: A5 22        LDA $22
	CMP #$04		;4 attacks				;C2/0D9A: C9 04        CMP #$04
	BEQ .Ret							;C2/0D9C: F0 03        BEQ $0DA1
	JMP .AttackLoop							;C2/0D9E: 4C 76 0C     JMP $0C76
.Ret	RTS 								;C2/0DA1: 60           RTS 


%subdef(SimpleOneHand)
;Process one hand's attacks (for simple no-proc attacks)
;Params
;$0E: char equipment offset
;$11: weapon attack type
;$14: Pointer to weapon info struct
;$16: 0 for rh, $80 for LH
	JSR SelectCurrentProcSequence	;sets Y to attackinfo offset			
        STZ $12
	TYX
        LDY $0E			;gearstats offset		
-       LDA ($14),Y						
        STA !AttackInfo,X					
        INX 							
        INY 							
        INC $12							
        LDA $12							
        CMP #$0C		;copy 12 bytes weapon data	
        BNE -							

        JSR GFXCmdAbilityAnim
        LDA $16
        STA GFXQueue.Data2,X	;hand for animation
        LDA ProcSequence					
        TAX 							
	ASL
	TAY
        LDA $11			;attack type
        STA AtkType,X						
        STZ MultiTarget,X					
        STZ TargetType,X					
        LDA TempTargetBitmask					
        STA CommandTargetBitmask,Y				
        LDA TempTargetBitmask+1					
        STA CommandTargetBitmask+1,Y				
        INC ProcSequence					
        JMP GFXCmdDamageNumbers


endif