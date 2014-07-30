program ddpic

local var `1'
local isbaseball `2'

run_reg `var' `isbaseball'

make_pic `var' `isbaseball'

end


program run_reg

use ${stash}master, clear

local var `1'
local isbaseball `2'

drop if isbaseball != `isbaseball'

qui xtreg `var' 1.treat##b2008.year, fe vce(robust)

qui parmest, label list(parm estimate min* max* p) saving(${stash}mypars, replace)

end

program make_pic

local var `1'
local isbaseball `2'

clear
use ${stash}mypars, clear

keep if regexm(parm, "1.*treat#20[0-9][0-9].*") == 1
gen year = regexs(1) if regexm(parm, ".*#(20[0-9][0-9])b?\..*")
destring year, replace

drop if year < 2005

qui gen xaxis = 0

if "`isbaseball'" == "0"{
   local vartitle = "Basketball"
   local yt = ""
 }

if "`isbaseball'" == "1"{
   local vartitle = "Baseball"
   local yt = "Mean value / page"
 }

graph twoway (connected estimate year, msize(small) lpattern(dash) lcolor(edkblue) lwidth(thin)) (line max year, lwidth(vthin) lpattern(-) lcolor(gs8)) (line min year, lwidth(vthin) lpattern(-) lcolor(gs8)) (line xaxis year, lwidth(vthin) lcolor(gs8)), xtitle("") ytitle("`yt'") xlabel(2005(1)2013) legend(off) title("`vartitle' Players")

** ylabel(-0.2 (0.2) 0.8)

graph export "${tables}timeline_`var'_`isbaseball'.eps", replace
shell epstopdf  "${tables}timeline_`var'_`isbaseball'.eps"

end
