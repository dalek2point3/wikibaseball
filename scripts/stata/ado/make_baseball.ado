program make_baseball

make_hof

make_allstar


insheet using ${lahman}Master.csv, clear

merge 1:1 playerid using ${lahman}hof, keep(match) nogen

// there are players who were hall of fame, but not all star
merge 1:1 playerid using ${lahman}allstar, keep(match master)


end

// This Makes Hall of Fame
program make_hof

insheet using ${lahman}HallOfFame.csv, clear
bysort playerid: egen everinducted = max(inducted=="Y")
bysort playerid: gen num_hof_nominations = _N
sort playerid yearid
bysort playerid: gen hof_year_elected = yearid[_N]*everinducted
replace hof_year_elected = -1 if hof_year_elected == 0

bysort playerid: gen hof_year_first = yearid[1]

// TODO : calculate margin
bysort playerid: drop if _n > 1
keep playerid everinducted num_hof hof_year*

save ${lahman}hof, replace

end

// This Makes Allstar
program make_allstar

insheet using ${lahman}AllstarFull.csv, clear
bysort playerid: gen numallstar = _N
sort playerid yearid
bysort playerid: gen firstallstar = yearid[1]
bysort playerid: drop if _n > 1
keep playerid numallstar firstallstar
save ${lahman}allstar, replace

end
