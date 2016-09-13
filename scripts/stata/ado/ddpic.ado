program ddpic

local var `1'
<<<<<<< HEAD

// step 1. run regression and store estimates
run_reg `var' 

// step 2. use estimates to plot chart
make_pic `var'
=======
local isbaseball `2'

run_reg `var' `isbaseball'

make_pic `var' `isbaseball'
>>>>>>> 5cb8b96e4d01968e78d3274c1a7f003e6a5352f5

end


<<<<<<< HEAD
// helper programs

// Step 1. run regression
=======
>>>>>>> 5cb8b96e4d01968e78d3274c1a7f003e6a5352f5
program run_reg

use ${stash}master, clear

local var `1'
<<<<<<< HEAD

drop if isbaseball != 1
=======
local isbaseball `2'

drop if isbaseball != `isbaseball'
>>>>>>> 5cb8b96e4d01968e78d3274c1a7f003e6a5352f5
drop if year < 2004

qui xtreg `var' 1.treat##b2008.year, fe vce(robust)

qui parmest, label list(parm estimate min* max* p) saving(${stash}mypars, replace) level(90)

end

<<<<<<< HEAD
// Step 2. make dd figure
program make_pic

local var `1'
=======
program make_pic

local var `1'
local isbaseball `2'
>>>>>>> 5cb8b96e4d01968e78d3274c1a7f003e6a5352f5

clear
use ${stash}mypars, clear

keep if regexm(parm, "1.*treat#20[0-9][0-9].*") == 1
gen year = regexs(1) if regexm(parm, ".*#(20[0-9][0-9])b?\..*")
destring year, replace

drop if year < 2004

qui gen xaxis = 0

<<<<<<< HEAD
local vartitle = "Baseball Players"
local yt = "Mean value / page"
=======
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

>>>>>>> 5cb8b96e4d01968e78d3274c1a7f003e6a5352f5

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

<<<<<<< HEAD
drop if year == 2008
graph twoway (scatter estimate year) (rcap max min year,lcolor(navy)), legend(off) title("") xtitle("Wikipedia-Year") ytitle("") yscale(r(-0.2 0.4)) ylabel(-0.1(0.1)0.4) xline(2008, lcolor(gs10)) yline(0, lcolor(gs10))

graph export "${tables}timeline_`var'_1.eps", replace
shell epstopdf  "${tables}timeline_`var'_1.eps"
=======

// graph twoway (connected estimate year, msize(small) lpattern(dash) lcolor(edkblue) lwidth(thin)) (line max year, lwidth(vthin) lpattern(-) lcolor(gs8)) (line min year, lwidth(vthin) lpattern(-) lcolor(gs8)) (line xaxis year, lwidth(vthin) lcolor(gs8)), xtitle("") ytitle("`yt'") xlabel(2005(1)2013) legend(off) title("") `scale'

** ylabel(-0.2 (0.2) 0.8)
drop if year == 2008
graph twoway (scatter estimate year) (rcap max min year,lcolor(navy)), legend(off) title("") xtitle("Wikipedia-Year") ytitle("") yscale(r(-0.2 0.4)) ylabel(-0.1(0.1)0.4) xline(2008, lcolor(gs10)) yline(0, lcolor(gs10))


graph export "${tables}timeline_`var'_`isbaseball'.eps", replace
shell epstopdf  "${tables}timeline_`var'_`isbaseball'.eps"
>>>>>>> 5cb8b96e4d01968e78d3274c1a7f003e6a5352f5

end
