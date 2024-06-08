if !_Optimize

;optimizations: save some bytes when copying BattleData back to FieldData

EndBattle:
	JSR WipeDisplayStructures						;C2/5070: 20 18 02     JSR $0218      
	LDX #$0007		;clear 8 bytes					;C2/5073: A2 07 00     LDX #$0007
-	STZ FieldItemsWon,X							;C2/5076: 9E 3B 01     STZ $013B,X
	STZ BattleItemsWon,X							;C2/5079: 9E 66 7C     STZ $7C66,X
	DEX 									;C2/507C: CA           DEX 
	BPL -									;C2/507D: 10 F7        BPL $5076
	LDA ResetBattle								;C2/507F: AD D8 7C     LDA $7CD8
	BEQ .CheckDead								;C2/5082: F0 03        BEQ $5087
	JMP .Finish								;C2/5084: 4C 42 51     JMP $5142

.CheckDead
	LDA BattleOver								;C2/5087: AD DE 7B     LDA $7BDE
	AND #$40		;party dead					;C2/508A: 29 40        AND #$40
	BEQ .CheckEscaped							;C2/508C: F0 17        BEQ $50A5
	LDA #$01								;C2/508E: A9 01        LDA #$01
	JSR GFXCmdMessageClearAnim						;C2/5090: 20 47 58     JSR $5847
	LDA #$75    		;game over music				;C2/5093: A9 75        LDA #$75       
	JSR MusicChange								;C2/5095: 20 6E 00     JSR $006E      
	LDA #$01		;game over flag					;C2/5098: A9 01        LDA #$01
	STA BattleData.EventFlags						;C2/509A: 8D 84 7C     STA $7C84
	LDA #$2A		;message					;C2/509D: A9 2A        LDA #$2A
	STA MessageBoxes							;C2/509F: 8D 5F 3C     STA $3C5F
	JMP .MessageDisplay							;C2/50A2: 4C 17 51     JMP $5117

.CheckEscaped
	LDA BattleOver								;C2/50A5: AD DE 7B     LDA $7BDE
	AND #$01		;escaped					;C2/50A8: 29 01        AND #$01
	BEQ .CheckVictory  							;C2/50AA: F0 30        BEQ $50DC      
	LDA #$02		;escaped flag					;C2/50AC: A9 02        LDA #$02
	STA BattleData.EventFlags						;C2/50AE: 8D 84 7C     STA $7C84
	LDA #$80		;??						;C2/50B1: A9 80        LDA #$80
	STA ActionAnim.TargetBits						;C2/50B3: 8D CF 3B     STA $3BCF
	LDA #$0C		;C1 routine					;C2/50B6: A9 0C        LDA #$0C
	JSR CallC1   								;C2/50B8: 20 69 00     JSR $0069      
	JSR ResetStats								;C2/50BB: 20 5C 51     JSR $515C
	JSR ApplyPartyGear							;C2/50BE: 20 5E 9A     JSR $9A5E      
	JSR UpdateFieldData							;C2/50C1: 20 F4 51     JSR $51F4
	LDA #$2B		;message					;C2/50C4: A9 2B        LDA #$2B
	STA MessageBoxes							;C2/50C6: 8D 5F 3C     STA $3C5F
	TDC 									;C2/50C9: 7B           TDC 
	JSR GFXCmdMessageClearAnim						;C2/50CA: 20 47 58     JSR $5847
	CLC 									;C2/50CD: 18           CLC 
	LDA BattleData.Escapes							;C2/50CE: AD 75 7C     LDA $7C75      
	ADC #$01								;C2/50D1: 69 01        ADC #$01
	BCC +									;C2/50D3: 90 02        BCC $50D7
	LDA #$FF    		;255 cap					;C2/50D5: A9 FF        LDA #$FF       
+	STA BattleData.Escapes							;C2/50D7: 8D 75 7C     STA $7C75
	BRA .MessageDisplay							;C2/50DA: 80 3B        BRA $5117

.CheckVictory
	STZ BattleData.EventFlags	;victory				;C2/50DC: 9C 84 7C     STZ $7C84
	JSR ResetStats								;C2/50DF: 20 5C 51     JSR $515C
	LDA BattleOver								;C2/50E2: AD DE 7B     LDA $7BDE
	BPL .NoReward		;ended in a way other than enemies dying	;C2/50E5: 10 28        BPL $510F
	LDA EncounterInfo.Flags							;C2/50E7: AD FE 3E     LDA $3EFE
	AND #$02		;no reward flag					;C2/50EA: 29 02        AND #$02
	BNE .NoReward								;C2/50EC: D0 21        BNE $510F
	LDA EncounterInfo.Music							;C2/50EE: AD FD 3E     LDA $3EFD
	BMI +			;no track change				;C2/50F1: 30 05        BMI $50F8
	LDA #$70    		;victory music					;C2/50F3: A9 70        LDA #$70       
	JSR MusicChange   							;C2/50F5: 20 6E 00     JSR $006E      
+	LDA #$0D		;C1 routine					;C2/50F8: A9 0D        LDA #$0D
	JSR CallC1  								;C2/50FA: 20 69 00     JSR $0069      
	LDA #$01								;C2/50FD: A9 01        LDA #$01
	JSR GFXCmdMessageClearAnim						;C2/50FF: 20 47 58     JSR $5847
	LDA #$29		;message					;C2/5102: A9 29        LDA #$29
	STA MessageBoxes							;C2/5104: 8D 5F 3C     STA $3C5F
	LDA #$0A		;C1 routine: execute graphics script		;C2/5107: A9 0A        LDA #$0A
	JSR CallC1   								;C2/5109: 20 69 00     JSR $0069      
	JSR GetLootExp								;C2/510C: 20 A2 52     JSR $52A2
.NoReward
	JSR ApplyPartyGear   							;C2/510F: 20 5E 9A     JSR $9A5E      
	JSR UpdateFieldData							;C2/5112: 20 F4 51     JSR $51F4
	BRA .CleanupItems							;C2/5115: 80 05        BRA $511C

.MessageDisplay			;maybe also item drop window?
	LDA #$0A		;C1 routine: execute graphics script		;C2/5117: A9 0A        LDA #$0A
	JSR CallC1    								;C2/5119: 20 69 00     JSR $0069      

.CleanupItems
	JSL CleanupFieldItems_D0						;C2/511C: 22 78 EF D0  JSL $D0EF78    
	JSR MergeItemDupes							;C2/5120: 20 C2 51     JSR $51C2

;copy battle data
	LDX #!BattleData							;C2/5123: 7B           TDC 
	LDY #!FieldData								;C2/5124: AA           TAX 
	LDA #$1F		;copy 32 bytes
	MVN #$7E,#$7E
	
	REP #$20
	LDA BattleTimer
	STA FieldTimer
	TDC
	SEP #$20
	
	LDA #$0E		;C1 routine					;C2/513D: A9 0E        LDA #$0E
	JSR CallC1   								;C2/513F: 20 69 00     JSR $0069       

.Finish
	TDC 									;C2/5142: 7B           TDC 
	TAX 									;C2/5143: AA           TAX 
-	ORA BattleItemsWon,X							;C2/5144: 1D 66 7C     ORA $7C66,X
	INX 									;C2/5147: E8           INX 
	CPX #$0008								;C2/5148: E0 08 00     CPX #$0008
	BNE -									;C2/514B: D0 F7        BNE $5144
	PHA 		;non-zero A means there was an item drop		;C2/514D: 48           PHA 
	PLA 									;C2/514E: 68           PLA 
	BNE .Ret								;C2/514F: D0 0A        BNE $515B
	LDA EncounterInfo.Music							;C2/5151: AD FD 3E     LDA $3EFD
	BMI .Ret	;no track change					;C2/5154: 30 05        BMI $515B
	LDA #$7F    								;C2/5156: A9 7F        LDA #$7F        
	JSR MusicChange								;C2/5158: 20 6E 00     JSR $006E       
.Ret	RTS 									;C2/515B: 60           RTS 

endif