/****************************************************
Date: 04/13/2024
Title: STATA sample
Name: Prakriti Shakya
Task: Create a household size proxy, calculate total values of animal, tool, durable goods assets, create Kessler score and categories, merge all 3 datasets, run regressions
****************************************************/

********************** PART 1 ***********************

cls
clear
set more off

* set global path 

global path /Users/prakritishakya/Desktop/StataAssessment_2024

* call the demographics dataset 

use "$path/data/demographics.dta"

* creating a proxy variable for household size for Wave 1 

by hhid: egen hhsize_w1 = count(hhmid) if wave == 1

* assuming Wave 2 has the same size

by hhid: egen hhsize = count(hhsize_w1)

drop hhsize_w1 

label variable hhsize "Household Size"

save "$path/cleaned_demographics.dta"

****************************************************
****************************************************

cls
clear
set more off

* call the assets dataset 

use "$path/data/assets.dta"

* remove outliers 

replace currentvalue =. if currentvalue ==.d

* creating a new variable that contains median for each animal, tool, durable good type 

bysort animaltype toolcode durablegood_code: egen median = median(currentvalue)

* replacing the missing value in 'currentvalue' with the median 

replace currentvalue = median if currentvalue ==.

drop median

* create a new variable 'totalvalue' by multiplying quantity and the current value 

gen totalvalue = quantity * currentvalue

* dropping all the variables that we don't need 

drop InstanceNumber animaltype toolcode durablegood_code quantity currentvalue

* collapse all the observations to the sum of asset type

collapse (sum) totalvalue, by (hhid wave Asset_Type)

* generate just the numeric value of Asset_Type

gen asset = Asset_Type

/* here:
1 - Animals
2 - Tools
3 - Durable goods */

* drop Asset_Type

drop Asset_Type

* reshape from long to wide 

reshape wide totalvalue, i(hhid wave) j(asset)

* rename the total values

rename totalvalue1 animals
label variable animals "Total Value from Animals"

rename totalvalue2 tools
label variable tools "Total Value from Tools"

rename totalvalue3 durablegoods
label variable durablegoods "Total Value from Durable Goods"

foreach x of varlist animals tools durablegoods {
	replace `x' = 0 if `x' ==.
}

* create a total assets value

gen total_assets = animals + tools + durablegoods
label variable total_assets "Total Value from Assets"

* for merge later, change hhid to numeric 
destring hhid, replace

save "$path/cleaned_assets.dta"

****************************************************
****************************************************

clear
cls
set more off

* call the depression dataset 

use "$path/data/depression.dta"

* drop the label values for all the 10 questions for the score
label drop TFrequencyScale 

* dropping observations that have missing values for the 10 questions
drop if tired ==. & nervous ==. & sonervous ==. & hopeless ==. & restless ==. & sorestless ==. & depressed ==. & everythingeffort ==. & nothingcheerup ==. & worthless ==. 

* 22 observations dropped; dropped because calculating their total would conclude that they don't have any sort of depression which isn't true 

* converting missing values to zero because only some values are missing
foreach var of varlist tired-worthless {
	replace `var' = 0 if `var' ==.
}

* calculating the kessler_score by summing up the values 
gen kessler_score = tired + nervous + sonervous + hopeless + restless + sorestless + depressed + everythingeffort + nothingcheerup + worthless

label variable kessler_score "Kessler Score"

* creating kessler_categories with 4 categories: no significant depression, mild depression, moderate depression, and severe depression
gen kessler_categories = 0
replace kessler_categories = 1 if kessler_score >= 10 & kessler_score <= 19
replace kessler_categories = 1 if kessler_score >= 20 & kessler_score <= 24
replace kessler_categories = 1 if kessler_score >= 25 & kessler_score <= 29
replace kessler_categories = 1 if kessler_score >= 30 & kessler_score <= 50

label define label 1 "no significant depression" 2 "mild depression" 3 "moderate depression" 4 "severe depression"
label values kessler_categories label
label variable kessler_categories "Kessler Categories"

save "$path/cleaned_depression.dta"


****************************************************
*–––––––––––––––––––  PART 2  –––––––––––––––––––––*
****************************************************

clear
cls
set more off

* call cleaned demographics data
use "$path/cleaned_demographics.dta"

* merge it with depression data
merge 1:1 hhid hhmid wave using "$path/cleaned_depression.dta"

drop if _merge == 1 

* This is because those who did not match aren't household head or their spouse, so we don't have their data

* merge it with assets data
merge m:1 hhid wave using "$path/cleaned_assets.dta", gen (second_merge)

drop if second_merge == 2

* EXPLANATORY ANALYSIS 

** exploring the relationship between kessler_score and assets value 

* changing total_assets to log for easier interpretation

gen ln_assets = log(total_assets)

* regressing ln_assets on kessler_score 
reg kessler_score ln_assets if wave == 1 

* exporting the results to table
outreg2 using regression.doc, replace ctitle(Assets)

* visual representation of the relationship
scatter kessler_score ln_assets if wave == 1

** exploring the relationship between kessler_score and gender 

* dropping the label values
codebook gender
label drop tgender

* replacing female with 1 and male with 0
replace gender = 0 if gender == 1
replace gender = 1 if gender == 5

* visual representation of gender and its relation with Kessler score
graph box kessler_score if wave == 1, over(gender) 	

* regressing ln_assets on kessler_score 
reg kessler_score gender if wave == 1 

* exporting the results to table
outreg2 using regression.doc, append ctitle(Gender)

* regressing treat_hh on kessler_score for wave 2 observations 
reg kessler_score treat_hh if wave == 2

outreg2 using causal.doc, replace ctitle(OLS) addtext (HH FE, NO)

* with fixed effects 
xtset hhid
xtreg kessler_score treat_hh if wave == 2

outreg2 using causal.doc, append ctitle(Fixed Effects) addtext (HH FE, YES)

* regressing treat_hh on kessler_score for wave 2 observations 
reg kessler_score treat_hh gender c.gender#c.treat_hh if wave == 2

outreg2 using interact.doc, replace 

