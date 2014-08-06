program killer_pic2

use ${stash}master, clear

local decay 0.999
local mode `1'

keep if isbaseball == `mode'
keep id isbaseball debut year img finalyear

reshape wide img, i(id) j(year)

gen diff = img2013 - img2008
gen percent = (1964 - debut) / (finaly - debut)
replace percent = 1 if percent <= 0
replace percent = 1 if percent >= 1

gen before = (debut < 1964)

gen cutoff = 1963.5

by debutyear, sort: egen meanpct = mean(percent)
by debutyear, sort: egen meangrp = mean(diff)
by debutyear, sort: drop if _n > 1

gen meandiff = meangrp / meanpct

replace meanpct = 0.001 if debutyear>=1964
replace meanpct = meanpct * -1
replace meanpct = meanpct - 0.5


tw (bar meandiff debutyear if debutyear < 1964, barwidth(0.75) color(gs2)) (bar meandiff debutyear if debutyear >= 1964, barwidth(0.75) color(gs8)),  title("") xtitle("Player Debut Appearance Year") ytitle("Images Added Between 2008-2013 (Rescaled)") xsca(titlegap(3) range(1944 1984) noextend) ysca(axis(1) titlegap(2) range(-0.2 2.5)) xline(1963.5, noextend lcolor(gs4)) xlabel(1944(4)1984) ylabel(0(0.5)5,nogrid) legend(off)

//text(-0.5 1948 "Percent In-Copyright", place(e)) legend(off)


/*tw (bar meandiff debutyear if debutyear < 1964, barwidth(0.75) color(gs2)) (bar meandiff debutyear if debutyear >= 1964, barwidth(0.75) color(gs8)) (line meanpct debutyear, color(gs1)),  title("Change in Images for Baseball Players (Rescaled)") xtitle("Player Debut Appearance Year") ytitle("Images Added After Digitization (Rescaled)") xsca(titlegap(3) range(1944 1984) noextend) ysca(axis(1) titlegap(2) range(-0.2 2.5)) ysca(axis(1) titlegap(2) range(-1 0.1)) xline(1963.5, noextend lcolor(gs4)) xlabel(1944(4)1984) ylabel(0(0.5)5,nogrid)  text(-0.5 1948 "Percent In-Copyright", place(e)) legend(off)

legend(label(1 "`nocopyright' (Before 1964)") label(2 "`incopyright' (After 1964)")) legend(order(1 2))*/

graph export "${tables}killerpic2_`mode'.eps", replace
shell epstopdf "${tables}killerpic2_`mode'.eps" 

end
