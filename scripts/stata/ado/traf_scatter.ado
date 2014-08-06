program traf_scatter

use ${stash}master, clear

drop if isbaseball == 0
keep if (year == 2008) | (year == 2013)
 
keep playername debut year img traf everinducted treat id

reshape wide img traf, i(playername) j(year)

split playername, gen(names) parse(" ")
replace names2 = names2 + " " + names3 if names3 != ""
drop names3

gen diffimg = (img2013 - img2008)
gen difftraf = (traf2013 - traf2008)

corr difftraf diffimg 
local corr : di %4.3f r(rho)
corr difftraf diffimg if everinducted == 1
local corrInduct : di %4.3f r(rho)

drop if diffimg > 6
drop if difftraf > 500

tw (scatter difftraf diffimg if debut<1964 & everinducted == 1, msymbol(oh) mcolor(navy) mlabel(names2)) (lfit difftraf diffimg if everinducted == 1, subtitle(correlation `corrInduct')),  xtitle("Change in Images between 2008 and 2011") ytitle("Change in Traffic Between 2008 and 2013") legend(off) xscale(range(0 8)) title (Panel A : Hall of Fame Inductees)

graph export "${tables}traf_scatter_1.eps", replace
shell epstopdf "${tables}traf_scatter_1.eps"

tw (scatter difftraf diffimg if debut<1964, msymbol(x) mcolor(navy)) (lfit difftraf diffimg, subtitle(correlation `corr')), xtitle("Change in Images between 2008 and 2013") ytitle("Change in Traffic Between 2008 and 2013") legend(off) xscale(range(0 8)) title (Panel B : Full Baseball Sample)

graph export "${tables}traf_scatter_2.eps", replace
shell epstopdf "${tables}traf_scatter_2.eps"


end
