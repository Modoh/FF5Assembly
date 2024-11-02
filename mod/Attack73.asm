if !_CombatTweaks 

incsrc "utility/attackutil.asm"

;Attack Type 73 (Spears Strong vs. Creature)
;Tweaks: Adding Magic Sword
;Param1: Creature Type
%subdef(Attack73)
	JSR SetHit100andTargetEvade					
	JSR HitPhysical							
	LDA AtkMissed							
	BEQ .Hit
	JMP PhysMiss	
.Hit	JSR SwordDamage													
	JSR CheckJump
	JSR StandardMSwordMods		
	JSR CheckCreatureCrit
	JMP StandardMSwordFinish	

endif
