// digitization DD with basketball data
program reg_dd_appendix

use ${stash}master, clear

fvset base 2012 year

local int 1.treat#1.post#1.isbaseball
local x1 1.treat#1.post
local x2 1.isbaseball#1.post

est clear

foreach x in bd img text{

    eststo: qui xtreg `x' `x2' i.$fe, fe cluster(id)
    qui estadd local fixed "Yes"
    qui estadd local sstt "Year"

}

esttab using "${tables}appendix_dd.tex", keep(`x2') se ar2 nonotes star(+ 0.15 * 0.10 ** 0.05 *** 0.01) coeflabels(`x2' "\emph{baseball X post}") order(`x2') mgroups("Digitization DD", pattern(1 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) mtitles( "Citations" "Images" "Text") replace nonumbers booktabs s(fixed sstt r2_a N N_g, label("Player FE" "Time FE" "adj. \$R^2\$" N "Clusters")) width(\hsize) staraux

end




