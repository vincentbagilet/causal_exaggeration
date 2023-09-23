* for ease of others to use the model, we create csv's here of our data 
* ready to be plugged into a readily avilable app at Maximilian Kasy's (of Andrews & Kasy 2019) website

capture use "Data/MM Data.dta", clear

levelsof method, local(methods) 
foreach method of local methods{
	di "`method'"
preserve
drop if mu ==.
drop if sd ==.
drop if sd <= 0
keep if method=="`method'" 
drop if abs(t)>100
keep mu sd 
export delimited using "`method'.csv", novarnames replace
restore
}
* then plug these csv's into the online app at https://maxkasy.github.io/home/metastudy/