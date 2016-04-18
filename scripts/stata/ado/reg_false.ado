program reg_false

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

end

program run_reg

est clear
local x `1'

//save_mean `x'

//eststo: qui reg `x' 1.tvar#1.post, cluster(citeyear)
//qui estadd local fixed "No"
//qui estadd local yearfe "No"

// falsification 1 : sample A -- different year, limited sample

// falsification 2 : sample A -- different year, full sample

// falsitifaction 3: sample B -- different year, limited sample

// falsitifaction 4: sample B -- different year, full sample

// falsification 4 : basketball analysis



use ${stash}citelines, clear
fvset base 2012 year
gen tvar = treat
table_set "out-of-copy X post" "Issue-Year"

replace post = (year>2006)
eststo: qui xtreg `x' 1.tvar#1.post i.${fe} if year < 2009, cluster(citeyear) fe
qui estadd local fixed "Yes"
qui estadd local yearfe "Year"
restore

preserve
replace post = (year>2006)
eststo: qui xtreg `x' 1.tvar#1.post i.${fe}, cluster(citeyear) fe
qui estadd local fixed "Yes"
qui estadd local yearfe "Year"
restore



/*eststo: qui xtreg `x' 1.tvar#1.post i.five_year, cluster(citeyear) fe
qui estadd local fixed "Controls"
qui estadd local yearfe "Decade X Year"
*/
end
