if !_Optimize

;**optimize: Don't load Param2 twice

;Attack Type 40 (Change Row)
;Param1: Hit%
;Param2: 	80h Switch Row (target)
;		40h Front Row (target)
;		Else Back Row (attacker)
;**optimize: Don't load Param2 twice
%subdef(Attack40)
	JSR HitMagic							;C2/7119: 20 F6 7E     JSR $7EF6  (Hit Determination for Magic)
	LDA AtkMissed							;C2/711C: A5 56        LDA $56
	BNE .Ret							;C2/711E: D0 13        BNE $7133
	LDA Param2							;C2/7120: A5 58        LDA $58
	BPL +								;C2/7122: 10 03        BPL $7127
	JMP TargetChangeRow		;80h set			;C2/7124: 4C 01 91     JMP $9101  (Change Target Row)
+	
if not(!_Optimize)
	LDA Param2							;C2/7127: A5 58        LDA $58
endif
	AND #$40							;C2/7129: 29 40        AND #$40
	BEQ +								;C2/712B: F0 03        BEQ $7130
	JMP TargetFrontRow		;40h set			;C2/712D: 4C 17 91     JMP $9117  (Move Target to Front Row)
+	JMP AttackerBackRow		;anything else			;C2/7130: 4C 22 91     JMP $9122  (Move Attacker to Back Row)
.Ret	RTS 								;C2/7133: 60           RTS 

endif