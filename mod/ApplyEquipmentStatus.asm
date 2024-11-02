if !_Fixes 

;Fixes: bugs with always status:
		;only the last piece of a gear with always status applied (for each status type)
		;always poison didn't start its timer

;potential for future expansion (for situations that can't happen in vanilla):
	;doesn't currently support charm/berserk via items, but it could
	;doesn't always check mutually exclusive status before applying them (always charm/berserk)
	;always regen still doesn't start its timer, I assume existing items use normal regen which doesn't wear off anyway

;rewrites a bunch of code which also ends up optimizing a lot of it
;but there's no optimized version without behavior changes, so no !_Optimize tag

;Apply status from equipment 
;uses $26 as offset into ROMArmorStatus table
%subdef(ApplyEquipmentStatus)
	STZ $13			;set to 1 for always status, 0 for initial		
	LDY AttackerOffset							
	LDX $26			;ROMArmorStatus Offset					
	LDA ROMArmorStatus.Status1,X						
	BEQ .CheckUncontrolled								
	STA $12			;Status 1 to apply					
	AND #$04		;poison							
	BEQ .CheckAlwaysStatus	;only poison needs a timer				
	LDA CharStruct.Status1,Y						
	ORA CharStruct.AlwaysStatus1,Y						
	AND #$04		;poison							
	BNE .CheckAlwaysStatus	;already poisoned, don't need a new timer		
	LDA #$01		;poison timer						
	JSR StartTimerCurrentChar

.CheckAlwaysStatus
	LDY AttackerOffset
	LDA $12
	BMI .AlwaysS1	;high bit indicates always status instead of just initial

.ApplyS1									
	ORA CharStruct.Status1,Y							
	STA CharStruct.Status1,Y
	BRA .CheckUncontrolled
	
.AlwaysS1		
	AND #$7F	;clear always bit because it also means dead					
	ORA CharStruct.AlwaysStatus1,Y								;*
	STA CharStruct.AlwaysStatus1,Y			
	INC $13		;flag for always status instead of initial (for later statuses)	

.CheckUncontrolled									
	LDX $26		;ROMArmorStatus Offset						
	LDA ROMArmorStatus.Status2,X							
	STA $12		;Status 2 to apply						
	LDA CharStruct.Job,Y								
	CMP #$06	;Berserker							
	BNE .CheckZombie

.Berserker
	LDA EncounterInfo.IntroFX							
	BMI .CheckZombie	;don't berserk during the credits demo battles			
	LDA CharStruct.AlwaysStatus2,Y
	AND #$EF	;clear charm, since it's exclusive with berserk
	ORA #$08	;Berserk							
	STA CharStruct.AlwaysStatus2,Y		
	BRA .Uncontrolled

.CheckZombie	
	LDA CharStruct.Status1,Y						
	ORA CharStruct.AlwaysStatus1,Y							
	AND #$02	;Zombie								
	BEQ .Status2

.Uncontrolled		;berserk or zombie					
	JSR UncontrolledResetATB
	
.Status2								
	LDA $12		;Status 2 to apply					
	BEQ .Status3	;Nothing to apply					
+	STA $12									
	LDA $13		;always status						
	BEQ .CheckS2								

.AlwaysS2
	LDA CharStruct.AlwaysStatus2,Y
	ORA $12		;Status 2 to apply	
	STA CharStruct.AlwaysStatus2,Y						
	BRA .Status3	

.CheckS2
	LDA CharStruct.Status2,Y
	ORA CharStruct.AlwaysStatus2,Y
	STA $14		;save merged status2 for later
	TRB $12		;reset bits of status to apply for any status we already have
			;this lets us remove a bunch of later checks
	LDA $12		;Status 2 to apply					
	AND #$A4	;old, paralyze, mute					
	BEQ .ApplyS2	;only those need timers					
	AND #$80	;old							
	BEQ .CheckPara										
	LDA $14		;current status2					
	AND #$80	;old							
	BNE .CheckPara	;already old												
	LDA #$06	;old timer						
	JSR StartTimerCurrentChar						
.CheckPara		;oddly inefficient compared to the other statuses
	LDA $12									
	AND #$20	;paralyze						
	BEQ .CheckMute								
	LDA $12		;Status 2 to apply											
	LDA $14		;current status2				
	AND #$20	;paralyze						
	BNE .CheckMute	;already paralyzed										
	LDA #$09	;paralyze timer						
	JSR StartTimerCurrentChar						
.CheckMute
	LDA $12		;Status 2 to apply					
	AND #$04	;mute							
	BEQ .ApplyS2														
	LDA $14					
	AND #$04	;mute							
	BNE .ApplyS2	;already mute												
	LDA #$04	;mute timer						
	JSR StartTimerCurrentChar													
.ApplyS2
	LDY AttackerOffset							
	LDA CharStruct.Status2,Y						
	ORA $12		;+Status 2						
	STA CharStruct.Status2,Y						
	
.Status3
	LDX $26		;ROMArmorStatus Offset					
	LDA ROMArmorStatus.Status3,X							
	BEQ .Status4	;no status 3 to apply					
+	STA $12		;status 3 to apply					
	LDA $13		;always status						
	BEQ .CheckS3	

.AlwaysS3
	LDA CharStruct.AlwaysStatus3,Y	
	ORA $12		;status 3 to apply					
	STA CharStruct.AlwaysStatus3,Y						
	BRA .Status4	

.CheckS3							
	LDA CharStruct.Status3,Y						
	ORA CharStruct.AlwaysStatus3,Y		
	STA $14		;merged current status 3
	TRB $12		;reset bits of status to apply for any status we already have
	LDA $12		;status 3 to apply					
	AND #$91	;reflect/stop/regen					
	BEQ .ApplyS3	;only those need timers					
	AND #$80	;Reflect						
	BEQ .CheckStop																
	LDA $14		;merged current status 3
	AND #$80	;reflect						
	BNE .CheckStop	;already reflected											
	LDA #$02	;reflect timer						
	JSR StartTimerCurrentChar						
.CheckStop					
	LDA $12		;status 3 to apply					
	AND #$10	;Stop							
	BEQ .CheckRegen														
	LDA $14		;merged current status 3
	AND #$10	;stop							
	BNE .CheckRegen	;already stopped											
	LDA #$00	;timer for stop status					
	JSR StartTimerCurrentChar						
.CheckRegen								
	LDA $12		;status 3 to apply					
	AND #$01	;regen							
	BEQ .ApplyS3														
	LDA $14		;merged current status 3
	AND #$01	;regen							
	BNE .ApplyS3	;already regen											
	LDA #$07	;regen timer						
	JSR StartTimerCurrentChar													
							
.ApplyS3
	LDY AttackerOffset							
	LDA CharStruct.Status3,Y						
	ORA $12		;+status 3 						
	STA CharStruct.Status3,Y						

.Status4
	LDX $26		;ROMArmorStatus Offse					
	LDA ROMArmorStatus.Status4,X							
	BEQ .Ret								
	STA $12		;Status 4 to apply					
	LDA $13		;always status						
	BEQ .CheckS4								

.AlwaysS4
	LDA CharStruct.AlwaysStatus4,Y	
	ORA $12		;Status 4 to apply					
	STA CharStruct.AlwaysStatus4,Y						
	BRA .Ret

.CheckS4	
	LDA CharStruct.Status4,Y						
	ORA CharStruct.AlwaysStatus4,Y		
	STA $14		;merged current status 4
	TRB $12		;reset bits of status to apply for any status we already have
	LDA $12									
	AND #$18	;Countdown and HP Leak					
	BEQ .ApplyS4	;only those need timers					
	AND #$10	;countdown						
	BEQ .CheckLeak										
	LDA $14		;merged current status 4
	AND #$10	;countdown						
	BNE .CheckLeak	;already countdown										
	LDA #$03	;timer for countdown status				
	JSR StartTimerCurrentChar						
.CheckLeak								
	LDA $12		;Status 4 to apply					
	AND #$08	;HP Leak						
	BEQ .ApplyS4															
	LDA $14		;merged current status 4
	AND #$08	;hp leak						
	BNE .ApplyS4								
	LDA #$05	;hp leak timer						
	JSR StartTimerCurrentChar						
							
.ApplyS4
	LDY AttackerOffset							
	LDA CharStruct.Status4,Y						
	ORA $12		;+Status 4 						
	STA CharStruct.Status4,Y						
.Ret	RTS 									

;made this into a utility routine
;will be useful if we ever support charm/berserk via item passives
%subdef(UncontrolledResetATB)
	LDA CurrentChar								
	TAX 									
	LDA #$3C								
	STA UncontrolledATB,X							
	TXA							
	ASL 									
	TAX 									
	LDA ROMTimes11w,X								
	TAX 									
	TDC 									
	STA EnableTimer.ATB,X	;disable normal ATB				
	INC 									
	STA CurrentTimer.ATB,X	;normal ATB timer set at 1	
	RTS

endif