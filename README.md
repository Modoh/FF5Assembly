# FF5Assembly

Complete assembly code for FF5's C2 bank (battle logic). 

This isn't just commented diassembly.   All of the addresses are labeled, so code can be added easily without being limited by the size of the original routines, just the size of the entire bank.   The ff5_structures file is also useful as a fairly complete memory map. 

Optionally, some gameplay tweaks and bug fixes can be enabled.  Right now, that includes allowing Magic Sword with more weapon types, adjusting damage formulas for knives and a few others, and fixing Power Drinks.   These haven't been tested much yet and I plan to expand on this side of things, such as implementing Sword Slap.  Regardless, the original code and behavior will always be available.

Assembles with the Asar assembler (v1.81), patching over an existing FF5 rom.   Can be configured to generate byte identical data to the original rom.   It should work with any FF5 rom or hack of it, but will overwrite any changes in the battle portion of the C2 bank ($C20000-C29FFF).   The menu code starting at $C2A000 is unaffected (which is good, because most translations make changes there).   

I don't currently have plans to expand this project outside the C2 bank battle code, but that could change in the future. 
