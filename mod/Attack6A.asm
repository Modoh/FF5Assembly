if !_Optimize


;Attack Type 6A (Win Battle)
%subdef(Attack6A)
if !_Optimize				;use a loop to save space
	LDX #$0007		
-	STZ ActiveParticipants+4,X 
	DEX                        
	BPL -
else	
	STZ ActiveParticipants+4	;these are the monster slots	;C2/78BC: 9C C6 3E     STZ $3EC6
	STZ ActiveParticipants+5					;C2/78BF: 9C C7 3E     STZ $3EC7
	STZ ActiveParticipants+6					;C2/78C2: 9C C8 3E     STZ $3EC8
	STZ ActiveParticipants+7					;C2/78C5: 9C C9 3E     STZ $3EC9
	STZ ActiveParticipants+8					;C2/78C8: 9C CA 3E     STZ $3ECA
	STZ ActiveParticipants+9					;C2/78CB: 9C CB 3E     STZ $3ECB
	STZ ActiveParticipants+10					;C2/78CE: 9C CC 3E     STZ $3ECC
	STZ ActiveParticipants+11					;C2/78D1: 9C CD 3E     STZ $3ECD
endif
	LDA #$80			;Enemies Dead			;C2/78D4: A9 80        LDA #$80
	STA BattleOver							;C2/78D6: 8D DE 7B     STA $7BDE
	INC UnknownReaction						;C2/78D9: EE FB 7B     INC $7BFB
	RTS 								;C2/78DC: 60           RTS 


	
endif