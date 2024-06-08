if !_Fixes

;AI Condition 01: Check Status
;Param1: AITarget routine
;Param2: Status offset (0-3 for status 1-4)
;Param3: Status bits
;if checking for death status, also succeed if hp is 0 (though this behavior is bugged)
AICondition01:		
	LDA AIParam1							;C2/283E: AD 21 27     LDA $2721       
	JSR GetAITarget	;populates list of targets to check		;C2/2841: 20 27 2C     JSR $2C27       
	LDA AIParam2  							;C2/2844: AD 22 27     LDA $2722       
	TAX 								;C2/2847: AA           TAX 
	STX $0E								;C2/2848: 86 0E        STX $0E
	TDC 								;C2/284A: 7B           TDC 
	TAY 								;C2/284B: A8           TAY 
.Loop	REP #$20							;C2/284C: C2 20        REP #$20
	LDA AITargetOffsets,Y						;C2/284E: B9 20 26     LDA $2620,Y
	CMP #$FFFF	;end of list or no target found			;C2/2851: C9 FF FF     CMP #$FFFF
	BNE .TargetFound						;C2/2854: D0 05        BNE $285B
	TDC 								;C2/2856: 7B           TDC 
	SEP #$20							;C2/2857: E2 20        SEP #$20
	BRA .Finish							;C2/2859: 80 31        BRA $288C

.TargetFound
	STA $10		;target offset					;C2/285B: 85 10        STA $10
	CLC 								;C2/285D: 18           CLC 
	ADC $0E		;status offset					;C2/285E: 65 0E        ADC $0E
	TAX 								;C2/2860: AA           TAX 
	TDC 								;C2/2861: 7B           TDC 
	SEP #$20							;C2/2862: E2 20        SEP #$20
	LDA CharStruct.Status1,X	;could be status 1-4 depending	;C2/2864: BD 1A 20     LDA $201A,X
	ORA CharStruct.AlwaysStatus1,X	;on status offset		;C2/2867: 1D 70 20     ORA $2070,X
	AND AIParam3							;C2/286A: 2D 23 27     AND $2723
	BNE .Match							;C2/286D: D0 13        BNE $2882
	LDA $0E								;C2/286F: A5 0E        LDA $0E
	BNE .Next							;C2/2871: D0 12        BNE $2885
	LDA AIParam3							;C2/2873: AD 23 27     LDA $2723
	BPL .Next							;C2/2876: 10 0D        BPL $2885
	LDX $10			;if asked to check death status		;C2/2878: A6 10        LDX $10
	LDA CharStruct.CurHP,X	;also succeed if hp is 0		;C2/287A: BD 06 20     LDA $2006,X
if !_Fixes			;**bug: should be HP high byte $2007
	ORA CharStruct.CurHP+1,X
else
	ORA CharStruct.CurHP,X						;C2/287D: 1D 06 20     ORA $2006,X
endif
	BNE .Next							;C2/2880: D0 03        BNE $2885
.Match	INC AIConditionMet						;C2/2882: EE 94 46     INC $4694      
.Next	INY 								;C2/2885: C8           INY 
	INY 								;C2/2886: C8           INY 
	CPY #$0018	;12 characters * 2 bytes			;C2/2887: C0 18 00     CPY #$0018
	BNE .Loop							;C2/288A: D0 C0        BNE $284C
.Finish			;fail if any targets failed	
	LDA AIMultiTarget						;C2/288C: AD 24 27     LDA $2724
	BEQ .Ret							;C2/288F: F0 0B        BEQ $289C
	LDA AITargetCount						;C2/2891: AD 25 27     LDA $2725
	CMP AIConditionMet						;C2/2894: CD 94 46     CMP $4694
	BEQ .Ret							;C2/2897: F0 03        BEQ $289C
	STZ AIConditionMet  						;C2/2899: 9C 94 46     STZ $4694      
.Ret	RTS 								;C2/289C: 60           RTS 

endif