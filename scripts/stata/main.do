clear all
set more off
set matsize 11000
program drop _all

/////////// SET PARAMETERS //////////////////

// enter path of the wikibaseball directory here
local home "/mnt/nfs6/wikipedia.proj/wikibaseball/"

qui adopath + "`home'scripts/stata/ado"
declare_global `home'
cd ${path}

/////////// DATA CREATION //////////////////

// STEP 1: Make Sample A
make_cite

// STEP 2 : Make Sample B    

// 2a. create three separate files

make_baseball

make_basketball

make_traf

// 2b. Merge data

use ${lahman}bb_master, clear
qui append using ${basketball}bk_master
gen isbaseball = (minutesrank==.)
save ${stash}bbk_master, replace

make_merge

// we now have two main datasets
// sample A -- ${stash}citelines
// sample B -- ${stash}master

/////////// ANALYSIS //////////////////

// TABLES    
//////////////////////////////

// 1. Summary Stats (Sample A and B)
summary

// 2. T-Test Table (Sample A and B)
t_test

// 3. Impact of copyright DD (Sample A and B)
reg_dd_combined numcite bd 2004 2012 2009

// 4. Traffic Sample B
reg_traf

// 5. Images vs. Text (Samples A and B)
reg_dd_compare numimg numtext


// FIGURES
//////////////////////////////
    
// 1. schematic figure -- no data required

// 2. Time-series impact of digitization (Sample A)
mean_digit

// 3. DD chart-- impact on citations (Sample A and B)
cite_ddpic cites
ddpic bd 1

// 4. Killer chart (Sample A)
cite_killer_pic

// 5. Killer pic (Sample A) -- for images and text
cite_killer_pic

// 6. DD Pic (Sample A)
cite_ddpic img
cite_ddpic text

// 7. Quality-wise impacts
chart_qual img
chart_qual traf 

/////////////////////////////////
// APPENDIX

//1. Digitization effect using Basketball data (Sample B)
reg_dd_appendix

// 2. Leads and Lags Regression (Sample A)
ddpic_table

// 3. alternate years
reg_dd_combined numcite bd 2004 2009 2007

// 4. this shortens the panel length
reg_dd_combined numcite bd 2005 2011 2009
reg_dd_combined numcite bd 2006 2010 2009

// 5. alternate specs
reg_robust copy

// 6. Out of copyright exposure index
robust_traf

