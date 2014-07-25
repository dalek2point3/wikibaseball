program make_baseball

make_hof

make_allstar

make_match

make_master


end

// This makes baseball data for MT
program make_mt

use ${lahman}bb_master, clear

gen displayname = namefirst + " " + namelast + " " + namegiven
gen searchname = namefirst + "+" + namelast + "+" + namegiven + " baseball"

gen link = "http://en.wikipedia.org/w/index.php?title=Special%3ASearch&profile=default&search=" + searchname + "&fulltext=Search"

outsheet playerid displayname link using ${stash}mt_input_bb.csv, replace comma

end


// This makes master baseball dataset
program make_master

insheet using ${lahman}Master.csv, clear

merge 1:1 playerid using ${lahman}hof, keep(match) nogen

// there are players who were hall of fame, but not all star
merge 1:1 playerid using ${lahman}allstar, keep(match master)

gen debutyear = substr(debut, 1,4)
gen finalyear = substr(finalgame, 1,4)

keep playerid birthyear debutyear finalyear deathyear name* everinducted *hof* numallstar firstallstar

destring, replace

gen playername = namefirst + " " + namelast

// this deletes and old player that we dont care about anyway
bysort playername: drop if _n > 1

// generate file for amazon to get me data on
drop if debutyear < 1940
drop if debutyear > 2000

save ${lahman}bb_master, replace

end


program make_match

insheet using ${rawdata}match_wiki.csv, clear names
keep if sport == "Baseball"
drop  if wikiname == "None"

save ${rawdata}match_wiki, replace

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
