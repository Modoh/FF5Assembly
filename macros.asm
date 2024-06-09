if !assembler_ver > 10801
	print "In testing, versions of Asar newer than 1.81 (compiled from source) caused problems, and its error reporting was broken.  Use version 1.81 instead or proceed at your own risk!"
endif

if !assembler_ver < 10801
	print "Untested in versions of Asar older than 1.81"
endif

if !_StaticMode && !_CombatTweaks
	error "Combat Tweaks are not compatible with Static Mode, turn one of them off in settings.asm"
endif

!_SubRollback = 0

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

macro sub(label)
;macro for subroutine substitution (attempts to load code from file and removes original code if succesful)
;this could, in theory, be extended to handle multiple mod directories then report any conflicts

	;!_SubSentinel is used to track whether we're in a subroutine, to catch errors
	
	if defined("_SubSentinel")
		assert !_SubSentinel == 0,"subroutine macro called inside a subroutine"
	endif

	if !_ModFiles && not(defined("<label>"))
		if not(getfilestatus("mod/<label>.asm"))	;getfilestatus returns 0 if file exists and is readable
			incsrc "mod/<label>.asm"
			if !_ReportMods
				if defined("<label>")
					print "Loaded file mod/<label>.asm -- Replaced routine <label> from file"
				else
					print "Loaded file mod/<label>.asm -- Label <label> not defined, using original code for routine"
				endif
			endif
		endif
	else
		if defined("<label>")
			if !_ReportMods
				print "Label <label> was already defined, skipping both mod file and original code"
			endif
		endif
	endif

	!_SubSentinel = 1	;flags that we're in a replacable subroutine

	if defined("<label>")
		!_SubRollback = 1
		pushpc
	else
		!_SubRollback = 0
		<label>:
	endif
	
	

	;original code follows this macro 
	;it will be skipped if modded asm is used instead
	;endsub macro will close the if statement
endmacro

macro endsub()
;ends the wrapping if statement around a routine started with sub macro

	;this check is in case we're not in an if statement, since endif will error out anyway
	assert !_SubSentinel,"endsub macro called without a matching sub macro"	
	
	if !_SubRollback == 1
		warnpc $C2A000
		pullpc
		!_SubRollback = 0
	endif
	
	!_SubSentinel = 0
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

;overrides table name of Attack types to AtkTypeJumpTable
if stringsequal("<name>","Attack")
	!_tempname = AtkTypeJumpTable
else
	!_tempname = <name>
endif

print "!_tempname jump table generating at ",hex(!_tempname)
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
