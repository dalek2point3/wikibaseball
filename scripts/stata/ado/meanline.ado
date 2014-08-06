program meanline

use ${stash}master, clear

local var `1'
local varlabel `2'
local isb `3'

local time year

if "`var'" == "traf"{
    drop if year < 2008
}

drop if isbaseball != `isb'

collapse (mean) mean=`var' (semean) se=`var' , by(`time' treat)


if "`var'" == "img" {
    local scale "yscale(range(-0.3 2.2)) ylabel(0 (0.4) 2)"
}

if "`var'" == "text" {
    local scale "yscale(range(0 20000)) ylabel(0 (5000) 20000)"
}

if "`var'" == "bd" {
    local scale "yscale(range(0 0.9)) ylabel(0 (0.2) 0.8)"
}


sort `time' treat
label variable mean "`varlabel'"

gen lo = mean - 1.96*se
gen hi = mean + 1.96*se

tw (connected mean `time' if treat == 0, symbol(X)) (connected mean `time' if treat == 1, msize(small)) (rcap lo hi  `time' if treat == 0, lcolor(gs10)) (rcap lo hi  `time' if treat == 1,lcolor(gs10)), legend(order(2 "Out-of-Copyright" 1 "In-Copyright" )) xtitle("Year") title("`varlabel'") xline(2008.5) `scale'

graph export ${tables}meanline_`var'_`isb'.eps, replace
shell epstopdf ${tables}meanline_`var'_`isb'.eps

end
