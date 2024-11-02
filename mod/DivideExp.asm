if !_Optimize

incsrc utility/Division_32bit.asm

;Divides Exp for party members
;minimum 1 exp per char(this isn't called if total exp is 0)

;optimization: use a shared 32 bit division routine
%subdef(DivideExp)
	LDX $10			;count of active chars				;C2/57E6: A6 10        LDX $10
	PHX 									;C2/57E8: DA           PHX 

	LDX #$000F								;C2/57E9: A2 0F 00     LDX #$000F
-	STZ $0E,X		;clear $0E-1D					;C2/57EC: 74 0E        STZ $0E,X
	DEX 									;C2/57EE: CA           DEX 
	BPL -									;C2/57EF: 10 FB        BPL $57EC

	PLX 									;C2/57F1: FA           PLX 
	STX $12			;count of active chars, divisor			;C2/57F2: 86 12        STX $12
	LDX VictoryExp								;C2/57F4: AE 0E 7C     LDX $7C0E
	STX $0E									;C2/57F7: 86 0E        STX $0E
	LDA VictoryExp+2							;C2/57F9: AD 10 7C     LDA $7C10
	STA $10									;C2/57FC: 85 10        STA $10

	JSR Division_32bit

	LDA $16			;quotient, exp to distribute			;C2/5832: A5 16        LDA $16
	ORA $17									;C2/5834: 05 17        ORA $17
	ORA $18									;C2/5836: 05 18        ORA $18
	BNE +									;C2/5838: D0 02        BNE $583C
	INC $16			;min 1 						;C2/583A: E6 16        INC $16
+	LDX $16									;C2/583C: A6 16        LDX $16
	STX VictoryExp								;C2/583E: 8E 0E 7C     STX $7C0E
	LDA $18									;C2/5841: A5 18        LDA $18
	STA VictoryExp+2							;C2/5843: 8D 10 7C     STA $7C10
	RTS 									;C2/5846: 60           RTS 

endif
