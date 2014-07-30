program make_traf

insheet using ${stash}traf.csv, clear

egen traf = rowtotal(v1-v12)
replace traf = traf/12

rename v13 wikihandle
rename v14 year

drop v*

save ${stash}traf, replace    

end
