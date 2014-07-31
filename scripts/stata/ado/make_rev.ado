program make_rev

make_data

make_var

balance_var

save ${stash}rev, replace

end

program balance_var

use ${stash}rev_mk, replace

egen unitid = group(wikihandle)

tsset unitid year

tsfill, full

local outcomes "numrev numuser numregusers numnew_wiki numnewreg_wiki numnewreg_page numserious18 numserious39 numserious112 numserious324 numserious791 totsize avgsize numcountry numregion numtimezone numnewregion numnewregion_wiki"

local covars "wikihandle"

foreach x in `outcomes'{
        replace `x' = 0 if `x' == .
}

foreach x in `covars'{
    gsort unitid year
    bysort unitid: carryforward `x', gen(tmp1)
    gsort unitid -year
    bysort unitid: carryforward tmp1, gen(tmp2)
    replace `x' = tmp2
    drop tmp1 tmp2
    di "finished `x'"
    di "---"
}

end


program make_var

use ${stash}revlist, clear

gen year = year(dofc(tstamp))

// number revisions
bysort wikihandle year: gen numrev = _N

// number users
bysort wikihandle year user: gen tmp=(_n==1)
bysort wikihandle year: egen numuser = total(tmp)
drop tmp

// total size
bysort wikihandle year: egen totsize = total(size)

// avg size
bysort wikihandle year: egen avgsize = mean(size)

// number registered users
gen isreg  = regexm(user, "[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+") != 1
bysort wikihandle year: egen numregusers = total(isreg)

// num first users
sort user tstamp
bysort user: gen first_wikiedit = tstamp[1]
bysort wikihandle year: egen numnew_wiki = total(tstamp==first_wikiedit)
bysort wikihandle year: egen numnewreg_wiki = total((tstamp==first_wikiedit)*isreg)

sort wikihandle user tstamp
bysort wikihandle user: gen first_pageedit = tstamp[1]
bysort wikihandle year: egen numnew_page = total(tstamp==first_pageedit)
bysort wikihandle year: egen numnewreg_page = total((tstamp==first_pageedit)*isreg)

drop first_*

// serious users
local levels "18 39 112 324 791"
foreach x in `levels'{
    bysort wikihandle year: egen numserious`x' = total((numrev>`x'))
}

// geography of users
bysort wikihandle year countrycode: gen tmp = (_n==1)
bysort wikihandle year: egen numcountry = total(tmp)
drop tmp

bysort wikihandle year region: gen tmp = (_n==1)
bysort wikihandle year: egen numregion = total(tmp)
drop tmp

bysort wikihandle year timezone: gen tmp = (_n==1)
bysort wikihandle year: egen numtimezone = total(tmp)
drop tmp

bysort wikihandle region: gen tmp = (_n==1)
bysort wikihandle year: egen numnewregion = total(tmp)
drop tmp

bysort region: gen tmp = (_n==1)
bysort wikihandle year: egen numnewregion_wiki = total(tmp)
drop tmp


keep num* totsize avgsize wikihandle year

bysort wikihandle year: drop if _n > 1

save ${stash}rev_mk, replace

end


program make_data

insheet using ${stash}ip_geo.csv, clear
rename v1 countrycode
rename v2 cityname
rename v3 zipcode
rename v4 longitude
rename v5 countryname
rename v6 latitude
rename v7 timezone
rename v8 user
rename v9 regionname

bysort user: drop if _n > 1

save ${stash}ip_geo, replace

insheet using ${revlist}revlist.csv, clear

gen tstamp = clock(v1, "YMD#hms#")
format tstamp %tc

rename v2 revid
rename v3 user
rename v4 size
rename v5 wikihandle

drop v*

merge m:1 user using ${stash}ip_geo, keep(match master) nogen
    
save ${stash}revlist, replace


end
