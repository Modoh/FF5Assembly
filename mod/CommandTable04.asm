if !_Optimize || !_CombatTweaks

incsrc utility/GFXCmd.asm		;for GFXCmdMagicAnim utility routine

;Command $05 (Fight)
;optimizations: 
;	uses existing BuildTargetBitmask routine, rather than duplicating the code
;	saves hand-specific data to scratch ram then calls FightOneHand (a new routine), rather than near-duplicate code for each hand
;	uses 16 bit mode where applicable to save a few more bytes (in FightOneHand)
;	uses utility routines to create graphics commands (one existing, one new)
%subdef(CommandTable04)
	LDX AttackerOffset							
	LDA CharStruct.MonsterTargets,X 					
	STA MonsterTargets							
	LDA CharStruct.PartyTargets,X						
	STA PartyTargets							
	JSR CheckRetarget							
	LDX AttackerOffset							
	LDA PartyTargets							
	STA CharStruct.PartyTargets,X						
	LDA MonsterTargets							
	STA CharStruct.MonsterTargets,X						
	JSR BuildTargetBitmask						
	LDA AttackerIndex							
	TAX 									
	LDA ROMTimes84,X		;multiplies by 84			
	TAX 									
	STX $0E				;offset into character equipment	
	LDX AttackerOffset							
	LDA CharStruct.RHWeapon,X						
	BEQ .Left										

	LDA RHWeapon.Properties,X	
	STA $10				;Weapon Properties
	LDA RHWeapon.AtkType,X
	STA $11
	LDY RHWeapon.Param2,X
	STY $12				;Params 2 and 3
	LDY #!RHWeapon
	STY $14
	STZ $16				;magic sword hand bit
	JSR FightOneHand

.Left	LDX AttackerOffset
	LDA CharStruct.LHWeapon,X
	BEQ .Ret
	LDA LHWeapon.Properties,X
	STA $10
	LDA LHWeapon.AtkType,X
	STA $11
	LDY LHWeapon.Param2,X
	STY $12
	LDY #!LHWeapon
	STY $14
	LDA #$80
	STA $16
	JSR FightOneHand
.Ret	RTS

;Process one hand's attacks (for fight command)
;Params
;$0E: char equipment offset
;$10: weapon properties
;$11: weapon attack type
;$12: Weapon Param2 (proc%)
;$13: Weapon Param3 (command or magic proc)
;$14: Pointer to weapon info struct
;$16: 0 for rh, $80 for LH
%subdef(FightOneHand)
	LDA $10				;Weapon Properties			
	AND #$02			;command instead of attack		
	BEQ .NormalAttack							
	LDA CurrentlyReacting							
	BNE .NormalAttack							
	LDX AttackerOffset							
	LDA CharStruct.Status1,X						
	AND #$02      			;Zombie					
	BNE .NormalAttack							
	LDA CharStruct.Status2,X   						
	AND #$10			;Charm					
	BNE .NormalAttack							
	JSR Random_0_99								
	CMP $12				;proc chance				
	BCS .NormalAttack							
	LDA $13				;proc command				
	JMP DispatchCommand_CommandReady	;dispatch the new command	

.NormalAttack								
	JSR SelectCurrentProcSequence	;Y and $0C = AttackInfo offsets		
	TYX 				;opt: we need to swap which index registers we use because the address mode we need later is Y-only
	STZ $17									
	LDY $0E				;offset into character equipment	

.CopyAttackInfo									
	LDA ($14),Y			;weapon info (via pointer)
	STA !AttackInfo,X							
	INX 									
	INY 									
	INC $17									
	LDA $17									
	CMP #$0C			;12 byte structure size			
	BNE .CopyAttackInfo								

	LDA $10				;weapon properties
	AND #$04			;Magic Sword OK				
	BNE .MSword								
	TDC 				;no MSword effect					
	BRA .CreateGFXCmds									
								
.MSword	LDA $16
	ASL				;high bit into carry (for hand test later)
	LDX AttackerOffset							
	LDA CharStruct.MSwordAnim,X						
	AND #$7F			;clear hand bit
	BCC .CreateGFXCmds
	ORA #$80			;set hand bit if LH

.CreateGFXCmds	
	PHA 									
	LDA #$04
	JSR GFXCmdAbilityAnim		;creates gfx command $00,FC,01,04,00
	PLA 									
	STA GFXQueue.Data2,X		;replaces last param with MSword anim
	LDA ProcSequence							
	TAX 									
	LDA $11						
	STA AtkType,X								
	STZ MultiTarget,X							
	STZ TargetType,X							
	TXA
	ASL 									
	TAX 									
	REP #$20	
	LDA TempTargetBitmask							
	STA CommandTargetBitmask,X						
	TDC		
	SEP #$20	
	INC ProcSequence							
	JSR GFXCmdDamageNumbers		;creates GFX cmd $00,FC,06,00,00

if !_CombatTweaks			;begin swordslap proc
	LDA SwordSlap
	BEQ .CheckWonder
	JSR Random_0_99
	CMP #$4B			;75% chance
	BCS .CheckWonder
	LDA #$7F			;Whip paralyze spell 
					;..could also consider monster spell $BC if it works and looks ok
					;..which would make hit% vary with level difference
	STA $10				;Proc Magic
	BRA .MagicProc
endif					;end swordslap 
	
.CheckWonder
	LDA $10				;Weapon Properties			
	AND #$01			;Wonder Rod				
	BEQ .CheckMagicProc								

	CLC 									
	LDA BattleData.WonderRod						
	ADC #$12			;+18					
	STA $10				;Wonder Rod Spell + 18			
	CLC 									
	LDA BattleData.WonderRod						
	BNE +									
	INC 				;min 1 (skips scan)			
+	ADC #$01			;					
	CMP #$24			;36					
	BNE +									
	TDC 				;clear wonder rod if it got too high	
+	STA BattleData.WonderRod						
	BRA .MagicProc								

.CheckMagicProc
	LDA $10				;Weapon Properties			
	AND #$08			;Magic on hit				
	BEQ .Ret								
	JSR Random_0_99								
	CMP $12				;Proc Chance				
	BCS .Ret								
	LDA $13				;Proc Magic				
	STA $10				;Proc Magic				
								
.MagicProc
	LDY $0C				;AttackInfo offset			
	TYA 									
	CLC 									
	ADC #$0C			;+12, size of AttackInfo		
	TAY 									
	STY $0C				;next AttackInfo offset			
	LDA $10				;Proc or Wonder Magic			
	JSR CopyROMMagicInfo							
	LDA ProcSequence							
	TAX 									
	LDY $0C				;AttackInfo offset			
	LDA AttackInfo.MagicAtkType,Y						
	AND #$7F								
	STA AtkType,X								
	LDA $10				;Proc or Wonder Magic			
	JSR GFXCmdMagicAnim		;created command $00,FC,07,<Magic>,00	
	LDA ProcSequence							
	TAX 									
	STZ MultiTarget,X							
	LDA #$10								
	STA TargetType,X							
	LDA ProcSequence							
	ASL 									
	TAX
	REP #$20
	LDA TempTargetBitmask							
	STA CommandTargetBitmask,X						
	STA TargetBitmask,X							
	TDC
	SEP #$20
	INC ProcSequence							
	JSR GFXCmdDamageNumbers		;creates Action $00,FC,06,00,00		
.Ret	RTS
	
endif
