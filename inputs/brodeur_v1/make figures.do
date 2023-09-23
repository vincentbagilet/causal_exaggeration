clear
set more off

* read in the data
capture use "Data/MM Data.dta", clear 

*** figure 1a
histogram t if t <= 10 , title() width(0.1) start(0) fcolor(gs10) lcolor(gs10) kdensity kdenopts(width(0.1)) xtitle(z-statistic) xline(1.65 1.96 2.58, lwidth(thin)) xlabel(0 1 1.65 "*" 1.96 "**" 2.58 "***" 3 4 5 6 7 8 9 10) legend(off) scheme(s1mono)

graph export figure1a.png, replace width(1000)

*** figure 1b
gen top5 = 0 
replace top5 = 1 if strpos(journal,"Quarterly Journal of Economics")
replace top5 = 1 if strpos(journal,"Journal of Political Economy")
replace top5 = 1 if strpos(journal,"Econometrica")
replace top5 = 1 if strpos(journal,"American Economic Review")
replace top5 = 1 if strpos(journal,"Review of Economic Studies")

histogram t if t <= 10 & top5==1 , title("Top 5") saving(temp1, replace) width(0.1) start(0) fcolor(gs10) lcolor(gs10) kdensity kdenopts(width(0.1)) xtitle(z-statistic) xline(1.65 1.96 2.58, lwidth(thin)) xlabel(0(1)10) legend(off) scheme(s1mono)
histogram t if t <= 10 & top5==0 , title("Non-Top 5") saving(temp2, replace) width(0.1) start(0) fcolor(gs10) lcolor(gs10) kdensity kdenopts(width(0.1)) xtitle(z-statistic) xline(1.65 1.96 2.58, lwidth(thin)) xlabel(0(1)10) legend(off) scheme(s1mono)

graph combine temp1.gph temp2.gph , ycommon scheme(s1mono) xcommon  xsize(4) ysize(1.5)
graph export figure1b.png, replace width(1000)

*** figure 2

histogram t if t <= 10 & method=="DID"  , title("DID") saving(temp1, replace) width(0.1) start(0) fcolor(gs10) lcolor(gs10) kdensity kdenopts(width(0.1)) xtitle(z-statistic) xline(1.65 1.96 2.58, lwidth(thin)) xlabel(0(1)10) legend(off) scheme(s1mono)
histogram t if t <= 10 & method=="IV" , title("IV") saving(temp2, replace) width(0.1) start(0) fcolor(gs10) lcolor(gs10) kdensity kdenopts(width(0.1)) xtitle(z-statistic) xline(1.65 1.96 2.58, lwidth(thin)) xlabel(0(1)10) legend(off) scheme(s1mono)
histogram t if t <= 10 & method=="RCT" , title("RCT") saving(temp3, replace) width(0.1) start(0) fcolor(gs10) lcolor(gs10) kdensity kdenopts(width(0.1)) xtitle(z-statistic) xline(1.65 1.96 2.58, lwidth(thin)) xlabel(0(1)10) legend(off) scheme(s1mono)
histogram t if t <= 10 & method=="RDD", title("RDD") saving(temp4, replace) width(0.1) start(0) fcolor(gs10) lcolor(gs10) kdensity kdenopts(width(0.1)) xtitle(z-statistic) xline(1.65 1.96 2.58, lwidth(thin)) xlabel(0(1)10) legend(off) scheme(s1mono)

graph combine temp1.gph temp2.gph temp3.gph temp4.gph, ycommon scheme(s1mono) xcommon xsize(4) ysize(3)
graph export figure2.png, replace width(1000)

*** figure 3a
preserve

use "Data/Star Wars Data.dta", clear

append using "Data/MM Data.dta", force

capture drop top3

gen top3 = 0
replace top3 = 1 if strpos(journal,"Quarterly Journal of Economics")
replace top3 = 1 if strpos(journal,"Journal of Political Economy")
replace top3 = 1 if strpos(journal,"American Economic Review")

histogram t if t <= 10 & year<2015 & top3==1 , title("2005-2011") saving(temp1, replace) width(0.1) start(0) fcolor(gs10) lcolor(gs10) kdensity kdenopts(width(0.1)) xtitle(z-statistic) xline(1.65 1.96 2.58, lwidth(thin)) xlabel(0(1)10) legend(off) scheme(s1mono)
histogram t if t <= 10 & year>=2015 & top3==1 , title("2015 & 2018") saving(temp2, replace) width(0.1) start(0) fcolor(gs10) lcolor(gs10) kdensity kdenopts(width(0.1)) xtitle(z-statistic) xline(1.65 1.96 2.58, lwidth(thin)) xlabel(0(1)10) legend(off) scheme(s1mono)

graph combine temp1.gph temp2.gph, ycommon scheme(s1mono) xcommon xsize(4) ysize(1.5)
graph export figure3a.png, replace width(1000)

restore

*** figure 3b

histogram t if t <= 10 & year==2015 , title("2015") saving(temp1, replace) width(0.1) start(0) fcolor(gs10) lcolor(gs10) kdensity kdenopts(width(0.1)) xtitle(z-statistic) xline(1.65 1.96 2.58, lwidth(thin)) xlabel(0(1)10) legend(off) scheme(s1mono)
histogram t if t <= 10 & year==2018 , title("2018") saving(temp2, replace) width(0.1) start(0) fcolor(gs10) lcolor(gs10) kdensity kdenopts(width(0.1)) xtitle(z-statistic) xline(1.65 1.96 2.58, lwidth(thin)) xlabel(0(1)10) legend(off) scheme(s1mono)

graph combine temp1.gph temp2.gph , ycommon scheme(s1mono) xcommon  xsize(4) ysize(1.5)
graph export figure3b.png, replace width(1000)

*** figure 4

capture drop x
gen x = _n / 100
replace x = . if _n > 1000

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

capture drop pdf_t
gen pdf_t = ntden(`df',`np',x)
label var pdf_t "t~(`df',`np')"

twoway 	(line pdf_t x, lpattern(dash) sort) ///
	(kdensity t if method=="`method'" & t < 10, lcolor(black)) ///
	, scheme(s1mono) xlabel(0 1.65 "*" 1.96 "**" 2.58 "***" 5 10) xtitle("z-statistic") xline(1.65 1.96 2.58, lwidth(vvthin)) saving(`method',replace) legend(pos(2) ring(0) col(1) lab(1 "t~(`df',`np')") lab(2 "`method'"))

}

graph combine DID.gph IV.gph RCT.gph RDD.gph, ycommon scheme(s1mono)
graph export figure4.png, replace width(2000)

capture erase DID.gph 
capture erase IV.gph 
capture erase RCT.gph 
capture erase RDD.gph 

*** figure 5a

capture destring fstat, replace force

histogram fstat if fstat <= 50 , title() width(2) start(0) fcolor(gs10) lcolor(gs10) kdensity kdenopts() xtitle(F-Statistic) xline(10, lwidth(thin)) xlabel(0 10 20 30 40 50) legend(off) scheme(s1mono)
graph export figure5a.png, replace width(1000)

*** figure 5b

capture destring fstat, replace force

histogram t if t <= 10 & method=="IV" & fstat< 30 , title("F less than 30") saving(temp1, replace) width(0.1) start(0) fcolor(gs10) lcolor(gs10) kdensity kdenopts(width(0.1)) xtitle(z-statistic) xline(1.65 1.96 2.58, lwidth(thin)) xlabel(0 1 1.65 "*" 1.96 "**" 2.58 "***" 3 4 5 6 7 8 9 10) legend(off) scheme(s1mono)

histogram t if t <= 10 & method=="IV" & fstat>= 30 , title("F greater than or equal to 30") saving(temp2, replace) width(0.1) start(0) fcolor(gs10) lcolor(gs10) kdensity kdenopts(width(0.1)) xtitle(z-statistic) xline(1.65 1.96 2.58, lwidth(thin)) xlabel(0 1 1.65 "*" 1.96 "**" 2.58 "***" 3 4 5 6 7 8 9 10) legend(off) scheme(s1mono)

graph combine temp1.gph temp2.gph , ycommon scheme(s1mono) xcommon xsize(2) ysize(1) caption()
graph export figure5b.png, replace  width(1000)

*** figure 6

preserve

use "Data/MM Data with WP.dta", clear

histogram WP_t if WP_t <= 10 & WP==0 & has_WP==1 , title("Published") saving(temp1, replace) width(0.1) start(0) fcolor(gs10) lcolor(gs10) kdensity kdenopts(width(0.1)) xtitle(z-statistic) xline(1.65 1.96 2.58, lwidth(thin)) xlabel(0 1 1.65 "*" 1.96 "**" 2.58 "***" 3 4 5 6 7 8 9 10) legend(off) scheme(s1mono)
histogram WP_t if WP_t <= 10 & WP==1 & has_WP==1 , title("Working Paper") saving(temp2, replace) width(0.1) start(0) fcolor(gs10) lcolor(gs10) kdensity kdenopts(width(0.1)) xtitle(z-statistic) xline(1.65 1.96 2.58, lwidth(thin)) xlabel(0 1 1.65 "*" 1.96 "**" 2.58 "***" 3 4 5 6 7 8 9 10) legend(off) scheme(s1mono)

restore

graph combine temp1.gph temp2.gph , ycommon scheme(s1mono) xcommon  xsize(4) ysize(1.5)
graph export figure6.png, replace width(1000)

***************************************************************************************************

*** figure a1

preserve

use "Data/Star Wars Data.dta", clear

append using "Data/MM Data.dta", force

capture drop top3

gen top3 = 0
replace top3 = 1 if strpos(journal,"Quarterly Journal of Economics")
replace top3 = 1 if strpos(journal,"Journal of Political Economy")
replace top3 = 1 if strpos(journal,"American Economic Review")

keep if top3==1

replace article=article_page if article==.

duplicates drop journal article year method, force

	capture drop titles
	gen titles = .
levelsof method, local(methods) 
foreach method of local methods {
	capture drop p`method'
	gen p`method' = .
		local counter = 1

levelsof year, local(years) 
foreach year of local years {
count if year == `year'
local all = r(N)
count if year== `year' & method=="`method'"
*count if year == `year' & method == "`method'"
local num_method = r(N)
di `num_method' / `all'
replace titles = `year' in `counter'
replace p`method' = `num_method' / `all' in `counter'
local counter = `counter' + 1

}
}
 
twoway (connected pIV pDID pRCT pRDD titles, sort) if top3==1, scheme(s1mono) xlabel(2005 2006 2007 2008 2009 2010 2011 2015 2018) legend(order(1 "IV" 2 "DID" 3 "RCT" 4 "RDD") rows(1)) xtitle(Year) ytitle(Proportion of Articles)
graph export figurea1.png, replace width(1000)

restore

*** figure a2

capture use "Data/MM Data.dta", clear 

duplicates drop journal article year method, force

	capture drop titles
	gen titles = .
levelsof method, local(methods) 
foreach method of local methods {
	capture drop p`method'
	gen p`method' = .
		local counter = 1

levelsof year, local(years) 
foreach year of local years {
count if year == `year'
local all = r(N)
count if year== `year' & method=="`method'"
*count if year == `year' & method == "`method'"
local num_method = r(N)
di `num_method' / `all'
replace titles = `year' in `counter'
replace p`method' = `num_method' / `all' in `counter'
local counter = `counter' + 1

}
}
 
twoway (connected pIV pDID pRCT pRDD titles, sort), scheme(s1mono) xlabel(2015 2018) legend(order(1 "IV" 2 "DID" 3 "RCT" 4 "RDD") rows(1)) xtitle(Year) ytitle(Proportion of Articles)
graph export figurea2.png, replace width(1000)

*** figure a3
capture use "Data/MM Data.dta", clear 

bysort title : gen test_count = round((1/_N)*1000000000,1)

histogram t if t <= 10 & method=="DID"  [fw=test_count], title("DID") saving(temp1, replace) width(0.1) start(0) fcolor(gs10) lcolor(gs10) kdensity kdenopts(width(0.1)) xtitle(z-statistic) xline(1.65 1.96 2.58, lwidth(thin)) xlabel(0(1)10) legend(off) scheme(s1mono)
histogram t if t <= 10 & method=="IV" [fw=test_count], title("IV") saving(temp2, replace) width(0.1) start(0) fcolor(gs10) lcolor(gs10) kdensity kdenopts(width(0.1)) xtitle(z-statistic) xline(1.65 1.96 2.58, lwidth(thin)) xlabel(0(1)10) legend(off) scheme(s1mono)
histogram t if t <= 10 & method=="RCT" [fw=test_count], title("RCT") saving(temp3, replace) width(0.1) start(0) fcolor(gs10) lcolor(gs10) kdensity kdenopts(width(0.1)) xtitle(z-statistic) xline(1.65 1.96 2.58, lwidth(thin)) xlabel(0(1)10) legend(off) scheme(s1mono)
histogram t if t <= 10 & method=="RDD" [fw=test_count], title("RDD") saving(temp4, replace) width(0.1) start(0) fcolor(gs10) lcolor(gs10) kdensity kdenopts(width(0.1)) xtitle(z-statistic) xline(1.65 1.96 2.58, lwidth(thin)) xlabel(0(1)10) legend(off) scheme(s1mono)
graph combine temp1.gph temp2.gph temp3.gph temp4.gph, ycommon scheme(s1mono) xcommon xsize(4) ysize(3)
graph export figurea3.png, replace width(1000)

*** figure a4

capture drop _k*
capture drop x2
gen x2 = _n/10
replace x2 =. if x2 >10
kdensity t if t<10 & method=="IV" , w(0.1) nogr generate(_k1) at(x2)
kdensity t if t<10 & method=="DID" , w(0.1) nogr generate(_k2) at(x2)
kdensity t if t<10 & method=="RCT", w(0.1) nogr generate(_k3) at(x2)
kdensity t if t<10 & method=="RDD", w(0.1) nogr generate(_k4) at(x2)

label var _k1 "IV"
label var _k2 "DID"
label var _k3 "RCT"
label var _k4 "RDD"

twoway (line _k1 x2, lpattern(shortdash) lcolor(gs10))(line _k2 x2, lpattern(dash) lcolor(gs8))(line _k3 x2, lpattern(longdash)  lcolor(gs6))(line _k4 x2, lpattern(line)  lcolor(gs4)) if x2 <= 3.29 & x2 >= 1.28, xline(1.65 1.96 2.58,lstyle(foreground)) xlabel(1.28 1.65 "*" 1.96 "**" 2.58 "***" 3.29) scheme(s1mono) title() leg(rows(4) position(1) ring(0)) ytitle("Density") xtitle("z-Statistic")
graph export figurea4.png, replace width(1000)

*** figure a5

bysort title : egen aw = count(t)
bysort title table : egen tw = count(t)
gen aw_tw = aw*tw

replace aw = 1/aw
replace tw = 1/tw
replace aw_tw = 1/aw_tw

sort journal article table mu
capture drop x2
gen x2 = _n / 1000 if _n < 10001
label var x2 "z-statistic"

sort x2

kdensity t if t<10 [],  w(0.1) nogr generate(temp1) at(x2)
kdensity t if t<10 [aw=aw],  w(0.1) nogr generate(temp2) at(x2)
kdensity t if t<10 [aw=tw],  w(0.1) nogr generate(temp3) at(x2)
kdensity t if t<10 [aw=aw_tw],  w(0.1) nogr generate(temp4) at(x2)

twoway (line temp1 x2)(line temp2 x2, lpattern(dash))(line temp3 x2, lpattern(dot))(line temp4 x2, lpattern(dash)) if x2<=10, xline(1.65 1.96 2.58,lstyle(foreground)) xlabel(0 1 1.65 "*" 1.96 "**" 2.58 "***" 4 5 6 7 8 9 10) saving(temp1, replace) scheme(s1mono) title() ytitle("Density") xtitle("z-statistic") legend(pos(2) ring(0) col(1) lab(1 "Unweighted") lab(2 "Article Weight") lab(3 "Table Weight") lab(4 "Article-Table Weight"))

graph export figurea5.png, replace width(1000)

*** figure a6

capture use "Data/MM Data.dta", clear 

gen top5 = 0 
replace top5 = 1 if strpos(journal,"Quarterly Journal of Economics")
replace top5 = 1 if strpos(journal,"Journal of Political Economy")
replace top5 = 1 if strpos(journal,"Econometrica")
replace top5 = 1 if strpos(journal,"American Economic Review")
replace top5 = 1 if strpos(journal,"Review of Economic Studies")

sort journal article table mu
capture drop x2
gen x2 = _n / 1000 if _n < 10001
label var x2 "z-statistic"

sort x2


capture drop solo_*
capture drop multi_*

kdensity t if t<10 & method=="DID" & top5 == 1   ,  w(0.1) nogr generate(solo_did) at(x2)
kdensity t if t<10 & method=="DID" & top5 == 0   ,  w(0.1) nogr generate(multi_did) at(x2)

kdensity t if t<10 & method=="IV" & top5 == 1   ,  w(0.1) nogr generate(solo_iv) at(x2)
kdensity t if t<10 & method=="IV" & top5 == 0   ,  w(0.1) nogr generate(multi_iv) at(x2)

kdensity t if t<10 & method=="RCT" & top5 == 1   ,  w(0.1) nogr generate(solo_rct) at(x2)
kdensity t if t<10 & method=="RCT" & top5 == 0   ,  w(0.1) nogr generate(multi_rct) at(x2)

kdensity t if t<10 & method=="RDD" & top5 == 1   ,  w(0.1) nogr generate(solo_rdd) at(x2)
kdensity t if t<10 & method=="RDD" & top5 == 0   ,  w(0.1) nogr generate(multi_rdd) at(x2)


twoway (line solo_did x2)(line multi_did x2, lpattern(dash)) if x2<=10, xline(1.65 1.96 2.58,lstyle(foreground)) xlabel(0 1 1.65 "*" 1.96 "**" 2.58 "***" 4 5 6 7 8 9 10) saving(temp1, replace) scheme(s1mono) title(DID) ytitle("Density") xtitle("z-statistic") legend(pos(2) ring(0) col(1) lab(1 "Top 5") lab(2 "Non Top 5"))
twoway (line solo_iv  x2)(line multi_iv  x2, lpattern(dash)) if x2<=10, xline(1.65 1.96 2.58,lstyle(foreground)) xlabel(0 1 1.65 "*" 1.96 "**" 2.58 "***" 4 5 6 7 8 9 10) saving(temp2, replace) scheme(s1mono) title(IV)  ytitle("Density") xtitle("z-statistic") legend(pos(2) ring(0) col(1) lab(1 "Top 5") lab(2 "Non Top 5"))
twoway (line solo_rct x2)(line multi_rct x2, lpattern(dash)) if x2<=10, xline(1.65 1.96 2.58,lstyle(foreground)) xlabel(0 1 1.65 "*" 1.96 "**" 2.58 "***" 4 5 6 7 8 9 10) saving(temp3, replace) scheme(s1mono) title(RCT) ytitle("Density") xtitle("z-statistic") legend(pos(2) ring(0) col(1) lab(1 "Top 5") lab(2 "Non Top 5"))
twoway (line solo_rdd x2)(line multi_rdd x2, lpattern(dash)) if x2<=10, xline(1.65 1.96 2.58,lstyle(foreground)) xlabel(0 1 1.65 "*" 1.96 "**" 2.58 "***" 4 5 6 7 8 9 10) saving(temp4, replace) scheme(s1mono) title(RDD) ytitle("Density") xtitle("z-statistic") legend(pos(2) ring(0) col(1) lab(1 "Top 5") lab(2 "Non Top 5"))

graph combine temp1.gph temp2.gph temp3.gph temp4.gph, ycommon scheme(s1mono) xcommon
graph export figurea6.png, replace width(1000)

*** figure a7

egen num_authors2 = rownonmiss(Author*), strok
replace num_authors = num_authors2 if num_authors==.
drop num_authors2

sort x2

capture drop identifier
gen identifier = 0
local label0 "Solo-Authored"
replace identifier = 1 if num_authors >  1
local label1 "Multi-Authored"

capture drop solo_*
capture drop multi_*

kdensity t if t<10 & method=="DID" & identifier == 0 ,  w(0.1) nogr generate(solo_did) at(x2)
kdensity t if t<10 & method=="DID" & identifier == 1 ,  w(0.1) nogr generate(multi_did) at(x2)

kdensity t if t<10 & method=="IV" & identifier == 0 ,  w(0.1) nogr generate(solo_iv) at(x2)
kdensity t if t<10 & method=="IV" & identifier == 1 ,  w(0.1) nogr generate(multi_iv) at(x2)

kdensity t if t<10 & method=="RCT" & identifier == 0 ,  w(0.1) nogr generate(solo_rct) at(x2)
kdensity t if t<10 & method=="RCT" & identifier == 1 ,  w(0.1) nogr generate(multi_rct) at(x2)

kdensity t if t<10 & method=="RDD" & identifier == 0 ,  w(0.1) nogr generate(solo_rdd) at(x2)
kdensity t if t<10 & method=="RDD" & identifier == 1 ,  w(0.1) nogr generate(multi_rdd) at(x2)


twoway (line solo_did x2)(line multi_did x2, lpattern(dash)) if x2<=10, xline(1.65 1.96 2.58,lstyle(foreground)) xlabel(0 1 1.65 "*" 1.96 "**" 2.58 "***" 4 5 6 7 8 9 10) saving(temp1, replace) scheme(s1mono) title(DID) ytitle("Density") xtitle("z-statistic") legend(pos(2) ring(0) col(1) lab(1 "`label0'") lab(2 "`label1'"))
twoway (line solo_iv  x2)(line multi_iv  x2, lpattern(dash)) if x2<=10, xline(1.65 1.96 2.58,lstyle(foreground)) xlabel(0 1 1.65 "*" 1.96 "**" 2.58 "***" 4 5 6 7 8 9 10) saving(temp2, replace) scheme(s1mono) title(IV)  ytitle("Density") xtitle("z-statistic") legend(pos(2) ring(0) col(1) lab(1 "`label0'") lab(2 "`label1'"))
twoway (line solo_rct x2)(line multi_rct x2, lpattern(dash)) if x2<=10, xline(1.65 1.96 2.58,lstyle(foreground)) xlabel(0 1 1.65 "*" 1.96 "**" 2.58 "***" 4 5 6 7 8 9 10) saving(temp3, replace) scheme(s1mono) title(RCT) ytitle("Density") xtitle("z-statistic") legend(pos(2) ring(0) col(1) lab(1 "`label0'") lab(2 "`label1'"))
twoway (line solo_rdd x2)(line multi_rdd x2, lpattern(dash)) if x2<=10, xline(1.65 1.96 2.58,lstyle(foreground)) xlabel(0 1 1.65 "*" 1.96 "**" 2.58 "***" 4 5 6 7 8 9 10) saving(temp4, replace) scheme(s1mono) title(RDD) ytitle("Density") xtitle("z-statistic") legend(pos(2) ring(0) col(1) lab(1 "`label0'") lab(2 "`label1'"))

graph combine temp1.gph temp2.gph temp3.gph temp4.gph, ycommon scheme(s1mono) xcommon
graph export figurea7.png, replace width(1000)

*** figure a8

forval i = 1(1)11 {
capture drop top_author`i'
gen top_author`i'=0
replace top_author`i'=. if Author`i'==""
replace top_author`i'=1 if strpos(AF`i', "Harvard")
replace top_author`i'=1 if strpos(AF`i', "Massachusetts Institute of Technology") | strpos(AF`i', "MIT")
replace top_author`i'=1 if strpos(AF`i', "Berkeley")
replace top_author`i'=1 if strpos(AF`i', "University of Chicago")
replace top_author`i'=1 if strpos(AF`i', "Paris School of Economics") | strpos(AF`i', "PSE")
replace top_author`i'=1 if strpos(AF`i', "Princeton University")
replace top_author`i'=1 if strpos(AF`i', "Stanford University")
replace top_author`i'=1 if strpos(AF`i', "Oxford University")
replace top_author`i'=1 if strpos(AF`i', "Toulouse School of Economics") | strpos(AF`i', "TSE")
replace top_author`i'=1 if strpos(AF`i', "Columbia University")
replace top_author`i'=1 if strpos(AF`i', "New York University") | strpos(AF`i', "NYU")
replace top_author`i'=1 if strpos(AF`i', "Yale University")
replace top_author`i'=1 if strpos(AF`i', "Boston University")
replace top_author`i'=1 if strpos(AF`i', "Barcelona Graduate School of Economics") | strpos(AF`i', "Barcelona GSE")
replace top_author`i'=1 if strpos(AF`i', "University of California-San Diego") | strpos(AF`i', "UCSD")
replace top_author`i'=1 if strpos(AF`i', "Dartmouth College")
replace top_author`i'=1 if strpos(AF`i', "University of Pennsylvania")
replace top_author`i'=1 if strpos(AF`i', "University College London")  | strpos(AF`i', "UCL")
replace top_author`i'=1 if strpos(AF`i', "Northwestern University")
replace top_author`i'=1 if strpos(AF`i', "Columbia University")
replace top_author`i'=1 if strpos(AF`i', "University of California-Los Angeles ") | strpos(AF`i', "UCLA")
replace top_author`i'=1 if strpos(AF`i', "London School of Economics") | strpos(AF`i', "LSE")
replace top_author`i'=1 if strpos(AF`i', "University of Wisconsin-Madison")
replace top_author`i'=1 if strpos(AF`i', "University of Michigan")
}

capture drop share_top_authors
egen share_top_authors = rowmean(top_author`i'*)

sort x2

capture drop identifier
gen identifier = 0
local label0 "No Top Authors"
replace identifier = 1 if share_top_authors >  0
local label1 "Any Top Authors"

capture drop solo_*
capture drop multi_*

kdensity t if t<10 & method=="DID" & identifier == 0 ,  w(0.1) nogr generate(solo_did) at(x2)
kdensity t if t<10 & method=="DID" & identifier == 1 ,  w(0.1) nogr generate(multi_did) at(x2)

kdensity t if t<10 & method=="IV" & identifier == 0 ,  w(0.1) nogr generate(solo_iv) at(x2)
kdensity t if t<10 & method=="IV" & identifier == 1 ,  w(0.1) nogr generate(multi_iv) at(x2)

kdensity t if t<10 & method=="RCT" & identifier == 0 ,  w(0.1) nogr generate(solo_rct) at(x2)
kdensity t if t<10 & method=="RCT" & identifier == 1 ,  w(0.1) nogr generate(multi_rct) at(x2)

kdensity t if t<10 & method=="RDD" & identifier == 0 ,  w(0.1) nogr generate(solo_rdd) at(x2)
kdensity t if t<10 & method=="RDD" & identifier == 1 ,  w(0.1) nogr generate(multi_rdd) at(x2)


twoway (line solo_did x2)(line multi_did x2, lpattern(dash)) if x2<=10, xline(1.65 1.96 2.58,lstyle(foreground)) xlabel(0 1 1.65 "*" 1.96 "**" 2.58 "***" 4 5 6 7 8 9 10) saving(temp1, replace) scheme(s1mono) title(DID) ytitle("Density") xtitle("z-statistic") legend(pos(2) ring(0) col(1) lab(1 "`label0'") lab(2 "`label1'"))
twoway (line solo_iv  x2)(line multi_iv  x2, lpattern(dash)) if x2<=10, xline(1.65 1.96 2.58,lstyle(foreground)) xlabel(0 1 1.65 "*" 1.96 "**" 2.58 "***" 4 5 6 7 8 9 10) saving(temp2, replace) scheme(s1mono) title(IV)  ytitle("Density") xtitle("z-statistic") legend(pos(2) ring(0) col(1) lab(1 "`label0'") lab(2 "`label1'"))
twoway (line solo_rct x2)(line multi_rct x2, lpattern(dash)) if x2<=10, xline(1.65 1.96 2.58,lstyle(foreground)) xlabel(0 1 1.65 "*" 1.96 "**" 2.58 "***" 4 5 6 7 8 9 10) saving(temp3, replace) scheme(s1mono) title(RCT) ytitle("Density") xtitle("z-statistic") legend(pos(2) ring(0) col(1) lab(1 "`label0'") lab(2 "`label1'"))
twoway (line solo_rdd x2)(line multi_rdd x2, lpattern(dash)) if x2<=10, xline(1.65 1.96 2.58,lstyle(foreground)) xlabel(0 1 1.65 "*" 1.96 "**" 2.58 "***" 4 5 6 7 8 9 10) saving(temp4, replace) scheme(s1mono) title(RDD) ytitle("Density") xtitle("z-statistic") legend(pos(2) ring(0) col(1) lab(1 "`label0'") lab(2 "`label1'"))

graph combine temp1.gph temp2.gph temp3.gph temp4.gph, ycommon scheme(s1mono) xcommon
graph export figurea8.png, replace width(1000)

*** figure a9

forval i = 1(1)11 {
capture drop top_phd`i'
gen top_phd`i'=0
replace top_phd`i'=. if Author`i'==""
replace top_phd`i'=1 if strpos(PhDInstitution`i', "Harvard")
replace top_phd`i'=1 if strpos(PhDInstitution`i', "Massachusetts Institute of Technology") | strpos(PhDInstitution`i', "MIT")
replace top_phd`i'=1 if strpos(PhDInstitution`i', "Berkeley")
replace top_phd`i'=1 if strpos(PhDInstitution`i', "University of Chicago")
replace top_phd`i'=1 if strpos(PhDInstitution`i', "Paris School of Economics") | strpos(PhDInstitution`i', "PSE")
replace top_phd`i'=1 if strpos(PhDInstitution`i', "Princeton University")
replace top_phd`i'=1 if strpos(PhDInstitution`i', "Stanford University")
replace top_phd`i'=1 if strpos(PhDInstitution`i', "Oxford University")
replace top_phd`i'=1 if strpos(PhDInstitution`i', "Toulouse School of Economics") | strpos(PhDInstitution`i', "TSE")
replace top_phd`i'=1 if strpos(PhDInstitution`i', "Columbia University")
replace top_phd`i'=1 if strpos(PhDInstitution`i', "New York University") | strpos(PhDInstitution`i', "NYU")
replace top_phd`i'=1 if strpos(PhDInstitution`i', "Yale University")
replace top_phd`i'=1 if strpos(PhDInstitution`i', "Boston University")
replace top_phd`i'=1 if strpos(PhDInstitution`i', "Barcelona Graduate School of Economics") | strpos(PhDInstitution`i', "Barcelona GSE")
replace top_phd`i'=1 if strpos(PhDInstitution`i', "University of California-San Diego") | strpos(PhDInstitution`i', "UCSD")
replace top_phd`i'=1 if strpos(PhDInstitution`i', "Dartmouth College")
replace top_phd`i'=1 if strpos(PhDInstitution`i', "University of Pennsylvania")
replace top_phd`i'=1 if strpos(PhDInstitution`i', "University College London")  | strpos(PhDInstitution`i', "UCL")
replace top_phd`i'=1 if strpos(PhDInstitution`i', "Northwestern University")
replace top_phd`i'=1 if strpos(PhDInstitution`i', "Columbia University")
replace top_phd`i'=1 if strpos(PhDInstitution`i', "University of California-Los Angeles ") | strpos(PhDInstitution`i', "UCLA")
replace top_phd`i'=1 if strpos(PhDInstitution`i', "London School of Economics") | strpos(PhDInstitution`i', "LSE")
replace top_phd`i'=1 if strpos(PhDInstitution`i', "University of Wisconsin-Madison")
replace top_phd`i'=1 if strpos(PhDInstitution`i', "University of Michigan")
}

capture drop share_top_phd
egen share_top_phd = rowmean(top_phd`i'*)

sort x2

capture drop identifier
gen identifier = 0
local label0 "No Top PhD's"
replace identifier = 1 if share_top_phd >  0
local label1 "Any Top PhD's"

capture drop solo_*
capture drop multi_*

kdensity t if t<10 & method=="DID" & identifier == 0 ,  w(0.1) nogr generate(solo_did) at(x2)
kdensity t if t<10 & method=="DID" & identifier == 1 ,  w(0.1) nogr generate(multi_did) at(x2)

kdensity t if t<10 & method=="IV" & identifier == 0 ,  w(0.1) nogr generate(solo_iv) at(x2)
kdensity t if t<10 & method=="IV" & identifier == 1 ,  w(0.1) nogr generate(multi_iv) at(x2)

kdensity t if t<10 & method=="RCT" & identifier == 0 ,  w(0.1) nogr generate(solo_rct) at(x2)
kdensity t if t<10 & method=="RCT" & identifier == 1 ,  w(0.1) nogr generate(multi_rct) at(x2)

kdensity t if t<10 & method=="RDD" & identifier == 0 ,  w(0.1) nogr generate(solo_rdd) at(x2)
kdensity t if t<10 & method=="RDD" & identifier == 1 ,  w(0.1) nogr generate(multi_rdd) at(x2)


twoway (line solo_did x2)(line multi_did x2, lpattern(dash)) if x2<=10, xline(1.65 1.96 2.58,lstyle(foreground)) xlabel(0 1 1.65 "*" 1.96 "**" 2.58 "***" 4 5 6 7 8 9 10) saving(temp1, replace) scheme(s1mono) title(DID) ytitle("Density") xtitle("z-statistic") legend(pos(2) ring(0) col(1) lab(1 "`label0'") lab(2 "`label1'"))
twoway (line solo_iv  x2)(line multi_iv  x2, lpattern(dash)) if x2<=10, xline(1.65 1.96 2.58,lstyle(foreground)) xlabel(0 1 1.65 "*" 1.96 "**" 2.58 "***" 4 5 6 7 8 9 10) saving(temp2, replace) scheme(s1mono) title(IV)  ytitle("Density") xtitle("z-statistic") legend(pos(2) ring(0) col(1) lab(1 "`label0'") lab(2 "`label1'"))
twoway (line solo_rct x2)(line multi_rct x2, lpattern(dash)) if x2<=10, xline(1.65 1.96 2.58,lstyle(foreground)) xlabel(0 1 1.65 "*" 1.96 "**" 2.58 "***" 4 5 6 7 8 9 10) saving(temp3, replace) scheme(s1mono) title(RCT) ytitle("Density") xtitle("z-statistic") legend(pos(2) ring(0) col(1) lab(1 "`label0'") lab(2 "`label1'"))
twoway (line solo_rdd x2)(line multi_rdd x2, lpattern(dash)) if x2<=10, xline(1.65 1.96 2.58,lstyle(foreground)) xlabel(0 1 1.65 "*" 1.96 "**" 2.58 "***" 4 5 6 7 8 9 10) saving(temp4, replace) scheme(s1mono) title(RDD) ytitle("Density") xtitle("z-statistic") legend(pos(2) ring(0) col(1) lab(1 "`label0'") lab(2 "`label1'"))

graph combine temp1.gph temp2.gph temp3.gph temp4.gph, ycommon scheme(s1mono) xcommon
graph export figurea9.png, replace width(1000)

*** figure a10
capture use "Data/MM Data.dta", clear 

sort journal article table mu
capture drop x2
gen x2 = _n / 1000 if _n < 10001
label var x2 "z-statistic"


* experience
replace PhDYear1 = "1989" if PhDYear1=="2989"

forval i = 1(1)11 {
capture drop PhDYear`i'sieve
egen PhDYear`i'sieve = sieve(PhDYear`i'), keep(numeric)
destring PhDYear`i'sieve, replace
replace PhDYear`i'sieve = . if PhDYear`i'sieve==0
replace PhDYear`i'sieve = . if PhDYear`i'sieve==9999
capture drop experience`i'
gen experience`i' = year-PhDYear`i'sieve
replace experience`i' = . if experience`i'<0
replace experience`i' = . if experience`i' == .
}

capture drop experience_avg
egen experience_avg = rowmean(experience*)

sum experience*

capture drop flag
egen flag = tag(title)

sum experience_avg if flag
local myavg r(mean)
di `myavg'


sort x2

capture drop identifier
gen identifier = 0
local label0 "Low Experience"
replace identifier = 1 if experience_avg >  `myavg'
local label1 "High Experience"

capture drop solo_*
capture drop multi_*

kdensity t if t<10 & method=="DID" & identifier == 0 ,  w(0.1) nogr generate(solo_did) at(x2)
kdensity t if t<10 & method=="DID" & identifier == 1 ,  w(0.1) nogr generate(multi_did) at(x2)

kdensity t if t<10 & method=="IV" & identifier == 0 ,  w(0.1) nogr generate(solo_iv) at(x2)
kdensity t if t<10 & method=="IV" & identifier == 1 ,  w(0.1) nogr generate(multi_iv) at(x2)

kdensity t if t<10 & method=="RCT" & identifier == 0 ,  w(0.1) nogr generate(solo_rct) at(x2)
kdensity t if t<10 & method=="RCT" & identifier == 1 ,  w(0.1) nogr generate(multi_rct) at(x2)

kdensity t if t<10 & method=="RDD" & identifier == 0 ,  w(0.1) nogr generate(solo_rdd) at(x2)
kdensity t if t<10 & method=="RDD" & identifier == 1 ,  w(0.1) nogr generate(multi_rdd) at(x2)


twoway (line solo_did x2)(line multi_did x2, lpattern(dash)) if x2<=10, xline(1.65 1.96 2.58,lstyle(foreground)) xlabel(0 1 1.65 "*" 1.96 "**" 2.58 "***" 4 5 6 7 8 9 10) saving(temp1, replace) scheme(s1mono) title(DID) ytitle("Density") xtitle("z-statistic") legend(pos(2) ring(0) col(1) lab(1 "`label0'") lab(2 "`label1'"))
twoway (line solo_iv  x2)(line multi_iv  x2, lpattern(dash)) if x2<=10, xline(1.65 1.96 2.58,lstyle(foreground)) xlabel(0 1 1.65 "*" 1.96 "**" 2.58 "***" 4 5 6 7 8 9 10) saving(temp2, replace) scheme(s1mono) title(IV)  ytitle("Density") xtitle("z-statistic") legend(pos(2) ring(0) col(1) lab(1 "`label0'") lab(2 "`label1'"))
twoway (line solo_rct x2)(line multi_rct x2, lpattern(dash)) if x2<=10, xline(1.65 1.96 2.58,lstyle(foreground)) xlabel(0 1 1.65 "*" 1.96 "**" 2.58 "***" 4 5 6 7 8 9 10) saving(temp3, replace) scheme(s1mono) title(RCT) ytitle("Density") xtitle("z-statistic") legend(pos(2) ring(0) col(1) lab(1 "`label0'") lab(2 "`label1'"))
twoway (line solo_rdd x2)(line multi_rdd x2, lpattern(dash)) if x2<=10, xline(1.65 1.96 2.58,lstyle(foreground)) xlabel(0 1 1.65 "*" 1.96 "**" 2.58 "***" 4 5 6 7 8 9 10) saving(temp4, replace) scheme(s1mono) title(RDD) ytitle("Density") xtitle("z-statistic") legend(pos(2) ring(0) col(1) lab(1 "`label0'") lab(2 "`label1'"))

graph combine temp1.gph temp2.gph temp3.gph temp4.gph, ycommon scheme(s1mono) xcommon
graph export figurea10.png, replace width(1000)

*** figure a11

forval i = 1(1)11 {
destring Editor`i', replace force
replace Editor`i' = 0 if Editor`i'==. 
}

capture drop editor_present
egen editor_present = rowmax(Editor*)

sort x2

capture drop identifier
gen identifier = 0
local label0 "No Editors"
replace identifier = 1 if editor_present > 0
local label1 "Any Editors"

capture drop solo_*
capture drop multi_*

kdensity t if t<10 & method=="DID" & identifier == 0 ,  w(0.1) nogr generate(solo_did) at(x2)
kdensity t if t<10 & method=="DID" & identifier == 1 ,  w(0.1) nogr generate(multi_did) at(x2)

kdensity t if t<10 & method=="IV" & identifier == 0 ,  w(0.1) nogr generate(solo_iv) at(x2)
kdensity t if t<10 & method=="IV" & identifier == 1 ,  w(0.1) nogr generate(multi_iv) at(x2)

kdensity t if t<10 & method=="RCT" & identifier == 0 ,  w(0.1) nogr generate(solo_rct) at(x2)
kdensity t if t<10 & method=="RCT" & identifier == 1 ,  w(0.1) nogr generate(multi_rct) at(x2)

kdensity t if t<10 & method=="RDD" & identifier == 0 ,  w(0.1) nogr generate(solo_rdd) at(x2)
kdensity t if t<10 & method=="RDD" & identifier == 1 ,  w(0.1) nogr generate(multi_rdd) at(x2)


twoway (line solo_did x2)(line multi_did x2, lpattern(dash)) if x2<=10, xline(1.65 1.96 2.58,lstyle(foreground)) xlabel(0 1 1.65 "*" 1.96 "**" 2.58 "***" 4 5 6 7 8 9 10) saving(temp1, replace) scheme(s1mono) title(DID) ytitle("Density") xtitle("z-statistic") legend(pos(2) ring(0) col(1) lab(1 "`label0'") lab(2 "`label1'"))
twoway (line solo_iv  x2)(line multi_iv  x2, lpattern(dash)) if x2<=10, xline(1.65 1.96 2.58,lstyle(foreground)) xlabel(0 1 1.65 "*" 1.96 "**" 2.58 "***" 4 5 6 7 8 9 10) saving(temp2, replace) scheme(s1mono) title(IV)  ytitle("Density") xtitle("z-statistic") legend(pos(2) ring(0) col(1) lab(1 "`label0'") lab(2 "`label1'"))
twoway (line solo_rct x2)(line multi_rct x2, lpattern(dash)) if x2<=10, xline(1.65 1.96 2.58,lstyle(foreground)) xlabel(0 1 1.65 "*" 1.96 "**" 2.58 "***" 4 5 6 7 8 9 10) saving(temp3, replace) scheme(s1mono) title(RCT) ytitle("Density") xtitle("z-statistic") legend(pos(2) ring(0) col(1) lab(1 "`label0'") lab(2 "`label1'"))
twoway (line solo_rdd x2)(line multi_rdd x2, lpattern(dash)) if x2<=10, xline(1.65 1.96 2.58,lstyle(foreground)) xlabel(0 1 1.65 "*" 1.96 "**" 2.58 "***" 4 5 6 7 8 9 10) saving(temp4, replace) scheme(s1mono) title(RDD) ytitle("Density") xtitle("z-statistic") legend(pos(2) ring(0) col(1) lab(1 "`label0'") lab(2 "`label1'"))

graph combine temp1.gph temp2.gph temp3.gph temp4.gph, ycommon scheme(s1mono) xcommon
graph export figurea11.png, replace width(1000)

*** figure a12

*ssc inst egenmore // may be necessary 

capture drop authors_gender_string
gen authors_gender_string=""
replace authors_gender_string=Gender1+Gender2+Gender3+Gender4+Gender5+Gender6+Gender7+Gender8+Gender9+Gender10+Gender11

capture drop num_male_authors
egen num_male_authors = nss(authors_gender_string) , find(m)

capture drop num_female_authors
egen num_female_authors = nss(authors_gender_string) , find(f)

capture drop share_male_authors
gen share_male_authors = num_male_authors / num_authors

capture drop share_female_authors
gen share_female_authors = num_female_authors / num_authors

sort x2

capture drop identifier
gen identifier = 0
local label0 "No Female Authors"
replace identifier = 1 if share_female_authors > 0
local label1 "Any Female Authors"

capture drop solo_*
capture drop multi_*

kdensity t if t<10 & method=="DID" & identifier == 0 ,  w(0.1) nogr generate(solo_did) at(x2)
kdensity t if t<10 & method=="DID" & identifier == 1 ,  w(0.1) nogr generate(multi_did) at(x2)

kdensity t if t<10 & method=="IV" & identifier == 0 ,  w(0.1) nogr generate(solo_iv) at(x2)
kdensity t if t<10 & method=="IV" & identifier == 1 ,  w(0.1) nogr generate(multi_iv) at(x2)

kdensity t if t<10 & method=="RCT" & identifier == 0 ,  w(0.1) nogr generate(solo_rct) at(x2)
kdensity t if t<10 & method=="RCT" & identifier == 1 ,  w(0.1) nogr generate(multi_rct) at(x2)

kdensity t if t<10 & method=="RDD" & identifier == 0 ,  w(0.1) nogr generate(solo_rdd) at(x2)
kdensity t if t<10 & method=="RDD" & identifier == 1 ,  w(0.1) nogr generate(multi_rdd) at(x2)


twoway (line solo_did x2)(line multi_did x2, lpattern(dash)) if x2<=10, xline(1.65 1.96 2.58,lstyle(foreground)) xlabel(0 1 1.65 "*" 1.96 "**" 2.58 "***" 4 5 6 7 8 9 10) saving(temp1, replace) scheme(s1mono) title(DID) ytitle("Density") xtitle("z-statistic") legend(pos(2) ring(0) col(1) lab(1 "`label0'") lab(2 "`label1'"))
twoway (line solo_iv  x2)(line multi_iv  x2, lpattern(dash)) if x2<=10, xline(1.65 1.96 2.58,lstyle(foreground)) xlabel(0 1 1.65 "*" 1.96 "**" 2.58 "***" 4 5 6 7 8 9 10) saving(temp2, replace) scheme(s1mono) title(IV)  ytitle("Density") xtitle("z-statistic") legend(pos(2) ring(0) col(1) lab(1 "`label0'") lab(2 "`label1'"))
twoway (line solo_rct x2)(line multi_rct x2, lpattern(dash)) if x2<=10, xline(1.65 1.96 2.58,lstyle(foreground)) xlabel(0 1 1.65 "*" 1.96 "**" 2.58 "***" 4 5 6 7 8 9 10) saving(temp3, replace) scheme(s1mono) title(RCT) ytitle("Density") xtitle("z-statistic") legend(pos(2) ring(0) col(1) lab(1 "`label0'") lab(2 "`label1'"))
twoway (line solo_rdd x2)(line multi_rdd x2, lpattern(dash)) if x2<=10, xline(1.65 1.96 2.58,lstyle(foreground)) xlabel(0 1 1.65 "*" 1.96 "**" 2.58 "***" 4 5 6 7 8 9 10) saving(temp4, replace) scheme(s1mono) title(RDD) ytitle("Density") xtitle("z-statistic") legend(pos(2) ring(0) col(1) lab(1 "`label0'") lab(2 "`label1'"))

graph combine temp1.gph temp2.gph temp3.gph temp4.gph, ycommon scheme(s1mono) xcommon

graph export figurea12.png, replace width(1000) 

*** figure a13

use "Data/Star Wars Data.dta", clear // main tables only, DID IV RCT and RDD only

histogram t if t <= 10 & method=="DID"  , title("DID") saving(temp1, replace) width(0.1) start(0) fcolor(gs10) lcolor(gs10) kdensity kdenopts(width(0.1)) xtitle(z-statistic) xline(1.65 1.96 2.58, lwidth(thin)) xlabel(0(1)10) legend(off) scheme(s1mono)
histogram t if t <= 10 & method=="IV" , title("IV") saving(temp2, replace) width(0.1) start(0) fcolor(gs10) lcolor(gs10) kdensity kdenopts(width(0.1)) xtitle(z-statistic) xline(1.65 1.96 2.58, lwidth(thin)) xlabel(0(1)10) legend(off) scheme(s1mono)
histogram t if t <= 10 & method=="RCT" , title("RCT") saving(temp3, replace) width(0.1) start(0) fcolor(gs10) lcolor(gs10) kdensity kdenopts(width(0.1)) xtitle(z-statistic) xline(1.65 1.96 2.58, lwidth(thin)) xlabel(0(1)10) legend(off) scheme(s1mono)
histogram t if t <= 10 & method=="RDD", title("RDD") saving(temp4, replace) width(0.1) start(0) fcolor(gs10) lcolor(gs10) kdensity kdenopts(width(0.1)) xtitle(z-statistic) xline(1.65 1.96 2.58, lwidth(thin)) xlabel(0(1)10) legend(off) scheme(s1mono)
graph combine temp1.gph temp2.gph temp3.gph temp4.gph, ycommon scheme(s1mono) xcommon xsize(4) ysize(3)
graph export figurea13.png, replace width(1000) 

*** figure a14


local figure a b c d 
foreach panel of local figure {
	di "`panel'"

	if "`panel'"=="a" {
	local threshold = 3 // 3 or 5 make sense
	local scale = "N" // Y or N
	local dist = "t" // not a lever, dont change
	}
	if "`panel'"=="b" {
	local threshold = 3 // 3 or 5 make sense
	local scale = "Y" // Y or N
	local dist = "t" // not a lever, dont change
	}
	if "`panel'"=="c" {
	local threshold = 5 // 3 or 5 make sense
	local scale = "N" // Y or N
	local dist = "t" // not a lever, dont change
	}
	if "`panel'"=="d" {
	local threshold = 5 // 3 or 5 make sense
	local scale = "Y" // Y or N
	local dist = "t" // not a lever, dont change
	}
	
	capture use "Data/MM Data.dta", clear 
	
	

capture drop mydf
gen mydf = .

capture drop mynp
gen mynp = .

capture drop myscale
gen myscale = .

levelsof method, local(methods) 
foreach method of local methods {
	di "`method'"  
	capture drop `method'tester
	gen `method'tester = 1
	sum t if method=="`method'"

// isolate the tail
capture drop t_truncated
gen t_truncated = t - `threshold' //  threshold 
replace t_truncated = . if t_truncated <= 0

if "`scale'" == "Y" {

mlexp (ln((ntden({df},{np},t_truncated/{scale})/{scale}))) if t_truncated<10 & method=="`method'" 

matrix B = e(b)
local mydf = B[1,1]
local mynp = B[1,2]
local myscale = B[1,3]

}
else if "`scale'" == "N" {
    
mlexp (ln((ntden({df},{np},t_truncated)))) if t_truncated<10 & method=="`method'" 

matrix B = e(b)
local mydf = B[1,1]
local mynp = B[1,2]
local myscale = 1
	
}

// start with the x values
capture drop x
gen x = _n / 100
replace x = . if _n > 1000

// make the pdf
capture drop pdf_t
gen pdf_t = ntden(`mydf',`mynp',x/`myscale')/`myscale'
label var pdf_t "t~(`mydf',`mynp')"

local mydf = round(`mydf',0.01)
local mynp = round(`mynp',0.01)
local myscale = round(`myscale',0.01)

replace mydf = `mydf' if  method=="`method'"
replace mynp = `mynp' if  method=="`method'"
replace myscale = `myscale' if  method=="`method'"


twoway 	(line pdf_t x, lpattern(dash) sort) ///
	(kdensity t if t < 10  & method=="`method'", lcolor(black)) ///
	,  scheme(s1mono) xlabel(0 1.65 "*" 1.96 "**" 2.58 "***" 5 10) xtitle("t Statistic") xline(1.65 1.96 2.58, lwidth(vvthin)) saving(`method',replace) legend(pos(2) ring(0) col(1) lab(1 "t~(`mydf',`mynp',`myscale')") lab(2 "`method'"))

}

graph combine DID.gph IV.gph RCT.gph RDD.gph , ycommon scheme(s1mono) xcommon xsize(1) ysize(1) caption("") scale(0.75)
graph export figurea14`panel'.png, replace width(1000)
	
	
}



*** figure a15

capture destring fstat, replace force

histogram fstat if fstat <= 100 , title() width(2) start(0) fcolor(gs10) lcolor(gs10) kdensity kdenopts() xtitle(F-Statistic) xline(10, lwidth(thin)) xlabel(0(10)100) legend(off) scheme(s1mono)
graph export figurea15.png, replace width(1000)

*** figure a16

histogram t if t <= 10 & graph_did==0 , title("No Graph") saving(temp1, replace) width(0.1) start(0) fcolor(gs10) lcolor(gs10) kdensity kdenopts(width(0.1)) xtitle(z-statistic) xline(1.65 1.96 2.58, lwidth(thin)) xlabel(0(1)10) legend(off) scheme(s1mono)

histogram t if t <= 10 & graph_did==1 , title("Graph") saving(temp2, replace) width(0.1) start(0) fcolor(gs10) lcolor(gs10) kdensity kdenopts(width(0.1)) xtitle(z-statistic) xline(1.65 1.96 2.58, lwidth(thin)) xlabel(0(1)10) legend(off) scheme(s1mono)

graph combine temp1.gph temp2.gph , ycommon scheme(s1mono) xcommon  xsize(4) ysize(1.5)
graph export figurea16.png, replace width(1000)

*** figure a17

capture drop iv
gen iv = .
replace iv = 1 if method=="IV"

capture drop rct
gen rct = .
replace rct = 1 if method=="RCT"

bysort journal article : egen iv_article = min(iv)
bysort journal article : egen rct_article = min(rct)

capture drop iv_from_rct
gen iv_from_rct = .
replace iv_from_rct = 1 if rct==1 & iv_article==1
replace iv_from_rct = 0 if iv==1 & iv_article==1

histogram t if t <= 10 & iv_from_rct==1 , title(IV From RCT) saving(temp1, replace) width(0.1) start(0) fcolor(gs10) lcolor(gs10) kdensity kdenopts(width(0.1)) xtitle(z-statistic) xline(1.65 1.96 2.58, lwidth(thin)) xlabel(0 1 1.65 "*" 1.96 "**" 2.58 "***" 3 4 5 6 7 8 9 10) legend(off) scheme(s1mono)
histogram t if t <= 10 & iv_from_rct==0 , title(IV) saving(temp2, replace) width(0.1) start(0) fcolor(gs10) lcolor(gs10) kdensity kdenopts(width(0.1)) xtitle(z-statistic) xline(1.65 1.96 2.58, lwidth(thin)) xlabel(0 1 1.65 "*" 1.96 "**" 2.58 "***" 3 4 5 6 7 8 9 10) legend(off) scheme(s1mono)

graph combine temp1.gph temp2.gph , ycommon scheme(s1mono) xcommon xsize(2) ysize(1)
graph export figurea17.png, replace width(1000)

*** figure a18

capture drop iv
gen iv = .
replace iv = 1 if method=="IV"

capture drop rct
gen rct = .
replace rct = 1 if method=="RCT"

capture drop iv_article
bysort journal article : egen iv_article = min(iv)

capture drop rct_article
bysort journal article : egen rct_article = min(rct)

capture drop iv_from_rct
gen iv_from_rct = .
replace iv_from_rct = 1 if rct==1 & iv_article==1
replace iv_from_rct = 0 if iv==1 & iv_article==1

histogram t if t <= 10 & iv_from_rct==1 , title(IV From RCT) saving(temp1, replace) width(0.1) start(0) fcolor(gs10) lcolor(gs10) kdensity kdenopts(width(0.1)) xtitle(z-statistic) xline(1.65 1.96 2.58, lwidth(thin)) xlabel(0 1 1.65 "*" 1.96 "**" 2.58 "***" 3 4 5 6 7 8 9 10) legend(off) scheme(s1mono)
histogram t if t <= 10 & iv_from_rct!=1 & rct==1 , title(RCT) saving(temp2, replace) width(0.1) start(0) fcolor(gs10) lcolor(gs10) kdensity kdenopts(width(0.1)) xtitle(z-statistic) xline(1.65 1.96 2.58, lwidth(thin)) xlabel(0 1 1.65 "*" 1.96 "**" 2.58 "***" 3 4 5 6 7 8 9 10) legend(off) scheme(s1mono)

graph combine temp1.gph temp2.gph , ycommon scheme(s1mono) xcommon xsize(2) ysize(1)
graph export figurea18.png, replace width(1000)

*** figure a19

capture use "Data/MM Data with WP.dta", clear

histogram WP_t if WP_t <= 10 & WP==0  , title("Published") saving(temp1, replace) width(0.1) start(0) fcolor(gs10) lcolor(gs10) kdensity kdenopts(width(0.1)) xtitle(z-statistic) xline(1.65 1.96 2.58, lwidth(thin)) xlabel(0 1 1.65 "*" 1.96 "**" 2.58 "***" 3 4 5 6 7 8 9 10) legend(off) scheme(s1mono)
histogram WP_t if WP_t <= 10 & WP==1  , title("Working Paper") saving(temp2, replace) width(0.1) start(0) fcolor(gs10) lcolor(gs10) kdensity kdenopts(width(0.1)) xtitle(z-statistic) xline(1.65 1.96 2.58, lwidth(thin)) xlabel(0 1 1.65 "*" 1.96 "**" 2.58 "***" 3 4 5 6 7 8 9 10) legend(off) scheme(s1mono)

graph combine temp1.gph temp2.gph , ycommon scheme(s1mono) xcommon  xsize(4) ysize(1.5)
graph export figurea19.png, replace width(1000)

*** figure a20

sort journal article table mu
capture drop x2
gen x2 = _n / 1000 if _n < 10001
label var x2 "z-statistic"

sort x2

capture drop identifier
gen identifier = 0
local label0 "Published"
replace identifier = 1 if WP == 1
local label1 "Working Paper"

capture drop solo_*
capture drop multi_*

kdensity WP_t if WP_t<10 & WP_method=="DID" & identifier == 0 & has_WP==1 ,  w(0.1) nogr generate(solo_did) at(x2)
kdensity WP_t if WP_t<10 & WP_method=="DID" & identifier == 1 & has_WP==1 ,  w(0.1) nogr generate(multi_did) at(x2)

kdensity WP_t if WP_t<10 & WP_method=="IV" & identifier == 0 & has_WP==1 ,  w(0.1) nogr generate(solo_iv) at(x2)
kdensity WP_t if WP_t<10 & WP_method=="IV" & identifier == 1 & has_WP==1 ,  w(0.1) nogr generate(multi_iv) at(x2)

kdensity WP_t if WP_t<10 & WP_method=="RCT" & identifier == 0 & has_WP==1 ,  w(0.1) nogr generate(solo_rct) at(x2)
kdensity WP_t if WP_t<10 & WP_method=="RCT" & identifier == 1 & has_WP==1 ,  w(0.1) nogr generate(multi_rct) at(x2)

kdensity WP_t if WP_t<10 & WP_method=="RDD" & identifier == 0 & has_WP==1 ,  w(0.1) nogr generate(solo_rdd) at(x2)
kdensity WP_t if WP_t<10 & WP_method=="RDD" & identifier == 1 & has_WP==1 ,  w(0.1) nogr generate(multi_rdd) at(x2)


twoway (line solo_did x2)(line multi_did x2, lpattern(dash)) if x2<=10, xline(1.65 1.96 2.58,lstyle(foreground)) xlabel(0 1 1.65 "*" 1.96 "**" 2.58 "***" 4 5 6 7 8 9 10) saving(temp1, replace) scheme(s1mono) title(DID) ytitle("Density") xtitle("z-statistic") legend(pos(2) ring(0) col(1) lab(1 "`label0'") lab(2 "`label1'"))
twoway (line solo_iv  x2)(line multi_iv  x2, lpattern(dash)) if x2<=10, xline(1.65 1.96 2.58,lstyle(foreground)) xlabel(0 1 1.65 "*" 1.96 "**" 2.58 "***" 4 5 6 7 8 9 10) saving(temp2, replace) scheme(s1mono) title(IV)  ytitle("Density") xtitle("z-statistic") legend(pos(2) ring(0) col(1) lab(1 "`label0'") lab(2 "`label1'"))
twoway (line solo_rct x2)(line multi_rct x2, lpattern(dash)) if x2<=10, xline(1.65 1.96 2.58,lstyle(foreground)) xlabel(0 1 1.65 "*" 1.96 "**" 2.58 "***" 4 5 6 7 8 9 10) saving(temp3, replace) scheme(s1mono) title(RCT) ytitle("Density") xtitle("z-statistic") legend(pos(2) ring(0) col(1) lab(1 "`label0'") lab(2 "`label1'"))
twoway (line solo_rdd x2)(line multi_rdd x2, lpattern(dash)) if x2<=10, xline(1.65 1.96 2.58,lstyle(foreground)) xlabel(0 1 1.65 "*" 1.96 "**" 2.58 "***" 4 5 6 7 8 9 10) saving(temp4, replace) scheme(s1mono) title(RDD) ytitle("Density") xtitle("z-statistic") legend(pos(2) ring(0) col(1) lab(1 "`label0'") lab(2 "`label1'"))

graph combine temp1.gph temp2.gph temp3.gph temp4.gph, ycommon scheme(s1mono) xcommon
graph export figurea20.png, replace width(1000)

*** figure a21

capture use "Data/MM Data with WP.dta", clear

gen top5 = 0 
replace top5 = 1 if strpos(journal,"Quarterly Journal of Economics")
replace top5 = 1 if strpos(journal,"Journal of Political Economy")
replace top5 = 1 if strpos(journal,"Econometrica")
replace top5 = 1 if strpos(journal,"American Economic Review")
replace top5 = 1 if strpos(journal,"Review of Economic Studies")

sort journal article table mu
capture drop x2
gen x2 = _n / 1000 if _n < 10001
label var x2 "z-statistic"

sort x2

capture drop solo_*
capture drop multi_*

kdensity WP_t if WP_t<10 & WP_method=="DID" & top5 == 1 & has_WP==1 ,  w(0.1) nogr generate(solo_did) at(x2)
kdensity WP_t if WP_t<10 & WP_method=="DID" & top5 == 0 & has_WP==1 ,  w(0.1) nogr generate(multi_did) at(x2)

kdensity WP_t if WP_t<10 & WP_method=="IV" & top5 == 1 & has_WP==1 ,  w(0.1) nogr generate(solo_iv) at(x2)
kdensity WP_t if WP_t<10 & WP_method=="IV" & top5 == 0 & has_WP==1 ,  w(0.1) nogr generate(multi_iv) at(x2)

kdensity WP_t if WP_t<10 & WP_method=="RCT" & top5 == 1 & has_WP==1 ,  w(0.1) nogr generate(solo_rct) at(x2)
kdensity WP_t if WP_t<10 & WP_method=="RCT" & top5 == 0 & has_WP==1 ,  w(0.1) nogr generate(multi_rct) at(x2)

kdensity WP_t if WP_t<10 & WP_method=="RDD" & top5 == 1 & has_WP==1 ,  w(0.1) nogr generate(solo_rdd) at(x2)
kdensity WP_t if WP_t<10 & WP_method=="RDD" & top5 == 0 & has_WP==1 ,  w(0.1) nogr generate(multi_rdd) at(x2)


twoway (line solo_did x2)(line multi_did x2, lpattern(dash)) if x2<=10, xline(1.65 1.96 2.58,lstyle(foreground)) xlabel(0 1 1.65 "*" 1.96 "**" 2.58 "***" 4 5 6 7 8 9 10) saving(temp1, replace) scheme(s1mono) title(DID) ytitle("Density") xtitle("z-statistic") legend(pos(2) ring(0) col(1) lab(1 "Top 5") lab(2 "Non Top 5"))
twoway (line solo_iv  x2)(line multi_iv  x2, lpattern(dash)) if x2<=10, xline(1.65 1.96 2.58,lstyle(foreground)) xlabel(0 1 1.65 "*" 1.96 "**" 2.58 "***" 4 5 6 7 8 9 10) saving(temp2, replace) scheme(s1mono) title(IV)  ytitle("Density") xtitle("z-statistic") legend(pos(2) ring(0) col(1) lab(1 "Top 5") lab(2 "Non Top 5"))
twoway (line solo_rct x2)(line multi_rct x2, lpattern(dash)) if x2<=10, xline(1.65 1.96 2.58,lstyle(foreground)) xlabel(0 1 1.65 "*" 1.96 "**" 2.58 "***" 4 5 6 7 8 9 10) saving(temp3, replace) scheme(s1mono) title(RCT) ytitle("Density") xtitle("z-statistic") legend(pos(2) ring(0) col(1) lab(1 "Top 5") lab(2 "Non Top 5"))
twoway (line solo_rdd x2)(line multi_rdd x2, lpattern(dash)) if x2<=10, xline(1.65 1.96 2.58,lstyle(foreground)) xlabel(0 1 1.65 "*" 1.96 "**" 2.58 "***" 4 5 6 7 8 9 10) saving(temp4, replace) scheme(s1mono) title(RDD) ytitle("Density") xtitle("z-statistic") legend(pos(2) ring(0) col(1) lab(1 "Top 5") lab(2 "Non Top 5"))

graph combine temp1.gph temp2.gph temp3.gph temp4.gph, ycommon scheme(s1mono) xcommon
graph export figurea21.png, replace width(1000)

*** figure a22

capture drop solo_*
capture drop multi_*

kdensity WP_t if WP_t<10 & WP_method=="DID" & top5 == 1 & has_WP==1 & WP==0,  w(0.1) nogr generate(solo_did) at(x2)
kdensity WP_t if WP_t<10 & WP_method=="DID" & top5 == 0 & has_WP==1 & WP==0 ,  w(0.1) nogr generate(multi_did) at(x2)

kdensity WP_t if WP_t<10 & WP_method=="IV" & top5 == 1 & has_WP==1 & WP==0 ,  w(0.1) nogr generate(solo_iv) at(x2)
kdensity WP_t if WP_t<10 & WP_method=="IV" & top5 == 0 & has_WP==1 & WP==0 ,  w(0.1) nogr generate(multi_iv) at(x2)

kdensity WP_t if WP_t<10 & WP_method=="RCT" & top5 == 1 & has_WP==1 & WP==0 ,  w(0.1) nogr generate(solo_rct) at(x2)
kdensity WP_t if WP_t<10 & WP_method=="RCT" & top5 == 0 & has_WP==1 & WP==0 ,  w(0.1) nogr generate(multi_rct) at(x2)

kdensity WP_t if WP_t<10 & WP_method=="RDD" & top5 == 1 & has_WP==1 & WP==0 ,  w(0.1) nogr generate(solo_rdd) at(x2)
kdensity WP_t if WP_t<10 & WP_method=="RDD" & top5 == 0 & has_WP==1 & WP==0 ,  w(0.1) nogr generate(multi_rdd) at(x2)


twoway (line solo_did x2)(line multi_did x2, lpattern(dash)) if x2<=10, xline(1.65 1.96 2.58,lstyle(foreground)) xlabel(0 1 1.65 "*" 1.96 "**" 2.58 "***" 4 5 6 7 8 9 10) saving(temp1, replace) scheme(s1mono) title(DID) ytitle("Density") xtitle("z-statistic") legend(pos(2) ring(0) col(1) lab(1 "Top 5") lab(2 "Non Top 5"))
twoway (line solo_iv  x2)(line multi_iv  x2, lpattern(dash)) if x2<=10, xline(1.65 1.96 2.58,lstyle(foreground)) xlabel(0 1 1.65 "*" 1.96 "**" 2.58 "***" 4 5 6 7 8 9 10) saving(temp2, replace) scheme(s1mono) title(IV)  ytitle("Density") xtitle("z-statistic") legend(pos(2) ring(0) col(1) lab(1 "Top 5") lab(2 "Non Top 5"))
twoway (line solo_rct x2)(line multi_rct x2, lpattern(dash)) if x2<=10, xline(1.65 1.96 2.58,lstyle(foreground)) xlabel(0 1 1.65 "*" 1.96 "**" 2.58 "***" 4 5 6 7 8 9 10) saving(temp3, replace) scheme(s1mono) title(RCT) ytitle("Density") xtitle("z-statistic") legend(pos(2) ring(0) col(1) lab(1 "Top 5") lab(2 "Non Top 5"))
twoway (line solo_rdd x2)(line multi_rdd x2, lpattern(dash)) if x2<=10, xline(1.65 1.96 2.58,lstyle(foreground)) xlabel(0 1 1.65 "*" 1.96 "**" 2.58 "***" 4 5 6 7 8 9 10) saving(temp4, replace) scheme(s1mono) title(RDD) ytitle("Density") xtitle("z-statistic") legend(pos(2) ring(0) col(1) lab(1 "Top 5") lab(2 "Non Top 5"))

graph combine temp1.gph temp2.gph temp3.gph temp4.gph, ycommon scheme(s1mono) xcommon
graph export figurea22.png, replace width(1000)

*** figures a23, a24 and a25

 use "Data/MM Data.dta", clear


local thresholds 1.65 1.96 2.58
foreach threshold of local thresholds {
di `threshold'

set seed 1989

capture drop results_did
gen results_did = .
capture drop results_iv
gen results_iv = .
capture drop results_rct
gen results_rct = .
capture drop results_rdd
gen results_rdd = .

capture drop num_did
gen num_did = .
capture drop num_iv
gen num_iv = .
capture drop num_rct
gen num_rct = .
capture drop num_rdd
gen num_rdd = .


quietly forval i=1(1)100 {

local delta =  0.25

capture drop binomial
gen binomial = .
replace binomial = 0 if t < `threshold'
replace binomial = 1 if t >= `threshold'

capture drop random
gen random = runiform() if t < `threshold' + `delta' & t > `threshold' - `delta'

capture drop max_random
bysort title table : egen max_random=max(random) if t < `threshold' + `delta' & t > `threshold' - `delta'

capture drop pickme 
gen pickme=0  
replace pickme=1 if random==max_random & t < `threshold' + `delta' & t > `threshold' - `delta'

bitest binomial == 0.5 if t < `threshold' + `delta' & t > `threshold' - `delta' & method == "DID"  & pickme==1
replace results_did = r(p_u) in `i'  // probability of seeing this number of observed stat sigs, or greater
replace num_did = r(N) in `i'  // number of tests used

bitest binomial == 0.5 if t < `threshold' + `delta' & t > `threshold' - `delta' & method == "IV"  & pickme==1
replace results_iv = r(p_u) in `i'  // probability of seeing this number of observed stat sigs, or greater
replace num_iv = r(N) in `i'  // number of tests used

bitest binomial == 0.5 if t < `threshold' + `delta' & t > `threshold' - `delta' & method == "RCT"  & pickme==1
replace results_rct = r(p_u) in `i'  // probability of seeing this number of observed stat sigs, or greater
replace num_rct = r(N) in `i'  // number of tests used

bitest binomial == 0.5 if t < `threshold' + `delta' & t > `threshold' - `delta' & method == "RDD"  & pickme==1
replace results_rdd = r(p_u) in `i'  // probability of seeing this number of observed stat sigs, or greater
replace num_rdd = r(N) in `i'  // number of tests used


}
hist results_did, start(0) width (0.05) xscale(range(0 1)) xlabel(0(0.1)1) addlabels percent title(DID) saving(temp1, replace) fcolor(gs10) lcolor(black) xtitle(p-value) xscale(titlegap(2)) xline(0.1) legend(off) scheme(s1mono)
hist results_iv, start(0) width (0.05) xscale(range(0 1)) xlabel(0(0.1)1) addlabels percent title(IV) saving(temp2, replace) fcolor(gs10) lcolor(black) xtitle(p-value) xscale(titlegap(2)) xline(0.1) legend(off) scheme(s1mono)
hist results_rct, start(0) width (0.05) xscale(range(0 1)) xlabel(0(0.1)1) addlabels percent title(RCT) saving(temp3, replace) fcolor(gs10) lcolor(black) xtitle(p-value) xscale(titlegap(2)) xline(0.1) legend(off) scheme(s1mono)
hist results_rdd, start(0) width (0.05) xscale(range(0 1)) xlabel(0(0.1)1) addlabels percent title(RDD) saving(temp4, replace) fcolor(gs10) lcolor(black) xtitle(p-value) xscale(titlegap(2)) xline(0.1) legend(off) scheme(s1mono)

graph combine temp1.gph temp2.gph temp3.gph temp4.gph , ycommon scheme(s1mono) xcommon xsize(1) ysize(1) caption("") scale(0.75)

if "`threshold'" == "1.65" {
graph export figurea23.png, replace
}

if "`threshold'" == "1.96" {
graph export figurea24.png, replace
}

if "`threshold'" == "2.58" {
graph export figurea25.png, replace
}


} 


*** figure a26

* read in the data
use "Data/MM data.dta" , clear

* journals
rename journal journal_name
gen journal=.
replace journal=1 if journal_name=="Quarterly Journal of Economics"
replace journal=3 if journal_name=="Journal of Political Economy"
replace journal=4 if journal_name=="Econometrica"
replace journal=5 if journal_name=="Journal of Finance" 
replace journal=6 if journal_name=="Review of Economic Studies" 
replace journal=7 if journal_name=="AEJ: Macroeconomics" 
replace journal=8 if journal_name=="Journal of Economic Growth"
replace journal=9 if journal_name=="Review of Economics and Statistics"
replace journal=11 if journal_name=="American Economic Review"
replace journal=12 if journal_name=="Economic Policy"
replace journal=15 if journal_name=="AEJ: Applied Economics"
replace journal=16 if journal_name=="Journal of the European Economic Association"
replace journal=17 if journal_name=="Review of Financial Studies"
replace journal=18 if journal_name=="Journal of International Economics"
replace journal=19 if journal_name=="Economic Journal"
replace journal=20 if journal_name=="Journal of Financial Economics"
replace journal=21 if journal_name=="Experimental Economics"
replace journal=22 if journal_name=="Journal of Development Economics"
replace journal=23 if journal_name=="Journal of Labor Economics"
replace journal=24 if journal_name=="Journal of Financial Intermediation"
replace journal=25 if journal_name=="Journal of Applied Econometrics"
replace journal=26 if journal_name=="Journal of Human Resources"
replace journal=27 if journal_name=="AEJ: Economic Policy" 
replace journal=31 if journal_name=="Journal of Urban Economics"
replace journal=32 if journal_name=="Journal of Public Economics"

gen top5=0 if journal!=.
replace top5=1 if journal==1
replace top5=1 if journal==3
replace top5=1 if journal==4
replace top5=1 if journal==6
replace top5=1 if journal==11

gen FINANCE=0 if journal!=.
replace FINANCE=1 if journal==5
replace FINANCE=1 if journal==17
replace FINANCE=1 if journal==20
replace FINANCE=1 if journal==24

gen MACRO_GROWTH=0 if journal!=.
replace MACRO_GROWTH=1 if journal==7
replace MACRO_GROWTH=1 if journal==8

gen GEN_INT=0 if journal!=.
replace GEN_INT=1 if journal==9
replace GEN_INT=1 if journal==12
replace GEN_INT=1 if journal==14
replace GEN_INT=1 if journal==15
replace GEN_INT=1 if journal==16
replace GEN_INT=1 if journal==19
replace GEN_INT=1 if journal==25
replace GEN_INT=1 if journal==26

gen EXP=0 if journal!=.
replace EXP=1 if journal==21

gen DEV=0 if journal!=.
replace DEV=1 if journal==22

gen LABOR=0 if journal!=.
replace LABOR=1 if journal==23

gen PUB=0 if journal!=.
replace PUB=1 if journal==27
replace PUB=1 if journal==32

gen URB=0 if journal!=.
replace URB=1 if journal==31

* how reported
encode report, gen(ireport)

* weights
gen journal_cluster=journal*10000

egen journal_article_cluster=concat(journal_cluster article)
destring journal_article_cluster, replace

egen journal_article=concat(journal article)
destring journal_article, replace

egen article_table=concat(journal_article_cluster table)
destring article_table, replace

bysort journal_article_cluster: gen test_count = _N
gen aw_d=1/test_count
gen aw=aw_d*10000

bysort article_table: gen test_count_1 = _N
gen aw_tab_d=1/test_count_1
gen aw_tab=aw_tab_d*10000

* unique identifiers
capture egen unique_j = group(journal)
capture egen unique_ja = group(journal article)
capture egen unique_jat = group(journal article table)

* method identifiers
gen RCT=.
replace RCT=1 if method=="RCT"
replace RCT=0 if method!="RCT"

gen DID=.
replace DID=1 if method=="DID"
replace DID=0 if method!="DID"

gen IV=.
replace IV=1 if method=="IV"
replace IV=0 if method!="IV"

gen RDD=.
replace RDD=1 if method=="RDD"
replace RDD=0 if method!="RDD"

* statistical threshold identifiers
gen sign_1pct=.
replace sign_1pct=1 if t!=. & t>2.58
replace sign_1pct=0 if t!=. & t<=2.58

gen sign_5pct=.
replace sign_5pct=1 if t!=. & t>1.96
replace sign_5pct=0 if t!=. & t<=1.96

gen sign_10pct=.
replace sign_10pct=1 if t!=. & t>1.65
replace sign_10pct=0 if t!=. & t<=1.65

* num authors

capture drop num_authors
egen num_authors = rownonmiss(Author*), strok
replace num_authors = 11 if title=="Giving kids a head start: The impact and mechanisms of early commitment of financial aid on poor students in rural China" 

capture drop authored_solo
gen authored_solo = 0
replace authored_solo = 1 if num_authors==1


* genders
*ssc inst egenmore // may be necessary 

capture drop authors_gender_string
gen authors_gender_string=""
replace authors_gender_string=Gender1+Gender2+Gender3+Gender4+Gender5+Gender6+Gender7+Gender8+Gender9+Gender10+Gender11

capture drop num_male_authors
egen num_male_authors = nss(authors_gender_string) , find(m)

capture drop num_female_authors
egen num_female_authors = nss(authors_gender_string) , find(f)

capture drop share_male_authors
gen share_male_authors = num_male_authors / num_authors

capture drop share_female_authors
gen share_female_authors = num_female_authors / num_authors



* experience
replace PhDYear1 = "1989" if PhDYear1=="2989"

forval i = 1(1)11 {
capture drop PhDYear`i'sieve
egen PhDYear`i'sieve = sieve(PhDYear`i'), keep(numeric)
destring PhDYear`i'sieve, replace
replace PhDYear`i'sieve = . if PhDYear`i'sieve==0
replace PhDYear`i'sieve = . if PhDYear`i'sieve==9999
capture drop experience`i'
gen experience`i' = year-PhDYear`i'sieve
replace experience`i' = . if experience`i'<0
replace experience`i' = . if experience`i' == .
}

sum PhDYear*

sum experience*

capture drop experience_avg
capture drop experience_avg_sq

egen experience_avg = rowmean(experience*)
replace experience_avg = 0 if experience_avg==.
gen experience_avg_sq = (experience_avg^2)/100

sum experience*


* editor_present

forval i = 1(1)11 {
destring Editor`i', replace force
replace Editor`i' = 0 if Editor`i'==. 
}

capture drop editor_present
egen editor_present = rowmax(Editor*)

* share_top_authors

forval i = 1(1)11 {
capture drop top_author`i'
gen top_author`i'=0
replace top_author`i'=. if Author`i'==""
replace top_author`i'=1 if strpos(AF`i', "Harvard")
replace top_author`i'=1 if strpos(AF`i', "Massachusetts Institute of Technology") | strpos(AF`i', "MIT")
replace top_author`i'=1 if strpos(AF`i', "Berkeley")
replace top_author`i'=1 if strpos(AF`i', "University of Chicago")
replace top_author`i'=1 if strpos(AF`i', "Paris School of Economics") | strpos(AF`i', "PSE")
replace top_author`i'=1 if strpos(AF`i', "Princeton University")
replace top_author`i'=1 if strpos(AF`i', "Stanford University")
replace top_author`i'=1 if strpos(AF`i', "Oxford University")
replace top_author`i'=1 if strpos(AF`i', "Toulouse School of Economics") | strpos(AF`i', "TSE")
replace top_author`i'=1 if strpos(AF`i', "Columbia University")
replace top_author`i'=1 if strpos(AF`i', "New York University") | strpos(AF`i', "NYU")
replace top_author`i'=1 if strpos(AF`i', "Yale University")
replace top_author`i'=1 if strpos(AF`i', "Boston University")
replace top_author`i'=1 if strpos(AF`i', "Barcelona Graduate School of Economics") | strpos(AF`i', "Barcelona GSE")
replace top_author`i'=1 if strpos(AF`i', "University of California-San Diego") | strpos(AF`i', "UCSD")
replace top_author`i'=1 if strpos(AF`i', "Dartmouth College")
replace top_author`i'=1 if strpos(AF`i', "University of Pennsylvania")
replace top_author`i'=1 if strpos(AF`i', "University College London")  | strpos(AF`i', "UCL")
replace top_author`i'=1 if strpos(AF`i', "Northwestern University")
replace top_author`i'=1 if strpos(AF`i', "Columbia University")
replace top_author`i'=1 if strpos(AF`i', "University of California-Los Angeles ") | strpos(AF`i', "UCLA")
replace top_author`i'=1 if strpos(AF`i', "London School of Economics") | strpos(AF`i', "LSE")
replace top_author`i'=1 if strpos(AF`i', "University of Wisconsin-Madison")
replace top_author`i'=1 if strpos(AF`i', "University of Michigan")
}

capture drop share_top_authors
egen share_top_authors = rowmean(top_author`i'*)

* share_top_phd

forval i = 1(1)11 {
capture drop top_phd`i'
gen top_phd`i'=0
replace top_phd`i'=. if Author`i'==""
replace top_phd`i'=1 if strpos(PhDInstitution`i', "Harvard")
replace top_phd`i'=1 if strpos(PhDInstitution`i', "Massachusetts Institute of Technology") | strpos(PhDInstitution`i', "MIT")
replace top_phd`i'=1 if strpos(PhDInstitution`i', "Berkeley")
replace top_phd`i'=1 if strpos(PhDInstitution`i', "University of Chicago")
replace top_phd`i'=1 if strpos(PhDInstitution`i', "Paris School of Economics") | strpos(PhDInstitution`i', "PSE")
replace top_phd`i'=1 if strpos(PhDInstitution`i', "Princeton University")
replace top_phd`i'=1 if strpos(PhDInstitution`i', "Stanford University")
replace top_phd`i'=1 if strpos(PhDInstitution`i', "Oxford University")
replace top_phd`i'=1 if strpos(PhDInstitution`i', "Toulouse School of Economics") | strpos(PhDInstitution`i', "TSE")
replace top_phd`i'=1 if strpos(PhDInstitution`i', "Columbia University")
replace top_phd`i'=1 if strpos(PhDInstitution`i', "New York University") | strpos(PhDInstitution`i', "NYU")
replace top_phd`i'=1 if strpos(PhDInstitution`i', "Yale University")
replace top_phd`i'=1 if strpos(PhDInstitution`i', "Boston University")
replace top_phd`i'=1 if strpos(PhDInstitution`i', "Barcelona Graduate School of Economics") | strpos(PhDInstitution`i', "Barcelona GSE")
replace top_phd`i'=1 if strpos(PhDInstitution`i', "University of California-San Diego") | strpos(PhDInstitution`i', "UCSD")
replace top_phd`i'=1 if strpos(PhDInstitution`i', "Dartmouth College")
replace top_phd`i'=1 if strpos(PhDInstitution`i', "University of Pennsylvania")
replace top_phd`i'=1 if strpos(PhDInstitution`i', "University College London")  | strpos(PhDInstitution`i', "UCL")
replace top_phd`i'=1 if strpos(PhDInstitution`i', "Northwestern University")
replace top_phd`i'=1 if strpos(PhDInstitution`i', "Columbia University")
replace top_phd`i'=1 if strpos(PhDInstitution`i', "University of California-Los Angeles ") | strpos(PhDInstitution`i', "UCLA")
replace top_phd`i'=1 if strpos(PhDInstitution`i', "London School of Economics") | strpos(PhDInstitution`i', "LSE")
replace top_phd`i'=1 if strpos(PhDInstitution`i', "University of Wisconsin-Madison")
replace top_phd`i'=1 if strpos(PhDInstitution`i', "University of Michigan")
}

capture drop share_top_phd
egen share_top_phd = rowmean(top_phd`i'*)

capture drop min_table
capture drop main_table
egen min_table = min(table), by(journal_article_cluster)
gen main_table = .
replace main_table = 1 if min_table == table

gen DID_graph=DID
replace DID_graph=0 if graph_did==0


label var experience_avg "Experience"
label var experience_avg_sq "Experience$^2$"
label var share_top_authors "Top Institution"
label var share_top_phd "PhD Top Institution"
label var top5 "Top 5"
label var year "Year"


capture drop coef_did
gen coef_did = .

capture drop coef_iv
gen coef_iv = .

capture drop coef_rdd
gen coef_rdd = .

capture drop sig_did
gen sig_did = .

capture drop sig_iv
gen sig_iv = .

capture drop sig_rdd
gen sig_rdd = .


set seed 1989

quietly forval i=1(1)1000 {

	local depvar "sign_5pct"
	local threshold 1.96
	local weight1 "pw="
	local weight2 "aw"
	
capture drop random
gen random = runiform() if t>(`threshold'-0.25) & t<(`threshold'+0.25)

capture drop mean_random
bysort title : egen mean_random=mean(random) if t>(`threshold'-0.25) & t<(`threshold'+0.25)

*probit `depvar' DID IV RDD if t>(`threshold'-0.25) & t<(`threshold'+0.25) & mean_random<0.5 [`weight1'`weight2'], cluster(journal_article_cluster) // resampling papers
probit `depvar' DID IV RDD if t>(`threshold'-0.25) & t<(`threshold'+0.25) & random<mean_random [`weight1'`weight2'], cluster(journal_article_cluster) // resampling tests, within a paper
margins, dydx(*) post

matrix A = e(b)
replace coef_did = A[1,1] in `i'
replace coef_iv = A[1,2] in `i'
replace coef_rdd = A[1,3] in `i'

matrix B = e(V)
replace sig_did = A[1,1]/(B[1,1])^0.5 in `i'
replace sig_iv = A[1,2]/(B[2,2])^0.5 in `i'
replace sig_rdd = A[1,3]/(B[3,3])^0.5 in `i'
// nah do pvalues
replace sig_did = 2*(1-normal(abs(A[1,1]/(B[1,1])^0.5))) in `i'
replace sig_iv = 2*(1-normal(abs(A[1,2]/(B[2,2])^0.5))) in `i'
replace sig_rdd = 2*(1-normal(abs(A[1,3]/(B[3,3])^0.5))) in `i'

}

hist sig_did, start(0) width (0.05) xscale(range(0 1)) xlabel(0(0.1)1) addlabels percent title(DID) saving(temp1, replace) fcolor(gs10) lcolor(black) xtitle(p-value) xscale(titlegap(2)) xline(0.1) legend(off) scheme(s1mono)
hist sig_iv, start(0) width (0.05) xscale(range(0 1)) xlabel(0(0.1)1) addlabels percent title(IV) saving(temp2, replace) fcolor(gs10) lcolor(black) xtitle(p-value) xscale(titlegap(2)) xline(0.1) legend(off) scheme(s1mono)
hist sig_rdd, start(0) width (0.05) xscale(range(0 1)) xlabel(0(0.1)1) addlabels percent title(RDD) saving(temp3, replace) fcolor(gs10) lcolor(black) xtitle(p-value) xscale(titlegap(2)) xline(0.1) legend(off) scheme(s1mono)

graph combine temp1.gph temp2.gph temp3.gph , ycommon scheme(s1mono) xcommon xsize(1) ysize(1) caption("") scale(0.75) rows(2)
graph export figurea26a.png, replace width(1000)

hist coef_did, start() width (0.01) xscale(range()) xlabel()  percent title(DID) saving(temp1, replace) fcolor(gs10) lcolor(black) xtitle(Coefficient) xscale(titlegap(2)) xline(0) legend(off) scheme(s1mono)
hist coef_iv, start() width (0.01) xscale(range()) xlabel()  percent title(IV) saving(temp2, replace) fcolor(gs10) lcolor(black) xtitle(Coefficient) xscale(titlegap(2)) xline(0) legend(off) scheme(s1mono)
hist coef_rdd, start() width (0.01) xscale(range()) xlabel()  percent title(RDD) saving(temp3, replace) fcolor(gs10) lcolor(black) xtitle(Coefficient) xscale(titlegap(2)) xline(0) legend(off) scheme(s1mono)

graph combine temp1.gph temp2.gph temp3.gph , ycommon scheme(s1mono) xcommon xsize(1) ysize(1) caption("") scale(0.75) rows(2)
graph export figurea26b.png, replace width(1000)

*** figure a27

* read in the data
use "Data/MM data.dta" , clear

* journals
rename journal journal_name
gen journal=.
replace journal=1 if journal_name=="Quarterly Journal of Economics"
replace journal=3 if journal_name=="Journal of Political Economy"
replace journal=4 if journal_name=="Econometrica"
replace journal=5 if journal_name=="Journal of Finance" 
replace journal=6 if journal_name=="Review of Economic Studies" 
replace journal=7 if journal_name=="AEJ: Macroeconomics" 
replace journal=8 if journal_name=="Journal of Economic Growth"
replace journal=9 if journal_name=="Review of Economics and Statistics"
replace journal=11 if journal_name=="American Economic Review"
replace journal=12 if journal_name=="Economic Policy"
replace journal=15 if journal_name=="AEJ: Applied Economics"
replace journal=16 if journal_name=="Journal of the European Economic Association"
replace journal=17 if journal_name=="Review of Financial Studies"
replace journal=18 if journal_name=="Journal of International Economics"
replace journal=19 if journal_name=="Economic Journal"
replace journal=20 if journal_name=="Journal of Financial Economics"
replace journal=21 if journal_name=="Experimental Economics"
replace journal=22 if journal_name=="Journal of Development Economics"
replace journal=23 if journal_name=="Journal of Labor Economics"
replace journal=24 if journal_name=="Journal of Financial Intermediation"
replace journal=25 if journal_name=="Journal of Applied Econometrics"
replace journal=26 if journal_name=="Journal of Human Resources"
replace journal=27 if journal_name=="AEJ: Economic Policy" 
replace journal=31 if journal_name=="Journal of Urban Economics"
replace journal=32 if journal_name=="Journal of Public Economics"

gen top5=0 if journal!=.
replace top5=1 if journal==1
replace top5=1 if journal==3
replace top5=1 if journal==4
replace top5=1 if journal==6
replace top5=1 if journal==11

gen FINANCE=0 if journal!=.
replace FINANCE=1 if journal==5
replace FINANCE=1 if journal==17
replace FINANCE=1 if journal==20
replace FINANCE=1 if journal==24

gen MACRO_GROWTH=0 if journal!=.
replace MACRO_GROWTH=1 if journal==7
replace MACRO_GROWTH=1 if journal==8

gen GEN_INT=0 if journal!=.
replace GEN_INT=1 if journal==9
replace GEN_INT=1 if journal==12
replace GEN_INT=1 if journal==14
replace GEN_INT=1 if journal==15
replace GEN_INT=1 if journal==16
replace GEN_INT=1 if journal==19
replace GEN_INT=1 if journal==25
replace GEN_INT=1 if journal==26

gen EXP=0 if journal!=.
replace EXP=1 if journal==21

gen DEV=0 if journal!=.
replace DEV=1 if journal==22

gen LABOR=0 if journal!=.
replace LABOR=1 if journal==23

gen PUB=0 if journal!=.
replace PUB=1 if journal==27
replace PUB=1 if journal==32

gen URB=0 if journal!=.
replace URB=1 if journal==31

* how reported
encode report, gen(ireport)

* weights
gen journal_cluster=journal*10000

egen journal_article_cluster=concat(journal_cluster article)
destring journal_article_cluster, replace

egen journal_article=concat(journal article)
destring journal_article, replace

egen article_table=concat(journal_article_cluster table)
destring article_table, replace

bysort journal_article_cluster: gen test_count = _N
gen aw_d=1/test_count
gen aw=aw_d*10000

bysort article_table: gen test_count_1 = _N
gen aw_tab_d=1/test_count_1
gen aw_tab=aw_tab_d*10000

* unique identifiers
capture egen unique_j = group(journal)
capture egen unique_ja = group(journal article)
capture egen unique_jat = group(journal article table)

* method identifiers
gen RCT=.
replace RCT=1 if method=="RCT"
replace RCT=0 if method!="RCT"

gen DID=.
replace DID=1 if method=="DID"
replace DID=0 if method!="DID"

gen IV=.
replace IV=1 if method=="IV"
replace IV=0 if method!="IV"

gen RDD=.
replace RDD=1 if method=="RDD"
replace RDD=0 if method!="RDD"

* statistical threshold identifiers
gen sign_1pct=.
replace sign_1pct=1 if t!=. & t>2.58
replace sign_1pct=0 if t!=. & t<=2.58

gen sign_5pct=.
replace sign_5pct=1 if t!=. & t>1.96
replace sign_5pct=0 if t!=. & t<=1.96

gen sign_10pct=.
replace sign_10pct=1 if t!=. & t>1.65
replace sign_10pct=0 if t!=. & t<=1.65

* num authors

capture drop num_authors
egen num_authors = rownonmiss(Author*), strok
replace num_authors = 11 if title=="Giving kids a head start: The impact and mechanisms of early commitment of financial aid on poor students in rural China" 

capture drop authored_solo
gen authored_solo = 0
replace authored_solo = 1 if num_authors==1


* genders
*ssc inst egenmore // may be necessary 

capture drop authors_gender_string
gen authors_gender_string=""
replace authors_gender_string=Gender1+Gender2+Gender3+Gender4+Gender5+Gender6+Gender7+Gender8+Gender9+Gender10+Gender11

capture drop num_male_authors
egen num_male_authors = nss(authors_gender_string) , find(m)

capture drop num_female_authors
egen num_female_authors = nss(authors_gender_string) , find(f)

capture drop share_male_authors
gen share_male_authors = num_male_authors / num_authors

capture drop share_female_authors
gen share_female_authors = num_female_authors / num_authors



* experience
replace PhDYear1 = "1989" if PhDYear1=="2989"

forval i = 1(1)11 {
capture drop PhDYear`i'sieve
egen PhDYear`i'sieve = sieve(PhDYear`i'), keep(numeric)
destring PhDYear`i'sieve, replace
replace PhDYear`i'sieve = . if PhDYear`i'sieve==0
replace PhDYear`i'sieve = . if PhDYear`i'sieve==9999
capture drop experience`i'
gen experience`i' = year-PhDYear`i'sieve
replace experience`i' = . if experience`i'<0
replace experience`i' = . if experience`i' == .
}

sum PhDYear*

sum experience*

capture drop experience_avg
capture drop experience_avg_sq

egen experience_avg = rowmean(experience*)
replace experience_avg = 0 if experience_avg==.
gen experience_avg_sq = (experience_avg^2)/100

sum experience*


* editor_present

forval i = 1(1)11 {
destring Editor`i', replace force
replace Editor`i' = 0 if Editor`i'==. 
}

capture drop editor_present
egen editor_present = rowmax(Editor*)

* share_top_authors

forval i = 1(1)11 {
capture drop top_author`i'
gen top_author`i'=0
replace top_author`i'=. if Author`i'==""
replace top_author`i'=1 if strpos(AF`i', "Harvard")
replace top_author`i'=1 if strpos(AF`i', "Massachusetts Institute of Technology") | strpos(AF`i', "MIT")
replace top_author`i'=1 if strpos(AF`i', "Berkeley")
replace top_author`i'=1 if strpos(AF`i', "University of Chicago")
replace top_author`i'=1 if strpos(AF`i', "Paris School of Economics") | strpos(AF`i', "PSE")
replace top_author`i'=1 if strpos(AF`i', "Princeton University")
replace top_author`i'=1 if strpos(AF`i', "Stanford University")
replace top_author`i'=1 if strpos(AF`i', "Oxford University")
replace top_author`i'=1 if strpos(AF`i', "Toulouse School of Economics") | strpos(AF`i', "TSE")
replace top_author`i'=1 if strpos(AF`i', "Columbia University")
replace top_author`i'=1 if strpos(AF`i', "New York University") | strpos(AF`i', "NYU")
replace top_author`i'=1 if strpos(AF`i', "Yale University")
replace top_author`i'=1 if strpos(AF`i', "Boston University")
replace top_author`i'=1 if strpos(AF`i', "Barcelona Graduate School of Economics") | strpos(AF`i', "Barcelona GSE")
replace top_author`i'=1 if strpos(AF`i', "University of California-San Diego") | strpos(AF`i', "UCSD")
replace top_author`i'=1 if strpos(AF`i', "Dartmouth College")
replace top_author`i'=1 if strpos(AF`i', "University of Pennsylvania")
replace top_author`i'=1 if strpos(AF`i', "University College London")  | strpos(AF`i', "UCL")
replace top_author`i'=1 if strpos(AF`i', "Northwestern University")
replace top_author`i'=1 if strpos(AF`i', "Columbia University")
replace top_author`i'=1 if strpos(AF`i', "University of California-Los Angeles ") | strpos(AF`i', "UCLA")
replace top_author`i'=1 if strpos(AF`i', "London School of Economics") | strpos(AF`i', "LSE")
replace top_author`i'=1 if strpos(AF`i', "University of Wisconsin-Madison")
replace top_author`i'=1 if strpos(AF`i', "University of Michigan")
}

capture drop share_top_authors
egen share_top_authors = rowmean(top_author`i'*)

* share_top_phd

forval i = 1(1)11 {
capture drop top_phd`i'
gen top_phd`i'=0
replace top_phd`i'=. if Author`i'==""
replace top_phd`i'=1 if strpos(PhDInstitution`i', "Harvard")
replace top_phd`i'=1 if strpos(PhDInstitution`i', "Massachusetts Institute of Technology") | strpos(PhDInstitution`i', "MIT")
replace top_phd`i'=1 if strpos(PhDInstitution`i', "Berkeley")
replace top_phd`i'=1 if strpos(PhDInstitution`i', "University of Chicago")
replace top_phd`i'=1 if strpos(PhDInstitution`i', "Paris School of Economics") | strpos(PhDInstitution`i', "PSE")
replace top_phd`i'=1 if strpos(PhDInstitution`i', "Princeton University")
replace top_phd`i'=1 if strpos(PhDInstitution`i', "Stanford University")
replace top_phd`i'=1 if strpos(PhDInstitution`i', "Oxford University")
replace top_phd`i'=1 if strpos(PhDInstitution`i', "Toulouse School of Economics") | strpos(PhDInstitution`i', "TSE")
replace top_phd`i'=1 if strpos(PhDInstitution`i', "Columbia University")
replace top_phd`i'=1 if strpos(PhDInstitution`i', "New York University") | strpos(PhDInstitution`i', "NYU")
replace top_phd`i'=1 if strpos(PhDInstitution`i', "Yale University")
replace top_phd`i'=1 if strpos(PhDInstitution`i', "Boston University")
replace top_phd`i'=1 if strpos(PhDInstitution`i', "Barcelona Graduate School of Economics") | strpos(PhDInstitution`i', "Barcelona GSE")
replace top_phd`i'=1 if strpos(PhDInstitution`i', "University of California-San Diego") | strpos(PhDInstitution`i', "UCSD")
replace top_phd`i'=1 if strpos(PhDInstitution`i', "Dartmouth College")
replace top_phd`i'=1 if strpos(PhDInstitution`i', "University of Pennsylvania")
replace top_phd`i'=1 if strpos(PhDInstitution`i', "University College London")  | strpos(PhDInstitution`i', "UCL")
replace top_phd`i'=1 if strpos(PhDInstitution`i', "Northwestern University")
replace top_phd`i'=1 if strpos(PhDInstitution`i', "Columbia University")
replace top_phd`i'=1 if strpos(PhDInstitution`i', "University of California-Los Angeles ") | strpos(PhDInstitution`i', "UCLA")
replace top_phd`i'=1 if strpos(PhDInstitution`i', "London School of Economics") | strpos(PhDInstitution`i', "LSE")
replace top_phd`i'=1 if strpos(PhDInstitution`i', "University of Wisconsin-Madison")
replace top_phd`i'=1 if strpos(PhDInstitution`i', "University of Michigan")
}

capture drop share_top_phd
egen share_top_phd = rowmean(top_phd`i'*)

capture drop min_table
capture drop main_table
egen min_table = min(table), by(journal_article_cluster)
gen main_table = .
replace main_table = 1 if min_table == table

gen DID_graph=DID
replace DID_graph=0 if graph_did==0


label var experience_avg "Experience"
label var experience_avg_sq "Experience$^2$"
label var share_top_authors "Top Institution"
label var share_top_phd "PhD Top Institution"
label var top5 "Top 5"
label var year "Year"


capture drop coef_did
gen coef_did = .

capture drop coef_iv
gen coef_iv = .

capture drop coef_rdd
gen coef_rdd = .

capture drop sig_did
gen sig_did = .

capture drop sig_iv
gen sig_iv = .

capture drop sig_rdd
gen sig_rdd = .


set seed 1989

quietly forval i=1(1)1000 {

	local depvar "sign_5pct"
	local threshold 1.96
	local weight1 "pw="
	local weight2 "aw"
	
capture drop random
gen random = runiform() if t>(`threshold'-0.25) & t<(`threshold'+0.25)

capture drop mean_random
bysort title : egen mean_random=mean(random) if t>(`threshold'-0.25) & t<(`threshold'+0.25)

probit `depvar' DID IV RDD if t>(`threshold'-0.25) & t<(`threshold'+0.25) & mean_random<0.5 [`weight1'`weight2'], cluster(journal_article_cluster) // resampling papers
*probit `depvar' DID IV RDD if t>(`threshold'-0.25) & t<(`threshold'+0.25) & random<mean_random [`weight1'`weight2'], cluster(journal_article_cluster) // resampling tests, within a paper
margins, dydx(*) post

matrix A = e(b)
replace coef_did = A[1,1] in `i'
replace coef_iv = A[1,2] in `i'
replace coef_rdd = A[1,3] in `i'

matrix B = e(V)
replace sig_did = A[1,1]/(B[1,1])^0.5 in `i'
replace sig_iv = A[1,2]/(B[2,2])^0.5 in `i'
replace sig_rdd = A[1,3]/(B[3,3])^0.5 in `i'
// nah do pvalues
replace sig_did = 2*(1-normal(abs(A[1,1]/(B[1,1])^0.5))) in `i'
replace sig_iv = 2*(1-normal(abs(A[1,2]/(B[2,2])^0.5))) in `i'
replace sig_rdd = 2*(1-normal(abs(A[1,3]/(B[3,3])^0.5))) in `i'

}

hist sig_did, start(0) width (0.05) xscale(range(0 1)) xlabel(0(0.1)1) addlabels percent title(DID) saving(temp1, replace) fcolor(gs10) lcolor(black) xtitle(p-value) xscale(titlegap(2)) xline(0.1) legend(off) scheme(s1mono)
hist sig_iv, start(0) width (0.05) xscale(range(0 1)) xlabel(0(0.1)1) addlabels percent title(IV) saving(temp2, replace) fcolor(gs10) lcolor(black) xtitle(p-value) xscale(titlegap(2)) xline(0.1) legend(off) scheme(s1mono)
hist sig_rdd, start(0) width (0.05) xscale(range(0 1)) xlabel(0(0.1)1) addlabels percent title(RDD) saving(temp3, replace) fcolor(gs10) lcolor(black) xtitle(p-value) xscale(titlegap(2)) xline(0.1) legend(off) scheme(s1mono)

graph combine temp1.gph temp2.gph temp3.gph , ycommon scheme(s1mono) xcommon xsize(1) ysize(1) caption("") scale(0.75) rows(2)
graph export figurea27a.png, replace width(1000)

hist coef_did, start() width (0.01) xscale(range()) xlabel()  percent title(DID) saving(temp1, replace) fcolor(gs10) lcolor(black) xtitle(Coefficient) xscale(titlegap(2)) xline(0) legend(off) scheme(s1mono)
hist coef_iv, start() width (0.01) xscale(range()) xlabel()  percent title(IV) saving(temp2, replace) fcolor(gs10) lcolor(black) xtitle(Coefficient) xscale(titlegap(2)) xline(0) legend(off) scheme(s1mono)
hist coef_rdd, start() width (0.01) xscale(range()) xlabel()  percent title(RDD) saving(temp3, replace) fcolor(gs10) lcolor(black) xtitle(Coefficient) xscale(titlegap(2)) xline(0) legend(off) scheme(s1mono)

graph combine temp1.gph temp2.gph temp3.gph , ycommon scheme(s1mono) xcommon xsize(1) ysize(1) caption("") scale(0.75) rows(2)
graph export figurea27b.png, replace width(1000)

*** figure a28

histogram t if t <= 10 & method=="DID" & avg_articles>1 , title("DID") saving(temp1, replace) width(0.1) start(0) fcolor(gs10) lcolor(gs10) kdensity kdenopts(width(0.1)) xtitle(z-statistic) xline(1.65 1.96 2.58, lwidth(thin)) xlabel(0(1)10) legend(off) scheme(s1mono)
histogram t if t <= 10 & method=="IV" & avg_articles>1, title("IV") saving(temp2, replace) width(0.1) start(0) fcolor(gs10) lcolor(gs10) kdensity kdenopts(width(0.1)) xtitle(z-statistic) xline(1.65 1.96 2.58, lwidth(thin)) xlabel(0(1)10) legend(off) scheme(s1mono)
histogram t if t <= 10 & method=="RCT" & avg_articles>1, title("RCT") saving(temp3, replace) width(0.1) start(0) fcolor(gs10) lcolor(gs10) kdensity kdenopts(width(0.1)) xtitle(z-statistic) xline(1.65 1.96 2.58, lwidth(thin)) xlabel(0(1)10) legend(off) scheme(s1mono)
histogram t if t <= 10 & method=="RDD" & avg_articles>1, title("RDD") saving(temp4, replace) width(0.1) start(0) fcolor(gs10) lcolor(gs10) kdensity kdenopts(width(0.1)) xtitle(z-statistic) xline(1.65 1.96 2.58, lwidth(thin)) xlabel(0(1)10) legend(off) scheme(s1mono)
graph combine temp1.gph temp2.gph temp3.gph temp4.gph, ycommon scheme(s1mono) xcommon xsize(4) ysize(3)
graph export figurea28.png, replace width(1000)


beep
