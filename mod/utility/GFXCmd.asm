includeonce

;Routines to create animation commands

;GFXCommandAbilityAnim already exists in vanilla
;it creates $00,FC,01,<A>,00
;optimised version calls GFXCmdAnim with X=7

%subdef(GFXCmdMagicAnim)
	LDX #$0007
;	BRA GFXCmdAnim	;this or JMP needed if moved

%subdef(GFXCmdAnim)
;using above
	LDY #$00FC
;	JMP GFXCmdAny	;needed if moved
	
;creates Action $00,<Y>,<X>,<A>,00
%subdef(GFXCmdAny)
	PHA
 	TXA
	PHA	
	JSR FindOpenGFXQueueSlot				  
	STZ GFXQueue.Flag,X					
	TYA		
	STA GFXQueue.Cmd,X					
	PLA	
	STA GFXQueue.Type,X					
	PLA 							
	STA GFXQueue.Data1,X					
	STZ GFXQueue.Data2,X 					  
	RTS 	

%subdef(GFXCmdNullAnim)
;creates Action with all 0's (no animation)
;using the above routine is shortest, at 6 bytes
	TDC
	TAX
	TAY
	JMP GFXCmdAny

;without the Any routine routine we need 9 bytes
;	TDC
;	TAX
;	JSR GFXCmdAnim
;	STZ GFXQueue.Cmd,X
;	RTS

;loop version is 14 bytes 
;	JSR FindOpenGFXQueueSlot
;	LDY #$0004
;-	STZ !GFXQueue,X
;	INX
;	DEY
;	BPL -
;	RTS	

;directly setting all 5 bytes is 19 bytes 
;	JSR FindOpenGFXQueueSlot
;	STZ GFXQueue.Flag,X
;	STZ GFXQueue.Cmd,X
;	STZ GFXQueue.Type,X
;	STZ GFXQueue.Data1,X
;	STZ GFXQueue.Data2,X
;	RTS