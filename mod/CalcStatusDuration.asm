if !_Optimize

;Status Duration Determination
;Param2($58) is base duration with a flag in the high bit
;Result in StatusDuration ($3ED8)
;	if flag is set result is (2*base + level/4)
;	if no flag set result is (2*base + level/4 - targetlvl/4) or 30 if target is heavy

;**optimize: simplified calclations, removing some really strange code
CalcStatusDuration:
	LDA Param2								
	ASL        			;base*2, high bit into carry (ignored)
	STA $0E    								
	LDA Level								
	JSR ShiftDivide_4  							
	CLC 									
	ADC $0E									
	BCC +				;check for overflow
	LDA #$FF			;cap at 255
+	STA $0E    			
	LDA Param2								
	BMI .Finish  								
	LDX TargetOffset							
	LDA CharStruct.CreatureType,X						
	AND #$20   			;heavy					
	BEQ + 									
	LDA #$1E			;duration is 30 if target heavy		
	STA $0E    								
	BRA .Finish								
+	CLC 									
	LDA CharStruct.Level,X							
	ADC CharStruct.BonusLevel,X						
	JSR ShiftDivide_4  							
	STA $0F				;target level /4			
	SEC 									
	LDA $0E				;duration				
	SBC $0F    			;target level /4			
	BEQ +									
	BCS ++									
+	LDA #$01   			;min duration 1				
++	STA $0E									
.Finish	LDA $0E									
	STA StatusDuration							
	RTS 									

endif