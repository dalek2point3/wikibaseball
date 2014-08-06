program reg_ddd

local ln `1'

use ${stash}master, clear

fvset base 2013 year

local int 1.treat#1.post#1.isbaseball
local x1 1.treat#1.post
local x2 1.isbaseball#1.post

est clear
foreach x in `ln'bd `ln'img `ln'text{
    eststo: qui xtreg `x' `int' `x1' `x2' i.${fe}, fe cluster(id)
    qui estadd local fixed "Yes"
    qui estadd local sstt "Yes"
}

esttab using "${tables}`ln'ddd.tex", keep(`int' `x1' `x2') se ar2 nonotes star(+ 0.15 * 0.10 ** 0.05 *** 0.01) coeflabels(`int' "Out-of-Copy X Post X Baseball" `x1' "Out-of-Copy X Post" `x2' "Baseball X Post") mtitles( "Citations" "Images" "Text") replace booktabs s(fixed sstt r2_a N N_g, label("Player FE" "Year FE" "adj. \$R^2\$" N "Clusters")) width(\hsize) staraux

end




