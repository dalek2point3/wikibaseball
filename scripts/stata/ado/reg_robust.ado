<<<<<<< HEAD
// this program implements four different robustness checks
program reg_robust

local mode `1'
local meanline "\vspace{5mm}\\"

// Define a "top", which codes the Latex syntax for the top line
local keepvar "1.tvar#1.post"
local varname "\emph{out-of-copy X post}"
local top "keep(`keepvar') star(+ 0.15 * 0.10 ** 0.05 *** 0.01) se ar2 nonotes coeflabels(`keepvar' "`varname'") booktabs order(`keepvar')  stats(, labels()) mtitles("(1)" "(2)" "(3)" "(4)" ) nonumbers nocons replace width(\hsize) postfoot(\end{tabular*} }) prefoot("") varwidth(50) eqlabels("") staraux"


make_data `mode'
run_robust bd
esttab using "${tables}`mode'_robust.tex", `top' posthead("\midrule \underline{\textbf{Panel A: Citations}} `meanline'") 
=======
program reg_robust

local mode `1'
local ln `2'

local meanline "\vspace{5mm}\\"

// define my own top
local keepvar "1.tvar#1.post"
local varname "\emph{out-of-copy X post}"
local top "keep(`keepvar') star(+ 0.15 * 0.10 ** 0.05 *** 0.01) se ar2 nonotes coeflabels(`keepvar' "`varname'") booktabs order(`keepvar')  stats(, labels()) mtitles("(1)" "(2)" "(3)" "(4)" ) nonumbers nocons replace width(\hsize) postfoot(\end{tabular*} }) prefoot("") varwidth(50) eqlabels("") staraux"
//mtitles ("No-Overlap" "Alt. Definition" "Drop Well-Known" "Alt. Depvar")

make_data `mode'
run_robust `ln'bd
**local meanline "\vspace{5mm} ($\mu$=$meanvar)\\"
esttab using "${tables}`ln'`mode'_robust.tex", `top' posthead("\midrule \underline{\textbf{Panel A: Citations}} `meanline'") 
>>>>>>> 5cb8b96e4d01968e78d3274c1a7f003e6a5352f5


make_data `mode'
run_robust `ln'img
<<<<<<< HEAD
esttab using "${tables}`mode'_robust.tex",  ${middle} posthead("\midrule \vspace{5mm} \underline{\textbf{Panel B : Images}}\hphantom{ons}`meanline'")

make_data `mode'
run_robust `ln'text
esttab using "${tables}`mode'_robust.tex",   ${end} posthead("\midrule \vspace{5mm} \underline{\textbf{Panel C : Text}}\hphantom{ations}`meanline'")

end

// helper programs

// makes relevant data for particular robustness check
=======
**local meanline "\vspace{5mm} ($\mu$=$meanvar)\\"
esttab using "${tables}`ln'`mode'_robust.tex",  ${middle} posthead("\midrule \vspace{5mm} \underline{\textbf{Panel B : Images}}\hphantom{ons}`meanline'")

make_data `mode'
run_robust `ln'text
**local meanline "\vspace{5mm} ($\mu$=$meanvar)\\"
esttab using "${tables}`ln'`mode'_robust.tex",   ${end} posthead("\midrule \vspace{5mm} \underline{\textbf{Panel C : Text}}\hphantom{ations}`meanline'")

end


program save_mean

local var `1'
qui tabstat `var', save
matrix stats=r(StatTotal)
global meanvar=round(stats[1,1],0.01)
global meanvar : di %3.2f $meanvar

di "jsut saved $meanvar"

end

>>>>>>> 5cb8b96e4d01968e78d3274c1a7f003e6a5352f5
program make_data

local mode `1'

use ${stash}master, clear
fvset base 2012 year
drop if year < 2004

if "`mode'" == "digit" {
    gen tvar = isbaseball
    table_set "out-of-copy X post"
}

if "`mode'" == "copy" {
    drop if isbaseball == 0
    gen tvar = treat
    table_set "out-of-copy X post"
}

end

<<<<<<< HEAD
// run regressions for robustness checks

=======
>>>>>>> 5cb8b96e4d01968e78d3274c1a7f003e6a5352f5
program run_robust

est clear
local x `1'

<<<<<<< HEAD
replace bd = (bd>0)

// a) check 1: drop overlapping players
=======
save_mean `x'
replace bd = (bd>0)

// TODO: add later
// a) log model
**eststo: qui xtreg ln`x' 1.tvar#1.post i.${fe}, fe cluster(id)
**qui estadd local fixed "Yes"
**qui estadd local yearfe "Year"

// b) no overlap
>>>>>>> 5cb8b96e4d01968e78d3274c1a7f003e6a5352f5
gen overlap = !((debut > 1963) | (final < 1964))
eststo: qui xtreg `x' 1.tvar#1.post i.${fe} if overlap==0, fe cluster(id)
qui estadd local fixed "Yes"
qui estadd local yearfe "Year"

<<<<<<< HEAD
// b) check 2: alternate definition of out-of-copy
=======
// c) alternate definition
>>>>>>> 5cb8b96e4d01968e78d3274c1a7f003e6a5352f5
gen treat2 = (firstallstar < 1964) & (firsta != .)
replace tvar = treat2
eststo: qui xtreg `x' 1.tvar#1.post i.${fe}, fe cluster(id)
qui estadd local fixed "Yes"
qui estadd local yearfe "Year"

<<<<<<< HEAD
// c) check 3: remove v. famous players
=======
// d) remove v. famous players
>>>>>>> 5cb8b96e4d01968e78d3274c1a7f003e6a5352f5
replace tvar = treat
eststo: qui xtreg `x' 1.tvar#1.post i.${fe} if numa<15, fe cluster(id)
qui estadd local fixed "Yes"
qui estadd local yearfe "Year"

<<<<<<< HEAD
// d) check 4: alternate definitions for dependent variables
=======
// e) alternate definitions
>>>>>>> 5cb8b96e4d01968e78d3274c1a7f003e6a5352f5
preserve
destring size, replace ignore("NA")
replace img=(img>0)
replace text=size
replace bd = (bd>0)

eststo: xtreg `x' 1.tvar#1.post i.${fe}, fe cluster(id)
qui estadd local fixed "Yes"
qui estadd local yearfe "Year"

restore

<<<<<<< HEAD
=======
// e) two period only
/* preserve */
/* keep if year==2008 | year==2013 */
/* eststo: qui xtreg ln`x' 1.tvar#1.post i.${fe} if numa<15, fe cluster(id) */
/* qui estadd local fixed "Yes" */
/* qui estadd local yearfe "Yes" */
/* restore */


>>>>>>> 5cb8b96e4d01968e78d3274c1a7f003e6a5352f5
end


