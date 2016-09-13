program ivest

use $stash/master, clear
keep if isbaseball == 1

gen instrument = post*treat
gen inducted_i = (everinducted == 1)

gen careerlength = finalyear - debutyear
gen ageatdebut = debutyear - birthyear
tabulate year, gen(ytmp)

local controls "inducted_i ageatdebut careerlength"
label variable traf "Traffic"
label variable img "Images"
label variable treat "Out-of-Copy"
label variable instrument "Out-Of-Copy. X Post"

est clear
eststo: reg traf img ytmp5-ytmp13 `controls', clust(id)
estadd local covar "Yes" 
estadd local yearfe "Yes" 

eststo: xtreg traf img ytmp5-ytmp13, fe clust(id)
estadd local covar "Player FE" 
estadd local yearfe "Yes" 

eststo: ivreg2 traf (img=instrument) ytmp5-ytmp13, small savefirst savefprefix(first) clust(id)
mat first=e(first)
local FStat = round(first[3,1],0.01)
estadd local FStat `FStat'  : firstimg
estadd local covar "Yes" : firstimg
estadd local covar "Yes" 
estadd local yearfe "Yes" : firstimg
estadd local yearfe "Yes" 

 eststo: xtivreg2 traf (img=instrument) ytmp5-ytmp13, fe small savefirst savefprefix(firstcontrol) clust(id) ffirst
mat first=e(first)
local FStat = round(first[3,1],0.01)
estadd local FStat `FStat'  : firstcontrolimg
estadd local covar "Player FE" : firstcontrolimg 
estadd local covar "Player FE" 
estadd local yearfe "Yes" : firstcontrolimg
estadd local yearfe "Yes" 

**local note1 "Standard errors clustered at player level are reported"
**local note2 "* p $<$ 0.10, ** p $<$ 0.05, *** p $<$ 0.01"

esttab est1 est2 firstimg firstc* est3 est4 using ${tables}mechanism.tex, drop(_cons `controls' *ytmp*) se stats(covar yearfe N r2 FStat,labels("Controls" "Year FE" "N" "adj. \$R^2\$" "F-Stat")) label replace mgroups("OLS" "First Stage" "IV Estimates", pattern(1 0 1 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) booktabs  addnote("`note1'" "`note2'") nonotes star(+ 0.15 * 0.10 ** 0.05 *** 0.01)

end
