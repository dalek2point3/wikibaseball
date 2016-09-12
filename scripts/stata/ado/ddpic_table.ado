program ddpic_table

use ${stash}citelines, clear

est clear
foreach x in cite img text{
qui eststo: xtreg num`x' 1.treat##b2008.year, fe vce(robust)
estadd local fixed "Yes"
estadd local sstt "Year"
}

use ${stash}master, clear
fvset base 2009 year
drop if year < 2004 | year > 2012

foreach x in bd img text{
qui eststo: xtreg `x' 1.treat##b2008.year, fe vce(robust)
estadd local fixed "Yes"
estadd local sstt "Year"
}

esttab  using "${tables}`ln'leads-lags.tex", drop(1o.treat _cons 2008b.year 1o.treat#2008b.year 2004.year 1.treat#2004.year ) coeflabels(2005.year "\$Digitization_{-3}\$" 2006.year "\$Digitization_{-2}\$" 2007.year "\$Digitization_{-1}\$" 2009.year "\$Digitization_{+1}\$" 2010.year "\$Digitization_{+2}\$" 2011.year "\$Digitization_{+3}\$" 2012.year "\$Digitization_{+4}\$" 1.treat#2005.year "\$Digitization_{-3}\$ x out-of-copy"  1.treat#2006.year "\$Digitization_{-2}\$ x out-of-copy"  1.treat#2007.year "\$Digitization_{-1}\$ x out-of-copy"  1.treat#2009.year "\$Digitization_{+1}\$ x out-of-copy"  1.treat#2010.year "\$Digitization_{+2}\$ x out-of-copy"  1.treat#2011.year "\$Digitization_{+3}\$ x out-of-copy" 1.treat#2012.year "\$Digitization_{+4}\$ x out-of-copy") se ar2 nonotes star(+ 0.15 * 0.10 ** 0.05 *** 0.01) replace booktabs s(fixed sstt r2_a N, label("Player FE" "Time FE" "adj. \$R^2\$" N)) width(\hsize) staraux b(3) subs("_" "_") nonum mgroups("Sample A" "Sample B", pattern(1 0 0 1 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) mtitles("Citations" "Images" "Text" "Citations" "Images" "Text")

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
