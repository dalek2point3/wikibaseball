program reg_ddd

use ${stash}master, clear

local int 1.treat#1.post#1.isbaseball

est clear
foreach x in lnimg lntext lnbd{
    eststo: qui xtreg `x' `int' i.${fe}, fe cluster(id)
    qui estadd local fixed "Yes"
    qui estadd local sstt "Yes"
}

esttab using "${tables}ddd.tex", keep(`int') se ar2 nonotes star(* 0.10 ** 0.05 *** 0.01) coeflabels(`int' "Out-of-Copy X Post X Baseball") mtitles("Images" "Text" "Citations") replace booktabs s(fixed sstt r2_a N N_g, label("Player FE" "Group X Year FEs" "adj. \$R^2\$" N "Clusters")) width(\hsize)

end
