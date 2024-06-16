if !_Optimize

;Attack Type 66 (Targetting)
%subdef(Attack66)
	SEC 							;C2/77B6: 38           SEC 
	LDA AttackerIndex					;C2/77B7: A5 47        LDA $47
	SBC #$04		;now monster index		;C2/77B9: E9 04        SBC #$04
	ASL 							;C2/77BB: 0A           ASL 
	TAY 							;C2/77BC: A8           TAY 
	TDC 							;C2/77BD: 7B           TDC 
	STA ForcedTarget.Party,Y				;C2/77BE: 99 2A 7C     STA $7C2A,Y
	STA ForcedTarget.Monster,Y				;C2/77C1: 99 2B 7C     STA $7C2B,Y
	LDA TargetIndex						;C2/77C4: A5 48        LDA $48
	CMP #$04						;C2/77C6: C9 04        CMP #$04
	BCS .Monster						;C2/77C8: B0 09        BCS $77D3
	TAX 							;C2/77CA: AA           TAX 
	TDC 							;C2/77CB: 7B           TDC 
	JSR SetBit_X						;C2/77CC: 20 D6 01     JSR $01D6
	STA ForcedTarget.Party,Y				;C2/77CF: 99 2A 7C     STA $7C2A,Y
	RTS 							;C2/77D2: 60           RTS 
;
.Monster
	SEC 							;C2/77D3: 38           SEC 
	SBC #$04						;C2/77D4: E9 04        SBC #$04
	TAX 							;C2/77D6: AA           TAX 
	TDC 							;C2/77D7: 7B           TDC 
	JSR SetBit_X						;C2/77D8: 20 D6 01     JSR $01D6
	STA ForcedTarget.Monster,Y				;C2/77DB: 99 2B 7C     STA $7C2B,Y
	RTS 							;C2/77DE: 60           RTS 

if not(!_Optimize)		;get rid of duplicate RTS
	RTS 							;C2/77DF: 60           RTS 
endif

endif