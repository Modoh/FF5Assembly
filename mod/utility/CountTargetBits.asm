includeonce

;returns X = number of targets in TargetBitmask
%subdef(CountTargetBits)
	LDA MultiCommand							
	ASL 									
	TAX 									
	LDA TargetBitmask,X							
	AND #$F0								
	BNE +			;party targetted				
	LDA TargetBitmask,X							
	AND #$0F								
	
	STA $0E
	LDA TargetBitmask+1,X
	AND #$F0
	ORA $0E		;A now has a number of bits set equal to number of monsters targetted
				;in a strange order, but order doesn't matter when we're just counting
	
+	JSR CountSetBits	;result in X	
	RTS
