if !_Optimize || !_GFXCmd

incsrc mod/utility/GFXCmd.asm	
;uses GFXCmdAnim combined routine to save space

;Displays an ability or command animation
;creates Action $00,FC,01,<A>,00
GFXCmdAbilityAnim:
	LDX #$0001
	JMP GFXCmdAnim 	

endif