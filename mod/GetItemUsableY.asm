if !_Optimize

incsrc mod/utility/EquipUsable.asm

;Calculate Item Usability (from inventory index)
;(Y:index into in-battle inventory)
;(Returns A: bitmask depending on equipment type and some character properties)
; format seems to be 2 bits per character, 00 for usable and 10 for not

;optimization: use a shared routine to merge the shared code between A and Y versions
GetItemUsableY:
	LDA Temp,Y								
	BPL +									
	LDA #$AA		;usable for none				
	JMP .Ret								

+	AND #$40		;Consumable					
	BEQ .Equipment								
	LDA InventoryFlags,Y							
	AND #$20								
	BEQ .RetZero								
	LDA #$AA		;usable for none				
	BRA .Ret								

.RetZero								
	LDA #$00		;usable for all					
	BRA .Ret								

.Equipment				
	LDA Temp,Y								
	ASL 									
	ASL 									
	TAX 									

	JSR EquipUsable		
.Ret	RTS

endif