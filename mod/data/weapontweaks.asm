;Data mods to items
;Adds Spellblade (grapical effect) support to Axes/Spears/Katanas/Rune
;Adds Double Grip (Optional) to Spears
;Changes Harps to not be so useless
;Drain Blade Hit% buff so it's somewhat usable without being a Freelancer/Mime

hirom 

;Magic:
;Target Bitmask
;Attack type Bitmask
;Learnable/Hits
;Reflectable/MP Cost
;
;Unavoidable/Formula
;Param1
;Param2
;Param3

;Harp Magic
;Silver Harp is still gravity but upgraded
;Dream/Lamia Harps now use the bell formula which uses different parameters
;Currently fixed 75% status chance (was dependant on magic hit% before but bells don't miss)
;Requires Attack Type asm (without it will apply "random" statuses to target)
org $d10f20
db $08,$20,$00,$80,$07,$63,$04,$00	;Silver Harp Spell, changed gravity potency from 1/16 to 4/16
db $08,$20,$00,$80,$2F,$19,$4B,$40	;Dream Harp Spell, changed to 25 power bell attack 
db $08,$20,$00,$80,$2F,$1E,$4B,$10	;Lamia Harp Spell, changed to 30 power bell attack

;Harp Weapon Stats
;Updating displayed weapon power to match the spells that they cast
;Even though the value is only used for Goblin Punch

org $d10354
db $78,$20,$4E,$80,$9B,$08,$78,$0F,$7F,$00,$64,$74 	;Silver 
db $78,$20,$4E,$80,$9B,$08,$78,$19,$7F,$00,$63,$75 	;Dream
db $78,$20,$4E,$80,$9B,$08,$78,$1E,$7F,$00,$63,$76 	;Lamia - changed displayed power to 30 to match updated spell
db $78,$20,$4E,$80,$9B,$08,$78,$4B,$7F,$00,$63,$77	;Apollo - changed displayed power to 75 to match its spell (which wasn't changed)

;78 20 4E 80 9B 08 78 0F 7F 00 64 74 
;78 20 4E 80 9B 08 78 19 7F 00 63 75 
;78 20 4E 80 9B 08 78 23 7F 00 63 76 
;78 20 4E 80 9B 08 78 2D 7F 00 63 77							

;Weapons:
;Weapon properties:
;	0 Targeting (when used as item) 
;	    80 Multi-target optional 
;	    40 Hits all targets 
;	    20 Target selectable 
;	    10 Side selectable 
;	    08 Target enemy (by default) 
;	    04 Roulette 
;	    02 
;	    01 
;  	1 Action type
;	    80 Physical 
;	    40 Aerial (weapons) 
;	    20 Song 
;	    10 Summon 
;	    08 Dimen 
;	    04 Black 
;	    02 White 
;	    01 Blue 
;	2 Throw + Equipment type value 
;		40 NOT throwable 
;		20-01 Table of "sets" of classes that can use it
;	3 Element/stats up 
;		80 Stats up ->
;		40 Wind         Strength
;		20 Earth        Speed
;		10 Holy         Vitality
;		08 Poison       Magic power
;		04 Lightning    \
;		02 Ice           Stat bonuses
;		01 Fire         /
;	Stat bonuses
;		    0 +1 
;		    1 +2 
;		    2 +3 
;		    3 +1/-1/+1/-1 (not used) 
;		    4 -1 (use inverted stat selection) (not used) 
;		    5 +5/-5/+5/-5 (Giant Gloves) 
;		    6 -5 (use inverted stat selection) 
;		    7 +5 
;	4 Double Grip + Description
;		80 Double Grip only 
;		40 Double Grip allowed 
;		20-01 Table of which "equip notes" description to display, such as "Magic Sword OK"
;	5 Special properties 
;		80h: Sword parry (Hardened, Defender) 
;		40h: Knife parry (Guardian) 
;		20h: Initiative
;		08h: Action on hit
;		04h: Magic Sword OK
;		02h: Ability instead of attack
;		01h: Wonder Rod
;	6 Used as item:
;		80: Breaks after Use
;		40-01 Magic cast
;	7 Attack power 
;	8 Attack formula 
;	9 Parameter 1 	(See table below for what various weapon types use these for)
;	A Parameter 2  	(For most atk types this is Proc chance)
;	B Parameter 3  	(For most atk types this is Proc Command/Magic)

;Description table:
;01	 Restores HP
;02	 Restores MP
;03	 Completely restores HP/MP
;04	 Recovers the wounded
;05	 Cures ‘Frog’ status
;06	 Cures ‘Zombie’ status
;07	 Ingredient for ‘Mix’
;08	 Cures ‘Poison’ status
;09	 Cures ‘Darkness’ status
;0A	 Cures ‘Stone’ status
;0B	 Cures ‘Mini’ status
;0C	 Summons an Esper when used in battle
;0D	 Rest a night to recover health
;0E	 ‘Drink’ to double max  HP
;0F	 ‘Drink’ to raise attack power
;10	 ‘Drink’ to cause effect of ‘Haste’
;11	 ‘Drink’ to raise defense power
;12	 ‘Drink’ to raise all   powers
;13	 Use at menu screen to learn an Esper spell
;14	 ‘Throw’ to damage all enemies
;15	 ‘Double Grip’ OK       ‘Magic Sword’ OK
;16	 ‘Magic Sword’ OK
;17	 ‘Jump’ to double attack power
;18	 Back row OK            ‘Double Grip’ OK
;19	 ‘Double Grip’ OK
;1A	 ‘Double Grip’ OK
;1B	 ‘Double Grip’ only     Back row OK
;1C	 Halves MP cost in battle
;1D	 Improves ‘Steal’ success rate
;1E	 Improves flame/cold/thunder/poison/earth damage
;1F	 Improves power of ‘Holy’!
;20	 Prevents Zombie/Aging
;21	 Prevents most status ailments
;22	 Absorbs water,nullifies flame, weak again…
;23	 Back row OK
;24	 Improves ‘Brawl’ performance!
;25	 Improves ‘Control’ success rate!
;26	 Becomes easier to ‘Catch’ monsters
;27	 ‘Your bravery praised for victory over …
;28	 ‘Your wisdom and bravery prevailed…
;29	 Uses MP for its power   ‘Double Grip’ OK
;2A	 Steadily decreases HP
;2B	 Undead armor!
;2C	 A Shield that does not evade
;2D	 A ring lain with a curse of ‘Doom’!

;Params for various weapon types:
;Swords:		Element     	Proc%         	Proc
;Knives:     	Element     	Proc%         	Proc
;Spears:     	Element     	Proc%         	Proc
;Axes:         	Hit%        	Proc%         	Proc
;Bows(35):    	Hit%        	Status%+TypeBit	Status
;Bows(36):    	Hit%        	Crit%        	Element
;Katanas:    	Crit%        	Proc%        	Proc
;Whips:        	Hit%        	Proc%        	Proc
;Bells:        	?        		Proc%        	Proc		
;Long Axes:    	Hit%        	Proc%        	Proc
;Rods:        	Hit%        	?        		Element
;Rune:        	Hit%        	Dmg Boost    	MP Cost
;Bows(72):    	Creature Type   ?        	?
;Spears(73):    Creature Type   ?        	?
;? entries are probably unused
;this table is for vanilla, asm mod makes first bell param override attack power if non-zeros (for use with harps)
;nothing uses bell procs in vanilla because earth bell was on a different formula, it works in testing though

;Swords
org $d103fc
db $38,$80,$45,$8F,$00,$00,$78,$54,$0D,$42,$54,$00		;Drain Sword, changed to 66% hit from 25%
								;Doesn't support spellblade because it uses drain formula
db $38,$80,$44,$80,$69,$04,$78,$32,$3C,$63,$14,$08		;Rune Edge - Enable Spellblade (byte 6 add $04)

;Spears
;		Enable Spellblade (byte 6 add $04)
;		Enable Optional Two Handed (byte 5 add $40)
;		Description change to Magic Sword/Spellblade OK instead of Jump Double (we can't have both listed)
org $d10114
db $38,$80,$06,$C0,$55,$04,$78,$37,$33,$00,$00,$00 		;Javelin
db $38,$80,$06,$A0,$55,$04,$78,$19,$33,$00,$00,$00 		;Spear
db $00,$80,$06,$80,$55,$04,$78,$1E,$33,$00,$00,$00 		;Mythril
db $00,$80,$06,$80,$55,$04,$78,$26,$33,$04,$00,$00 		;Trident
db $00,$80,$06,$80,$55,$04,$78,$2C,$33,$40,$00,$00 		;Wind
db $00,$80,$06,$80,$55,$04,$78,$3E,$33,$00,$00,$00 		;Partisan
db $00,$80,$06,$80,$55,$04,$78,$36,$33,$00,$00,$00		;Gungnir
db $00,$80,$1E,$80,$00,$02,$78,$3D,$33,$00,$64,$55 		;Double Lance	;This casts a double attack spell instead of attacking, not enabling spellblade gfx until I'm sure it doesn't break
db $00,$80,$06,$C2,$55,$04,$78,$6D,$33,$10,$00,$00		;Holy
db $00,$80,$06,$80,$55,$04,$78,$77,$73,$10,$00,$00		;Dragoon
org $d10504
db $38,$80,$55,$F9,$16,$04,$78,$59,$73,$80,$00,$00		;ManEater	;Uses spear damage formula, we add spellblade but not double grip because it's kind of a dagger

;Axes/Hammers
;		Enable Spellblade (byte 6 add $04)
;		Description change to Magic Sword/Spellblade OK
org $d1018c
db $00,$80,$07,$80,$55,$04,$78,$17,$34,$50,$00,$00		;Battle
db $38,$80,$48,$80,$55,$04,$78,$1C,$34,$50,$00,$00 		;Mythril
db $00,$80,$47,$80,$55,$04,$78,$21,$34,$50,$00,$00 		;Ogre
db $00,$80,$08,$80,$55,$04,$78,$26,$34,$50,$00,$00 		;War
db $00,$80,$07,$80,$55,$0C,$78,$30,$34,$50,$43,$27 		;Venom
db $00,$80,$08,$20,$55,$06,$78,$3A,$3A,$50,$19,$56 		;Earth
db $00,$04,$07,$8A,$69,$04,$78,$47,$3C,$5A,$0A,$05 		;Rune		;Won't say Spellblade OK because it says uses MP instead
db $00,$40,$48,$80,$58,$04,$78,$51,$3A,$50,$00,$00		;Thor		;Won't say Spellblade OK because it says Back Row OK instead
org $d104ec
db $38,$80,$47,$80,$55,$0C,$78,$2B,$34,$55,$21,$34 		;Doom
db $38,$80,$47,$80,$55,$04,$78,$5B,$34,$5A,$00,$00		;Giant

;Katana
;		Enable Spellblade (byte 6 add $04)
;		Description change to Magic Sword/Spellblade OK
org $d101ec
db $00,$80,$09,$80,$55,$04,$78,$2A,$37,$0C,$00,$00 		;Katana
db $38,$80,$09,$40,$55,$06,$78,$2C,$37,$0C,$0C,$53 		;Air Blade
db $00,$80,$09,$80,$55,$04,$78,$3A,$37,$0C,$00,$00 		;Kotetsu
db $00,$80,$09,$80,$55,$04,$78,$33,$37,$0C,$00,$00 		;Bizen
db $00,$80,$09,$80,$55,$04,$78,$57,$37,$0C,$00,$00 		;Forged
db $00,$80,$09,$80,$55,$04,$78,$61,$37,$19,$00,$00 		;Murasame
db $30,$80,$09,$80,$55,$24,$3A,$6B,$37,$0F,$00,$00 		;Masamune
db $00,$80,$09,$80,$55,$04,$78,$75,$37,$14,$00,$00		;Tempest

;Bells
;		Only the noted changes for now
;		May end up increasing atk power eventually but would have to do a run with Geo first
org $d103c0
db $38,$20,$50,$80,$23,$00,$78,$18,$39,$00,$00,$00		;Giyaman
db $38,$20,$50,$20,$23,$02,$78,$23,$39,$00,$21,$56		;Earth		;switched to bell formula, changed to 33% chance to cast, from 25%
db $38,$20,$50,$7F,$16,$04,$78,$2D,$3C,$63,$0A,$05		;Rune		;added spellblade effects and Spellblade OK desc since Rune formula applies them
db $38,$20,$50,$80,$23,$00,$78,$37,$39,$00,$00,$00		;Tinker

;Currently non-spellbladed items/attacks include Whips, Chakram, Flails, Bows, Non-Rune bells, Rods, Staves, Fists
