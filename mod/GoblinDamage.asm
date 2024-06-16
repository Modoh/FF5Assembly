if !_Fixes || !_Optimize || !_CombatTweaks 

incsrc "utility/damageutil.asm"

;Goblin Punch Damage formula
;nothing wrong with it in vanilla but updated to work with new Power Drink fix and optimized
%subdef(GoblinDamage)
	LDX AttackerOffset
	LDA CharStruct.MonsterAttack,X		
	JSR LoadAttackPower_DrinkOnly		;Add Power Drink and cap at 255
	STA Attack
	STZ Attack+1				;Clearing high byte
	LDA AttackerIndex			;Attacker Index
	CMP #$04				;Check if attacker is a monster
	BCS .Monster 				;Monsters don't need the rest of this	
	LDA CharStruct.MonsterAttackLH,X		
	JSR LoadAttackPower_DrinkOnly		;Add Power Drink and cap at 255	
	REP #$21				;16 bit and clear carry
	ADC Attack				;Left + Right inlcuding drinks
	STA Attack	
	JMP StrDamageCalc			;apply str and finish calculations
.Monster			
	LDA CharStruct.MonsterM,X		;
	TAX 				
	STX M    				;(M = Monster Attack Multiplier)
	JMP NormalDefense			


endif