if !_Optimize
;Command modifications to damage
;**optimize: save some bytes by shifting in 8 bit mode to avoid mode switches
CommandMod:
	LDX AttackerOffset							;C2/83BD: A6 32        LDX $32
	LDA CharStruct.DamageMod,X						;C2/83BF: BD 1F 20     LDA $201F,X
	AND #$40								;C2/83C2: 29 40        AND #$40
	BEQ + 									;C2/83C4: F0 06        BEQ $83CC
	ASL Attack    								;C2/83C8: 06 50        ASL $50      (Damage = Damage * 2)
	ROL Attack+1
+
	LDA CharStruct.DamageMod,X						;C2/83CC: BD 1F 20     LDA $201F,X
	AND #$20								;C2/83CF: 29 20        AND #$20
	BEQ +									;C2/83D1: F0 07        BEQ $83DA
	REP #$20								;C2/83D3: C2 20        REP #$20
	LSR Attack+1
	ROR Attack      							;C2/83D5: 46 50        LSR $50      (Damage = Damage / 2)
+
	LDA CharStruct.DamageMod,X						;C2/83DA: BD 1F 20     LDA $201F,X
	AND #$10								;C2/83DD: 29 10        AND #$10
	BEQ +									;C2/83DF: F0 06        BEQ $83E7
	ASL M    								;C2/83E3: 06 52        ASL $52      (M = M * 2)
	ROL M+1
+
	LDA CharStruct.DamageMod,X						;C2/83E7: BD 1F 20     LDA $201F,X
	AND #$08								;C2/83EA: 29 08        AND #$08
	BEQ +									;C2/83EC: F0 07        BEQ $83F5
	LSR M+1    								;C2/83F0: 46 52        LSR $52      (M = M / 2)
	ROR M
+
	LDA CharStruct.DamageMod,X						;C2/83F5: BD 1F 20     LDA $201F,X
	AND #$04								;C2/83F8: 29 04        AND #$04
	BEQ +									;C2/83FA: F0 04        BEQ $8400
	TDC 									;C2/83FC: 7B           TDC 
	TAX 									;C2/83FD: AA           TAX 
	STX Defense   								;C2/83FE: 86 54        STX $54      (Defense = 0)
+
	LDX TargetOffset							;C2/8400: A6 49        LDX $49
	LDA CharStruct.CreatureType,X						;C2/8402: BD 65 20     LDA $2065,X  (Target Creature Type = Human?)
	BPL +									;C2/8405: 10 0F        BPL $8416
	LDX AttackerOffset							;C2/8407: A6 32        LDX $32
	LDA CharStruct.DamageMod,X						;C2/8409: BD 1F 20     LDA $201F,X
	AND #$01								;C2/840C: 29 01        AND #$01
	BEQ +									;C2/840E: F0 06        BEQ $8416
	ASL Attack    								;C2/8412: 06 50        ASL $50      (Damage = Damage * 2)
	ROL Attack+1
+
	LDX TargetOffset							;C2/8416: A6 49        LDX $49
	LDA CharStruct.CmdStatus,X						;C2/8418: BD 1E 20     LDA $201E,X
	BPL +	  				;Defending			;C2/841B: 10 07        BPL $8424    (If Target is Defending)
	LSR M+1   								;C2/841F: 46 52        LSR $52      (M = M / 2)
	ROR M
+
	LDA CharStruct.CmdStatus,X						;C2/8424: BD 1E 20     LDA $201E,X
	AND #$40				;Guarding			;C2/8427: 29 40        AND #$40
	BEQ +	  								;C2/8429: F0 04        BEQ $842F    (If Target is Guarding)
	TDC 									;C2/842B: 7B           TDC 
	TAX 									;C2/842C: AA           TAX 
	STX Attack    								;C2/842D: 86 50        STX $50      (Damage = 0)
+
	RTS 									;C2/842F: 60           RTS 




endif