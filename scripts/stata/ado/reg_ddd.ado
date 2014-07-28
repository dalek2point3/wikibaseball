program reg_ddd

local ln `1'

use ${stash}master, clear

local int 1.treat#1.post#1.isbaseball
local x1 1.treat#1.post
local x2 1.isbaseball#1.post

est clear
foreach x in `ln'img `ln'text `ln'bd{
    eststo: qui xtreg `x' `int' `x1' `x2' i.${fe}, fe cluster(id)
    qui estadd local fixed "Yes"
    qui estadd local sstt "Yes"
}

esttab using "${tables}`ln'ddd.tex", keep(`int' `x1' `x2') se ar2 nonotes star(* 0.10 ** 0.05 *** 0.01) coeflabels(`int' "Out-of-Copy X Post X Baseball" `x1' "Out-of-Copy X Post" `x2' "Baseball X Post") mtitles("Images" "Text" "Citations") replace booktabs s(fixed sstt r2_a N N_g, label("Player FE" "Group X Year FEs" "adj. \$R^2\$" N "Clusters")) width(\hsize)

end




