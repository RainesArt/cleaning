* Arthur Raines EC-REACH
/* The following file runs a program called cleanAcsDataFiles
   This program first loops through the directory containing the raw .csv files
   These raw files are named 2010 Labor, 2010 Race, 2010 Population, 2011 Labor etc.. 
   Each individual raw data file is then cleaned and saved as a .dta file
   The files are then appended to the cleaned ACS 2010 file which initially serves as the master file
   The final appended file is saved as ACS_labor_master.dta, ACS_population_master.dta, ACS_race_master.dta
*/

version 18.0 // Stata Version

clear all
set more off
//set trace on 
cap log using ACS_labor_clean.txt, replace
   
/* 1. Loop through each file in specified directory ending in .csv and
	  perform data cleanup */
/* 2. Save all the data files into seperate .dta files */
/* 3. Append the data files together using the cleaned 2010 labor file as
the master file */

program cleanAcsDataFiles

// Specify directory or directories containing Labor, Race,  and Population files
// By default 3 file directories are included for each ACS category
#delimit ;
local acs_directory = "C:\Development\UPK_PROJ\ACS\Labor 
C:\Development\UPK_PROJ\ACS\Population C:\Development\UPK_PROJ\ACS\Race";
#delimit cr

// Outer loop loops through the acs_directory list
foreach dir in `acs_directory' {
	cd $C`dir' // set the working directory
	local acs_files: dir "`dir'" files "*.csv" // local macro contains acs_files
	
	// Loop through each .csv file in current directory 
	foreach file in `acs_files' {
		
		// row 2 contains labels for each variable start with row 3 and use row
		// use row 1 as variable names - see variable name doc for variable labels
		import delimited using "`file'", varnames(1) rowrange(3) clear
		
		// convert string values to numeric
		foreach var of varlist _all {
		   cap destring `var', ignore("-N*(X) ") replace
		   }
		   
		// local macro that contains value of file year and file category
		local year = substr("`file'", 1, 4) 
		local file_category = substr("`file'", 6,.)
		
		// generates a year variable refering spring year to the school year
		gen year_spring = real("`year'") 
		
		// Save 2010 as master data file 
		if "`year'" == "2010" {
			save "ACS_`file_category'_cleaned_master.dta", replace
		}
		
		// Save years not equal to 2010 as ACS_labor_data_cleaned_year.dta 
		// Use the ACS_labor_cleaned_master and append each individual year file
		else{
			save "ACS_`file_category'_data_cleaned_`year'.dta", replace
			use "ACS_`file_category'_cleaned_master.dta", clear
			append using "ACS_`file_category'_data_cleaned_`year'.dta", force
			save "ACS_`file_category'_cleaned_master.dta", replace
		}

	}
	
	// Label the spring year variable which refers spring year to the school year
	label var year_spring "Year notation that refers spring year to the school year"
	replace geo_id = subinstr(geo_id, "1400000US", "", .)
	save "ACS_`file_category'_cleaned_master.dta", replace
}
end
cleanAcsDataFiles

set trace off 
cap log close
exit