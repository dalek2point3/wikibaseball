program make_citepanel

// append both text and image citation datasets
use ${stash}citelines_text, clear
keep wikih citeyear year 
sort wikih citeyear year

// this keeps the first year of every added citation
bysort wikih citeyear: drop if _n > 1

append using ${stash}citelines_img

// keep only relevant years
drop if citeyear < 1944 | citeyear > 1984

gen isimg = (titlehref != "")

// multiple steps to make balanced panel
// 1. copy each observation till 2013
egen citetextid = group(wikihandle citeyear) if wikihandle != ""
egen citeimgid = group(titlehref) if wikihandle == ""
gen citeid = max(citetextid,1000*citeimgid)

keep citeid isimg year citeyear

// 2. carryforward citatation to all following years
tsset citeid year
tsfill, full
bysort citeid: carryforward citeyear isimg, replace
drop if citeyear == .

// 3. create outcomes
bysort citeyear year: gen numcites = _N
bysort citeyear year: egen numimg = total(isimg)
bysort citeyear year: egen numtext = total(!isimg)

bysort citeyear year: drop if _n > 1
keep citeyear year num*

tsset citeyear year
tsfill, full

foreach x in cites img text{
    replace num`x' = 0 if num`x'==.
}

gen treat = citeyear < 1964
gen post = year > 2008

// restrict attention till year 2012
drop if year == 2013

// save balanced panel and final dataset
save ${stash}citelines, replace

end
