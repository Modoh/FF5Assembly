if !_CombatTweaks 

incsrc "mod/utility/attackutil.asm"

;Attack Type 34 (Axes)
;Tweaks: Adding Magic Sword
;Param1: Hit%
;Param2/3: Proc% and Proc, not handled here
Attack34:
	JSR SetHitParam1andTargetEvade_Dupe				
	JSR HitPhysical							
	LDA AtkMissed							
	BEQ .Hit	
	JMP PhysMiss
.Hit	JSR AxeDamage							
	JSR BackRowMod							
	JSR StandardMSwordMods				
	JMP StandardMSwordFinish							

endif