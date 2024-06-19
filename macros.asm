if !assembler_ver > 10801
	print "In testing, versions of Asar newer than 1.81 (compiled from source) caused problems, and its error reporting was broken.  Use version 1.81 instead or proceed at your own risk!"
endif

if !assembler_ver < 10801
	print "Untested in versions of Asar older than 1.81"
endif

if !_StaticMode && !_ModFiles
	error "Static Mode is not compatible with loading any mod files, turn one of them off in settings.asm"
endif

!_SubSentinel = 0
!_SubRollback = 0

macro org(address)		
;macro used instead of regular org command that can optionally be ignored
;also warns if routines overflow, but routines need to be in address order
;most of what I wanted here doesn't work because asar has a bunch of undocumented limitations
	
	if !_DumpAddr 
		print "Current PC: ",pc,", Original Vanilla Address: ",hex(<address>)
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

macro subdef(label)
	!_SubDefined_<label> = 1
	if !_DumpAddr 
		print "Mod Routine Defined: <label> at PC: ",pc
	endif
	
	
;	error !_SubDefined_<label>
;	error !_SubDefined_<label>
	<label>:
endmacro

macro sub(label)
;macro for subroutine substitution (attempts to load code from file and removes original code if succesful)
;this could, in theory, be extended to handle multiple mod directories then report any conflicts

;not all that happy with how hacky this got, shame the original simple version didn't work

	;!_SubSentinel is used to track whether we're in a subroutine, to catch errors

	;assert !_SubSentinel,"subroutine macro called inside a subroutine"
	;asar's assert routine is apparently worthless, so we do it manually
	if !_SubSentinel
		error "subroutine macro for <label> called inside another subroutine"
	endif

	if !_ModFiles 
		if defined("_SubDefined_<label>")
			if !_ReportMods
				print "Label <label> was already defined, skipping any mod files and original code"
			endif
		else
			if not(getfilestatus("mod/<label>.asm"))	;getfilestatus returns 0 if file exists and is readable
				incsrc "mod/<label>.asm"
				if defined("_SubDefined_<label>")	;check if the included file defined this routine
					if !_ReportMods
						print "Loaded file mod/<label>.asm -- Replaced routine <label> from file"
					endif
				else
					if !_ReportMods
						print "Loaded file mod/<label>.asm -- Label <label> was not defined by file, using original code for routine"
					endif
				endif
			endif
		endif
		!_SubLabel = <label>
		

		if defined("_SubDefined_<label>")
		;label was either already defined or was just defined in the loaded file
		;save pc so we can roll it back later, as there's no way to conditionally skip code from a macro that I can see
;			pushpc			;pushpc in asar trashes the current address for some reason, so it's unusable

			;!_SubPC #= pc()	;alternate option?
			
			;original code follows this macro 
			;if we don't need it, the endsub macro will roll back the pc to reclaim the space
			!_SubRollback = 1
			!_SubRollbackLabel = <label>
			!_SubSentinel = 1

			;put us in a garbage namespace, so the original code labels don't cause redefinition errors
			namespace __discarded
			<label>_Rollback:
		else
			!_SubRollback = 0
		endif

	endif

	;flags that we're in a replacable subroutine
	!_SubSentinel = 1
endmacro

macro endsub()
	namespace off

	;make sure this was called after a %sub call

	;assert !_SubSentinel,"endsub macro called without a matching sub macro"	
	;asar's assert routine is apparently worthless, so we do it manually
	if !_SubSentinel == 0
		error "endsub macro called without a matching sub macro"
	endif	

	
	if !_ModFiles
		;check if we need to roll back the pc to reclaim the original code space
		;this method requires extra space during the processing, but I can't see any other way in asar to do it
		;unfortunately this does mean that large replaced subs near the end of the bank could overflow it, even if the final size would be small enough
		if !_SubRollback != 0 
			;make sure the original code assembly didn't overflow the battle area
			warnpc $C2A000
			
			;restore original pc, so subsequent code uses the space the original routine occupied
			namespace __discarded
			org !{_SubRollbackLabel}_Rollback
			namespace off
			!_SubRollback = 0
					
		endif
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
