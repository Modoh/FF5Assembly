if !_CombatTweaks 

incsrc "utility/attackutil.asm"

;Attack Type 3C (Rune Weapons)
;Tweaks: Adding Magic Sword
;Param1: Hit%
;Param2: Rune Damage Boost
;Param3: Rune MP Cost
%subdef(Attack3C)
	JSR SetHitParam1andTargetEvade				
	JSR HitPhysical							
	LDA AtkMissed							
	BEQ .Hit
	JMP PhysMiss	
.Hit	JSR AxeDamage							
	JSR RuneMod							
	JSR BackRowMod
	JSR StandardMSwordMods	
	JMP StandardMSwordFinish					

endif