program reg_traf

local ln `1'
di "this is `ln'"

local int 1.treat#1.post#1.isbaseball
local x1 1.treat#1.post
local x2 1.isbaseball#1.post



est clear
use ${stash}master, clear

eststo: qui xtreg `ln'traf `x1' i.${fe} if isb==1, fe vce(robust)
qui estadd local fixed "Yes"
qui estadd local yearfe "Yes"

eststo: qui xtreg `ln'traf `x1' i.qy if isb==1, fe vce(robust)
qui estadd local fixed "Quality X Year"
qui estadd local yearfe "Yes"

eststo: qui xtreg `ln'traf `int' `x1' `x2' i.$fe, fe vce(robust)
qui estadd local fixed "Yes"
qui estadd local yearfe "Yes"


eststo: qui xtreg `ln'traf `int' `x1' `x2' i.qy, fe vce(robust)
qui estadd local fixed "Quality X Year"
qui estadd local yearfe "Yes"

esttab using "${tables}`ln'traf.tex", keep(`int' `x1' `x2') se ar2 nonotes star(+ 0.15 * 0.10 ** 0.05 *** 0.01) coeflabels(`int' "\emph{out-of-copy X post X baseball}" `x1' "\emph{out-of-copy X post}" `x2' "\emph{baseball X post}") order(`int' `x1' `x2') mtitles( "Traffic" "Traffic" "Traffic" "Traffic") replace booktabs s(fixed yearfe r2_a N N_g, label("Player FE" "Year FE" "adj. \$R^2\$" N "Clusters")) width(\hsize) staraux



end
