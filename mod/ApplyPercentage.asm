if !_Optimize

incsrc utility/Division_32bit.asm

;Utility routine used for the +% HP/MP passives on level up
;inputs: 
;$2E: 4 byte multiply result (value * percentage)
;$08: 2 byte base value
;$0A: 2 byte cap (generally 999 or 9999)
;output:
;$08: 2 byte value (value*percentage/100)+Base, capped

;optimization: use a shared 32 bit division routine
%subdef(ApplyPercentage)
	LDX #$000F								;C2/0491: A2 0F 00     LDX #$000F
-	STZ $0E,X		;clear $0E-1D					;C2/0494: 74 0E        STZ $0E,X
	DEX 									;C2/0496: CA           DEX 
	BPL -									;C2/0497: 10 FB        BPL $0494
	LDX #$0064		;100						;C2/0499: A2 64 00     LDX #$0064
	STX $12									;C2/049C: 86 12        STX $12
	LDX $2E			;previous multiply result (low bytes)		;C2/049E: A6 2E        LDX $2E
	STX $0E									;C2/04A0: 86 0E        STX $0E
	LDA $30			;(high bytes)					;C2/04A2: A5 30        LDA $30
	STA $10									;C2/04A4: 85 10        STA $10

	JSR Division_32bit

	CLC 									;C2/04DA: 18           CLC 
	LDA $16		;quotient, input/100					;C2/04DB: A5 16        LDA $16
	ADC $08		;base value						;C2/04DD: 65 08        ADC $08
	STA $08		;adjusted value						;C2/04DF: 85 08        STA $08
	LDA $17		;high byte of above					;C2/04E1: A5 17        LDA $17
	ADC $09									;C2/04E3: 65 09        ADC $09
	STA $09									;C2/04E5: 85 09        STA $09
	SEC 		;checks against 9999					;C2/04E7: 38           SEC 
	LDA $08									;C2/04E8: A5 08        LDA $08
	SBC $0A		;9999 low byte						;C2/04EA: E5 0A        SBC $0A
	LDA $09									;C2/04EC: A5 09        LDA $09
	SBC $0B		;9999 high byte						;C2/04EE: E5 0B        SBC $0B
	BCC .Ret								;C2/04F0: 90 08        BCC $04FA
	LDA $0A		;caps at 9999						;C2/04F2: A5 0A        LDA $0A
	STA $08									;C2/04F4: 85 08        STA $08
	LDA $0B									;C2/04F6: A5 0B        LDA $0B
	STA $09									;C2/04F8: 85 09        STA $09
.Ret	RTS 									;C2/04FA: 60           RTS 

endif