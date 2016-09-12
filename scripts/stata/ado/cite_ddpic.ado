program cite_ddpic

use ${stash}citelines, clear

local var `1'

qui xtreg num`var' 1.treat##b2008.year, fe vce(robust)

qui parmest, label list(parm estimate min* max* p) saving(${stash}mypars, replace) level(90)

use ${stash}mypars, clear

keep if regexm(parm, "1.*treat#20[0-9][0-9].*") == 1
gen year = regexs(1) if regexm(parm, ".*#(20[0-9][0-9])b?\..*")
destring year, replace

qui gen xaxis = 0

if "`var'" == "img"{
    local x = "Citations for Image Reuse"
}
else if "`var'" == "text" {
    local x = "Citations in Text"
}

// graph twoway (connected estimate year, msize(small) lpattern(dash) lcolor(edkblue) lwidth(thin)) (line max year, lwidth(vthin) lpattern(-) lcolor(gs8)) (line min year, lwidth(vthin) lpattern(-) lcolor(gs8)) (line xaxis year, lwidth(vthin) lcolor(gs8)), title("`x'") xtitle("") ytitle("Avg. Citations") xlabel(2005(1)2012) legend(off) yscale(range(0(5)15)) ylabel(0(5)15)

graph twoway (scatter estimate year) (rcap max min year, lcolor(navy)), legend(off) title("") xtitle("Wikipedia-Year") ytitle("") yscale(r(0 16)) ylabel(0(5)15) xline(2008, lcolor(gs10)) yline(0, lcolor(gs10))

graph export "${tables}cite_timeline_`var'.eps", replace
shell epstopdf  "${tables}cite_timeline_`var'.eps"

//              , msize(small) lpattern(dash) lcolor(edkblue) lwidth(thin)) (line max year, lwidth(vthin) lpattern(-) lcolor(gs8)) (line min year, lwidth(vthin) lpattern(-) lcolor(gs8)) (line xaxis year, lwidth(vthin) lcolor(gs8)), title("`x'") xtitle("") ytitle("Avg. Citations") xlabel(2005(1)2012) legend(off) yscale(range(0(5)15)) ylabel(0(5)15)

//graph twoway (scatter estimate quality) (rcap min max quality), legend(off) title("") xtitle("") xscale(r(0 5)) yline(0, lcolor(gs10)) xlabel(1 "Top 25 pctile" 2 "25-50 pctile" 3 "50-75 pctile" 4 "Bottom 25 pctile")



end

/*
** ylabel(-0.2 (0.2) 0.8)




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

qui parmest, label list(parm estimate min* max* p) saving(${stash}mypars, replace) level(90)

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
   local vartitle = "Basketball Players"
   local yt = ""
 }

if "`isbaseball'" == "0" & "`var'" == "bd"{
   local vartitle = "Basketball Players (No Citations, see note below)"
   local yt = ""
 }


if "`isbaseball'" == "1"{
   local vartitle = "Baseball Players"
   local yt = "Mean value / page"
 }


if "`var'" == "img" {
    local scale "yscale(range(-0.3 0.8)) ylabel(-0.2 (0.2) 0.8)"
}

if "`var'" == "text" {
    local scale "yscale(range(-350 300)) ylabel(-300 (100) 300)"
}

if "`var'" == "traf" {
    drop if year == 2013
    local scale "yscale(range(-100 50)) ylabel(-100 (25) 50)"
}


graph twoway (connected estimate year, msize(small) lpattern(dash) lcolor(edkblue) lwidth(thin)) (line max year, lwidth(vthin) lpattern(-) lcolor(gs8)) (line min year, lwidth(vthin) lpattern(-) lcolor(gs8)) (line xaxis year, lwidth(vthin) lcolor(gs8)), xtitle("") ytitle("`yt'") xlabel(2005(1)2013) legend(off) title("`vartitle'") `scale'

** ylabel(-0.2 (0.2) 0.8)

graph export "${tables}timeline_`var'_`isbaseball'.eps", replace
shell epstopdf  "${tables}timeline_`var'_`isbaseball'.eps"

end
*/
