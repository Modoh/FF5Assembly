if !_Optimize

incsrc "mod/utility/CountTargetBits.asm"

;Multitargetting Modifications
;
;**optimize: use util routine
MultiTargetMod:
	LDA AttackerOffset2						;C2/8366: A5 39        LDA $39
	TAX 								;C2/8368: AA           TAX 
	LDA AttackInfo.Targetting,X					;C2/8369: BD FC 79     LDA $79FC,X
	AND #$40   		;hits all targets			;C2/836C: 29 40        AND #$40      
	BNE .Return  							;C2/836E: D0 2A        BNE $839A    (If attacker's spell is auto Multitargettable)

	JSR CountTargetBits

	DEX 								;C2/8393: CA           DEX 
	BEQ .Return							;C2/8394: F0 04        BEQ $839A
	LSR Attack+1							;C2/8396: 46 51        LSR $51
	ROR Attack    							;C2/8398: 66 50        ROR $50      Damage = Damage / 2
.Return	RTS 								;C2/839A: 60           RTS 

endif