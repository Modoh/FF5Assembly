if !_Optimize

incsrc mod/utility/SetupUncontrolledFight.asm

;optimization: use utility routine to clear second action fields

;Param X = Char Offset, $3D = Char index
;sets up a fight command targetting a random party member
BerserkAction:
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