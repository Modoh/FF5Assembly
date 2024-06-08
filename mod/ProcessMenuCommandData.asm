if !_Optimize || !_Fixes

if !_Optimize
	incsrc "mod/utility/ClearSecondAction.asm"
endif

;copies command data from MenuData struct into CharStruct, and performs any other necessary processing
;also handles gear changes, removing control when needed, consuming items when used, and action delays

;optimizations: uses loops to clear data ranges instead of a bunch of individual instrcutions
;fixes: clears SecondPartyTargets rather than SecondMonsterTargets twice

ProcessMenuCommandData:
	LDA EncounterInfo.IntroFX					
	BPL +		;check for credits demo				
	JSR SetupCreditsDemo						

+	LDA DisplayInfo.CurrentChar  					
	STA CurrentChar							
	LDA GearChanged							
	BEQ +								
	STZ GearChanged							
	JSR ReplaceHands						
	JSR ApplyGear    						

+	LDA DisplayInfo.CurrentChar					
	JSR CalculateCharOffset						
	LDA CharStruct.Status1,X					
	AND #$C0	;dead/stone					
	BNE .ClearControl						
	LDA CharStruct.Status2,X					
	ORA CharStruct.AlwaysStatus2,X					
	AND #$78	;sleep/para/charm/berserk			
	BNE .ClearControl						
	LDA CharStruct.Status3,X					
	AND #$10	;stop						
	BNE .ClearControl						
	LDA CharStruct.Status4,X					
	AND #$80	;erased						
	BEQ +								
.ClearControl
	LDA DisplayInfo.CurrentChar					
	TAX 								
	STZ ControlTarget,X						
	BRA .ClearMenuData						

+	LDA DisplayInfo.CurrentChar					
	CMP MenuData.CurrentChar					
	BEQ +								
	LDA EncounterInfo.IntroFX					
	BMI +		;branch if credits fight			
	LDA #$0D	;C1 Routine 	 				
	JSR CallC1    							
.WaitForever
	BRA .WaitForever	;infinite loop? 			
+	LDA DisplayInfo.CurrentChar					
	TAX 								
	LDA ControlTarget,X						
	BEQ .NoControlTarget						
	TAY 								
	LDA ActiveParticipants,Y					
	BEQ .ClearMenuData						
	INC ControlCommand,X						
	SEC 								
	LDA ControlTarget,X						
	SBC #$04							
	STA $0E		;monster index of control target		
	TAY 								
	LDA DisplayInfo.CurrentChar					
	TAX 								
	CLC 								
	LDA ROMTimes20,X	;size of CharControl struct		
	ADC MenuData.SelectedItem	;action 0-3			
	TAX 								
	LDA CharControl.Actions,X  					
	STA MonsterControlActions,Y					
	SEC 								
	LDA $0E								
	ASL 								
	TAX 								
	LDA MenuData.PartyTargets					
	STA ForcedTarget.Party,X					
	LDA MenuData.MonsterTargets					
	STA ForcedTarget.Monster,X					

.ClearMenuData
        LDA #$80                                                        
        STA MenuData.ActionFlag                                         
if !_Optimize	;opt: use loop to save space, does clear a few extra unused bytes
        LDX #$000B
-	STZ MenuData.Command,X  
	DEX			
	BPL -			
else	
        STZ MenuData.Command                                           
        STZ MenuData.MonsterTargets                                    
        STZ MenuData.PartyTargets                                      
        STZ MenuData.SelectedItem                                      
        STZ MenuData.SecondActionFlag                                  
        STZ MenuData.SecondCommand                                     
        STZ MenuData.SecondMonsterTargets                              
        STZ MenuData.SecondPartyTargets                                
        STZ MenuData.SecondSelectedItem                                
endif
        BRA .CopyCommands                                              

.NoControlTarget
	LDA ControllingB						
	BNE .ClearMenuData	;controlling with no target		

.CopyCommands
	LDA DisplayInfo.CurrentChar					
	TAX 								
	STX $2A								
	LDX #$028A   	;650, size of CharSpells struct			
	STX $2C								
	JSR Multiply_16bit	;not using the rom *650 table?		
	REP #$20							
	CLC 								
	LDA $2E		;CurrentChar * 650				
	ADC #$2D34   	;CharSpells struct location			
	STA TempSpellOffset						
	TDC 								
	SEP #$20							
	LDX AttackerOffset   						
	LDA CharStruct.Status2,X					
	ORA CharStruct.AlwaysStatus2,X					
	AND #$18	;charm/berserk					
	BNE .CheckCommand						
	LDA MenuData.Command						
	STA CharStruct.Command,X					
	LDA MenuData.MonsterTargets					
	STA CharStruct.MonsterTargets,X					
	LDA MenuData.PartyTargets					
	STA CharStruct.PartyTargets,X					
	LDA MenuData.SelectedItem					
	STA CharStruct.SelectedItem,X					
	LDA MenuData.ActionFlag						
	STA CharStruct.ActionFlag,X					
	AND #$20	;magic						
	BEQ .NotXMagic							
	LDA MenuData.SelectedItem					
	TAY 								
	LDA (TempSpellOffset),Y						
	STA CharStruct.SelectedItem,X					
	LDA MenuData.ActionFlag						
	AND #$08	;x-magic					
	BEQ .NotXMagic							
	LDA MenuData.SecondCommand					
	STA CharStruct.SecondCommand,X					
	LDA MenuData.SecondMonsterTargets				
	STA CharStruct.SecondMonsterTargets,X				
	LDA MenuData.SecondPartyTargets					
	STA CharStruct.SecondPartyTargets,X				
	LDA MenuData.SecondSelectedItem					
	TAY 								
	LDA (TempSpellOffset),Y						
	STA CharStruct.SecondSelectedItem,X				
	LDA MenuData.SecondActionFlag					
	STA CharStruct.SecondActionFlag,X				
	BRA .CheckCommand						
.NotXMagic
if !_Optimize
	JSR ClearSecondAction
else
	STZ CharStruct.SecondCommand,X					
	STZ CharStruct.SecondMonsterTargets,X				
	if !_Fixes		;clear party targets instead of monster targets twice
		STZ CharStruct.SecondPartyTargets,X
	else	
		STZ CharStruct.SecondMonsterTargets,X				
	endif
	STZ CharStruct.SecondSelectedItem,X				
	STZ CharStruct.SecondActionFlag,X				
endif 

.CheckCommand
	LDA MenuData.Command						
	STA $24								
	LDA #$08							
	STA $25								
	JSR Multiply_8bit    						
	LDX $26		;command * 8 					
	LDY AttackerOffset      					
	LDA ROMAbilityInfo.CmdStatus,X					
	STA CharStruct.CmdStatus,Y					
	LDA ROMAbilityInfo.DamageMod,X					
	STA CharStruct.DamageMod,Y					
	LDA MenuData.Command						
	CMP #$2C	;first magic command				
	BCC .NotMagicCommand    					
	CMP #$4E	;after last magic command			
	BCS .NotMagicCommand						
	LDA CharStruct.ActionFlag,Y					
	ORA #$01     	;costs MP					
	STA CharStruct.ActionFlag,Y					
.NotMagicCommand
	LDA MenuData.Command						
	TAX 								
	LDA ROMCommandDelay,X						
	BMI .CalculateDelay						
	PHA 								
	LDA MenuData.Command						
	CMP #$11	;throw						
	BEQ .Item							
	CMP #$20	;drink						
	BEQ .Item							
	CMP #$1F	;mix						
	BNE .NotItem							
.Mix	
	LDA MenuData.SecondSelectedItem					
	PHA 								
	TAX 								
	LDA InventoryItems,X						
	LDX AttackerOffset						
	STA CharStruct.SecondSelectedItem,X				
	PLA 								
	JSR ConsumeItem							
.Item
	LDA MenuData.SelectedItem					
	PHA 								
	TAX 								
	LDA InventoryItems,X						
	LDX AttackerOffset						
	STA CharStruct.SelectedItem,X					
	PLA 								
	JSR ConsumeItem							
.NotItem
	PLA 								
	JMP .Finish							

.CalculateDelay	
	LDA MenuData.ActionFlag						
	AND #$08	;XMagic						
	BEQ +								
	JMP .MagicDelay							
+	LDA MenuData.ActionFlag						
	AND #$40	;Item						
	BNE .ItemDelay							
	LDA MenuData.ActionFlag						
	AND #$20	;Magic						
	BEQ +								
	JMP .MagicDelay							
+	LDA MenuData.ActionFlag						
	AND #$10	;Weapon used as item				
	BEQ .WeaponAttackDelay						
	JMP .WeaponUseDelay						

.WeaponAttackDelay	;despite the calculation, I don't think any weapons have delay values
	STZ $0E								
	LDA DisplayInfo.CurrentChar					
	STA $24								
	LDA #$54     ;84, size of GearStats struct			
	STA $25								
	JSR Multiply_8bit						
	LDY $26								
	LDX AttackerOffset						
	LDA CharStruct.RHWeapon,X					
	BEQ +								
	LDA RHWeapon.Targetting,Y					
	AND #$03	;delay bits (delay/10)				
	TAX 								
	LDA ROMTimes10,X						
	STA $0E		;attack delay					
+	LDX AttackerOffset      					
	LDA CharStruct.LHWeapon,X					
	BEQ +								
	LDA !LHWeapon,Y							
	AND #$03	;delay bits (delay/10)				
	TAX 								
	CLC 								
	LDA ROMTimes10,X						
	ADC $0E		;add other weapon's delay			
	STA $0E								
+	LDA $0E		;attack delay					
	JMP .Finish							
.ItemDelay 
	LDA MenuData.SelectedItem					
	TAX 								
	LDA InventoryItems,X						
	LDX AttackerOffset						
	STA CharStruct.SelectedItem,X					
	SEC 								
	SBC #$E0	;consumable item offset				
	REP #$20							
	JSR ShiftMultiply_8    						
	TAX 								
	TDC 								
	SEP #$20							
	LDA ROMConsumables.Misc,X					
	AND #$08							
	BNE +								
	LDA MenuData.SelectedItem					
	JSR ConsumeItem							
+	LDA ROMConsumables.Targetting,X					
	AND #$03	;delay bits (delay/10)				
	TAX 								
	LDA ROMTimes10,X						
	BRA .Finish							
.MagicDelay	
	STZ $0E								
	LDA MenuData.SelectedItem					
	REP #$20							
	JSR ShiftMultiply_8    	  					
	TAX 								
	TDC 								
	SEP #$20							
	LDA ROMMagicInfo.Targetting,X					
	AND #$03	;delay bits (delay/10)				
	TAX 								
	LDA ROMTimes10,X						
	STA $0E		;attack delay					
	LDA MenuData.ActionFlag						
	AND #$08	;X-Magic					
	BEQ .FinishMagic						
	LDA MenuData.SecondSelectedItem					
	REP #$20							
	JSR ShiftMultiply_8   						
	TAX 								
	TDC 								
	SEP #$20							
	LDA ROMMagicInfo.Targetting,X					
	AND #$03	;delay bits (delay/10)				
	TAX 								
	CLC 								
	LDA ROMTimes10,X						
	ADC $0E		;add other spell's delay			
	STA $0E								
.FinishMagic
	LDA $0E		;attack delay					
	BRA .Finish							
.WeaponUseDelay
	LDA DisplayInfo.CurrentChar					
	STA $24								
	LDA #$54     	;84, size of GearStats struct			
	STA $25								
	JSR Multiply_8bit    						
	LDY $26								
	LDA MenuData.SelectedItem					
	BEQ +								
	REP #$20							
	TYA 								
	CLC 								
	ADC #$000C	;shifts offset from RHWeapon to LHWeapon	
	TAY 								
	TDC 								
	SEP #$20							
+	LDA RHWeapon.ItemMagic,Y	;could be LHWeapon		
	AND #$7F	;weapon magic to cast				
	BEQ .Finish							
	REP #$20							
	JSR ShiftMultiply_8    						
	TAX 								
	TDC 								
	SEP #$20							
	LDA ROMMagicInfo.Targetting,X					
	AND #$03	;delay bits (delay/10)				
	TAX 								
	LDA ROMTimes10,X						
.Finish		
	PHA 								
	LDA DisplayInfo.CurrentChar					
	JSR GetTimerOffset	;Y and $36 = timer offset  		
	LDX AttackerOffset						
	PLA 								
	JSR HasteSlowMod	;adjusts delay				
	STA CurrentTimer.ATB,Y	;time until action fires		
	LDA #$41		;flag indicating a queued action	
	STA EnableTimer.ATB,Y						
	LDA #$80		;physical/other				
	STA MenuData.ActionFlag						
if !_Optimize		;save space using a loop
	LDX $000B	
-	STZ MenuData.Command,X	
	DEX			
	BPL -			
else
	STZ MenuData.Command						
	STZ MenuData.CurrentChar					
	STZ MenuData.MonsterTargets					
	STZ MenuData.PartyTargets					
	STZ MenuData.SelectedItem					
	STZ MenuData.7							
	STZ MenuData.SecondActionFlag					
	STZ MenuData.SecondCommand					
	STZ MenuData.10							
	STZ MenuData.SecondMonsterTargets				
	STZ MenuData.SecondPartyTargets					
	STZ MenuData.SecondSelectedItem					
endif
	RTS 								

endif