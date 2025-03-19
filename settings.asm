;Sets byte to fill any freed space, $EA is NOP, $00 is BRK
padbyte $00

;Gameplay Options
!_ModFiles = 1			;determines whether modded routines will be loaded from mod folder
				;required for any gameplay tweaks/fixes/optimizations to load
				
!_Optimize = 1			;enables replacing routines with size optimized versions
				;most of the other additions need this to be on for there to be enough space
				;should not modify game behavior on its own

!_Fixes = 1			;fixes gameplay bugs
				;intentionally doesn't include many beneficial bugs
				
!_CombatTweaks = 1		;applies combat formula tweaks, changing gameplay
				;magic sword with more weapon types
				;double hand with spears
				;rod/bell/harp/brave formula improvements
				
				;if your equipment has all the element ups (ignoring holy), 
				;you get +water (since there's no other way for items to give +water)
				;only really applies to wizard rod in vanilla FF5
				
;Individual Fixes, not included in the above !_Fixes set 
!_Overpowered_Knife_Fix = 0	;Directly fixes the knife agi bug with no concern for balance
				;only recommended if you're also lowering knife/agi weapon attack values or something
				;normal knife fix:	Str*Lvl/256 + Agi*Lvl/256 + 3  (included in !_Fixes and !_CombatTweaks)
				;overpowered fix: 	Str*Lvl/128 + Agi*Lvl/128 + 2
				;vanilla knives:	Str*Lvl/128 + [bugged 0 or 1] + 2

!_CantEvade_Doubles_M = 1	;There's code for the "can't evade" bit to double M when calcuating damage
				;but it (almost) never applies due to a bug
				;leaving it separate until balance impact is tested

!_Fix_Stat_Underflow = 0	;Fixes stat underflow for character equipment
				;usually seen with Berserkers + Thornlet for ~250 magic power

;Some bigger individual gameplay changes not included in Combat Tweaks
!_BerserkerCommands = 1		;Berserk uses random equipped commands
				; 33% chance per slot
				; invalid commands convert to fight

!_ArmorEvade = 1		;Normally the game doesn't load evasion values from armor, now it does
				;this still doesn't load evade from weapons, 
				;because that byte is reused for item magic like rod breaking

!_StackingDefender = 0 		;Allows the bonus weapon evades of the same type to stack, 
				;using the extra bit $10 in WeaponProperties
				;
				
;Test/Debug options
!_DumpAddr = 0			;prints all org addresses to console

!_ReportMods = 1		;prints all mod asm files that were loaded

!_StaticMode = 0		;keeps functions and tables at their original starting location
				;restricts code size per-routine to the same size as the original
				;this is useful for ensuring that the compiler output matches original ff5
				;but won't work with the mod file system
				
;these only apply in StaticMode
!_StaticPad = 0			;if set, wipes the extra space if routines are smaller than the original

!_StaticOverflow = 0		;allows routines to overflow past where they should end
				;unlikely for the resulting rom to work, but can be useful to troubleshoot assembler output


