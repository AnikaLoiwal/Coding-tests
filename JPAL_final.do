*set wordking directory (change the directory when running do file)
cd "C:\Users\Administrator\Downloads\JPAL\JPAL STATA test"
C:\Users\Administrator\Downloads\JPAL\JPAL STATA test

*Section 1
*1. importing data set in excel format and saving the same in .dta format in stata 
import excel "Data for Stata Test_2024 (1).xlsx", sheet("Data") firstrow clear
save "Data for Stata Test_2024.dta" , replace

*importing the supplementary dataset and renaming the matching variable in those two datasets as town_id
import excel "Town Names for Stata Test_2024 (1).xlsx", sheet("Sheet1") firstrow clear
rename TownID town_id

*2. merging the datasets with matching variable i.e., town_id 
merge 1:m town_id using "Data for Stata Test_2024.dta"
*dropping the irrelevant towns 
drop if _merge !=3
drop _merge

*3. creating numeric variable of district (which earlier was in string)
encode district, gen(dist_id)

*4. creating a unique id for each observation so that first three digits are town id. 
sort town_id dist_id
bys town_id : gen poll_id = _n
ssc install unique 
unique town_id poll_id
gen unique_id =town_id*1000+poll_id

*5. identifying missing data 
replace  registered_total = . if registered_total == -999

*6. creating a dummy variable for each of town_id 
tabulate town_id, generate(town_id)

*7. lablelling variables as 'ID variable', 'Electoral data' or 'Intervention'
label variable town_id "ID Variable"
label variable poll_id "ID Variable"
label variable unique_id "ID Variable"
label variable dist_id "ID Variable"
label variable turnout_total "Electoral data"
label variable turnout_male  "Electoral data"
label variable turnout_female "Electoral data"
label variable registered_total "Electoral data"
label variable registered_male "Electoral data"
label variable registered_female "Electoral data"
label variable treatment_phase "Intervention"

*8.labelling values for treatment variable 
label define treat 0 "not-treated" 1 "treated"
label values treatment treat
sort town_id dist_id


*Section 2
*9. Taking out the summary for turnout_total to calculate the average (mean) turnout rate, minimum and maximum 
* The total turnout rate on average is approx. 465, with 0 being the lowest turnout and 1045 being the highest turnout rates.  
* summarize turnout_total to get statistics, including the max
summarize turnout_total
summarize turnout_total, detail
* store the max value in a local macro
local maxturnout = r(max)
* count the observations where turnout_total equals the max value, number of pooling booths recording the highest turnout rate is 1.  
count if turnout_total == `maxturnout'


*10. tabulating the number of booths in phases 1 and 2 of the study 
tab treatment if treatment_phase == 1 | treatment_phase == 2

*11. tabulating the average turnout rate for females for each district having a total turnout rate of 75% or above 
* preserve the original dataset
preserve
keep if turnout_total >= 75
collapse (mean) turnout_female, by (district)
* to revert to the original dataset
restore

*12. Using the data to test for the significance of the difference in the average female turnout rates for tratement vs control.
 ttest turnout_female, by(treatment)
*The average turnout rate for females is higher in treatment pooling booths (which is approximately 216) than control booths (which is 208 approx.) 
*The difference is significant as the treatment mean is different than control mean and p value for left tailed and two tailed test is 0, is very less than 0.05 or 0.01 and thus significant at 5 or 1% level of signifiance.

*13. creating a bar graph which shows the difference in turnout between treatment and control pooling booths by gender and by total turnout
* first creating new treatment numeric variable
tostring treatment, generate(treatment_str)
generate treatment_status = 0 if treatment_str == "0"
replace treatment_status = 1 if treatment_str == "1"
* plotting the graph
preserve
graph bar turnout_total turnout_female, over(treatment_status) legend(label(1 "Treatment") label(2 "Control")) title("Turnout by Treatment Group") blabel(bar, position(center) format(%2.2f)) graphregion(color(white)) bgcolor(white)
		 
		 
*Section 3	 
*14. to show the effect of treatment on total turnout, regression is performed by regressing the dependent variable total turnout 
*on independent variables: treatment, all dummies of town id and registered turnout (registered total)
regress turnout_total treatment i.town_id registered_total
*outputting results in excel 
ssc install outreg2
outreg2 using "regression_results.xlsx", replace

*15. calculating mean turnout for the control group and treatment, mean turnout for control group is 461.25  
summarize turnout_total if treatment == 0
summarize turnout_total if treatment == 1

*16. the dependent variable is turnout_total here. 

*17. Mean for total turnout for control and treatment is already calculated in question 15, thus change in the dependent variable after intervention or difference between treatment and control of turnout is -7.4

*18. difference in turnout between treatment and control is statistically significant at 5 % level of significance, as the p value for two tailed test is 0.04 and for left tailed test is 0.02(less than 0.05)
ttest turnout_total, by(treatment)

 
