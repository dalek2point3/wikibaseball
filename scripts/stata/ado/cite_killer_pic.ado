// create bargraph that shows new content added by citeyear for each pub-year between 1944 and 1984
program cite_killer_pic

use ${stash}citelines, clear

keep citeyear numcites numimg numtext year

keep if year == 2008 | year == 2012

sort citeyear year
// calculate new additions between 2012 and 2008
foreach x in cites img text{
    bysort citeyear: gen diff`x' = num`x'[2]-num`x'[1] 
}

keep diff* citeyear

foreach x in cite img text{
    if "`x'" == "img"{
        local y "Image "
        local range "30"
    }
    else if "`x'" == "text"{
        local y "Text "
        local range "30"
    }
    else {
        local y ""
        local range "50"
    }

    tw (bar diff`x' citeyear if citeyear < 1964, barwidth(0.75) color(gs2)) (bar diff`x' citeyear if citeyear >= 1964, barwidth(0.75) color(gs8)),  title("") xtitle("Year of Baseball Digest Publication") ytitle("`y' Citations Added After Digitization") xsca(titlegap(3) range(1944 1984) noextend) ysca(titlegap(2) range(-0.2 `range')) xline(1963.5, noextend lcolor(gs4)) xlabel(1944(4)1984) ylabel(0(10)`range',nogrid) legend(label(1 "`nocopyright' Out-of-copyright") label(2 "`incopyright' In-copyright")) legend(order(1 2))

    graph export "${tables}cite_killer_`x'.eps", replace
    shell epstopdf "${tables}cite_killer_`x'.eps"
}

end
