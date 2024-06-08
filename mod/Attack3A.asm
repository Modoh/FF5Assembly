if !_CombatTweaks 

incsrc "mod/utility/attackutil.asm"

;Attack Type 3A (Long Reach Axes)
;Tweaks: Adding Magic Sword
;Param1: Hit%
;Param2/3: Proc% and Proc, not handled here
Attack3A:
	JSR SetHitParam1andTargetEvade_Dupe				
	JSR HitPhysical							
	LDA AtkMissed							
	BNE .Hit							
	JMP PhysMiss
.Hit	JSR AxeDamage
	JSR StandardMSwordMods				
	JMP StandardMSwordFinish
	
endif