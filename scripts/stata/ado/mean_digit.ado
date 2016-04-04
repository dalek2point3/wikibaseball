program mean_digit


use ${stash}citelines, clear

collapse (mean) numcites, by(year)

tw (bar numcites year if year < 2009, barwidth(0.8)) (bar numcites year if year >= 2009, barwidth(0.8)),  xtitle("Year") ytitle("Avg. Cites Per Issue-Year") legend(label(1 "Pre-Digitization") label(2 "Post-Digitization")) xlabel(2004 (1) 2012)

graph export ${tables}mean_digit.eps, replace
shell epstopdf ${tables}mean_digit.eps

end
