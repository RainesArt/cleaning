/*
	Arthur Raines
	EC-REACH
*/
version 18
clear all
set more off
set trace on

global dir "C:\Development\UPK_PROJ\INCCRRA"
global cleaned_data_dir "C:\Development\UPK_PROJ\INCCRRA\Days Cleaned Data"
cd ${dir}
program inccrra_days_clean
	foreach year_val of numlist 2010/2019{
		import excel using "${dir}\Chicago child care programs June `year_val'.xlsx", firstrow sheet("Days") clear
		
		egen days = noccur(DaysofCare), string("y--")
		egen weeks = noccur(DaysofCare), string("------------")
		gen AverageDaysofCare = days/weeks
		drop days
		drop weeks
		
		gen dayCopy = DaysofCare
		gen last = strpos(dayCopy, "------------")
		replace dayCopy = substr(dayCopy, 1, last+1)
		egen DaysOpen = noccur(dayCopy), string("y--")
		drop dayCopy last
		
		label variable AverageDaysofCare "Average days in a week that the care center is open"
		label variable DaysOpen "Days open in the first listed week (day shift presumably)"
		
		save "${cleaned_data_dir}\Days `year_val'", replace
	}
end
inccrra_days_clean

set trace off
cap log close
exit 
