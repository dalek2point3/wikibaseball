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


/*use ${stash}master, clear
keep if year == 2008 | year == 2013
save, replace
*/
    
/////////// ANALYSIS //////////////////

// 1. Summary Stats
summary

// 2. Meanline Charts
program drop _all
meanline img Images(Baseball) 1
meanline img Images(Basketball) 0

meanline text Text(Baseball) 1
meanline text Text(Basketball) 0

meanline bd Citations(Baseball) 1
meanline bd Citations(Basketball) 0

meanline traf Traffic(Baseball) 1
meanline traf Traffic(Basketball) 0

meanline numuser Users(Baseball) 1
meanline numuser Users(Basketball) 0

meanline numrev Revisions(Baseball) 1
meanline numrev Revisions(Basketball) 

meanline avgsize Size(Baseball) 1
meanline avgsize Size(Basketball) 0

// 3. Baseline Digit & Copyright Regressions
reg_digit
reg_digit ln

reg_copy
reg_copy ln

// 4. DDD regressions
reg_ddd
reg_ddd ln

// 5. User regressions


// 6. Killer Pictures
program drop _all
killer_pic

// 7. Time dummies picture
ddpic img 1
ddpic img 0

ddpic text 1
ddpic text 0

ddpic traf 1
ddpic traf 0

ddpic bd 1
ddpic bd 0









