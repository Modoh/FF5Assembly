if !_Optimize

;Check for Critical Hit
;Param1: Crit%
;**optimize: 	don't switch modes, use inc on Crit flag
%subdef(CheckCrit)
	LDA MagicSword	;no crits with magic sword, 			
	BNE .Ret	;in vanilla FF5 no weapons support both anyway	
			
	JSR Random_0_99							
	CMP Param1  							
	BCS .Ret							
	INC Crit							
	ASL Attack							
	ROL Attack+1
	TDC 								
	TAX 								
	STX Defense  							
.Ret	RTS 									

endif