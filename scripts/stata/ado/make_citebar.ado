program make_citebar

use ${stash}citelines, replace

drop treat post
reshape wide numcites numtext numimg, i(citeyear) j(year)


foreach x in cites text img{
    gen numchange`x'=num`x'2013-num`x'2008
    tw (bar numchange`x' citeyear if citeyear<1964) (bar numchange`x' citeyear if citeyear>=1964)
    graph export "${tables}citebar_`x'.eps", replace
}

end
