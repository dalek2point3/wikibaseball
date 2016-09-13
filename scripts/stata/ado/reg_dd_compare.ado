program reg_dd_compare

local var1 `1'
local var2 `2'

local x1 1.treat#1.post

est clear
use ${stash}citelines, clear
fvset base 2012 year

// Loop over, once each for images and text
foreach x in `var1' `var2' {
 eststo: qui reg `x' `x1' i.${fe}, cluster(citeyear)
 qui estadd local fixed "No"
 qui estadd local yearfe "Yes"

 eststo: qui xtreg `x' `x1' i.${fe}, cluster(citeyear) fe
 qui estadd local fixed "Yes"
 qui estadd local yearfe "Yes"

 gen ln`x'=ln(`x'+1)
 eststo: qui xtreg ln`x' `x1' i.${fe}, cluster(citeyear) fe
 qui estadd local fixed "Yes"
 qui estadd local yearfe "Yes"
}

// write Latex table

esttab using "${tables}reg_dd_compare.tex", keep(`x1') se ar2 nonotes star(+ 0.15 * 0.10 ** 0.05 *** 0.01) coeflabels(`x1' "\emph{out-of-copy X post}") order(`x1') replace booktabs s(fixed yearfe r2_a N, label("Publication-Year FE" "Year FE" "adj. \$R^2\$" N )) width(\hsize) staraux mgroups("Images" "Text", pattern(1 0 0 1 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) mtitles("OLS" "OLS" "Log-OLS" "OLS" "OLS" "Log-OLS") nonum


end
