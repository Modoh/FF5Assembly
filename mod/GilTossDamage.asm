if !_Optimize


;GilToss Damage Formula
;Attack = Level + 10 (or =0, if poor)
;M = Param2
;Defense = Target Defense
;Gil Cost = Param1 * Level

;**optimize: use shorter addresses when accessing Gil
%subdef(GilTossDamage)
	CLC 							
	LDA Level						
	ADC #$0A   	;+10					
	TAX 							
	STX Attack    						
	LDA Param1						
	STA $24							
	LDA Level  						
	STA $25							
	JSR Multiply_8bit					
	LDA Gil+2						
	BNE .GilOK	;>65535 Gil				

	REP #$20						
	LDA Gil							
	CMP $26							
	BCS .GilOK						

	;Not enough Gil, Attack = 0
	TDC 							
	STA Attack						
	SEP #$20						
	BRA .Finish						

.GilOK	;manual 24 bit subtraction
	TDC 							
	SEP #$21	;also sets carry for subtraction						
	LDA Gil							
	SBC $26							
	STA Gil							
	LDA Gil+1						
	SBC $27							
	STA Gil+1						
	LDA Gil+2						
	SBC #$00						
	STA Gil+2						

.Finish	LDA Param2						
	TAX 							
	STX M							
	LDX TargetOffset					
	LDA CharStruct.Defense,X				
	TAX 							
	STX Defense						
	RTS 							
	
endif