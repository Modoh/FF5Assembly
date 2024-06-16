if !_Optimize


;Check Creature Type for Critical Hit
;Param1: Creature Type
;**optimize: 	don't switch modes, use inc on Crit flag
%subdef(CheckCreatureCrit)
	LDX TargetOffset						
	LDA CharStruct.CreatureType,X					
	AND Param1    							
	BEQ .Ret							
	INC Crit							
	ASL M    							
	ROL M+1
	TDC 								
	TAX 								
	STX Defense    							
.Ret	RTS 									

endif