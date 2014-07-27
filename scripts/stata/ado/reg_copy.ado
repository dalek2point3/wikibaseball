program reg_copy

use ${stash}master, clear

keep if isbaseball == 1

est clear

foreach x in lnimg lntext lnbd{
    eststo: qui xtreg `x' 1.treat#1.post i.sstt, fe cluster(id)
    qui estadd local fixed "Yes"
    qui estadd local sstt "Yes"
}

esttab using "${tables}copy.tex", keep(1.treat#1.post) se ar2 nonotes star(* 0.10 ** 0.05 *** 0.01) coeflabels(1.treat#1.post "Out-of-Copy X Post") mtitles("Images" "Text" "Citations") replace booktabs s(fixed sstt r2_a N N_g, label("Player FE" "Group X Year FEs" "adj. \$R^2\$" N "Clusters")) width(0.75\hsize)

end
