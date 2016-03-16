program cite_killer_pic

use ${stash}citelines, clear

keep citeyear numcites numimg numtext year

keep if year == 2008 | year == 2013
sort citeyear year
foreach x in cites img text{
    di "`x'"
    bysort citeyear: gen diff`x' = num`x'[2]-num`x'[1] 
}

keep diff* citeyear

foreach x in img text{
    if "`x'" == "img"{
        local y "Image"
        local z "A"
    }
    else{
        local y "Text"
        local z "B"
    }
    tw (bar diff`x' citeyear if citeyear < 1964, barwidth(0.75) color(gs2)) (bar diff`x' citeyear if citeyear >= 1964, barwidth(0.75) color(gs8)),  title("Panel `z' : Increase in `y' Citations Post-Digitization") xtitle("Year of Baseball Digest Publication") ytitle("`y' Citations Added After Digitization") xsca(titlegap(3) range(1944 1984) noextend) ysca(titlegap(2) range(-0.2 30)) xline(1963.5, noextend lcolor(gs4)) xlabel(1944(4)1984) ylabel(0(5)30,nogrid) legend(label(1 "`nocopyright' (Before 1964)") label(2 "`incopyright' (After 1964)")) legend(order(1 2))

    graph export "${tables}cite_killer_`x'.eps", replace
    shell epstopdf "${tables}cite_killer_`x'.eps"
}

end
