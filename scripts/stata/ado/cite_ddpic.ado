// creates time-trends chart using Sample A data, for cites, images and text

program cite_ddpic

use ${stash}citelines, clear

local var `1'

qui xtreg num`var' 1.treat##b2008.year, fe vce(cluster citeyear)

qui parmest, label list(parm estimate min* max* p) saving(${stash}mypars, replace) level(90)

use ${stash}mypars, clear

keep if regexm(parm, "1.*treat#20[0-9][0-9].*") == 1
gen year = regexs(1) if regexm(parm, ".*#(20[0-9][0-9])b?\..*")
destring year, replace

qui gen xaxis = 0

graph twoway (scatter estimate year) (rcap max min year, lcolor(navy)), legend(off) title("") xtitle("Wikipedia-Year") ytitle("") yscale(r(0 16)) ylabel(0(5)15) xline(2008, lcolor(gs10)) yline(0, lcolor(gs10))

graph export "${tables}cite_timeline_`var'.eps", replace
shell epstopdf  "${tables}cite_timeline_`var'.eps"

end
