program ddpic

local var `1'

// step 1. run regression and store estimates
run_reg `var' 

// step 2. use estimates to plot chart
make_pic `var'

end


// helper programs

// Step 1. run regression
program run_reg

use ${stash}master, clear

local var `1'

drop if isbaseball != 1
drop if year < 2004

qui xtreg `var' 1.treat##b2008.year, fe vce(robust)

qui parmest, label list(parm estimate min* max* p) saving(${stash}mypars, replace) level(90)

end

// Step 2. make dd figure
program make_pic

local var `1'

clear
use ${stash}mypars, clear

keep if regexm(parm, "1.*treat#20[0-9][0-9].*") == 1
gen year = regexs(1) if regexm(parm, ".*#(20[0-9][0-9])b?\..*")
destring year, replace

drop if year < 2004

qui gen xaxis = 0

local vartitle = "Baseball Players"
local yt = "Mean value / page"

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

drop if year == 2008
graph twoway (scatter estimate year) (rcap max min year,lcolor(navy)), legend(off) title("") xtitle("Wikipedia-Year") ytitle("") yscale(r(-0.2 0.4)) ylabel(-0.1(0.1)0.4) xline(2008, lcolor(gs10)) yline(0, lcolor(gs10))

graph export "${tables}timeline_`var'_1.eps", replace
shell epstopdf  "${tables}timeline_`var'_1.eps"

end
