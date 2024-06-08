if !_CombatTweaks 

incsrc "mod/utility/attackutil.asm"

;Attack Type 37 (Katanas)
;Tweaks: Adding Magic Sword
;Param1: Crit%
;Param2/3: Proc% and Proc, not handled here
Attack37:
	JSR SetHit100andTargetEvade 					
	JSR HitPhysical 						
	LDA AtkMissed							
	BEQ .Hit
	JMP PhysMiss
.Hit	JSR SwordDamage							
	JSR BackRowMod	
	JSR StandardMSwordMods					
	JSR CheckCrit
	JMP StandardMSwordFinish	

endif