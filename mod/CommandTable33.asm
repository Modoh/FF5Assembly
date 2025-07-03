if !_Optimize
;optimizations: 
;uses BuildTargetBitmask and SimpleOneHand utility routines to remove a lot of near-duplicate code

;BuildTargetBitmask is a vanilla utility routine!

incsrc utility/SimpleOneHand.asm
;Process one hand's attacks (for simple no-proc attacks)
;Params
;$0E: char equipment offset
;$11: weapon attack type
;$14: Pointer to weapon info struct
;$16: 0 for rh, $80 for LH
;$17: number of extra attacks (twin lance)

;Command $55
;for Double Lance, attacks twice per hand if hand's weapon has this command proc 
%subdef(CommandTable33)
	STZ ProcSequence	;cancels any other procs		;C2/14B8: 9C FA 79     STZ $79FA
	STZ NextGFXQueueSlot						;C2/14BB: 9C F9 79     STZ $79F9
	LDX AttackerOffset						;C2/14BE: A6 32        LDX $32         
	LDA CharStruct.MonsterTargets,X					;C2/14C0: BD 58 20     LDA $2058,X
	STA MonsterTargets						;C2/14C3: 85 65        STA $65
	LDA CharStruct.PartyTargets,X					;C2/14C5: BD 59 20     LDA $2059,X
	STA PartyTargets						;C2/14C8: 85 66        STA $66
	JSR CheckRetarget      						;C2/14CA: 20 FE 4A     JSR $4AFE       
	LDX AttackerOffset    						;C2/14CD: A6 32        LDX $32         
	LDA PartyTargets						;C2/14CF: A5 66        LDA $66
	STA CharStruct.PartyTargets,X					;C2/14D1: 9D 59 20     STA $2059,X
	LDA MonsterTargets						;C2/14D4: A5 65        LDA $65
	STA CharStruct.MonsterTargets,X					;C2/14D6: 9D 58 20     STA $2058,X
	JSR BuildTargetBitmask	;call shared routine instead of duplicating bitmask code


	LDA AttackerIndex						;C2/14F0: A5 47        LDA $47         
	TAX 								;C2/14F2: AA           TAX 
	LDA ROMTimes84,X	;size of one character's gear structs	;C2/14F3: BF 85 ED D0  LDA $D0ED85,X
	TAY 								;C2/14F7: AA           TAX 
	STY $0E			;GearStruct offset			;C2/14F8: 86 0E        STX $0E
	LDX AttackerOffset						;C2/14FA: A6 32        LDX $32         
	LDA CharStruct.RHWeapon,X					;C2/14FC: BD 13 20     LDA $2013,X
	BEQ .LH								;C2/14FF: D0 03        BNE $1504

.RH	LDA RHWeapon.AtkType,Y
	STA $11			;attack type
	LDX #!RHWeapon
	STX $14			;weapon info pointer					
	STZ $16			;flag for hand anim					
	STZ $17			;no extra attacks					

	;check if this weapon has twin lance command
	LDA RHWeapon.Properties,Y
	AND #$02		;command instead of attack
	BEQ .LaunchRH
	LDA RHWeapon.Param3,Y
	CMP #$55		;this command (double lance)
	BNE .LaunchRH
	INC $17			;1 more attack
	LDA #$80							;C2/1587: A9 80        LDA #$80
	STA ActionAnimShift	;flag for later anim manipulation	;C2/1589: 8D 9B 7C     STA $7C9B
	
.LaunchRH
	JSR SimpleOneHand

.LH	LDX AttackerOffset						;C2/15C9: A6 32        LDX $32         
	LDA CharStruct.LHWeapon,X					;C2/15CB: BD 14 20     LDA $2014,X
	BEQ .Ret
	LDY $0E			;GearStruct offset
	LDA LHWeapon.AtkType,Y
	STA $11			;attack type
	LDX #!LHWeapon          
	STX $14                 ;weapon info pointer	
	LDA #$80              	
	STA $16                	;flag for hand anim
	STZ $17                 ;no extra attacks

	;check if this weapon has twin lance command
	LDA LHWeapon.Properties,Y
	AND #$02		;command instead of attack
	BEQ .LaunchLH
	LDA LHWeapon.Param3,Y
	CMP #$55		;this command (double lance)
	BNE .LaunchLH
	INC $17			;1 more attack
	LDA ActionAnimShift	
	ORA #$40		
	STA ActionAnimShift	;flag for later anim manipulation			
	
.LaunchLH
	JMP SimpleOneHand

.Ret	RTS
	


endif