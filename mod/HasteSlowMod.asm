if !_Optimize

;Haste or Slow Modifier
;(A=A/2 if Haste, A=A*2 if Slow, Min 1, Max 255)
;**opt: only load status once, take advantage of haste/slow being exclusive
%subdef(HasteSlowMod)
	PHA 								;C2/6163: 48           PHA 
	LDA CharStruct.Status3,X					;C2/6164: BD 1C 20     LDA $201C,X
	ORA CharStruct.AlwaysStatus3,X					;C2/6167: 1D 72 20     ORA $2072,X
	AND #$0C	;haste or slow
	BEQ .None	;neither, so exit
	AND #$08   	;haste						;C2/616A: 29 08        AND #$08     
	BEQ .Slow							;C2/616C: F0 06        BEQ $6174
	PLA 								;C2/616E: 68           PLA 
	LSR        	;half duration					;C2/616F: 4A           LSR          
	BNE .Ret							;C2/6170: D0 01        BNE $6173
	INC        	;min 1						;C2/6172: 1A           INC          
.Ret	RTS

.Slow			;wasn't haste, must be slow
	PLA 								;C2/617E: 68           PLA 
	ASL        	;double duration				;C2/617F: 0A           ASL          
	BCC .Ret2							;C2/6180: 90 02        BCC $6184
	LDA #$FF   	;max 255					;C2/6182: A9 FF        LDA #$FF     
.Ret2	RTS

.None
	PLA		
	RTS
	
endif