program chart_qual

use ${stash}master, clear

local var `1'
local isbaseball `2'

keep if isbaseball == `isbaseball'


gen tvar = treat

xtreg `var' tvar##post##quality i.$fe, vce(robust) fe level(90)

qui parmest, label list(parm estimate min* max* p) saving(${stash}pars_tmp, replace) level(90)

clear
use ${stash}pars_tmp, clear

keep if regexm(parm, "[0-9].*tvar.*post.*quality") == 1 | parm == "1.tvar#1.post"

drop if estimate == 0

gen quality = regexs(1) if regexm(parm, ".*post.*\#([0-9]+)\.quality")
replace quality = "1" if quality == ""

replace estimate = estimate + estimate[1] if _n > 1
replace max90 = max90 + estimate[1] if _n > 1
replace min90 = min90 + estimate[1] if _n > 1

list quality estimate max min

destring quality, replace

label define qualitylabel 1 "Top 25 pctile" 2 "25-50 pctile" 3 "50-75 pctile" 4 "Bottom 25 pctile"

label values quality qualitylabel

graph twoway (scatter estimate quality) (rcap min max quality), legend(off) title("") xtitle("") xscale(r(0 5)) yline(0, lcolor(gs10)) xlabel(1 "Top 25 pctile" 2 "25-50 pctile" 3 "50-75 pctile" 4 "Bottom 25 pctile")

graph export "${tables}quality_`var'_`isbaseball'.eps", replace

shell epstopdf  "${tables}quality_`var'_`isbaseball'.eps"

end

