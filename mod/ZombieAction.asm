if !_Optimize

incsrc mod/utility/SetupUncontrolledFight.asm

;optimization: use utility routine to clear second action fields

;Param X = Char Offset, $3D = Char index
;sets up a fight command targetting a random party member
ZombieAction:
	PHX
	JSR SetupUncontrolledFight					;*C2/1E2F: A9 80        LDA #$80
									;*C2/1E31: 9D 56 20     STA $2056,X     
									;*C2/1E34: A9 05        LDA #$05
									;*C2/1E36: 9D 57 20     STA $2057,X     
									;*C2/1E39: 9E 58 20     STZ $2058,X
									;*C2/1E3C: 9E 5A 20     STZ $205A,X
									;*C2/1E3F: 9E 5B 20     STZ $205B,X
									;*C2/1E42: 9E 5C 20     STZ $205C,X
									;*C2/1E45: 9E 5D 20     STZ $205D,X
									;*C2/1E48: 9E 5E 20     STZ $205E,X
									;*C2/1E4B: 9E 5F 20     STZ $205F,X
									;*C2/1E4E: DA           PHX 
	TDC 								;C2/1E4F: 7B           TDC 
	TAX 								;C2/1E50: AA           TAX 
	LDA #$03							;C2/1E51: A9 03        LDA #$03
	JSR Random_X_A  ;0..3						;C2/1E53: 20 7C 00     JSR $007C       
	TAX 								;C2/1E56: AA           TAX 
	TDC 								;C2/1E57: 7B           TDC 
	JSR SetBit_X  							;C2/1E58: 20 D6 01     JSR $01D6       
	PLX 								;C2/1E5B: FA           PLX 
	STA CharStruct.PartyTargets,X	;fight random party member	;C2/1E5C: 9D 59 20     STA $2059,X     
	JMP QueueUncontrolledAction					;C2/1E5F: 4C B3 1F     JMP $1FB3
	
endif
