includeonce

%subdef(ClearMem)
-	STZ $0000,X
	INX
	DEY
	BNE -
	RTS

