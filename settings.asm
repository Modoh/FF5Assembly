;Set pad byte to any freed space, $EA is NOP, $00 is BRK
padbyte $00

;Gameplay Options
!_CombatTweaks = 1		;applies combat formula tweaks, changing gameplay
				;actual code for this is in other asm files, but it removes the original code in this file when set
				;does not support StaticMode (will overflow size checks)

;Assembly Options (mostly for testing)
!_StaticMode = 0		;keeps functions and tables at their original starting location
				;restricts code size per-routine to the same size as the original
				;but useful for testing and may preserve compatibility with some binary patches
				
;these only apply in StaticMode
!_StaticPad = 0			;if set, wipes the extra space if routines are smaller than the original

!_StaticOverflow = 1		;allows routines to overflow past where they should end
				;unlikely for the resulting rom to work, but can be useful to troubleshoot assembler output

!_DumpAddr = 0			;prints all org addresses to console

