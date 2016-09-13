program chart_qual

local var `1'

<<<<<<< HEAD
// step 1. estimate coeffs
=======
>>>>>>> 5cb8b96e4d01968e78d3274c1a7f003e6a5352f5
use ${stash}master, clear
keep if isbaseball == 1
keep if year > 2003
gen tvar = treat
xtreg `var' tvar##post##quality i.$fe, vce(robust) fe level(90)

<<<<<<< HEAD
// step 2. calculate predicted values
make_q

// step 3. plot predicted values
=======
make_q

>>>>>>> 5cb8b96e4d01968e78d3274c1a7f003e6a5352f5
make_chart `var'

end

<<<<<<< HEAD
// helper programs

// 1. Estimate coefficients by quality quartile
=======
>>>>>>> 5cb8b96e4d01968e78d3274c1a7f003e6a5352f5

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

<<<<<<< HEAD
// 2. plot estimates

=======
>>>>>>> 5cb8b96e4d01968e78d3274c1a7f003e6a5352f5
program make_chart

local var `1'

label define qualitylabel 1 "Top 25 pctile" 2 "25-50 pctile" 3 "50-75 pctile" 4 "Bottom 25 pctile"

label values quality qualitylabel

graph twoway (scatter estimate quality) (rcap min max quality, lcolor(navy)), legend(off) title("") xtitle("") xscale(r(0 5)) yline(0, lcolor(gs10)) xlabel(1 "Top 25 pctile" 2 "25-50 pctile" 3 "50-75 pctile" 4 "Bottom 25 pctile")

graph export "${tables}quality_`var'.eps", replace
<<<<<<< HEAD
=======

>>>>>>> 5cb8b96e4d01968e78d3274c1a7f003e6a5352f5
shell epstopdf  "${tables}quality_`var'.eps"

end

