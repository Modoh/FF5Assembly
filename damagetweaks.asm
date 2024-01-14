;Damage formula ASM mods
;Improve Bells/Rods formulas to make them somewhat usable
;Add Sta/Vit scaling to Brave Blade to make it compete better with Chicken Knife
;Fix Knives formula Agi scaling without making them overpowered
;Used some utility routines to save space (such as a generic stat*level)
;Includes a new Power Drink fix (one from Algo guide doesn't work with the other changes here)

;Swords damage formula
;Tweaks: Added Power Drink fix and refactored a bit for some code reuse
SwordDamage:
	JSR LoadAttackPower		;*Load Attack Power including Power Drinks
	TAX 	        		;
	STX $0E	        		;
	JSR ShiftDivide_8		;(Divide by 8)
	LDX #$0000			;
	JSR Random_X_A			;
	REP #$20			;
	CLC 	        		;
	ADC $0E    			;(Attack Power + (0..(Attack Power/8))
	STA Attack    			;
.StrCalc	
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

;Fists Damage Formula
;Tweaks: Power Drink fix and significant size optimization

;With Brawl:
;	Attack = Attack Power + Level*2 + 0..Level/4 + (50 with Kaiser Knuckles)
;	M = Level*Strength/256 + 2
;Without Brawl:
;	Attack = Attack Power + 0..Level/4
;	M = 2
;Defense = Target Defense
;
FistDamage:
	JSR LoadAttackPower
	TAX 							
	STX $0E			;Attack Power			
	TDC 							
	TAX 							
	LDA Level						
	JSR ShiftDivide_4					
	JSR Random_X_A						
	TAX 							
	STX $10			;0..Level/4			
	LDA Level   						
	JSR StatTimesLevel	;(Strength * Level), returns in 16 bit mode							
	JSR ShiftDivide_256	;/256
	INC
	INC			;+2
	STA M
	TDC
	SEP #$20
	LDX AttackerOffset					
	LDA CharStruct.Passives2,X				
	AND #$40    		;Brawl				
	BEQ .NoBrawl						
	LDA Level
	REP #$20		
	ASL			;Level *2, also clears carry since level*2 can't overflow
	ADC $10			;+0..Level/4			
	ADC $0E			;+Attack Power			
	STA Attack		;Attack Power + Level*2 + 0..Level/4
	TDC 							
	SEP #$20						
	LDX AttackerOffset					
	LDA CharStruct.ArmorProperties,X 			
	AND #$20    		;Improved Brawl			
	BEQ .Def						
	REP #$21		;also clears carry													
	LDA Attack						
	ADC #$0032		;+50				
	STA Attack									
	BRA .Def
	
.NoBrawl	
	REP #$21		;also clears carry				 							
	LDA $0E     		;Attack Power			
	ADC $10     		;+ 0..Level/4			
	STA Attack
	LDA #$0002
	STA M
	
.Def	JMP NormalDefense16							


;Knives damage formula
;Tweaks:
;Power Drink fix and related changes to account for possible attack power overflow
;Fixes agi bug where it ignored high byte of result
;Reduced stat scaling to /256 instead of /128 and changes static value to 3 to offset rounding loss
;Goal is to restore bugged str/agi scaling without also making them too good and overshadow str weapons for str classes

;Attack = Attack Power + 0..3
;M = Level*Strength/128 + Level*Agility/128 + 3
;Defense = Target Defense

KnifeDamage:
	JSR LoadAttackPower	;*Load Attack Power including Power Drinks
	TAX
	STX Attack		
	TDC
	TAX 		
	LDA #$03		
	JSR Random_X_A 		;(0..3)
	REP #$21 		;*saves a byte by clearing carry alongside m flag
	ADC Attack    		;(Attack Power + (0..3))
	STA Attack
	TDC
	SEP #$20
	LDA Strength  		
	JSR StatTimesLevel	;Stat * Level, returns in 16 bit mode
	JSR ShiftDivide_256    	;Divide by 256 instead of 128
	STA $0E		
	TDC 		
	SEP #$20		
	LDA Agility   		
	JSR StatTimesLevel	;Stat * Level, returns in 16 bit mode
	JSR ShiftDivide_256	;Divide by 256 instead of 128
	CLC 		
	ADC $0E      		;(Level*Strength)/256 + (Level*Agility)/256
	INC
	INC
	INC			;+3
	STA M		
	JMP NormalDefense16 			


;Axes Damage formula
;Tweaks: Power Drink fix, size optimization

;Attack = Attack Power / 2 + 0..Attack Power
;M = Level*Strength/128 + 2
;Defense = Target Defense / 4
AxeDamage:
	JSR LoadAttackPower	;*Load Attack Power including Power Drinks
	TAX 
	STX $0E
	LSR $0E      		;(Attack Power/2)
	LDX #$0000		;
	JSR Random_X_A		;(0..Attack Power)
	REP #$21		;also clears carry
	ADC $0E      		;(Attack Power/2) + (0..Attack Power)
	STA Attack		
	JSR SwordDamage_StrCalc ;Swords do nearly the same thing as axes
	LSR Defense+1
	ROR Defense
	LSR Defense+1		
	ROR Defense		;Defense/4
	RTS 			

;Bells Damage formula
;Tweaks:
;Increases bell damage from 50-100% base damage to 50-125%
;Also divides mdef by 2
;Goal is to make bells usable and have a purpose
;Overrides Attack Power with Param 2 (for harp magic mod, but applies to bells too if data is changed)
BellDamage:
	LDA Param1		;*param 1						
	BNE .SkipBP		;*if set, use Param 1 instead of BP			
	JSR LoadAttackPower	;*load Attack Power including Power Drinks 		
.SkipBP
	LSR          		;(Attack Power/2)
	TAX 		
	STX $0E			
	LSR			;AP/4
	ADC $0E			;AP/2 + AP/4 (effectively AP * 75%)
	LDX #$0000		
	JSR Random_X_A 		;(0..(AP/2 + AP/4))
	REP #$21		;*saves a byte by clearing carry alongside m flag	
	ADC $0E      		;(Attack Power/2) + (0..(AP/2 + AP/4))
	STA M		
	TDC 		
	SEP #$20		
	LDA Agility    	
	JSR StatTimesLevel	;returns in 16 bit mode					
	JSR ShiftDivide_128	
	STA $0E		
	TDC 		
	SEP #$20		
	LDA MagicPower							
	JSR StatTimesLevel	;returns in 16 bit mode
	JSR ShiftDivide_128	
	CLC 		
	ADC $0E      		;(Level*Agility)/128 + (Level*Magic Power)/128
	INC
	INC			;+2
	STA M		
	JSR NormalMDefense16	;returns in 8 bit mode
	LSR Defense+1
	ROR Defense		;Def/2
	RTS

 
;Rods damage formula
;Changes rod damage from 0-200% base damage to 100-200%
;Goal is to make rods not hit for 0 all the time
RodDamage:
	JSR LoadAttackPower	;*Load Attack Power including Power Drinks
	TAX	
	STX $0E			
	LDX #$0000		
	JSR Random_X_A 		;(0..Attack Power)
	REP #$21		;*saves a byte by clearing carry alongside m
	ADC $0E			;(Attack Power) + (0..Attack Power)
	STA Attack		
	TDC 		
	SEP #$20     		
	LDA MagicPower    	
	JSR StatTimesLevel	;Stat * Level, returns in 16 bit mode
	JSR ShiftDivide_256	;/256
	INC
	INC			;+2
	STA M		
	JMP NormalMDefense16	


;Monster damage formula
;Tweaks: 	Just updating to work with power drink fix.  
;		Not likely to occur, but it worked for them in vanilla if you used some chemistry on them
;		and needs changes to work with the new power drink 
MonsterDamage:
	LDX AttackerOffset						
	LDA CharStruct.MonsterAttack,X					
	JSR LoadAttackPower_DrinkOnly_SkipX
	STA $0E
	STZ $0F
	JSR ShiftDivide_8  						
	LDX #$0000							
	JSR Random_X_A 							
	REP #$21				;also clears carry 								
	ADC $0E    							
	STA Attack
	TDC
	SEP #$20
	LDX AttackerOffset						
	LDA CharStruct.MonsterM,X					
	TAY 								
	STY M								
	JMP NormalDefense					

;Brave Blade Damage formula
;Add a Vit/256 factor to M
BraveDamage:
	JSR LoadAttackPower	;*Load Attack Power including Power Drinks
	SEC 
	SBC BattleData.Escapes   		;(Attack = Attack - # times escaped)
	BCS +			;
	TDC 			;min 0
+
	TAX          		
	STX Attack
	LDA Vitality  		
	JSR StatTimesLevel 	;Stat * Level, returns in 16 bit mode
	JSR ShiftDivide_256	;/256
	STA M			;
	JMP SwordDamage_StrCalc	;*add str and finish up in sword routine

;Goblin Punch Damage formula
;nothing wrong with it in vanilla but updated to work with new Power Drink fix
GoblinDamage:
	LDX AttackerOffset
	LDA CharStruct.MonsterAttack,X		
	JSR LoadAttackPower_DrinkOnly_SkipX	;Add Power Drink and cap at 255
	STA Attack
	STZ Attack+1				;Clearing high byte
	LDA AttackerIndex			;Attacker Index
	CMP #$04				;Check if attacker is a monster
	BCS .Monster 				;Monsters don't need the rest of this	
	LDA CharStruct.MonsterAttackLH,X		
	JSR LoadAttackPower_DrinkOnly_SkipX	;Add Power Drink and cap at 255	
	REP #$21				;16 bit and clear carry
	ADC Attack				;Left + Right inlcuding drinks
	STA Attack	
	JMP SwordDamage_StrCalc			;*apply str and finish calculations in swords routine
.Monster			
	LDA CharStruct.MonsterM,X		;
	TAX 				
	STX M    				;(M = Monster Attack Multiplier)
	JMP NormalDefense			

;Strong Fight Damage
;Tweaks: 	Just updating to work with power drink fix.  
;		Not likely to occur (impossible in vanilla?) 
;		but vanilla code would have worked so fixing it here
StrongFightDamage:
	LDX AttackerOffset													
	LDA CharStruct.MonsterAttack,X
	JSR LoadAttackPower_DrinkOnly_SkipX
	STA $0E	
	REP #$20						
	JSR ShiftMultiply_8					
	STA Attack    						
	TDC 							
	SEP #$20						
	LDA CharStruct.MonsterM,X				
	TAX 							
	STX M
	LDA $0E
	JSR ShiftDivide_8					
	LDX #$0000						
	JSR Random_X_A 						
	REP #$21			;also clears carry
	ADC Attack 						
	STA Attack    						
	JMP NormalDefense16
;

;Chicken Knife Damage Formula
;Power Drink fix and refactoring to free space
ChickenDamage:
	LDA BattleData.Escapes		;Flee Count
	LSR				;divide by 2
	JSR LoadAttackPower_DrinkOnly	;*add Power Drink effects (only)
	TAX 
	STX Attack
	LDA Agility			;(Agility)
	JSR StatTimesLevel		;(Level * Agility) 
	JSR ShiftDivide_128    		;(Level * Agility)/128
	STA M      			;
	JMP SwordDamage_StrCalc		;*add str and finish up in sword routine
					
;Increase Attack (Power Drink)
;Changing it from updating $2044 and $2045 which are only used by goblin punch
;Instead it now updates $2079 which seems is unused and initialized to zero 
IncreaseAtk:
	LDX TargetOffset
	CLC 
	LDA CharStruct.Unused3,X	;*new memory location for power drinks
	ADC Param3
	BCC +
	LDA #$FF    		;max 255
+	STA CharStruct.Unused3,X
	RTS		

;Loads Attack Power including Power Drinks
;Returns: 	Total Attack Power in A (capped at 255)
LoadAttackPower:
	LDA AttackerOffset2
	TAX
	LDA AttackInfo.AtkPower,X		;(Attack Power)
.DrinkOnly					;Use this label to add Power Drink to a different base BP
	LDX AttackerOffset			;
..SkipX						;Can skip the X load if not needed
	CLC		
	ADC CharStruct.Unused3,X		;Unused byte in char data repurposed for Power Drink
	BCC .Ret				;
	LDA #$FF				;255 cap
.Ret	RTS					;17 bytes used

;Stat times Level utility routine
;Params: 8 bit Stat in A
;Returns: 16 bit result in A 
;Note: 	Call in 8 bit mode, returns in 16 bit mode
;	This is strange but allows us to follow original code flow without wasting space
StatTimesLevel:
	STA $24	
	LDA Level  		;(Level)
	STA $25	
	JSR Multiply_8bit	;(Stat * Level)
	REP #$20
	LDA $26
	RTS			

NormalDefense16:
	TDC
	SEP #$20
NormalDefense:
	LDX TargetOffset      		
	LDA CharStruct.Defense,X	
	TAX 
	STX Defense
	RTS 
	
NormalMDefense16:
	TDC
	SEP #$20	
NormalMDefense:
	LDX TargetOffset	
	LDA CharStruct.MDefense,X  		;(Magic Defense)				
	TAX 	
	STX Defense
	RTS
