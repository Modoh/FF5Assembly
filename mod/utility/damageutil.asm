includeonce

;Loads Attack Power including Power Drinks
;Returns: 	Total Attack Power in A (capped at 255)
%subdef(LoadAttackPower)
	LDA AttackerOffset2
	TAX
	LDA AttackInfo.AtkPower,X		;(Attack Power)

.DrinkOnly					;Use this label to add Power Drink to a different base BP
						;does nothing past here without fixes applied, to keep original behavior
if !_Fixes || !_CombatTweaks
	LDX AttackerOffset			;
	CLC		
	ADC CharStruct.DrinkAtk_Bugfix,X	;Unused byte in char data repurposed for Power Drink
	BCC .Ret				;
	LDA #$FF				;255 cap
endif

.Ret	RTS					;17 bytes used

;Stat times Level utility routine
;Params: 8 bit Stat in A
;Returns: 16 bit result in A 
;Note: 	Call in 8 bit mode, returns in 16 bit mode
;	This is strange but allows us to follow original code flow without wasting space
%subdef(StatTimesLevel)
	STA $24	
	LDA Level  		;(Level)
	STA $25	
	JSR Multiply_8bit	;(Stat * Level)
	REP #$20
	LDA $26
	RTS			

;standard strength calculation
;calling in 16 bit mode is ok
;M=Str*Lvl/128+2, Def=Target Def
%subdef(StrDamageCalc)	
	TDC 	        		;
	SEP #$20			;
	LDA Strength  			;(Strength)
	JSR StatTimesLevel		;(Strength * Level), returns in 16 bit mode
	JSR ShiftDivide_128		;(Divide by 128)
	CLC 	        		;
	ADC #$0002 			;(+2)
	ADC M				;*this is 0 for swords but may have something stored if this code used by other types
	STA M	        		;
	JMP NormalDefense16


%subdef(NormalDefense16)
	TDC
	SEP #$20
%subdef(NormalDefense)
	LDX TargetOffset      		
	LDA CharStruct.Defense,X	
	TAX 
	STX Defense
	RTS 
	
%subdef(NormalMDefense16)
	TDC
	SEP #$20	
%subdef(NormalMDefense)
	LDX TargetOffset	
	LDA CharStruct.MDefense,X  		;(Magic Defense)				
	TAX 	
	STX Defense
	RTS
