includeonce


;new routine, used by optimizations for GetItemUsableA and GetItemUsableY

;takes ROMItemEquippable index in X
;returns equippable byte in A
EquipUsable:
	LDA $14			;save original value of the temp var we're using to restore later
	PHA
	TDC 									
	TAY 										
										
-	LDA !ROMItemEquippable,X						
	STA !TempEquippable,Y							
	INX 									
	INY 									
	CPY #$0004		;2 weapon bytes, 2 armor bytes			
	BNE -									
										
	TDC									
	TAX 									
	TAY 									
	LDA #$AA		;usable for none				
	STA $14			;in-progress usable byte			

.DetermineEquippableLoop
	LDA CharEquippable.Weapons,X						
	AND TempEquippable.Weapons,Y						
	BNE .Match								
	LDA CharEquippable.Weapons+1,X						
	AND TempEquippable.Weapons+1,Y						
	BNE .Match								
	LDA CharEquippable.Armor,X						
	AND TempEquippable.Armor,Y						
	BNE .Match								
	LDA CharEquippable.Armor+1,X						
	AND TempEquippable.Armor+1,Y						
	BEQ .NextChar								

.Match	
	TXA 									
	LSR
	LSR	
	BNE .Check1								
								
	LDA $14		;in-progress usable byte				
	AND #$7F	;clear first character bit				
	STA $14									
	BRA .NextChar								

.Check1								
	CMP #$01								
	BNE .Check2								
	LDA $14									
	AND #$DF	;clear second character bit				
	STA $14									
	BRA .NextChar								
.Check2								
	CMP #$02								
	BNE .Other								
	LDA $14									
	AND #$F7	;clear third character bit				
	STA $14									
	BRA .NextChar								
.Other								
	LDA $14									
	AND #$FD	;clear fourth character bit				
	STA $14									

.NextChar
	INX 									
	INX 									
	INX 									
	INX 									
	CPX #$0010	;4 bytes * 4 characters					
	BNE .DetermineEquippableLoop						
										
	LDA $14		;usable equipment byte to return
	TAY		
	PLA
	STA $14		;restore original temp var contents
	TYA		
	RTS