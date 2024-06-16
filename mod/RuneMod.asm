if !_Optimize

incsrc "utility/damageutil.asm"

;Bonus to Attack, costing MP
;optimizations: use utility routine, moved crit flag to save bytes changing modes
%subdef(RuneMod)
	LDA Param3	;MP Cost				;C2/8467: A5 59        LDA $59
	TAX 							;C2/8469: AA           TAX 
	STX $12							;C2/846A: 86 12        STX $12
	LDA Param2	;Attack Boost				;C2/846C: A5 58        LDA $58
	TAX 							;C2/846E: AA           TAX 
	STX $10							;C2/846F: 86 10        STX $10
	REP #$20						;C2/8471: C2 20        REP #$20
	LDX AttackerOffset					;C2/8473: A6 32        LDX $32
	LDA CharStruct.CurMP,X					;C2/8475: BD 0A 20     LDA $200A,X
	CMP $12							;C2/8478: C5 12        CMP $12
	BCC .Finish   	;not enough MP				;C2/847A: 90 2F        BCC $84AB    (Check if enough MP)
	SEC 							;C2/847C: 38           SEC 
	SBC $12							;C2/847D: E5 12        SBC $12
	STA CharStruct.CurMP,X					;C2/847F: 9D 0A 20     STA $200A,X  (Subtract MP)
	CLC 							;C2/8482: 18           CLC 
	LDA Attack						;C2/8483: A5 50        LDA $50
	ADC $10							;C2/8485: 65 10        ADC $10
	STA Attack     						;C2/8487: 85 50        STA $50      (Bonus to Damage)
	INC Crit	;flag for screen flash
	TDC 							;C2/8489: 7B           TDC 
	SEP #$20						;C2/848A: E2 20        SEP #$20
	LDA MagicPower 						;C2/848C: AD E5 7B     LDA $7BE5    (Level)
	JSR StatTimesLevel
	JSR ShiftDivide_128					;C2/849D: 20 BB 01     JSR $01BB    (Level * Magic Power)/128
	CLC 							;C2/84A0: 18           CLC 
	ADC M							;C2/84A1: 65 52        ADC $52
	STA M 							;C2/84A3: 85 52        STA $52      (M = M + (Level * Magic Power)/128)

.Finish	TDC 							;C2/84AB: 7B           TDC 
	SEP #$20						;C2/84AC: E2 20        SEP #$20
	RTS 							;C2/84AE: 60           RTS 



endif