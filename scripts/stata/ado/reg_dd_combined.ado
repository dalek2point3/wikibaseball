program reg_dd_combined

local var1 `1'
local var2 `2'
local startyear `3'
local endyear `4'
local postyear `5'

local x1 1.treat#1.post

// 1. Sample A diff-in-diff
est clear
use ${stash}citelines, clear
fvset base 2009 year
drop if year<`startyear' | year > `endyear'
replace post = (year>=`postyear')

eststo: qui reg `var1' `x1' i.${fe}, cluster(citeyear)
qui estadd local fixed "No"
qui estadd local yearfe "Yes"
qui estadd local agefe "---"

eststo: qui xtreg `var1' `x1' i.${fe}, cluster(citeyear) fe
qui estadd local fixed "Yes"
qui estadd local yearfe "Yes"
qui estadd local agefe "---"

gen ln`var1'=ln(`var1'+1)
eststo: qui xtreg ln`var1' `x1' i.${fe}, cluster(citeyear) fe
qui estadd local fixed "Yes"
qui estadd local yearfe "Yes"
qui estadd local agefe "---"

// 2. Sample B diff-in-diff

use ${stash}master, clear
fvset base 2009 year

drop if year<`startyear' | year > `endyear'
replace post = (year>=`postyear')

// make age into factor var
egen ageid = group(age)

eststo: qui reg `var2' `x1' i.${fe} i.ageid if isb==1, vce(robust)
qui estadd local fixed "No"
qui estadd local yearfe "Yes"
qui estadd local agefe "Yes"


eststo: qui xtreg `var2' `x1' i.${fe} i.ageid if isb==1, fe vce(cluster playerid)
qui estadd local fixed "Yes"
qui estadd local yearfe "Yes"
qui estadd local agefe "Yes"

eststo: qui xtreg ln`var2' `x1' i.${fe} i.ageid if isb==1, fe vce(cluster playerid)
qui estadd local fixed "Yes"
qui estadd local yearfe "Yes"
qui estadd local agefe "Yes"

// 3. Write table to Latex

esttab using "${tables}reg_dd_combined_`startyear'_`endyear'_`postyear'.tex", keep(`x1') se ar2 nonotes star(* 0.10 ** 0.05 *** 0.01) coeflabels(`x1' "\emph{out-of-copy X post}") order(`x1') replace booktabs s(fixed yearfe agefe r2_a N, label("Unit of Obs. FE" "Year FE" "Page-Age FE" "adj. \$R^2\$" N )) width(\hsize) staraux mgroups("Sample A" "Sample B", pattern(1 0 0 1 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) mtitles("Cites" "Cites" "Log-Cites" "Cites" "Cites" "Log-Cites") nonum


end
