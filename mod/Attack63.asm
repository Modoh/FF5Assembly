if !_Optimize

;Attack Type 63 (Grand Cross)
;optimizations:
;	pick status type first, then retry on bad outcomes
;		a bit ugly and executes slower, but saves space
;		confused casters in vanilla use this retry strategy to pick spells 
;		which could have a much higher chance of retrying, so this should be ok
;	111 bytes
%subdef(Attack63)
	LDX TargetOffset						;C2/76CE: A6 49        LDX $49
	LDA CharStruct.Status1,X					;C2/76D0: BD 1A 20     LDA $201A,X
	AND #$C2		;select for dead/stone/zombie		;C2/76D3: 29 C2        AND #$C2
	BEQ +	 							;C2/76D5: F0 01        BEQ $76D8    (Check if Target Status 1 = Dead, Stone or Zombie)
	RTS 								;C2/76D7: 60           RTS 
									;
+	INC								;C2/76D8: A9 01        LDA #$01
	STA StatusFixedDur						;C2/76DA: 8D D7 3E     STA $3ED7
	
.Retry	TDC 								;C2/76DD: 7B           TDC 
	TAX 								;C2/76DE: AA           TAX 
	LDA #$20								
	JSR Random_X_A 		;0..32
	;33 outcomes, 15 result in rerolls
	;remaining 18 outcomes are evenly distributed just like the original
	
	CMP #$20
	BCS .HPCritical
	CMP #$18
	BCS .Status4
	CMP #$10
	BCS .Status3
	CMP #$08
	AND #$07		;now 0..7 for Status 1 and 2 (doesn't change carry for branch)
	BCS .Status2
	
.Status1			
	CMP #$04		;float not allowed
	BEQ .Retry			
	TAX
	TDC
	JSR SetBit_X		
	STA Param3		;status to apply
	JSR ApplyStatus1
	BRA .Finish
	
.Status2			
	CMP #$06		;image statuses not allowed
	BCS .Retry			
	TAX
	TDC
	JSR SetBit_X		
	STA Param3		;status to apply
	JSR ApplyStatus2
	BRA .Finish

.Status3				
	AND #$03		;now 0..3
	BNE .Retry		;retry 3 of 4 status 3 rolls to preserve original status chances
	LDA #$04		;slow status
	STA Param3
	JSR ApplyStatus3
	BRA .Finish

.Status4			
	AND #$07		;now 0..7
	CMP #$02		
	BCS .Retry		;retry 3 of 4 status 4 rolls to preserve original status chances
	AND #$01		;now 0 or 1
	INC			;now 1 or 2
	ASL			
	ASL
	ASL
	STA Param3		;after shifts, is now $08 or $10, for Countdown or HP Leak
	JSR ApplyStatus4
	BRA .Finish

.HPCritical
	JSR SetHPCritical
	
.Finish	STZ AtkMissed							;C2/7771: 64 56        STZ $56
	RTS 								;C2/7773: 60           RTS 



;alternate option, disabled for now
if 0
;Attack Type 63 (Grand Cross)
;optimizations:
;	uses a jump table instead of chained branches
;	still feels like it could be better
;	132 bytes
%subdef(Attack63Alt)
	LDX !TargetOffset						;C2/76CE: A6 49        LDX $49
	LDA CharStruct.Status1,X					;C2/76D0: BD 1A 20     LDA $201A,X
	AND #$C2		;select for dead/stone/zombie		;C2/76D3: 29 C2        AND #$C2
	BEQ +	 							;C2/76D5: F0 01        BEQ $76D8    (Check if Target Status 1 = Dead, Stone or Zombie)
	RTS 								;C2/76D7: 60           RTS 
									;
+	INC								;C2/76D8: A9 01        LDA #$01
	STA StatusFixedDur						;C2/76DA: 8D D7 3E     STA $3ED7
	
	TDC 								;C2/76DD: 7B           TDC 
	TAX 								;C2/76DE: AA           TAX 
	LDA #$11		;17					;C2/76DF: A9 11        LDA #$11
	JSR Random_X_A 		;0..17					;C2/76E1: 20 7C 00     JSR $007C  (0..17)
	ASL			;adjust for the size of the		;1
	ASL			;.. status table entries                ;1
	REP #$20			                                ;2
	CLC			                                        ;1
	ADC #.StatusTable	;address of the status table		;3
	STA $0E			                                        ;2
	TDC
	SEP #$20			                                ;2
	JMP ($000E)			                                ;3

.StatusTable			;entries must be exactly 4 bytes long, except the last one
	LDA #$80		;0: Dead				;C2/76E6: A9 80        LDA #$80
	BRA .Status1							;C2/76E8: 80 28        BRA $7712
	LDA #$40		;1: Stone				;C2/76ED: A9 40        LDA #$40
	BRA .Status1							;C2/76EF: 80 21        BRA $7712
	LDA #$20		;2: Toad				;C2/76F4: A9 20        LDA #$20
	BRA .Status1							;C2/76F6: 80 1A        BRA $7712
	LDA #$10		;3: Mini				;C2/76FB: A9 10        LDA #$10
	BRA .Status1							;C2/76FD: 80 13        BRA $7712
	LDA #$04		;4: Poison				;C2/7702: A9 04        LDA #$04
	BRA .Status1							;C2/7704: 80 0C        BRA $7712
	LDA #$02		;5: Zombie				;C2/7709: A9 02        LDA #$02
	BRA .Status1							;C2/770B: 80 05        BRA $7712
	LDA #$01		;6: Blind				;C2/7710: A9 01        LDA #$01
	BRA .Status1                                                    ;2
	LDA #$80		;7: Old					;C2/771C: A9 80        LDA #$80
	BRA .Status2							;C2/771E: 80 21        BRA $7741
	LDA #$40		;8: Sleep				;C2/7723: A9 40        LDA #$40
	BRA .Status2							;C2/7725: 80 1A        BRA $7741
	LDA #$20		;9: Paralyze				;C2/772A: A9 20        LDA #$20
	BRA .Status2		 					;C2/772C: 80 13        BRA $7741
	LDA #$10		;10: Charm				;C2/7731: A9 10        LDA #$10
	BRA .Status2							;C2/7733: 80 0C        BRA $7741
	LDA #$08		;11: Berserk				;C2/7738: A9 08        LDA #$08
	BRA .Status2							;C2/773A: 80 05        BRA $7741
	LDA #$04		;12: Mute				;C2/773F: A9 04        LDA #$04
	BRA .Status2                                                    ;2
	LDA #$04		;13: Slow				;C2/774B: A9 04        LDA #$04
	BRA .Status3							;C2/774D: 80 05        BRA $7754
	LDA #$04		;14: Slow 				;C2/7752: A9 04        LDA #$04
	BRA .Status3                                                    ;2
	LDA #$10		;15: Countdown				;C2/775E: A9 10        LDA #$10
	BRA .Status4							;C2/7760: 80 05        BRA $7767
	LDA #$08		;16: HP Leak				;C2/7765: A9 08        LDA #$08
	BRA .Status4                                                    ;2
	JSR SetHPCritical	;17: HP Critical			;C2/776E: 20 FD 88     JSR $88FD  (Reduce HP to critical Damage)
	BRA .Finish                                                     ;2
.Status1
	STA Param3							;C2/7712: 85 59        STA $59
	JSR ApplyStatus1						;C2/7714: 20 AC 8C     JSR $8CAC  (Apply Status Effect 1)
	BRA .Finish							;C2/7717: 80 58        BRA $7771
.Status2
	STA Param3							;C2/7741: 85 59        STA $59
	JSR ApplyStatus2						;C2/7743: 20 2E 8D     JSR $8D2E  (Apply Status Effect 2)
	BRA .Finish							;C2/7746: 80 29        BRA $7771
.Status3
	STA Param3							;C2/7754: 85 59        STA $59
	JSR ApplyStatus3						;C2/7756: 20 CB 8D     JSR $8DCB  (Apply Status Effect 3)
	BRA .Finish							;C2/7759: 80 16        BRA $7771
.Status4
	STA Param3							;C2/7767: 85 59        STA $59
	JSR ApplyStatus4						;C2/7769: 20 05 8E     JSR $8E05  (Apply Status Effect 4)
.Finish	STZ AtkMissed							;C2/7771: 64 56        STZ $56
	RTS 								;C2/7773: 60           RTS 
endif

endif