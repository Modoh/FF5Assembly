if !_Optimize 

incsrc "mod/utility/ShiftDivide32b.asm"

;Gravity Attack Damage, Type 07h
;Damage is Param2($58) * Current HP of target / 16 unless target is Heavy

;optimized: 	used utility routine to divide 32 bit number
GravityDamage:
	LDX TargetOffset							;C2/8874: A6 49        LDX $49
	LDA CharStruct.CreatureType,X						;C2/8876: BD 65 20     LDA $2065,X
	AND #$20    			;heavy					;C2/8879: 29 20        AND #$20     	(Target Creature Type = Heavy?)
	BEQ .NotHeavy								;C2/887B: F0 09        BEQ $8886
	TDC 									;C2/887D: 7B           TDC 
	TAX 									;C2/887E: AA           TAX 
	STX BaseDamage   							;C2/887F: 8E 69 7B     STX $7B69    	(Final Damage = 0)
	STX DamageToTarget							;C2/8882: 8E 6D 7B     STX $7B6D
	RTS 									;C2/8885: 60           RTS 
.NotHeavy									;
	LDA CharStruct.CurHP,X							;C2/8886: BD 06 20     LDA $2006,X
	STA $2A									;C2/8889: 85 2A        STA $2A
	LDA CharStruct.CurHP+1,X 						;C2/888B: BD 07 20     LDA $2007,X  	(target current HP)
	STA $2B									;C2/888E: 85 2B        STA $2B
	LDA Param2						 		;C2/8890: A5 58        LDA $58		Param 2 (fraction numerator)
	TAX 									;C2/8892: AA           TAX 
	STX $2C									;C2/8893: 86 2C        STX $2C		
	JSR Multiply_16bit		;Multiply $2A by $2C and store in $2E	;C2/8895: 20 D2 00     JSR $00D2		Multiply $2A by $2C and store in $2E.
	REP #$20								;C2/8898: C2 20        REP #$20
	JSR ShiftDivide32b_16		;divide 32 bit result by 16		;C2/889A: 46 30        LSR $30		;shifts perform division by 16 on 32 bit number
	SEP #$20								;C2/88AA: E2 20        SEP #$20
	LDX $30									;C2/88AC: A6 30        LDX $30		
	BNE +									;C2/88AE: D0 07        BNE $88B7		;if the result is still >65535 cap it
	LDX $2E									;C2/88B0: A6 2E        LDX $2E
	CPX #$270F								;C2/88B2: E0 0F 27     CPX #$270F	
	BCC ++									;C2/88B5: 90 03        BCC $88BA		;if result >9999 cap it
+	LDX #$270F  			;9999 if result was greater		;C2/88B7: A2 0F 27     LDX #$270F   	(Max Damage = 9999)
++	STX BaseDamage								;C2/88BA: 8E 69 7B     STX $7B69
	STX DamageToTarget							;C2/88BD: 8E 6D 7B     STX $7B6D
	RTS 									;C2/88C0: 60           RTS 


endif