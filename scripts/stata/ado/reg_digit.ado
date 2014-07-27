program reg_digit

use ${stash}master, clear

est clear

foreach x in lnimg lntext lnbd{
    eststo: qui xtreg `x' 1.isbase#1.post i.${fe}, fe cluster(id)
    qui estadd local fixed "Yes"
    qui estadd local sstt "Yes"
}

esttab using "${tables}digitization.tex", keep(1.isbaseball#1.post) se ar2 nonotes star(* 0.10 ** 0.05 *** 0.01) coeflabels(1.isbaseball#1.post "Baseball X Post") mtitles("Images" "Text" "Citations") replace booktabs s(fixed sstt r2_a N N_g, label("Player FE" "Decade X Year FEs" "adj. \$R^2\$" N "Clusters")) width(\hsize)

end

