use "MM data.dta" , clear
datasignature
quietly{
	replace t = abs(invnormal(abs(pv/2))) if report=="p"
	replace t = 20 if t==. & report=="p"
}
datasignature
save "MM data.dta" , replace

use "MM Data with WP.dta" , clear
datasignature
quietly{
	replace t = abs(invnormal(abs(pv/2))) if report=="p"
	replace t = 20 if t==. & report=="p"
}
datasignature
save "MM Data with WP.dta" , replace

