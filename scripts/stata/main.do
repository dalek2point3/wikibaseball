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

// 1b. Merge data
make_merge

/////////// ANALYSIS //////////////////

// 1. Summary Stats
summary

t_test 1
t_test 0

// 2. Digitization
program drop _all
reg_all digit

// 3. Copy DD
reg_all copy

// 4. Copy DDD
reg_ddd

// 5. DD regressions -- Traf
reg_traf

// 5b. IV == Traf
ivest

// FIGURES

// 1. figure

// 2. Mean charts
meanline img Images(Baseball) 1
meanline img Images(Basketball) 0

program drop _all
meanline text Text(Baseball) 1
meanline text Text(Basketball) 0

meanline bd Citations(Baseball) 1
meanline bd Citations(Basketball) 0

// 6. Killer Pictures
killer_pic2 1
killer_pic2 0

// 7. Time dummies picture
ddpic bd 1
ddpic bd 0

ddpic img 1
ddpic img 0

ddpic text 1
ddpic text 0

// 8. Scatterplot
traf_scatter

// APPENDIX
reg_all digit ln

reg_all copy ln

reg_ddd ln

reg_traf ln

program drop _all
reg_robust copy







