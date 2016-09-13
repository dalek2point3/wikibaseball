program make_traf

insheet using ${stash}traf.csv, clear

rename v13 wikihandle
rename v14 year

egen traf = rowtotal(v1-v12)
replace traf = traf/12 if year > 2007

// traffic data not available
replace traf = . if year < 2007

drop v*

save ${stash}traf, replace    

end
