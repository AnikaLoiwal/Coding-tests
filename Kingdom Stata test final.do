*Importing dataset into stata // set your own directory
import delimited "C:\Users\Administrator\Downloads\sample_data_set_RA_hiring.csv"

* Create log of total monthly household expenditure
gen ln_total_expenditure = log(total_expenditure)  

* Create log of residual income as a control variable
gen ln_resid_income = log(resid_income)  

* Generate a dummy variable indicating households in Vastrapur (New Kingdom)
gen NK = (kingdom == "New Kingdom")  

* Create a time variable combining year and month
gen time = ym(year, month)  
format time %tm  

* Generate a dummy variable for the treatment period (for May 2016 onwards, when King's Gift policy was implemented)
gen KG = (time >= ym(2016,5))  

* Create the interaction term for Difference-in-Differences (DID) estimation, to see the post policy effect
gen NK_KG = NK * KG  

* Set panel data structure: household ID (hh_id) as the panel identifier and time as the time variable
xtset hh_id time  

* Run DID regression for all farmers in Vastrapur
* This assesses the average effects of the cash transfer policy across all farmers and we add time fixed effects and cluster errors by province: this gives the average treatment effect as 0.105, which means that cash transfer policy increases total expenditure of all farmers in Vastrapur by 10.5%, when controlling for inflation and residual income and including time fixed effects and clustering errors by province.
xtreg ln_total_expenditure NK KG NK_KG ln_resid_income inflation_r i.time, fe vce(cluster province)  

*The policy had a statistically significant (as the p value 0.04 is less than 5% level of significance) positive impact on household consumption in Vastrapur.


* Generate a dummy variable indicating if the household is a small farmer
gen is_small_farmer = (hh_occupation == "Small Farmers")  

* Run DID regression for small farmers
* This evaluates the effect of the cash transfer policy specifically for small farmers. This assesses the average effects of the cash transfer policy across small farmers and we add time fixed effects and cluster errors by province:This gives the average treatment effect as 0.115, which means that cash transfer policy increases total expenditure of small farmers in Vastrapur by 11.5%, when controlling for inflation and residual income and including time fixed effects and clustering errors by province.
xtreg ln_total_expenditure NK KG NK_KG ln_resid_income inflation_r i.time if is_small_farmer == 1, fe vce(cluster province) 

*Small farmers experience the largest benefit amongst all, as their total expenditure increased the most due to King's gift policy. The impact is statistically significant at 1 % level of significance, for p value of interaction term is 0.007, less than 0.01.

* Generate a dummy variable indicating if the household is a large farmer
gen is_large_farmer = (hh_occupation == "Large Farmers")  

* Run DID regression for large farmers
* This evaluates the effect of the cash transfer policy specifically for large farmers. This assesses the average effects of the cash transfer policy across large farmers and we add time fixed effects and cluster errors by province: this gives the average treatment effect as 0.105, which means that cash transfer policy increases total expenditure of large farmers in Vastrapur by 7.6%, when controlling for inflation and residual income and including time fixed effects and clustering errors by province.
xtreg ln_total_expenditure NK KG NK_KG ln_resid_income inflation_r i.time if is_large_farmer == 1, fe vce(cluster province)  

*The policy positively impacted the expenditure of large farmers too, but was lower compared to small farmers. But this effect is not statistically significant as though consumption is meant to increase by 7.6% , the p value is 0.3, greater than 5% level of significance and hence not that significant. We can say that this is significant at 10 % level of significance and probably, the increase cannot be solely attributed to the cash transfer policy and the regression needs more controls to be added. 

* Generate a dummy variable indicating if the household is an agricultural laborer
gen is_agri_labourer = (hh_occupation == "Agricultural Labourers")  

* Run DID regression for agricultural laborers
* This evaluates the effect of the cash transfer policy specifically for agricultural laborers. This assesses the average effects of the cash transfer policy across agricultural laborers and we add time fixed effects and cluster errors by province:this gives the average treatment effect as 0.105, which means that cash transfer policy decreases total expenditure of agricultural labourers in Vastrapur by 0.3%, when controlling for inflation and residual income and including time fixed effects and clustering errors by province.
xtreg ln_total_expenditure NK KG NK_KG ln_resid_income inflation_r i.time if is_agri_labourer == 1, fe vce(cluster province)  

*Thus, the cash transfer policy though positively impacts small and large farmers, it does not benefit the agricultural labourers much and rather slightly decreases their total household expenditure by 0.3% which is but insignificant as p value is  0.9, greater than any significance level. This could also mean there maybe a potential inequity in policy design or implementation. 

* Clear stored estimation results
eststo clear  

* Store and label the first regression results (all farmers) for LaTeX output
eststo est1: xtreg ln_total_expenditure NK KG NK_KG ln_resid_income inflation_r i.time, fe vce(cluster province)  

* Add fixed effects labels to the table
estadd local Time_FE "yes"  
estadd local Household_FE "yes"  

* Export regression results to LaTeX for all farmers
esttab est1 using didreg1.tex, ///
   cells(b(fmt(3) star) se(fmt(3) par)) ///
   label nodepvars nomtitle nonumber ///
   noobs collabels("Dependent Variable: Log total expenditure" "") ///
   varlabels(NK "New Kingdom" KG "King's Gift"  NK_KG "New Kingdom*King's Gift" inflation_r "Rural Inflation" ln_resid_income "Residual Income") ///
   stats(r2 N) ///
   starlevels(* 0.10 * 0.05 ** 0.01) ///
   addnote("***p$<$0.01, ** p$<$0.05, * p$<$0.1") ///
   title("Regression Results showing effect of cash transfer policy to Vastrapur farmers") ///
   replace  

* Store and label the second regression results (small farmers) for LaTeX output
eststo est2: xtreg ln_total_expenditure NK KG NK_KG ln_resid_income inflation_r i.time if is_small_farmer == 1, fe vce(cluster province)  

* Add fixed effects labels to the table
estadd local Time_FE "yes"  
estadd local Household_FE "yes"  

* Export regression results to LaTeX for small farmers
esttab est2 using didreg2.tex, ///
   cells(b(fmt(3) star) se(fmt(3) par)) ///
   label nodepvars nomtitle nonumber ///
   noobs collabels("Dependent Variable: Log total expenditure" "") ///
   varlabels(NK "New Kingdom" KG "King's Gift"  NK_KG "New Kingdom*King's Gift" inflation_r "Rural Inflation" ln_resid_income "Residual Income") ///
   stats(r2 N) ///
   starlevels(* 0.10 * 0.05 ** 0.01) ///
   addnote("***p$<$0.01, ** p$<$0.05, * p$<$0.1") ///
   title("Regression Results showing effect of cash transfer policy to small farmers of Vastrapur") ///
   replace  

* Store and label the third regression results (large farmers) for LaTeX output
eststo est3: xtreg ln_total_expenditure NK KG NK_KG ln_resid_income inflation_r i.time if is_large_farmer == 1, fe vce(cluster province)  

* Add fixed effects labels to the table
estadd local Time_FE "yes"  
estadd local Household_FE "yes"  

* Export regression results to LaTeX for large farmers
esttab est3 using didreg3.tex, ///
   cells(b(fmt(3) star) se(fmt(3) par)) ///
   label nodepvars nomtitle nonumber ///
   noobs collabels("Dependent Variable: Log total expenditure" "") ///
   varlabels(NK "New Kingdom" KG "King's Gift"  NK_KG "New Kingdom*King's Gift" inflation_r "Rural Inflation" ln_resid_income "Residual Income") ///
   stats(r2 N) ///
   starlevels(* 0.10 * 0.05 ** 0.01) ///
   addnote("***p$<$0.01, ** p$<$0.05, * p$<$0.1") ///
   title("Regression Results showing effect of cash transfer policy to large farmers of Vastrapur") ///
   replace  

* Store and label the fourth regression results (agricultural laborers) for LaTeX output
eststo est4: xtreg ln_total_expenditure NK KG NK_KG ln_resid_income inflation_r i.time if is_agri_labourer == 1, fe vce(cluster province)  

* Add fixed effects labels to the table
estadd local Time_FE "yes"  
estadd local Household_FE "yes"  

* Export regression results to LaTeX for agricultural laborers
esttab est4 using didreg4.tex, ///
   cells(b(fmt(3) star) se(fmt(3) par)) ///
   label nodepvars nomtitle nonumber ///
   noobs collabels("Dependent Variable: Log total expenditure" "") ///
   varlabels(NK "New Kingdom" KG "King's Gift"  NK_KG "New Kingdom*King's Gift" inflation_r "Rural Inflation" ln_resid_income "Residual Income") ///
   stats(r2 N) ///
   starlevels(* 0.10 * 0.05 ** 0.01) ///
   addnote("***p$<$0.01, ** p$<$0.05, * p$<$0.1") ///
   title("Regression Results showing effect of cash transfer policy to agricultural labourers of Vastrapur") ///
   replace  
