program killer_pic

use ${stash}master, clear

keep id isbaseball debut year img firstall

reshape wide img, i(id) j(year)

replace debut = firstall if isbaseball == 1
gen diff = img2013 - img2008

gen before = (debut < 1964)

tabstat diff if isbaseball == 0, by(before) save
matrix stats=r(Stat1)
local bk_meanimgafter =  string(round(stats[1,1],0.001))
matrix stats=r(Stat2)
local bk_meanimgbefore =  string(round(stats[1,1],0.001))

tabstat diff if isbaseball == 1, by(before) save
matrix stats=r(Stat2)
local bb_meanimgbefore =  string(round(stats[1,1],0.001))
matrix stats=r(Stat1)
local bb_meanimgafter =  string(round(stats[1,1],0.001))

gen cutoff = 1963.5
by isbaseball before, sort: egen meangrp = mean(diff)
by isbaseball before, sort: egen segrp = semean(diff)

gen hi = meangrp + segrp
gen lo = meangrp - segrp

by debutyear isbaseball, sort: egen meandiff = mean(diff)
by debutyear isbaseball, sort: drop if _n > 1

// means are : 1.17, .60 (base) and .16 and 0.21
replace meandiff = 0.01 if meandiff == 0

tw (bar meandiff debutyear if debutyear < 1964, barwidth(0.75) color(gs2)) (bar meandiff debutyear if debutyear >= 1964, barwidth(0.75) color(gs8)) (line meangrp debutyear if debutyear < 1964, lcolor(gs8)) (line meangrp debutyear if debutyear >= 1964, lcolor(gs8)) if isbaseball==1,  title("Panel A : Baseball Players") xtitle("Player Debut Appearance Year") ytitle("Images Added After Digitization") xsca(titlegap(3) range(1944 1984) noextend) ysca(titlegap(2) range(-0.2 2.5)) xline(1963.5, noextend lcolor(gs4)) xlabel(1944(4)1984) ylabel(0(0.5)2.5,nogrid) text(-0.15 1948 "Mean Change = `bb_meanimgbefore'", place(e)) text(-0.15 1968 "Mean Change = `bb_meanimgafter'", place(e)) legend(label(1 "`nocopyright' (Before 1964)") label(2 "`incopyright' (After 1964)")) legend(order(1 2))

graph export "${tables}bb_killer.eps", replace

tw (bar meandiff debutyear if debutyear < 1964, barwidth(0.75) color(gs2)) (bar meandiff debutyear if debutyear >= 1964, barwidth(0.75) color(gs8)) (line meangrp debutyear if debutyear < 1964, lcolor(gs8)) (line meangrp debutyear if debutyear >= 1964, lcolor(gs8)) if isbaseball==0,  legend(off) title("Panel B : Basketball Players") xtitle("Player Debut Appearance Year") ytitle("Images Added After Digitization") xsca(titlegap(3) range(1944 1984) noextend) ysca(titlegap(2) range(-0.05 0.5)) xline(1963.5, noextend lcolor(gs4)) xlabel(1944(4)1984) ylabel(0(0.1)0.5,nogrid) text(-0.05 1948 "Mean Change = `bk_meanimgbefore'", place(e)) text(-0.05 1970 "Mean Change = `bk_meanimgafter'", place(e))

graph export "${tables}bk_killer.eps", replace

shell epstopdf "${tables}bb_killer.eps"
shell epstopdf "${tables}bk_killer.eps" 



end
