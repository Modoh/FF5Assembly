includeonce

;divides 32 bit numbers by powers of 2 via shifting, requires 16 bit mode
;memory where it operates are results from SNES multiplier
ShiftDivide32b:
.16	LSR $30
	ROR $2E
.8	LSR $30
	ROR $2E
.4	LSR $30
	ROR $2E
.2	LSR $30
	ROR $2E
	RTS
