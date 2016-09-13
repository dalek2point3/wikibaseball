<<<<<<< HEAD
/* This program makes Sample A */

program make_cite

// this produces ${stash}citelines_text
make_textcite

// this produces ${stash}citelines_img
make_imgcite

// merges data and creates final panel dataset
make_citepanel

end

=======
program make_cite

make_textcite
// this gives ${stash}citelines_text

make_imgcite
// this gives ${stash}citelines_img

// makepanel
make_panel

end


program make_panel

// append both datasets
use ${stash}citelines_text, clear
keep wikih citeyear year 
sort wikih citeyear year

// this keeps the first year of every added citation
bysort wikih citeyear: drop if _n > 1

append using ${stash}citelines_img

drop if citeyear < 1944 | citeyear > 1984

gen isimg = (titlehref != "")

// copy each observation till 2013
egen citetextid = group(wikihandle citeyear) if wikihandle != ""
egen citeimgid = group(titlehref) if wikihandle == ""
gen citeid = max(citetextid,1000*citeimgid)

keep citeid isimg year citeyear

// carryforward citatation to all following years
tsset citeid year
tsfill, full
bysort citeid: carryforward citeyear isimg, replace
drop if citeyear == .

// create outcomes
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

drop if year == 2013
save ${stash}citelines, replace

end


>>>>>>> 5cb8b96e4d01968e78d3274c1a7f003e6a5352f5
