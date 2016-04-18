program reg_ddd_appendix

local ln `1'

use ${stash}master, clear

//merge m:1 year isbaseball using ${stash}gtrends, keep(match) nogen

fvset base 2012 year

local int 1.treat#1.post#1.isbaseball
local x1 1.treat#1.post
local x2 1.isbaseball#1.post

est clear

foreach x in `ln'bd `ln'img `ln'text{

    eststo: qui xtreg `x' `x2' i.$fe, fe cluster(id)
    qui estadd local fixed "Yes"
    qui estadd local sstt "Year"


}

foreach x in `ln'bd `ln'img `ln'text{

    eststo: qui xtreg `x' `int' `x1' `x2' i.$fe, fe cluster(id)
    qui estadd local fixed "Yes"
    qui estadd local sstt "Year"


}

esttab using "${tables}appendix_`ln'ddd.tex", keep(`int' `x1' `x2') se ar2 nonotes star(+ 0.15 * 0.10 ** 0.05 *** 0.01) coeflabels(`int' "\emph{out-of-copy X post X baseball}" `x1' "\emph{out-of-copy X post}" `x2' "\emph{baseball X post}") order(`int' `x2' `x1') mgroups("Digitization DD" "Copyright DDD", pattern(1 0 0 1 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) mtitles( "Citations" "Images" "Text" "Citations" "Images" "Text") replace nonumbers booktabs s(fixed sstt r2_a N N_g, label("Player FE" "Time FE" "adj. \$R^2\$" N "Clusters")) width(\hsize) staraux

end




