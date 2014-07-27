program make_merge

insheet using ${stash}tmp.csv, clear

renamevar

merge m:1 wikihandle using ${stash}bbk_master, nogen

egen id = group(wikihandle)
xtset id year

gen post = (year>2008)
gen treat = (debutyear < 1964)

foreach x in img text bd {
    gen ln`x' = ln(`x'+1)
}

drop if debut < 1944 | debut > 1984
egen sstt = group(isbaseball treat year)

save ${stash}master, replace

end

program renamevar

rename v1 wikihandle
rename v2 year
rename v3 user
rename v4 revid
rename v5 size
rename v6 text
rename v7 img
rename v8 bd


end
