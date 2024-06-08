if !_Optimize

incsrc mod/Attack0C.asm		;we're reusing a lot of code from this, so gotta have it

;Attack Type 08 (Flare)
;Param2: Spell Power
;Param3: Element
;
;**optimize: merge with Attack0C (Flare with HP Leak) to save space
Attack08:
	LDA Param3		;Element (used in other routine)	
	STZ Param3		;Clear so other routine doesn't apply HP leak
	JMP Attack0C_Element
	
endif