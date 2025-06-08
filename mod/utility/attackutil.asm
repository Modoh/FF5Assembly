includeonce

;Utility Routines

%subdef(PhysMiss)
	LDA #$80	
	STA AtkMissed	
.Ret	RTS 		

%subdef(StandardMSwordFinish)
	LDA TargetDead			
	BNE PhysMiss_Ret		;borrowing RTS here to save a byte		
	LDA AtkMissed			
	BEQ .Hit
	JMP PhysMiss	
.Hit	JSR CalcFinalDamageMSword	
	JMP ApplyMSwordStatus
	
%subdef(PhysElement)
	LDA Param1							
	STA AtkElement							
	JMP ElementDamageModPhys		
	
%subdef(StandardMSwordMods)
	JSR CommandMod							
	JSR DoubleGripMod						
	JSR TargetStatusModPhys						
	JSR AttackerStatusModPhys					
	JMP MagicSwordMod
	
