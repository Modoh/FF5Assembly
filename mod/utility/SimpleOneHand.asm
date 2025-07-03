includeonce

incsrc GFXCmd.asm
;for GFXCmdNullAnim

%subdef(SimpleOneHand)
;Process one hand's attacks (for simple no-proc attacks)
;Params
;$0E: char equipment offset
;$11: weapon attack type
;$14: Pointer to weapon info struct
;$16: 0 for rh, $80 for LH
;$17: number of extra attacks (twin lance)

	STZ $13			;for handling twin lance non-animation

.Start
	JSR SelectCurrentProcSequence	;sets Y to attackinfo offset			
        STZ $12
	TYX
        LDY $0E			;gearstats offset		
-       LDA ($14),Y						
        STA !AttackInfo,X					
        INX 							
        INY 							
        INC $12							
        LDA $12							
        CMP #$0C		;copy 12 bytes weapon data	
        BNE -							


	LDA $13			;check if we want an animation this time
	BEQ .Anim
	JSR GFXCmdNullAnim
	BRA .DoneAnim
	
.Anim
	LDA #$04		;fight anim
        JSR GFXCmdAbilityAnim
        LDA $16
        STA GFXQueue.Data2,X	;hand for animation

.DoneAnim
        LDA ProcSequence					
        TAX 							
        LDA $11			;attack type
        STA AtkType,X						
        STZ MultiTarget,X					
        STZ TargetType,X					
	
	JSR FinishCommand	;vanilla utility routine called at the end of most commands
				;copies temptargetbitmask to commandtargetbitmask and targetbitmask

;	replaced this with FinishCommand call
;	but that additonally sets TargetBitmask in addition to CommandTargetBitmask
;	probably ok, but unsure? leaving it commented for now.  
;       LDA ProcSequence					
;       ASL
;	TAY 
;       LDA TempTargetBitmask					
;       STA CommandTargetBitmask,Y				
;       LDA TempTargetBitmask+1					
;       STA CommandTargetBitmask+1,Y				
;       INC ProcSequence
	
	JSR GFXCmdDamageNumbers
	
	;handle twin lance extra attacks
	DEC $17			
	BMI .Ret	
	INC $13			;no animation for subsequent attacks
	BRA .Start
	
.Ret	RTS

