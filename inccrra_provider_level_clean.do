/* Arthur Raines
 * EC-REACH
 * INCCRRA Data Clean
 * The following do file cleans sheet Provider level data from 2010-2019
   */
   
   // install the following modules before executing this do file
   //cap ssc install egenmore
   //cap ssc install ereplace
   
clear all
set more off
set trace on
global dir "C:\Development\UPK_PROJ\INCCRRA"

// Community tract directory used to merge the community tract data
global comm_tract_dir "C:\Development\UPK_PROJ\INCCRRA\Community Tract"
global cleaned_data_dir "C:\Development\UPK_PROJ\INCCRRA\Provider Cleaned Data"
global add_min_max_dir "C:\Development\UPK_PROJ\INCCRRA\Additional Min_Max Var"
cd ${dir}
cap log using inccrra_provider_level_log.txt, replace

program inccrraProviderClean
// Loop through each INCCRRA excel file from 2010-2019

foreach year_val of numlist 2010/2022 {
	// import only the "Proivder Level Data sheet"
	if `year_val' < 2020 {
		import excel using "${dir}\Chicago child care programs June `year_val'.xlsx", firstrow sheet("Provider Level Data") clear
	}
	else {
		import excel using "${dir}\Chicago child care programs June `year_val'.xlsx", firstrow sheet("Providers") clear
	}
	
	/*  Several of the variables have values that need to be categorized before converting
	 *  The values from string to numeric. The variables are as follows
	 *  1. TypeofCare
	 *  2. RegulationStatus
	 *  3. NonProfitFlag
	 *  4. CenterSetting
	 *  5. QualityRating (If it is a string)
	 *  6. MinAgeServed
	 *  7. MaxAgeserved
	*/
	gen file_year = `year_val'
	
	// Begin converting values to numeric values
	cap replace TypeofCare = "(CCC)Head Start/Early Head Start Only" if TypeofCare=="(CCC)Head Start/Early HeadStart Only"
	replace TypeofCare="1" if TypeofCare=="Child Care Center"
	replace TypeofCare="2" if TypeofCare=="Family Child Care"
	replace TypeofCare="3" if TypeofCare=="Preschool Program"
	replace TypeofCare="4" if TypeofCare=="(CCC)Head Start/Early Head Start Only"
	replace TypeofCare="5" if TypeofCare=="(CCC)Preschool For All Only"
	destring TypeofCare, replace
	
	// Take the original variable values and use them as the variable Labels 
	cap rename LicenseStatus RegulationStatus
	cap replace RegulationStatus = "0" if RegulationStatus=="Exempt" | RegulationStatus=="Exempt "
	cap replace RegulationStatus = "1" if RegulationStatus=="Regulated/Licensed" | RegulationStatus=="Regulated/Licensed "
	cap replace RegulationStatus="1" if RegulationStatus== "Licensed" | RegulationStatus== "Licensed "
	destring RegulationStatus, replace
	
	
	replace NonProfitFlag="0" if NonProfitFlag=="N"
	replace NonProfitFlag="1" if NonProfitFlag=="Y"
	destring NonProfitFlag, replace

	cap rename Setting CenterSetting
	
	replace CenterSetting="1" if CenterSetting=="Non-residential"
	replace CenterSetting="2" if CenterSetting=="Faith-based"
	replace CenterSetting="3" if CenterSetting=="Public School Setting"
	replace CenterSetting="4" if CenterSetting=="Workplace-based"
	replace CenterSetting="5" if CenterSetting=="College-based"
	replace CenterSetting="6" if CenterSetting=="Chain Center"
	replace CenterSetting="7" if CenterSetting=="Hospital-based"
	
	replace CenterSetting="8" if CenterSetting=="Home-Based"
	replace CenterSetting="9" if CenterSetting=="Center-Based"
	replace CenterSetting="10" if CenterSetting=="School-Based"
	replace CenterSetting="11" if CenterSetting=="Other"
	destring CenterSetting, replace
	
	cap replace AcceptsChildren="1" if AcceptsChildren=="Part-Time"
	cap replace AcceptsChildren="2" if AcceptsChildren=="Full-Time"
	cap replace AcceptsChildren="3" if AcceptsChildren=="Both"
	cap destring AcceptsChildren, replace
	
	cap confirm string var QualityRating
	if _rc==0 {
		replace QualityRating="1" if QualityRating=="Training Tier 1"
		replace QualityRating="2" if QualityRating=="Training Tier 2"
		replace QualityRating="3" if QualityRating=="Training Tier 3"
		replace QualityRating="4" if QualityRating=="Star Level 1"
		replace QualityRating="5" if QualityRating=="Star Level 2"
		replace QualityRating="6" if QualityRating=="Star Level 3"
		replace QualityRating="7" if QualityRating=="Star Level 4"
		replace QualityRating="8" if QualityRating=="Bronze Circle of Quality"
		replace QualityRating="9" if QualityRating=="Silver Circle of Quality"
		replace QualityRating="10" if QualityRating=="Gold Circle of Quality"
		replace QualityRating="11" if QualityRating=="Licensed Circle of Quality"
		destring QualityRating, replace 
	}
	
	// MinAgeServed and MaxAgeserved //
	
	generate MinAS = 0
	generate MaxAS = 0
	
	/* The code below begins by first creating the number of weeks, months and years
	   then the min age served is calculated using the weeks, months, years.
	   The minimum and maximum aged served variables are different after 2019
	   This codes generates a minimum and maximum for 2010-2019*/
	   
	if `year_val' < 2020 {
		// Generate Weeks
		egen week1 = noccur(MinAgeServed),string("1 week")
		egen week2 = noccur(MinAgeServed),string("2 weeks")
		egen week3 = noccur(MinAgeServed),string("3 weeks")
		egen week4 = noccur(MinAgeServed),string("4 weeks")
		
		// Generate Months
		egen month1 = noccur(MinAgeServed),string("1 month")
		egen month2 = noccur(MinAgeServed),string("2 months")
		egen month3 = noccur(MinAgeServed),string("3 months")
		egen month4 = noccur(MinAgeServed),string("4 months")
		egen month5 = noccur(MinAgeServed),string("5 months")
		egen month6 = noccur(MinAgeServed),string("6 months")
		egen month7 = noccur(MinAgeServed),string("7 months")
		egen month8 = noccur(MinAgeServed),string("8 months")
		egen month9 = noccur(MinAgeServed),string("9 months")
		egen month10 = noccur(MinAgeServed),string("10 months")
		egen month11 = noccur(MinAgeServed),string("11 months")
		
		//Generate Years
		egen year1 = noccur(MinAgeServed),string("1 year")
		egen year2 = noccur(MinAgeServed),string("2 years")
		egen year3 = noccur(MinAgeServed),string("3 years")
		egen year4 = noccur(MinAgeServed),string("4 years")
		egen year5 = noccur(MinAgeServed),string("5 years")
		egen year6 = noccur(MinAgeServed),string("6 years")
		egen year7 = noccur(MinAgeServed),string("7 years")
		egen year8 = noccur(MinAgeServed),string("8 years")
		egen year9 = noccur(MinAgeServed),string("9 years")
		
		//Add the weeks
		replace MinAS = MinAS + 7/365 if week1==1
		replace MinAS = MinAS + 14/365 if week2==1
		replace MinAS = MinAS + 21/365 if week3==1
		replace MinAS = MinAS + 28/365 if week4==1
		
		//Add the months
		replace MinAS = MinAS + 1/12 if month1==1 & month11 != 1
		replace MinAS = MinAS + 2/12 if month2==1
		replace MinAS = MinAS + 3/12 if month3==1
		replace MinAS = MinAS + 4/12 if month4==1
		replace MinAS = MinAS + 5/12 if month5==1
		replace MinAS = MinAS + 6/12 if month6==1
		replace MinAS = MinAS + 7/12 if month7==1
		replace MinAS = MinAS + 8/12 if month8==1
		replace MinAS = MinAS + 9/12 if month9==1
		replace MinAS = MinAS + 10/12 if month10==1
		replace MinAS = MinAS + 11/12 if month11==1
		
		//Add the years
		replace MinAS = MinAS + 1 if year1==1
		replace MinAS = MinAS + 2 if year2==1
		replace MinAS = MinAS + 3 if year3==1
		replace MinAS = MinAS + 4 if year4==1
		replace MinAS = MinAS + 5 if year5==1
		replace MinAS = MinAS + 6 if year6==1
		replace MinAS = MinAS + 7 if year7==1
		replace MinAS = MinAS + 8 if year8==1
		replace MinAS = MinAS + 9 if year9==1
		
		//No longer need variables generated drop them 
		drop week1-week4
		drop month1-month11
		drop year1-year9
		
		/* The code below begins by first creating the number of weeks, months and years
		   then the max age served is calculated using the weeks, months, years */
		// Generate Weeks
		egen week1 = noccur(MaxAgeServed),string("1 week")
		egen week2 = noccur(MaxAgeServed),string("2 weeks")
		egen week3 = noccur(MaxAgeServed),string("3 weeks")
		egen week4 = noccur(MaxAgeServed),string("4 weeks")
		
		//Generate Months
		egen month1 = noccur(MaxAgeServed),string("1 month")
		egen month2 = noccur(MaxAgeServed),string("2 months")
		egen month3 = noccur(MaxAgeServed),string("3 months")
		egen month4 = noccur(MaxAgeServed),string("4 months")
		egen month5 = noccur(MaxAgeServed),string("5 months")
		egen month6 = noccur(MaxAgeServed),string("6 months")
		egen month7 = noccur(MaxAgeServed),string("7 months")
		egen month8 = noccur(MaxAgeServed),string("8 months")
		egen month9 = noccur(MaxAgeServed),string("9 months")
		egen month10 = noccur(MaxAgeServed),string("10 months")
		egen month11 = noccur(MaxAgeServed),string("11 months")
		//Generate Years
		egen year1 = noccur(MaxAgeServed),string("1 year")
		egen year2 = noccur(MaxAgeServed),string("2 years")
		egen year3 = noccur(MaxAgeServed),string("3 years")
		egen year4 = noccur(MaxAgeServed),string("4 years")
		egen year5 = noccur(MaxAgeServed),string("5 years")
		egen year6 = noccur(MaxAgeServed),string("6 years")
		egen year7 = noccur(MaxAgeServed),string("7 years")
		egen year8 = noccur(MaxAgeServed),string("8 years")
		egen year9 = noccur(MaxAgeServed),string("9 years")
		egen year10 = noccur(MaxAgeServed),string("10 years")
		egen year11 = noccur(MaxAgeServed),string("11 years")
		egen year12 = noccur(MaxAgeServed),string("12 years")
		egen year13 = noccur(MaxAgeServed),string("13 years")
		egen year14 = noccur(MaxAgeServed),string("14 years")
		
		//Add the weeks
		replace MaxAS = MaxAS + 7/365 if week1==1
		replace MaxAS = MaxAS + 14/365 if week2==1
		replace MaxAS = MaxAS + 21/365 if week3==1
		replace MaxAS = MaxAS + 28/365 if week4==1
		
		//Add the months
		replace MaxAS = MaxAS + 1/12 if month1==1 & month11 != 1
		replace MaxAS = MaxAS + 2/12 if month2==1
		replace MaxAS = MaxAS + 3/12 if month3==1
		replace MaxAS = MaxAS + 4/12 if month4==1
		replace MaxAS = MaxAS + 5/12 if month5==1
		replace MaxAS = MaxAS + 6/12 if month6==1
		replace MaxAS = MaxAS + 7/12 if month7==1
		replace MaxAS = MaxAS + 8/12 if month8==1
		replace MaxAS = MaxAS + 9/12 if month9==1
		replace MaxAS = MaxAS + 10/12 if month10==1
		replace MaxAS = MaxAS + 11/12 if month11==1
		
		//Add the years
		replace MaxAS = MaxAS + 1 if year1==1 & year11 != 1
		replace MaxAS = MaxAS + 2 if year2==1 & year12 != 1
		replace MaxAS = MaxAS + 3 if year3==1 & year13 != 1
		replace MaxAS = MaxAS + 4 if year4==1 & year14 != 1
		replace MaxAS = MaxAS + 5 if year5==1
		replace MaxAS = MaxAS + 6 if year6==1
		replace MaxAS = MaxAS + 7 if year7==1
		replace MaxAS = MaxAS + 8 if year8==1
		replace MaxAS = MaxAS + 9 if year9==1
		replace MaxAS = MaxAS + 10 if year10==1
		replace MaxAS = MaxAS + 11 if year11==1
		replace MaxAS = MaxAS + 12 if year12==1
		replace MaxAS = MaxAS + 13 if year13==1
		replace MaxAS = MaxAS + 14 if year14==1
		
		//No longer need variables generated drop them
		drop week1-week4
		drop month1-month11
		drop year1-year14
	} 
	else{
		replace MinAS = MinAgeServed/52
		replace MaxAS = MaxAgeServed/52
		rename MinAgeServed MinAgeServed_2
		rename MaxAgeServed MaxAgeServed_2
	}

	// Merge the communities and tracts data
	if `year_val' < 2020{
		merge 1:1 ProviderID using "${comm_tract_dir}\Communities and Tracts `year_val'"
		drop _merge
	
	}
	else{
		rename OldProviderID ProviderID
		destring ProviderID, replace
		merge 1:1 ORG_ID using "${comm_tract_dir}\Communities and Tracts `year_val'", update
		cap drop old_lon old_lat old_geoid old_community
		drop _merge
	}
	
	cap rename Zip4 Zip_4
	cap destring Zip_4, replace
	cap replace Zip_4 = . if Zip_4 == 0
	cap destring TotalCenterStaff, replace
	
	rename lon Longitude
	rename lat Latitude
	rename community Community
	rename geoid GEOID
	tostring GEOID, replace format("%11.0f")
	cap rename BusinessName Name
	cap rename Languages_ Languages // Exists in files after 2019
	cap rename AccreditationType Accreditation // Exists in Files after 2019
	
	/* Each year, CPS releases the Annual Regional Analysis (ARA) with the goal
	of helping in district planning. It contains a district overview report and
	16 regional reports. The City of Chicago's Department of Planning and Development
	created these regions based on research done on housing and jobs. CPS considers these
	regions "more stable than city wards and school networks"
	
	More information regarding the ARA can be found here: https://www.cps.edu/sites/ara/about-the-ara/
	More Information on Chicago's community areas can be found here: https://en.wikipedia.org/wiki/Community_areas_in_Chicago	
	*/
	
	// The code below assigns the appropirate regions based upon a communities location
	gen AraRegion = ""
	replace AraRegion = "North Lakefront" if Community=="UPTOWN" | Community =="EDGEWATER" | Community == "ROGERS PARK"
	replace AraRegion = "Greater Lincoln Park" if Community=="LAKE VIEW" | Community=="LINCOLN PARK"
	replace AraRegion = "Central Area" if Community=="NEAR NORTH SIDE" | Community=="LOOP" | Community=="NEAR SOUTH SIDE"
	
	replace AraRegion = "Northwest Side" if Community=="WEST RIDGE" | Community=="LINCOLN SQUARE" | Community=="NORTH CENTER" | Community=="NORTH PARK" | Community=="IRVING PARK" | Community=="ALBANY PARK"
	
	replace AraRegion = "Greater Milwaukee Avenue" if Community=="AVONDALE" | Community=="LOGAN SQUARE" | Community=="WEST TOWN"
	
	replace AraRegion = "Far Northwest Side" if Community=="EDISON PARK" | Community=="NORWOOD PARK" | Community=="JEFFERSON PARK" | Community=="FOREST GLEN" | Community=="PORTAGE PARK" | Community=="DUNNING" | Community=="MONTCLARE" | Community=="BELMONT CRAGIN" | Community=="HERMOSA" | Community=="OHARE"
	
	replace AraRegion = "West Side" if inlist(Community, "AUSTIN", "HUMBOLDT PARK", "WEST GARFIELD PARK", "EAST GARFIELD PARK", "NORTH LAWNDALE")
	
	replace AraRegion = "Near West Side" if inlist(Community, "NEAR WEST SIDE")
	replace AraRegion = "Greater Stockyard" if inlist(Community, "BRIGHTON PARK", "MCKINLEY PARK", "BRIDGEPORT", "NEW CITY", "ARMOUR SQUARE")
	replace AraRegion = "Pilsen/Little Village" if inlist(Community, "SOUTH LAWNDALE", "LOWER WEST SIDE")
	replace AraRegion = "Greater Midway" if inlist(Community, "ARCHER HEIGHTS", "GARFIELD RIDGE", "WEST ELSDON", "GAGE PARK", "CLEARING", "WEST LAWN", "CHICAGO LAWN", "ASHBURN")
	replace AraRegion = "Bronzeville/South Lakefront" if inlist(Community, "DOUGLAS", "OAKLAND", "FULLER PARK", "GRAND BOULEVARD", "KENWOOD", "WASHINGTON PARK", "HYDE PARK", "WOODLAWN")
	replace AraRegion = "South Side" if inlist(Community, "WEST ENGLEWOOD", "ENGLEWOOD", "AUBURN GRESHAM", "WASHINGTON HEIGHTS")
	replace AraRegion = "Far Southwest Side" if inlist(Community, "BEVERLY", "MOUNT GREENWOOD", "MORGAN PARK")
	replace AraRegion = "Greater Stony Island" if inlist(Community, "SOUTH SHORE", "CHATHAM", "AVALON PARK", "SOUTH CHICAGO", "BURNSIDE", "CALUMET HEIGHTS", "GREATER GRAND CROSSING")
	replace AraRegion = "Greater Calumet" if inlist(Community, "ROSELAND", "PULLMAN", "SOUTH DEERING", "EAST SIDE", "WEST PULLMAN", "RIVERDALE", "HEGEWISCH")
	
	// After generating a string value the next step invovles converting to a numeric value 
	replace AraRegion = "1" if AraRegion=="Far Northwest Side"
	replace AraRegion = "2" if AraRegion=="Northwest Side"
	replace AraRegion = "3" if AraRegion=="North Lakefront"
	replace AraRegion = "4" if AraRegion=="Greater Lincoln Park"
	replace AraRegion = "5" if AraRegion=="Greater Milwaukee Avenue"
	replace AraRegion = "6" if AraRegion=="West Side"
	replace AraRegion = "7" if AraRegion=="Near West Side"
	replace AraRegion = "8" if AraRegion=="Central Area"
	replace AraRegion = "9" if AraRegion=="Pilsen/Little Village"
	replace AraRegion = "10" if AraRegion=="Greater Stockyard"
	replace AraRegion = "11" if AraRegion=="Greater Midway"
	replace AraRegion = "12" if AraRegion=="South Side"
	replace AraRegion = "13" if AraRegion=="Bronzeville/South Lakefront"
	replace AraRegion = "14" if AraRegion=="Greater Stony Island"
	replace AraRegion = "15" if AraRegion=="Far Southwest Side"
	replace AraRegion = "16" if AraRegion=="Greater Calumet"
	destring AraRegion, replace
	
	gen OldRolloutYear = 0
	replace OldRolloutYear = 1 if inlist(AraRegion, 16, 14, 12, 9, 6) | inlist(Community, "WEST TOWN", "LOGAN SQUARE", "UPTOWN")
	replace OldRolloutYear = 2 if inlist(AraRegion, 13, 11, 10, 7, 1) | inlist(Community, "AVONDALE", "EDGEWATER", "ROGERS PARK")
	replace OldRolloutYear = 3 if inlist(AraRegion, 15, 8, 4, 2)
	
	/* In the raw data files, some provider information is incorrect due to input errors
		The code below fixes those typos to the street address, City name, and zip code
		for several providers.
	*/
	if `year_val' < 2020 {
		replace City="CHICAGO" if City=="Chicago"
		replace StreetAddress="1802 N FAIRFIELD AVE" if (ProviderID == 45)
		replace StreetAddress="8352 S COLFAX AVE" if (ProviderID == 829 & ("`year_val'"=="2010"|"`year_val'"=="2011"|"`year_val'"=="2012"|"`year_val'"=="2013"|"`year_val'"=="2014"))
		replace StreetAddress="1365 N HUDSON AVE" if (ProviderID == 4078 & ("`year_val'"=="2011"|"`year_val'"=="2012"))
		replace StreetAddress="1237 W GREENLEAF AVE" if (ProviderID == 4461)
		
		replace StreetAddress="425 W 99TH ST" if (ProviderID == 4539)
		replace StreetAddress="7330 S WASHTENAW AVE" if (ProviderID == 4821 & ("`year_val'"=="2010"|"`year_val'"=="2011"))
		replace StreetAddress="2257 E 71ST ST" if (ProviderID == 6099 & "`year_val'"=="2012")
		replace StreetAddress="2337 W MAYPOLE AVE" if (ProviderID == 7085 & ("`year_val'"=="2017"|"`year_val'"=="2018"|"`year_val'"=="2019"))
		replace StreetAddress="3307 W MADISON ST" if (ProviderID == 7606)
		replace StreetAddress="3165 W MONROE ST" if (ProviderID == 7836)
		
		replace StreetAddress="626 E 47TH ST" if (ProviderID == 8558)
		replace StreetAddress="8204 S YATES BLVD" if (ProviderID == 8561)
		replace StreetAddress="5209 W AUGUSTA BLVD" if (ProviderID == 8613 & ("`year_val'"=="2010"|"`year_val'"=="2011"))
		replace StreetAddress="8538 S WOLCOTT AVE" if (ProviderID == 9570)
		replace StreetAddress="1820 S ST LOUIS AVE" if (ProviderID == 9590 & ("`year_val'"=="2010"|"`year_val'"=="2011"|"`year_val'"=="2012"|"`year_val'"=="2013"|"`year_val'"=="2014"|"`year_val'"=="2015"))
		
		replace StreetAddress="1913 S HAMLIN AVE" if (ProviderID == 9590 & ("`year_val'"=="2016"|"`year_val'"=="2017"|"`year_val'"=="2018"|"`year_val'"=="2019"))
		replace StreetAddress="3418 W DOUGLAS BLVD" if (ProviderID == 10033 & ("`year_val'"=="2016"|"`year_val'"=="2017"|"`year_val'"=="2018"|"`year_val'"=="2019"))
		replace StreetAddress="3811 W FULLERTON AVE" if (ProviderID == 10118 & ("`year_val'"=="2017"|"`year_val'"=="2018"|"`year_val'"=="2019"))
		replace StreetAddress="1807 S TROY ST" if (ProviderID == 10285 & ("`year_val'"=="2010"|"`year_val'"=="2011"|"`year_val'"=="2012"))
		replace StreetAddress="4920 W FULLERTON AVE" if (ProviderID == 10422 & ("`year_val'"=="2018"|"`year_val'"=="2019"))
		replace StreetAddress="5725 W CHICAGO AVE" if (ProviderID == 10911)
		replace StreetAddress="6415 S PULASKI RD" if (ProviderID == 11037)
		replace StreetAddress="1015 W 79TH ST" if (ProviderID == 11078 & "`year_val'"=="2019")
		replace StreetAddress="3430 W ROOSEVELT RD" if (ProviderID == 11372 & ("`year_val'"=="2016"|"`year_val'"=="2017"))
		replace StreetAddress="5644 S ELIZABETH ST" if (ProviderID == 11460 & ("`year_val'"=="2018"|"`year_val'"=="2019"))
		replace StreetAddress="626 EAST 47TH ST" if (ProviderID == 11897 & ("`year_val'"=="2012"|"`year_val'"=="2013"))
		replace StreetAddress="3817 W FULLERTON AVE" if (ProviderID == 12072 & ("`year_val'"=="2018"|"`year_val'"=="2019"))
		replace StreetAddress="1223 S KOSTNER AVE" if (ProviderID == 12913 & ("`year_val'"=="2015"|"`year_val'"=="2016"|"`year_val'"=="2017"))
		
		replace StreetAddress="9304 S ASHLAND AVE" if (ProviderID == 13598 & "`year_val'"=="2019")
		replace State="IL" if (ProviderID == 13807 & "`year_val'"=="2019")
		replace Zip=60620 if (ProviderID == 13807 & "`year_val'"=="2019")
		replace StreetAddress="8434 S CARPENTER ST" if (ProviderID == 13807 & "`year_val'"=="2019")
		replace StreetAddress="461 E 111TH ST" if (ProviderID == 13893 & "`year_val'"=="2019")	
	}
	save "${cleaned_data_dir}\Provider Level Data `year_val'", replace
	
	if `year_val' > 2019 {
		local year_file_abbrev : di subinstr("`year_val'", "20", "", 1)
		import excel using "${add_min_max_dir}\FY`year_file_abbrev' Min and Max Age Re-Run.xlsx", clear firstrow
		
		rename MINIMUM_AGE MINIMUM_AGE_N
		rename MAXIMUM_AGE MAXIMUM_AGE_N

		rename MIN_YEAR MIN_YEAR_N
		rename MIN_MONTH MIN_MONTH_N
		rename MIN_WEEK MIN_WEEK_N

		rename MAX_YEAR MAX_YEAR_N
		rename MAX_MONTH MAX_MONTH_N
		rename MAX_WEEK MAX_WEEK_N

		merge 1:1 ORG_ID using "${dir}\Provider Cleaned Data\Provider Level Data `year_val'"

		order MAX_WEEK_N, after (MaxAS)
		order MAX_MONTH_N, after (MaxAS)
		order MAX_YEAR_N, after (MaxAS)
		order MIN_WEEK_N, after (MaxAS)
		order MIN_MONTH_N, after (MaxAS)
		order MIN_YEAR_N, after (MaxAS)
		order MAXIMUM_AGE_N, after (MaxAS)
		order MINIMUM_AGE_N, after (MaxAS)
		
		drop if _merge == 1
		drop _merge
		
		* Correcting the duplicate ProviderID in later years
		replace ProviderID = 553 if StreetAddress == "4255 W Division St"
		replace ProviderID = 4281 if StreetAddress == "8225 S Throop St"
		replace ProviderID = 4391 if StreetAddress == "9813 S Avenue M"
		replace ProviderID = 10744 if StreetAddress == "5740 S Mozart St"
		replace ProviderID = 12159 if StreetAddress == "823 W Lawrence Ave"
		
		*Correcting Typos in ProviderID
		replace ProviderID = 2475 if ORG_ID == "B17728"
		replace ProviderID = 3712 if ORG_ID == "B31341"
		replace ProviderID = 4104 if ORG_ID == "B60863"
		replace ProviderID = 4393 if ORG_ID == "B17550"
		replace ProviderID = 10374 if ORG_ID == "B44206"

	}
	
	// do file that containes the variable labels 
	do "inccrra_provider_data_label"
	save "${cleaned_data_dir}\Provider Level Data `year_val'", replace
}
end

inccrraProviderClean
cap log close 
set trace off
exit