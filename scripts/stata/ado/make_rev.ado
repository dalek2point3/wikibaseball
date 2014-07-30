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

local outcomes "numrev numuser totsize avgsize"
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

// total size
bysort wikihandle year: egen totsize = total(size)

// avg size
bysort wikihandle year: egen avgsize = mean(size)

bysort wikihandle year: drop if _n > 1

keep numrev numuser totsize avgsize wikihandle year

save ${stash}rev_mk, replace

end


program make_data

insheet using ${revlist}revlist.csv, clear

gen tstamp = clock(v1, "YMD#hms#")
format tstamp %tc

rename v2 revid
rename v3 user
rename v4 size
rename v5 wikihandle

drop v*

save ${stash}revlist, replace

end
