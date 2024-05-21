/*
Title: Prakriti's do file for thesis merging and regression 
Date: 10/27/2023
Datasets Used: merged_weather.csv, mergedata.dta, maize_gdd.dta, rice_gdd.dta, long_avgweather.dta, minmaxweather.dta
Includes merges, regression, and graphs
************************************************************
************************************************************/

clear 
cls 
set more off

* set global directory 
global path /Users/prakritishakya/Desktop/Dataset

************************************************************ 
*||||||||||||||||||||||||||| MERGE |||||||||||||||||||||||||
************************************************************ 
************************************************************ 

* importing merged weather dataset: weather data adjusted to a year before the interview was conducted
import delimited "/Users/prakritishakya/Desktop/Dataset/mergedata/merged_weather.csv", clear 

* merging it with main dataset (household, child, mother surveys)
merge 1:m district year using "$path/mergedata/mergedata_new.dta"

drop _merge

sort hhid_usaid  

* merge with rainy maize gdd dataset
merge m:1 district year using "$path/gddataset/maize_gdd.dta"

drop _merge

* merge with rainy rice gdd dataset
merge m:1 district year using "$path/gddataset/rice_gdd.dta"

drop _merge

* merge total long trend of avg weather data
merge m:1 district using "$path/Others/weatherdata/long_avgweather.dta"

drop _merge

* merge with min max temperature 
merge m:1 year district using "$path/Others/weatherdata_minmax/minmaxweather.dta"

drop _merge

* merge with cropland filtered temperature 
*merge m:1 year district using "$path/cropland_weather/croplandweather.dta"

*drop _merge

************************************************************ 
*|||||||||||||||||CREATE NEW VARIABLES |||||||||||||||||||||
************************************************************ 
************************************************************

* creating z scores for temperature and precipitation 

gen z_avgtemp = (avgtemp - avg_temp)/ std_avg_temp

/* here
avgtemp = avg temp in the year by district 
avg_temp = avg temp over the years 1979-2016 by district 
std_avgtemp = sd(avg temp in each of the years 1979-2016 by district)
*/

order avg_temp std_avg_temp z_avgtemp, after(avgtemp)

gen z_avgprp = (avgprp - avg_prp)/ std_avg_prp

/* here
avgprp = avg prp in the year by district 
avg_prp = avg prp over the years 1979-2016 by district 
std_avgprp = sd(avg prp in each of the years 1979-2016 by district)
*/

order avg_prp std_avg_prp z_avgprp, after(avgprp)

* generate districts that were a part of MSNP Phase I (2013-2017) 1 if in the program
gen msnp = 0

replace msnp = 1 if dist_name == "Bajhang" | dist_name == "Mugu" | dist_name == "Jumla" | dist_name == "Doti" | dist_name == "Rolpa" | dist_name == "Nawalparasi" | dist_name == "Bara" | dist_name == "Sarlahi" | dist_name == "Dhanusa" 
*11,888 changes made 

* generate dummy for defecate, 1 if inside the house 
gen defecate_in = 0
replace defecate_in = 1 if defecate == 1 | defecate == 2 | defecate == 7
* 8,196 changes made 

* generate dummy for treated water, 1 for treat
gen treat_water = 0
replace treat_water = 1 if f4c_4 == 1 
* 2,477 changes made 

* generate districts that were severely hit by earthquake 
gen earthquake = 0

replace earthquake = 1 if year == 2016 & dist_name == "Arghakhanchi"
replace earthquake = 1 if year == 2016 & dist_name == "Lamjung"
replace earthquake = 1 if year == 2016 & dist_name == "Rasuwa"
replace earthquake = 1 if year == 2016 & dist_name == "Sindhupalchok"
replace earthquake = 1 if year == 2016 & dist_name == "Kathmandu"
replace earthquake = 1 if year == 2016 & dist_name == "Ramechhap"
replace earthquake = 1 if year == 2016 & dist_name == "Solukhumbu"

******************************************************************************
******************************************************************************
******************************************************************************
******************************************************************************
************************** creating dummies for WEALTH INDEX

*** House ownership 
rename f4b_1 dwelling 

gen dwelling_own = 0
replace dwelling_own = 1 if dwelling == 1

gen dwelling_rent = 0
replace dwelling_rent = 1 if dwelling == 2 

gen dwelling_free = 0
replace dwelling_free = 1 if dwelling == 3

gen dwelling_other = 0
replace dwelling_other = 1 if dwelling == 8

*** electricity 

gen electricity = 0 
replace electricity = 1 if f4b_3 == 1

*** Source of cooking fuel 

rename f4b_4 cooking 

gen cooking_firewood = 0 
replace cooking_firewood = 1 if cooking == 1 

gen cooking_gas = 0 
replace cooking_gas = 1 if cooking == 2

gen cooking_biogas = 0 
replace cooking_biogas = 1 if cooking == 3 

gen cooking_electricity = 0 
replace cooking_electricity = 1 if cooking == 4

gen cooking_kerosene = 0 
replace cooking_kerosene = 1 if cooking == 5 

gen cooking_dung = 0 
replace cooking_dung = 1 if cooking == 6 

gen cooking_other = 0 
replace cooking_other = 1 if cooking == 8 

*** removing missing values \\ for assets ownership

drop if f4b5_a == 97 | f4b5_a == 66 
drop if f4b5_b == 97 | f4b5_b == 66
drop if f4b5_c == 97 | f4b5_c == 66
drop if f4b5_d == 97 | f4b5_d == 66
drop if f4b5_e == 97 | f4b5_d == 66
drop if f4b5_f == 97 | f4b5_d == 66
drop if f4b5_g == 97 | f4b5_d == 66
drop if f4b5_h == 97 | f4b5_d == 66

*** Source of drinking water

rename f4c_1 water

gen water_well = 0 
replace water_well = 1 if water == 1 

gen water_bottled = 0 
replace water_bottled = 1 if water == 2

gen water_tube = 0 
replace water_tube = 1 if water == 3 

gen water_tap = 0 
replace water_tap = 1 if water == 4 

gen water_piped = 0 
replace water_piped = 1 if water == 5 

gen water_other = 0 
replace water_other = 1 if water == 8  

*** Own land 

gen own_land = 0 
replace own_land = 1 if f4i_1 == 1

*** Own any livestock 

gen own_livestock = 0
replace own_livestock = 1 if f4l1 == 1 

*** removing missing values Livestock/Poultry/Aquaculture
drop if f4l2_a == 9 | f4l2_a == 66 | f4l2_a == 97
drop if f4l2_b == 9 | f4l2_b == 66 | f4l2_b == 97
drop if f4l2_c == 9 | f4l2_c == 66 | f4l2_c == 97
drop if f4l2_d == 9 | f4l2_d == 66 | f4l2_d == 97
drop if f4l2_e == 9 | f4l2_e == 66 | f4l2_e == 97
drop if f4l2_f == 9 | f4l2_f == 66 | f4l2_f == 97
drop if f4l2_g == 9 | f4l2_g == 66 | f4l2_g == 97
drop if f4l2_h == 9 | f4l2_h == 66 | f4l2_h == 97
drop if f4l2_i == 9 | f4l2_i == 66 | f4l2_i == 97
drop if f4l2_j == 9 | f4l2_j == 66 | f4l2_j == 97
drop if f4l2_k == 9 | f4l2_k == 66 | f4l2_k == 97

*** has separate kitchen 

gen separate_kitchen = 0
replace separate_kitchen = 1 if f51 == 1

*** Floor material 

rename f52 floor 

gen floor_sand = 0
replace floor_sand = 1 if floor == 1

gen floor_dung = 0
replace floor_dung = 1 if floor == 2

gen floor_wood = 0
replace floor_wood = 1 if floor == 3

gen floor_bamboo = 0
replace floor_bamboo = 1 if floor == 4

gen floor_parquet = 0
replace floor_parquet = 1 if floor == 5

gen floor_asphalt = 0
replace floor_asphalt = 1 if floor == 6

gen floor_ceramic = 0
replace floor_ceramic = 1 if floor == 7

gen floor_cement = 0
replace floor_cement = 1 if floor == 8

gen floor_carpet = 0
replace floor_carpet = 1 if floor == 9

gen floor_other = 0
replace floor_other = 1 if floor == 98

*** Wall material 

rename f53 wall 

gen wall_no = 0
replace wall_no = 1 if wall == 0

gen wall_palm = 0
replace wall_palm = 1 if wall == 1

gen wall_mud = 0
replace wall_mud = 1 if wall == 2

gen wall_bamboo_mud = 0
replace wall_bamboo_mud = 1 if wall == 3

gen wall_stone_mud = 0
replace wall_stone_mud = 1 if wall == 4

gen wall_plywood = 0
replace wall_plywood = 1 if wall == 5

gen wall_cardboard = 0
replace wall_cardboard = 1 if wall == 6

gen wall_wood = 0
replace wall_wood = 1 if wall == 7

gen wall_cement = 0
replace wall_cement = 1 if wall == 8

gen wall_stone_cement = 0
replace wall_stone_cement = 1 if wall == 9

gen wall_bricks = 0
replace wall_bricks = 1 if wall == 10

gen wall_blocks = 0
replace wall_blocks = 1 if wall == 11

gen wall_planks = 0
replace wall_planks = 1 if wall == 12

gen wall_other = 0
replace wall_other = 1 if wall == 98

*** Roof material 

rename f54 roof

gen roof_no = 0
replace roof_no = 1 if roof == 0

gen roof_thatch = 0
replace roof_thatch = 1 if roof == 1

gen roof_rustic = 0
replace roof_rustic = 1 if roof == 2

gen roof_palm = 0
replace roof_palm = 1 if roof == 3

gen roof_planks = 0
replace roof_planks = 1 if roof == 4

gen roof_cardboard = 0
replace roof_cardboard = 1 if roof == 5

gen roof_sheet = 0
replace roof_sheet = 1 if roof == 6

gen roof_wood = 0
replace roof_wood = 1 if roof == 7

gen roof_calamine = 0
replace roof_calamine = 1 if roof == 8

gen roof_ceramic = 0
replace roof_ceramic = 1 if roof == 9

gen roof_cement = 0
replace roof_cement = 1 if roof == 10

gen roof_shingles = 0
replace roof_shingles = 1 if roof == 11

gen roof_other = 0
replace roof_other = 1 if roof == 98

*** Type of toilet 

rename f55 toilet

gen toilet_no = 0
replace toilet_no = 1 if toilet == 0

gen toilet_flush = 0
replace toilet_flush = 1 if toilet == 1

gen toilet_ventilated_pit = 0
replace toilet_ventilated_pit = 1 if toilet == 2

gen toilet_pit = 0
replace toilet_pit = 1 if toilet == 3

gen toilet_other = 0
replace toilet_other = 1 if toilet == 8

*******************************************************************************
* CREATING THE INDEX

pca dwelling_own dwelling_rent dwelling_free dwelling_other electricity cooking_firewood cooking_gas cooking_biogas cooking_electricity cooking_kerosene cooking_dung cooking_other f4b5_a f4b5_b f4b5_c f4b5_d f4b5_e f4b5_f f4b5_g f4b5_h water_well water_bottled water_tube water_tap water_piped water_other own_land own_livestock f4l2_a f4l2_b f4l2_c f4l2_d f4l2_e f4l2_f f4l2_g f4l2_h f4l2_i f4l2_j f4l2_k separate_kitchen floor_sand floor_dung floor_wood floor_bamboo floor_parquet floor_asphalt floor_ceramic floor_cement floor_carpet floor_other wall_no wall_palm wall_mud wall_bamboo_mud wall_stone_mud wall_plywood wall_cardboard wall_wood wall_cement wall_stone_cement wall_bricks wall_blocks wall_planks wall_other roof_no roof_thatch roof_rustic roof_palm roof_planks roof_cardboard roof_sheet roof_wood roof_calamine roof_ceramic roof_cement roof_shingles roof_other toilet_no toilet_flush toilet_ventilated_pit toilet_pit toilet_other

predict wealthindex

egen wealthindex_std = std (wealthindex)

************************************************************ 
*||||||||||||||||||| RENAME VARIABLES |||||||||||||||||||||
************************************************************ 
************************************************************

* renaming variables 
rename f4e1_1 hh_exp
rename f4f_1 negeffect
rename f7chld_age child_age
rename f7chld_sex child_sex
rename f7d5_d micronutrient
rename f7e_2 healthfacility
rename f7f_1j refusedeat
rename f6moth_age mother_age
rename f6no_child childnum

rename f6b_r1 mother_poorappetite
rename f6l_3h decision_exp
rename f6l_3j decision_nutri

rename f4d1_a inc_farming
rename f4d3_a incin_farming
rename f4d1_b inc_livestock
rename f4d1_c inc_forest
rename f4d3_c incin_forest
rename f4d1_d inc_biz
rename f4d3_d incin_biz
rename f4d1_e inc_wage
rename f4d3_e incin_wage
rename f4d1_f inc_salary
rename f4d7_a remittance

rename f6weight maternal_weight
rename f7h_4 breastfed_perday
rename f4c_7 defecate
rename f7weight child_weight
rename f4hfiasscr food_insecurityscore

rename f7f_1a loose_stool
rename f7f_1b cough
rename f7f_1g fever
rename f7f_1h malaria
rename f7f_1i vomiting

drop if loose_stool == 9 
drop if cough == 9 
drop if fever == 9 
drop if malaria == 9 
drop if vomiting == 9 

************************************************************ 
*|||||||||||||||| CLEAN VARIABLES used |||||||||||||||||||||
************************************************************ 
************************************************************

drop if f7waz ==.
* 935 observations dropped

replace adlt_scho2 = 0 if adlt_scho2 ==.

drop if adlt_scho2 > 17
* 4 observations deleted 

tab adlt_scho2

gen childsex = 0
replace childsex = 1 if child_sex == 1
drop child_sex
rename childsex child_sex

save "$path/final.dta"

*************************************************************************
*************************************************************************
*||||||||||||||||||--------- REMOVING OUTLIERS ---------|||||||||||||||||
*************************************************************************
*************************************************************************

/*
su f7whz if region == 1 & child_sex == 1, d
* drop if f7whz < -3.37 and f7whz > 1.99
su f7whz if region == 1 & child_sex == 0, d
* drop if f7whz < -3.21 and f7whz > 1.76

su f7whz if region == 2 & child_sex == 1, d
* drop if f7whz < -3.07 and f7whz > 2.01
su f7whz if region == 2 & child_sex == 0, d
* drop if f7whz < -3.11 and f7whz > 1.9

su f7whz if region == 3 & child_sex == 1, d
* drop if f7whz < -3.67 and f7whz > 1.19
su f7whz if region == 3 & child_sex == 0, d
* drop if f7whz < -3.59 and f7whz > 1.11

*REGION 1
drop if child_sex == 1 & region == 1 & f7whz < -3.37 
*12 dropped
drop if child_sex == 1 & region == 1 & f7whz > 1.99
*185 dropped
drop if child_sex == 0 & region == 1 & f7whz < -3.21
*11 dropped
drop if child_sex == 0 & region == 1 & f7whz > 1.76
*164 dropped

*REGION 2
drop if child_sex == 1 & region == 2 & f7whz < -3.07
*22 dropped
drop if child_sex == 1 & region == 2 & f7whz > 2.01
*236 dropped
drop if child_sex == 0 & region == 2 & f7whz < -3.11
*18 dropped
drop if child_sex == 0 & region == 2 & f7whz > 1.9
*217 dropped

*REGION 3
drop if child_sex == 1 & region == 3 & f7whz < -3.67
*50 dropped
drop if child_sex == 1 & region == 3 & f7whz > 1.19
*736 dropped
drop if child_sex == 0 & region == 3 & f7whz < -3.59 
*45 dropped
drop if child_sex == 0 & region == 3 & f7whz > 1.11
*654 dropped
*/

*************************************************************************
*************************************************************************
*||||||||||||||||||--------- REGRESSIONS ---------|||||||||||||||||||||||
*************************************************************************
*************************************************************************   

* creating boxplot for whz score
graph box f7whz, over (child_sex) over(region)	

*** here temperature is the same for the district - only three distinct differences in temperature which is why there are three lines, and no other variation, whereas with survey data, we have more variations
graph twoway (lfit gddrice f7whz) (scatter gddrice f7whz) if region == 3

* controls: child_age child_sex childnum mother_age adlt_scho2 wealthindex_std

* AVG TEMP ON WHZ SCORE **************** 1 fixed effect and standard error clustered at ward level 2 fixed effect and standard error clustered at district level
* Mountains 
eststo mountain1: reghdfe f7whz avgtemp child_age child_sex childnum mother_age adlt_scho2 wealthindex_std if region == 1, absorb (clusterid year) vce(cluster clusterid)
quietly estadd local fixed_cluster "Yes", replace
quietly estadd local fixed_year "Yes", replace 

outreg2 using reg_cluster.doc, replace ctitle(Mountains I) addtext(Ward FE, YES, Year FE, YES, Controls YES)

eststo mountain2: reghdfe f7whz avgtemp child_age child_sex childnum mother_age adlt_scho2 wealthindex_std if region == 1, absorb (district year) vce(cluster district)

quietly estadd local fixed_district "Yes", replace
quietly estadd local fixed_year "Yes", replace 

outreg2 using reg_cluster.doc, append ctitle(Mountains II) addtext(District FE, YES, Year FE, YES, Controls YES)

*binscatterhist f7whz avgtemp if region ==3, regtype(reghdfe) controls (child_age child_sex childnum mother_age adlt_scho2 wealthindex_std) absorb(clusterid year) cluster(clusterid) coefficient(0.01) ci(95) pvalue histogram (f7whz avgtemp)xhistbarheight(15) yhistbarheight(15)

*binscatter f7whz avgtemp, by(region)

* Hills 
eststo hills1: reghdfe f7whz avgtemp child_age child_sex childnum mother_age adlt_scho2 wealthindex_std if region == 2, absorb (clusterid year) vce(cluster clusterid)
quietly estadd local fixed_cluster "Yes", replace
quietly estadd local fixed_year "Yes", replace 

outreg2 using reg_cluster.doc, append ctitle(Hills I) addtext(Ward FE, YES, Year FE, YES, Controls YES)

eststo hills2: reghdfe f7whz avgtemp child_age child_sex childnum mother_age adlt_scho2 wealthindex_std if region == 2, absorb (district year) vce(cluster district)
quietly estadd local fixed_district "Yes", replace
quietly estadd local fixed_year "Yes", replace 

outreg2 using reg_cluster.doc, append ctitle(Hills II) addtext(District FE, YES, Year FE, YES, Controls YES)

* Terai 
eststo terai1: reghdfe f7whz avgtemp child_age child_sex childnum mother_age adlt_scho2 wealthindex_std if region == 3, absorb (clusterid year) vce(cluster clusterid)
quietly estadd local fixed_cluster "Yes", replace
quietly estadd local fixed_year "Yes", replace 

outreg2 using reg_cluster.doc, append ctitle(Terai I) addtext(Ward FE, YES, Year FE, YES, Controls YES)

eststo terai2: reghdfe f7whz avgtemp child_age child_sex childnum mother_age adlt_scho2 wealthindex_std if region == 3, absorb (district year) vce(cluster district)
quietly estadd local fixed_district "Yes", replace
quietly estadd local fixed_year "Yes", replace 

outreg2 using reg_cluster.doc, append ctitle(Terai II) addtext(District FE, YES, Year FE, YES, Controls YES)

esttab mountain1 mountain2 hills1 hills2 terai1 terai2 using "results1.doc", replace label se star(* 0.10 ** 0.05 *** 0.01)s(fixed_cluster fixed_year fixed_district N,label("Cluster FE" "Year FE" "District FE" "Observations")) keep(avgtemp)

* AVG MAX TEMP ON WHZ SCORE **************** standard error clustered at ward level
* Mountains 
eststo mountain1: reghdfe f7whz maxtemp child_age child_sex childnum mother_age adlt_scho2 wealthindex_std if region == 1, absorb (clusterid year) vce(cluster clusterid)
quietly estadd local fixed_cluster "Yes", replace
quietly estadd local fixed_year "Yes", replace 

eststo mountain2: reghdfe f7whz maxtemp child_age child_sex childnum mother_age adlt_scho2 wealthindex_std if region == 1, absorb (district year) vce(cluster district)
quietly estadd local fixed_district "Yes", replace
quietly estadd local fixed_year "Yes", replace 

* Hills 
eststo hills1: reghdfe f7whz maxtemp child_age child_sex childnum mother_age adlt_scho2 wealthindex_std if region == 2, absorb (clusterid year) vce(cluster clusterid)
quietly estadd local fixed_cluster "Yes", replace
quietly estadd local fixed_year "Yes", replace 

eststo hills2: reghdfe f7whz maxtemp child_age child_sex childnum mother_age adlt_scho2 wealthindex_std if region == 2, absorb (district year) vce(cluster district)
quietly estadd local fixed_district "Yes", replace 
quietly estadd local fixed_year "Yes", replace 

* Terai 
eststo terai1: reghdfe f7whz maxtemp child_age child_sex childnum mother_age adlt_scho2 wealthindex_std if region == 3, absorb (clusterid year) vce(cluster clusterid)
quietly estadd local fixed_cluster "Yes", replace
quietly estadd local fixed_year "Yes", replace 

eststo terai2: reghdfe f7whz maxtemp child_age child_sex childnum mother_age adlt_scho2 wealthindex_std if region == 3, absorb (district year) vce(cluster district)
quietly estadd local fixed_district "Yes", replace
quietly estadd local fixed_year "Yes", replace 

esttab mountain1 mountain2 hills1 hills2 terai1 terai2 using "results2.doc", replace label se star(* 0.10 ** 0.05 *** 0.01)s(fixed_cluster fixed_year fixed_district N,label("Cluster FE" "Year FE" "District FE" "Observations")) keep(maxtemp)

* GDD, HDD ON WHZ SCORE ****************
* Mountains 
eststo mountain: reghdfe f7whz gddrice hddrice child_age child_sex childnum mother_age adlt_scho2 wealthindex_std if region == 1, absorb (clusterid year) vce(cluster clusterid) 
quietly estadd local fixed_cluster "Yes", replace
quietly estadd local fixed_year "Yes", replace 

* Hills 
eststo hills: reghdfe f7whz gddrice hddrice child_age child_sex childnum mother_age adlt_scho2 wealthindex_std if region == 2, absorb (clusterid year) vce(cluster clusterid)   
quietly estadd local fixed_cluster "Yes", replace
quietly estadd local fixed_year "Yes", replace 

* Terai 
eststo terai: reghdfe f7whz gddrice hddrice child_age child_sex childnum mother_age adlt_scho2 wealthindex_std if region == 3, absorb (clusterid year) vce(cluster clusterid)   
quietly estadd local fixed_cluster "Yes", replace
quietly estadd local fixed_year "Yes", replace 

esttab mountain hills terai using "res.doc", replace label se star(* 0.10 ** 0.05 *** 0.01)s(fixed_cluster fixed_year N,label("Cluster FE" "Year FE" "Observations")) keep(gddrice hddrice gddmaize hddmaize)

* Z-SCORE OF AVG TEMP ON WHZ SCORE with separation of regions ****************
* Mountains 
eststo mountain1: reghdfe f7whz z_avgtemp child_age child_sex childnum mother_age adlt_scho2 if region == 1, absorb (clusterid year) vce(cluster clusterid)
quietly estadd local fixed_cluster "Yes", replace
quietly estadd local fixed_year "Yes", replace 

eststo mountain2: reghdfe f7whz z_avgtemp child_age child_sex childnum mother_age adlt_scho2 if region == 1, absorb (district year) vce(cluster district)

* Hills 
eststo hills1: reghdfe f7whz z_avgtemp child_age child_sex childnum mother_age adlt_scho2 if region == 2, absorb (clusterid year) vce(cluster clusterid)
quietly estadd local fixed_cluster "Yes", replace
quietly estadd local fixed_year "Yes", replace  

eststo hills2: reghdfe f7whz z_avgtemp child_age child_sex childnum mother_age adlt_scho2 if region == 2, absorb (district year) vce(cluster district)

* Terai 
eststo terai1: reghdfe f7whz z_avgtemp child_age child_sex childnum mother_age adlt_scho2 if region == 3, absorb (clusterid year) vce(cluster clusterid)
quietly estadd local fixed_cluster "Yes", replace
quietly estadd local fixed_year "Yes", replace 

eststo terai2: reghdfe f7whz z_avgtemp child_age child_sex childnum mother_age adlt_scho2 if region == 3, absorb (district year) vce(cluster district)

esttab mountain1 hills1 terai1 using "zscore.doc", replace label se star(* 0.10 ** 0.05 *** 0.01)s(fixed_cluster fixed_year fixed_district N,label("Cluster FE" "Year FE" "District FE" "Observations")) keep(z_avgtemp)

/* Z-SCORE OF AVG PRP ON WHZ SCORE with separation of regions ****************
* Mountains 
eststo mountain1: reghdfe f7whz z_avgprp child_age child_sex childnum mother_age adlt_scho2 if region == 1, absorb (clusterid year) vce(cluster clusterid)
quietly estadd local fixed_cluster "Yes", replace
quietly estadd local fixed_year "Yes", replace 

* Hills 
eststo hills: reghdfe f7whz z_avgprp child_age child_sex childnum mother_age adlt_scho2 if region == 2, absorb (clusterid year) vce(cluster clusterid)
quietly estadd local fixed_cluster "Yes", replace
quietly estadd local fixed_year "Yes", replace  

* Terai 
eststo terai: reghdfe f7whz z_avgprp child_age child_sex childnum mother_age adlt_scho2 if region == 3, absorb (clusterid year) 
quietly estadd local fixed_cluster "Yes", replace
quietly estadd local fixed_year "Yes", replace 

esttab mountain hills terai using "res1.doc", replace label se star(* 0.10 ** 0.05 *** 0.01)s(fixed_cluster fixed_year N,label("Cluster FE" "Year FE" "Observations")) keep(z_avgprp)
*/

************************************************************ 
*||||||||||||||||||||| GRAPHS ||||||||||||||||||||||||||||||
************************************************************ 
************************************************************
 

* GDD, HDD ON WHZ SCORE in terai region with different occupations ***********
* Terai 
/*
0 Not working 
1 Retired
2 Student 
3 Non earning occupation (housewife/FCHV) 
4 Wage employment 
5 Business/trade/self employment 
6 Salaried worker 
7 Agriculture/Livestock/Poultry/Aquaculture 
8 Others 68 Missing 97 NA */

* 0
reghdfe f7whz gddrice hddrice if region == 3 & adlt_ocup1 ==0, absorb (clusterid year) vce (cluster clusterid)

estimates store Notworking  

* 1
reghdfe f7whz gddrice hddrice if region == 3 & adlt_ocup1 ==1, absorb (clusterid year) vce (cluster clusterid)

estimates store Retired

* 2 - omitted
reghdfe f7whz gddrice if region == 3 & adlt_ocup1 ==2, absorb (clusterid year) vce (cluster clusterid)

estimates store Student

* 3
reghdfe f7whz gddrice hddrice if region == 3 & adlt_ocup1 ==3, absorb (clusterid year) vce (cluster clusterid)

estimates store Volunteers

* 4
reghdfe f7whz gddrice hddrice if region == 3 & adlt_ocup1 ==4, absorb (clusterid year) vce (cluster clusterid)

estimates store Wage

* 5
reghdfe f7whz gddrice hddrice if region == 3 & adlt_ocup1 ==5, absorb (clusterid year) vce (cluster clusterid)

estimates store Business

* 6
reghdfe f7whz gddrice hddrice if region == 3 & adlt_ocup1 ==6, absorb (clusterid year) vce (cluster clusterid)

estimates store Salaried

* 7
reghdfe f7whz gddrice hddrice if region == 3 & adlt_ocup1 ==7, absorb (clusterid year) vce (cluster clusterid)

estimates store Agriculture

* 8
reghdfe f7whz gddrice hddrice if region == 3 & adlt_ocup1 ==8, absorb (clusterid year) vce (cluster clusterid)

estimates store Others 

coefplot Notworking Retired Volunteers Wage Business Salaried Agriculture Others, drop(_cons hddrice) xline(0) ciopts(recast(rcap)) grid(none)
*****************************************************

* 6 is salaried worker
eststo terai1: reghdfe f7whz gddrice hddrice if region == 3 & adlt_ocup1 ==6, absorb (clusterid year) vce (cluster clusterid)
quietly estadd local fixed_cluster "Yes", replace
quietly estadd local fixed_year "Yes", replace 

* 7 is related to agriculture
eststo terai2: reghdfe f7whz gddrice hddrice if region == 3 & adlt_ocup1 ==7, absorb (clusterid year) vce (cluster clusterid)
quietly estadd local fixed_cluster "Yes", replace
quietly estadd local fixed_year "Yes", replace 

* 8 is others - negative sign - ignore
eststo terai3: reghdfe f7whz gddrice hddrice if region == 3 & adlt_ocup1 ==8, absorb (clusterid year) vce (cluster clusterid)
quietly estadd local fixed_cluster "Yes", replace
quietly estadd local fixed_year "Yes", replace  

* 3 is houseowner 
eststo terai2: reghdfe f7whz gddrice hddrice if region == 3 & adlt_ocup2 ==3, absorb (clusterid year) 
quietly estadd local fixed_cluster "Yes", replace
quietly estadd local fixed_year "Yes", replace 

esttab terai1 terai2 terai3 using "terai.doc", replace label se star(* 0.10 ** 0.05 *** 0.01)s(fixed_cluster fixed_year fixed_district N,label("Cluster FE" "Year FE" "Observations")) keep(avgtemp)

* coefplots for the main results 

reghdfe f7whz avgtemp avgprp child_age child_sex childnum mother_age adlt_scho2 wealthindex_std if region == 3, absorb (clusterid year) vce(cluster clusterid) 

estimates store Mountains

reghdfe f7whz maxtemp avgprp child_age child_sex childnum mother_age adlt_scho2 wealthindex_std if region == 3, absorb (district year) vce(cluster clusterid)

estimates store Hills

reghdfe f7whz z_avgtemp avgprp child_age child_sex childnum mother_age adlt_scho2 wealthindex_std if region == 3, absorb (clusterid year) vce(cluster clusterid)

estimates store Terai

coefplot Mountains Hills Terai, keep(avgtemp maxtemp z_avgtemp) xline(0) ciopts(recast(rcap)) grid(none) xlabel(-0.1(0.1)0.3, labsize(large)) xscale(range(-0.1(0.1)0.3)) 


* correlation between avgtemp and whz
twoway (fpfitci f7whz gddrice)

twoway (fpfitci hddrice f7whz) if region == 3

twoway (fpfitci gddrice f7whz) if region == 3

twoway (fpfitci f7whz gddrice)

twoway (fpfitci f7whz hddrice)

lowess f7whz avgtemp, bwidth(.5)

twoway (fpfitci hddrice avgtemp)


********************************************
********************************************
ONLY TERAI REGION
********************************************
********************************************

* temp on whz score // I add avgprp 
reghdfe f7whz avgtemp avgprp child_age child_sex childnum mother_age adlt_scho2 wealthindex if region == 3, absorb (clusterid year) vce(cluster clusterid)

estimates store avgtemp

reghdfe f7whz maxtemp avgprp child_age child_sex childnum mother_age adlt_scho2 wealthindex if region == 3, absorb (clusterid year) vce(cluster clusterid)

estimates store maxtemp

reghdfe f7whz z_avgtemp avgprp child_age child_sex childnum mother_age adlt_scho2 wealthindex if region == 3, absorb (clusterid year) vce(cluster clusterid)

estimates store z_avgtemp

coefplot avgtemp maxtemp z_avgtemp, keep(avgtemp maxtemp z_avgtemp) xline(0) ciopts(recast(rcap)) grid(none) xlabel(-0.1(0.1)0.3, labsize(large)) xscale(range(-0.1(0.1)0.3)) 

* temp on wasting
reghdfe f7cwasstat avgtemp child_age child_sex childnum mother_age adlt_scho2 if region == 3, absorb (clusterid year) vce(cluster clusterid)

* gdd hdd on whz score
reghdfe f7whz gddrice hddrice child_age child_sex childnum mother_age adlt_scho2 if region == 3, absorb (clusterid year) vce(cluster clusterid)

* gdd hdd on whz score
reghdfe f7cwasstat gddrice hddrice child_age child_sex childnum mother_age adlt_scho2 if region == 3, absorb (clusterid year) vce(cluster clusterid)

* maxtemp on whz score
reghdfe f7whz maxtemp child_age child_sex childnum mother_age adlt_scho2 if region == 3, absorb (clusterid year) vce(cluster district)

* farmers 
reghdfe f7whz gddrice hddrice child_age child_sex childnum mother_age adlt_scho2 if region == 3 & adlt_ocup1 == 7, absorb (clusterid year) vce(cluster clusterid)
