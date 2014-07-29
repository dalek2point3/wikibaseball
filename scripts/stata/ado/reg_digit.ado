program reg_digit

local ln `1'

use ${stash}master, clear

fvset base 2013 year

est clear

foreach x in `ln'img `ln'text `ln'bd `ln'traf{
    eststo: qui xtreg `x' 1.isbase#1.post i.${fe}, fe cluster(id)
    qui estadd local fixed "Yes"
    qui estadd local sstt "Yes"
}

esttab est4

esttab using "${tables}`ln'digitization.tex", keep(1.isbaseball#1.post) se ar2 nonotes star(+ 0.15 * 0.10 ** 0.05 *** 0.01) coeflabels(1.isbaseball#1.post "Baseball X Post") mtitles("Images" "Text" "Citations" "Traffic") replace booktabs s(fixed sstt r2_a N N_g, label("Player FE" "Decade X Year FEs" "adj. \$R^2\$" N "Clusters")) width(\hsize)

end

