includeonce

;Utility routine to copy magic info from a temp location to the attack info struct, which are different sizes
;I'd like to generalize it more using a pointer but half of the cases use a 24-bit address in rom 
;which makes it not worth the setup 

;It would be much easier if it were a 4/4/4 split instead of 5/4/3, 
;and it would make more sense in the attackinfo structure that way as well
;but would have to change the in memory layout that too much stuff uses
CopyTempMagicInfo:
	TDC
	TAX
-	LDA TempMagicInfo,X    			
       	STA AttackInfo,Y       
       	INX                    
       	INY                    
       	CPX #$0005             
       	BNE -                  
       	INY                    
       	INY                    
       	INY                    
       	INY                    
-	LDA TempMagicInfo,X    
        STA AttackInfo,Y	
        INX 			
        INY 			
        CPX #$0008		
        BNE -	
	RTS