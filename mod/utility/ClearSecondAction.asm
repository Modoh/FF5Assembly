includeonce

ClearSecondAction:
	;Replaces this code, used in multple places:
	;STZ CharStruct.SecondActionFlag,X	
        ;STZ CharStruct.SecondCommand,X		
        ;STZ CharStruct.SecondMonsterTargets,X	
        ;STZ CharStruct.SecondPartyTargets,X	
        ;STZ CharStruct.SecondSelectedItem,X


	;loop clears $205B-205F
	;loop version overwrites X and Y, but that's not an issue for where it's used
	LDY #$0004						
-	STZ CharStruct.SecondActionFlag,X	
	INX					
	DEY 					
	BPL -					
	
	RTS

