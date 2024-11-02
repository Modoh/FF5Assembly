if !_Fixes

;Fixes:
;	Fixes Sword Slap not waking people up
;	Fixes Mute/Void stopping the wrong person's sing timer
;	Fixes Barrier getting queued up while Paralyzed or Berserk	
;	Fixes some instances where flow could jump back to the first reaction from the second

;Check for and launch any reactions to the attacks this tick
;Includes things like waking from sleep but also AI scripted reactions
%subdef(HandleReactions)
	LDA #$01							;C2/35E3: A9 01        LDA #$01
	STA ReactingIndexType						;C2/35E5: 8D 56 7C     STA $7C56
	LDA CurrentlyReacting						;C2/35E8: AD 4E 47     LDA $474E
	BNE .StartReactions						;C2/35EB: D0 79        BNE $3666
	LDA TurnProcessed						;C2/35ED: AD 54 47     LDA $4754
	BNE +								;C2/35F0: D0 03        BNE $35F5
	JMP .Finish							;C2/35F2: 4C 0C 3C     JMP $3C0C
+	LDA AttackerIndex						;C2/35F5: A5 47        LDA $47         
	STA ActedIndex							;C2/35F7: 8D 73 7C     STA $7C73
	LDA #$FF							;C2/35FA: A9 FF        LDA #$FF
	STA ReactingIndex						;C2/35FC: 8D 55 47     STA $4755
	STZ ReactionFlags						;C2/35FF: 9C 53 47     STZ $4753
	STZ FinalTargetBits						;C2/3602: 9C 4F 47     STZ $474F
	STZ TargetWasParty						;C2/3605: 9C 50 47     STZ $4750
	STZ FinalTarget2Bits						;C2/3608: 9C 51 47     STZ $4751
	STZ Target2WasParty						;C2/360B: 9C 52 47     STZ $4752
	LDA ActionAnim[0].Flags						;C2/360E: AD CC 3B     LDA $3BCC
	AND #$40	;target was a monster				;C2/3611: 29 40        AND #$40
	BNE +								;C2/3613: D0 03        BNE $3618
	INC TargetWasParty						;C2/3615: EE 50 47     INC $4750
+	LDA ActionAnim[0].TargetBits					;C2/3618: AD CF 3B     LDA $3BCF
	STA FinalTargetBits						;C2/361B: 8D 4F 47     STA $474F
	BNE .TargetSet							;C2/361E: D0 10        BNE $3630
	LDA ActionAnim[0].ReflecteeBits					;C2/3620: AD D1 3B     LDA $3BD1
	BEQ .TargetSet							;C2/3623: F0 0B        BEQ $3630
	STA FinalTargetBits						;C2/3625: 8D 4F 47     STA $474F
	LDA TargetWasParty						;C2/3628: AD 50 47     LDA $4750
	EOR #$01							;C2/362B: 49 01        EOR #$01
	STA TargetWasParty						;C2/362D: 8D 50 47     STA $4750
.TargetSet
	LDA #$80							;C2/3630: A9 80        LDA #$80
	STA ReactionFlags						;C2/3632: 8D 53 47     STA $4753
	LDA Skip2ndReactionCheck	;may be unused?			;C2/3635: AD 2E 7B     LDA $7B2E
	CMP #$FF							;C2/3638: C9 FF        CMP #$FF
	BEQ .StartReactions		;skips 2nd reaction setup	;C2/363A: F0 2A        BEQ $3666
	LDA ActionAnim[1].Flags						;C2/363C: AD D3 3B     LDA $3BD3
	AND #$40			;target was a monster		;C2/363F: 29 40        AND #$40
	BNE +								;C2/3641: D0 03        BNE $3646
	INC Target2WasParty						;C2/3643: EE 52 47     INC $4752
+	LDA ActionAnim[1].TargetBits					;C2/3646: AD D6 3B     LDA $3BD6
	STA FinalTarget2Bits						;C2/3649: 8D 51 47     STA $4751
	BNE .Target2Set							;C2/364C: D0 10        BNE $365E
	LDA ActionAnim[1].ReflecteeBits					;C2/364E: AD D8 3B     LDA $3BD8
	BEQ .Target2Set							;C2/3651: F0 0B        BEQ $365E
	STA FinalTarget2Bits						;C2/3653: 8D 51 47     STA $4751
	LDA Target2WasParty						;C2/3656: AD 52 47     LDA $4752
	EOR #$01							;C2/3659: 49 01        EOR #$01
	STA Target2WasParty						;C2/365B: 8D 52 47     STA $4752
.Target2Set
	LDA ReactionFlags						;C2/365E: AD 53 47     LDA $4753
	ORA #$40							;C2/3661: 09 40        ORA #$40
	STA ReactionFlags						;C2/3663: 8D 53 47     STA $4753

.StartReactions
	LDA PendingReactions						;C2/3666: AD 56 47     LDA $4756
	BEQ +								;C2/3669: F0 03        BEQ $366E
	JMP .Finish							;C2/366B: 4C 0C 3C     JMP $3C0C
+	LDA ReactingIndex						;C2/366E: AD 55 47     LDA $4755
	BMI +								;C2/3671: 30 03        BMI $3676
	JSR RestoreActionData						;C2/3673: 20 08 3D     JSR $3D08
+	LDA ReactionFlags						;C2/3676: AD 53 47     LDA $4753
	AND #$01	;should check second reaction instead		;C2/3679: 29 01        AND #$01
	BEQ .CheckTargetsLoop						;C2/367B: F0 03        BEQ $3680
	JMP .CheckTargets2Loop						;C2/367D: 4C 51 39     JMP $3951

.CheckTargetsLoop
	TDC 								;C2/3680: 7B           TDC 
	TAX 								;C2/3681: AA           TAX 
-	LDA FinalTargetBits						;C2/3682: AD 4F 47     LDA $474F
	JSR SelectBit_X  						;C2/3685: 20 DB 01     JSR $01DB       
	BNE .FoundTarget						;C2/3688: D0 0C        BNE $3696
	INX 								;C2/368A: E8           INX 
	CPX #$0008							;C2/368B: E0 08 00     CPX #$0008
	BNE -								;C2/368E: D0 F2        BNE $3682
	INC ReactionFlags	;switch to second reaction 		;C2/3690: EE 53 47     INC $4753
	JMP .CheckTargets2Loop						;C2/3693: 4C 51 39     JMP $3951

.FoundTarget
	LDA FinalTargetBits						;C2/3696: AD 4F 47     LDA $474F
	JSR ClearBit_X	 						;C2/3699: 20 D1 01     JSR $01D1       
	STA FinalTargetBits						;C2/369C: 8D 4F 47     STA $474F
	TXA 								;C2/369F: 8A           TXA 
	STA ReactingIndex						;C2/36A0: 8D 55 47     STA $4755
	LDA TargetWasParty						;C2/36A3: AD 50 47     LDA $4750
	BNE .PartyTarget						;C2/36A6: D0 08        BNE $36B0
	CLC 								;C2/36A8: 18           CLC 
	LDA ReactingIndex						;C2/36A9: AD 55 47     LDA $4755
	ADC #$04	;now character index				;C2/36AC: 69 04        ADC #$04
	BRA .MonsterTarget						;C2/36AE: 80 03        BRA $36B3

.PartyTarget
	LDA ReactingIndex						;C2/36B0: AD 55 47     LDA $4755
.MonsterTarget
	TAX 								;C2/36B3: AA           TAX 
	LDA ActiveParticipants,X					;C2/36B4: BD C2 3E     LDA $3EC2,X
	BEQ .CheckTargetsLoop						;C2/36B7: F0 C7        BEQ $3680
	TXA 								;C2/36B9: 8A           TXA 
	JSR CalculateCharOffset  					;C2/36BA: 20 EC 01     JSR $01EC       
	LDA CharStruct.Status1,X					;C2/36BD: BD 1A 20     LDA $201A,X
	AND #$40	;stone						;C2/36C0: 29 40        AND #$40
	BNE .CheckTargetsLoop						;C2/36C2: D0 BC        BNE $3680
	LDA CharStruct.Status3,X					;C2/36C4: BD 1C 20     LDA $201C,X
	AND #$10	;stop						;C2/36C7: 29 10        AND #$10
	BNE .CheckTargetsLoop						;C2/36C9: D0 B5        BNE $3680
	LDA CharStruct.Status4,X					;C2/36CB: BD 1D 20     LDA $201D,X
	AND #$81	;erased or hidden				;C2/36CE: 29 81        AND #$81
	BNE .CheckTargetsLoop						;C2/36D0: D0 AE        BNE $3680
	LDA TargetWasParty						;C2/36D2: AD 50 47     LDA $4750
	BEQ .MonsterChecks						;C2/36D5: F0 03        BEQ $36DA
	JMP .PartyChecks						;C2/36D7: 4C B9 37     JMP $37B9

.MonsterChecks
	LDA CharStruct.Reaction1Magic,X					;C2/36DA: BD 47 20     LDA $2047,X
	CMP #$80	;monster fight					;C2/36DD: C9 80        CMP #$80
	BEQ .Fight							;C2/36DF: F0 23        BEQ $3704
	CMP #$81	;monster special				;C2/36E1: C9 81        CMP #$81
	BEQ .Fight							;C2/36E3: F0 1F        BEQ $3704
	LDA CharStruct.Reaction1Command,X				;C2/36E5: BD 46 20     LDA $2046,X
	CMP #$04	;fight						;C2/36E8: C9 04        CMP #$04
	BEQ .Fight							;C2/36EA: F0 18        BEQ $3704
	CMP #$0B	;capture/mug					;C2/36EC: C9 0B        CMP #$0B
	BEQ .Fight							;C2/36EE: F0 14        BEQ $3704
if !_Fixes		;fixes sword slap not waking people up
	CMP #$11	;sword slap
	BEQ .Fight
endif
	CMP #$15	;aim						;C2/36F0: C9 15        CMP #$15
	BEQ .Fight							;C2/36F2: F0 10        BEQ $3704
	CMP #$16	;x-fight					;C2/36F4: C9 16        CMP #$16
	BEQ .Fight							;C2/36F6: F0 0C        BEQ $3704
	CMP #$2C	;simple fight (no procs)			;C2/36F8: C9 2C        CMP #$2C
	BEQ .Fight							;C2/36FA: F0 08        BEQ $3704
	CMP #$2D	;jump landing					;C2/36FC: C9 2D        CMP #$2D
	BEQ .Fight							;C2/36FE: F0 04        BEQ $3704
	CMP #$33	;double lance					;C2/3700: C9 33        CMP #$33
	BNE .CheckReactions	;**bug: missing swordslap		;C2/3702: D0 7E        BNE $3782

.Fight	;remove relevant statuses after getting hit
	LDA CharStruct.Status4,X					;C2/3704: BD 1D 20     LDA $201D,X
	AND #$DF	;clear controlled status			;C2/3707: 29 DF        AND #$DF
	STA CharStruct.Status4,X					;C2/3709: 9D 1D 20     STA $201D,X
	CLC 								;C2/370C: 18           CLC 
	LDA ReactingIndex						;C2/370D: AD 55 47     LDA $4755
	ADC #$04							;C2/3710: 69 04        ADC #$04
	STA $0E		;char index					;C2/3712: 85 0E        STA $0E
	TDC 								;C2/3714: 7B           TDC 
	TAY 								;C2/3715: A8           TAY 
-	LDA ControlTarget,Y						;C2/3716: B9 3A 7C     LDA $7C3A,Y
	CMP $0E								;C2/3719: C5 0E        CMP $0E
	BEQ .ClearControl						;C2/371B: F0 08        BEQ $3725
	INY 								;C2/371D: C8           INY 
	CPY #$0004							;C2/371E: C0 04 00     CPY #$0004
	BNE -								;C2/3721: D0 F3        BNE $3716
	BRA .CheckSleep							;C2/3723: 80 19        BRA $373E

.ClearControl
	TDC 								;C2/3725: 7B           TDC 
	STA ControlTarget,Y						;C2/3726: 99 3A 7C     STA $7C3A,Y
	LDA CharStruct.Status2,X					;C2/3729: BD 1B 20     LDA $201B,X
	ORA CharStruct.AlwaysStatus2,X					;C2/372C: 1D 71 20     ORA $2071,X
	STA $10		;stored status2					;C2/372F: 85 10        STA $10
	LDA ReactingIndex						;C2/3731: AD 55 47     LDA $4755
	ASL 								;C2/3734: 0A           ASL 
	TAX 								;C2/3735: AA           TAX 
	STZ ForcedTarget.Party,X					;C2/3736: 9E 2A 7C     STZ $7C2A,X
	STZ ForcedTarget.Monster,X					;C2/3739: 9E 2B 7C     STZ $7C2B,X
	BRA .WakeUp							;C2/373C: 80 16        BRA $3754

.CheckSleep
	LDA CharStruct.Status2,X					;C2/373E: BD 1B 20     LDA $201B,X
	ORA CharStruct.AlwaysStatus2,X					;C2/3741: 1D 71 20     ORA $2071,X
	STA $10		;stored status2					;C2/3744: 85 10        STA $10
	LDA ReactingIndex						;C2/3746: AD 55 47     LDA $4755
	JSR ShiftMultiply_4  						;C2/3749: 20 B7 01     JSR $01B7       
	TAY 								;C2/374C: A8           TAY 
	LDA CombinedStatus[8].S2,Y	;8 is first monster		;C2/374D: B9 9F 7B     LDA $7B9F,Y
	AND #$40	;sleep						;C2/3750: 29 40        AND #$40
	BEQ .Awake							;C2/3752: F0 0F        BEQ $3763

.WakeUp
	PHX 								;C2/3754: DA           PHX 
	LDA $0E		;char index					;C2/3755: A5 0E        LDA $0E
	JSR ResetATB							;C2/3757: 20 82 24     JSR $2482
	PLX 								;C2/375A: FA           PLX 
	LDA CharStruct.Status2,X					;C2/375B: BD 1B 20     LDA $201B,X
	AND #$BF	;clear sleep					;C2/375E: 29 BF        AND #$BF
	STA CharStruct.Status2,X					;C2/3760: 9D 1B 20     STA $201B,X

.Awake
	LDA ReactingIndex						;C2/3763: AD 55 47     LDA $4755
	JSR ShiftMultiply_4  						;C2/3766: 20 B7 01     JSR $01B7       
	TAY 								;C2/3769: A8           TAY 
	LDA CombinedStatus[8].S2,Y	;8 is first monster		;C2/376A: B9 9F 7B     LDA $7B9F,Y
	AND #$10	;charm						;C2/376D: 29 10        AND #$10
	BEQ +								;C2/376F: F0 08        BEQ $3779
	LDA CharStruct.Status2,X					;C2/3771: BD 1B 20     LDA $201B,X
	AND #$EF	;clear charm					;C2/3774: 29 EF        AND #$EF
	STA CharStruct.Status2,X					;C2/3776: 9D 1B 20     STA $201B,X
+	LDA $10		;stored status2					;C2/3779: A5 10        LDA $10
	AND #$78	;sleep/para/charm/berserk			;C2/377B: 29 78        AND #$78
	BEQ .CheckReactions						;C2/377D: F0 03        BEQ $3782

.GoCheckTargetsLoop
	JMP .CheckTargetsLoop	;look for next target to check		;C2/377F: 4C 80 36     JMP $3680

.CheckReactions		
	LDX AttackerOffset						;C2/3782: A6 32        LDX $32         
	LDA CharStruct.Status2,X					;C2/3784: BD 1B 20     LDA $201B,X
	AND #$78	;sleep/para/charm/berserk			;C2/3787: 29 78        AND #$78
	BNE .GoCheckTargetsLoop						;C2/3789: D0 F4        BNE $377F
	LDA CharStruct.Status4,X					;C2/378B: BD 1D 20     LDA $201D,X
	AND #$20	;controlled					;C2/378E: 29 20        AND #$20
	BNE .GoCheckTargetsLoop						;C2/3790: D0 ED        BNE $377F
	LDA CharStruct.Reaction1Command,X				;C2/3792: BD 46 20     LDA $2046,X
	CMP #$1C	;catch						;C2/3795: C9 1C        CMP #$1C
	BEQ .GoCheckTargetsLoop						;C2/3797: F0 E6        BEQ $377F
	JSR CheckReactionConditions					;C2/3799: 20 10 3C     JSR $3C10
	LDA AIConditionMet 						;C2/379C: AD 94 46     LDA $4694
	BNE +								;C2/379F: D0 03        BNE $37A4
	JMP .CheckTargetsLoop						;C2/37A1: 4C 80 36     JMP $3680
+	CLC 								;C2/37A4: 18           CLC 
	LDA ReactingIndex						;C2/37A5: AD 55 47     LDA $4755
	ADC #$04	;shift to become Char Index			;C2/37A8: 69 04        ADC #$04
	STA ReactingIndex						;C2/37AA: 8D 55 47     STA $4755
	JSR SaveActionData						;C2/37AD: 20 7F 3C     JSR $3C7F
	JSR ProcessReaction						;C2/37B0: 20 C7 3D     JSR $3DC7
	JSR ReactionPauseTimerChecks					;C2/37B3: 20 9C 3D     JSR $3D9C
	JMP .Finish							;C2/37B6: 4C 0C 3C     JMP $3C0C

.PartyChecks	
	LDX AttackerOffset						;C2/37B9: A6 32        LDX $32         
	LDA CharStruct.Status2,X					;C2/37BB: BD 1B 20     LDA $201B,X
	AND #$04	;mute						;C2/37BE: 29 04        AND #$04
	BNE +								;C2/37C0: D0 07        BNE $37C9
	LDA Void							;C2/37C2: AD E6 7B     LDA $7BE6
	AND #$40	;void						;C2/37C5: 29 40        AND #$40
	BEQ .CheckHP							;C2/37C7: F0 18        BEQ $37E1
+	LDA CharStruct.Status4,X					;C2/37C9: BD 1D 20     LDA $201D,X
	AND #$04	;singing					;C2/37CC: 29 04        AND #$04
	BEQ .CheckHP							;C2/37CE: F0 11        BEQ $37E1
	LDA CharStruct.Status4,X					;C2/37D0: BD 1D 20     LDA $201D,X
	AND #$FB	;clear singing					;C2/37D3: 29 FB        AND #$FB
	STA CharStruct.Status4,X					;C2/37D5: 9D 1D 20     STA $201D,X
if !_Fixes		;**bug: mute or void is supposed to stop singing, but stops the wrong person's sing timer
	LDA ReactingIndex	;this is address $4755, so they likely missed the high byte of the address to load
else
	LDA Defense+1	;$55 high byte of defense, which is usually 0	;C2/37D8: A5 55        LDA $55
endif
	JSR GetTimerOffset 						;C2/37DA: 20 07 02     JSR $0207       
	TDC 								;C2/37DD: 7B           TDC 
	STA EnableTimer.Sing,Y						;C2/37DE: 99 F9 3C     STA $3CF9,Y

.CheckHP
	LDX AttackerOffset						;C2/37E1: A6 32        LDX $32         
	LDA CharStruct.CurHP,X						;C2/37E3: BD 06 20     LDA $2006,X
	ORA CharStruct.CurHP+1,X					;C2/37E6: 1D 07 20     ORA $2007,X
	BEQ .Dead							;C2/37E9: F0 11        BEQ $37FC
	LDA CharStruct.Status1,X					;C2/37EB: BD 1A 20     LDA $201A,X
	AND #$80	;dead						;C2/37EE: 29 80        AND #$80
	BNE .Dead							;C2/37F0: D0 0A        BNE $37FC
	LDA CharStruct.Status2,X					;C2/37F2: BD 1B 20     LDA $201B,X
	ORA CharStruct.AlwaysStatus2,X					;C2/37F5: 1D 71 20     ORA $2071,X
	AND #$20	;paralyze					;C2/37F8: 29 20        AND #$20
	BEQ +								;C2/37FA: F0 03        BEQ $37FF
.Dead	JMP .GoCheckTargetsLoopB					;C2/37FC: 4C 4B 39     JMP $394B

+	LDA CharStruct.Reaction1Magic,X					;C2/37FF: BD 47 20     LDA $2047,X
	CMP #$80	;monster fight					;C2/3802: C9 80        CMP #$80
	BEQ .PFight							;C2/3804: F0 23        BEQ $3829
	CMP #$81	;monster special				;C2/3806: C9 81        CMP #$81
	BEQ .PFight							;C2/3808: F0 1F        BEQ $3829
	LDA CharStruct.Reaction1Command,X				;C2/380A: BD 46 20     LDA $2046,X
	CMP #$04	;fight						;C2/380D: C9 04        CMP #$04
	BEQ .PFight							;C2/380F: F0 18        BEQ $3829
	CMP #$0B	;capture/mug					;C2/3811: C9 0B        CMP #$0B
	BEQ .PFight							;C2/3813: F0 14        BEQ $3829
if !_Fixes		;fixes sword slap not waking people up
	CMP #$11	;sword slap
	BEQ .PFight
endif
	CMP #$15	;aim						;C2/3815: C9 15        CMP #$15
	BEQ .PFight							;C2/3817: F0 10        BEQ $3829
	CMP #$16	;x-fight					;C2/3819: C9 16        CMP #$16
	BEQ .PFight							;C2/381B: F0 0C        BEQ $3829
	CMP #$2C	;simple fight (no procs)			;C2/381D: C9 2C        CMP #$2C
	BEQ .PFight							;C2/381F: F0 08        BEQ $3829
	CMP #$2D	;jump landing					;C2/3821: C9 2D        CMP #$2D
	BEQ .PFight							;C2/3823: F0 04        BEQ $3829
	CMP #$33	;double lance					;C2/3825: C9 33        CMP #$33
	BNE .CheckDisablingStatus	;**bug: missing swordslap	;C2/3827: D0 5C        BNE $3885

.PFight	LDA CharStruct.Status2,X						;C2/3829: BD 1B 20     LDA $201B,X
	ORA CharStruct.AlwaysStatus2,X						;C2/382C: 1D 71 20     ORA $2071,X
	STA $0E		;saved status2						;C2/382F: 85 0E        STA $0E
	LDA CharStruct.Status4,X						;C2/3831: BD 1D 20     LDA $201D,X
	STA $0F		;saved status4						;C2/3834: 85 0F        STA $0F
	LDA ReactingIndex							;C2/3836: AD 55 47     LDA $4755
	JSR ShiftMultiply_4							;C2/3839: 20 B7 01     JSR $01B7     
	TAY 									;C2/383C: A8           TAY 
	LDA CombinedStatus.S2,Y							;C2/383D: B9 7F 7B     LDA $7B7F,Y
	AND #$40	;sleep							;C2/3840: 29 40        AND #$40
	BEQ +									;C2/3842: F0 08        BEQ $384C
	LDA CharStruct.Status2,X						;C2/3844: BD 1B 20     LDA $201B,X
	AND #$BF	;clear sleep						;C2/3847: 29 BF        AND #$BF
	STA CharStruct.Status2,X						;C2/3849: 9D 1B 20     STA $201B,X
+	LDA CombinedStatus.S2,Y							;C2/384C: B9 7F 7B     LDA $7B7F,Y
	AND #$10	;charm							;C2/384F: 29 10        AND #$10
	BEQ +									;C2/3851: F0 08        BEQ $385B
	LDA CharStruct.Status2,X						;C2/3853: BD 1B 20     LDA $201B,X
	AND #$EF	;clear charm						;C2/3856: 29 EF        AND #$EF
	STA CharStruct.Status2,X						;C2/3858: 9D 1B 20     STA $201B,X
+	LDA CharStruct.Status4,X						;C2/385B: BD 1D 20     LDA $201D,X
	AND #$FB	;clear singing						;C2/385E: 29 FB        AND #$FB
	STA CharStruct.Status4,X						;C2/3860: 9D 1D 20     STA $201D,X
	LDA CombinedStatus.S2,Y							;C2/3863: B9 7F 7B     LDA $7B7F,Y
	AND $0E		;saved status2						;C2/3866: 25 0E        AND $0E
	AND #$50	;sleep/charm						;C2/3868: 29 50        AND #$50
	BNE +									;C2/386A: D0 10        BNE $387C
	LDA $0F		;saved status4						;C2/386C: A5 0F        LDA $0F
	AND #$04	;singing						;C2/386E: 29 04        AND #$04
if !_Fixes		;**bug: barrier can be queued if para/berserk when reacting to physical attacks
	BEQ .CheckDisablingStatus
else
	BEQ .CheckBarrier							;C2/3870: F0 27        BEQ $3899
endif
	LDA ReactingIndex							;C2/3872: AD 55 47     LDA $4755
	JSR GetTimerOffset  							;C2/3875: 20 07 02     JSR $0207     
	TDC 									;C2/3878: 7B           TDC 
	STA EnableTimer.Sing,Y							;C2/3879: 99 F9 3C     STA $3CF9,Y
+	LDA ReactingIndex							;C2/387C: AD 55 47     LDA $4755
	JSR ResetATB								;C2/387F: 20 82 24     JSR $2482
	JMP .GoCheckTargetsLoopB						;C2/3882: 4C 4B 39     JMP $394B

.CheckDisablingStatus
	LDA CharStruct.Status2,X					;C2/3885: BD 1B 20     LDA $201B,X
	ORA CharStruct.AlwaysStatus2,X					;C2/3888: 1D 71 20     ORA $2071,X
	AND #$78	;sleep/para/charm/berserk			;C2/388B: 29 78        AND #$78
	BNE +								;C2/388D: D0 07        BNE $3896
	LDA CharStruct.Status4,X					;C2/388F: BD 1D 20     LDA $201D,X
	AND #$04	;singing					;C2/3892: 29 04        AND #$04
	BEQ .CheckBarrier						;C2/3894: F0 03        BEQ $3899
+	JMP .GoCheckTargetsLoopB					;C2/3896: 4C 4B 39     JMP $394B

.CheckBarrier
	LDA CharStruct.Passives1,X					;C2/3899: BD 20 20     LDA $2020,X
	AND #$20	;Barrier					;C2/389C: 29 20        AND #$20
	BEQ .CheckCounter						;C2/389E: F0 50        BEQ $38F0
	LDA CharStruct.Status3,X					;C2/38A0: BD 1C 20     LDA $201C,X
	ORA CharStruct.AlwaysStatus3,X					;C2/38A3: 1D 72 20     ORA $2072,X
	BMI .CheckCounter	;no barrier if reflected		;C2/38A6: 30 48        BMI $38F0
	LDA AttackerIndex						;C2/38A8: A5 47        LDA $47       
	CMP #$04	;no barrier if attacker was also party		;C2/38AA: C9 04        CMP #$04
	BCC .CheckCounter						;C2/38AC: 90 42        BCC $38F0
	REP #$20							;C2/38AE: C2 20        REP #$20
	LDA CharStruct.MaxHP,X						;C2/38B0: BD 08 20     LDA $2008,X
	JSR ShiftDivide_16						;C2/38B3: 20 BE 01     JSR $01BE     
	CMP CharStruct.CurHP,X						;C2/38B6: DD 06 20     CMP $2006,X
	BCC .CheckCounter16						;C2/38B9: 90 32        BCC $38ED
	TDC 								;C2/38BB: 7B           TDC 
	SEP #$20							;C2/38BC: E2 20        SEP #$20
	JSR SaveActionData						;C2/38BE: 20 7F 3C     JSR $3C7F
	LDY AttackerOffset						;C2/38C1: A4 32        LDY $32       
	LDA #$20	;Magic						;C2/38C3: A9 20        LDA #$20
	STA CharStruct.ActionFlag,Y					;C2/38C5: 99 56 20     STA $2056,Y
	LDA #$2C	;Magic						;C2/38C8: A9 2C        LDA #$2C
	STA CharStruct.Command,Y					;C2/38CA: 99 57 20     STA $2057,Y
	LDA #$7C	;Magic Barrier spell				;C2/38CD: A9 7C        LDA #$7C
	STA CharStruct.SelectedItem,Y					;C2/38CF: 99 5A 20     STA $205A,Y
	LDA ReactingIndex						;C2/38D2: AD 55 47     LDA $4755
	TAX 								;C2/38D5: AA           TAX 
	TDC 								;C2/38D6: 7B           TDC 
	JSR SetBit_X							;C2/38D7: 20 D6 01     JSR $01D6     
	STA CharStruct.PartyTargets,Y					;C2/38DA: 99 59 20     STA $2059,Y
	TDC 								;C2/38DD: 7B           TDC 
	STA CharStruct.MonsterTargets,Y					;C2/38DE: 99 58 20     STA $2058,Y
	JSR ProcessReaction_Party					;C2/38E1: 20 91 3E     JSR $3E91
	JSR ReactionPauseTimerChecks					;C2/38E4: 20 9C 3D     JSR $3D9C
	INC CurrentlyReacting						;C2/38E7: EE 4E 47     INC $474E
	JMP .GoFinish							;C2/38EA: 4C 4E 39     JMP $394E

.CheckCounter16
	TDC 								;C2/38ED: 7B           TDC 
	SEP #$20							;C2/38EE: E2 20        SEP #$20
.CheckCounter
	LDA CharStruct.Passives1,X					;C2/38F0: BD 20 20     LDA $2020,X   
	AND #$80	;counter					;C2/38F3: 29 80        AND #$80
	BPL .GoCheckTargetsLoopB					;C2/38F5: 10 54        BPL $394B     
	LDA CharStruct.Reaction1Magic,X					;C2/38F7: BD 47 20     LDA $2047,X   
	CMP #$80	;monster fight					;C2/38FA: C9 80        CMP #$80
	BEQ .CounterAttempt						;C2/38FC: F0 17        BEQ $3915
	CMP #$81	;monster special				;C2/38FE: C9 81        CMP #$81
	BNE .GoCheckTargetsLoopB					;C2/3900: D0 49        BNE $394B
	LDA ActedIndex							;C2/3902: AD 73 7C     LDA $7C73
	REP #$20							;C2/3905: C2 20        REP #$20
	JSR ShiftMultiply_128   					;C2/3907: 20 B2 01     JSR $01B2     
	TAY 								;C2/390A: A8           TAY 
	TDC 								;C2/390B: 7B           TDC 
	SEP #$20							;C2/390C: E2 20        SEP #$20
	LDA CharStruct.Specialty,Y					;C2/390E: B9 6E 20     LDA $206E,Y   
	AND #$83	;auto hit ignore defense, hp leak, 1.5x damage	;C2/3911: 29 83        AND #$83
	BEQ .GoCheckTargetsLoopB	   				;C2/3913: F0 36        BEQ $394B     

.CounterAttempt		;50% chance to counter monster fight or damaging specialty
	JSR Random_0_99							;C2/3915: 20 A2 02     JSR $02A2     
	CMP #$32     	;50%						;C2/3918: C9 32        CMP #$32      
	BCS .GoCheckTargetsLoopB					;C2/391A: B0 2F        BCS $394B
	JSR SaveActionData						;C2/391C: 20 7F 3C     JSR $3C7F
	LDY AttackerOffset						;C2/391F: A4 32        LDY $32       
	LDA #$80	;Physical/Other					;C2/3921: A9 80        LDA #$80
	STA CharStruct.ActionFlag,Y					;C2/3923: 99 56 20     STA $2056,Y
	LDA #$05     	;Fight						;C2/3926: A9 05        LDA #$05      
	STA CharStruct.Command,Y					;C2/3928: 99 57 20     STA $2057,Y
	SEC 								;C2/392B: 38           SEC 
	LDA AttackerIndex						;C2/392C: A5 47        LDA $47       
	SBC #$04	;to monster index				;C2/392E: E9 04        SBC #$04
	TAX 								;C2/3930: AA           TAX 
	TDC 								;C2/3931: 7B           TDC 
	JSR SetBit_X   							;C2/3932: 20 D6 01     JSR $01D6     
	STA CharStruct.MonsterTargets,Y					;C2/3935: 99 58 20     STA $2058,Y
	TDC 								;C2/3938: 7B           TDC 
	STA CharStruct.PartyTargets,Y					;C2/3939: 99 59 20     STA $2059,Y
	STA CharStruct.SelectedItem,Y					;C2/393C: 99 5A 20     STA $205A,Y
	JSR ProcessReaction_Party					;C2/393F: 20 91 3E     JSR $3E91
	JSR ReactionPauseTimerChecks					;C2/3942: 20 9C 3D     JSR $3D9C
	INC CurrentlyReacting						;C2/3945: EE 4E 47     INC $474E
	JMP .GoFinish							;C2/3948: 4C 4E 39     JMP $394E

.GoCheckTargetsLoopB
	JMP .CheckTargetsLoop	;check next target for reactions	;C2/394B: 4C 80 36     JMP $3680

.GoFinish
	JMP .Finish							;C2/394E: 4C 0C 3C     JMP $3C0C
	
.CheckTargets2Loop		;second reaction, same general code structure as above
				;**optimize: 	could probably move a lot of the dupe code to reusable functions
				;		this is more difficult that it should be because the second set of reactions is split up in ram
	TDC 								;C2/3951: 7B           TDC 
	TAX 								;C2/3952: AA           TAX 
-	LDA FinalTarget2Bits						;C2/3953: AD 51 47     LDA $4751
	JSR SelectBit_X							;C2/3956: 20 DB 01     JSR $01DB      
	BNE .FoundTarget2						;C2/3959: D0 14        BNE $396F
	INX 								;C2/395B: E8           INX 
	CPX #$0008							;C2/395C: E0 08 00     CPX #$0008
	BNE -								;C2/395F: D0 F2        BNE $3953
	LDA CurrentlyReacting						;C2/3961: AD 4E 47     LDA $474E
	BEQ .GoFinish2							;C2/3964: F0 06        BEQ $396C
	JSR UnpauseTimerChecks						;C2/3966: 20 BB 3D     JSR $3DBB
	STZ CurrentlyReacting						;C2/3969: 9C 4E 47     STZ $474E
.GoFinish2
	JMP .Finish							;C2/396C: 4C 0C 3C     JMP $3C0C

.FoundTarget2
	LDA FinalTarget2Bits						;C2/396F: AD 51 47     LDA $4751
	JSR ClearBit_X   						;C2/3972: 20 D1 01     JSR $01D1      
	STA FinalTarget2Bits						;C2/3975: 8D 51 47     STA $4751
	TXA 								;C2/3978: 8A           TXA 
	STA ReactingIndex						;C2/3979: 8D 55 47     STA $4755
	LDA Target2WasParty						;C2/397C: AD 52 47     LDA $4752
	BNE .PartyTarget2						;C2/397F: D0 08        BNE $3989
	CLC 								;C2/3981: 18           CLC 
	LDA ReactingIndex						;C2/3982: AD 55 47     LDA $4755
	ADC #$04	;now char index					;C2/3985: 69 04        ADC #$04
	BRA .MonsterTarget2						;C2/3987: 80 03        BRA $398C

.PartyTarget2
	LDA ReactingIndex						;C2/3989: AD 55 47     LDA $4755
.MonsterTarget2
	TAX 								;C2/398C: AA           TAX 
	LDA ActiveParticipants,X					;C2/398D: BD C2 3E     LDA $3EC2,X
	BEQ .CheckTargets2Loop						;C2/3990: F0 BF        BEQ $3951
	TXA 								;C2/3992: 8A           TXA 
	JSR CalculateCharOffset    					;C2/3993: 20 EC 01     JSR $01EC      
	LDA CharStruct.Status1,X					;C2/3996: BD 1A 20     LDA $201A,X
	AND #$40	;stone						;C2/3999: 29 40        AND #$40
	BNE .CheckTargets2Loop						;C2/399B: D0 B4        BNE $3951
	LDA CharStruct.Status3,X					;C2/399D: BD 1C 20     LDA $201C,X
	AND #$10	;stop						;C2/39A0: 29 10        AND #$10
	BNE .CheckTargets2Loop						;C2/39A2: D0 AD        BNE $3951
	LDA CharStruct.Status4,X					;C2/39A4: BD 1D 20     LDA $201D,X
	AND #$81	;erased or hidden				;C2/39A7: 29 81        AND #$81
	BNE .CheckTargets2Loop						;C2/39A9: D0 A6        BNE $3951
	LDA Target2WasParty						;C2/39AB: AD 52 47     LDA $4752
	BEQ .MonsterChecks2						;C2/39AE: F0 03        BEQ $39B3
	JMP .PartyChecks2						;C2/39B0: 4C 92 3A     JMP $3A92

.MonsterChecks2
	LDA CharStruct.Reaction2Magic,X					;C2/39B3: BD 4E 20     LDA $204E,X
	CMP #$80	;monster fight					;C2/39B6: C9 80        CMP #$80
	BEQ .Fight2							;C2/39B8: F0 23        BEQ $39DD
	CMP #$81	;monster special				;C2/39BA: C9 81        CMP #$81
	BEQ .Fight2							;C2/39BC: F0 1F        BEQ $39DD
	LDA CharStruct.Reaction2Command,X				;C2/39BE: BD 4D 20     LDA $204D,X
	CMP #$04	;fight						;C2/39C1: C9 04        CMP #$04
	BEQ .Fight2							;C2/39C3: F0 18        BEQ $39DD
	CMP #$0B	;capture/mug					;C2/39C5: C9 0B        CMP #$0B
	BEQ .Fight2							;C2/39C7: F0 14        BEQ $39DD
if !_Fixes		;fixes sword slap not waking people up
	CMP #$11	;sword slap
	BEQ .Fight2
endif
	CMP #$15	;aim						;C2/39C9: C9 15        CMP #$15
	BEQ .Fight2							;C2/39CB: F0 10        BEQ $39DD
	CMP #$16	;x-fight					;C2/39CD: C9 16        CMP #$16
	BEQ .Fight2							;C2/39CF: F0 0C        BEQ $39DD
	CMP #$2C	;simple fight (no procs)			;C2/39D1: C9 2C        CMP #$2C
	BEQ .Fight2							;C2/39D3: F0 08        BEQ $39DD
	CMP #$2D	;jump landing					;C2/39D5: C9 2D        CMP #$2D
	BEQ .Fight2							;C2/39D7: F0 04        BEQ $39DD
	CMP #$33	;double lance					;C2/39D9: C9 33        CMP #$33
	BNE .CheckReactions2	;**bug: missing swordslap		;C2/39DB: D0 7E        BNE $3A5B

.Fight2		;remove relevant statuses after getting hit
	LDA CharStruct.Status4,X					;C2/39DD: BD 1D 20     LDA $201D,X
	AND #$DF	;clear controlled status			;C2/39E0: 29 DF        AND #$DF
	STA CharStruct.Status4,X					;C2/39E2: 9D 1D 20     STA $201D,X
	CLC 								;C2/39E5: 18           CLC 
	LDA ReactingIndex						;C2/39E6: AD 55 47     LDA $4755
	ADC #$04							;C2/39E9: 69 04        ADC #$04
	STA $0E		;char index					;C2/39EB: 85 0E        STA $0E
	TDC 								;C2/39ED: 7B           TDC 
	TAY 								;C2/39EE: A8           TAY 
-	LDA ControlTarget,Y						;C2/39EF: B9 3A 7C     LDA $7C3A,Y
	CMP $0E								;C2/39F2: C5 0E        CMP $0E
	BEQ .ClearControl2						;C2/39F4: F0 08        BEQ $39FE
	INY 								;C2/39F6: C8           INY 
	CPY #$0004							;C2/39F7: C0 04 00     CPY #$0004
	BNE -								;C2/39FA: D0 F3        BNE $39EF
	BRA .CheckSleep2						;C2/39FC: 80 19        BRA $3A17
	
.ClearControl2
	TDC 								;C2/39FE: 7B           TDC 
	STA ControlTarget,Y						;C2/39FF: 99 3A 7C     STA $7C3A,Y
	LDA CharStruct.Status2,X					;C2/3A02: BD 1B 20     LDA $201B,X
	ORA CharStruct.AlwaysStatus2,X					;C2/3A05: 1D 71 20     ORA $2071,X
	STA $10								;C2/3A08: 85 10        STA $10
	LDA ReactingIndex						;C2/3A0A: AD 55 47     LDA $4755
	ASL 								;C2/3A0D: 0A           ASL 
	TAX 								;C2/3A0E: AA           TAX 
	STZ ForcedTarget.Party,X					;C2/3A0F: 9E 2A 7C     STZ $7C2A,X
	STZ ForcedTarget.Monster,X					;C2/3A12: 9E 2B 7C     STZ $7C2B,X
	BRA .WakeUp2							;C2/3A15: 80 16        BRA $3A2D

.CheckSleep2
	LDA CharStruct.Status2,X					;C2/3A17: BD 1B 20     LDA $201B,X   
	ORA CharStruct.AlwaysStatus2,X					;C2/3A1A: 1D 71 20     ORA $2071,X   
	STA $10								;C2/3A1D: 85 10        STA $10       
	LDA ReactingIndex						;C2/3A1F: AD 55 47     LDA $4755     
	JSR ShiftMultiply_4   						;C2/3A22: 20 B7 01     JSR $01B7     
	TAY 								;C2/3A25: A8           TAY           
	LDA CombinedStatus[8].S2,Y	;8 is first monster		;C2/3A26: B9 9F 7B     LDA $7B9F,Y   
	AND #$40	;sleep						;C2/3A29: 29 40        AND #$40      
	BEQ .Awake2							;C2/3A2B: F0 0F        BEQ $3A3C     
													     
.WakeUp2                                                                                                     
	PHX 								;C2/3A2D: DA           PHX           
	LDA $0E		;char index					;C2/3A2E: A5 0E        LDA $0E       
	JSR ResetATB							;C2/3A30: 20 82 24     JSR $2482     
	PLX 								;C2/3A33: FA           PLX           
	LDA CharStruct.Status2,X					;C2/3A34: BD 1B 20     LDA $201B,X   
	AND #$BF	;clear sleep					;C2/3A37: 29 BF        AND #$BF      
	STA CharStruct.Status2,X					;C2/3A39: 9D 1B 20     STA $201B,X   
													     
.Awake2                                                                                                      
	LDA ReactingIndex						;C2/3A3C: AD 55 47     LDA $4755     
	JSR ShiftMultiply_4  						;C2/3A3F: 20 B7 01     JSR $01B7     
	TAY 								;C2/3A42: A8           TAY           
	LDA CombinedStatus[8].S2,Y	;8 is first monster		;C2/3A43: B9 9F 7B     LDA $7B9F,Y   
	AND #$10	;charm						;C2/3A46: 29 10        AND #$10      
	BEQ +								;C2/3A48: F0 08        BEQ $3A52     
	LDA CharStruct.Status2,X					;C2/3A4A: BD 1B 20     LDA $201B,X   
	AND #$EF	;clear charm					;C2/3A4D: 29 EF        AND #$EF      
	STA CharStruct.Status2,X					;C2/3A4F: 9D 1B 20     STA $201B,X   
+	LDA $10		;stored status2					;C2/3A52: A5 10        LDA $10       
	AND #$78	;sleep/para/charm/berserk			;C2/3A54: 29 78        AND #$78      
	BEQ .CheckReactions2						;C2/3A56: F0 03        BEQ $3A5B     
.GoCheckTargets2Loop                                                                                         
	JMP .CheckTargets2Loop						;C2/3A58: 4C 51 39     JMP $3951     
													     
.CheckReactions2                                                                                             
	LDX AttackerOffset						;C2/3A5B: A6 32        LDX $32       
	LDA CharStruct.Status2,X					;C2/3A5D: BD 1B 20     LDA $201B,X   
	AND #$78	;sleep/para/charm/berserk			;C2/3A60: 29 78        AND #$78      
	BNE .GoCheckTargets2Loop					;C2/3A62: D0 F4        BNE $3A58     
	LDA CharStruct.Status4,X					;C2/3A64: BD 1D 20     LDA $201D,X   
	AND #$20	;controlled					;C2/3A67: 29 20        AND #$20      
	BNE .GoCheckTargets2Loop					;C2/3A69: D0 ED        BNE $3A58     
	LDA CharStruct.Reaction2Command,X				;C2/3A6B: BD 4D 20     LDA $204D,X   
	CMP #$1C	;catch						;C2/3A6E: C9 1C        CMP #$1C      
	BEQ .GoCheckTargets2Loop					;C2/3A70: F0 E6        BEQ $3A58     
	JSR CheckReactionConditions					;C2/3A72: 20 10 3C     JSR $3C10     
	LDA AIConditionMet 						;C2/3A75: AD 94 46     LDA $4694     
	BNE +								;C2/3A78: D0 03        BNE $3A7D     
	JMP .CheckTargets2Loop						;C2/3A7A: 4C 51 39     JMP $3951     
+	CLC 								;C2/3A7D: 18           CLC           
	LDA ReactingIndex						;C2/3A7E: AD 55 47     LDA $4755     
	ADC #$04	;shift to become Char Index			;C2/3A81: 69 04        ADC #$04      
	STA ReactingIndex						;C2/3A83: 8D 55 47     STA $4755     
	JSR SaveActionData						;C2/3A86: 20 7F 3C     JSR $3C7F     
	JSR ProcessReaction						;C2/3A89: 20 C7 3D     JSR $3DC7     
	JSR ReactionPauseTimerChecks					;C2/3A8C: 20 9C 3D     JSR $3D9C     
	JMP .Finish							;C2/3A8F: 4C 0C 3C     JMP $3C0C     
													     
.PartyChecks2	;differs from first set of reactions, is missing the silence sing check             
	LDA CurrentlyReacting						;C2/3A92: AD 4E 47     LDA $474E     
	BEQ +								;C2/3A95: F0 06        BEQ $3A9D     
	JSR UnpauseTimerChecks						;C2/3A97: 20 BB 3D     JSR $3DBB     
	STZ CurrentlyReacting						;C2/3A9A: 9C 4E 47     STZ $474E     
+	LDX AttackerOffset						;C2/3A9D: A6 32        LDX $32       
	LDA CharStruct.CurHP,X						;C2/3A9F: BD 06 20     LDA $2006,X   
	ORA CharStruct.CurHP+1,X					;C2/3AA2: 1D 07 20     ORA $2007,X   
	BEQ .Dead2							;C2/3AA5: F0 11        BEQ $3AB8     
	LDA CharStruct.Status1,X					;C2/3AA7: BD 1A 20     LDA $201A,X   
	AND #$80	;dead						;C2/3AAA: 29 80        AND #$80      
	BNE .Dead2							;C2/3AAC: D0 0A        BNE $3AB8     
	LDA CharStruct.Status2,X					;C2/3AAE: BD 1B 20     LDA $201B,X   
	ORA CharStruct.AlwaysStatus2,X					;C2/3AB1: 1D 71 20     ORA $2071,X   
	AND #$20	;paralyze					;C2/3AB4: 29 20        AND #$20      
	BEQ +								;C2/3AB6: F0 03        BEQ $3ABB     
.Dead2	JMP .GoCheckTargets2LoopB					;C2/3AB8: 4C 09 3C     JMP $3C09     
													     
+	LDA CharStruct.Reaction2Magic,X					;C2/3ABB: BD 4E 20     LDA $204E,X   
	CMP #$80	;monster fight					;C2/3ABE: C9 80        CMP #$80      
	BEQ .PFight2							;C2/3AC0: F0 23        BEQ $3AE5     
	CMP #$81	;monster special				;C2/3AC2: C9 81        CMP #$81      
	BEQ .PFight2							;C2/3AC4: F0 1F        BEQ $3AE5     
	LDA CharStruct.Reaction2Command,X				;C2/3AC6: BD 4D 20     LDA $204D,X   
	CMP #$04	;fight						;C2/3AC9: C9 04        CMP #$04      
	BEQ .PFight2							;C2/3ACB: F0 18        BEQ $3AE5     
	CMP #$0B	;capture/mug					;C2/3ACD: C9 0B        CMP #$0B      
	BEQ .PFight2							;C2/3ACF: F0 14        BEQ $3AE5     
if !_Fixes		;fixes sword slap not waking people up
	CMP #$11	;sword slap
	BEQ .PFight2
endif
	CMP #$15	;aim						;C2/3AD1: C9 15        CMP #$15      
	BEQ .PFight2							;C2/3AD3: F0 10        BEQ $3AE5     
	CMP #$16	;x-fight					;C2/3AD5: C9 16        CMP #$16      
	BEQ .PFight2							;C2/3AD7: F0 0C        BEQ $3AE5     
	CMP #$2C	;simple fight (no procs)			;C2/3AD9: C9 2C        CMP #$2C      
	BEQ .PFight2							;C2/3ADB: F0 08        BEQ $3AE5     
	CMP #$2D	;jump landing					;C2/3ADD: C9 2D        CMP #$2D      
	BEQ .PFight2							;C2/3ADF: F0 04        BEQ $3AE5     
	CMP #$33	;double lance					;C2/3AE1: C9 33        CMP #$33      
	BNE .CheckDisablingStatus2					;C2/3AE3: D0 5C        BNE $3B41     
													     
.PFight2                                                                                                     
	LDA CharStruct.Status2,X						;C2/3AE5: BD 1B 20     LDA $201B,X
	ORA CharStruct.AlwaysStatus2,X						;C2/3AE8: 1D 71 20     ORA $2071,X
	STA $0E									;C2/3AEB: 85 0E        STA $0E
	LDA CharStruct.Status4,X						;C2/3AED: BD 1D 20     LDA $201D,X
	STA $0F									;C2/3AF0: 85 0F        STA $0F
	LDA ReactingIndex							;C2/3AF2: AD 55 47     LDA $4755
	JSR ShiftMultiply_4    							;C2/3AF5: 20 B7 01     JSR $01B7      
	TAY 									;C2/3AF8: A8           TAY 
	LDA CombinedStatus.S2,Y							;C2/3AF9: B9 7F 7B     LDA $7B7F,Y
	AND #$40	;sleep							;C2/3AFC: 29 40        AND #$40
	BEQ +									;C2/3AFE: F0 08        BEQ $3B08
	LDA CharStruct.Status2,X						;C2/3B00: BD 1B 20     LDA $201B,X
	AND #$BF	;clear sleep						;C2/3B03: 29 BF        AND #$BF
	STA CharStruct.Status2,X						;C2/3B05: 9D 1B 20     STA $201B,X
+	LDA CombinedStatus.S2,Y							;C2/3B08: B9 7F 7B     LDA $7B7F,Y
	AND #$10	;charm							;C2/3B0B: 29 10        AND #$10
	BEQ +									;C2/3B0D: F0 08        BEQ $3B17
	LDA CharStruct.Status2,X						;C2/3B0F: BD 1B 20     LDA $201B,X
	AND #$EF	;clear charm						;C2/3B12: 29 EF        AND #$EF
	STA CharStruct.Status2,X						;C2/3B14: 9D 1B 20     STA $201B,X
+	LDA CharStruct.Status4,X						;C2/3B17: BD 1D 20     LDA $201D,X
	AND #$FB	;clear singing						;C2/3B1A: 29 FB        AND #$FB
	STA CharStruct.Status4,X						;C2/3B1C: 9D 1D 20     STA $201D,X
	LDA CombinedStatus.S2,Y							;C2/3B1F: B9 7F 7B     LDA $7B7F,Y
	AND $0E		;saved status2						;C2/3B22: 25 0E        AND $0E
	AND #$50	;sleep/charm						;C2/3B24: 29 50        AND #$50
	BNE +									;C2/3B26: D0 10        BNE $3B38
	LDA $0F		;saved status4						;C2/3B28: A5 0F        LDA $0F
	AND #$04	;singing						;C2/3B2A: 29 04        AND #$04
if !_Fixes			;**bug: barrier can be queued when para/berserk when hit by physical attacks
	BEQ .CheckDisablingStatus2
else
	BEQ .CheckBarrier2							;C2/3B2C: F0 27        BEQ $3B55
endif
	LDA ReactingIndex							;C2/3B2E: AD 55 47     LDA $4755
	JSR GetTimerOffset   							;C2/3B31: 20 07 02     JSR $0207      
	TDC 									;C2/3B34: 7B           TDC 
	STA EnableTimer.Sing,Y							;C2/3B35: 99 F9 3C     STA $3CF9,Y
+	LDA ReactingIndex							;C2/3B38: AD 55 47     LDA $4755
	JSR ResetATB								;C2/3B3B: 20 82 24     JSR $2482
if !_Fixes			;**bug: wrong reaction loop (first instead of second)
	JMP .CheckTargets2Loop
else
	JMP .GoCheckTargetsLoopB						;C2/3B3E: 4C 4B 39     JMP $394B
endif

.CheckDisablingStatus2
	LDA CharStruct.Status2,X						;C2/3B41: BD 1B 20     LDA $201B,X
	ORA CharStruct.AlwaysStatus2,X						;C2/3B44: 1D 71 20     ORA $2071,X
	AND #$78	;sleep/para/charm/berserk				;C2/3B47: 29 78        AND #$78
	BNE +									;C2/3B49: D0 07        BNE $3B52
	LDA CharStruct.Status4,X						;C2/3B4B: BD 1D 20     LDA $201D,X
	AND #$04	;singing						;C2/3B4E: 29 04        AND #$04
	BEQ .CheckBarrier2							;C2/3B50: F0 03        BEQ $3B55
+	
if !_Fixes			;**bug: wrong reaction loop again
	JMP .CheckTargets2Loop
else
	JMP .GoCheckTargetsLoopB						;C2/3B52: 4C 4B 39     JMP $394B
endif

.CheckBarrier2 
	LDA CharStruct.Passives1,X					;C2/3B55: BD 20 20     LDA $2020,X
	AND #$20	;barrier					;C2/3B58: 29 20        AND #$20
	BEQ .CheckCounter2						;C2/3B5A: F0 51        BEQ $3BAD
	LDA CharStruct.Status3,X					;C2/3B5C: BD 1C 20     LDA $201C,X
	ORA CharStruct.AlwaysStatus3,X					;C2/3B5F: 1D 72 20     ORA $2072,X
	BMI .CheckCounter2	;no barrier if reflected		;C2/3B62: 30 49        BMI $3BAD
	LDA ActedIndex							;C2/3B64: AD 73 7C     LDA $7C73
	CMP #$04	;no barrier if attacker was also party		;C2/3B67: C9 04        CMP #$04
	BCC .CheckCounter2						;C2/3B69: 90 42        BCC $3BAD
	REP #$20							;C2/3B6B: C2 20        REP #$20
	LDA CharStruct.MaxHP,X						;C2/3B6D: BD 08 20     LDA $2008,X
	JSR ShiftDivide_16						;C2/3B70: 20 BE 01     JSR $01BE      
	CMP CharStruct.CurHP,X						;C2/3B73: DD 06 20     CMP $2006,X
	BCC .CheckCounter2Mode						;C2/3B76: 90 32        BCC $3BAA
	TDC 								;C2/3B78: 7B           TDC 
	SEP #$20							;C2/3B79: E2 20        SEP #$20
	JSR SaveActionData						;C2/3B7B: 20 7F 3C     JSR $3C7F
	LDY AttackerOffset						;C2/3B7E: A4 32        LDY $32        
	LDA #$20	;Magic						;C2/3B80: A9 20        LDA #$20
	STA CharStruct.ActionFlag,Y					;C2/3B82: 99 56 20     STA $2056,Y
	LDA #$2C	;Magic						;C2/3B85: A9 2C        LDA #$2C
	STA CharStruct.Command,Y					;C2/3B87: 99 57 20     STA $2057,Y
	LDA #$7C	;Magic Barrier spell				;C2/3B8A: A9 7C        LDA #$7C
	STA CharStruct.SelectedItem,Y					;C2/3B8C: 99 5A 20     STA $205A,Y
	LDA ReactingIndex						;C2/3B8F: AD 55 47     LDA $4755
	TAX 								;C2/3B92: AA           TAX 
	TDC 								;C2/3B93: 7B           TDC 
	JSR SetBit_X							;C2/3B94: 20 D6 01     JSR $01D6      
	STA CharStruct.PartyTargets,Y					;C2/3B97: 99 59 20     STA $2059,Y
	TDC 								;C2/3B9A: 7B           TDC 
	STA CharStruct.MonsterTargets,Y					;C2/3B9B: 99 58 20     STA $2058,Y
	JSR ProcessReaction_Party					;C2/3B9E: 20 91 3E     JSR $3E91
	JSR ReactionPauseTimerChecks					;C2/3BA1: 20 9C 3D     JSR $3D9C
	INC CurrentlyReacting						;C2/3BA4: EE 4E 47     INC $474E
	JMP .Finish							;C2/3BA7: 4C 0C 3C     JMP $3C0C

.CheckCounter2Mode
	TDC 								;C2/3BAA: 7B           TDC 
	SEP #$20							;C2/3BAB: E2 20        SEP #$20
.CheckCounter2
	LDA CharStruct.Passives1,X					;C2/3BAD: BD 20 20     LDA $2020,X
	AND #$80	;counter					;C2/3BB0: 29 80        AND #$80
	BPL .GoCheckTargets2LoopB					;C2/3BB2: 10 55        BPL $3C09
	LDA CharStruct.Reaction2Magic,X					;C2/3BB4: BD 4E 20     LDA $204E,X
	CMP #$80	;monster fight					;C2/3BB7: C9 80        CMP #$80
	BEQ .CounterAttempt2						;C2/3BB9: F0 17        BEQ $3BD2
	CMP #$81	;monster special				;C2/3BBB: C9 81        CMP #$81
	BNE .GoCheckTargets2LoopB					;C2/3BBD: D0 4A        BNE $3C09
	LDA ActedIndex							;C2/3BBF: AD 73 7C     LDA $7C73
	REP #$20							;C2/3BC2: C2 20        REP #$20
	JSR ShiftMultiply_128 						;C2/3BC4: 20 B2 01     JSR $01B2      
	TAY 								;C2/3BC7: A8           TAY 
	TDC 								;C2/3BC8: 7B           TDC 
	SEP #$20							;C2/3BC9: E2 20        SEP #$20
	LDA CharStruct.Specialty,Y					;C2/3BCB: B9 6E 20     LDA $206E,Y
	AND #$83	;auto hit ignore defense, hp leak, 1.5x damage	;C2/3BCE: 29 83        AND #$83
	BEQ .GoCheckTargets2LoopB					;C2/3BD0: F0 37        BEQ $3C09

.CounterAttempt2	;50% chance to counter monster fight or damaging specialty
	JSR Random_0_99							;C2/3BD2: 20 A2 02     JSR $02A2      
	CMP #$32     	;50%						;C2/3BD5: C9 32        CMP #$32       
	BCS .GoCheckTargets2LoopB					;C2/3BD7: B0 30        BCS $3C09
	JSR SaveActionData						;C2/3BD9: 20 7F 3C     JSR $3C7F
	LDY AttackerOffset						;C2/3BDC: A4 32        LDY $32        
	LDA #$80	;Physical/Other					;C2/3BDE: A9 80        LDA #$80
	STA CharStruct.ActionFlag,Y					;C2/3BE0: 99 56 20     STA $2056,Y
	LDA #$05     	;Fight						;C2/3BE3: A9 05        LDA #$05
	STA CharStruct.Command,Y					;C2/3BE5: 99 57 20     STA $2057,Y
	SEC 								;C2/3BE8: 38           SEC 
	LDA ActedIndex	;first counter check used AttackerIndex		;C2/3BE9: AD 73 7C     LDA $7C73
	SBC #$04	;to monster index				;C2/3BEC: E9 04        SBC #$04
	TAX 								;C2/3BEE: AA           TAX 
	TDC 								;C2/3BEF: 7B           TDC 
	JSR SetBit_X   			  				;C2/3BF0: 20 D6 01     JSR $01D6      
	STA CharStruct.MonsterTargets,Y					;C2/3BF3: 99 58 20     STA $2058,Y
	TDC 								;C2/3BF6: 7B           TDC 
	STA CharStruct.PartyTargets,Y					;C2/3BF7: 99 59 20     STA $2059,Y
	STA CharStruct.SelectedItem,Y					;C2/3BFA: 99 5A 20     STA $205A,Y
	JSR ProcessReaction_Party					;C2/3BFD: 20 91 3E     JSR $3E91
	JSR ReactionPauseTimerChecks					;C2/3C00: 20 9C 3D     JSR $3D9C
	INC CurrentlyReacting						;C2/3C03: EE 4E 47     INC $474E
	JMP .Finish							;C2/3C06: 4C 0C 3C     JMP $3C0C

.GoCheckTargets2LoopB
	JMP .CheckTargets2Loop						;C2/3C09: 4C 51 39     JMP $3951

.Finish
	STZ ReactingIndexType						;C2/3C0C: 9C 56 7C     STZ $7C56
	RTS 								;C2/3C0F: 60           RTS 

endif