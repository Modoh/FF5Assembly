includeonce

%subdef(RandomTarget)	
;sets up CharStruct.MonsterTargets/PartyTargets using defaults for a given targetting byte
;hits the appropriate side, and either a random target or all targets 
;doesn't support roulette bit

;params: 	A = Targetting byte
;		X = Char Offset (maintained at end)
;temps: $0F
	PHX			;char offset
	STA $0F			;targetting byte
	BIT #$40		;hits all bit
	BEQ .SingleTarget
	BIT #$08		;targets enemy bit
	BEQ .ApplyAllParty
	BRA .ApplyAllMonster

.SingleTarget
	TDC
	TAX
	LDA #$07
	JSR Random_X_A		;0..7
	TAX
	TDC
	JSR SetBit_X		
	TAY			;random bit is set
	LDA $0F			;targetting byte
	BIT #$08
	BEQ .RandomParty	
	TYA
	BRA .ApplyMonster	;byte is already set up for random monster so just apply it
	
.RandomParty			;need to fix up result to make sure a valid party member is set
	TYA
	AND #$F0		
	BNE .ApplyParty		;valid bit was already set, apply it
	TYA
	JSR ShiftMultiply_16	;shift the lower 4 bits into upper 4
	BRA .ApplyParty
	
.ApplyAllParty
	LDA #$F0		;all party
.ApplyParty
	PLX
	STA CharStruct.PartyTargets,X
	STZ CharStruct.MonsterTargets,X
	RTS

.ApplyAllMonster
	LDA #$FF		;all monsters
.ApplyMonster
	PLX 
	STA CharStruct.MonsterTargets,X
	STZ CharStruct.PartyTargets,X
	RTS
