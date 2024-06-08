if !_Optimize || !_CantEvade_Doubles_M

incsrc "mod/utility/CalcDamageUtil.asm"

;Calculate Final Damage 
;similar to $8811/CalcFinalDamageMSword but doesn't have Magic Sword checks, and makes sure M is at least 1
;
;**bugfix: 	"can't evade" bit should also double damage	
;**optimize: 	used utility routines, shared with the other final damage routine
%sub(CalcFinalDamage)	
CalcFinalDamage:
	JSR CalcBaseDamage								
	LDX BaseDamage									
	BNE .CheckM		
        STX DamageToTarget  	
        RTS 			

.CheckM	
	LDX M								

if !_CantEvade_Doubles_M
	BNE .CheckCantEvade	;bug, the "can't evade"	check here is only hit if M was 0 (now 1)
else
	BNE .End							
endif
	INC M     		;min 1 for M					
	
.CheckCantEvade			
	JSR CantEvadeMod	;multiplies M by 2 if Can't Evade bit is set

.End	JMP CalcFinalDamageEnd													
	
endif