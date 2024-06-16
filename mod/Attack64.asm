if !_Optimize

;Attack Type 64 (Chicken Knife)
;Param2/3: Proc% and Proc, not handled here
%subdef(Attack64)
	JSR SetHit100andHalfTargetEvade					;C2/7774: 20 53 7C     JSR $7C53  (Hit = 100, Evade = Evade/2)
	JSR HitPhysical							;C2/7777: 20 BE 7E     JSR $7EBE  (Hit Determination for physical)
	LDA AtkMissed							;C2/777A: A5 56        LDA $56
	BNE .Miss							;C2/777C: D0 20        BNE $779E
	JSR ChickenDamage						;C2/777E: 20 26 86     JSR $8626  (Chicken Knife Damage formula)
	JSR BackRowMod							;C2/7781: 20 9B 83     JSR $839B  (Back Row Modifications to Damage)
	JSR CommandMod							;C2/7784: 20 BD 83     JSR $83BD  (Command Modifiers to Damage)
	JSR TargetStatusModPhys						;C2/7787: 20 12 85     JSR $8512  (Target Status Effect Modifiers to Damage)
	JSR AttackerStatusModPhys					;C2/778A: 20 33 85     JSR $8533  (Attacker Status Effect Modifiers to Damage)
	JSR MagicSwordMod						;C2/778D: 20 84 86     JSR $8684  (Magic Sword Modifiers)
	LDA TargetDead							;C2/7790: A5 61        LDA $61
	BNE .Ret							;C2/7792: D0 0F        BNE $77A3
	LDA AtkMissed							;C2/7794: A5 56        LDA $56
	BNE .Miss							;C2/7796: D0 06        BNE $779E
	JSR CalcFinalDamageMSword					;C2/7798: 20 11 88     JSR $8811  (Calculate Final Damage)
	JMP ApplyMSwordStatus						;C2/779B: 4C CF 8B     JMP $8BCF  (Apply Magic Sword Status Effects)
.Miss	LDA #$80							;C2/779E: A9 80        LDA #$80
	STA AtkMissed							;C2/77A0: 85 56        STA $56
if not(!_Optimize)		;get rid of duplicate RTS
	RTS 								;C2/77A2: 60           RTS 
endif
.Ret	RTS 								;C2/77A3: 60           RTS 

endif