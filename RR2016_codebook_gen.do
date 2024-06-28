// Testing the usage of `putdocx' to automate the .docx codebook generation process using RR 2016 dataset

cap log close
cd /Users/jasminesun/Desktop/ECREACH/codebook_gen/


// Start by writing a program to specify what information we want to see for each variable
// Seperate program for ID, str categorical, numeric categorical and continuous numeric variables 

	// Program to produce codebook for continuous numeric variables
		cap program drop codebook_cont_num
		program define codebook_cont_num
		
			args var
			
			* New page
			putdocx pagebreak
		
			// Set up codebook entry as a 4 x 2 table
			// Put Ns and summary stats on the right
			putdocx table cb_`var' = (5,2), border(top) border(bottom) 
			
				// Put variable name, label on the left
				local lab : var label `var'
				putdocx table cb_`var'(1,1) = ("Variable: `var'"), bold
				putdocx table cb_`var'(2,1) = ("Label: `lab'")		
				
				// Put Ns and summary stats on the right
				count if mi(`var')
				local n_miss = r(N)
				
				sum `var'
				local n_nonmiss = r(N)
				local mean = round(r(mean),.001)
				local min = r(min)
				local max = r(max)
				local sd = round(r(sd),.001)
				
				putdocx table cb_`var'(1,2) = ("N non-missing: `n_nonmiss'")
				putdocx table cb_`var'(2,2) = ("N missing: `n_miss'")	
				putdocx table cb_`var'(3,2) = ("Mean: `mean'")	
				putdocx table cb_`var'(4,2) = ("SD: `sd'")	
				putdocx table cb_`var'(5,2) = ("Range: [`min', `max' ]")	
				
			// Placeholders for description, recoding/cleaning info
			// This could be enetered manually after the summary stats for all variables are exported
			putdocx paragraph
			putdocx text ("Variable Description"), bold
			putdocx paragraph
			putdocx text ("fill")
			
			putdocx paragraph
			putdocx text ("Variable Caveats"), bold
			putdocx paragraph
			putdocx text ("fill")
				
				
		end
		
		// User-written program to produce codebook for categorical var		
		cap program drop codebook_cat_str
		program define codebook_cat_str
		
			args var
			
			* New page
			putdocx pagebreak
		
			// Set up codebook entry as a N x 2 table, where N is the number of unique values of the variable + 3
			levelsof `var', local(vals)
			local num_vals = r(r)
			
			// Put Ns and summary stats on the right
			local num_row = `num_vals' + 3
			di "num_row : `num_row'"
			putdocx table cb_`var' = (`num_row',2)
			
				// Put variable name, label on the left
				local lab : var label `var'
				putdocx table cb_`var'(1,1) = ("Variable: `var'"), bold
				putdocx table cb_`var'(2,1) = ("Label: `lab'")		
				
				// Put Ns and tabs
				count if mi(`var')
				local n_miss = r(N)
				
				count if !mi(`var')
				local n_nonmiss = r(N)
				
				putdocx table cb_`var'(1,2) = ("N non-missing: `n_nonmiss'")
				putdocx table cb_`var'(2,2) = ("N missing: `n_miss'")	
				putdocx table cb_`var'(3,2) = ("Tabulation:")	
				
				local i = 4
				foreach v in `vals' {
					count if `var'=="`v'"
					local n = r(N)
					
					putdocx table cb_`var'(`i',2) = ("`v': `n'")
					local i = `i' + 1
				}
				
			// Placeholders for description, recoding/cleaning info
			// This could be enetered manually after the summary stats for all variables are exported
			putdocx paragraph
			putdocx text ("Variable Description"), bold
			putdocx paragraph
			putdocx text ("fill")
			
			putdocx paragraph
			putdocx text ("Variable Caveats"), bold
			putdocx paragraph
			putdocx text ("fill")
			
		end
		
		
		//Program to produce codebook for ID variables
		cap program drop codebook_id
		program define codebook_id
			
			args var
			
			* New page
			putdocx pagebreak
			* Set up codebook entry as a 3 x 2 table
			putdocx table cb_`var' = (3,2)
			
			* Put variable name and label on the left
			local lab : var label `var'
			putdocx table cb_`var'(1,1) = ("Variable: `var'"), bold
			putdocx table cb_`var'(2,1) = ("Label: `lab'")
			
			* Put Ns on the right
			count if mi(`var')
			local n_miss = r(N)
			
			count if !mi(`var')
			local n_nonmiss = r(N)
			
			putdocx table cb_`var'(1,2) = ("N non-missing: `n_nonmiss'")
			putdocx table cb_`var'(2,2) = ("N missing: `n_miss'")
			
			* Calculate and put the number of unique values
			*quietly levelsof `var', local(unique_vals)
			*local num_unique = word count `unique_vals'
			* putdocx table cb_`var'(3,2) = ("Number of Unique Values: `num_unique'")
			
			
			* Placeholders for description, recoding/cleaning info
			* Could be entered manually after the summary stats for all variables are exported
			putdocx paragraph
			putdocx text ("Variable Description"), bold
			putdocx paragraph
			putdocx text ("fill")
			
			putdocx paragraph
			putdocx text ("Variable Caveats"), bold
			putdocx paragraph
			putdocx text ("fill")
			
		end

// Codebook Creation 	

use "Racial Report_2016.dta", clear

// Manually inputting id variables into id_variables macro
local id_variables "school_id school_name"

// Creating macro of string variables
ds, has(type string)
local string_vars `r(varlist)'

// Creating macro of numeric variables
ds, has(type numeric)
local numeric_vars `r(varlist)'
	
	// Start the Word doc
	putdocx clear
	putdocx begin
	
	// Add a title
	putdocx paragraph, style(Title)
	putdocx text ("Racial Report 2016 Codebook")
	
	// Add another subheading (e.g., agency)
	putdocx paragraph, style(Heading1)
	putdocx text ("SUBHEADING (E.G. AGENCY NAME OR FILE NAME)")
	
	// Add another subheading
	putdocx paragraph, style(Heading2)
	putdocx text ("ANOTHER SUBHEADING IF NECESSARY")


// Two for loops that iterates through list of string variables, then list of numeric variables
	* Inner for loop iterates through each variable in id_variables to check for matches
		* If it's in id_variables, then run codebook_id program 
		* Else run associated program


	foreach var of local string_vars {
		// Initialize a flag
		local is_id = 0
		
		// Check if the variable is in the id_variables list
		foreach idvar of local id_variables {
			if "`var'" == "`idvar'" {
				local is_id = 1
			}
		}
		
		// Run the codebook_cat_str program if the variable is not in the id_variables list
		if `is_id' == 0 {
			display "Processing string variable: `var'"
			codebook_cat_str `var'
		} 
		else {
			codebook_id `var'
		}
	}
	
		foreach var of local numeric_vars {
		// Initialize a flag
		local is_id = 0
		
		// Check if the variable is in the id_variables list
		foreach idvar of local id_variables {
			if "`var'" == "`idvar'" {
				local is_id = 1
			}
		}
		
		// Run the codebook_cat_str program if the variable is not in the id_variables list
		if `is_id' == 0 {
			display "Processing numeric variable: `var'"
			codebook_cont_num `var'
		} 
		else {
			codebook_id `var'
		}
	}

	// Want to automate naming convention based on dataset name
	putdocx save RR2016_codebook, replace

			