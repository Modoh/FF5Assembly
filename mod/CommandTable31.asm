if !_Optimize		;**optimize: use shorter instructions to save space

;Command $53
;Handles weapons that cast effect spells
;Wind Slash by default, but can be called mid-routine for other effects like Earthquake
%subdef(CommandTable31)
	LDA #$4B	;wind slash spell effect			
	STA TempEffect							
%subdef(WeaponEffectCommand)	;called here for other weapon effects
	STZ $0E		;hand						
	STZ NextGFXQueueSlot						
	LDX AttackerOffset      					   
	LDA CharStruct.RHWeapon,X					
	BNE +								
	LDA #$80	;left hand					
	STA $0E								
+	JSR FindOpenGFXQueueSlot   					   
	STZ GFXQueue.Flag						
	LDA #$FC	;exec graphics command				
	STA GFXQueue.Cmd						
	LDA #$01	;ability/command anim				
	STA GFXQueue.Type						
	LDA #$04	;fight						
	STA GFXQueue.Data1						
	LDA $0E		;hand (0 for RH, 80 for LH)			
	STA GFXQueue.Data2						
	LDA #$7E	;always miss					
	STA AtkType							
	STZ MultiTarget							
	STZ TargetType							
	STZ CommandTargetBitmask					
	STZ CommandTargetBitmask+1					
	INC ProcSequence						
	JSR GFXCmdDamageNumbers						
	LDA #$FF							

	STA MonsterTargets						;opt: saves 2 bytes by using 1 byte address for these
        STZ PartyTargets						;

	LDA TempEffect							
	STA TempSpell							
	LDA #$01							
	STA TempIsEffect						
	STA TempSkipNaming						
	STZ TempAttachedSpell						
	JSR CastSpell							
	LDX AttackerOffset						   
	LDA CharStruct.Command,X					
	CMP #$0C	;capture/mug					
	BNE .Ret	;removes return address from stack for capture	
	PLX 		;likely unreachable since capture cancels procs	
.Ret	RTS 								

endif