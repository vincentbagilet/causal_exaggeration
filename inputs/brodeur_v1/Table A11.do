*** a11

clear
set more off

* read in the data
capture use "Data/MM Data.dta", clear 

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

// Political Science

// now we combine them, adding 128 to 65 and 49 with 90
bitesti 192 139 0.5  
// gerber malhotra 2008a table 1, APSR Vol. 89–101 10% Caliper 64 total, 49 above 15 below
bitesti 64 49 0.5  
// gerber malhotra 2008a table 1, AJPS Vol. 39-51 10% Caliper 128 total, 90 above 38 below
bitesti 128 90 0.5  


// Sociology

// gerber malhotra 2008b table 2, combined 10% caliper over 73 under 33
bitesti 106 33 0.5 
// gerber malhotra 2008b table 2, manually made by adding 41+36 and 26+25
bitesti 77 51 0.5 
// gerber malhotra 2008b table 2, ASR (Vols. 68-70) 10% caliper over 26 under 15
bitesti 41 26 0.5 
// gerber malhotra 2008b table 2, AJS (Vols. 109-111) 10% caliper over 25 under 11
bitesti 36 25 0.5 
// gerber malhotra 2008b table 2, TSQ (Vols. 44-46) 10% caliper over 22 under 7
bitesti 29 22 0.5 