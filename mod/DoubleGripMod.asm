if !_Optimize


;Double Grip Damage Multiplier Modifier
;**optimize: save some bytes by shifting in 8 bit mode to avoid mode switches
DoubleGripMod:
	LDX AttackerOffset						;C2/8430: A6 32        LDX $32
	LDA CharStruct.Passives2,X					;C2/8432: BD 21 20     LDA $2021,X
	AND #$20    				;Double Grip		;C2/8435: 29 20        AND #$20     (Attacker has Double Grip Ability)
	BEQ .Ret							;C2/8437: F0 18        BEQ $8451
	LDA CharStruct.RHShield,X					;C2/8439: BD 11 20     LDA $2011,X
	ORA CharStruct.LHShield,X					;C2/843C: 1D 12 20     ORA $2012,X  (No Bonus if Shield Equipped in either hand)
	BNE .Ret							;C2/843F: D0 10        BNE $8451
	LDA CharStruct.RHWeapon,X					;C2/8441: BD 13 20     LDA $2013,X
	BEQ .EmptyHand							;C2/8444: F0 05        BEQ $844B
	LDA CharStruct.LHWeapon,X 					;C2/8446: BD 14 20     LDA $2014,X  (No Bonus if two Weapons equipped)
	BNE .Ret							;C2/8449: D0 06        BNE $8451
.EmptyHand
	ASL M     							;C2/844D: 06 52        ASL $52      (M = M * 2)
	ROL M+1
.Ret	RTS 								;C2/8451: 60           RTS 


endif