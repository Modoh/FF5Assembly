if !_Optimize


;Attack Type 23 (Earth Wall)
;Param2: Spell Power
;
;**optimize: save a byte on AtkMissed, use 16 bit mode to save 2 more
Attack23:
	LDA EarthWallHP 						;C2/6D83: AD 1E 7C     LDA $7C1E   (Miss if already a current Wall)
	ORA EarthWallHP+1						;C2/6D86: 0D 1F 7C     ORA $7C1F
	BNE .Miss							;C2/6D89: D0 1C        BNE $6DA7
	LDA Param2							;C2/6D8B: A5 58        LDA $58
	STA $24								;C2/6D8D: 85 24        STA $24
	LDA Level 							;C2/6D8F: AD E5 7B     LDA $7BE5   (Level)
	STA $25								;C2/6D92: 85 25        STA $25
	JSR Multiply_8bit  						;C2/6D94: 20 F1 00     JSR $00F1   (Level * Parameter 2)
	REP #$21
	LDA $26
	ADC #1000
	STA EarthWallHP
	TDC
	SEP #$20
	RTS 								;C2/6DA6: 60           RTS 

.Miss	INC AtkMissed							;C2/6DA7: EE 56 00     INC $0056
	RTS 								;C2/6DAA: 60           RTS 

endif