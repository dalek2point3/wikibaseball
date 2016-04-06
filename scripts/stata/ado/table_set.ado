program table_set

local var `1'
local unitname `2'

local varname "\emph{`var'}"
local keepvar "1.tvar#1.post"

global top "keep(`keepvar') star(+ 0.15 * 0.10 ** 0.05 *** 0.01) se ar2 nonotes coeflabels(`keepvar' "`varname'") booktabs order(`keepvar')  stats(, labels()) mtitles("OLS" "OLS" "Log-OLS") nonumbers nocons replace width(\hsize) postfoot(\end{tabular*} }) prefoot("") varwidth(50) eqlabels("") staraux"

global middle "keep(1.tvar#1.post) star(+ 0.15 * 0.10 ** 0.05 *** 0.01) se ar2 nonotes coeflabels(`keepvar' "`varname'") booktabs order(`keepvar')  stats(, labels()) nomtitles nocons width(\hsize) postfoot(\end{tabular*} }) prefoot("") append collabels(none) prehead(`"{"' `"\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}"' \begin{tabular*}{\hsize}{@{\hskip\tabcolsep\extracolsep\fill}l*{@E}{c}}) nonumbers eqlabels("") staraux varwidth(50)" 

//global end "keep(`keepvar') star(+ 0.15 * 0.10 ** 0.05 *** 0.01) se ar2 nonotes coeflabels(`keepvar' "`varname'") booktabs order(`keepvar') stats(fixed yearfe N r2_a N_g, label("Player FE" "Time FE" N "Adj R-square" "Clusters")) nomtitles nocons append width(\hsize) nonumbers prehead(`"{"' `"\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}"' \begin{tabular*}{\hsize}{@{\hskip\tabcolsep\extracolsep\fill}l*{@E}{c}}) eqlabels("") staraux varwidth(50)"

global end "keep(`keepvar') star(+ 0.15 * 0.10 ** 0.05 *** 0.01) se ar2 nonotes coeflabels(`keepvar' "`varname'") booktabs order(`keepvar') stats(fixed yearfe N r2_a, label("`unitname' FE" "Time FE" N "Adj R-square")) nomtitles nocons append width(\hsize) nonumbers prehead(`"{"' `"\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}"' \begin{tabular*}{\hsize}{@{\hskip\tabcolsep\extracolsep\fill}l*{@E}{c}}) eqlabels("") staraux varwidth(50)"

end
