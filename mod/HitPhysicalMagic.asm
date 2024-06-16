if !_Optimize

;Hit% Determination for Physical Magic
%subdef(HitPhysicalMagic)
	LDA Param1						;C2/7F1B: A5 57        LDA $57
	BMI .Return						;C2/7F1D: 30 10        BMI $7F2F    (Check for Autohit)
if !_Optimize		;don't use dupe routine so we can remove it
	JSR SetHitParam1andTargetEvade
else
	JSR SetHitParam1andTargetEvade_Dupe			;C2/7F1F: 20 3B 7C     JSR $7C3B    (Hit = 1st Parameter, Evade = Evade%)
endif
	JSR CheckSpecialEvade					;C2/7F22: 20 FC 7C     JSR $7CFC    (Check for Evade, Weapon Block or Elf Cape)
	LDA AtkMissed						;C2/7F25: A5 56        LDA $56
	BNE .Return						;C2/7F27: D0 06        BNE $7F2F
	JSR TargetPHitMod					;C2/7F29: 20 AC 7D     JSR $7DAC    (Target Status Effect Modifiers to Hit%)
	JSR CheckPHit						;C2/7F2C: 20 23 7E     JSR $7E23    (Check for Physical Hit)
.Return	RTS 							;C2/7F2F: 60           RTS 

endif