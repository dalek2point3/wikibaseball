clear all
set more off
set matsize 11000
program drop _all

<<<<<<< HEAD
/////////// SET PARAMETERS //////////////////

// enter path of the wikibaseball directory here
local home "/home/nagaraj/Dropbox/research/wikibaseball/"

qui adopath + "`home'scripts/stata/ado"
declare_global `home'
cd ${path}

/////////// DATA CREATION //////////////////

// STEP 1: Make Sample A
make_cite

// STEP 2 : Make Sample B    

// 2a. create three separate files

=======
qui adopath + "/mnt/nfs6/wikipedia.proj/wikibaseball/scripts/stata/ado"
declare_global

cd ${path}

// 1a. Produce Baseball / Basketball datasets
>>>>>>> 5cb8b96e4d01968e78d3274c1a7f003e6a5352f5
make_baseball

make_basketball

make_traf

<<<<<<< HEAD
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
=======
make_rev

use ${lahman}bb_master, clear
append using ${basketball}bk_master
gen isbaseball = (minutesrank==.)
save ${stash}bbk_master, replace

// 1b. Merge data
make_merge

// 2 citation data
make_cite

/////////// ANALYSIS //////////////////

// 1. Summary Stats (Sample A and B)
summary

// 2. T Test
>>>>>>> 5cb8b96e4d01968e78d3274c1a7f003e6a5352f5
t_test

// 3. Impact of copyright DD (Sample A and B)
reg_dd_combined numcite bd 2004 2012 2009

// 4. Traffic Sample B
reg_traf

<<<<<<< HEAD
// 5. Images vs. Text (Samples A and B)
reg_dd_compare numimg numtext


// FIGURES
//////////////////////////////
    
// 1. schematic figure -- no data required

// 2. Time-series impact of digitization (Sample A)
mean_digit

// 3. DD chart-- impact on citations (Sample A and B)
=======
// 5. Hetero combined (A and B)
reg_dd_compare numimg numtext


//////////////////////////////
// FIGURES
//////////////////////////////
    
// 1. schematic figure

// 2. Mean digitization (Sample A)
mean_digit

// 3. DD chart (Sample A and B for cites)
>>>>>>> 5cb8b96e4d01968e78d3274c1a7f003e6a5352f5
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

<<<<<<< HEAD
//1. Digitization effect using Basketball data (Sample B)
reg_dd_appendix
=======
//1. Redo with basketball + digit + copy (Sample B)
reg_ddd_appendix
>>>>>>> 5cb8b96e4d01968e78d3274c1a7f003e6a5352f5

// 2. Leads and Lags Regression (Sample A)
ddpic_table

// 3. alternate years
reg_dd_combined numcite bd 2004 2009 2007

// 4. this shortens the panel length
reg_dd_combined numcite bd 2005 2011 2009
reg_dd_combined numcite bd 2006 2010 2009

// 5. alternate specs
reg_robust copy

<<<<<<< HEAD
// 6. Out of copyright exposure index
robust_traf

=======



///////////////////////
////////
// OLD re-organize -- these are tables no longer in the main paper

//reg_alternate 2011 2005 2009
//reg_alternate 2010 2006 2009


//syntax: reg_alternate endyear startyear postyear (Sample A and B)
// placebo
//reg_alternate 2009 2004 2007



//cite_reg
//reg_all copy
//reg_all_combined

// 3. Impact of copyright using Sample A

// 4. Impact of copyright using Sample B


// 6. Falsification
//reg_false



// Fig 1. Hall of fame traffic
traf_scatter



// APPENDIX
reg_all digit ln

reg_all copy ln

reg_ddd ln

reg_traf ln


// 5. Killer Pic (B) and Time varying (B)
//killer_pic2 img 1
//killer_pic2 traf 1
//killer_pic2 bd 1
//killer_pic2 text 1
//ddpic img 1



// 2. Digitization
program drop _all
reg_all digit


// 3. Copy DD


// 4. Copy DDD
reg_ddd

// 5. DD regressions -- Traf

// 6. IV == Traf
ivest

// 2. Mean charts
meanline img Images(Baseball) 1
meanline img Images(Basketball) 0

program drop _all
meanline text Text(Baseball) 1
meanline text Text(Basketball) 0

meanline bd Citations(Baseball) 1
meanline bd Citations(Basketball) 0

// 6. Killer Pictures

killer_pic2 0

// 7. Time dummies picture
ddpic bd 1
ddpic bd 0

ddpic img 1
ddpic img 0

ddpic text 1
ddpic text 0


// NEW CITE TABLES AND FIGURES

// 1. killer picture
cite_killer_pic

// 2. DD timeline
cite_ddpic img
cite_ddpic text
cite_ddpic cites

// 3. main regression table
program drop cite_reg
cite_reg
>>>>>>> 5cb8b96e4d01968e78d3274c1a7f003e6a5352f5
