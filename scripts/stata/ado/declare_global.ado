
program declare_global

global path "/mnt/nfs6/wikipedia.proj/wikibaseball/scripts/stata/"
global lahman "/mnt/nfs6/wikipedia.proj/wikibaseball/rawdata/lahman/"

global basketball "/mnt/nfs6/wikipedia.proj/wikibaseball/rawdata/basketball/"

global rawdata "/mnt/nfs6/wikipedia.proj/wikibaseball/rawdata/"

global stash "/mnt/nfs6/wikipedia.proj/wikibaseball/rawdata/stash/"

global tables "/mnt/nfs6/wikipedia.proj/wikibaseball/scripts/stata/tables/"

global revlist "/mnt/nfs6/wikipedia.proj/wikibaseball/rawdata/wiki/revlist/"

global fe "year"

global top "keep(1.tvar#1.post) star(+ 0.15 * 0.10 ** 0.05 *** 0.01) se ar2 nonotes coeflabels(1.tvar#1.post "TREAT X POST") booktabs order(1.tvar#1.post)  stats(, labels()) nomtitles nocons replace width(\hsize) postfoot(\end{tabular*} }) prefoot("") varwidth(25) eqlabels("") staraux"

global middle "keep(1.tvar#1.post) star(+ 0.15 * 0.10 ** 0.05 *** 0.01) se ar2 nonotes coeflabels(1.tvar#1.post "TREAT X POST") booktabs order(1.tvar#1.post)  stats(, labels()) nomtitles nocons width(\hsize) postfoot(\end{tabular*} }) prefoot("") append collabels(none) prehead(`"{"' `"\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}"' \begin{tabular*}{\hsize}{@{\hskip\tabcolsep\extracolsep\fill}l*{@E}{c}}) nonumbers eqlabels("") staraux"

global end "keep(1.tvar#1.post) star(+ 0.15 * 0.10 ** 0.05 *** 0.01) se ar2 nonotes coeflabels(1.tvar#1.post "TREAT X POST") booktabs order(1.tvar#1.post) s(fixed yearfe N N_g, label("Player FE" "Year FE" N "Clusters")) nomtitles nocons append width(\hsize) nonumbers prehead(`"{"' `"\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}"' \begin{tabular*}{\hsize}{@{\hskip\tabcolsep\extracolsep\fill}l*{@E}{c}}) eqlabels("") staraux"

end
