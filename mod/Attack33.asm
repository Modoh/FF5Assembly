if !_CombatTweaks 

incsrc "mod/utility/attackutil.asm"

;Attack Type 33 (Spears)
;Tweaks: Adding Double Hand and Magic Sword
;Param1: Element
;Param2/3: Proc% and Proc, not handled here
Attack33:
	JSR SetHit100andTargetEvade 					
	JSR HitPhysical  						
	LDA AtkMissed							
	BEQ .Hit
	JMP PhysMiss
.Hit	JSR SwordDamage 												
	JSR CheckJump  							
	JSR StandardMSwordMods	
	JSR PhysElement					
	JMP StandardMSwordFinish	

endif