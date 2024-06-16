if !_Optimize 

incsrc utility/GFXCmd.asm	
;uses GFXCmdAnim combined routine to save space

;Displays an ability or command animation
;creates Action $00,FC,01,<A>,00
%subdef(GFXCmdAbilityAnim)
	LDX #$0001
	JMP GFXCmdAnim 	

endif