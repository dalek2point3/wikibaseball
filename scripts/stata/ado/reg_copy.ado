program reg_copy

local ln `1'

use ${stash}master, clear

keep if isbaseball == 1

est clear

foreach x in `ln'img `ln'text `ln'bd `ln'traf{
    eststo: qui xtreg `x' 1.treat#1.post i.${fe}, fe cluster(id)
    qui estadd local fixed "Yes"
    qui estadd local sstt "Yes"
}

esttab using "${tables}`ln'copy.tex", keep(1.treat#1.post) se ar2 nonotes star(+ 0.15 * 0.10 ** 0.05 *** 0.01) coeflabels(1.treat#1.post "Out-of-Copy X Post") mtitles("Images" "Text" "Citations" "Traffic") replace booktabs s(fixed sstt r2_a N N_g, label("Player FE" "Decade X Year FEs" "adj. \$R^2\$" N "Clusters")) width(0.99\hsize)

end
