if !_Optimize || !_Fixes || !_CombatTweaks

incsrc "utility/damageutil.asm"

;Throw Damage formula
;Attack = Item Attack Power + (0..Item Attack/8)
;M = Level*Strength/128 + Level*Agility/128 + 2
;Defense = Target Defense
%subdef(ThrowDamage)
	LDX AttackerOffset					;C2/8299: A6 32        LDX $32
	LDA CharStruct.SelectedItem,X				;C2/829B: BD 5A 20     LDA $205A,X
	STA ThrownItem						;C2/829E: 8D 63 7C     STA $7C63
	REP #$20						;C2/82A1: C2 20        REP #$20
	JSR ShiftMultiply_4					;C2/82A3: 20 B7 01     JSR $01B7    (x4)
	STA $0E			;ItemID*4			;C2/82A6: 85 0E        STA $0E
	ASL          		;ItemID*8			;C2/82A8: 0A           ASL          (x2)
	CLC 							;C2/82A9: 18           CLC 
	ADC $0E			;ItemID*12			;C2/82AA: 65 0E        ADC $0E
	TAX 							;C2/82AC: AA           TAX 
	TDC 							;C2/82AD: 7B           TDC 
	SEP #$20						;C2/82AE: E2 20        SEP #$20
	LDA ROMItems.AtkPower,X					;C2/82B0: BF 07 00 D1  LDA $D10007,X
	JSR LoadAttackPower_DrinkOnly	;power drink fix
	TAX
	STX $0E       		;Item Attack			;C2/82B4: 85 0E        STA $0E       (Throw Damage)
	JSR ShiftDivide_8     	;Item Attack / 8		;C2/82B6: 20 BF 01     JSR $01BF     (Divide by 8)
	LDX #$0000						;C2/82B9: A2 00 00     LDX #$0000
	JSR Random_X_A     	;0..Item Attack / 8		;C2/82BC: 20 7C 00     JSR $007C     (0..(Throw Damage/8))
	REP #$21						;C2/82BF: 18           CLC 
	ADC $0E							;C2/82C0: 65 0E        ADC $0E
	STA Attack    	;Item Attack + 0..Item Attack / 8	;C2/82C2: 85 50        STA $50       (Damage = Throw Damage + (0..(Throw Damage/8))0
	
	JSR StrDamageCalc	;standard strength damage calc: M=Str*Lvl/128+2, Def=Target Def
	LDA Agility		;then add agility portion
	JSR StatTimesLevel
	JSR ShiftDivide_128
	CLC
	ADC M
	STA M
	TDC
	SEP #$20
	RTS
	
endif