program reg_robust

local mode `1'
local ln `2'

local meanline "\vspace{5mm}\\"

make_data `mode'
run_robust `ln'bd
**local meanline "\vspace{5mm} ($\mu$=$meanvar)\\"
esttab using "${tables}`ln'`mode'_robust.tex", ${top} posthead("\midrule \underline{\textbf{Panel A: Citations}} `meanline'")

make_data `mode'
run_robust `ln'img
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

program make_data

local mode `1'

use ${stash}master, clear
fvset base 2013 year

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

program run_robust

est clear
local x `1'

save_mean `x'
replace bd = (bd>0)

// a) log model
eststo: qui xtreg ln`x' 1.tvar#1.post i.${fe}, fe cluster(id)
qui estadd local fixed "Yes"
qui estadd local yearfe "Yes"

// b) no overlap
gen overlap = !((debut > 1963) | (final < 1964))
eststo: qui xtreg `x' 1.tvar#1.post i.${fe} if overlap==0, fe cluster(id)
qui estadd local fixed "Yes"
qui estadd local yearfe "Yes"

// c) alternate definition
gen treat2 = (firstallstar < 1964) & (firsta != .)
replace tvar = treat2
eststo: qui xtreg `x' 1.tvar#1.post i.${fe}, fe cluster(id)
qui estadd local fixed "Yes"
qui estadd local yearfe "Yes"

// d) remove v. famous players
replace tvar = treat
eststo: qui xtreg `x' 1.tvar#1.post i.${fe} if numa<15, fe cluster(id)
qui estadd local fixed "Yes"
qui estadd local yearfe "Yes"

// e) alternate definitions
preserve
destring size, replace ignore("NA")
replace img=(img>0)
replace text=size
replace bd = (bd>0)

eststo: qui xtreg `x' 1.tvar#1.post i.${fe}, fe cluster(id)
qui estadd local fixed "Yes"
qui estadd local yearfe "Yes"

restore

// e) two period only
/* preserve */
/* keep if year==2008 | year==2013 */
/* eststo: qui xtreg ln`x' 1.tvar#1.post i.${fe} if numa<15, fe cluster(id) */
/* qui estadd local fixed "Yes" */
/* qui estadd local yearfe "Yes" */
/* restore */


end


