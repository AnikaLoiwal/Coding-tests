global dir "C:\Users\Admin\Documents\NSS 61 (4)\NSS 61" ///Please change the directory///
global data "$dir\data"


*i Load the household level data (level01)
use "$data\level01.dta", clear
rename mpce_30_days mpce 
destring mpce, replace 
destring hh_size, replace 

*Calculate monthly per capita consumption expenditure
gen per_capita_expenditure = mpce / hh_size
gen states=substr(state_region,1,2)
destring states, replace 
label define states 1 Jammu_and_Kashmir 2 Himachal_Pradesh 3 Punjab 4 Chandigarh 5 Uttaranchal 6 Haryana 7 Delhi 8 Rajasthan 9 Uttar_Pradesh 10 Bihar 11 Sikkim 12 Arunachal_Pradesh 13 Nagaland 14 Manipur 15 Mizoram 	16 Tripura 17 Meghalaya 	18 Assam 19 West_Bengal 20 Jharkhand 21 Orissa 	22 Chhattisgarh 23 Madhya_Pradesh 24 Gujrat 25 Daman_and_Diu 26 Dadra_and_Nagar_Haveli 27 Maharastra 28 Andhra_Pradesh 29 Karnataka 30 Goa 31 Lakshadweep 32 Kerala 33 Tamil_Nadu 34 Pondicheri 35 Andaman_and_Nicober 
label values states states
tab states

*Calculate the mean per capita expenditure for each state
preserve
collapse (mean) per_capita_expenditure, by(states)
list states per_capita_expenditure 
restore
*states like Mizoram (highest)(Rs. 11786) Chandigarh (Rs. 1471); Delhi (Rs.1403), Andaman and Nicobar (Rs.1254) and Nagaland (Rs. 1162) are the five topmost states to have the highest per capita consumption expenditure 


*ii Load the household level data (level01)

*Calculate deciles
sum per_capita_expenditure, detail
xtile decile = per_capita_expenditure, n(10)

*cut-offs 
summarize per_capita_expenditure if decile ==1, detail
summarize per_capita_expenditure if decile ==2, detail
summarize per_capita_expenditure if decile ==3, detail
summarize per_capita_expenditure if decile ==4, detail
summarize per_capita_expenditure if decile ==5, detail
summarize per_capita_expenditure if decile ==6, detail
summarize per_capita_expenditure if decile ==7, detail
summarize per_capita_expenditure if decile ==8, detail
summarize per_capita_expenditure if decile ==9, detail
summarize per_capita_expenditure if decile ==10, detail

*merging level01 with level03 and level04.dta datasets
use "$data\level01.dta", clear
merge 1:m common_id using "$data\level03.dta", nogen
save "$data\merged_data3.dta", replace
merge 1:1 _n using "$data\level04.dta"
save "$data\merged_dataset.dta", replace 


* iii Load the individual level data
use "$data\merged_dataset.dta", clear

*Keep individuals aged 15-59
destring age, replace 
*keep if age >= 15 & age <= 59
label define sex 1 Male 2 Female
destring sex, replace
label values sex sex 
//keep common_id age pri_activity_status sex
*Keep individuals aged 15-59
destring age, replace
keep if age >= 15 & age <= 59
destring sex, replace
destring pri_activity_status, replace
keep if pri_activity_status >= 11 & pri_activity_status <= 51
sort pri_activity_status
bys pri_activity_status: gen tot_pop = _N

*computing proportion of female and male employed by principle status (11-51)
egen tot_fem = total(sex) if sex == 2, by(pri_activity_status)
replace tot_fem = tot_fem/2
bysort pri_activity_status: replace tot_fem = tot_fem[_n-1] if missing(tot_fem)
bysort pri_activity_status: replace tot_fem = tot_fem[_n+1] if missing(tot_fem)
egen tot_male = total(sex) if sex == 1, by(pri_activity_status)
bysort pri_activity_status: replace tot_male = tot_male[_n-1] if missing(tot_male)
bysort pri_activity_status: replace tot_male = tot_male[_n+1] if missing(tot_male)
gen female_prop = tot_fem/tot_pop
gen male_prop = tot_male/tot_pop

*testing if employment proportion is significantly different across males and females:
ttest female_prop == male_prop
*we find that we reject the null hypothesis as P-value for two-tailed test is less than 0.05 (at 5 % level of significance), hence employment proportion is significantly different across males and females . 
 
*iv Load the household and individual level data (merged dataset)
* Keep females aged 15-59
keep if sex == 2 & age >= 15 & age <= 59

* Calculate employment rate by principal status for females
rename mpce_30_days mpce 
destring mpce, replace 
destring hh_size, replace
* Calculate monthly per capita consumption expenditure
gen per_capita_expenditure = mpce / hh_size
xtile decile = per_capita_expenditure, n(10)

*Plotting the difference in employment rate for females aged 15-59, across expenditure dciles
egen emp_rate = mean(tot_fem), by(decile)
graph bar emp_rate, over(decile) blabel(bar) title ("Employment Rate by Expenditure Decile for Females Aged 15-59")
graph export graph1.pdf, replace
*the employment rate by principal status for females (aged 15-59) differs slightly ranging between 17000 to 17230 from 1st to 9th decile and is much lower for the last expenditure decile.

* v Load the individual level data
use "$data\merged_dataset.dta", clear
tostring age, replace
rename _merge _1merge
*merging level06 with merged dataset
merge 1:1 _n using "$data\level06.dta"


* Generating month ang year variables from July 2004 to June 2005
tostring date_of_survey, replace 
gen year = substr(date_of_survey, 5, .)
destring year, replace
replace year = 2004 if year==4
replace year = 2005 if year==5
gen month = substr( date_of_survey, 3, 2)
destring month, replace
gen year_mo = ym(year, month)
format year_mo %tm
drop if year_mo >545

*generating daily wage rate variable 
destring age, replace
destring daily_activity_status, replace
label define daily_activity_status 11 worked_in_hh_enterprise_selfemployed_own_account_worker 	12 employer 	21 worked_as_helper_in_hh_enterprise_unpaid_family_worker	31 worked_as_regular_salaried_wage_employee 	41 worked_as_casual_wage_labour_in_public_works 	51 worked_as_casual_wage_labour_other_types_of_work 	61 had_work_in_hh_enterprise_but_did_not_work_due_to_sickness	62 had_work_in_hh_enterprise_but_did_not_work_due_to_other_reasons 	71 had_regular_salaried_wage_employment_but_did_not_work_due_to_sickness 	72 had_regular_salaried_wage_employment_but_did_not_work_due_to_other_reasons 	81 sought_work	82 did_not_seek_but_was_available_for_work 	91 attended_educational_institution 	92 attended_domestic_duties_only 	93 attended_domestic_duties_and_was_also_engaged_in_free_collection_of_goods_sewing_tailoring_weaving_for_household_use 	94 rentiers_pensioners_remittance_recipients 	95 not_able_to_work_due_to_disability 	97 others_including_begging_prostitution 	98 did_not_work__due_to_temporary_sickness_for_casual_workers_only 
destring daily_activity_status, replace
label values daily_activity_status daily_activity_status
destring earning_cash_seven_days_work, replace

* Keep individuals salaried employment
keep if daily_activity_status == 31
gen daily_wage_rate = earning_cash_seven_days_work/7 if daily_activity_status == 31

*saving merged dataset with level06 containing year, month and daily wage variables 
save "$data\merged_data_daily_wage.dta", replace 


*calculating average daily wage rate for individuals with salaried employment and plotting it month wise from July 2004 to June 2005
collapse (mean) avg_daily_wage = daily_wage_rate, by (year_mo)
tsset year_mo
label variable avg_daily_wage "Average Daily Wage"
label variable year_mo "Year Month"
twoway (tsline avg_daily_wage)
graph export graph2.pdf, replace
*the average wage rate across months between July 2004-June 2005 is highly fluctuating.


* vi Load the data saved with combined level 01, 03, 04 and 06 datasets containing year, month and daily wage variables 
use "$data\merged_data_daily_wage.dta", replace 


*Keep individuals aged 15-59
keep if age >= 15 & age <= 59

*Generate log of daily wage rate
gen log_daily_wage = log(daily_wage)

destring district, replace 
destring education, replace
destring  pri_activity_status, replace
label define sex 1 Male 2 Female
destring sex, replace
label values sex sex 

*Estimate the difference in log of daily wage rate between men and women, after controlling for age, education, district, occupation(pri_activity_status), month level (year_mo)
ssc install hdfe
regress log_daily_wage sex i.district i.pri_activity_status i.year_mo age education,cluster(district)
 
*performimg regression to absorb the fixed effects of controls 
* we can see that on an average, there is a 1.1 percentage points difference in male and female daily wage rate, provided other parameters are held constant/fixed.
*importing regression results in a tex file
eststo clear
eststo est1: reghdfe log_daily_wage sex age education, absorb(i.district i.pri_activity_status i.year_mo) 

// Add fixed effects information
estadd local Time_FE "yes"
estadd local District_FE "yes"
estadd local Occupation_FE "yes"

// Generate LaTeX code for the table, hiding specific control variables

esttab est1 using reg1_final.tex, ///
    cells(b(fmt(3) star) se(fmt(3) par)) ///
    label nodepvars nomtitle nonumber ///
    noobs collabels("Dependent Variable: Log Daily Wage" "") ///
    varlabels( "Sex" "Age" "Educational Level") ///
    stats(r2 N) ///
    starlevels(* 0.10 * 0.05 ** 0.01) ///
	addnote("**p$<$0.01, * p$<$0.05, * p$<$0.1") ///
    title("Regression Results showing Difference in Log Daily Wage across Gender") ///
    replace
	

*vii using the same dataset

*Keep salaried individuals aged 15-59
keep if daily_activity_status == 31 & age >= 15 & age <= 59
*Generate indicator variables for post-policy period (January 2005 onwards), female (1 if female and 0 if male), post_female an interaction between post_policy and female which is 1 if both post_policy and female is 1
*gen post_policy = (month >= 1 & year >= 2005)
gen post_policy = (year > 2005) | (year==2005 & month >=1)
gen female = (sex==2)
gen post_female = post_policy*female

*DID equation and results provided in latex pdf file 

*Estimate the effect of the policy change on the gender wage gap
regress log_daily_wage post_policy female post_female age education i.district i.pri_activity_status i.year_mo 

*performimg regression to absorb the fixed effects of controls 

*we can see that this policy increased wages of salaried females (aged 15-59) by 2.4 % on average, keeping age, education status constant and also controlling for district, occupation and month level
eststo clear
eststo est2: reghdfe log_daily_wage post_policy female post_female age education, absorb(i.district i.pri_activity_status i.year_mo) 

*Add fixed effects information
estadd local Time_FE "yes"
estadd local District_FE "yes"
estadd local Occupation_FE "yes"


*Generate LaTeX code for the table, hiding specific control variables

esttab est2 using reg2_final.tex, ///
   cells(b(fmt(3) star) se(fmt(3) par)) ///
   label nodepvars nomtitle nonumber ///
   noobs collabels("Dependent Variable: Log Daily Wage" "") ///
   varlabels(post_policy "Post Policy" female "Female" post_female "Post Policy*Female" age "Age" education "Education") ///
   stats(r2 N) ///
   starlevels(* 0.10 * 0.05 ** 0.01) ///
   addnote("***p$<$0.01, ** p$<$0.05, * p$<$0.1") ///
   title("Regression Results showing Gender gap in wages Post Policy") ///
   replace
	


  
