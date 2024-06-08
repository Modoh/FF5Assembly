if !_Optimize || !_CombatTweaks 

incsrc "mod/utility/attackutil.asm"

;Attack Type 31 (Swords)
;Tweaks: No gameplay changes, just using utility routines to save space
;Param1: Element
;Param2/3: Proc% and Proc, not handled here

Attack31:
	JSR SetHit100andTargetEvade					
	JSR HitPhysical							
	LDA AtkMissed							
	BEQ .Hit
	JMP PhysMiss
.Hit	JSR SwordDamage							
	JSR BackRowMod							
	JSR StandardMSwordMods	
	JSR PhysElement					
	JMP StandardMSwordFinish	

endif