if !_Optimize || !_Fixes

%subdef(TimerEffectOld)								;
;fixed: stats that were exactly 0 would underflow to 255
;..	also would only decrease monster attack if it was >128
;optimized: one loop of 8 instead of 2 loops of 4	
	LDA #$01							;C2/2264: A9 01        LDA #$01
	STA EnableTimer.Old,Y						;C2/2266: 99 F7 3C     STA $3CF7,Y
	LDA InitialTimer.Old,Y						;C2/2269: B9 FF 3D     LDA $3DFF,Y
	STA CurrentTimer.Old,Y						;C2/226C: 99 7B 3D     STA $3D7B,Y
	LDX AttackerOffset						;C2/226F: A6 32        LDX $32        
	STZ $0E								;C2/2271: 64 0E        STZ $0E
.StatsLoop		;applies to all 4 main stats, base and equipped	
	LDA CharStruct.BaseStr,X					;C2/2273: BD 24 20     LDA $2024,X
if !_Fixes
	BEQ +		;skip update if we'd go from 0->255
endif
	DEC 								;C2/2276: 3A           DEC 
	BEQ +		;skip update if we'd go from 1->0		;C2/2277: F0 03        BEQ $227C
	STA CharStruct.BaseStr,X					;C2/2279: 9D 24 20     STA $2024,X
	;opt: Equipped stats are right after base stats			;C2/227C: BD 28 20     LDA $2028,X
	;.. so we only need one loop					;C2/227F: 3A           DEC 
									;C2/2280: F0 03        BEQ $2285
									;C2/2282: 9D 28 20     STA $2028,X
+	INX 								;C2/2285: E8           INX 
	INC $0E								;C2/2286: E6 0E        INC $0E
	LDA $0E								;C2/2288: A5 0E        LDA $0E
	CMP #$08	;4 stats base then 4 equipped			;C2/228A: C9 04        CMP #$04
	BNE .StatsLoop							;C2/228C: D0 E5        BNE $2273
	LDX ProcessingTimer 						;C2/228E: AE CE 3E     LDX $3ECE
	LDA !TimerReadyChar,X						;C2/2291: BD B7 3E     LDA $3EB7,X
	CMP #$04	;monster check					;C2/2294: C9 04        CMP #$04
	BCC .Ret							;C2/2296: 90 14        BCC $22AC
	LDX AttackerOffset						;C2/2298: A6 32        LDX $32        
	LDA CharStruct.Level,X						;C2/229A: BD 02 20     LDA $2002,X
if !_Fixes
	BEQ +		;skip update if we'd go from 0->255
endif
	DEC 								;C2/229D: 3A           DEC 
	BEQ +		;skip update if we'd go from 1->0		;C2/229E: F0 03        BEQ $22A3
	STA CharStruct.Level,X						;C2/22A0: 9D 02 20     STA $2002,X
+	LDA CharStruct.MonsterAttack,X					;C2/22A3: BD 44 20     LDA $2044,X
if !_Fixes
	BEQ .Ret	;skip update if we'd go from 0->255
	DEC
	BEQ .Ret	;skip update if we'd go from 1->0
else			;not only can the attack underflow but it also only applies to attack values over 128
	DEC 								;C2/22A6: 3A           DEC 
	BPL .Ret	;only decreases attack if above 128		;C2/22A7: 10 03        BPL $22AC
endif
	STA CharStruct.MonsterAttack,X					;C2/22A9: 9D 44 20     STA $2044,X
.Ret	RTS 								;C2/22AC: 60           RTS 


endif