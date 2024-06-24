clear all
set more off
set trace on

log using "/Users/bengordon/Desktop/UPK/Data Cleanup Work/DataCleanupAssignmentCreation.log", replace

use "/Users/bengordon/Desktop/UPK/Data Cleanup Work/GeneratedBadData.dta", clear

* Data Errors Summary:
* Missing values in read_score_three (Non-Fixable)
* Birthdays adding extra characters to string (Fixable)
* Negative values in numeric variables? (Fixable, but won't because it may be intentional)

*Generate a variable to check the birthday string length for anomalies
gen birthday_str_long = 0

*If string length is greater than 9, new variable is equal to 1 and there is an anomaly
replace birthday_str_long = 1 if length(birthdate_str) > 9

*Clean the 1900-00-00 out of birthdays to make the age variable easier to create
replace birthdate_str = substr(birthdate_str, 1, 9)

*Delete the variable used for the substitution
drop birthday_str_long

*Generate a variable for age
gen age=floor((today()-birthdate)/365.25)

*List street names
local street_names "Washington Lincoln Kennedy Grant Jefferson Jackson Adams Johnson Madison Monroe Bush"

*List street endings
local street_endings "St Ave Blvd Ln Rd Drv"

*Generate address variable
gen streetname = ""
gen streetnumber = round(runiform()*999 + 1000)
gen streetend = ""


forval i = 1/`=_N'{
	local fill_street_name : word `=ceil(runiform()*11)' of `street_names'
	local fill_street_end : word `=ceil(runiform()*6)' of `street_endings'
	replace streetname = "`fill_street_name'" in `i'
	replace streetend = "`fill_street_end'" in `i'
}

*Generate family ID variable (adressnumber+lastname)
egen family_id = concat(streetnumber lastname)

*Generate verbal skills variable based on average reading score + average math score
gen math_score_average = (math_score_one+math_score_two)/2
gen reading_score_average = (read_score_one+read_score_two+read_score_three)/3
replace reading_score_average = (read_score_one+read_score_two)/2 if read_score_three ==.
gen verbal_skills = round(7.5+((math_score_average-25)/7.2)+((reading_score_average-10)/3.46))

*Generate race variable
local races "White Black Hispanic Asian Native-American Middle-Eastern Other"
gen race = ""
forval i = 1/`=_N'{
	local fill_race : word `=ceil(runiform()*7)' of `races'
	replace race = "`fill_race'" in `i'
}

*Save data as a new data set
save cleandata.dta

log close
