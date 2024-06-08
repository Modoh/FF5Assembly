if !_Optimize

;Command $15 (Animals)
;**optimize: rewrite to remove repeated BRA's 
CommandTable14:
	TDC 								;C2/0BBF: 7B           TDC 
	TAX 								;C2/0BC0: AA           TAX 
	LDA Level   							;C2/0BC1: AD E5 7B     LDA $7BE5      
	JSR Random_X_A		;0..Level				;C2/0BC4: 20 7C 00     JSR $007C      
	BEQ .Chosen		;0 rabbit 				;C2/0BC7: D0 03        BNE $0BCC
	LDX #$0008                           				;C2/0BC9: 7B           TDC 
	CMP #$3C                                			;C2/0BCA: 80 3A        BRA $0C06
	BCS .8                  ;>=60 unicorn          			;C2/0BCC: C9 05        CMP #$05
	CMP #$32                                			;C2/0BCE: B0 04        BCS $0BD4
	BCS .7                  ;>=50 boar             			;C2/0BD0: A9 01        LDA #$01
	CMP #$28                                			;C2/0BD2: 80 32        BRA $0C06
	BCS .6                  ;>=40 skunk            			;C2/0BD4: C9 0A        CMP #$0A
	CMP #$1E                                			;C2/0BD6: B0 04        BCS $0BDC
	BCS .5                  ;>=30 falcon          			;C2/0BD8: A9 02        LDA #$02
	CMP #$14                                			;C2/0BDA: 80 2A        BRA $0C06
	BCS .4                  ;>=20 momonga      			;C2/0BDC: C9 14        CMP #$14
	CMP #$0A                                			;C2/0BDE: B0 04        BCS $0BE4
	BCS .3                  ;>=10 nightingale      			;C2/0BE0: A9 03        LDA #$03
	CMP #$05                                			;C2/0BE2: 80 22        BRA $0C06
	BCS .2                  ;>=5 bees             			;C2/0BE4: C9 1E        CMP #$1E
.1	DEX                     ;<5 squirrel           			;C2/0BE6: B0 04        BCS $0BEC
.2	DEX                                     			;C2/0BE8: A9 04        LDA #$04
.3	DEX                                     			;C2/0BEA: 80 1A        BRA $0C06
.4	DEX                                     			;C2/0BEC: C9 28        CMP #$28
.5	DEX                                     			;C2/0BEE: B0 04        BCS $0BF4
.6	DEX                                     			;C2/0BF0: A9 05        LDA #$05
.7	DEX                                     			;C2/0BF2: 80 12        BRA $0C06
.8	TXA                                     			;C2/0BF4: C9 32        CMP #$32       
									;C2/0BF6: B0 04        BCS $0BFC
									;C2/0BF8: A9 06        LDA #$06
									;C2/0BFA: 80 0A        BRA $0C06
									;C2/0BFC: C9 3C        CMP #$3C
									;C2/0BFE: B0 04        BCS $0C04
									;C2/0C00: A9 07        LDA #$07
									;C2/0C02: 80 02        BRA $0C06
									;C2/0C04: A9 08        LDA #$08
.Chosen
	STA TempSpell    						;C2/0C06: 8D 22 27     STA $2722      
	REP #$20							;C2/0C09: C2 20        REP #$20
	JSR ShiftMultiply_8						;C2/0C0B: 20 B6 01     JSR $01B6      
	TAX 								;C2/0C0E: AA           TAX 
	TDC 								;C2/0C0F: 7B           TDC 
	SEP #$20							;C2/0C10: E2 20        SEP #$20
	TDC 								;C2/0C12: 7B           TDC 
	TAY 								;C2/0C13: A8           TAY 
-	LDA !ROMEffectInfo,X						;C2/0C14: BF B1 6A D1  LDA $D16AB1,X
	STA Temp,Y							;C2/0C18: 99 20 26     STA $2620,Y
	INX 								;C2/0C1B: E8           INX 
	INY 								;C2/0C1C: C8           INY 
	CPY #$0008	;copy 8 bytes magic info			;C2/0C1D: C0 08 00     CPY #$0008
	BNE -								;C2/0C20: D0 F2        BNE $0C14
	STZ PartyTargets						;C2/0C22: 64 66        STZ $66
	STZ MonsterTargets						;C2/0C24: 64 65        STZ $65
	LDA Temp	;targetting byte in magic info			;C2/0C26: AD 20 26     LDA $2620
	BNE .Targetting							;C2/0C29: D0 0B        BNE $0C36
	LDA AttackerIndex 						;C2/0C2B: A5 47        LDA $47        
	TAX 								;C2/0C2D: AA           TAX 
	TDC 								;C2/0C2E: 7B           TDC 
	JSR SetBit_X    						;C2/0C2F: 20 D6 01     JSR $01D6      
	STA PartyTargets	;default to targetting self		;C2/0C32: 85 66        STA $66
	BRA .TargetSet							;C2/0C34: 80 25        BRA $0C5B
.Targetting
	AND #$08		;target enemy				;C2/0C36: 29 08        AND #$08
	BNE .TargetEnemy						;C2/0C38: D0 06        BNE $0C40
	LDA #$F0							;C2/0C3A: A9 F0        LDA #$F0
	STA PartyTargets	;entire party				;C2/0C3C: 85 66        STA $66
	BRA .TargetSet							;C2/0C3E: 80 1B        BRA $0C5B
.TargetEnemy
	LDA Temp							;C2/0C40: AD 20 26     LDA $2620
	AND #$40		;hits all targets			;C2/0C43: 29 40        AND #$40
	BNE .TargetAll							;C2/0C45: D0 10        BNE $0C57
	TDC 								;C2/0C47: 7B           TDC 
	TAX 								;C2/0C48: AA           TAX 
	LDA #$07							;C2/0C49: A9 07        LDA #$07
	JSR Random_X_A    	;0..7 random monster			;C2/0C4B: 20 7C 00     JSR $007C      
	TAX 								;C2/0C4E: AA           TAX 
	TDC 								;C2/0C4F: 7B           TDC 
	JSR SetBit_X    						;C2/0C50: 20 D6 01     JSR $01D6      
	STA MonsterTargets						;C2/0C53: 85 65        STA $65
	BRA .TargetSet							;C2/0C55: 80 04        BRA $0C5B
.TargetAll
	LDA #$FF							;C2/0C57: A9 FF        LDA #$FF
	STA MonsterTargets						;C2/0C59: 85 65        STA $65
.TargetSet
	STZ TempAttachedSpell	;CastSpell routine params		;C2/0C5B: 64 20        STZ $20
	STZ TempSkipNaming						;C2/0C5D: 64 21        STZ $21
	LDA #$01		;animals are effect magic		;C2/0C5F: A9 01        LDA #$01
	STA TempIsEffect						;C2/0C61: 8D 23 27     STA $2723
	JMP CastSpell							;C2/0C64: 4C E1 5C     JMP $5CE1
	
	
if false
;Command $15 (Animals)
;**optimize: rewrite to remove repeated BRA's 
;smaller but unusual version using snes divide hardware
;doesn't save enough space to be worth the complexity and testing, but fun
CommandTable14Alt:
	TDC 					           		
	TAX 					           		
	LDA Level   				           		
	JSR Random_X_A		;0..Level	           		
	TAX								
	REP #$20
	STA $004204		;snes hardware division			
	LDA #$0500		;writes 5 to divisor, triggers divide start (does this work?)
	STA $004205		;16 cycle wait for result  		
	TXA			;2			           		
	SEP #$20		;3	;high byte of level is 0 so we don't need to clear A before					
	BEQ .Chosen		;2	;check for rabbit while waiting	
	CMP #$05		;2	;and squirrel         		
	TDC			;2                         		
	BCC .Squirrel		;2                         		
	LDA $004214		;4 before reading, result is ready	
	LSR                     ;		              		
	INC								
.Squirrel
	INC                     ;(0..level)/5/2 +2 fits middle animals	
	CMP #$09                                           		
	BCC .Chosen                                        		
	LDA #$08                ;Unicorn at 8 is the last animal	

.Chosen
	STA TempSpell    						;C2/0C06: 8D 22 27     STA $2722
	REP #$20							;C2/0C09: C2 20        REP #$20
	JSR ShiftMultiply_8						;C2/0C0B: 20 B6 01     JSR $01B6
	TAX 								;C2/0C0E: AA           TAX 
	TDC 								;C2/0C0F: 7B           TDC 
	SEP #$20							;C2/0C10: E2 20        SEP #$20
	TDC 								;C2/0C12: 7B           TDC 
	TAY 								;C2/0C13: A8           TAY 
-	LDA !ROMEffectInfo,X						;C2/0C14: BF B1 6A D1  LDA $D16A
	STA Temp,Y							;C2/0C18: 99 20 26     STA $2620
	INX 								;C2/0C1B: E8           INX 
	INY 								;C2/0C1C: C8           INY 
	CPY #$0008	;copy 8 bytes magic info			;C2/0C1D: C0 08 00     CPY #$000
	BNE -								;C2/0C20: D0 F2        BNE $0C14
	STZ PartyTargets						;C2/0C22: 64 66        STZ $66
	STZ MonsterTargets						;C2/0C24: 64 65        STZ $65
	LDA Temp	;targetting byte in magic info			;C2/0C26: AD 20 26     LDA $2620
	BNE .Targetting							;C2/0C29: D0 0B        BNE $0C36
	LDA AttackerIndex 						;C2/0C2B: A5 47        LDA $47  
	TAX 								;C2/0C2D: AA           TAX 
	TDC 								;C2/0C2E: 7B           TDC 
	JSR SetBit_X    						;C2/0C2F: 20 D6 01     JSR $01D6
	STA PartyTargets	;default to targetting self		;C2/0C32: 85 66        STA $66
	BRA .TargetSet							;C2/0C34: 80 25        BRA $0C5B
.Targetting
	AND #$08		;target enemy				;C2/0C36: 29 08        AND #$08
	BNE .TargetEnemy						;C2/0C38: D0 06        BNE $0C40
	LDA #$F0							;C2/0C3A: A9 F0        LDA #$F0
	STA PartyTargets	;entire party				;C2/0C3C: 85 66        STA $66
	BRA .TargetSet							;C2/0C3E: 80 1B        BRA $0C5B
.TargetEnemy
	LDA Temp							;C2/0C40: AD 20 26     LDA $2620
	AND #$40		;hits all targets			;C2/0C43: 29 40        AND #$40
	BNE .TargetAll							;C2/0C45: D0 10        BNE $0C57
	TDC 								;C2/0C47: 7B           TDC 
	TAX 								;C2/0C48: AA           TAX 
	LDA #$07							;C2/0C49: A9 07        LDA #$07
	JSR Random_X_A    	;0..7 random monster			;C2/0C4B: 20 7C 00     JSR $007C
	TAX 								;C2/0C4E: AA           TAX 
	TDC 								;C2/0C4F: 7B           TDC 
	JSR SetBit_X    						;C2/0C50: 20 D6 01     JSR $01D6
	STA MonsterTargets						;C2/0C53: 85 65        STA $65
	BRA .TargetSet							;C2/0C55: 80 04        BRA $0C5B
.TargetAll
	LDA #$FF							;C2/0C57: A9 FF        LDA #$FF
	STA MonsterTargets						;C2/0C59: 85 65        STA $65
.TargetSet
	STZ TempAttachedSpell	;CastSpell routine params		;C2/0C5B: 64 20        STZ $20
	STZ TempSkipNaming						;C2/0C5D: 64 21        STZ $21
	LDA #$01		;animals are effect magic		;C2/0C5F: A9 01        LDA #$01
	STA TempIsEffect						;C2/0C61: 8D 23 27     STA $2723
	JMP CastSpell							;C2/0C64: 4C E1 5C     JMP $5CE1

endif


endif