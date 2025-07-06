if !_Fixes
;fixes: prevent softlock with 4 berserkers attempting to flee via chicken knife

;checks if the battle ended via timer, death, victory, or escape
%subdef(CheckBattleEnd)
	TDC 								;C2/5AB4: 7B           TDC 
	TAX 								;C2/5AB5: AA           TAX 
	TAY 								;C2/5AB6: A8           TAY 
	LDA BattleOver  	;check if it's already ending		;C2/5AB7: AD DE 7B     LDA $7BDE     
	BEQ .CheckTimer							;C2/5ABA: F0 01        BEQ $5ABD
	RTS								;C2/5ABC: 60           RTS

.CheckTimer								
	LDA BattleTimerEnable						;C2/5ABD: AD 94 7C     LDA $7C94
	CMP #$02							;C2/5AC0: C9 02        CMP #$02
	BNE .CheckParty							;C2/5AC2: D0 0E        BNE $5AD2
	LDA BattleTimer							;C2/5AC4: AD 95 7C     LDA $7C95
	ORA BattleTimer+1						;C2/5AC7: 0D 96 7C     ORA $7C96
	BNE .CheckParty							;C2/5ACA: D0 06        BNE $5AD2
	LDA #$20		;end via timer				;C2/5ACC: A9 20        LDA #$20
	STA BattleOver							;C2/5ACE: 8D DE 7B     STA $7BDE     
	RTS								;C2/5AD1: 60           RTS

.CheckParty									
	LDA ActiveParticipants,Y					;C2/5AD2: B9 C2 3E     LDA $3EC2,Y   
	BEQ .NextParty  						;C2/5AD5: F0 0A        BEQ $5AE1     
	LDA CharStruct.Status1,X					;C2/5AD7: BD 1A 20     LDA $201A,X   
	ORA CharStruct.AlwaysStatus1,X					;C2/5ADA: 1D 70 20     ORA $2070,X
	AND #$02	;zombies are active but don't count		;C2/5ADD: 29 02        AND #$02
	BEQ .CheckHideFlee  						;C2/5ADF: F0 0F        BEQ $5AF0     
.NextParty
	JSR NextCharOffset  						;C2/5AE1: 20 E0 01     JSR $01E0     
	INY 								;C2/5AE4: C8           INY 
	CPY #$0004							;C2/5AE5: C0 04 00     CPY #$0004
	BNE .CheckParty							;C2/5AE8: D0 E8        BNE $5AD2
	LDA #$40	;end via party ko				;C2/5AEA: A9 40        LDA #$40
	STA BattleOver	  						;C2/5AEC: 8D DE 7B     STA $7BDE     
	RTS								;C2/5AEF: 60           RTS

.CheckHideFlee		;X and Y start where they left off from the party checks
	LDA ActiveParticipants,Y					;C2/5AF0: B9 C2 3E     LDA $3EC2,Y   
	BEQ .NextHide							;C2/5AF3: F0 07        BEQ $5AFC
	LDA CharStruct.Status4,X					;C2/5AF5: BD 1D 20     LDA $201D,X   
	AND #$01	;hidden						;C2/5AF8: 29 01        AND #$01
	BEQ .CheckMonsters						;C2/5AFA: F0 0E        BEQ $5B0A     
.NextHide
	JSR NextCharOffset 						;C2/5AFC: 20 E0 01     JSR $01E0     
	INY 								;C2/5AFF: C8           INY 
	CPY #$0004							;C2/5B00: C0 04 00     CPY #$0004
	BNE .CheckHideFlee						;C2/5B03: D0 EB        BNE $5AF0
	LDA EncounterInfo.FleeChance					;C2/5B05: AD F0 3E     LDA $3EF0     
	BPL .FleeSuccess  ;80h = can't run				;C2/5B08: 10 58        BPL $5B62     

.CheckMonsters
	LDY #$0004 	;first monster index				;C2/5B0A: A0 04 00     LDY #$0004    
	LDX #$0200 	;first monster offset				;C2/5B0D: A2 00 02     LDX #$0200    
.MonsterLoop
	LDA ActiveParticipants,Y					;C2/5B10: B9 C2 3E     LDA $3EC2,Y   
	BEQ .NextMonster						;C2/5B13: F0 0A        BEQ $5B1F
	LDA CharStruct.Status1,X					;C2/5B15: BD 1A 20     LDA $201A,X   
	ORA CharStruct.AlwaysStatus1,X					;C2/5B18: 1D 70 20     ORA $2070,X
	AND #$02	;zombie monsters don't exist, but check anyway	;C2/5B1B: 29 02        AND #$02
	BEQ .CheckFlee  						;C2/5B1D: F0 0F        BEQ $5B2E     
.NextMonster
	JSR NextCharOffset 						;C2/5B1F: 20 E0 01     JSR $01E0     
	INY 								;C2/5B22: C8           INY 
	CPY #$000C	;12 slots					;C2/5B23: C0 0C 00     CPY #$000C
	BNE .MonsterLoop						;C2/5B26: D0 E8        BNE $5B10
	LDA #$80	;victory					;C2/5B28: A9 80        LDA #$80
	STA BattleOver  						;C2/5B2A: 8D DE 7B     STA $7BDE     
	RTS								;C2/5B2D: 60           RTS

.CheckFlee									
	LDA FleeSuccess		;bugfix: check FleeSuccess before checking FleeTickerActive
	BMI .FleeSuccess	;80h: exit cast				
	BEQ .ResetFleeTicker
	LDA FleeTickerActive						
	BEQ .ResetFleeTicker						
	LDA EncounterInfo.FleeChance					;C2/5B3A: AD F0 3E     LDA $3EF0
	BPL .AdvanceTicker 						;C2/5B3D: 10 11        BPL $5B50     
	JSR WipeDisplayStructures  					;C2/5B3F: 20 18 02     JSR $0218     
	TDC 								;C2/5B42: 7B           TDC 
	JSR GFXCmdMessageClearAnim					;C2/5B43: 20 47 58     JSR $5847
	LDA #$20   	;can't run message				;C2/5B46: A9 20        LDA #$20      
	STA MessageBoxes						;C2/5B48: 8D 5F 3C     STA $3C5F
	LDA #$0A	;C1 routine: execute graphics script		;C2/5B4B: A9 0A        LDA #$0A
	JMP CallC1							;C2/5B4D: 4C 69 00     JMP $0069     
.AdvanceTicker
	INC FleeTicker 							;C2/5B50: EE 5F 7C     INC $7C5F
	LDA FleeTicker 							;C2/5B53: AD 5F 7C     LDA $7C5F
	CMP #$14	;20 ticks before flee attempt			;C2/5B56: C9 14        CMP #$14
	BNE .Ret							;C2/5B58: D0 11        BNE $5B6B
	JSR Random_0_99  						;C2/5B5A: 20 A2 02     JSR $02A2     
	CMP EncounterInfo.FleeChance					;C2/5B5D: CD F0 3E     CMP $3EF0
	BCS .ResetFleeTicker						;C2/5B60: B0 06        BCS $5B68
.FleeSuccess
	LDA #$01	;escaped					;C2/5B62: A9 01        LDA #$01
	STA BattleOver							;C2/5B64: 8D DE 7B     STA $7BDE
	RTS 								;C2/5B67: 60           RTS 
.ResetFleeTicker
	STZ FleeTicker							;C2/5B68: 9C 5F 7C     STZ $7C5F
.Ret	RTS 								;C2/5B6B: 60           RTS 



endif