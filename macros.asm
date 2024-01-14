if !assembler_ver > 10801
	print "In testing, versions of Asar newer than 1.81 (compiled from source) caused problems, and its error reporting was broken.  Use version 1.81 instead or proceed at your own risk!"
endif

if !assembler_ver < 10801
	print "Untested in versions of Asar older than 1.81"
endif

if !_StaticMode && !_CombatTweaks
	error "Combat Tweaks are not compatible with Static Mode, turn one of them off in settings.asm"
endif

macro org(address)		
;macro used instead of regular org command that can optionally be ignored
;also warns if routines overflow, but routines need to be in address order
;most of what I wanted here doesn't work because asar has a bunch of undocumented limitations
;	?here:
	
	if !_DumpAddr 
		print "PC: ",pc,", org: ",hex(<address>)
	endif
		
	if !_StaticMode 
;		if !_StaticReportGap && realbase() < <address>
;			!_diff #= <address>-realbase()
;			print "Gap at ",hex(realbase()),": ",dec(!_diff)," bytes"
;		endif
		
		if !_StaticOverflow 
;			!_diff #= realbase()-<address>
;			if !_diff > 0
;				print "Overflow at ",pc,", continuing anyway..."
;			endif
		else
			warnpc <address>
		endif	
		
		if !_StaticPad
			pad <address>		
		else
			org <address>				
		endif
	endif
endmacro
	
;macro stuff to generate attack type table
;there has to be a better way to do this, but hex() in asar is print-only and I can't come up with anything else
macro singlehex(number)
	if <number> < 10
		!_output := <number>
	elseif <number> == 10
		!_output := "A"
	elseif <number> == 11
		!_output := "B"
	elseif <number> == 12
		!_output := "C"
	elseif <number> == 13
		!_output := "D"
	elseif <number> == 14
		!_output := "E"
	elseif <number> == 15
		!_output := "F"
	endif	
endmacro

macro hexstring(number)

	!_low #= <number>%16
	!_high #= <number>/16
		
	%singlehex(!_low)
	!_second := !_output
	%singlehex(!_high)
	!_first := !_output
	!_output := !_first!_second
endmacro

macro generatejumptable(name, number)
;generates jump table with format:
;dw <name>00
;dw <name>01
;..
;dw <name><number>

if stringsequal("<name>","Attack")
	!_tempname = AtkTypeJumpTable
else
	!_tempname = <name>
endif

print "<name> jump table generated at ",hex(!_tempname)
!_i = 0
while !_i <= <number>
	%hexstring(!_i)
	dw <name>!_output
	if !_DumpAddr
		print "<name>!_output at ",hex(<name>!_output,4)
	endif
	!_i #= !_i+1
endif	;newer versions of asar prefer endwhile, but those versions currently seem broken in other ways

endmacro
