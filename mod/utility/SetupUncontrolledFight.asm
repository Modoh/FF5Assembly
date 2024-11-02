includeonce

incsrc "ClearSecondAction.asm"

;sets up the character structure fields for a fight command, for use by charm/zombie/berserk
%subdef(SetupUncontrolledFight)
	LDA #$80			
	STA CharStruct.ActionFlag,X	
	LDA #$05	;fight		
	STA CharStruct.Command,X	
	STZ CharStruct.PartyTargets,X	
	STZ CharStruct.MonsterTargets,X
	STZ CharStruct.SelectedItem,X
	JSR ClearSecondAction
	RTS
	