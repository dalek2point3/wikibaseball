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

// 2 citation data
make_cite

/////////// ANALYSIS //////////////////

// 1. Summary Stats (Sample A and B)
summary

// 2. T Test
t_test

// 3. Impact of copyright using Sample A
cite_reg

// 4. Impact of copyright using Sample B
reg_all copy

// 5. Traffic Sample B
reg_traf

// 6. Falsification
//reg_false

// FIGURES

// 1. figure

// 2. Mean digitization (Sample A)
mean_digit

// 3. Killer chart (Sample A)
cite_killer_pic

// 4. DD chart (Sample A)
cite_ddpic cites
cite_ddpic img
cite_ddpic text

// 5. Killer Pic (B) and Time varying (B)
killer_pic2 img 1
killer_pic2 traf 1
ddpic img 1

// 6. Scatterplot
traf_scatter

// 7. Quality-wise impacts
chart_qual img 1
chart_qual traf 1
chart_qual text 1
chart_qual bd 1

// APPENDIX

//1. Redo with basketball + digit + copy (Sample B)
reg_ddd_appendix

// 2. Leads and Lags Regression (Sample A)
ddpic_table

// 3. alternate years

//syntax: reg_alternate endyear startyear postyear (Sample A and B)
// placebo
reg_alternate 2009 2004 2007

// 4. this shortens the panel length
reg_alternate 2011 2005 2009
reg_alternate 2010 2006 2009

// 5. alternate specs
reg_robust copy




// APPENDIX
reg_all digit ln

reg_all copy ln

reg_ddd ln

reg_traf ln

program drop _all

///////////////////////
////////
// OLD re-organize

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
