if !_StackingDefender

;Check for Evade, Weapon Block or Elf Cape
%subdef(CheckSpecialEvade)
	LDX TargetOffset						;C2/7CFC: A6 49        LDX $49
	LDA CharStruct.Status2,X					;C2/7CFE: BD 1B 20     LDA $201B,X
	ORA CharStruct.AlwaysStatus2,X					;C2/7D01: 1D 71 20     ORA $2071,X
	AND #$70    							;C2/7D04: 29 70        AND #$70     (Target Status2 = Sleep, Charm or Paralyze)
	BNE .Return							;C2/7D06: D0 76        BNE $7D7E
	LDA CharStruct.Status3,X					;C2/7D08: BD 1C 20     LDA $201C,X  
	AND #$10    							;C2/7D0B: 29 10        AND #$10     (Target Status3 = Stop)
	BNE .Return							;C2/7D0D: D0 6F        BNE $7D7E
	LDA CharStruct.Passives1,X					;C2/7D0F: BD 20 20     LDA $2020,X
	AND #$40    							;C2/7D12: 29 40        AND #$40     (Target has Evade Ability)
	BEQ .CheckSword							;C2/7D14: F0 14        BEQ $7D2A
	JSR Random_0_99							;C2/7D16: 20 A2 02     JSR $02A2
	CMP #$19    							;C2/7D19: C9 19        CMP #$19     (0.99) < 25
	BCS .CheckSword							;C2/7D1B: B0 0D        BCS $7D2A
	LDA AttackerIndex						;C2/7D1D: A5 47        LDA $47
	CMP TargetIndex							;C2/7D1F: C5 48        CMP $48      (Can't Miss if Attacker = Target)
	BEQ .CheckSword							;C2/7D21: F0 07        BEQ $7D2A
	LDA #$05							;C2/7D23: A9 05        LDA #$05
	STA BladeGrasp							;C2/7D25: 85 5E        STA $5E
	INC AtkMissed   						;C2/7D27: E6 56        INC $56      (Attack Misses)
	RTS 								;C2/7D29: 60           RTS 

.CheckSword
	LDA #$19		;default chance is 25%
	STA $0E
	LDX TargetOffset						;C2/7D2A: A6 49        LDX $49
	LDA CharStruct.WeaponProperties,X				;C2/7D2C: BD 38 20     LDA $2038,X
	BPL .CheckKnife   						;C2/7D2F: 10 14        BPL $7D45    (Check Weapon Special Effect Byte = 80h = Hardened + Defender)
	AND #$10		;bit that indicates multiple swords w/defender
	BEQ +
	LDA #$32		;modifies chance to 50% 
	STA $0E
+	JSR Random_0_99							;C2/7D31: 20 A2 02     JSR $02A2
	CMP $0E    							;C2/7D34: C9 19        CMP #$19     (0.99) < 25
	BCS .CheckKnife							;C2/7D36: B0 0D        BCS $7D45
	LDA AttackerIndex						;C2/7D38: A5 47        LDA $47
	CMP TargetIndex    						;C2/7D3A: C5 48        CMP $48      (Can't Miss if Attacker = Target)
	BEQ .CheckKnife							;C2/7D3C: F0 07        BEQ $7D45
	LDA #$01							;C2/7D3E: A9 01        LDA #$01
	STA SwordBlock							;C2/7D40: 85 5A        STA $5A
	INC AtkMissed 							;C2/7D42: E6 56        INC $56      (Attack Misses)
	RTS 								;C2/7D44: 60           RTS 

.CheckKnife
	;uses default chance of 25% from swords
	;since we can't have two swords AND two knives
	LDX TargetOffset						;C2/7D45: A6 49        LDX $49
	LDA CharStruct.WeaponProperties,X				;C2/7D47: BD 38 20     LDA $2038,X
	BIT #$40    							;C2/7D4A: 29 40        AND #$40     (Check Weapon Special Effect Byte = 40h = Guardian)
	BEQ .CheckCape							;C2/7D4C: F0 14        BEQ $7D62
	BIT #$10		;bit that indicates multiple swords w/defender
	BEQ +
	LDA #$32		;modifies chance to 50% 
	STA $0E
+	JSR Random_0_99							;C2/7D4E: 20 A2 02     JSR $02A2
	CMP $0E    							;C2/7D51: C9 19        CMP #$19     (0.99) < 25
	BCS .CheckCape							;C2/7D53: B0 0D        BCS $7D62
	LDA AttackerIndex						;C2/7D55: A5 47        LDA $47
	CMP TargetIndex							;C2/7D57: C5 48        CMP $48      (Can't Miss if Attacker = Target)
	BEQ .CheckCape							;C2/7D59: F0 07        BEQ $7D62
	LDA #$02							;C2/7D5B: A9 02        LDA #$02
	STA KnifeBlock							;C2/7D5D: 85 5B        STA $5B
	INC AtkMissed 							;C2/7D5F: E6 56        INC $56      (Attack Misses)
	RTS 								;C2/7D61: 60           RTS 

.CheckCape								;Check for Elf Cape
	LDX TargetOffset						;C2/7D62: A6 49        LDX $49
	LDA CharStruct.ArmorProperties,X 				;C2/7D64: BD 39 20     LDA $2039,X   (Check Attacker Armour Special Effect Byte)
	AND #$40    							;C2/7D67: 29 40        AND #$40      (Check if Evade (Elf Cape))
	BEQ .Return							;C2/7D69: F0 13        BEQ $7D7E
	JSR Random_0_99							;C2/7D6B: 20 A2 02     JSR $02A2
	CMP #$21    							;C2/7D6E: C9 21        CMP #$21      (0.99) < 33
	BCS .Return							;C2/7D70: B0 0C        BCS $7D7E
	LDA AttackerIndex						;C2/7D72: A5 47        LDA $47
	CMP TargetIndex							;C2/7D74: C5 48        CMP $48       (Can't Miss if Attacker = Target)
	BEQ .Return							;C2/7D76: F0 06        BEQ $7D7E
	LDA #$03							;C2/7D78: A9 03        LDA #$03
	STA ElfCape							;C2/7D7A: 85 5C        STA $5C
	INC AtkMissed 	     						;C2/7D7C: E6 56        INC $56       (Attack Misses)
.Return
	RTS								;C2/7D7E: 60           RTS

endif