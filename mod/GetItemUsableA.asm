if !_Optimize

incsrc utility/EquipUsable.asm

;Calculate Item Usability (from equipment type)
;(A: item data equipment type (byte 2/12), returns A = Useable byte, 2 bits per char)

;optimization: use a shared routine to merge the shared code between A and Y versions
%subdef(GetItemUsableA)
	PHY 										
	AND #$3F		;strip flags						
	ASL
	ASL										
	TAX 										
	JSR EquipUsable
	PLY
	RTS
	
endif