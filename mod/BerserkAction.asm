if !_BerserkerCommands
;todo/notes: 	DispatchCommand doesn't save berserker actions for mimic, which is fine I guess
;		May need to adjust for focus/jump/other delayed actions? (in PerformAction?)
;			should work as-is, but their special berserk atb will progress while waiting for their attack
;			might break things if their berserk atb becomes ready before attack lands?

incsrc "utility/RandomTarget.asm"
incsrc "utility/ClearSecondAction.asm"
%subdef(BerserkAction)
;Param X and $3F = Char Offset, $3D = Char index
;sets up a randomly chosen command with its default targetting
	PHX
	JSR PickBerserkCommand
	STA $0E					;chosen command

	JSR ShiftMultiply_8
	TAX
	LDA ROMAbilityInfo.Targetting,X
	PLX
	JSR RandomTarget
	LDA #$80				;physical/other, may need to adjust this if anything magic is allowed
	STA CharStruct.ActionFlag,X
	LDA $0E					;chosen command
	STA CharStruct.Command,X
	JSR ClearSecondAction
	
	JMP QueueUncontrolledAction					;C2/1FB0: 4C B3 1F     JMP $1FB3


incsrc "utility/CalcBitfieldIndexes.asm"
%subdef(PickBerserkCommand)
;params: $3F = char offset
;temps: $0E-$17
;returns command to use for berserk in A

	TDC
	TAX
	STX $0E					;loop index

	;pick random command index to use
	LDA #$03
	JSR Random_X_A
	TAX
	STX $16					;selected command index
	
.ValidateCommands
	LDX $3F					;char offset
	LDA CharStruct.BattleCommands,X
	STA $10					;command to check
	JSR CalcBitfieldIndexes			;X = byte offset, Y = bit offset
	CPX #$0006
	BCS .FightInstead			;everything past the end of the table is invalid
	TDC
	ORA ROMBitSet,Y				
	AND ROMBerserkCommands,X		;check if ability is allowed
	BNE .CheckDupe

.FightInstead						
	LDA #$05				;override command to fight
	STA $10

.CheckDupe					;check if command was already in the list
	TDC
	TAX
.DupeLoop
	CPX $0E					;check until we reach current main loop index
	BCC .DupeOK				
	LDA $12,X
	INX					
	CMP $10
	BNE .DupeLoop
	LDA #$05				;duplicate, override to fight
	STA $10
	BRA .DupeLoop
	
.DupeOK	LDA $10
	LDY $0E					;loop index
	CPY $16					;picked random command
	BCS .Ret				;no further processing needed, return with chosen command
	
	STA $12,Y				;save command to list
	INY
	STY $0E
	BRA .ValidateCommands			;don't need a loop condition because it'll bail out when it gets to the chosen command
	
.Ret	RTS
	
ROMBerserkCommands:
;hardcoded bitfield of valid commands
;should probably be in a data bank but here works for now
;currently excludes anything magical, flee-related, or needing a menu selection
;   0                   1                   2          
;   01234567  89ABCDEF  01234567  89ABCDEF  01234567  89ABCDEF
db %00000111,%11011110,%10111111,%00000000,%00000000,%01110000


elseif !_Optimize
incsrc "utility/SetupUncontrolledFight.asm"
;optimization: use utility routine to clear second action fields

;Param X and $3F = Char Offset, $3D = Char index
;sets up a fight command targetting a random monster
%subdef(BerserkAction)
	PHX
	JSR SetupUncontrolledFight					;*C2/1F80: A9 80        LDA #$80
									;*C2/1F82: 9D 56 20     STA $2056,X
									;*C2/1F85: A9 05        LDA #$05
									;*C2/1F87: 9D 57 20     STA $2057,X
									;*C2/1F8A: 9E 59 20     STZ $2059,X
									;*C2/1F8D: 9E 5A 20     STZ $205A,X
									;*C2/1F90: 9E 5B 20     STZ $205B,X
									;*C2/1F93: 9E 5C 20     STZ $205C,X
									;*C2/1F96: 9E 5D 20     STZ $205D,X
									;*C2/1F99: 9E 5E 20     STZ $205E,X
									;*C2/1F9C: 9E 5F 20     STZ $205F,X
									;*C2/1F9F: DA           PHX 
	TDC 								;C2/1FA0: 7B           TDC 
	TAX 								;C2/1FA1: AA           TAX 
	LDA #$07							;C2/1FA2: A9 07        LDA #$07
	JSR Random_X_A	;0..7 random monster				;C2/1FA4: 20 7C 00     JSR $007C       
	TAX 								;C2/1FA7: AA           TAX 
	TDC 								;C2/1FA8: 7B           TDC 
	JSR SetBit_X   							;C2/1FA9: 20 D6 01     JSR $01D6       
	PLX 								;C2/1FAC: FA           PLX 
	STA CharStruct.MonsterTargets,X					;C2/1FAD: 9D 58 20     STA $2058,X
	JMP QueueUncontrolledAction					;C2/1FB0: 4C B3 1F     JMP $1FB3
	
endif
