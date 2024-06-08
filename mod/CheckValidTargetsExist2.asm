if !Optimize

;Makes sure there is a valid target available

;optimize:	instead of reimplementing the same basic check, just act as a wrapper for CheckValidTargetsExist
CheckValidTargetsExist2:
	LDA $0E		;starting index param
	STA $12		
	LDA $0F		;ending index param
	INC		;the other routine wants it to be one past the valid range
	STA $13		
	JSR CheckValidTargetsExist
	STA $11		;1 if no valid targets found, 0 otherwise
	RTS
	
endif