if !_Optimize

;this deletes an unneeded routine
;the only time it is called has been replaced by a call to the other copy
;but we'll define the label to the RTS from the previous routine just in case

skip -1
SetHitParam1andTargetEvade_Dupe:
skip 1

endif