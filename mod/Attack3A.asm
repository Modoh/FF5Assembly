if !_CombatTweaks 

incsrc "utility/attackutil.asm"

;Attack Type 3A (Long Reach Axes)
;Tweaks: Adding Magic Sword
;Param1: Hit%
;Param2/3: Proc% and Proc, not handled here
%subdef(Attack3A)
	JSR SetHitParam1andTargetEvade			
	JSR HitPhysical							
	LDA AtkMissed							
	BEQ .Hit							
	JMP PhysMiss
.Hit	JSR AxeDamage
	JSR StandardMSwordMods				
	JMP StandardMSwordFinish
	
endif