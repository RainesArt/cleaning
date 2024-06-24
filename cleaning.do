/* Jasmine Sun
* EC-REACH Data Cleaning Assignment 
* The following do file conducts cleaning and generation of variables */
	

clear all
set more off
set trace on 


cd /Users/jasminesun/Desktop/ECREACH/

cap log using data_cleaning.txt, replace

use "synthetic.dta", clear

* Looked at variables using 'codebook' and 'summarize' commands
/* 
- birthdate variable made up of year, month and day variables 
- 43,152 missing observations for read_score_three
- birthdate_str is of length 20, should be of length 9
- all math/reading scores have negative values but don't seem to be following a normal distribution
	-- What do negative scores mean? What do scores mean in general?
*/

// I want to look at the distribution of numeric variables 


// I want to look more closely at observations where the birthdate_str variable is longer than it should be 
browse if strlen(birthdate_str) > 9
* All typo birthdate_str have '1900-00-0000' at the end 

replace birthdate_str = substr(birthdate_str, 1, length(birthdate_str) - 12) + substr(string(year(birthdate)), -1, 1) if typo_sample == 1


// generating an age variable 
gen today_date = mdy(month(today()), day(today()), year(today()))

* Calculate age in years
gen age = (today_date - birthdate) / 365.25

drop today_date

* Round the age
replace age = floor(age)

* Average math score variable
gen math_score_avg = (math_score_one + math_score_two)/2

* Total math score variable
gen math_score_total = math_score_one + math_score_two

* Average reading score variable
gen read_score_avg = (read_score_one + read_score_two + read_score_three)/3

* Total reading score variable
gen read_score_total = read_score_one + read_score_two + read_score_three

* Calculate mean and standard deviation of cummulative_score
summarize cummulative_score

* Store the mean and standard deviation in local macros
local mean_cummulative_score = r(mean)
local sd_cummulative_score = r(sd)

* Compute the threshold
local threshold = `mean_cummulative_score' + `sd_cummulative_score'

* Generate the high_achiever variable
gen high_achiever = (cummulative_score > `threshold')

* saving cleaned data 
save "cleaned.dta", replace

log close
