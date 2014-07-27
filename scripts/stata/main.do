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

use ${lahman}bb_master, clear
append using ${basketball}bk_master
gen isbaseball = (minutesrank==.)
save ${stash}bbk_master, replace

outsheet wikihandle playerid using ${stash}wikilist.csv, replace nonames noquote

// 1b. Merge data
make_merge

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

// 3. Baseline Digit & Copyright Regressions
reg_digit

reg_copy

// 4. DDD regressions






