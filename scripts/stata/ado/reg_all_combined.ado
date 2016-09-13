program reg_all_combined

local symbol "$\bar{y}$="
local box "\makebox[13em][l]{\underline{\textbf{"
local mode "combined"
local lab "out-of-copy X post"

local end "keep(1.tvar#1.post) star(+ 0.15 * 0.10 ** 0.05 *** 0.01) se ar2 nonotes coeflabels(1.tvar#1.post "\emph{`lab'}") booktabs order(1.tvar#1.post) stats(fixed yearfe, label("Unit of Obs. FE" "Time FE" )) nomtitles nocons append width(\hsize) nonumbers prehead(`"{"' `"\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi}"' \begin{tabular*}{\hsize}{@{\hskip\tabcolsep\extracolsep\fill}l*{@E}{c}}) eqlabels("") staraux varwidth(50)"


/* make_data `mode' */
/* run_reg `ln'bd */
/* local meanline "\vspace{5mm} (`symbol'$meanvar)" */
/* esttab using "${tables}`ln'`mode'.tex", ${top} posthead("\midrule `box'Panel A: Citations}} `meanline'}\\")  */

make_data_cite
run_reg numimg citeyear
local meanline "\vspace{5mm} (`symbol'$meanvar)"
esttab using "${tables}`ln'`mode'.tex", ${top} posthead("\midrule `box'Sample A : Images}} `meanline'}\\") 
    
make_data_cite
run_reg numtext citeyear
local meanline "\vspace{5mm} (`symbol'$meanvar)"
esttab using "${tables}`ln'`mode'.tex",   ${middle} posthead("\midrule \vspace{5mm} `box'Sample A : Text}}`meanline'}\\")


make_data 
run_reg `ln'img playerid
local meanline "\vspace{5mm} (`symbol'$meanvar)"
esttab using "${tables}`ln'`mode'.tex",  ${middle} posthead("\midrule \vspace{5mm} `box'Sample B : Images}}`meanline'}\\")

make_data 
run_reg `ln'text playerid
local meanline "\vspace{5mm} (`symbol'$meanvar)"
esttab using "${tables}`ln'`mode'.tex",   `end' posthead("\midrule \vspace{5mm} `box'Sample B : Text}}`meanline'}\\")

end


program save_mean

local var `1'
qui tabstat `var', save
matrix stats=r(StatTotal)
global meanvar=round(stats[1,1],0.01)
global meanvar : di %3.2f $meanvar

di "jsut saved $meanvar"

end


program make_data_cite
use ${stash}citelines, clear
fvset base 2012 year
gen tvar = treat
table_set "out-of-copy X post" "Unit of Obs."
end


program make_data
use ${stash}master, clear
fvset base 2012 year
drop if isbaseball == 0
gen tvar = treat
drop lnimg lntext
table_set "out-of-copy X post" "Unit of Obs."

end

program run_reg

est clear
local x `1'

save_mean `x'
local unit `2'
eststo: qui reg `x' 1.tvar#1.post i.${fe}, cluster(`unit')
qui estadd local fixed "No"
qui estadd local yearfe "Year"

eststo: qui xtreg `x' 1.tvar#1.post i.${fe}, cluster(`unit') fe
qui estadd local fixed "Yes"
qui estadd local yearfe "Year"

gen ln`x'=ln(`x'+1)
eststo: qui xtreg ln`x' 1.tvar#1.post i.${fe}, cluster(`unit') fe
qui estadd local fixed "Yes"
qui estadd local yearfe "Year"

end
