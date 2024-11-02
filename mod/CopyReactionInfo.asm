if !_Optimize

;Copies information about the last attack to the character structure
;for use for reactions afterward
;there's only space for the first 2 actions to be countered

;**optimize: used a loop for first case, 16 bit copies for second
%subdef(CopyReactionInfo)
	LDX TargetOffset							;C2/9885: A6 49        LDX $49
	TDC
	TAY
	LDA MultiCommand							;C2/9887: AD 2C 7B     LDA $7B2C
	BNE .CopyReaction2							;C2/988A: D0 2C        BNE $98B8

.CopyReaction1
;reaction1 is contiguous, can just use a loop to copy it
	LDA CurrentCommand.ID,Y
	STA CharStruct.Reaction1Command,X
	INY
	INX
	CPY #$0007
	BCC .CopyReaction1
	RTS
	
.CopyReaction2
;we can't use a loop because reaction2 is split up in CharStruct
;using some 16 bit copies instead
	REP #$20
	LDA CurrentCommand.Element						;C2/98CA: AD 49 47     LDA $4749
	STA CharStruct.Reaction2Element,X					;C2/98CD: 9D 7B 20     STA $207B,X
;	LDA CurrentCommand.Category		;copied by above		;C2/98D0: AD 4A 47     LDA $474A
;	STA CharStruct.Reaction2Category,X					;C2/98D3: 9D 7C 20     STA $207C,X
	LDA CurrentCommand.Targets						;C2/98D6: AD 4B 47     LDA $474B
	STA CharStruct.Reaction2Targets,X					;C2/98D9: 9D 7D 20     STA $207D,X
;	LDA CurrentCommand.Damage		;copied by above		;C2/98DC: AD 4C 47     LDA $474C
;	STA CharStruct.Reaction2Damage,X					;C2/98DF: 9D 7E 20     STA $207E,X

	LDA CurrentCommand.ID							;C2/98B8: AD 46 47     LDA $4746
	STA CharStruct.Reaction2Command,X					;C2/98BB: 9D 4D 20     STA $204D,X
;	LDA CurrentCommand.Magic		;copied by above		;C2/98BE: AD 47 47     LDA $4747
;	STA CharStruct.Reaction2Magic,X						;C2/98C1: 9D 4E 20     STA $204E,X
	TDC
	SEP #$20
	LDA CurrentCommand.Item							;C2/98C4: AD 48 47     LDA $4748
	STA CharStruct.Reaction2Item,X						;C2/98C7: 9D 4F 20     STA $204F,X

.Ret	RTS 									;C2/98E2: 60           RTS 

endif