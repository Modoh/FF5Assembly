if !_Optimize

WipeActionData:
	STZ TargetIndex		;opt: uses single byte instead of 2 byte address
	LDX #$0133							
-	STZ $79F9,X	;clears memory $79F9 - $7B2C			
	DEX 								
	BPL -								
	TXA 		;now $FF					
	LDX #$0010							
-	STA $7B2D,X	;sets memory $7B2D - $7B3D to $FF		
	DEX 								
	BPL -								
	TDC 								
	RTS 								

endif
