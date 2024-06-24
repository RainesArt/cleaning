/* Jasmine Sun
* EC-REACH Data Cleaning Assignment 
* The following do file conducts tables and graphics generated from variables in the synthetic dataset */

clear all
set more off
set trace on 


cd /Users/jasminesun/Desktop/ECREACH/cleaning_task

use "cleaned.dta", clear

cd /Users/jasminesun/Desktop/ECREACH/cleaning_task/graphs


* Exploring distribution of cummulative score 
kdensity cummulative_score

graph save "cummulative_score_density.gph", replace

* Relationship between scores 
** Relationship between math_score_avg and read_score_avg 
twoway (scatter read_score_avg math_score_avg), title("Average Reading Score by Average Math Score")

graph save "avg_math_by_read_scatter.gph", replace

** Relationship between math_score_one and math_score_two
twoway (scatter math_score_two math_score_one), ///
	title("Scatter of 2nd Math Score by 1st Math Score")
	
graph save "math_score_two_by_one_scatter.gph", replace

** Relationship between read_score_one and read_score_two
twoway (scatter read_score_read math_score_one), ///
	title("Scatter of 2nd Read Score by 1st Read Score")
	
graph save "read_score_two_by_one_scatter.gph", replace

** Relationship between avg_math_score by age
graph box math_score_avg, over(age) ///
	title("Average Math Score By Age")

graph save "math_by_age_box.gph", replace

** Relationship between avg_read_score by age
graph box read_score_avg, over(age) ///
	title("Average Read Score By Age")

graph save "read_by_age_box.gph", replace

** Looking at high achiever percentage by age
tab age high_achiever, row 




	