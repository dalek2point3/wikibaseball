program make_merge

// balanced dataset of wikihandles
insheet using ${stash}tmp_word.csv, clear

// rename variables
renamevar

merge m:1 wikihandle using ${stash}bbk_master, nogen

merge 1:1 wikihandle year using ${stash}traf, nogen

egen id = group(wikihandle)
xtset id year

gen post = (year>2008)

gen treat = (debutyear < 1964)

local outcomes "img text bd traf"

foreach x in `outcomes'{
    gen ln`x' = ln(`x'+1)
}

drop if debut < 1944 | debut > 1984

// generate quality quartiles
genqual

gen decade = round(debut, 10)
egen dy = group(decade year)
egen qy = group(quality year)

//drop if year < 2004
drop if year == 2013
replace text = text/1000

keep wikihandle text img bd playerid ln* post treat quality qy debut traf year isbaseball id finalyear final firstall numa size playername everinducted

save ${stash}master, replace

end

// helper programs

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

program genqual

gen quality = .
_pctile numallstar, p(25, 50, 75)

replace qual = 1 if numallstar <= `r(r1)' & isb == 1
replace qual = 2 if numallstar > `r(r1)'  & numall <=`r(r2)' & isb == 1
replace qual = 3 if numallstar > `r(r2)'  & numall <=`r(r3)' & isb == 1
replace qual = 4 if numallstar > `r(r3)' & isb == 1

_pctile minutesrank, p(33.333, 66.667 90)

replace qual = 1 if minutesrank <= `r(r1)' & isb == 0
replace qual = 2 if minutesrank > `r(r1)' & minutesrank <=`r(r2)' & isb == 0
replace qual = 3 if minutesrank > `r(r2)' & minutesrank <=`r(r3)' & isb == 0
replace qual = 4 if minutesrank > `r(r3)' & isb == 0

end
