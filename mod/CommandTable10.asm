
;**optimize: uses SandwormBattle instead of checking encounter
if !_Optimize

%subdef(CommandTable10)
	LDX AttackerOffset						
	LDA CharStruct.SelectedItem,X					
	BPL .Weapon		;otherwise, a scroll			
	TDC 								
	TAX 								
	STZ $0E			;target bits				

.TargetActiveMonsters
	LDA ActiveParticipants+4,X					
	BEQ .Next							
	LDA $0E								
	JSR SetBit_X  		;add as target if active		
	STA $0E								
.Next	INX 								
	CPX #$0008		;8 monsters				
	BNE .TargetActiveMonsters					

	LDX AttackerOffset						

	LDA SandwormBattle						;opt: this is the changed section
	BEQ +								;
	LDA #$FD							;
+	DEC			;$FC for sandworm, $FF otherwise	;
	AND $0E			;exclude "real" sandworm 		;

	STA CharStruct.MonsterTargets,X					
.ItemFlag
	LDA #$40		;item 					
	STA CharStruct.ActionFlag,X					
	JMP ItemCommand							
.Weapon
	LDA #$11		;throw ability				
	JSR CopyAbilityInfo						
	JSR GetTargets							
	JSR CheckRetarget   						
	JSR BuildTargetBitmask						
	LDA #$11		;ability name				
	JSR GFXCmdAttackNameA						
	LDA #$10		;ability anim				
	JSR GFXCmdAbilityAnim  						
	JSR MagicAtkTypeSingleTarget					
	JSR FinishCommand						
	JMP GFXCmdDamageNumbers						

endif