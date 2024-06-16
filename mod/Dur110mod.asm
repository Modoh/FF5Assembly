if !_Optimize

%subdef(Dur110mod)
;Duration = 110 - Attacker's Magic Power, min 30
	SEC 							;C2/25A0: 38           SEC 
	LDA #$6E	;110					;C2/25A1: A9 6E        LDA #$6E
	SBC MagicPower						;C2/25A3: ED E4 7B     SBC $7BE4
	BCC Dur30						;C2/25A6: 90 04        BCC $25AC
	CMP #$1E	;min 30					;C2/25A8: C9 1E        CMP #$1E
	BCS Dur30_Ret						;C2/25AA: B0 02        BCS $25AE

%subdef(Dur30)
;Duration = 30
;opt: reuse code from Dur110mod 
	LDA #$1E	;min 30					;C2/25AC: A9 1E        LDA #$1E
.Ret	RTS 							;C2/25AE: 60           RTS 

endif