if !_Optimize

;Unused monster form switch for ArchaeAvis
;large routine and the in-game monster uses standard hide/unhide monster scripting instead
;getting rid of it saves 173 bytes

;(saving notes about improvements to the original routine, if it's needed later)
;**optimize: 	Specialty data at the end doesn't need temp vars, could loop clearing timers, could trim from address setup
;		TempMStats loads are offset by X but X is always zero..
;		We could probably bypass the whole temp stat structure entirely by calculating the rom address directly
%subdef(Attack71)
	RTS

endif
