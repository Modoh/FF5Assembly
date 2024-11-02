includeonce

;Routines to creates an animation commands

%subdef(GFXCmdMagicAnim)
	LDX #$0007
;	BRA GFXCmdAnim	;this or JMP if these are separated

;creates Action $00,FC,<X>,<A>,00
%subdef(GFXCmdAnim)
	PHA
 	TXA
	PHA	
	JSR FindOpenGFXQueueSlot				  
	STZ GFXQueue.Flag,X					
	LDA #$FC	;exec graphics command			
	STA GFXQueue.Cmd,X					
	PLA	
	STA GFXQueue.Type,X					
	PLA 							
	STA GFXQueue.Data1,X					
	STZ GFXQueue.Data2,X 					  
	RTS 							
