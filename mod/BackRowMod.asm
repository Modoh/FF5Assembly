if !_Optimize

;Back Row Modifications
;**optimize: save some bytes by shifting in 8 bit mode to avoid mode switches
%subdef(BackRowMod)
	LDX AttackerOffset						;C2/839B: A6 32        LDX $32
	LDA CharStruct.CmdStatus,X					;C2/839D: BD 1E 20     LDA $201E,X
	AND #$10   							;C2/83A0: 29 10        AND #$10     (Check if Attacker is Jumping)
	BNE .Return							;C2/83A2: D0 18        BNE $83BC
	LDA CharStruct.CharRow,X					;C2/83A4: BD 00 20     LDA $2000,X  (Check if Attack is in Back Row)
	BPL +								;C2/83A7: 10 06        BPL $83AF
	LSR M+1
	ROR M    							;C2/83AB: 46 52        LSR $52      (M = M/2)

+	LDX TargetOffset						;C2/83AF: A6 49        LDX $49
	LDA CharStruct.CharRow,X					;C2/83B1: BD 00 20     LDA $2000,X  (Check if Target is in Back Row)
	BPL .Return							;C2/83B4: 10 06        BPL $83BC
	LSR M+1
	ROR M    							;C2/83B8: 46 52        LSR $52      (M = M/2)
.Return
	RTS								;C2/83BC: 60           RTS


endif