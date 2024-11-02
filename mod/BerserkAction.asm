if !_BerserkerCommands
;todo/notes: 	DispatchCommand doesn't save berserker actions for mimic, which is fine I guess
;		May need to adjust for focus/jump/other delayed actions? (in PerformAction?)
;			should work as-is, but their special berserk atb will progress while waiting for their attack
;			might break things if their berserk atb becomes ready before attack lands?

incsrc "utility/RandomTarget.asm"
incsrc "utility/ClearSecondAction.asm"
%subdef(BerserkAction)
;Params $3F = Char Offset, $3D = Char index
;sets up a randomly chosen command with its default targetting
	JSR PickBerserkCommand
	STA $0E					;chosen command

	JSR ShiftMultiply_8
	TAX
	LDA ROMAbilityInfo.Targetting,X
	LDX $3F					;char offset
	JSR RandomTarget			;sets CharStruct.PartyTargets and Charstruct.MonsterTargets
	LDA #$80				;physical/other, may need to adjust this if anything magic is allowed
	STA CharStruct.ActionFlag,X
	LDA $0E					;chosen command
	STA CharStruct.Command,X
	JSR ClearSecondAction
	
	JMP QueueUncontrolledAction		


incsrc "utility/CalcBitfieldIndexes.asm"
%subdef(PickBerserkCommand)
;params: $3F = char offset
;temps: $0E
;returns command to use for berserk in A

	;pick random command index to use
	TDC
	TAX
	INX
	LDA #$03
	JSR Random_X_A				;1..3
						;berserkers have 33% chance of equipped ability (if valid), otherwise fight
						;other classes have 33% for each slot
						;berserk mimes get their 3 slots but for everyone else the 3rd slot is a 33% fight
	
	;get selected command from charstruct
	REP #$21
	ADC $3F					;add selection to char offset
	TAX
	TDC
	SEP #$20					
	LDA CharStruct.BattleCommands,X
	STA $0E					;selected command

	;validate command
	JSR CalcBitfieldIndexes			;X = byte offset, Y = bit offset
	CPX #$0006
	BCS .FightInstead			;everything past the end of the table is invalid
	LDA ValidBerserkCommands,X
	TYX
	JSR SelectBit_X
	BEQ .FightInstead
	LDA $0E
	RTS
	
.FightInstead						
	LDA #$05				;override command to fight
	RTS
	
ValidBerserkCommands:
;hardcoded bitfield of valid commands
;should probably be in a data bank but here works for now
;currently excludes anything magical, flee-related, or needing a menu selection
;   0                   1                   2          
;   01234567  89ABCDEF  01234567  89ABCDEF  01234567  89ABCDEF
db %00000111,%11011110,%10111111,%00010000,%00010000,%01110000

;Command here corresponds with this bitfield:
;Command	Table
;00		00			Nothing	
;01		00			!Other	
;02		01			!Item	
;03		02			!Row	
;04		03			!Def.	
;05		04			!Fight	
;06		05			!Guard	
;07		06			!Kick	
;
;08		07			!BuildUp	
;09		08			!Mantra	
;0A		09			!Escape	
;0B		0A			!Steal	
;0C		0B			!Capture	
;0D		0C			!Jump	
;0E		0D			!DrgnSwd	
;0F		0E			!Smoke	
;
;10		0F			!Image	
;11		10			!Throw	
;12		11			!SwdSlap	
;13		12			!GilToss	
;14		13			!Slash	
;15		14			!Animals	
;16		15			!Aim	
;17		16			!X-Fight	
;
;18		17			!Conjure	
;19		18			!Observe	
;1A		19			!Analyze	
;1B		1A			!Tame	
;1C		1B			!Control	
;1D		1C			!Catch	
;1E		1D			!Release	
;1F		1E			!Combine	
;
;20		1F			!Drink	
;21		20			!Pray	
;22		21			!Revive	
;23		22			!Terrain	
;24		23			!Dummy01	
;25		24			!Hide	
;26		25			!Show	
;27		26			!Dummy02	
;
;28		27			!Sing	
;29		28			!Flirt	
;2A		29			!Dance	
;2B		2A			!Mimic	


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
