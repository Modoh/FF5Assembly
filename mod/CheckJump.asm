if !_Optimize

;Check for Jump
;**optimize: save some bytes by shifting in 8 bit mode to avoid mode switches, rearranged to only have one RTS

CheckJump:
	LDX AttackerOffset						
	LDA CharStruct.CmdStatus,X					
	AND #$10				;Jumping		
	BNE .Jump 							
	JMP BackRowMod				;not jumping (in game), so back row mod applies				

.Jump	ASL M    							
	ROL M+1
	RTS 								
									



endif