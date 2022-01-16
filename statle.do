capture program drop statle 
program statle

	clear all 
	set more off 

	*Clear out any commas 
	local no_commas = subinstr("`1'", ",", "", .)
	local no_spaces = subinstr("`no_commas'", " ", "", .)

	*Get the length of the string free of commas and spaces
	local len = strlen("`no_spaces'") 
	
	*Remove commas and spaces from the position string as well
	local pos_no_commas = subinstr("`2'", ",", "", .) 
	local pos_no_spaces = subinstr("`pos_no_commas'", " ", "", .) 
	

	*Use the length information to insert blanks if not already provided
	if `len'==1{
		
		local add_spaces = "`no_spaces'" + " _ _ _ _" 
	
	}

	else if `len'==2{
		
		local add_spaces = substr("`no_spaces'", 1, 1) + " " + ///
			substr("`no_spaces'", 2, 1) + " _ _ _" 
		
	}

	else if `len'==3{
		
		local add_spaces = substr("`no_spaces'", 1, 1) + " " + ///
			substr("`no_spaces'", 2, 1) + " " + /// 
			substr("`no_spaces'", 3, 1) + " _ _" 
		
	}

	else if `len'==4{
		
		local add_spaces = substr("`no_spaces'", 1, 1) + " " + ///
			substr("`no_spaces'", 2, 1) + " " + /// 
			substr("`no_spaces'", 3, 1) + " " + ///
			substr("`no_spaces'", 4, 1) + " _" 
		
	}

	else if `len'==5{
		
		local add_spaces = substr("`no_spaces'", 1, 1) + " " + ///
			substr("`no_spaces'", 2, 1) + " " + /// 
			substr("`no_spaces'", 3, 1) + " " + ///
			substr("`no_spaces'", 4, 1) + " " + ///
			substr("`no_spaces'", 5, 1) +

	}

	*Throw some errors if you gave me no letters or too many letters
	else if `len'==0{
		
		di "ERROR: You specified `len' letters. You have to specify at least one."
		stop 
	}

	else{
		
		di "ERROR: You specified `len' letters. That is too many."
		stop 
		
	}

	*Set a new dataset with one observation 
	set obs 1 

	*Initialize 5 blank variables that will store each letter by position
	forvalues i = 1/5{
		
		gen letter`i' = ""
		
	}

	*Start a counter to use in the loop below
	local count = 1

	*Loop through all possible combinations of the 5 letters, the dumb way 
	foreach letter1 of local add_spaces{
		
		foreach letter2 of local add_spaces{
			
			foreach letter3 of local add_spaces{
				
				foreach letter4 of local add_spaces{
					
					foreach letter5 of local add_spaces{

						forvalues i = 1/5{
							
							replace letter`i' = "`letter`i''" in `count'
							local new_n = _N + 1
							set obs `new_n'
							
						}
						
						local ++count
						
					}
				}
				
			}
			
		}
	 
	}

	*Store a version of the string with no blanks 
	local no_blanks = subinstr("`add_spaces'", "_", "", .)

	*Create a series of dummies to tell us if specific letter is in a specific position
	foreach letter of local no_blanks{
		
		forvalues i = 1/5{
			
			gen letter`i'_is_`letter' = letter`i'=="`letter'"
			
		}
		
		*Calculate the number of times each letter appears 
		egen row_`letter'_count = rowtotal(*_is_`letter')
		
		*Drop the combination if the letter appears more than once or not at all 
		drop if row_`letter'_count>1 & !missing(row_`letter'_count) | ///
			row_`letter'_count==0
		
	}

	if "`pos_no_spaces'"=="_____"{
	    
		di "No Need to Check Positions!"
		
	}
	
	else{
	    
		/*Loop through all the letters to check the positions of the letter combinations 
			against the known positions
		*/
		foreach letter of local no_blanks{
			
			*Initialize a blank variable for storing indicators of out of position letters
			gen drop_because_of_`letter' = . 
			*Store the known position of the letter in the submitted string with known locations
			local let_pos = strpos("`pos_no_spaces'", "`letter'") 
			*If we don't know the positon of a letter, we pass
			if `let_pos'==0{
				
				di "No position of `letter' determined"
				
			}
			
			/* If we do know the position of a letter, we check whether the letter is in the 
				right position by checking the letter of that number against the letter
				it should be
			*/
			else{
				
				replace drop_because_of_`letter' = letter`let_pos'!="`letter'"
				
			}
			
		}

		*Aggregate across the drop indicators to make one single drop indicator
		egen to_drop = rowmax(drop_*)
		*Drop the combinations that don't meet the criteria
		drop if to_drop

		
	}
	
	*Drop all the weird variables we made along the way 
	drop *_*

	*Combine the letter options into one string
	gen arrangement = letter1+letter2+letter3+letter4+letter5
	*Tab all the remaining arrangements 
	tab arrangement
	
end 


