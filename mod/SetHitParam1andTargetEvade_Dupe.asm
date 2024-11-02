if !_Optimize

;this deletes an unneeded routine
;the only time it is called has been replaced by a call to the other copy

;we need a valid label though for the vanilla routine rollback
;so it's defined to wherever we are
;worst case if someone calls it they'll likely get one of the other hit routines
%subdef(SetHitParam1andTargetEvade_Dupe)

endif