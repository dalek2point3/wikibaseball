program cite_reg

local ln `1'

di "running"

make_data
run_reg `ln'numcites
local symbol "$\bar{y}$="
local meanline "\vspace{5mm} (`symbol'$meanvar)"
local box "\makebox[13em][l]{\underline{\textbf{"

esttab using "${tables}cite_reg`ln'.tex", ${top} posthead("\midrule `box'Panel A: Citations}} `meanline'}\\") 

make_data
run_reg `ln'numimg
local meanline "\vspace{5mm} (`symbol'$meanvar)"
esttab using "${tables}cite_reg`ln'.tex",  ${middle} posthead("\midrule \vspace{5mm} `box'Panel B : Images}}`meanline'}\\")

make_data `mode'
run_reg `ln'numtext
local meanline "\vspace{5mm} (`symbol'$meanvar)"
esttab using "${tables}cite_reg`ln'.tex",   ${end} posthead("\midrule \vspace{5mm} `box'Panel C : Text}}`meanline'}\\")

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

use ${stash}citelines, clear
fvset base 2012 year
gen tvar = treat
table_set "out-of-copy X post" "Issue-Year"

gen five = round((citeyear-1945)/5)
egen five_year = group(five year)

end

program run_reg

est clear
local x `1'

save_mean `x'

//eststo: qui reg `x' 1.tvar#1.post, cluster(citeyear)
//qui estadd local fixed "No"
//qui estadd local yearfe "No"

eststo: qui reg `x' 1.tvar#1.post i.${fe}, cluster(citeyear)
qui estadd local fixed "No"
qui estadd local yearfe "Year"

eststo: qui xtreg `x' 1.tvar#1.post i.${fe}, cluster(citeyear) fe
qui estadd local fixed "Yes"
qui estadd local yearfe "Year"

gen ln`x'=ln(`x'+1)
eststo: qui xtreg ln`x' 1.tvar#1.post i.${fe}, cluster(citeyear) fe
qui estadd local fixed "Yes"
qui estadd local yearfe "Year"


/*eststo: qui xtreg `x' 1.tvar#1.post i.five_year, cluster(citeyear) fe
qui estadd local fixed "Controls"
qui estadd local yearfe "Decade X Year"
*/
end
