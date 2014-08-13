program chart_qual

use ${stash}master, clear

local isbaseball `1'
local isbaseball "1"

local var img
keep if isbaseball == `isb'

gen tvar = treat

xtreg `var' tvar##post##quality i.$fe, vce(robust) fe level(90)

qui parmest, label list(parm estimate min* max* p) saving(${stash}pars_tmp, replace) level(90)

clear
use ${stash}pars_tmp, clear

keep if regexm(parm, "[0-9].*tvar.*post.*quality") == 1
drop if estimate == 0

gen quality = regexs(1) if regexm(parm, ".*post.*\#([0-9]+)\.quality")
list quality estimate max min


gen xaxis = 0
destring quality, replace

graph twoway (bar estimate quality, msize(small) lpattern(solid) lcolor(edkblue) lwidth(thin) barwidth(0.08)) (rcap min max quality) (line xaxis quality), legend(off) title("") xtitle("")

graph export "${tables}quality_`var'_`isbaseball'.eps", replace

shell epstopdf  "${tables}quality_`var'_`isbaseball'.eps"

end

