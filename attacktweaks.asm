
;Implements a new attack type for non-gravity harps
;Adds Double Hand and Magic Sword support to some more weapon types
;Save space via some use of utility routines


;Attack type 2F (Harps, was Unused)
;Bells damage + status, for non-gravity harps
;also requires changes to the bell damage formula to deal damage
;Params: 	
;		$57 = Attack Power Override if set
;		$58 = Status Chance 
;		$59 = Status 2
Attack2F:
	JSR Attack39		;Vanilla Bell attack routine
	LDA AtkMissed		;check for miss (only happens on void)
	BNE .Ret
	LDA Param2
	STA Param1		;HitMagic expects hit chance in Param 1
	JSR HitMagic
	JMP Attack07_Status	;Vanilla Gravity/Harp routine, status portion
.Ret	RTS

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

;Attack Type 73 (Spears Strong vs. Creature)
;Tweaks: Adding Magic Sword
;Param1: Creature Type
Attack73:
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
	
	
;Utility Routines

PhysMiss:
	LDA #$80	
	STA AtkMissed	
.Ret	RTS 		

StandardMSwordFinish:
	LDA TargetDead			
	BNE PhysMiss_Ret		;borrowing RTS here to save a byte		
	LDA AtkMissed			
	BEQ .Hit
	JMP PhysMiss	
.Hit	JSR CalcFinalDamageMSword	
	JMP ApplyMSwordStatus
	
PhysElement:
	LDA Param1							
	STA AtkElement							
	JSR ElementDamageModPhys		
	
StandardMSwordMods:
	JSR CommandMod							
	JSR DoubleGripMod						
	JSR TargetStatusModPhys						
	JSR AttackerStatusModPhys					
	JMP MagicSwordMod
	

