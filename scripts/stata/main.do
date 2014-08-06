clear all
set more off
set matsize 11000
program drop _all

qui adopath + "/mnt/nfs6/wikipedia.proj/wikibaseball/scripts/stata/ado"
declare_global

cd ${path}

// 1a. Produce Baseball / Basketball datasets
make_baseball

make_basketball

make_traf

make_rev

use ${lahman}bb_master, clear
append using ${basketball}bk_master
gen isbaseball = (minutesrank==.)
save ${stash}bbk_master, replace

** outsheet wikihandle playerid using ${stash}wikilist.csv, replace nonames noquote

// 1b. Merge data
make_merge

//1c. Make limited data
use ${stash}master, clear
keep if year == 2008 | year == 2013
save ${stash}master2, replace

    
/////////// ANALYSIS //////////////////

// 1. Summary Stats
summary

// 2. Digitization
program drop _all

reg_all digit

// 3. Copy DD
reg_all copy

// 4. Copy DDD
reg_ddd

// 5. Traffic

// 5. DD regressions
reg_traf

// 5b. IV
ivest

// FIGURES

// 1. figure

// 2. Mean charts
meanline img Images(Baseball) 1
meanline img Images(Basketball) 0

meanline text Text(Baseball) 1
meanline text Text(Basketball) 0

meanline bd Citations(Baseball) 1
meanline bd Citations(Basketball) 0

// 6. Killer Pictures
killer_pic2 1
killer_pic2 0

// 7. Time dummies picture
ddpic img 1
ddpic img 0

ddpic text 1
ddpic text 0

ddpic bd 1
ddpic bd 0

ddpic traf 1
ddpic traf 0

// 8. Scatterplot








