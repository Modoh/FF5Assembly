includeonce

;32 bit division routine
;Dividend: 	$0E-11
;Divisor: 	$12-15
;Quotient: 	$16-19
;Remainder: 	$1A-1C
;copied from FF5 where it was inlined in a few routines
%subdef(Division_32bit)
	REP #$20								;C2/04A6: C2 20        REP #$20
	CLC 									;C2/04A8: 18           CLC 
	LDX #$0020								;C2/04A9: A2 20 00     LDX #$0020
-	ROL $0E									;C2/04AC: 26 0E        ROL $0E
	ROL $10									;C2/04AE: 26 10        ROL $10
	ROL $1A									;C2/04B0: 26 1A        ROL $1A
	ROL $1C									;C2/04B2: 26 1C        ROL $1C
	SEC 									;C2/04B4: 38           SEC 
	LDA $1A									;C2/04B5: A5 1A        LDA $1A
	SBC $12									;C2/04B7: E5 12        SBC $12
	STA $1A									;C2/04B9: 85 1A        STA $1A
	LDA $1C									;C2/04BB: A5 1C        LDA $1C
	SBC $14									;C2/04BD: E5 14        SBC $14
	STA $1C									;C2/04BF: 85 1C        STA $1C
	BCS +									;C2/04C1: B0 0D        BCS $04D0
	LDA $1A									;C2/04C3: A5 1A        LDA $1A
	ADC $12									;C2/04C5: 65 12        ADC $12
	STA $1A									;C2/04C7: 85 1A        STA $1A
	LDA $1C									;C2/04C9: A5 1C        LDA $1C
	ADC $14									;C2/04CB: 65 14        ADC $14
	STA $1C									;C2/04CD: 85 1C        STA $1C
	CLC 									;C2/04CF: 18           CLC 
+	ROL $16									;C2/04D0: 26 16        ROL $16
	ROL $18									;C2/04D2: 26 18        ROL $18
	DEX 									;C2/04D4: CA           DEX 
	BNE -									;C2/04D5: D0 D5        BNE $04AC
	TDC 									;C2/04D7: 7B           TDC 
	SEP #$20								;C2/04D8: E2 20        SEP #$20
	RTS
	


	