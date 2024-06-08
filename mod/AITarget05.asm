includeonce

if !_Optimize

;AITarget05 through 0C (target monsters 1-8)
;target monsters for AI routines
;saves 67 bytes vs the original 8 routines
;does execute slower than the originals, but not slower than other AI target routines
;X is $FFFF (-1) when called
AITarget0C:	;11
	INX
AITarget0B:	;10
	INX
AITarget0A:	;9
	INX
AITarget09:	;8
	INX
AITarget08:	;7
	INX
AITarget07:	;6
	INX
AITarget06:	;5
	INX
AITarget05:	;4							;C2/2CF2: AD C6 3E     LDA $3EC6
	TXA                                                             ;C2/2CF5: F0 06        BEQ $2CFD
	CLC                                                             ;C2/2CF7: A2 00 02     LDX #$0200
	ADC #$05                                                        ;C2/2CFA: 8E 20 26     STX $2620
	TAX                                                             ;C2/2CFD: 60           RTS 
									;followed by 7 near-identical routines, 96 total bytes
	LDA ActiveParticipants,X
	BEQ .Ret
	REP #$20
	TXA
	JSR ShiftMultiply_128
	STA AITargetOffsets
	TDC
	SEP #$20
.Ret	RTS
;total 30 bytes

endif
