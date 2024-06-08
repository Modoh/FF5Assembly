
if !_Fixes

;AI Condition $0E: Reaction to Damage
AICondition0E:
	
	LDX AttackerOffset	;fix: load X before branch instead of after
	LDA ReactionFlags						
	AND #$01	;check second set of reactions			
	BNE .Reaction2							
	LDA CharStruct.Reaction1Damage,X				;C2/2B78: BD 4C 20     LDA $204C,X
	BNE .Met							;C2/2B7B: D0 06        BNE $2B83
	RTS 								;C2/2B7D: 60           RTS 

.Reaction2		
	LDA CharStruct.Reaction2Damage,X				;C2/2B7E: BD 7E 20     LDA $207E,X
	BEQ .Fail							;C2/2B81: F0 03        BEQ $2B86
.Met	INC AIConditionMet  						;C2/2B83: EE 94 46     INC $4694      
.Fail	RTS 

endif