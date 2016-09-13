program reg_robust_new

local ln `1'

di "running"

make_data
run_reg `ln'numcites


local symbol "$\bar{y}$="
local meanline "\vspace{5mm}"
local box "\makebox[13em][l]{\underline{\textbf{"

esttab
esttab using "${tables}cite_reg_robust`ln'.tex", ${top} posthead("\midrule `box'Panel A: Citations}} `meanline'}\\") 

make_data
run_reg `ln'numimg
local meanline "\vspace{5mm} (`symbol'$meanvar)"
esttab using "${tables}cite_reg_robust`ln'.tex",  ${middle} posthead("\midrule \vspace{5mm} `box'Panel B : Images}}`meanline'}\\")

make_data `mode'
run_reg `ln'numtext
local meanline "\vspace{5mm} (`symbol'$meanvar)"
esttab using "${tables}cite_reg_robust`ln'.tex",   ${end} posthead("\midrule \vspace{5mm} `box'Panel C : Text}}`meanline'}\\")

end


program make_data

use ${stash}citelines, clear
fvset base 2012 year
gen tvar = treat
table_set "out-of-copy X post" "Issue-Year"

end

program run_reg

est clear
local x `1'

replace post = year > 2006
eststo: qui xtreg `x' 1.tvar#1.post i.${fe} if year < 2010, cluster(citeyear) fe
qui estadd local fixed "Yes"
qui estadd local yearfe "Year"

replace post = year > 2006
eststo: qui xtreg `x' 1.tvar#1.post i.${fe}, cluster(citeyear) fe
qui estadd local fixed "Yes"
qui estadd local yearfe "Year"

// eststo: qui xtreg `x' 1.tvar#1.post i.five_year, cluster(citeyear) fe
// qui estadd local fixed "Controls"
// qui estadd local yearfe "Decade X Year"

end
