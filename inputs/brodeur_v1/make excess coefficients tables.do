*table a23 and a24

* read in the data
capture use "Data/MM Data.dta", clear  

* make cdf's, with no missing numbers	
foreach method in DID IV RCT RDD {	
	capture drop cdf_"`method'"
	sort t
	cumul t if method=="`method'", gen(cdf_`method')
	*replace cdf_`method' = 0 if t < 5
	}
	
*THIS SECTION CALIBRATES WHAT DF AND NP IS MOST APPROPRIATE FOR THE BELOW TABLE_EXCESS AND FIGURE_EXCESS



/* 
	
* cdf methods graph
* twoway (line cdf_* t, sort) if t < 10


* DID loop
capture drop np 
gen np = .

capture drop titles
gen titles = ""

	quietly forval df = 1(1)10 {

	capture drop fit_`df'
	gen fit_`df' = .

	count if t >= 5 & method=="DID"
	local above5 = r(N)

	count if t != . & method=="DID"
	local all = r(N)

	local empirical = `above5' / `all' // the percent of DID mass above 5


	local counter = 5
		forval np = 0 (0.01) 3.5 {
		capture drop sdf_t
		gen sdf_t = 1-((nt(`df',`np',t)-nt(`df',`np',0)))/(1-nt(`df',`np',0))
		sum sdf_t if t == 5
		replace np = `np' in `counter'
		replace fit_`df' = `empirical' - r(mean) in `counter'
		local counter = `counter' + 1
	}

	sum np if fit_`df'[_n]>0 & fit_`df'[_n+1]<0
	replace fit_`df' = r(mean) in 1
	replace fit_`df' = 1 if fit_`df'==. in 1
	replace titles = "Np best fit" in 1

	* now we just want to pick the cdf that is the closest to the empirical CDF
	capture drop cdf_t
	local np = fit_`df' in 1
	gen cdf_t = ((nt(`df',`np',t)-nt(`df',`np',0)))/(1-nt(`df',`np',0))
	
	capture drop cdf_t_`df'
	gen cdf_t_`df' = ((nt(`df',`np',t)-nt(`df',`np',0)))/(1-nt(`df',`np',0))	
	
	sum cdf_t if t >=5
	local cdf_t = r(mean)

	sum cdf_DID if t >= 5
	local cdf_DID = r(mean)

	replace fit_`df' = abs(`cdf_DID'-`cdf_t') in 2
	replace titles = "Diff in means t>5" in 2

	sum cdf_t if t >=0
	local cdf_t = r(mean)

	sum cdf_DID if t >= 0
	local cdf_DID = r(mean)

	replace fit_`df' = abs(`cdf_DID'-`cdf_t') in 3
	replace titles = "Diff in means t>0" in 3

}

twoway (line cdf_DID cdf_t_1 cdf_t_2 cdf_t_3  t, sort) if t < 10
twoway (line cdf_DID cdf_t_1 cdf_t_2 cdf_t_3  t, sort) if t > 5 & t < 10

export excel titles fit_* using "excess_fit" if _n <= 5, sheetmodify cell(A1) firstrow(variables) 
beep

* IV loop
capture drop np 
gen np = .

capture drop titles
gen titles = ""

	quietly forval df = 1(1)10 {

	capture drop fit_`df'
	gen fit_`df' = .

	count if t >= 5 & method=="IV"
	local above5 = r(N)

	count if t != . & method=="IV"
	local all = r(N)

	local empirical = `above5' / `all' // the percent of IV mass above 5


	local counter = 5
		forval np = 0 (0.01) 3.5 {
		capture drop sdf_t
		gen sdf_t = 1-((nt(`df',`np',t)-nt(`df',`np',0)))/(1-nt(`df',`np',0))
		sum sdf_t if t == 5
		replace np = `np' in `counter'
		replace fit_`df' = `empirical' - r(mean) in `counter'
		local counter = `counter' + 1
	}

	sum np if fit_`df'[_n]>0 & fit_`df'[_n+1]<0
	replace fit_`df' = r(mean) in 1
	replace fit_`df' = 1 if fit_`df'==. in 1
	replace titles = "Np best fit" in 1

	* now we just want to pick the cdf that is the closest to the empirical CDF
	capture drop cdf_t
	local np = fit_`df' in 1
	gen cdf_t = ((nt(`df',`np',t)-nt(`df',`np',0)))/(1-nt(`df',`np',0))
	
	capture drop cdf_t_`df'
	gen cdf_t_`df' = ((nt(`df',`np',t)-nt(`df',`np',0)))/(1-nt(`df',`np',0))	
	
	sum cdf_t if t >=5
	local cdf_t = r(mean)

	sum cdf_IV if t >= 5
	local cdf_IV = r(mean)

	replace fit_`df' = abs(`cdf_IV'-`cdf_t') in 2
	replace titles = "Diff in means t>5" in 2

	sum cdf_t if t >=0
	local cdf_t = r(mean)

	sum cdf_IV if t >= 0
	local cdf_IV = r(mean)

	replace fit_`df' = abs(`cdf_IV'-`cdf_t') in 3
	replace titles = "Diff in means t>0" in 3

}

twoway (line cdf_IV cdf_t_1 cdf_t_2 cdf_t_3  t, sort) if t < 10
twoway (line cdf_IV cdf_t_1 cdf_t_2 cdf_t_3  t, sort) if t > 5 & t < 10

export excel titles fit_* using "excess_fit" if _n <= 5, sheetmodify cell(A6) firstrow(variables) 
beep

* RCT loop
capture drop np 
gen np = .

capture drop titles
gen titles = ""

	quietly forval df = 1(1)10 {

	capture drop fit_`df'
	gen fit_`df' = .

	count if t >= 5 & method=="RCT"
	local above5 = r(N)

	count if t != . & method=="RCT"
	local all = r(N)

	local empirical = `above5' / `all' // the percent of RCT mass above 5


	local counter = 5
		forval np = 0 (0.01) 3.5 {
		capture drop sdf_t
		gen sdf_t = 1-((nt(`df',`np',t)-nt(`df',`np',0)))/(1-nt(`df',`np',0))
		sum sdf_t if t == 5
		replace np = `np' in `counter'
		replace fit_`df' = `empirical' - r(mean) in `counter'
		local counter = `counter' + 1
	}

	sum np if fit_`df'[_n]>0 & fit_`df'[_n+1]<0
	replace fit_`df' = r(mean) in 1
	replace fit_`df' = 1 if fit_`df'==. in 1
	replace titles = "Np best fit" in 1

	* now we just want to pick the cdf that is the closest to the empirical CDF
	capture drop cdf_t
	local np = fit_`df' in 1
	gen cdf_t = ((nt(`df',`np',t)-nt(`df',`np',0)))/(1-nt(`df',`np',0))
	
	capture drop cdf_t_`df'
	gen cdf_t_`df' = ((nt(`df',`np',t)-nt(`df',`np',0)))/(1-nt(`df',`np',0))	
	
	sum cdf_t if t >=5
	local cdf_t = r(mean)

	sum cdf_RCT if t >= 5
	local cdf_RCT = r(mean)

	replace fit_`df' = abs(`cdf_RCT'-`cdf_t') in 2
	replace titles = "Diff in means t>5" in 2

	sum cdf_t if t >=0
	local cdf_t = r(mean)

	sum cdf_RCT if t >= 0
	local cdf_RCT = r(mean)

	replace fit_`df' = abs(`cdf_RCT'-`cdf_t') in 3
	replace titles = "Diff in means t>0" in 3

}

twoway (line cdf_RCT cdf_t_1 cdf_t_2 cdf_t_3  t, sort) if t < 10
twoway (line cdf_RCT cdf_t_1 cdf_t_2 cdf_t_3  t, sort) if t > 5 & t < 10

export excel titles fit_* using "excess_fit" if _n <= 5, sheetmodify cell(A11) firstrow(variables) 
beep

* RDD loop
capture drop np 
gen np = .

capture drop titles
gen titles = ""

	quietly forval df = 1(1)10 {

	capture drop fit_`df'
	gen fit_`df' = .

	count if t >= 5 & method=="RDD"
	local above5 = r(N)

	count if t != . & method=="RDD"
	local all = r(N)

	local empirical = `above5' / `all' // the percent of RDD mass above 5


	local counter = 5
		forval np = 0 (0.01) 3.5 {
		capture drop sdf_t
		gen sdf_t = 1-((nt(`df',`np',t)-nt(`df',`np',0)))/(1-nt(`df',`np',0))
		sum sdf_t if t == 5
		replace np = `np' in `counter'
		replace fit_`df' = `empirical' - r(mean) in `counter'
		local counter = `counter' + 1
	}

	sum np if fit_`df'[_n]>0 & fit_`df'[_n+1]<0
	replace fit_`df' = r(mean) in 1
	replace fit_`df' = 1 if fit_`df'==. in 1
	replace titles = "Np best fit" in 1

	* now we just want to pick the cdf that is the closest to the empirical CDF
	capture drop cdf_t
	local np = fit_`df' in 1
	gen cdf_t = ((nt(`df',`np',t)-nt(`df',`np',0)))/(1-nt(`df',`np',0))
	
	capture drop cdf_t_`df'
	gen cdf_t_`df' = ((nt(`df',`np',t)-nt(`df',`np',0)))/(1-nt(`df',`np',0))	
	
	sum cdf_t if t >=5
	local cdf_t = r(mean)

	sum cdf_RDD if t >= 5
	local cdf_RDD = r(mean)

	replace fit_`df' = abs(`cdf_RDD'-`cdf_t') in 2
	replace titles = "Diff in means t>5" in 2

	sum cdf_t if t >=0
	local cdf_t = r(mean)

	sum cdf_RDD if t >= 0
	local cdf_RDD = r(mean)

	replace fit_`df' = abs(`cdf_RDD'-`cdf_t') in 3
	replace titles = "Diff in means t>0" in 3

}

twoway (line cdf_RDD cdf_t_1 cdf_t_2 cdf_t_3  t, sort) if t < 10
twoway (line cdf_RDD cdf_t_1 cdf_t_2 cdf_t_3  t, sort) if t > 5 & t < 10

export excel titles fit_* using "excess_fit" if _n <= 5, sheetmodify cell(A16) firstrow(variables) 
beep

*/

******************************************************************
*** table_excess
******************************************************************

* it takes in an upper and lower bound
* for the area underneath either an empirical pdf or the input pdf
* and then creates a table in excel
* from that excel, we clean it up and make a Latex manually

capture drop titles
gen titles = ""


local panel = 1

forval panel = 1(1)5 {

if "`panel'"=="1" {
	local lower = 0
	local upper = 1.65
}
if "`panel'"=="2" {
	local lower = 1.65
	local upper = 1.96
}
if "`panel'"=="3" {
	local lower = 1.96
	local upper = 2.58
}
if "`panel'"=="4" {
	local lower = 2.58
	local upper = 5
}
if "`panel'"=="5" {
	local lower = 5
	local upper = 1000
}


local methods DID IV RCT RDD
foreach method of local methods {

if "`method'"=="DID" {
	local df = 2
	local np = 1.81
}
if "`method'"=="IV" {
	local df = 2
	local np = 1.65
}
if "`method'"=="RCT" {
	local df = 2
	local np = 1.16
}
if "`method'"=="RDD" {
	local df = 2
	local np = 1.51
}


sort t
capture drop cdf_t

gen cdf_t = ((nt(`df',`np',t)-nt(`df',`np',0)))/(1-nt(`df',`np',0))
quietly sum cdf_t if t[_n]<`upper' & t[_n+1]>=`upper'
local cdf_t_3star = r(mean)



if "`lower'" == "0" {
quietly sum cdf_t if t[_n]==0 & t[_n+1]>`lower'
}
if "`lower'" > "0" {
quietly sum cdf_t if t[_n]<=`lower' & t[_n+1]>`lower'
}




local cdf_t_2star = r(mean)
local cdf_t_mass = `cdf_t_3star' - `cdf_t_2star'

sort cdf_`method'
quietly sum cdf_`method' if t[_n]<`upper' & t[_n+1]>=`upper'
local cdf_`method'_3star = r(mean)



if "`lower'" == "0" {
quietly sum cdf_`method' if t[_n]==0 & t[_n+1]>`lower'
}
if "`lower'" > "0" {
quietly sum cdf_`method' if t[_n]<`lower' & t[_n+1]>=`lower'
}



local cdf_`method'_2star = r(mean)
local cdf_`method'_mass = `cdf_`method'_3star' - `cdf_`method'_2star'

local difference = `cdf_`method'_mass' - `cdf_t_mass'

sort cdf_DID

capture drop excess_`method'
gen excess_`method' = .

local counter = 1

replace titles = "excess `lower' to `upper'" in `counter'
local counter = `counter' + 1

replace titles = "Observed" in `counter'
replace excess_`method' = `cdf_`method'_mass' in `counter'
local counter = `counter' + 1

replace titles = "Expected from t" in `counter'
replace excess_`method' = `cdf_t_mass' in `counter'
local counter = `counter' + 1

replace titles = "Difference" in `counter'
replace excess_`method' = `difference' in `counter'
local counter = `counter' + 1

replace titles = "Ratio of Excess to Expected " in `counter'
replace excess_`method' = `difference' / `cdf_t_mass' in `counter'
local counter = `counter' + 1

replace titles = "T distribution df" in `counter'
replace excess_`method' = `df' in `counter'
local counter = `counter' + 1

replace titles = "T distribution np" in `counter'
replace excess_`method' = `np' in `counter'
local counter = `counter' + 1


}


if "`panel'"=="1" {
export excel titles excess* using "table_excess.xls" if _n <= `counter', sheetmodify cell(A1) firstrow(variables) 

}
if "`panel'"=="2" {
export excel titles excess* using "table_excess.xls" if _n <= `counter', sheetmodify cell(A11) firstrow(variables) 

}
if "`panel'"=="3" {
export excel titles excess* using "table_excess.xls" if _n <= `counter', sheetmodify cell(A21) firstrow(variables) 

}
if "`panel'"=="4" {
export excel titles excess* using "table_excess.xls" if _n <= `counter', sheetmodify cell(A31) firstrow(variables) 

}
if "`panel'"=="5" {
export excel titles excess* using "table_excess.xls" if _n <= `counter', sheetmodify cell(A41) firstrow(variables) 

}


}

* now take the excel, and clean it manually, turn it into a23 and a24

