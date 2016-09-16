program chart_qual

local var `1'
local parameter `2'

// step 1. estimate coeffs
use ${stash}master, clear
keep if isbaseball == 1
keep if year > 2003
gen tvar = treat

gen qualvar = .

_pctile `parameter', p(25, 50, 75)
replace qualvar = 1 if `parameter' <= `r(r1)' & isb == 1
replace qualvar = 2 if `parameter' > `r(r1)'  & `parameter' <=`r(r2)' & isb == 1
replace qualvar = 3 if `parameter' > `r(r2)'  & `parameter' <=`r(r3)' & isb == 1
replace qualvar = 4 if `parameter' > `r(r3)' & isb == 1

replace quality = qualvar

xtreg `var' tvar##post##quality i.$fe, vce(robust) fe level(90)

// step 2. calculate predicted values
make_q

// step 3. plot predicted values
make_chart `var' `parameter'

end

// helper programs

// 1. Estimate coefficients by quality quartile

program make_q

gen estimate = .
gen q = .
gen min=.
gen max=.
foreach x in 1 2 3 4{
    replace q = `x' if _n == `x'
}

lincom 1.tvar#1.post, level(90)
replace estimate = `r(estimate)' if q == 1
replace min = r(estimate) + invnorm(0.05)*r(se) if q == 1
replace max = r(estimate) + invnorm(0.95)*r(se) if q == 1

foreach x in 2 3 4{
    lincom 1.tvar#1.post#`x'.quality+1.tvar#1.post, level(90)
    replace estimate = `r(estimate)' if q == `x'
    replace min = r(estimate) + invnorm(0.05)*r(se) if q == `x'
    replace max = r(estimate) + invnorm(0.95)*r(se) if q == `x'
}

keep q estimate max min
rename q quality
keep if _n < 5

end

// 2. plot estimates

program make_chart

local var `1'
local qualvar `2'

label define qualitylabel 1 "Top 25 pctile" 2 "25-50 pctile" 3 "50-75 pctile" 4 "Bottom 25 pctile"

label values quality qualitylabel

graph twoway (scatter estimate quality) (rcap min max quality, lcolor(navy)), legend(off) title("") xtitle("") xscale(r(0 5)) yline(0, lcolor(gs10)) xlabel(1 "Top 25 pctile" 2 "25-50 pctile" 3 "50-75 pctile" 4 "Bottom 25 pctile")

graph export "${tables}quality_`var'_`qualvar'.eps", replace
shell epstopdf  "${tables}quality_`var'_`qualvar'.eps"

end

