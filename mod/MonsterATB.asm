if !_Fixes
;Fixes: applys haste/slow mod to monster attack delays

;Queues up a monster's action when their ATB is ready
%subdef(MonsterATB)
	LDA #$01							;C2/25D3: A9 01        LDA #$01
	STA AISkipDeadCheck						;C2/25D5: 8D 50 7C     STA $7C50
	SEC 								;C2/25D8: 38           SEC 
	LDA AttackerIndex						;C2/25D9: A5 47        LDA $47        
	SBC #$04							;C2/25DB: E9 04        SBC #$04
	STA MonsterIndex						;C2/25DD: 8D 03 7C     STA $7C03      
	JSR ShiftMultiply_16						;C2/25E0: 20 B5 01     JSR $01B5      
	TAX 								;C2/25E3: AA           TAX 
	STX MonsterOffset16      					;C2/25E4: 8E 5E 43     STX $435E      
	ASL 								;C2/25E7: 0A           ASL 
	TAX 								;C2/25E8: AA           TAX 
	STX MonsterOffset32     					;C2/25E9: 8E 60 43     STX $4360      
	TDC 								;C2/25EC: 7B           TDC 
	TAY            							;C2/25ED: A8           TAY            
	STY TempCharm  							;C2/25EE: 84 22        STY $22        
	LDX MonsterOffset16 						;C2/25F0: AE 5E 43     LDX $435E
	LDA #$FF							;C2/25F3: A9 FF        LDA #$FF
-	STA MonsterMagic,X 						;C2/25F5: 9D DE 41     STA $41DE,X    
	INX 								;C2/25F8: E8           INX 
	INY 								;C2/25F9: C8           INY 
	CPY #$0010	;init 16 byte monster magic struct		;C2/25FA: C0 10 00     CPY #$0010
	BNE -								;C2/25FD: D0 F6        BNE $25F5
								;
	LDA MonsterIndex      						;C2/25FF: AD 03 7C     LDA $7C03      
	ASL 								;C2/2602: 0A           ASL 
	TAX 								;C2/2603: AA           TAX 
	LDA ROMTimes100w,X  						;C2/2604: BF 95 EE D0  LDA $D0EE95,X  
	STA $0E								;C2/2608: 85 0E        STA $0E
	LDA ROMTimes100w+1,X						;C2/260A: BF 96 EE D0  LDA $D0EE96,X
	STA $0F								;C2/260E: 85 0F        STA $0F
	TDC 								;C2/2610: 7B           TDC 
	TAY 								;C2/2611: A8           TAY 
	LDX $0E		;MonsterIndex *100				;C2/2612: A6 0E        LDX $0E
	LDA #$FF							;C2/2614: A9 FF        LDA #$FF
-	STA !MonsterAIScript,X    					;C2/2616: 9D 67 43     STA $4367,X    
	INX 								;C2/2619: E8           INX 
	INY 								;C2/261A: C8           INY 
	CPY #$0064	;init 100 bytes to $FF				;C2/261B: C0 64 00     CPY #$0064
	BNE -								;C2/261E: D0 F6        BNE $2616
	LDA AttackerIndex						;C2/2620: A5 47        LDA $47        
	JSR CalculateCharOffset      					;C2/2622: 20 EC 01     JSR $01EC      
	LDX AttackerOffset						;C2/2625: A6 32        LDX $32        
	LDA #$2C       	;magic						;C2/2627: A9 2C        LDA #$2C       
	STA CharStruct.Command,X 					;C2/2629: 9D 57 20     STA $2057,X    
	LDA #$21	;magic + costs mp				;C2/262C: A9 21        LDA #$21
	STA CharStruct.ActionFlag,X					;C2/262E: 9D 56 20     STA $2056,X    
	LDX AttackerOffset						;C2/2631: A6 32        LDX $32        
	LDA CharStruct.Status2,X    					;C2/2633: BD 1B 20     LDA $201B,X    
	ORA CharStruct.AlwaysStatus2,X					;C2/2636: 1D 71 20     ORA $2071,X
	AND #$08	;berserk					;C2/2639: 29 08        AND #$08
	BEQ .CheckCharm							;C2/263B: F0 15        BEQ $2652      

	LDA #$01							;C2/263D: A9 01        LDA #$01
	STA CharStruct.CmdCancelled,X					;C2/263F: 9D 61 20     STA $2061,X
	LDA #$80	;monster fight					;C2/2642: A9 80        LDA #$80
	STA AIBuffer							;C2/2644: 8D 40 26     STA $2640
	LDA #$FF	;end of list					;C2/2647: A9 FF        LDA #$FF
	STA AIBuffer+1							;C2/2649: 8D 41 26     STA $2641
	JSR DispatchAICommands						;C2/264C: 20 10 32     JSR $3210
	JMP .GoFinish							;C2/264F: 4C EC 26     JMP $26EC

.CheckCharm
	LDA CharStruct.Status2,X					;C2/2652: BD 1B 20     LDA $201B,X
	ORA CharStruct.AlwaysStatus2,X					;C2/2655: 1D 71 20     ORA $2071,X
	AND #$10	;charm						;C2/2658: 29 10        AND #$10
	BEQ .CheckFlirt    						;C2/265A: F0 3C        BEQ $2698      
.TryRandomAction
	LDX AttackerOffset						;C2/265C: A6 32        LDX $32        
	LDA #$01							;C2/265E: A9 01        LDA #$01
	STA CharStruct.CmdCancelled,X					;C2/2660: 9D 61 20     STA $2061,X
	TDC 								;C2/2663: 7B           TDC 
	TAX 								;C2/2664: AA           TAX 
	LDA #$03							;C2/2665: A9 03        LDA #$03
	JSR Random_X_A 	;0..3						;C2/2667: 20 7C 00     JSR $007C      
	TAX 								;C2/266A: AA           TAX 
	STX $0E								;C2/266B: 86 0E        STX $0E
	LDA MonsterIndex      						;C2/266D: AD 03 7C     LDA $7C03      
	ASL 								;C2/2670: 0A           ASL 
	TAX 								;C2/2671: AA           TAX 
	REP #$20							;C2/2672: C2 20        REP #$20
	LDA BattleMonsterID,X						;C2/2674: BD 20 40     LDA $4020,X
	JSR ShiftMultiply_4      					;C2/2677: 20 B7 01     JSR $01B7      
	CLC 								;C2/267A: 18           CLC 
	ADC $0E		;random number 0..3				;C2/267B: 65 0E        ADC $0E
	TAX 		;offset into control actions table		;C2/267D: AA           TAX 
	TDC 								;C2/267E: 7B           TDC 
	SEP #$20							;C2/267F: E2 20        SEP #$20
	LDA ROMControlActions,X  					;C2/2681: BF 00 56 D0  LDA $D05600,X  
	CMP #$FF							;C2/2685: C9 FF        CMP #$FF
	BEQ .TryRandomAction	;no action in this slot, try again	;C2/2687: F0 D3        BEQ $265C
	STA AIBuffer     						;C2/2689: 8D 40 26     STA $2640      
	LDA #$FF	;end of list					;C2/268C: A9 FF        LDA #$FF
	STA AIBuffer+1							;C2/268E: 8D 41 26     STA $2641
	INC TempCharm							;C2/2691: E6 22        INC $22
	JSR DispatchAICommands						;C2/2693: 20 10 32     JSR $3210
	BRA .GoFinish							;C2/2696: 80 54        BRA $26EC

.CheckFlirt								;
	LDA CharStruct.CmdStatus,X					;C2/2698: BD 1E 20     LDA $201E,X
	AND #$08	;flirt						;C2/269B: 29 08        AND #$08
	BEQ .CheckControl						;C2/269D: F0 0C        BEQ $26AB
	LDA #$51	;throbbing command				;C2/269F: A9 51        LDA #$51
	STA CharStruct.Command,X					;C2/26A1: 9D 57 20     STA $2057,X
	LDA #$80	;other						;C2/26A4: A9 80        LDA #$80
	STA CharStruct.ActionFlag,X					;C2/26A6: 9D 56 20     STA $2056,X
	BRA .GoFinish							;C2/26A9: 80 41        BRA $26EC

.CheckControl
	LDA CharStruct.Status4,X					;C2/26AB: BD 1D 20     LDA $201D,X
	AND #$20	;control					;C2/26AE: 29 20        AND #$20
	BNE .Control							;C2/26B0: D0 09        BNE $26BB
	LDA CharStruct.Status2,X					;C2/26B2: BD 1B 20     LDA $201B,X
	AND #$40	;sleep						;C2/26B5: 29 40        AND #$40
	BNE .Sleep							;C2/26B7: D0 13        BNE $26CC
	BRA .Normal							;C2/26B9: 80 34        BRA $26EF

.Control
	TDC 								;C2/26BB: 7B           TDC 
	TAY 								;C2/26BC: A8           TAY 
-	LDA ControlTarget,Y						;C2/26BD: B9 3A 7C     LDA $7C3A,Y
	CMP AttackerIndex						;C2/26C0: C5 47        CMP $47        
	BEQ .FoundController						;C2/26C2: F0 03        BEQ $26C7
	INY 								;C2/26C4: C8           INY 
	BRA -								;C2/26C5: 80 F6        BRA $26BD
.FoundController
	LDA ControlCommand,Y						;C2/26C7: B9 3E 7C     LDA $7C3E,Y
	BNE .ControlCommand						;C2/26CA: D0 0A        BNE $26D6
.Sleep	;or controlled without a command
	STZ CharStruct.Command,X					;C2/26CC: 9E 57 20     STZ $2057,X
	LDA #$80	;action complete?				;C2/26CF: A9 80        LDA #$80
	STA CharStruct.ActionFlag,X					;C2/26D1: 9D 56 20     STA $2056,X
	BRA .GoFinish							;C2/26D4: 80 16        BRA $26EC

.ControlCommand
	TDC 								;C2/26D6: 7B           TDC 
	STA ControlCommand,Y						;C2/26D7: 99 3E 7C     STA $7C3E,Y
	LDA MonsterIndex						;C2/26DA: AD 03 7C     LDA $7C03
	TAX 								;C2/26DD: AA           TAX 
	LDA MonsterControlActions,X					;C2/26DE: BD 43 7C     LDA $7C43,X
	STA AIBuffer							;C2/26E1: 8D 40 26     STA $2640
	LDA #$FF	;end of list					;C2/26E4: A9 FF        LDA #$FF
	STA AIBuffer+1							;C2/26E6: 8D 41 26     STA $2641
	JSR DispatchAICommands						;C2/26E9: 20 10 32     JSR $3210

.GoFinish
	JMP .Finish							;C2/26EC: 4C 8A 27     JMP $278A

.Normal
	LDA MonsterIndex						;C2/26EF: AD 03 7C     LDA $7C03
	TAX 								;C2/26F2: AA           TAX 
	LDA AIActiveConditionSet,X					;C2/26F3: BD 87 46     LDA $4687,X
	STA AICurrentActiveCondSet					;C2/26F6: 8D 8F 46     STA $468F
	LDA MonsterIndex						;C2/26F9: AD 03 7C     LDA $7C03
	ASL 								;C2/26FC: 0A           ASL 
	TAX 								;C2/26FD: AA           TAX 
	REP #$20							;C2/26FE: C2 20        REP #$20
	CLC 								;C2/2700: 18           CLC 
	LDA ROMTimes1620w,X	;*1620, size of MonsterAI struct	;C2/2701: BF A5 EE D0  LDA $D0EEA5,X
	ADC #!MonsterAI							;C2/2705: 69 59 47     ADC #$4759
	STA AIOffset							;C2/2708: 85 4B        STA $4B
	TDC 								;C2/270A: 7B           TDC 
	SEP #$20							;C2/270B: E2 20        SEP #$20
	STZ AICurrentCheckedSet						;C2/270D: 9C 90 46     STZ $4690

.CheckAIConditions
	LDA AICurrentCheckedSet						;C2/2710: AD 90 46     LDA $4690
	TAX 								;C2/2713: AA           TAX 
	LDA ROMTimes17,X	;size of a MonsterAI condition		;C2/2714: BF C9 EE D0  LDA $D0EEC9,X
	TAY 								;C2/2718: A8           TAY 
	STY AIConditionOffset						;C2/2719: 8C 92 46     STY $4692
	STZ AICheckIndex						;C2/271C: 9C 91 46     STZ $4691
.CheckSingleCondition
	LDY AIConditionOffset						;C2/271F: AC 92 46     LDY $4692
	LDA (AIOffset),Y						;C2/2722: B1 4B        LDA ($4B),Y
	BEQ .AIActions		;0 always succeeds			;C2/2724: F0 2A        BEQ $2750
	CMP #$FE		;indicates end of condition set		;C2/2726: C9 FE        CMP #$FE
	BEQ .AIActions							;C2/2728: F0 26        BEQ $2750
	JSR CheckAICondition						;C2/272A: 20 BF 27     JSR $27BF      
	LDA AIConditionMet						;C2/272D: AD 94 46     LDA $4694
	BEQ .NextConditionSet      					;C2/2730: F0 14        BEQ $2746      
	REP #$20							;C2/2732: C2 20        REP #$20
	CLC 								;C2/2734: 18           CLC 
	LDA AIConditionOffset						;C2/2735: AD 92 46     LDA $4692
	ADC #$0004		;next condition in set			;C2/2738: 69 04 00     ADC #$0004
	STA AIConditionOffset						;C2/273B: 8D 92 46     STA $4692
	TDC 								;C2/273E: 7B           TDC 
	SEP #$20							;C2/273F: E2 20        SEP #$20
	INC AICheckIndex						;C2/2741: EE 91 46     INC $4691
	BRA .CheckSingleCondition					;C2/2744: 80 D9        BRA $271F

.NextConditionSet	;failed a condition in this set, check next set of conditions
	INC AICurrentCheckedSet						;C2/2746: EE 90 46     INC $4690
	LDA AICurrentCheckedSet						;C2/2749: AD 90 46     LDA $4690
	CMP #$0A		;10 conditions max			;C2/274C: C9 0A        CMP #$0A
	BNE .CheckAIConditions						;C2/274E: D0 C0        BNE $2710

.AIActions
	REP #$20							;C2/2750: C2 20        REP #$20
	CLC 								;C2/2752: 18           CLC 
	LDA AIOffset							;C2/2753: A5 4B        LDA $4B
	ADC #$00AA	;advances from Conditions to Actions		;C2/2755: 69 AA 00     ADC #$00AA
	STA AIOffset							;C2/2758: 85 4B        STA $4B
	TDC 								;C2/275A: 7B           TDC 
	SEP #$20							;C2/275B: E2 20        SEP #$20
	LDA AICurrentActiveCondSet					;C2/275D: AD 8F 46     LDA $468F
	CMP AICurrentCheckedSet						;C2/2760: CD 90 46     CMP $4690
	BEQ .ConditionOK	;matches so don't need to change things	;C2/2763: F0 22        BEQ $2787
	LDA MonsterIndex						;C2/2765: AD 03 7C     LDA $7C03
	TAX 								;C2/2768: AA           TAX 
	LDA AICurrentCheckedSet						;C2/2769: AD 90 46     LDA $4690
	STA AIActiveConditionSet,X	;checked cond is now current	;C2/276C: 9D 87 46     STA $4687,X
	LDA MonsterIndex						;C2/276F: AD 03 7C     LDA $7C03
	ASL 								;C2/2772: 0A           ASL 
	TAY 								;C2/2773: A8           TAY 
	LDA AICurrentCheckedSet						;C2/2774: AD 90 46     LDA $4690
	ASL 								;C2/2777: 0A           ASL 
	TAX 								;C2/2778: AA           TAX 
	LDA ROMTimes64w,X						;C2/2779: BF B5 EE D0  LDA $D0EEB5,X
	STA AICurrentOffset,Y						;C2/277D: 99 96 46     STA $4696,Y
	LDA ROMTimes64w+1,X						;C2/2780: BF B6 EE D0  LDA $D0EEB6,X
	STA AICurrentOffset+1,Y						;C2/2784: 99 97 46     STA $4697,Y
.ConditionOK
	JSR ProcessAIScript						;C2/2787: 20 3B 31     JSR $313B       
.Finish
	LDX MonsterOffset16						;C2/278A: AE 5E 43     LDX $435E
	LDA MonsterMagic,X    						;C2/278D: BD DE 41     LDA $41DE,X     
	REP #$20							;C2/2790: C2 20        REP #$20
	JSR ShiftMultiply_8   						;C2/2792: 20 B6 01     JSR $01B6       
	TAX 								;C2/2795: AA           TAX 
	TDC 								;C2/2796: 7B           TDC 
	SEP #$20							;C2/2797: E2 20        SEP #$20
	LDA ROMMagicInfo.Targetting,X					;C2/2799: BF 80 0B D1  LDA $D10B80,X   
	AND #$03       	;delay values					;C2/279D: 29 03        AND #$03        
	TAX								;C2/279F: AA           TAX
	LDA ROMTimes10,X  						;C2/27A0: BF EE EC D0  LDA $D0ECEE,X   
	PHA 								;C2/27A4: 48           PHA 
	LDA AttackerIndex						;C2/27A5: A5 47        LDA $47         
	JSR GetTimerOffset    						;C2/27A7: 20 07 02     JSR $0207       
	PLA 								;C2/27AA: 68           PLA 
if !_Fixes		;**bug: should adjust monster attack delay for haste/slow
	JSR HasteSlowMod
endif
	STA CurrentTimer.ATB,Y   					;C2/27AB: 99 7F 3D     STA $3D7F,Y     
	LDA #$41	;pending action					;C2/27AE: A9 41        LDA #$41
	STA EnableTimer.ATB,Y    					;C2/27B0: 99 FB 3C     STA $3CFB,Y     
	LDA MonsterIndex						;C2/27B3: AD 03 7C     LDA $7C03
	ASL 								;C2/27B6: 0A           ASL 
	TAX 								;C2/27B7: AA           TAX 
	STZ ForcedTarget.Party,X					;C2/27B8: 9E 2A 7C     STZ $7C2A,X
	STZ ForcedTarget.Monster,X					;C2/27BB: 9E 2B 7C     STZ $7C2B,X
	RTS 								;C2/27BE: 60           RTS 

endif