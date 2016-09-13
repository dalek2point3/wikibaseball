// regression DD with Sample B
program reg_traf

local int 1.treat#1.post#1.isbaseball
local x1 1.treat#1.post
local x2 1.isbaseball#1.post

est clear
use ${stash}master, clear
drop if year < 2004 | year > 2012

eststo: qui reg traf `x1' i.${fe} if isb==1, vce(robust)
qui estadd local fixed "No"
qui estadd local yearfe "Year FE"

eststo: qui xtreg traf `x1' i.${fe} if isb==1, fe vce(robust)
qui estadd local fixed "Yes"
qui estadd local yearfe "Year FE"

eststo: qui xtreg traf `x1' i.qy if isb==1, fe vce(robust)
qui estadd local fixed "Yes"
qui estadd local yearfe "Quality X Year FE"

esttab using "${tables}`ln'traf.tex", keep(`x1') se ar2 nonotes star(+ 0.15 * 0.10 ** 0.05 *** 0.01) coeflabels(`x1' "\emph{out-of-copy X post}") order(`x1') mtitles( "Traffic" "Traffic" "Traffic") replace booktabs s(fixed yearfe r2_a N, label("Player-Page FE" "Time FE" "adj. \$R^2\$" N )) width(\hsize) staraux

end
