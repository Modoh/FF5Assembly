includeonce

;Routine to access multi-byte bitfields
;outputs:
;X: byte offset
;Y: bit offset within byte
;replaces a much longer repeated shift pattern used in multiple places
%subdef(CalcBitfieldIndexes)
	PHA
	LSR
	LSR
	LSR
	TAX		;input/8 (byte offset)
	PLA
	AND #$07	;low 3 bits (bit offset)
	TAY
	RTS