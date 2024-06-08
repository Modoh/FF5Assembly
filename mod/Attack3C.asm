if !_CombatTweaks 

incsrc "mod/utility/attackutil.asm"

;Attack Type 3C (Rune Weapons)
;Tweaks: Adding Magic Sword
;Param1: Hit%
;Param2: Rune Damage Boost
;Param3: Rune MP Cost
Attack3C:
	JSR SetHitParam1andTargetEvade_Dupe				
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