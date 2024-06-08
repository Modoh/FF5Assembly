includeonce

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
	