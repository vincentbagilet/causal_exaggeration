

*************************************************************************************************
*** Table 3, A6, A7

* read in the data
capture use "Data/MM Data.dta", clear 


local thresholds 1.65 1.96 2.58
foreach threshold of local thresholds {
di `threshold'

local counter = 1

forval panel = 1(1)7 {

if "`panel'"=="1" {
	local delta = 0.5

}
if "`panel'"=="2" {
	local delta = 0.4

}
if "`panel'"=="3" {
	local delta = 0.3
}
if "`panel'"=="4" {
	local delta = 0.2
}
if "`panel'"=="5" {
	local delta = 0.1
}
if "`panel'"=="6" {
	local delta = 0.075
}
if "`panel'"=="7" {
	local delta = 0.05
}

di `threshold'
di `delta'

capture drop binomial
gen binomial = .
replace binomial = 0 if t < `threshold'
replace binomial = 1 if t >= `threshold'

local delta2 = `delta'*1000
local threshold2 = `threshold'*1000


levelsof method, local(methods) 
foreach method of local methods{
bitest binomial == 0.5 if t < `threshold' + `delta' & t > `threshold' - `delta' & method == "`method'"

capture gen proportion_`threshold2'_`delta2' = .
label var proportion_`threshold2'_`delta2' "\hline Proportion Significant in `threshold'$\pm$0`delta'"
replace proportion_`threshold2'_`delta2' = `r(k)'/`r(N)' if method == "`method'"

capture gen pvalue_`threshold2'_`delta2' = .
replace pvalue_`threshold2'_`delta2' = `r(p_u)' if method =="`method'"
label var pvalue_`threshold2'_`delta2' "One Sided p-value"

capture gen obs_`threshold2'_`delta2' = .
replace obs_`threshold2'_`delta2' = `r(N)' if method =="`method'"
label var obs_`threshold2'_`delta2' "Number of Tests in `threshold'$\pm$0`delta'"

}
}

eststo clear

eststo DID : quietly estpost summarize ///
	proportion_`threshold2'_500 pvalue_`threshold2'_500 obs_`threshold2'_500 ///
	proportion_`threshold2'_400 pvalue_`threshold2'_400 obs_`threshold2'_400 ///
	proportion_`threshold2'_300 pvalue_`threshold2'_300 obs_`threshold2'_300 ///
	proportion_`threshold2'_200 pvalue_`threshold2'_200 obs_`threshold2'_200 ///
	proportion_`threshold2'_100 pvalue_`threshold2'_100 obs_`threshold2'_100 ///
	proportion_`threshold2'_75 pvalue_`threshold2'_75 obs_`threshold2'_75 ///
	proportion_`threshold2'_50 pvalue_`threshold2'_50 obs_`threshold2'_50 ///
	if method == "DID"  
eststo IV : quietly estpost summarize ///
  	proportion_`threshold2'_500 pvalue_`threshold2'_500 obs_`threshold2'_500 ///
	proportion_`threshold2'_400 pvalue_`threshold2'_400 obs_`threshold2'_400 ///
	proportion_`threshold2'_300 pvalue_`threshold2'_300 obs_`threshold2'_300 ///
	proportion_`threshold2'_200 pvalue_`threshold2'_200 obs_`threshold2'_200 ///
	proportion_`threshold2'_100 pvalue_`threshold2'_100 obs_`threshold2'_100 ///
	proportion_`threshold2'_75 pvalue_`threshold2'_75 obs_`threshold2'_75 ///
	proportion_`threshold2'_50 pvalue_`threshold2'_50 obs_`threshold2'_50 ///
	if method == "IV"  
eststo RCT : quietly estpost summarize ///
  	proportion_`threshold2'_500 pvalue_`threshold2'_500 obs_`threshold2'_500 ///
	proportion_`threshold2'_400 pvalue_`threshold2'_400 obs_`threshold2'_400 ///
	proportion_`threshold2'_300 pvalue_`threshold2'_300 obs_`threshold2'_300 ///
	proportion_`threshold2'_200 pvalue_`threshold2'_200 obs_`threshold2'_200 ///
	proportion_`threshold2'_100 pvalue_`threshold2'_100 obs_`threshold2'_100 ///
	proportion_`threshold2'_75 pvalue_`threshold2'_75 obs_`threshold2'_75 ///
	proportion_`threshold2'_50 pvalue_`threshold2'_50 obs_`threshold2'_50 ///
	if method == "RCT"  
eststo RDD : quietly estpost summarize ///
  	proportion_`threshold2'_500 pvalue_`threshold2'_500 obs_`threshold2'_500 ///
	proportion_`threshold2'_400 pvalue_`threshold2'_400 obs_`threshold2'_400 ///
	proportion_`threshold2'_300 pvalue_`threshold2'_300 obs_`threshold2'_300 ///
	proportion_`threshold2'_200 pvalue_`threshold2'_200 obs_`threshold2'_200 ///
	proportion_`threshold2'_100 pvalue_`threshold2'_100 obs_`threshold2'_100 ///
	proportion_`threshold2'_75 pvalue_`threshold2'_75 obs_`threshold2'_75 ///
	proportion_`threshold2'_50 pvalue_`threshold2'_50 obs_`threshold2'_50 ///
	if method == "RDD"  
	
esttab , ///
	 main(mean %6.3f) mtitles  nogaps compress noobs nonotes  label

esttab using table_above_below_`threshold2'_compared_to_half, tex replace ///
	 main(mean %6.3f) mtitles  nogaps compress noobs nonotes  label

}


*************************************************************************************************
*** Table A3, A4, A5

* read in the data
capture use "Data/MM Data.dta", clear 

local thresholds 1.65 1.96 2.58
foreach threshold of local thresholds {
di `threshold'

local counter = 1

forval panel = 1(1)7 {

if "`panel'"=="1" {
	local delta = 0.5

}
if "`panel'"=="2" {
	local delta = 0.4

}
if "`panel'"=="3" {
	local delta = 0.3
}
if "`panel'"=="4" {
	local delta = 0.2
}
if "`panel'"=="5" {
	local delta = 0.1
}
if "`panel'"=="6" {
	local delta = 0.075
}
if "`panel'"=="7" {
	local delta = 0.05
}

di `threshold'
di `delta'

capture drop binomial
gen binomial = .
replace binomial = 0 if t < `threshold'
replace binomial = 1 if t >= `threshold'

local delta2 = `delta'*1000
local threshold2 = `threshold'*1000

capture drop imethod
encode method, gen(imethod)  
    
proportion binomial if t < `threshold' + `delta' & t > `threshold' - `delta', over(imethod) coeflegend vce(cluster title)

levelsof imethod, local(imethods) 
foreach imethod of local imethods{
    
capture gen proportion_`threshold2'_`delta2' = .
label var proportion_`threshold2'_`delta2' "\hline Proportion Significant in `threshold'$\pm$0`delta'"
nlcom _b[1.binomial@`imethod'bn.imethod]
local b = r(b)[1,1]
replace proportion_`threshold2'_`delta2' = `b' if imethod == `imethod'

capture gen sd_`threshold2'_`delta2' = .
label var sd_`threshold2'_`delta2' "Standard Deviation"
nlcom _b[1.binomial@`imethod'bn.imethod]
local V = r(V)[1,1]
replace sd_`threshold2'_`delta2' = `V' if imethod == `imethod'

capture gen pv_equal_`threshold2'_`delta2' = .
label var pv_equal_`threshold2'_`delta2' "p-value of equal probability"
nlcom _b[1.binomial@`imethod'bn.imethod]-0.5
local b = r(b)[1,1]
local V = r(V)[1,1]
replace pv_equal_`threshold2'_`delta2' = 2*(1-normal(abs( `b'/`V'))) if imethod == `imethod'

capture gen pv_rct_`threshold2'_`delta2' = .
label var pv_rct_`threshold2'_`delta2' "p-value of equal to RCT"
nlcom _b[1.binomial@`imethod'bn.imethod]-_b[1.binomial@3.imethod]
local b = r(b)[1,1]
local V = r(V)[1,1]
replace pv_rct_`threshold2'_`delta2' = 2*(1-normal(abs( `b'/`V'))) if imethod == `imethod'

capture gen obs_`threshold2'_`delta2' = .
label var obs_`threshold2'_`delta2' "Number of statistics in window"
sum binomial if t < `threshold' + `delta' & t > `threshold' - `delta' & imethod == `imethod'
local n = r(N)
replace obs_`threshold2'_`delta2' = `n' if imethod == `imethod'

capture gen min_ci_`threshold2'_`delta2' = .
capture gen max_ci_`threshold2'_`delta2' = .
nlcom _b[1.binomial@`imethod'bn.imethod]-0.5
local b = r(b)[1,1]
local V = r(V)[1,1]
replace min_ci_`threshold2'_`delta2' = `b'-1.96*`V' if imethod == `imethod'
replace max_ci_`threshold2'_`delta2' = `b'+1.96*`V' if imethod == `imethod'

}
}

eststo clear

eststo DID : quietly estpost summarize ///
	proportion_`threshold2'_500 sd_`threshold2'_500  pv_equal_`threshold2'_500 pv_rct_`threshold2'_500 obs_`threshold2'_500 ///
	proportion_`threshold2'_400 sd_`threshold2'_400  pv_equal_`threshold2'_400 pv_rct_`threshold2'_400 obs_`threshold2'_400 ///
	proportion_`threshold2'_300 sd_`threshold2'_300  pv_equal_`threshold2'_300 pv_rct_`threshold2'_300 obs_`threshold2'_300 ///
	proportion_`threshold2'_200 sd_`threshold2'_200  pv_equal_`threshold2'_200 pv_rct_`threshold2'_200 obs_`threshold2'_200 ///
	proportion_`threshold2'_100 sd_`threshold2'_100  pv_equal_`threshold2'_100 pv_rct_`threshold2'_100 obs_`threshold2'_100 ///
	proportion_`threshold2'_75 sd_`threshold2'_75  pv_equal_`threshold2'_75 pv_rct_`threshold2'_75 obs_`threshold2'_75 ///
	proportion_`threshold2'_50 sd_`threshold2'_50  pv_equal_`threshold2'_50 pv_rct_`threshold2'_50 obs_`threshold2'_50 ///
	if method == "DID"  
eststo IV : quietly estpost summarize ///
	proportion_`threshold2'_500 sd_`threshold2'_500  pv_equal_`threshold2'_500 pv_rct_`threshold2'_500 obs_`threshold2'_500 ///
	proportion_`threshold2'_400 sd_`threshold2'_400  pv_equal_`threshold2'_400 pv_rct_`threshold2'_400 obs_`threshold2'_400 ///
	proportion_`threshold2'_300 sd_`threshold2'_300  pv_equal_`threshold2'_300 pv_rct_`threshold2'_300 obs_`threshold2'_300 ///
	proportion_`threshold2'_200 sd_`threshold2'_200  pv_equal_`threshold2'_200 pv_rct_`threshold2'_200 obs_`threshold2'_200 ///
	proportion_`threshold2'_100 sd_`threshold2'_100  pv_equal_`threshold2'_100 pv_rct_`threshold2'_100 obs_`threshold2'_100 ///
	proportion_`threshold2'_75 sd_`threshold2'_75  pv_equal_`threshold2'_75 pv_rct_`threshold2'_75 obs_`threshold2'_75 ///
	proportion_`threshold2'_50 sd_`threshold2'_50  pv_equal_`threshold2'_50 pv_rct_`threshold2'_50 obs_`threshold2'_50 ///
	if method == "IV"  
eststo RCT : quietly estpost summarize ///
	proportion_`threshold2'_500 sd_`threshold2'_500  pv_equal_`threshold2'_500 pv_rct_`threshold2'_500 obs_`threshold2'_500 ///
	proportion_`threshold2'_400 sd_`threshold2'_400  pv_equal_`threshold2'_400 pv_rct_`threshold2'_400 obs_`threshold2'_400 ///
	proportion_`threshold2'_300 sd_`threshold2'_300  pv_equal_`threshold2'_300 pv_rct_`threshold2'_300 obs_`threshold2'_300 ///
	proportion_`threshold2'_200 sd_`threshold2'_200  pv_equal_`threshold2'_200 pv_rct_`threshold2'_200 obs_`threshold2'_200 ///
	proportion_`threshold2'_100 sd_`threshold2'_100  pv_equal_`threshold2'_100 pv_rct_`threshold2'_100 obs_`threshold2'_100 ///
	proportion_`threshold2'_75 sd_`threshold2'_75  pv_equal_`threshold2'_75 pv_rct_`threshold2'_75 obs_`threshold2'_75 ///
	proportion_`threshold2'_50 sd_`threshold2'_50  pv_equal_`threshold2'_50 pv_rct_`threshold2'_50 obs_`threshold2'_50 ///
	if method == "RCT"  
eststo RDD : quietly estpost summarize ///
	proportion_`threshold2'_500 sd_`threshold2'_500  pv_equal_`threshold2'_500 pv_rct_`threshold2'_500 obs_`threshold2'_500 ///
	proportion_`threshold2'_400 sd_`threshold2'_400  pv_equal_`threshold2'_400 pv_rct_`threshold2'_400 obs_`threshold2'_400 ///
	proportion_`threshold2'_300 sd_`threshold2'_300  pv_equal_`threshold2'_300 pv_rct_`threshold2'_300 obs_`threshold2'_300 ///
	proportion_`threshold2'_200 sd_`threshold2'_200  pv_equal_`threshold2'_200 pv_rct_`threshold2'_200 obs_`threshold2'_200 ///
	proportion_`threshold2'_100 sd_`threshold2'_100  pv_equal_`threshold2'_100 pv_rct_`threshold2'_100 obs_`threshold2'_100 ///
	proportion_`threshold2'_75 sd_`threshold2'_75  pv_equal_`threshold2'_75 pv_rct_`threshold2'_75 obs_`threshold2'_75 ///
	proportion_`threshold2'_50 sd_`threshold2'_50  pv_equal_`threshold2'_50 pv_rct_`threshold2'_50 obs_`threshold2'_50 ///
	if method == "RDD"  
	
esttab , ///
	 main(mean %9.4f) mtitles  nogaps compress noobs nonotes  label

esttab using table_above_prop_`threshold2', tex replace ///
	 main(mean %9.4f) mtitles  nogaps compress noobs nonotes  label

}

*************************************************************************************************
*** A8 A9 A10

clear
set more off

* read in the data
capture use "Data/MM Data.dta", clear 

local thresholds 1.65 1.96 2.58
foreach threshold of local thresholds {
di `threshold'

local counter = 1

forval panel = 1(1)7 {

if "`panel'"=="1" {
	local delta = 0.5

}
if "`panel'"=="2" {
	local delta = 0.4

}
if "`panel'"=="3" {
	local delta = 0.3
}
if "`panel'"=="4" {
	local delta = 0.2
}
if "`panel'"=="5" {
	local delta = 0.1
}
if "`panel'"=="6" {
	local delta = 0.075
}
if "`panel'"=="7" {
	local delta = 0.05
}

di `threshold'
di `delta'

capture drop binomial
gen binomial = .
replace binomial = 0 if t < `threshold'
replace binomial = 1 if t >= `threshold'

local delta2 = `delta'*1000
local threshold2 = `threshold'*1000

capture bysort title : egen aw = count(binomial)


levelsof method, local(methods) 
foreach method of local methods{
bitest binomial == 0.5 if t < `threshold' + `delta' & t > `threshold' - `delta' & method == "`method'" [fw=aw]

capture gen proportion_`threshold2'_`delta2' = .
label var proportion_`threshold2'_`delta2' "\hline Proportion Significant in `threshold'$\pm$0`delta'"
replace proportion_`threshold2'_`delta2' = `r(k)'/`r(N)' if method == "`method'"

capture gen pvalue_`threshold2'_`delta2' = .
replace pvalue_`threshold2'_`delta2' = `r(p_u)' if method =="`method'"
label var pvalue_`threshold2'_`delta2' "One Sided p-value"

capture gen obs_`threshold2'_`delta2' = .
replace obs_`threshold2'_`delta2' = `r(N)' if method =="`method'"
label var obs_`threshold2'_`delta2' "Number of Tests in `threshold'$\pm$0`delta'"

}
}

eststo clear

eststo DID : quietly estpost summarize ///
	proportion_`threshold2'_500 pvalue_`threshold2'_500 obs_`threshold2'_500 ///
	proportion_`threshold2'_400 pvalue_`threshold2'_400 obs_`threshold2'_400 ///
	proportion_`threshold2'_300 pvalue_`threshold2'_300 obs_`threshold2'_300 ///
	proportion_`threshold2'_200 pvalue_`threshold2'_200 obs_`threshold2'_200 ///
	proportion_`threshold2'_100 pvalue_`threshold2'_100 obs_`threshold2'_100 ///
	proportion_`threshold2'_75 pvalue_`threshold2'_75 obs_`threshold2'_75 ///
	proportion_`threshold2'_50 pvalue_`threshold2'_50 obs_`threshold2'_50 ///
	if method == "DID"  
eststo IV : quietly estpost summarize ///
  	proportion_`threshold2'_500 pvalue_`threshold2'_500 obs_`threshold2'_500 ///
	proportion_`threshold2'_400 pvalue_`threshold2'_400 obs_`threshold2'_400 ///
	proportion_`threshold2'_300 pvalue_`threshold2'_300 obs_`threshold2'_300 ///
	proportion_`threshold2'_200 pvalue_`threshold2'_200 obs_`threshold2'_200 ///
	proportion_`threshold2'_100 pvalue_`threshold2'_100 obs_`threshold2'_100 ///
	proportion_`threshold2'_75 pvalue_`threshold2'_75 obs_`threshold2'_75 ///
	proportion_`threshold2'_50 pvalue_`threshold2'_50 obs_`threshold2'_50 ///
	if method == "IV"  
eststo RCT : quietly estpost summarize ///
  	proportion_`threshold2'_500 pvalue_`threshold2'_500 obs_`threshold2'_500 ///
	proportion_`threshold2'_400 pvalue_`threshold2'_400 obs_`threshold2'_400 ///
	proportion_`threshold2'_300 pvalue_`threshold2'_300 obs_`threshold2'_300 ///
	proportion_`threshold2'_200 pvalue_`threshold2'_200 obs_`threshold2'_200 ///
	proportion_`threshold2'_100 pvalue_`threshold2'_100 obs_`threshold2'_100 ///
	proportion_`threshold2'_75 pvalue_`threshold2'_75 obs_`threshold2'_75 ///
	proportion_`threshold2'_50 pvalue_`threshold2'_50 obs_`threshold2'_50 ///
	if method == "RCT"  
eststo RDD : quietly estpost summarize ///
  	proportion_`threshold2'_500 pvalue_`threshold2'_500 obs_`threshold2'_500 ///
	proportion_`threshold2'_400 pvalue_`threshold2'_400 obs_`threshold2'_400 ///
	proportion_`threshold2'_300 pvalue_`threshold2'_300 obs_`threshold2'_300 ///
	proportion_`threshold2'_200 pvalue_`threshold2'_200 obs_`threshold2'_200 ///
	proportion_`threshold2'_100 pvalue_`threshold2'_100 obs_`threshold2'_100 ///
	proportion_`threshold2'_75 pvalue_`threshold2'_75 obs_`threshold2'_75 ///
	proportion_`threshold2'_50 pvalue_`threshold2'_50 obs_`threshold2'_50 ///
	if method == "RDD"  
	
esttab , ///
	 main(mean %8.3f) mtitles  nogaps compress noobs nonotes  label

esttab using table_above_below_`threshold2'_compared_to_half_aw, tex replace ///
	 main(mean %8.3f) mtitles  nogaps compress noobs nonotes  label

}

*************************************************************************************************
*** a11

clear
set more off

* read in the data
capture use "Data/MM Data.dta", clear 

bitesti 192 53 0.5 // for Gerber Malhotra 2008a

capture drop binomial
gen binomial = .
replace binomial = 0 if t < 1.96
replace binomial = 1 if t >= 1.96

bitest binomial == 0.5 if t <1.96 + 0.20 & t > 1.96 - 0.20 
bitest binomial == 0.5 if t <1.96 + 0.20 & t > 1.96 - 0.20 & method == "DID"
bitest binomial == 0.5 if t <1.96 + 0.20 & t > 1.96 - 0.20 & method == "IV"
bitest binomial == 0.5 if t <1.96 + 0.20 & t > 1.96 - 0.20 & method == "RCT"
bitest binomial == 0.5 if t <1.96 + 0.20 & t > 1.96 - 0.20 & method == "RDD"

* journals
rename journal journal_name
gen journal=.
replace journal=1 if journal_name=="The Quarterly Journal of Economics"
replace journal=3 if journal_name=="Journal of Political Economy"
replace journal=4 if journal_name=="Econometrica"
replace journal=5 if journal_name=="Journal of Finance" // old one, has no effect
replace journal=5 if journal_name=="The Journal of Finance" 
replace journal=6 if journal_name=="Review of Economic Studies" // old one, has no effect
replace journal=6 if journal_name=="The Review of Economic Studies" 
replace journal=7 if journal_name=="AEJ: Macroeconomics" // old
replace journal=7 if journal_name=="American Economic Journal: Macroeconomics"
replace journal=8 if journal_name=="Journal of Economic Growth"
replace journal=9 if journal_name=="The Review of Economics and Statistics"
replace journal=11 if journal_name=="American Economic Review"
replace journal=12 if journal_name=="Economic Policy"
replace journal=15 if journal_name=="AEJ: Applied" // OLD
replace journal=15 if journal_name=="American Economic Journal: Applied Economics"
replace journal=16 if journal_name=="Journal of the European Economic Association"
replace journal=17 if journal_name=="Review of Financial Studies"
replace journal=18 if journal_name=="Journal of International Economics"
replace journal=19 if journal_name=="Economic Journal" // OLD
replace journal=19 if journal_name=="The Economic Journal"
replace journal=20 if journal_name=="Review of Financial Economics" // OLD
replace journal=20 if journal_name=="Journal of Financial Economics"
replace journal=21 if journal_name=="Experimental Economics"
replace journal=22 if journal_name=="Journal of Development Economics"
replace journal=23 if journal_name=="Journal of Labor Economics"
replace journal=24 if journal_name=="Journal of Financial Intermediation"
replace journal=25 if journal_name=="Journal of Applied Econometrics"
replace journal=26 if journal_name=="Journal of Human Resources"
replace journal=27 if journal_name=="AEJ: Economic Policy" // OLD
replace journal=27 if journal_name=="American Economic Journal: Economic Policy"
replace journal=31 if journal_name=="Journal of Urban Economics"
replace journal=32 if journal_name=="Journal of Public Economics"

gen top5=0 if journal!=.
replace top5=1 if journal==1
replace top5=1 if journal==3
replace top5=1 if journal==4
replace top5=1 if journal==6
replace top5=1 if journal==11

bitest binomial == 0.5 if t <1.96 + 0.20 & t > 1.96 - 0.20 & top5 == 1
bitest binomial == 0.5 if t <1.96 + 0.20 & t > 1.96 - 0.20 & top5 == 0

*************************************************************************************************
*** Table a25


clear
set more off

* read in the data
use "Data/Fstat.dta", clear

gen titles1 = ""
gen titles2 = ""
gen b_DID = .
gen b_IV = .
gen b_RCT = .
gen b_RDD = .


local thresholds 10
foreach threshold of local thresholds {
di `threshold'

local counter = 1

forval panel = 1(1)7 {

if "`panel'"=="1" {
	local delta = 25

}
if "`panel'"=="2" {
	local delta = 20

}
if "`panel'"=="3" {
	local delta = 15
}
if "`panel'"=="4" {
	local delta = 10
}
if "`panel'"=="5" {
	local delta = 5
}
if "`panel'"=="6" {
	local delta = 2.5
}
if "`panel'"=="7" {
	local delta = 1
}



local i = `counter' 
local j = `counter' + 1
local k = `counter' + 2

capture drop binomial
gen binomial = .
replace binomial = 0 if fstat < `threshold'
replace binomial = 1 if fstat > `threshold'

replace titles1 = "`threshold'+-0`delta'" in `i'
replace titles2 = "proportion" in `i'
replace titles2 = "p-value" in `j'
replace titles2 = "Observations" in `k'

local h0 =  0.5
bitest binomial == `h0' if fstat < `threshold' + `delta' & fstat > `threshold' - `delta' 
replace b_IV = round(`r(k)'/`r(N)',0.01) in `i'
replace b_IV = round(`r(p_u)',0.001) in `j'
replace b_IV = `r(N)' in `k'

bitest binomial == `h0' if fstat < `threshold' + `delta' & fstat > `threshold' - `delta'   
replace b_DID = round(`r(k)'/`r(N)',0.01) in `i'
replace b_DID = round(`r(p_u)',0.001) in `j'
replace b_DID = `r(N)' in `k'



local counter = `counter' + 4
}

list titles1 titles2  b_IV b_DID b_RCT b_RDD if titles2!="", sep(3)
*** Also find this in the data viewer for cut and paste
}
preserve

keep titles1 titles2 b_DID b_IV  b_RCT b_RDD
keep if titles2!=""

dataout, save("table_above_below_F") tex replace 

restore
