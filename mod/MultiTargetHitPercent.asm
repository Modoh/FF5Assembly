if !_Optimize

incsrc "utility/CountTargetBits.asm"

;Multitargetting effect on Hit%
;
;**optimize: use util routine
%subdef(MultiTargetHitPercent)
	LDA AttackerOffset2							;C2/7CC3: A5 39        LDA $39
	TAX 									;C2/7CC5: AA           TAX 
	LDA AttackInfo.Targetting,X 						;C2/7CC6: BD FC 79     LDA $79FC,X   
	AND #$40    		;hits all					;C2/7CC9: 29 40        AND #$40     (If attacker's spell is auto Multitargettable)
	BNE .Return								;C2/7CCB: D0 2E        BNE $7CFB

	JSR CountTargetBits

	DEX 									;C2/7CF0: CA           DEX 
	BEQ .Return		;if only one target				;C2/7CF1: F0 08        BEQ $7CFB
	LSR HitPercent     							;C2/7CF3: 46 4E        LSR $4E       (Hit = Hit% / 2)
	LDA HitPercent								;C2/7CF5: A5 4E        LDA $4E
	BNE .Return								;C2/7CF7: D0 02        BNE $7CFB
	INC HitPercent     							;C2/7CF9: E6 4E        INC $4E       (Minimum Hit = 1)
.Return	RTS 									;C2/7CFB: 60           RTS 

endif