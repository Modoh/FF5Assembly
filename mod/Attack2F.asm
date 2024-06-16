if !_CombatTweaks 

incsrc "utility/attackutil.asm"

;Attack type 2F (Harps, was Unused)
;Bells damage + status, for non-gravity harps
;also requires changes to the bell damage formula to deal damage
;Params: 	
;		$57 = Attack Power Override if set
;		$58 = Status Chance 
;		$59 = Status 2
%subdef(Attack2F)
	JSR Attack39		;Vanilla Bell attack routine
	LDA AtkMissed		;check for miss (only happens on void)
	BNE .Ret
	LDA Param2
	STA Param1		;HitMagic expects hit chance in Param 1
	JSR HitMagic
	JMP Attack07_Status	;Vanilla Gravity/Harp routine, status portion
.Ret	RTS

endif