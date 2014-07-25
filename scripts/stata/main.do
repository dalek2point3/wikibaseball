clear all
set more off
set matsize 11000
program drop _all

qui adopath + "/mnt/nfs6/wikipedia.proj/wikibaseball/scripts/stata/ado"
declare_global

cd ${path}

make_baseball

insheet using ${rawdata}match_wiki.csv, clear



