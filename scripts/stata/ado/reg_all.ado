program reg_all

local mode `1'
local ln `2'

make_data `mode'
run_reg `ln'bd
local meanline "\vspace{5mm} ($\mu$=$meanvar)\\"
esttab using "${tables}`ln'`mode'.tex", ${top} posthead("\midrule \underline{\textbf{Panel A: Citations}} `meanline'") 

make_data `mode'
run_reg `ln'img
local meanline "\vspace{5mm} ($\mu$=$meanvar)\\"
esttab using "${tables}`ln'`mode'.tex",  ${middle} posthead("\midrule \vspace{5mm} \underline{\textbf{Panel B : Images}}`meanline'")

make_data `mode'
run_reg `ln'text
local meanline "\vspace{5mm} ($\mu$=$meanvar)\\"
esttab using "${tables}`ln'`mode'.tex",   ${end} posthead("\midrule \vspace{5mm} \underline{\textbf{Panel C : Text}}`meanline'")

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
    table_set "baseball X post"

}

if "`mode'" == "copy" {
    drop if isbaseball == 0
    gen tvar = treat
    table_set "out-of-copy X post"
}

end

program run_reg

est clear
local x `1'

save_mean `x'

eststo: qui reg `x' 1.tvar#1.post i.${fe}, cluster(id)

qui estadd local fixed "No"
qui estadd local yearfe "Yes"
qui estadd local mean "${meanvar}"

eststo: qui reg `x' 1.tvar#1.post i.quality i.${fe}, cluster(id)
qui estadd local fixed "Controls"
qui estadd local yearfe "Yes"
qui estadd local mean "${meanvar}"

**keep if year==2008 | year==2013

eststo: qui xtreg `x' 1.tvar#1.post i.${fe}, fe cluster(id)
qui estadd local fixed "Yes"
qui estadd local yearfe "Yes"
qui estadd local mean "${meanvar}"

end
