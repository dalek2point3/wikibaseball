program mean_digit

<<<<<<< HEAD
// Panel 1. Time series from 2004-2012
=======
// first chart
>>>>>>> 5cb8b96e4d01968e78d3274c1a7f003e6a5352f5
use ${stash}citelines, clear

collapse (mean) numcites, by(year)

tw (bar numcites year if year < 2009, barwidth(0.8) color(gs8)) (bar numcites year if year >= 2009, barwidth(0.8) color(gs2)),  xtitle("Year") ytitle("Avg. Cites Per Publication-Year") legend(label(1 "Pre-Digitization") label(2 "Post-Digitization")) xlabel(2004 (1) 2012) xline(2008.5)

graph export ${tables}mean_digit.eps, replace
shell epstopdf ${tables}mean_digit.eps

<<<<<<< HEAD
// Panel 2. Time series, separated for in-copy and out-of-copy
=======
// second chart
>>>>>>> 5cb8b96e4d01968e78d3274c1a7f003e6a5352f5
use ${stash}citelines, clear

collapse (mean) numcites numimg numtext, by(year treat)

<<<<<<< HEAD
local x cites
tw (connected num`x' year if treat == 0, msymbol(X)) (connected num`x' year if treat == 1),  xtitle("Year") ytitle("Avg. Cites Per Publication-Year") legend(label(1 "In-Copyright(1964-1984)") label(2 "Out-of-Copyright(1944-1963)")) xlabel(2004 (1) 2012) xline(2008.5) yscale(range(0(2)20))  ylabel(0(4)20)

graph export ${tables}mean_connected_`x'.eps, replace
shell epstopdf ${tables}mean_connected_`x'.eps
=======
foreach x in cite img text{
    
    tw (connected num`x' year if treat == 0, msymbol(X)) (connected num`x' year if treat == 1),  xtitle("Year") ytitle("Avg. Cites Per Publication-Year") legend(label(1 "In-Copyright(1964-1984)") label(2 "Out-of-Copyright(1944-1963)")) xlabel(2004 (1) 2012) xline(2008.5) yscale(range(0(2)20))  ylabel(0(4)20)

    graph export ${tables}mean_connected_`x'.eps, replace
    shell epstopdf ${tables}mean_connected_`x'.eps
}
>>>>>>> 5cb8b96e4d01968e78d3274c1a7f003e6a5352f5

end
