// this program estimates impact of copyright on traffic in a cross-sectional framework
program robust_traf

use ${stash}master, clear

drop if isb == 0

gen percent = (1964 - debut) / (finaly - debut)
replace percent = 0 if percent <= 0
replace percent = 1 if percent >= 1

keep playername debut year img traf everinducted treat id numallstar percent

reshape wide img traf, i(playername) j(year)

gen diffimg = (img2012 - img2008)
gen difftraf = (traf2012 - traf2008)

replace difftraf = 0 if difftraf < 0
replace diffimg = 0 if diffimg < 0

gen lnt = ln(difftraf+1)
gen lni = ln(diffimg+1)

label variable diffimg "Diff. Img"
label variable lni "Log Diff. Img."
label variable difftraf "Diff. Traf"
label variable lnt "Log Diff. Traf"
label variable percent "Out-of-copy Exposure"

est clear
eststo: reg diffimg percent, robust
eststo: reg lni percent, robust
eststo: reg difftraf percent, robust
eststo: reg lnt percent, robust

esttab, keep(percent) p label

esttab using "${tables}robust_traf.tex", se ar2 nonotes star(+ 0.15 * 0.10 ** 0.05 *** 0.01) replace booktabs width(\hsize) staraux label

end


