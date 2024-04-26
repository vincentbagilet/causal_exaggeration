*************************************************************************************************
*** table1
capture use "Data/MM Data.dta", clear 
capture drop titles
gen titles = ""

capture drop DID
gen DID = .
capture drop IV
gen IV = .
capture drop RCT = .
gen RCT = .
capture drop RDD = .
gen RDD = .
capture drop Articles
gen Articles = .
capture drop Tests
gen Tests = .


local counter = 1
levelsof journal, local(journals)
foreach journal of local journals {
replace titles = "`journal'" in `counter'
	foreach method in DID IV RCT RDD {
		distinct article year if method=="`method'" & journal=="`journal'", joint
		replace `method' = r(ndistinct) in `counter'
	}
	distinct article year if journal=="`journal'", joint
	replace Articles = r(ndistinct) in `counter'
	sum t if journal=="`journal'"
	replace Tests = r(N) in `counter'
	local counter = `counter' + 1
}
replace titles = "Total Articles" in `counter'
	foreach method in DID IV RCT RDD {
		distinct journal article year if method=="`method'", joint
		replace `method' = r(ndistinct) in `counter'
	}
	distinct journal article year, joint
	replace Articles = r(ndistinct) in `counter'
	local counter = `counter' + 1

replace titles = "Total Tests" in `counter'
	foreach method in DID IV RCT RDD {
		sum t if method=="`method'"
		replace `method' = r(N) in `counter'
	}
	sum t
	replace Tests = r(N) in `counter'	

ssc install dataout

keep titles DID IV RCT RDD Articles Tests
keep if titles!=""
* see data browser, make manually

*************************************************************************************************
*** table2

clear
set more off

* read in the data
capture use "Data/MM Data.dta", clear 

* top5
gen top5 = 0 if journal!=""
replace top5 = 1 if strpos(journal,"Quarterly Journal of Economics")
replace top5 = 1 if strpos(journal,"Journal of Political Economy")
replace top5 = 1 if strpos(journal,"Econometrica")
replace top5 = 1 if strpos(journal,"American Economic Review")
replace top5 = 1 if strpos(journal,"Review of Economic Studies")

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

eststo clear

eststo DID: quietly estpost summarize ///
    top5 editor_present authored_solo experience_avg   share_female_authors share_top_authors share_top_phd  /// 
	if method == "DID"
eststo IV: quietly estpost summarize ///
    top5 editor_present authored_solo experience_avg   share_female_authors share_top_authors share_top_phd  /// 
	if method == "IV"
eststo RCT: quietly estpost summarize ///
    top5 editor_present authored_solo experience_avg   share_female_authors share_top_authors share_top_phd  /// 
	if method == "RCT"
eststo RDD: quietly estpost summarize ///
    top5 editor_present authored_solo experience_avg   share_female_authors share_top_authors share_top_phd  /// 
	if method == "RDD"	
eststo y2015: quietly estpost summarize ///
    top5 editor_present authored_solo experience_avg   share_female_authors share_top_authors share_top_phd  /// 
	if year == 2015
eststo y2018: quietly estpost summarize ///
    top5 editor_present authored_solo experience_avg   share_female_authors share_top_authors share_top_phd  /// 
	if year == 2018
eststo Top5: quietly estpost summarize ///
    top5 editor_present authored_solo experience_avg   share_female_authors share_top_authors share_top_phd  /// 
	if top5 == 1	
eststo NonTop5: quietly estpost summarize ///
    top5 editor_present authored_solo experience_avg   share_female_authors share_top_authors share_top_phd  /// 
	if top5 == 0
eststo Total: quietly estpost summarize ///
    top5 editor_present authored_solo experience_avg   share_female_authors share_top_authors share_top_phd  /// 
	
esttab ,cells(mean(fmt(2)) sd(par fmt(2)) )  mtitles nonumbers nonotes
esttab using table2, tex replace cells(mean(fmt(2)) sd(par fmt(2)) )  mtitles

*** tablea2
preserve
duplicates drop title method, force

eststo clear

eststo DID: quietly estpost summarize ///
    top5 editor_present authored_solo experience_avg   share_female_authors share_top_authors share_top_phd  /// 
	if method == "DID"
eststo IV: quietly estpost summarize ///
    top5 editor_present authored_solo experience_avg   share_female_authors share_top_authors share_top_phd  /// 
	if method == "IV"
eststo RCT: quietly estpost summarize ///
    top5 editor_present authored_solo experience_avg   share_female_authors share_top_authors share_top_phd  /// 
	if method == "RCT"
eststo RDD: quietly estpost summarize ///
    top5 editor_present authored_solo experience_avg   share_female_authors share_top_authors share_top_phd  /// 
	if method == "RDD"	
eststo y2015: quietly estpost summarize ///
    top5 editor_present authored_solo experience_avg   share_female_authors share_top_authors share_top_phd  /// 
	if year == 2015
eststo y2018: quietly estpost summarize ///
    top5 editor_present authored_solo experience_avg   share_female_authors share_top_authors share_top_phd  /// 
	if year == 2018
eststo Top5: quietly estpost summarize ///
    top5 editor_present authored_solo experience_avg   share_female_authors share_top_authors share_top_phd  /// 
	if top5 == 1	
eststo NonTop5: quietly estpost summarize ///
    top5 editor_present authored_solo experience_avg   share_female_authors share_top_authors share_top_phd  /// 
	if top5 == 0
eststo Total: quietly estpost summarize ///
    top5 editor_present authored_solo experience_avg   share_female_authors share_top_authors share_top_phd  /// 
	
esttab ,cells(mean(fmt(2)) sd(par fmt(2)) )  mtitles nonumbers nonotes
esttab using tablea2  , tex replace cells(mean(fmt(2)) sd(par fmt(2)) )  mtitles
restore

* tablea34
preserve
keep if author_dif_methods>1

eststo clear

eststo DID: quietly estpost summarize ///
    top5 editor_present authored_solo experience_avg   share_female_authors share_top_authors share_top_phd  /// 
	if method == "DID"
eststo IV: quietly estpost summarize ///
    top5 editor_present authored_solo experience_avg   share_female_authors share_top_authors share_top_phd  /// 
	if method == "IV"
eststo RCT: quietly estpost summarize ///
    top5 editor_present authored_solo experience_avg   share_female_authors share_top_authors share_top_phd  /// 
	if method == "RCT"
eststo RDD: quietly estpost summarize ///
    top5 editor_present authored_solo experience_avg   share_female_authors share_top_authors share_top_phd  /// 
	if method == "RDD"	
eststo y2015: quietly estpost summarize ///
    top5 editor_present authored_solo experience_avg   share_female_authors share_top_authors share_top_phd  /// 
	if year == 2015
eststo y2018: quietly estpost summarize ///
    top5 editor_present authored_solo experience_avg   share_female_authors share_top_authors share_top_phd  /// 
	if year == 2018
eststo Top5: quietly estpost summarize ///
    top5 editor_present authored_solo experience_avg   share_female_authors share_top_authors share_top_phd  /// 
	if top5 == 1	
eststo NonTop5: quietly estpost summarize ///
    top5 editor_present authored_solo experience_avg   share_female_authors share_top_authors share_top_phd  /// 
	if top5 == 0
eststo Total: quietly estpost summarize ///
    top5 editor_present authored_solo experience_avg   share_female_authors share_top_authors share_top_phd  /// 
	
esttab ,cells(mean(fmt(2)) sd(par fmt(2)) )  mtitles nonumbers nonotes
esttab using tablea34  , tex replace cells(mean(fmt(2)) sd(par fmt(2)) )  mtitles
restore