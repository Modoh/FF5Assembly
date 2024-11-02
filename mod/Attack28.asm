if !_Optimize

;Attack Type 28 (Direct Magic Damage)
;Param1: Hit%
;Damage = Param2 + Param3*256
;
;**optimize: just go to 16 bit mode and load param2
%subdef(Attack28)
	JSR HitMagic 							;C2/6DED: 20 F6 7E     JSR $7EF6  (Hit Determination for Magic)
	LDA AtkMissed							;C2/6DF0: A5 56        LDA $56
	BNE .Ret							;C2/6DF2: D0 1D        BNE $6E11
	REP #$20
	LDA Param2		;includes high byte in Param3
	CMP #$270F		;cap at 9999				;C2/6E03: C9 0F 27     CMP #$270F
	BCC +								;C2/6E06: 90 03        BCC $6E0B
	LDA #$270F							;C2/6E08: A9 0F 27     LDA #$270F
+	STA DamageToTarget						;C2/6E0B: 8D 6D 7B     STA $7B6D    (Max Damage = 9999)
	TDC 								;C2/6E0E: 7B           TDC 
	SEP #$20							;C2/6E0F: E2 20        SEP #$20
.Ret	RTS 								;C2/6E11: 60           RTS 

endif