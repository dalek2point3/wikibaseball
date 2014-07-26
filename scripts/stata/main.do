clear all
set more off
set matsize 11000
program drop _all

qui adopath + "/mnt/nfs6/wikipedia.proj/wikibaseball/scripts/stata/ado"
declare_global

cd ${path}

// 1. Produce Baseball / Basketball datasets
make_baseball

make_basketball

use ${lahman}bb_master, clear
append using ${basketball}bk_master
gen isbaseball = (minutesrank!=.)
save ${stash}bbk_master, replace

// 2. 

