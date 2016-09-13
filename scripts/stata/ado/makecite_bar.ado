program make_citebar


use ${stash}citelines_text, clear

bysort citeid: drop if _n > 1

append using ${stash}citelines_img

keep wikihandle citeyear titlehref

keep if citeyear > 1943 & citeyear < 1985

bysort citeyear: gen numc = _N
bysort citeyear: drop if _n > 1

bysort citeyear: egen numimg = total(title!="")
bysort citeyear: egen numtext = total(wikih!="")

tw (bar numc citeyear if citeyear<1964) (bar numc citeyear if citeyear>=1964)
graph export "${tables}citebar_all.eps", replace

tw (bar numimg citeyear if citeyear<1964) (bar numimg citeyear if citeyear>=1964)
graph export "${tables}citebar_img.eps", replace

tw (bar numtext citeyear if citeyear<1964) (bar numtext citeyear if citeyear>=1964)
graph export "${tables}citebar_text.eps", replace




end
