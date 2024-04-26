
* read in the data
use "Data/MM data.dta" , clear

* journals
rename journal journal_name
gen journal=.
replace journal=1 if journal_name=="Quarterly Journal of Economics"
replace journal=3 if journal_name=="Journal of Political Economy"
replace journal=4 if journal_name=="Econometrica"
replace journal=5 if journal_name=="Journal of Finance" // old one, has no effect
replace journal=5 if journal_name=="Journal of Finance" 
replace journal=6 if journal_name=="Review of Economic Studies" // old one, has no effect
replace journal=6 if journal_name=="Review of Economic Studies" 
replace journal=7 if journal_name=="AEJ: Macroeconomics" // old
replace journal=7 if journal_name=="American Economic Journal: Macroeconomics"
replace journal=8 if journal_name=="Journal of Economic Growth"
replace journal=9 if journal_name=="Review of Economics and Statistics"
replace journal=11 if journal_name=="American Economic Review"
replace journal=12 if journal_name=="Economic Policy"
replace journal=15 if journal_name=="AEJ: Applied Economics" // OLD
replace journal=15 if journal_name=="American Economic Journal: Applied Economics"
replace journal=16 if journal_name=="Journal of the European Economic Association"
replace journal=17 if journal_name=="Review of Financial Studies"
replace journal=18 if journal_name=="Journal of International Economics"
replace journal=19 if journal_name=="Economic Journal" // OLD
replace journal=19 if journal_name=="Economic Journal"
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
gen p_value=1 if report=="p"
gen z_stat=1 if report=="s"
gen t_stat=1 if report=="t"

replace p_value=0 if report=="s"
replace p_value=0 if report=="t"
replace z_stat=0 if report=="p"
replace z_stat=0 if report=="t"
replace t_stat=0 if report=="p"
replace t_stat=0 if report=="s"

encode report, gen(ireport)

* unique identifiers
capture egen unique_j = group(journal)
capture egen unique_ja = group(journal article)
capture egen unique_jat = group(journal article table)

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

gen rct_registered=0 if RCT!=.
replace rct_registered=1 if rct_pre_registered==1
destring registered, replace
replace rct_registered=1 if registered==1

gen DID_graph=DID
replace DID_graph=0 if graph_did==0

gen ambiguous=0 if sign_5pct!=.
replace ambiguous=1 if journal_name=="Journal of Urban Economics" & table==7 & article==7 & year==2018
replace ambiguous=1 if Not_sure_shouldbe_included=="1"
replace ambiguous=1 if ambig==1
replace ambiguous=1 if abelcomments=="This is an RCT, I  would code differently"
replace ambiguous=1 if abelcomments=="not sure which tables to select here"
replace ambiguous=1 if drop==1

***********************************
* table_cal_sign_Xpct
***********************************

* this makes 9 tables, for each threshold, 3 different weights

label var experience_avg "Experience"
label var experience_avg_sq "Experience$^2$"
label var share_top_authors "Top Institution"
label var share_top_phd "PhD Top Institution"
label var top5 "Top 5"
label var year "Year"


local panel = 1

forval panel = 1(1)9 {

if "`panel'"=="1" {
	local depvar "sign_5pct"
	local threshold 1.96
	local weight1 "pw="
	local weight2 "aw"
}
if "`panel'"=="2" {
	local depvar "sign_5pct"
	local threshold 1.96
	local weight1 ""
	local weight2 ""
}
if "`panel'"=="3" {
	local depvar "sign_5pct"
	local threshold 1.96
	local weight1 "pw="
	local weight2 "aw_tab"
}
if "`panel'"=="4" {
	local depvar "sign_10pct"
	local threshold 1.65
	local weight1 "pw="
	local weight2 "aw"
}
if "`panel'"=="5" {
	local depvar "sign_10pct"
	local threshold 1.65
	local weight1 ""
	local weight2 ""
}
if "`panel'"=="6" {
	local depvar "sign_10pct"
	local threshold 1.65
	local weight1 "pw="
	local weight2 "aw_tab"
}
if "`panel'"=="7" {
	local depvar "sign_1pct"
	local threshold 2.58
	local weight1 "pw="
	local weight2 "aw"
}
if "`panel'"=="8" {
	local depvar "sign_1pct"
	local threshold 2.58
	local weight1 ""
	local weight2 ""
}
if "`panel'"=="9" {
	local depvar "sign_1pct"
	local threshold 2.58
	local weight1 "pw="
	local weight2 "aw_tab"
}

eststo clear

probit `depvar' DID IV RDD if t>(`threshold'-0.5) & t<(`threshold'+0.5) [`weight1'`weight2'], cluster(journal_article_cluster)
eststo : margins, dydx(*) post
estadd local Window "[`threshold'$\pm$0.50]"

probit `depvar' DID IV RDD top5 i.year experience_avg experience_avg_sq share_top_authors share_top_phd i.ireport authored_solo share_female_authors editor_present if t>(`threshold'-0.5) & t<(`threshold'+0.5) [`weight1'`weight2'], cluster(journal_article_cluster)
eststo : margins, dydx(*) post
estadd local Window "[`threshold'$\pm$0.50]"


probit `depvar' DID IV RDD top5 i.year FINANCE MACRO_GROWTH GEN_INT EXP DEV LABOR PUB URB experience_avg experience_avg_sq share_top_authors share_top_phd i.ireport authored_solo share_female_authors editor_present if t>(`threshold'-0.5) & t<(`threshold'+0.5) [`weight1'`weight2'], cluster(journal_article_cluster)
eststo : margins, dydx(*) post
estadd local Window "[`threshold'$\pm$0.50]"


probit `depvar' DID IV RDD i.year i.unique_j experience_avg experience_avg_sq share_top_authors share_top_phd i.ireport authored_solo share_female_authors editor_present if t>(`threshold'-0.5) & t<(`threshold'+0.5) [`weight1'`weight2'], cluster(journal_article_cluster)
eststo : margins, dydx(*) post
estadd local Window "[`threshold'$\pm$0.50]"


probit `depvar' DID IV RDD i.year i.unique_j experience_avg experience_avg_sq share_top_authors share_top_phd i.ireport authored_solo share_female_authors editor_present if t>(`threshold'-0.35) & t<(`threshold'+0.35) [`weight1'`weight2'], cluster(journal_article_cluster)
eststo : margins, dydx(*) post
estadd local Window "[`threshold'$\pm$0.35]"


probit `depvar' DID IV RDD i.year i.unique_j experience_avg experience_avg_sq share_top_authors share_top_phd i.ireport authored_solo share_female_authors editor_present if t>(`threshold'-0.2) & t<(`threshold'+0.2) [`weight1'`weight2'], cluster(journal_article_cluster)
eststo : margins, dydx(*) post
estadd local Window "[`threshold'$\pm$0.20]"

esttab, margin ///
keep(DID IV RDD top5 2018.year experience_avg experience_avg_sq share_top_authors share_top_phd ) label stats(N Window, fmt(%9.0fc) labels("Observations"))

esttab using table_cal_`depvar'_`weight2'.tex, margin ///
keep(DID IV RDD top5 2018.year experience_avg experience_avg_sq share_top_authors share_top_phd) label  stats(N Window, fmt(%9.0fc) labels("Observations")) ///
mtitles() nomtitles nostar ///
 compress se(3) b(3) replace nogaps noomitted ///
indicate( ///
"Reporting Method = *ireport" ///
"Solo Authored = authored_solo" ///
"Share Female Authors = share_female_authors" ///
"Editor = editor_present" ///
"Field FE = FINANCE" ///
"Journal FE = *unique_j" ///
, labels("Y" " ")) ///
nonotes

}

***********************************
* table_cal_sign_5pct_aw_expanded
***********************************

	local depvar "sign_5pct"
	local threshold 1.96
	local weight1 "pw="
	local weight2 "aw"
	
	label var FINANCE "Finance"
	label var MACRO_GROWTH "Macroeconomics"
	label var GEN_INT "General Interest"
	label var EXP "Experimental"
	label var DEV "Development"
	label var LABOR "Labor"
	label var PUB "Public"
	label var URB "Urban"
	label var authored_solo "Solo-Authored"
	label var share_female_authors "Share Female Authors"
	label var editor_present "Editor Present"
	
eststo clear

probit `depvar' DID IV RDD if t>(`threshold'-0.5) & t<(`threshold'+0.5) [`weight1'`weight2'], cluster(journal_article_cluster)
eststo : margins, dydx(*) post
estadd local Window "[`threshold'$\pm$0.50]"

probit `depvar' DID IV RDD top5 i.year experience_avg experience_avg_sq share_top_authors share_top_phd i.ireport authored_solo share_female_authors editor_present if t>(`threshold'-0.5) & t<(`threshold'+0.5) [`weight1'`weight2'], cluster(journal_article_cluster)
eststo : margins, dydx(*) post
estadd local Window "[`threshold'$\pm$0.50]"


probit `depvar' DID IV RDD top5 i.year FINANCE MACRO_GROWTH GEN_INT EXP DEV LABOR PUB URB experience_avg experience_avg_sq share_top_authors share_top_phd i.ireport authored_solo share_female_authors editor_present if t>(`threshold'-0.5) & t<(`threshold'+0.5) [`weight1'`weight2'], cluster(journal_article_cluster)
eststo : margins, dydx(*) post
estadd local Window "[`threshold'$\pm$0.50]"


probit `depvar' DID IV RDD i.year i.unique_j experience_avg experience_avg_sq share_top_authors share_top_phd i.ireport authored_solo share_female_authors editor_present if t>(`threshold'-0.5) & t<(`threshold'+0.5) [`weight1'`weight2'], cluster(journal_article_cluster)
eststo : margins, dydx(*) post
estadd local Window "[`threshold'$\pm$0.50]"


probit `depvar' DID IV RDD i.year i.unique_j experience_avg experience_avg_sq share_top_authors share_top_phd i.ireport authored_solo share_female_authors editor_present if t>(`threshold'-0.35) & t<(`threshold'+0.35) [`weight1'`weight2'], cluster(journal_article_cluster)
eststo : margins, dydx(*) post
estadd local Window "[`threshold'$\pm$0.35]"


probit `depvar' DID IV RDD i.year i.unique_j experience_avg experience_avg_sq share_top_authors share_top_phd i.ireport authored_solo share_female_authors editor_present if t>(`threshold'-0.2) & t<(`threshold'+0.2) [`weight1'`weight2'], cluster(journal_article_cluster)
eststo : margins, dydx(*) post
estadd local Window "[`threshold'$\pm$0.20]"

esttab, margin ///
drop(*unique_j) label stats(N Window, fmt(%9.0fc) labels("Observations")) nobase ///
 compress se(3) b(3) replace nogaps noomitted ///

esttab using table_cal_sign_5pct_aw_expanded.tex, margin ///
 label  stats(N Window, fmt(%9.0fc) labels("Observations")) noomit nobase ///
mtitles() nomtitles nostar ///
 compress se(3) b(3) replace nogaps noomitted ///
indicate( ///
"Journal FE = *unique_j" ///
, labels("Y" " ")) ///
nonotes
	


***********************************
* table_cal_sign_5pct_aw_logit
***********************************

	local depvar "sign_5pct"
	local threshold 1.96
	local weight1 "pw="
	local weight2 "aw"


eststo clear

logit `depvar' DID IV RDD if t>(`threshold'-0.5) & t<(`threshold'+0.5) [`weight1'`weight2'], cluster(journal_article_cluster)
eststo : margins, dydx(*) post
estadd local Window "[`threshold'$\pm$0.50]"

logit `depvar' DID IV RDD top5 i.year experience_avg experience_avg_sq share_top_authors share_top_phd i.ireport authored_solo share_female_authors editor_present if t>(`threshold'-0.5) & t<(`threshold'+0.5) [`weight1'`weight2'], cluster(journal_article_cluster)
eststo : margins, dydx(*) post
estadd local Window "[`threshold'$\pm$0.50]"


logit `depvar' DID IV RDD top5 i.year FINANCE MACRO_GROWTH GEN_INT EXP DEV LABOR PUB URB experience_avg experience_avg_sq share_top_authors share_top_phd i.ireport authored_solo share_female_authors editor_present if t>(`threshold'-0.5) & t<(`threshold'+0.5) [`weight1'`weight2'], cluster(journal_article_cluster)
eststo : margins, dydx(*) post
estadd local Window "[`threshold'$\pm$0.50]"


logit `depvar' DID IV RDD i.year i.unique_j experience_avg experience_avg_sq share_top_authors share_top_phd i.ireport authored_solo share_female_authors editor_present if t>(`threshold'-0.5) & t<(`threshold'+0.5) [`weight1'`weight2'], cluster(journal_article_cluster)
eststo : margins, dydx(*) post
estadd local Window "[`threshold'$\pm$0.50]"


logit `depvar' DID IV RDD i.year i.unique_j experience_avg experience_avg_sq share_top_authors share_top_phd i.ireport authored_solo share_female_authors editor_present if t>(`threshold'-0.35) & t<(`threshold'+0.35) [`weight1'`weight2'], cluster(journal_article_cluster)
eststo : margins, dydx(*) post
estadd local Window "[`threshold'$\pm$0.35]"


logit `depvar' DID IV RDD i.year i.unique_j experience_avg experience_avg_sq share_top_authors share_top_phd i.ireport authored_solo share_female_authors editor_present if t>(`threshold'-0.2) & t<(`threshold'+0.2) [`weight1'`weight2'], cluster(journal_article_cluster)
eststo : margins, dydx(*) post
estadd local Window "[`threshold'$\pm$0.20]"

esttab, margin ///
keep(DID IV RDD top5 2018.year experience_avg experience_avg_sq share_top_authors share_top_phd ) label stats(N Window, fmt(%9.0fc) labels("Observations"))

esttab using table_cal_`depvar'_`weight2'_logit.tex, margin ///
keep(DID IV RDD top5 2018.year experience_avg experience_avg_sq share_top_authors share_top_phd) label  stats(N Window, fmt(%9.0fc) labels("Observations")) ///
mtitles() nomtitles nostar ///
 compress se(3) b(3) replace nogaps noomitted ///
indicate( ///
"Reporting Method = *ireport" ///
"Solo Authored = authored_solo" ///
"Share Female Authors = share_female_authors" ///
"Editor = editor_present" ///
"Field FE = FINANCE" ///
"Journal FE = *unique_j" ///
, labels("Y" " ")) ///
nonotes


***********************************
* table_cal_sign_5pct_aw_bootstrap
***********************************

/* just to save time commented out

	set seed 1989
	local depvar "sign_5pct"
	local threshold 1.96
	local weight1 "pw="
	local weight2 "aw"
	local reps 250


eststo clear

probit `depvar' DID IV RDD if t>(`threshold'-0.5) & t<(`threshold'+0.5) , vce(bootstrap, reps(`reps') cluster(title))
eststo : margins, dydx(*) post
estadd local Window "[`threshold'$\pm$0.50]"

probit `depvar' DID IV RDD top5 i.year experience_avg experience_avg_sq share_top_authors share_top_phd i.ireport authored_solo share_female_authors editor_present if t>(`threshold'-0.5) & t<(`threshold'+0.5), vce(bootstrap, reps(`reps') cluster(title))
eststo : margins, dydx(*) post
estadd local Window "[`threshold'$\pm$0.50]"


probit `depvar' DID IV RDD top5 i.year FINANCE MACRO_GROWTH GEN_INT EXP DEV LABOR PUB URB experience_avg experience_avg_sq share_top_authors share_top_phd i.ireport authored_solo share_female_authors editor_present if t>(`threshold'-0.5) & t<(`threshold'+0.5), vce(bootstrap, reps(`reps') cluster(title))
eststo : margins, dydx(*) post
estadd local Window "[`threshold'$\pm$0.50]"


probit `depvar' DID IV RDD i.year i.unique_j experience_avg experience_avg_sq share_top_authors share_top_phd i.ireport authored_solo share_female_authors editor_present if t>(`threshold'-0.5) & t<(`threshold'+0.5), vce(bootstrap, reps(`reps') cluster(title))
eststo : margins, dydx(*) post
estadd local Window "[`threshold'$\pm$0.50]"

probit `depvar' DID IV RDD i.year i.unique_j experience_avg experience_avg_sq share_top_authors share_top_phd i.ireport authored_solo share_female_authors editor_present if t>(`threshold'-0.35) & t<(`threshold'+0.35), vce(bootstrap, reps(`reps') cluster(title))
eststo : margins, dydx(*) post
estadd local Window "[`threshold'$\pm$0.35]"


probit `depvar' DID IV RDD i.year i.unique_j experience_avg experience_avg_sq share_top_authors share_top_phd i.ireport authored_solo share_female_authors editor_present if t>(`threshold'-0.2) & t<(`threshold'+0.2), vce(bootstrap, reps(`reps') cluster(title))
eststo : margins, dydx(*) post
estadd local Window "[`threshold'$\pm$0.20]"

esttab, margin ///
keep(DID IV RDD top5 2018.year experience_avg experience_avg_sq share_top_authors share_top_phd ) label stats(N Window, fmt(%9.0fc) labels("Observations"))

esttab using table_cal_sign_5pct_aw_bootstrap.tex, margin ///
keep(DID IV RDD top5 2018.year experience_avg experience_avg_sq share_top_authors share_top_phd) label  stats(N Window, fmt(%9.0fc) labels("Observations")) ///
mtitles() nomtitles nostar ///
 compress se(3) b(3) replace nogaps noomitted ///
indicate( ///
"Reporting Method = *ireport" ///
"Solo Authored = authored_solo" ///
"Share Female Authors = share_female_authors" ///
"Editor = editor_present" ///
"Field FE = FINANCE" ///
"Journal FE = *unique_j" ///
, labels("Y" " ")) ///
nonotes

beep

*/



***********************************
* table_cal_sign_5pct_ambig
***********************************

preserve

capture drop ambiguous
gen ambiguous=0 if sign_5pct!=.
replace ambiguous=1 if journal_name=="Journal of Urban Economics" & table==7 & article==7 & year==2018
replace ambiguous=1 if Not_sure_shouldbe_included=="1"
replace ambiguous=1 if ambig==1
replace ambiguous=1 if abelcomments=="This is an RCT, I  would code differently"
replace ambiguous=1 if abelcomments=="not sure which tables to select here"
replace ambiguous=1 if drop==1

drop if ambiguous == 1

	local depvar "sign_5pct"
	local threshold 1.96
	local weight1 "pw="
	local weight2 "aw"


eststo clear

probit `depvar' DID IV RDD if t>(`threshold'-0.5) & t<(`threshold'+0.5) [`weight1'`weight2'], cluster(journal_article_cluster)
eststo : margins, dydx(*) post
estadd local Window "[`threshold'$\pm$0.50]"

probit `depvar' DID IV RDD top5 i.year experience_avg experience_avg_sq share_top_authors share_top_phd i.ireport authored_solo share_female_authors editor_present if t>(`threshold'-0.5) & t<(`threshold'+0.5) [`weight1'`weight2'], cluster(journal_article_cluster)
eststo : margins, dydx(*) post
estadd local Window "[`threshold'$\pm$0.50]"


probit `depvar' DID IV RDD top5 i.year FINANCE MACRO_GROWTH GEN_INT EXP DEV LABOR PUB URB experience_avg experience_avg_sq share_top_authors share_top_phd i.ireport authored_solo share_female_authors editor_present if t>(`threshold'-0.5) & t<(`threshold'+0.5) [`weight1'`weight2'], cluster(journal_article_cluster)
eststo : margins, dydx(*) post
estadd local Window "[`threshold'$\pm$0.50]"


probit `depvar' DID IV RDD i.year i.unique_j experience_avg experience_avg_sq share_top_authors share_top_phd i.ireport authored_solo share_female_authors editor_present if t>(`threshold'-0.5) & t<(`threshold'+0.5) [`weight1'`weight2'], cluster(journal_article_cluster)
eststo : margins, dydx(*) post
estadd local Window "[`threshold'$\pm$0.50]"


probit `depvar' DID IV RDD i.year i.unique_j experience_avg experience_avg_sq share_top_authors share_top_phd i.ireport authored_solo share_female_authors editor_present if t>(`threshold'-0.35) & t<(`threshold'+0.35) [`weight1'`weight2'], cluster(journal_article_cluster)
eststo : margins, dydx(*) post
estadd local Window "[`threshold'$\pm$0.35]"


probit `depvar' DID IV RDD i.year i.unique_j experience_avg experience_avg_sq share_top_authors share_top_phd i.ireport authored_solo share_female_authors editor_present if t>(`threshold'-0.2) & t<(`threshold'+0.2) [`weight1'`weight2'], cluster(journal_article_cluster)
eststo : margins, dydx(*) post
estadd local Window "[`threshold'$\pm$0.20]"

esttab, margin ///
keep(DID IV RDD top5 2018.year experience_avg experience_avg_sq share_top_authors share_top_phd ) label stats(N Window, fmt(%9.0fc) labels("Observations"))

esttab using table_cal_sign_5pct_ambig.tex, margin ///
keep(DID IV RDD top5 2018.year experience_avg experience_avg_sq share_top_authors share_top_phd) label  stats(N Window, fmt(%9.0fc) labels("Observations")) ///
mtitles() nomtitles nostar ///
 compress se(3) b(3) replace nogaps noomitted ///
indicate( ///
"Reporting Method = *ireport" ///
"Solo Authored = authored_solo" ///
"Share Female Authors = share_female_authors" ///
"Editor = editor_present" ///
"Field FE = FINANCE" ///
"Journal FE = *unique_j" ///
, labels("Y" " ")) ///
nonotes

restore


***********************************
* table_cal_sign_5pct_aw_single_method_articles
***********************************

preserve

keep if article_number_methods==1

	local depvar "sign_5pct"
	local threshold 1.96
	local weight1 "pw="
	local weight2 "aw"


eststo clear

probit `depvar' DID IV RDD if t>(`threshold'-0.5) & t<(`threshold'+0.5) [`weight1'`weight2'], cluster(journal_article_cluster)
eststo : margins, dydx(*) post
estadd local Window "[`threshold'$\pm$0.50]"

probit `depvar' DID IV RDD top5 i.year experience_avg experience_avg_sq share_top_authors share_top_phd i.ireport authored_solo share_female_authors editor_present if t>(`threshold'-0.5) & t<(`threshold'+0.5) [`weight1'`weight2'], cluster(journal_article_cluster)
eststo : margins, dydx(*) post
estadd local Window "[`threshold'$\pm$0.50]"


probit `depvar' DID IV RDD top5 i.year FINANCE MACRO_GROWTH GEN_INT EXP DEV LABOR PUB URB experience_avg experience_avg_sq share_top_authors share_top_phd i.ireport authored_solo share_female_authors editor_present if t>(`threshold'-0.5) & t<(`threshold'+0.5) [`weight1'`weight2'], cluster(journal_article_cluster)
eststo : margins, dydx(*) post
estadd local Window "[`threshold'$\pm$0.50]"


probit `depvar' DID IV RDD i.year i.unique_j experience_avg experience_avg_sq share_top_authors share_top_phd i.ireport authored_solo share_female_authors editor_present if t>(`threshold'-0.5) & t<(`threshold'+0.5) [`weight1'`weight2'], cluster(journal_article_cluster)
eststo : margins, dydx(*) post
estadd local Window "[`threshold'$\pm$0.50]"


probit `depvar' DID IV RDD i.year i.unique_j experience_avg experience_avg_sq share_top_authors share_top_phd i.ireport authored_solo share_female_authors editor_present if t>(`threshold'-0.35) & t<(`threshold'+0.35) [`weight1'`weight2'], cluster(journal_article_cluster)
eststo : margins, dydx(*) post
estadd local Window "[`threshold'$\pm$0.35]"


probit `depvar' DID IV RDD i.year i.unique_j experience_avg experience_avg_sq share_top_authors share_top_phd i.ireport authored_solo share_female_authors editor_present if t>(`threshold'-0.2) & t<(`threshold'+0.2) [`weight1'`weight2'], cluster(journal_article_cluster)
eststo : margins, dydx(*) post
estadd local Window "[`threshold'$\pm$0.20]"

esttab, margin ///
keep(DID IV RDD top5 2018.year experience_avg experience_avg_sq share_top_authors share_top_phd ) label stats(N Window, fmt(%9.0fc) labels("Observations"))

esttab using table_cal_sign_5pct_aw_single_method_articles.tex, margin ///
keep(DID IV RDD top5 2018.year experience_avg experience_avg_sq share_top_authors share_top_phd) label  stats(N Window, fmt(%9.0fc) labels("Observations")) ///
mtitles() nomtitles nostar ///
 compress se(3) b(3) replace nogaps noomitted ///
indicate( ///
"Reporting Method = *ireport" ///
"Solo Authored = authored_solo" ///
"Share Female Authors = share_female_authors" ///
"Editor = editor_present" ///
"Field FE = FINANCE" ///
"Journal FE = *unique_j" ///
, labels("Y" " ")) ///
nonotes

restore

***********************************
* table_cal_sign_5pct_aw_tab_1sttable
***********************************

	local depvar "sign_5pct"
	local threshold 1.96
	local weight1 "pw="
	local weight2 "aw_tab"


eststo clear

probit `depvar' DID IV RDD if t>(`threshold'-0.5) & t<(`threshold'+0.5) & main_table==1  [`weight1'`weight2'], cluster(journal_article_cluster)
eststo : margins, dydx(*) post
estadd local Window "[`threshold'$\pm$0.50]"

probit `depvar' DID IV RDD top5 i.year experience_avg experience_avg_sq share_top_authors share_top_phd i.ireport authored_solo share_female_authors editor_present if t>(`threshold'-0.5) & t<(`threshold'+0.5) & main_table==1  [`weight1'`weight2'], cluster(journal_article_cluster)
eststo : margins, dydx(*) post
estadd local Window "[`threshold'$\pm$0.50]"


probit `depvar' DID IV RDD top5 i.year FINANCE MACRO_GROWTH GEN_INT EXP DEV LABOR PUB URB experience_avg experience_avg_sq share_top_authors share_top_phd i.ireport authored_solo share_female_authors editor_present if t>(`threshold'-0.5) & t<(`threshold'+0.5) & main_table==1  [`weight1'`weight2'], cluster(journal_article_cluster)
eststo : margins, dydx(*) post
estadd local Window "[`threshold'$\pm$0.50]"


probit `depvar' DID IV RDD i.year i.unique_j experience_avg experience_avg_sq share_top_authors share_top_phd i.ireport authored_solo share_female_authors editor_present if t>(`threshold'-0.5) & t<(`threshold'+0.5) & main_table==1  [`weight1'`weight2'], cluster(journal_article_cluster)
eststo : margins, dydx(*) post
estadd local Window "[`threshold'$\pm$0.50]"


probit `depvar' DID IV RDD i.year i.unique_j experience_avg experience_avg_sq share_top_authors share_top_phd i.ireport authored_solo share_female_authors editor_present if t>(`threshold'-0.35) & t<(`threshold'+0.35) & main_table==1  [`weight1'`weight2'], cluster(journal_article_cluster)
eststo : margins, dydx(*) post
estadd local Window "[`threshold'$\pm$0.35]"


probit `depvar' DID IV RDD i.year i.unique_j experience_avg experience_avg_sq share_top_authors share_top_phd i.ireport authored_solo share_female_authors editor_present if t>(`threshold'-0.2) & t<(`threshold'+0.2) & main_table==1  [`weight1'`weight2'], cluster(journal_article_cluster)
eststo : margins, dydx(*) post
estadd local Window "[`threshold'$\pm$0.20]"

esttab, margin ///
keep(DID IV RDD top5 2018.year experience_avg experience_avg_sq share_top_authors share_top_phd ) label stats(N Window, fmt(%9.0fc) labels("Observations"))

esttab using table_cal_`depvar'_`weight2'_1sttable.tex, margin ///
keep(DID IV RDD top5 2018.year experience_avg experience_avg_sq share_top_authors share_top_phd) label  stats(N Window, fmt(%9.0fc) labels("Observations")) ///
mtitles() nomtitles nostar ///
 compress se(3) b(3) replace nogaps noomitted ///
indicate( ///
"Reporting Method = *ireport" ///
"Solo Authored = authored_solo" ///
"Share Female Authors = share_female_authors" ///
"Editor = editor_present" ///
"Field FE = FINANCE" ///
"Journal FE = *unique_j" ///
, labels("Y" " ")) ///
nonotes





* whole sample non caliper

local panel = 1

forval panel = 1(1)3 {

if "`panel'"=="1" {
	local depvar "sign_5pct"
	local weight1 "pw="
	local weight2 "aw"
}
if "`panel'"=="2" {
	local depvar "sign_10pct"
	local weight1 "pw="
	local weight2 "aw"
}
if "`panel'"=="3" {
	local depvar "sign_1pct"
	local weight1 "pw="
	local weight2 "aw"
}

eststo clear

probit `depvar' DID IV RDD [`weight1'`weight2'], cluster(journal_article_cluster)
eststo : margins, dydx(*) post

probit `depvar' DID IV RDD top5 i.year experience_avg experience_avg_sq share_top_authors share_top_phd i.ireport authored_solo share_female_authors editor_present  [`weight1'`weight2'], cluster(journal_article_cluster)
eststo : margins, dydx(*) post

probit `depvar' DID IV RDD top5 i.year FINANCE MACRO_GROWTH GEN_INT EXP DEV LABOR PUB URB experience_avg experience_avg_sq share_top_authors share_top_phd i.ireport authored_solo share_female_authors editor_present [`weight1'`weight2'] , cluster(journal_article_cluster)
eststo : margins, dydx(*) post

probit `depvar' DID IV RDD i.year i.unique_j experience_avg experience_avg_sq share_top_authors share_top_phd i.ireport authored_solo share_female_authors editor_present [`weight1'`weight2'], cluster(journal_article_cluster)
eststo : margins, dydx(*) post

esttab, margin ///
keep(DID IV RDD top5 2018.year experience_avg experience_avg_sq share_top_authors share_top_phd ) label stats(N, fmt(%9.0fc) labels("Observations"))

esttab using table_`depvar'_`weight2'.tex, margin ///
keep(DID IV RDD top5 2018.year experience_avg experience_avg_sq share_top_authors share_top_phd) label  stats(N, fmt(%9.0fc) labels("Observations")) ///
mtitles() nomtitles nostar ///
 compress se(3) b(3) replace nogaps noomitted ///
indicate( ///
"Reporting Method = *ireport" ///
"Solo Authored = authored_solo" ///
"Share Female Authors = share_female_authors" ///
"Editor = editor_present" ///
"Field FE = FINANCE" ///
"Journal FE = *unique_j" ///
, labels("Y" " ")) ///
nonotes

}



*** windows


* table_cal_sign_5pct_aw_windows

	local depvar "sign_5pct"
	local threshold 1.96
	local weight1 "pw="
	local weight2 "aw"

eststo clear

probit `depvar' DID IV RDD i.year  experience_avg experience_avg_sq share_top_authors share_top_phd i.ireport authored_solo share_female_authors editor_present if t>(`threshold'-0.6) & t<(`threshold'+0.6) [`weight1'`weight2'], cluster(journal_article_cluster)
eststo : margins, dydx(*) post
estadd local Window "[`threshold'$\pm$0.60]"

probit `depvar' DID IV RDD i.year  experience_avg experience_avg_sq share_top_authors share_top_phd i.ireport authored_solo share_female_authors editor_present if t>(`threshold'-0.5) & t<(`threshold'+0.5) [`weight1'`weight2'], cluster(journal_article_cluster)
eststo : margins, dydx(*) post
estadd local Window "[`threshold'$\pm$0.50]"

probit `depvar' DID IV RDD i.year  experience_avg experience_avg_sq share_top_authors share_top_phd i.ireport authored_solo share_female_authors editor_present if t>(`threshold'-0.4) & t<(`threshold'+0.4) [`weight1'`weight2'], cluster(journal_article_cluster)
eststo : margins, dydx(*) post
estadd local Window "[`threshold'$\pm$0.40]"

probit `depvar' DID IV RDD i.year  experience_avg experience_avg_sq share_top_authors share_top_phd i.ireport authored_solo share_female_authors editor_present if t>(`threshold'-0.3) & t<(`threshold'+0.3) [`weight1'`weight2'], cluster(journal_article_cluster)
eststo : margins, dydx(*) post
estadd local Window "[`threshold'$\pm$0.30]"

probit `depvar' DID IV RDD i.year  experience_avg experience_avg_sq share_top_authors share_top_phd i.ireport authored_solo share_female_authors editor_present if t>(`threshold'-0.2) & t<(`threshold'+0.2) [`weight1'`weight2'], cluster(journal_article_cluster)
eststo : margins, dydx(*) post
estadd local Window "[`threshold'$\pm$0.20]"

probit `depvar' DID IV RDD i.year  experience_avg experience_avg_sq share_top_authors share_top_phd i.ireport authored_solo share_female_authors editor_present if t>(`threshold'-0.1) & t<(`threshold'+0.1) [`weight1'`weight2'], cluster(journal_article_cluster)
eststo : margins, dydx(*) post
estadd local Window "[`threshold'$\pm$0.10]"

esttab, margin ///
keep(DID IV RDD  2018.year experience_avg experience_avg_sq share_top_authors share_top_phd ) label stats(N Window, fmt(%9.0fc) labels("Observations"))

esttab using table_cal_`depvar'_`weight2'_windows.tex, margin ///
keep(DID IV RDD  2018.year experience_avg experience_avg_sq share_top_authors share_top_phd) label  stats(N Window, fmt(%9.0fc) labels("Observations")) ///
mtitles() nomtitles nostar ///
 compress se(3) b(3) replace nogaps noomitted ///
indicate( ///
"Reporting Method = *ireport" ///
"Solo Authored = authored_solo" ///
"Share Female Authors = share_female_authors" ///
"Editor = editor_present" ///
, labels("Y" " ")) ///
nonotes

* table_cal_sign_5pct_aw_windows_JFE

	local depvar "sign_5pct"
	local threshold 1.96
	local weight1 "pw="
	local weight2 "aw"

eststo clear

probit `depvar' DID IV RDD i.year i.unique_j experience_avg experience_avg_sq share_top_authors share_top_phd i.ireport authored_solo share_female_authors editor_present if t>(`threshold'-0.6) & t<(`threshold'+0.6) [`weight1'`weight2'], cluster(journal_article_cluster)
eststo : margins, dydx(*) post
estadd local Window "[`threshold'$\pm$0.60]"

probit `depvar' DID IV RDD i.year i.unique_j experience_avg experience_avg_sq share_top_authors share_top_phd i.ireport authored_solo share_female_authors editor_present if t>(`threshold'-0.5) & t<(`threshold'+0.5) [`weight1'`weight2'], cluster(journal_article_cluster)
eststo : margins, dydx(*) post
estadd local Window "[`threshold'$\pm$0.50]"

probit `depvar' DID IV RDD i.year i.unique_j experience_avg experience_avg_sq share_top_authors share_top_phd i.ireport authored_solo share_female_authors editor_present if t>(`threshold'-0.4) & t<(`threshold'+0.4) [`weight1'`weight2'], cluster(journal_article_cluster)
eststo : margins, dydx(*) post
estadd local Window "[`threshold'$\pm$0.40]"

probit `depvar' DID IV RDD i.year i.unique_j experience_avg experience_avg_sq share_top_authors share_top_phd i.ireport authored_solo share_female_authors editor_present if t>(`threshold'-0.3) & t<(`threshold'+0.3) [`weight1'`weight2'], cluster(journal_article_cluster)
eststo : margins, dydx(*) post
estadd local Window "[`threshold'$\pm$0.30]"

probit `depvar' DID IV RDD i.year i.unique_j experience_avg experience_avg_sq share_top_authors share_top_phd i.ireport authored_solo share_female_authors editor_present if t>(`threshold'-0.2) & t<(`threshold'+0.2) [`weight1'`weight2'], cluster(journal_article_cluster)
eststo : margins, dydx(*) post
estadd local Window "[`threshold'$\pm$0.20]"

probit `depvar' DID IV RDD i.year i.unique_j experience_avg experience_avg_sq share_top_authors share_top_phd i.ireport authored_solo share_female_authors editor_present if t>(`threshold'-0.1) & t<(`threshold'+0.1) [`weight1'`weight2'], cluster(journal_article_cluster)
eststo : margins, dydx(*) post
estadd local Window "[`threshold'$\pm$0.10]"

esttab, margin ///
keep(DID IV RDD  2018.year experience_avg experience_avg_sq share_top_authors share_top_phd ) label stats(N Window, fmt(%9.0fc) labels("Observations"))

esttab using table_cal_`depvar'_`weight2'_windows_JFE.tex, margin ///
keep(DID IV RDD  2018.year experience_avg experience_avg_sq share_top_authors share_top_phd) label  stats(N Window, fmt(%9.0fc) labels("Observations")) ///
mtitles() nomtitles nostar ///
 compress se(3) b(3) replace nogaps noomitted ///
indicate( ///
"Reporting Method = *ireport" ///
"Solo Authored = authored_solo" ///
"Share Female Authors = share_female_authors" ///
"Editor = editor_present" ///
"Journal FE = *unique_j" ///
, labels("Y" " ")) ///
nonotes






***********************************
* table_cal_sign_5pct_aw_DID_GRAPH
***********************************

	local depvar "sign_5pct"
	local threshold 1.96
	local weight1 "pw="
	local weight2 "aw"
	
	label var DID_graph "DID with Graph"

eststo clear

probit `depvar' DID_graph IV RDD RCT if t>(`threshold'-0.5) & t<(`threshold'+0.5) [`weight1'`weight2'], cluster(journal_article_cluster)
eststo : margins, dydx(*) post
estadd local Window "[`threshold'$\pm$0.50]"

probit `depvar' DID_graph IV RDD RCT  top5 i.year experience_avg experience_avg_sq share_top_authors share_top_phd i.ireport authored_solo share_female_authors editor_present if t>(`threshold'-0.5) & t<(`threshold'+0.5) [`weight1'`weight2'], cluster(journal_article_cluster)
eststo : margins, dydx(*) post
estadd local Window "[`threshold'$\pm$0.50]"


probit `depvar' DID_graph IV RDD RCT  top5 i.year FINANCE MACRO_GROWTH GEN_INT EXP DEV LABOR PUB URB experience_avg experience_avg_sq share_top_authors share_top_phd i.ireport authored_solo share_female_authors editor_present if t>(`threshold'-0.5) & t<(`threshold'+0.5) [`weight1'`weight2'], cluster(journal_article_cluster)
eststo : margins, dydx(*) post
estadd local Window "[`threshold'$\pm$0.50]"


probit `depvar' DID_graph IV RDD RCT  i.year i.unique_j experience_avg experience_avg_sq share_top_authors share_top_phd i.ireport authored_solo share_female_authors editor_present if t>(`threshold'-0.5) & t<(`threshold'+0.5) [`weight1'`weight2'], cluster(journal_article_cluster)
eststo : margins, dydx(*) post
estadd local Window "[`threshold'$\pm$0.50]"


probit `depvar' DID_graph IV RDD RCT  i.year i.unique_j experience_avg experience_avg_sq share_top_authors share_top_phd i.ireport authored_solo share_female_authors editor_present if t>(`threshold'-0.35) & t<(`threshold'+0.35) [`weight1'`weight2'], cluster(journal_article_cluster)
eststo : margins, dydx(*) post
estadd local Window "[`threshold'$\pm$0.35]"


probit `depvar' DID_graph IV RDD  RCT  i.year i.unique_j experience_avg experience_avg_sq share_top_authors share_top_phd i.ireport authored_solo share_female_authors editor_present if t>(`threshold'-0.2) & t<(`threshold'+0.2) [`weight1'`weight2'], cluster(journal_article_cluster)
eststo : margins, dydx(*) post
estadd local Window "[`threshold'$\pm$0.20]"

esttab, margin ///
keep(DID_graph IV RDD RCT top5 2018.year experience_avg experience_avg_sq share_top_authors share_top_phd ) label stats(N Window, fmt(%9.0fc) labels("Observations"))

esttab using table_cal_`depvar'_`weight2'_DID_GRAPH.tex, margin ///
keep(DID_graph IV RDD RCT top5 2018.year experience_avg experience_avg_sq share_top_authors share_top_phd) label  stats(N Window, fmt(%9.0fc) labels("Observations")) ///
mtitles() nomtitles nostar ///
 compress se(3) b(3) replace nogaps noomitted ///
indicate( ///
"Reporting Method = *ireport" ///
"Solo Authored = authored_solo" ///
"Share Female Authors = share_female_authors" ///
"Editor = editor_present" ///
"Field FE = FINANCE" ///
"Journal FE = *unique_j" ///
, labels("Y" " ")) ///
nonotes







***********************************
*App Table - By Field
***********************************

	local depvar "sign_5pct"
	local threshold 1.96
	local weight1 "pw="
	local weight2 "aw"

eststo clear

probit `depvar' DID IV RDD i.year i.unique_j experience_avg experience_avg_sq share_top_authors share_top_phd i.ireport authored_solo share_female_authors editor_present if t>(`threshold'-0.5) & t<(`threshold'+0.5) & top5==0  [`weight1'`weight2'], cluster(journal_article_cluster)
eststo : margins, dydx(*) post
estadd local Window "Top 5"

probit `depvar' DID IV RDD i.year i.unique_j experience_avg experience_avg_sq share_top_authors share_top_phd i.ireport authored_solo share_female_authors editor_present if t>(`threshold'-0.5) & t<(`threshold'+0.5) &  FINANCE==0  [`weight1'`weight2'], cluster(journal_article_cluster)
eststo : margins, dydx(*) post
estadd local Window "Finance"

probit `depvar' DID IV RDD i.year i.unique_j experience_avg experience_avg_sq share_top_authors share_top_phd i.ireport authored_solo share_female_authors editor_present if t>(`threshold'-0.5) & t<(`threshold'+0.5) &  MACRO_GROWTH==0  [`weight1'`weight2'], cluster(journal_article_cluster)
eststo : margins, dydx(*) post
estadd local Window "Macro"

probit `depvar' DID IV RDD i.year i.unique_j experience_avg experience_avg_sq share_top_authors share_top_phd i.ireport authored_solo share_female_authors editor_present if t>(`threshold'-0.5) & t<(`threshold'+0.5)  & GEN_INT==0  [`weight1'`weight2'], cluster(journal_article_cluster)
eststo : margins, dydx(*) post
estadd local Window "General"

probit `depvar' DID IV RDD i.year i.unique_j experience_avg experience_avg_sq share_top_authors share_top_phd i.ireport authored_solo share_female_authors editor_present if t>(`threshold'-0.5) & t<(`threshold'+0.5) &  DEV==0  [`weight1'`weight2'], cluster(journal_article_cluster)
eststo : margins, dydx(*) post
estadd local Window "Development"

probit `depvar' DID IV RDD i.year i.unique_j experience_avg experience_avg_sq share_top_authors share_top_phd i.ireport authored_solo share_female_authors editor_present if t>(`threshold'-0.5) & t<(`threshold'+0.5) &  EXP==0  [`weight1'`weight2'], cluster(journal_article_cluster)
eststo : margins, dydx(*) post
estadd local Window "Experimental"

probit `depvar' DID IV RDD i.year i.unique_j experience_avg experience_avg_sq share_top_authors share_top_phd i.ireport authored_solo share_female_authors editor_present if t>(`threshold'-0.5) & t<(`threshold'+0.5) &  LABOR==0  [`weight1'`weight2'], cluster(journal_article_cluster)
eststo : margins, dydx(*) post
estadd local Window "Labor"

probit `depvar' DID IV RDD i.year i.unique_j experience_avg experience_avg_sq share_top_authors share_top_phd i.ireport authored_solo share_female_authors editor_present if t>(`threshold'-0.5) & t<(`threshold'+0.5) &  PUB==0  [`weight1'`weight2'], cluster(journal_article_cluster)
eststo : margins, dydx(*) post
estadd local Window "Public"

probit `depvar' DID IV RDD i.year i.unique_j experience_avg experience_avg_sq share_top_authors share_top_phd i.ireport authored_solo share_female_authors editor_present if t>(`threshold'-0.5) & t<(`threshold'+0.5) &  URB==0  [`weight1'`weight2'], cluster(journal_article_cluster)
eststo : margins, dydx(*) post
estadd local Window "Urban"



esttab, margin ///
keep(DID IV RDD  2018.year experience_avg experience_avg_sq share_top_authors share_top_phd ) label stats(N Window, fmt(%9.0fc) labels("Observations"))

esttab using table_cal_`depvar'_`weight2'_FIELD.tex, margin ///
keep(DID IV RDD  2018.year experience_avg experience_avg_sq share_top_authors share_top_phd) label  stats(N Window, fmt(%9.0fc) labels("Observations" "Dropped")) ///
mtitles() nomtitles nostar ///
 compress se(3) b(3) replace nogaps noomitted ///
indicate( ///
"Reporting Method = *ireport" ///
"Solo Authored = authored_solo" ///
"Share Female Authors = share_female_authors" ///
"Editor = editor_present" ///
"Journal FE = *unique_j" ///
, labels("Y" " ")) ///
nonotes


********************* Working papers

clear
set more off

* read in the data
capture use "Data/MM Data with WP.dta", clear

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

* unique identifiers
capture egen unique_j = group(journal)
capture egen unique_ja = group(journal article)
capture egen unique_jat = group(journal article table)

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



* method identifiers
gen RCT=.
replace RCT=1 if method=="RCT" | WP_method=="RCT"
replace RCT=0 if method!="RCT" & WP_method!="RCT"

gen DID=.
replace DID=1 if method=="DID" | WP_method=="DID"
replace DID=0 if method!="DID" & WP_method!="DID"

gen IV=.
replace IV=1 if method=="IV" | WP_method=="IV"
replace IV=0 if method!="IV" & WP_method!="IV"

gen RDD=.
replace RDD=1 if method=="RDD" | WP_method=="RDD"
replace RDD=0 if method!="RDD" & WP_method!="RDD"

* statistical threshold identifiers
gen sign_1pct=.
replace sign_1pct=1 if WP_t!=. & t>2.58
replace sign_1pct=0 if WP_t!=. & t<=2.58

gen sign_5pct=.
replace sign_5pct=1 if WP_t!=. & WP_t>1.96
replace sign_5pct=0 if WP_t!=. & WP_t<=1.96

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

egen min_table = min(table), by(title)
gen main_table = .
replace main_table = 1 if min_table == table

gen DID_graph=DID
replace DID_graph=0 if graph_did==0


***********************************
* table_cal_sign_Xpct_wp
***********************************

label var experience_avg "Experience"
label var experience_avg_sq "Experience$^2$"
label var share_top_authors "Top Institution"
label var share_top_phd "PhD Top Institution"
label var top5 "Top 5"
label var year "Year"

replace report = WP_report if report==""
replace report = "c" if report =="ci"
drop ireport
encode report, gen(ireport)

egen ititle = group(title)

*** A23

capture drop Published
gen Published = 0
replace Published = 1 if WP == 0

label var Published "Published Version"

eststo clear 

eststo All :areg sign_5pct Published   [pw=aw] if WP_t>(1.46) & WP_t<(2.46) & has_WP==1, cluster(ititle) a(ititle)
estadd local Window "[1.96$\pm$0.50]"
 
eststo DID :areg sign_5pct Published   [pw=aw] if WP_t>(1.46) & WP_t<(2.46) &  has_WP==1 & WP_method=="DID", cluster(ititle) a(ititle)
estadd local Window "[1.96$\pm$0.50]"

eststo IV  :areg sign_5pct Published   [pw=aw] if WP_t>(1.46) & WP_t<(2.46) &  has_WP==1 & WP_method=="IV", cluster(ititle) a(ititle)
estadd local Window "[1.96$\pm$0.50]"

eststo RCT :areg sign_5pct Published   [pw=aw] if WP_t>(1.46) & WP_t<(2.46) &  has_WP==1 & WP_method=="RCT", cluster(ititle) a(ititle)
estadd local Window "[1.96$\pm$0.50]"

eststo RDD :areg sign_5pct Published   [pw=aw] if WP_t>(1.46) & WP_t<(2.46) &  has_WP==1 & WP_method=="RDD", cluster(ititle) a(ititle)
estadd local Window "[1.96$\pm$0.50]"

esttab,  ///
stats(N N_clust Window, fmt(%9.0fc) labels("Test Statistics" "Articles")) ///
label  mtitles(ALL DID IV RCT RDD)  nostar compress se(3) b(3) replace nogaps noomitted ///
nonotes

esttab using table_cal_sign_5pct_aw_wp.tex,  ///
stats(N N_clust Window, fmt(%9.0fc) labels("Test Statistics" "Articles")) ///
label  mtitles(ALL DID IV RCT RDD)  nostar compress se(3) b(3) replace nogaps noomitted ///
nonotes

*** A22

preserve

eststo clear

duplicates drop title, force

probit has_WP DID IV RDD [pw=aw], cluster(journal_article_cluster)
eststo : margins, dydx(*) post

probit has_WP DID IV RDD top5 i.year experience_avg experience_avg_sq share_top_authors share_top_phd i.ireport authored_solo share_female_authors editor_present [pw=aw], cluster(journal_article_cluster)
eststo : margins, dydx(*) post

probit has_WP DID IV RDD top5 i.year FINANCE MACRO_GROWTH GEN_INT EXP DEV LABOR PUB URB experience_avg experience_avg_sq share_top_authors share_top_phd i.ireport authored_solo share_female_authors editor_present [pw=aw], cluster(journal_article_cluster)
eststo : margins, dydx(*) post

probit has_WP DID IV RDD top5 i.year i.unique_j experience_avg experience_avg_sq share_top_authors share_top_phd i.ireport authored_solo share_female_authors editor_present [pw=aw], cluster(journal_article_cluster)
eststo : margins, dydx(*) post

esttab , margin ///
keep(DID IV RDD   top5 2018.year experience_avg experience_avg_sq share_top_authors share_top_phd) label  stats(N, fmt(%9.0fc) labels("Articles")) ///
mtitles() nomtitles   ///
 compress se(3) b(3) replace nogaps noomitted ///
indicate( ///
"Reporting Method = *ireport" ///
"Solo Authored = authored_solo" ///
"Share Female Authors = share_female_authors" ///
"Editor = editor_present" ///
"Field FE = FINANCE" ///
"Journal FE = *unique_j" ///
, labels("Y" " ")) ///
nonotes

esttab using table_has_wp.tex, margin ///
keep(DID IV RDD   top5 2018.year experience_avg experience_avg_sq share_top_authors share_top_phd) label  stats(N, fmt(%9.0fc) labels("Articles")) ///
mtitles() nomtitles nostar ///
 compress se(3) b(3) replace nogaps noomitted ///
indicate( ///
"Reporting Method = *ireport" ///
"Solo Authored = authored_solo" ///
"Share Female Authors = share_female_authors" ///
"Editor = editor_present" ///
"Field FE = FINANCE" ///
"Journal FE = *unique_j" ///
, labels("Y" " ")) ///
nonotes

restore
