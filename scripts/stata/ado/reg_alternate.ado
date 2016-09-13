program reg_alternate

local endyear `1'
local startyear `2'
local postyear `3'

di `postyear' `startyear' `endyear'

use ${stash}citelines, clear
fvset base 2007 year

est clear
replace post = year >=`postyear'
keep if year <= `endyear'
keep if year >= `startyear'

tab year post

foreach x in cite img text{
    eststo: qui xtreg num`x' 1.post#1.treat i.year, fe vce(cluster citeyear)
    qui estadd local fixed "Yes"
    qui estadd local sstt "Year"
}

use ${stash}master, clear
fvset base 2007 year
drop if isbaseball==0
replace post = year >=`postyear'
keep if year <= `endyear'
keep if year >= `startyear'

foreach x in bd img text{
    eststo: qui xtreg bd 1.post#1.treat i.year, fe vce(cluster playerid)
    qui estadd local fixed "Yes"
    qui estadd local sstt "Year"
}

esttab using "${tables}appendix_alternate_`endyear'_`startyear'_`postyear'.tex", keep(1.post#1.treat) se ar2 nonotes star(* 0.10 ** 0.05 *** 0.01) coeflabels(1.post#1.treat "\emph{out-of-copy X post}") mgroups("Sample A" "Sample B", pattern(1 0 0 1 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) mtitles( "Citations" "Images" "Text" "Citations" "Images" "Text") replace nonumbers booktabs s(fixed sstt r2_a N, label("Player FE" "Time FE" "adj. \$R^2\$" N)) width(\hsize) staraux

end
