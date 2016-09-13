set more off
set matsize 11000
local path "/home/nagaraj/Dropbox/research/copyright/stata/"
local nocopyright "Out-of-Copy"
local incopyright "In-Copy"

cd `path'

//prepare imgchar data
clear
insheet using ../lookups/imgchar.csv
rename v1 wikiname
rename v2 month
rename v3 year
rename v4 img
rename v5 char
bysort wikiname year month: drop if _n > 1
merge m:1 wikiname using ../data/result.dta, keep(match) nogen
save ../data/imgchar.dta, replace

//prepare traf data
clear
insheet using ../lookups/traf.csv
rename v1 wikiname
rename v2 month
rename v3 year
rename v4 traf
bysort wikiname year month: drop if _n > 1
merge m:1 wikiname using ../data/result.dta, keep(match) nogen
save ../data/traf.dta, replace

//merge
clear
use ../data/traf
merge 1:1 wikiname year month using ../data/imgchar.dta, keep(match) nogen
gen baseballdummy = (sport == "Baseball")
drop sport
save ../data/wikidata.dta, replace

//sportsmaster
use ../data/master, clear
replace playername = subinstr(playername, "%20", "", .)
save, replace

use ../data/octfinalall, clear
bysort playername: drop if _n > 1
drop if minutesrank > 1000 & baseball == 0
drop if hofid == "" & baseball == 1
gen finalyear = substr(finalgame, -4, .)

keep playername debutyear baseballdummy inducted appear allstar finalgame birthyear minutesrank gp pts asts turnover minutes finalyear firstall finalall
replace playername = subinstr(playername, "%20", " ", .)

//sort debut
//list debut firstall finalall finalyear if baseball == 1
save ../data/master, replace

// merge with sports master data
clear
use ../data/wikidata
merge m:1 playername using ../data/master, keep(match) nogen
gen before1964 = 0
replace before1964 = 1 if debut < 1964
gen post2008 = 0
replace post2008 = 1 if year > 2008
egen numplayer = group(playername)

keep if month > 9
bysort playername year: egen meantraf = mean(traf)
replace traf = meantraf
drop meantraf
keep if month == 12
bysort numplayer year: drop if _n > 1
save ../data/dataset_allyear, replace

clear
use ../data/dataset_allyear
keep if (year == 2008) | (year == 2012)
save ../data/dataset, replace


///**************** DATA PREP IS OVER *****************
/////////////////// TABLES ////////////////////////

///-------------------------------
/// TABLE 1. SUMMARY STATS
///-------------------------------

use ../data/dataset, clear

gen careerlength = substr(finalgame, -4,.)
destring careerlength, replace
replace careerlength = careerlength - debutyear

gen inducted_i = (inducted == "Y")

label variable debutyear "Debut Year"
label variable allstar "All Star Appearances"
label variable appear  "Total Appearances"
label variable career  "Career Years Played"
label variable inducted_i "Inducted in Hall of Fame"
label variable before1964 "Debut Before 1964 (pct)"
label variable img "Images"
label variable char "Text"
label variable traf "Traffic"

est clear

estpost tabstat img traf char debut before1964  if baseball == 1, s(mean sd median min max) columns(statistics)

esttab using "../tables/bb_summary.tex", cells ("mean(fmt(2) label(Mean)) sd(label(SD)) p50(label(Median)) min(label(Min)) max(label(Max))" ) coeflabels("Mean" "SD" "Median" "Min" "Max") replace nonum noobs label booktabs width(\hsize) alignment(rrrrr)

est clear

label variable minutes "Minutes Played"
label variable gp "Games Played"
label variable pts "Points"
label variable asts "Assists"
label variable turnover "Turnovers"

estpost tabstat img traf char debut before1964 if baseball == 0, s(mean sd median min max) columns(stats) 

esttab using "../tables/bk_summary.tex", cells ("mean(fmt(2) label(Mean)) sd(label(SD)) p50(label(Median)) min(label(Min)) max(label(Max))" ) coeflabels("Mean" "SD" "Median" "Min" "Max") replace nonum noobs label booktabs width(\hsize) alignment(rrrrr)

//---------------------------------
// TABLE 2. GRUBER
//---------------------------------

local temp 0

if temp == "1"{
  
clear
use ../data/dataset


egen groupvar = group(baseball before post2008)

gen after = !before
gen pre2008 = !post2008

/// data from these results are manually copied into excel
/// BASEBALL
ttest img if baseball == 1 & before == 1, by(post2008)
ttest traf if baseball == 1 & before == 1, by(post2008)

ttest img if baseball == 1 & before == 0, by(pre2008)
ttest traf if baseball == 1 & before == 0, by(pre2008)

//
ttest img if baseball == 1 & post2008 == 0, by(after)
ttest traf if baseball == 1 & post2008 == 0, by(after)

ttest img if baseball == 1 & post2008 == 1, by(after)
ttest traf if baseball == 1 & post2008 == 1, by(after)

reg img before##post2008 if baseball == 1, robust cluster(numplayer)
reg traf before##post2008 if baseball == 1, robust cluster(numplayer)

/// BASKETBALL
ttest img if baseball == 0 & before == 1, by(pre2008)
ttest traf if baseball == 0 & before == 1, by(pre2008)

ttest img if baseball == 0 & before == 0, by(pre2008)
ttest traf if baseball == 0 & before == 0, by(pre2008)

//
ttest img if baseball == 0 & post2008 == 0, by(after)
ttest traf if baseball == 0 & post2008 == 0, by(after)

ttest img if baseball == 0 & post2008 == 1, by(after)
ttest traf if baseball == 0 & post2008 == 1, by(after)

reg img before##post2008 if baseball == 0, robust cluster(numplayer)
reg traf before##post2008 if baseball == 0, robust cluster(numplayer)

reg img before##post2008##baseball, robust cluster(numplayer)

reg traf before##post2008##baseball, robust cluster(numplayer)

}

///-------------------------------
/// TABLE 3. DD Digitization Impact
//-------------------------------

clear
use ../data/dataset, replace
set matsize 10000

keep if (year == 2008) | (year == 2012)

tabstat img char traf, save
matrix stats=r(StatTotal)
local meanimg =  round(stats[1,1],0.001)
local meanchar =  round(stats[1,2],0.001)
local meantraf =  round(stats[1,3],0.001)

egen timeid = group(month year)
bysort numplayer timeid: drop if _n > 1
xtset numplayer timeid

est clear

eststo: qui xtreg img baseball##post2008, fe cluster(numplayer)
estadd local fixed "Yes" , replace

eststo: qui xtreg traf baseball##post2008, fe cluster(numplayer)
estadd local fixed "Yes" , replace

eststo: qui xtreg char baseball##post2008, fe cluster(numplayer)
estadd local fixed "Yes" , replace

local keepvar "_cons 1.baseball* 1.post*"
local note1 "Mean(Img) = `meanimg', Mean(Text) = `meanchar'"
local note2 "Mean(Traf) = `meantraf'"
local note3 "Robust standard errors clustered at player level are reported"
local note4 "* p $<$ 0.10, ** p $<$ 0.05, *** p $<$ 0.01"

esttab using "../tables/digitization.tex", keep(`keepvar') order(1.baseballdummy#1.post2008 1.post2008) se ar2 nonotes star(* 0.10 ** 0.05 *** 0.01) coeflabels(1.post2008 "Post 2008" 1.baseballdummy#1.post2008 "Baseball X Post" _cons "Constant") mtitles("Images" "Traf." "Text") replace booktabs addnote("`note3'" "`note4'" "`note1'" "`note2'")  s(fixed r2_a N, label("Player FE" "adj. \$R^2\$")) width(0.75\hsize)
 
//-------------------------------------
// TABLE 4. DD for Images and Traffic for BB
//-------------------------------------

clear
use ../data/dataset, replace
set matsize 10000

keep if (year == 2008) | (year == 2012)

egen timeid = group(month year)
bysort numplayer timeid: drop if _n > 1
xtset numplayer timeid

tabstat img traf char if baseball == 1, save
matrix stats=r(StatTotal)
local meanimg =  round(stats[1,1],0.001)
local meantraf =  round(stats[1,2],0.001)
local meanchar =  round(stats[1,3],0.001)

gen lntraf = ln(traf+1)
gen lnimg = ln(img+1)

est clear

eststo: qui xtreg img before##post2008 if baseball == 1, fe cluster(numplayer)
estadd local fixed "Yes" , replace

eststo: qui xtreg traf before##post2008 if baseball == 1, fe cluster(numplayer)
estadd local fixed "Yes" , replace

eststo: qui xtreg char before##post2008 if baseball == 1, fe cluster(numplayer)
estadd local fixed "Yes" , replace


local note1 "Robust standard errors clustered at player level are reported"
local note2 "* p $<$ 0.10, ** p $<$ 0.05, *** p $<$ 0.01"
local note3 "Mean(Images) = `meanimg', Mean(Traffic) = `meantraf', Mean(Text)=`meanchar'"

local keepvar "_cons 1.before1964#1.post2008 1.post*"
 
esttab using "../tables/baseline.tex", keep(`keepvar') order(1.before1964#1.post2008 1.post2008) se ar2 nonotes star(* 0.10 ** 0.05 *** 0.01) coeflabels(1.post2008 "Post 2008" 1.before1964#1.post2008 "`nocopyright' X Post" _cons "Constant") mtitles("Images" "Traffic" "Text") replace booktabs addnote("`note1'" "`note2'" "`note3'")  s(fixed r2_a N, label("Player FE" "adj. \$R^2\$")) width(0.75\hsize)


 
//---------------------------------
// TABLE 5. DDD for Images 
//---------------------------------

clear
use ../data/dataset

gen lntraf = ln(traf+1)
gen lnimg = ln(img+1)
gen lnchar = ln(char+1)

est clear


eststo: xi: qui xtreg img before##post2008##baseball, fe clust(numplayer) i(numplayer)
estadd local fixed "Yes" , replace

eststo: xi: qui xtreg traf before##post2008##baseball, fe clust(numplayer) i(numplayer)
estadd local fixed "Yes" , replace

eststo: xi: qui xtreg char before##post2008##baseball, fe clust(numplayer) i(numplayer)

estadd local fixed "Yes" , replace


tabstat img char traf, save
matrix stats=r(StatTotal)
local meanimg =  round(stats[1,1],0.001)
local meanchar =  round(stats[1,2],0.001)
local meantraf =  round(stats[1,3],0.001)

local note1 "Robust standard errors clustered at player level are reported"
local note2 "* p $<$ 0.10, ** p $<$ 0.05, *** p $<$ 0.01"
local note3 "Mean(Images) = `meanimg', Mean(Traf) = `meantraf' and Mean(Text) = `meanchar'"

 local keepvar "_cons 1.post2008 1.before1964#1.post2008 1.post2008#1.baseballdummy 1.before1964#1.post2008#1.baseballdummy"
 
esttab using "../tables/triplediff.tex", keep(`keepvar') order(1.before1964#1.post2008#1.baseballdummy 1.before1964#1.post2008 1.post2008#1.baseballdummy 1.post2008) se ar2 nonotes star(* 0.10 ** 0.05 *** 0.01) coeflabels(1.post2008 "Post 2008" 1.before1964#1.post2008 "`nocopyright' X Post" 1.before1964#1.post2008#1.baseballdummy "Post X Baseball X `nocopyright'" 1.post2008#1.baseballdummy "Post X Baseball" _cons "Constant") mtitles("Images" "Traffic" "Text" "Ln(Text)") replace booktabs addnote("`note1'" "`note2'" "`note3'")  s(fixed r2_a N, label("Player FE" "adj. \$R^2\$")) width(0.85\hsize)


//---------------------------------
// TABLE 6. Mechanism
//---------------------------------

clear
use ../data/dataset, replace
keep if baseball == 1

egen timeid = group(month year)
bysort numplayer timeid: drop if _n > 1
xtset numplayer timeid

gen instrument = post2008*before
gen inducted_i = (inducted == "Y")

gen careerlength = substr(finalgame, -4,.)
destring careerlength, replace
replace careerlength = careerlength - debutyear
gen ageatdebut = debutyear - birthyear

local controls "appearances inducted_i ageatdebut careerlength"
label variable traf "Traffic"
label variable img "Images"
label variable before "Out-of-Copy"
label variable instrument "Out-Of-Copy. X Post"


est clear
eststo: qui reg traf img post2008 `controls', clust(numplayer)
estadd local covar "Yes" 
estadd local yearfe "Yes" 

eststo: qui xtreg traf img post2008, fe clust(numplayer)
estadd local covar "Player FE" 
estadd local yearfe "Yes" 

eststo: qui ivreg2 traf (img=instrument) post2008, small savefirst savefprefix(first) clust(numplayer)
mat first=e(first)
local FStat = round(first[3,1],0.01)
estadd local FStat `FStat'  : firstimg
estadd local covar "Yes" : firstimg
estadd local covar "Yes" 
estadd local yearfe "Yes" : firstimg
estadd local yearfe "Yes" 

eststo: qui xtivreg2 traf (img=instrument) post2008, fe small savefirst savefprefix(firstcontrol) clust(numplayer)
mat first=e(first)
local FStat = round(first[3,1],0.01)
estadd local FStat `FStat'  : firstcontrolimg
estadd local covar "Player FE" : firstcontrolimg 
estadd local covar "Player FE" 
estadd local yearfe "Yes" : firstcontrolimg
estadd local yearfe "Yes" 

local note1 "Standard errors clustered at player level are reported"
local note2 "* p $<$ 0.10, ** p $<$ 0.05, *** p $<$ 0.01"


esttab est1 est2 firstimg firstc* est3 est4 using ../tables/mechanism.tex, drop(_cons `controls' post2008) se stats(covar yearfe N r2 FStat,labels("Controls" "Year FE" "N" "adj. \$R^2\$" "F-Stat")) label replace mgroups("OLS" "First Stage" "IV Estimates", pattern(1 0 1 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) booktabs nonumber  addnote("`note1'" "`note2'") nonotes






//end

/////////////////// FIGURES ////////////////////////
  
//-----------------------------
// 1. Timeline
//----------------------------- 

  // done

//-----------------------------
// 2. Illustration
//----------------------------- 

  // done

//-----------------------------
// 3. Killer graph
//----------------------------- 

clear
use ../data/dataset, replace

keep playername baseball debut year img

reshape wide img, i(playername) j(year)

gen diff = img2012 - img2008
gen before = (debut < 1964)

tabstat diff if baseball == 0, by(before) save
matrix stats=r(Stat1)
local bk_meanimgafter =  string(round(stats[1,1],0.001))
matrix stats=r(Stat2)
local bk_meanimgbefore =  string(round(stats[1,1],0.001))

tabstat diff if baseball == 1, by(before) save
matrix stats=r(Stat2)
local bb_meanimgbefore =  string(round(stats[1,1],0.001))
matrix stats=r(Stat1)
local bb_meanimgafter =  string(round(stats[1,1],0.001))


gen cutoff = 1963.5
by baseball before, sort: egen meangrp = mean(diff)
by baseball before, sort: egen segrp = semean(diff)

gen hi = meangrp + segrp
gen lo = meangrp - segrp

by debutyear baseball, sort: egen meandiff = mean(diff)
by debutyear baseball, sort: drop if _n > 1

// means are : 1.17, .60 (base) and .16 and 0.21
replace meandiff = 0.01 if meandiff == 0

tw (bar meandiff debutyear if debutyear < 1964, barwidth(0.75) color(gs2)) (bar meandiff debutyear if debutyear >= 1964, barwidth(0.75) color(gs8)) (line meangrp debutyear if debutyear < 1964, lcolor(gs8)) (line meangrp debutyear if debutyear >= 1964, lcolor(gs8)) if baseball==1,  title("Panel A : Baseball Players") xtitle("Player Debut Appearance Year") ytitle("Images Added After Digitization") xsca(titlegap(3) range(1944 1984) noextend) ysca(titlegap(2) range(-0.2 2.5)) xline(1963.5, noextend lcolor(gs4)) xlabel(1944(4)1984) ylabel(0(0.5)2.5,nogrid) text(-0.15 1948 "Mean Change = `bb_meanimgbefore'", place(e)) text(-0.15 1968 "Mean Change = `bb_meanimgafter'", place(e)) legend(label(1 "`nocopyright' (Before 1964)") label(2 "`incopyright' (After 1964)")) legend(order(1 2))

graph export "../tables/bb_changeimg.eps", replace

tw (bar meandiff debutyear if debutyear < 1964, barwidth(0.75) color(gs2)) (bar meandiff debutyear if debutyear >= 1964, barwidth(0.75) color(gs8)) (line meangrp debutyear if debutyear < 1964, lcolor(gs8)) (line meangrp debutyear if debutyear >= 1964, lcolor(gs8)) if baseball==0,  legend(off) title("Panel B : Basketball Players") xtitle("Player Debut Appearance Year") ytitle("Images Added After Digitization") xsca(titlegap(3) range(1944 1984) noextend) ysca(titlegap(2) range(-0.05 0.5)) xline(1963.5, noextend lcolor(gs4)) xlabel(1944(4)1984) ylabel(0(0.1)0.5,nogrid) text(-0.05 1948 "Mean Change = `bk_meanimgbefore'", place(e)) text(-0.05 1970 "Mean Change = `bk_meanimgafter'", place(e))

graph export "../tables/bk_changeimg.eps", replace

shell epstopdf "../tables/bb_changeimg.eps"
shell epstopdf "../tables/bk_changeimg.eps" 

//-----------------------------
// 4. Timeline Varying
//----------------------------- 

foreach var in "0" "1" {

  clear
  use ../data/dataset_allyear

  egen timeid = group(month year)
  bysort numplayer timeid: drop if _n > 1
  xtset numplayer timeid

  qui xtreg img before##b2008.year if baseball == `var', fe cluster(numplayer)

  qui parmest, label list(parm estimate min* max* p) saving(mypars, replace)

  clear
  use mypars

  keep if regexm(parm, "1.*before1964#20[0-9][0-9].*") == 1
  gen year = regexs(1) if regexm(parm, ".*#(20[0-9][0-9])b?\..*")
  destring year, replace
    
  qui gen xaxis = 0

  if "`var'" == "0"{
     local vartitle = "B : Basketball"
     local yt = ""
   }

  if "`var'" == "1"{
     local vartitle = "A : Baseball"
     local yt = "Mean Images / Page"
   }

   graph twoway (line estimate year, msize(small) lpattern(dash) lcolor(edkblue) lwidth(thin)) (line max year, lwidth(vthin) lpattern(-) lcolor(gs8)) (line min year, lwidth(vthin) lpattern(-) lcolor(gs8)) (line xaxis year, lwidth(vthin) lcolor(gs8)), yscale(range(-0.3 0.8)) xtitle("") ytitle("`yt'") xlabel(2006(1)2012) legend(off) title("Panel `vartitle' Players") ylabel(-0.2 (0.2) 0.8)

  graph export "../tables/timeline`var'.eps", replace
  shell epstopdf  "../tables/timeline`var'.eps"
}

//-----------------------------
// 5. Traffic Scatterplot
//----------------------------- 

clear
use ../data/dataset, replace

drop if baseballdummy == 0
keep if (year == 2008) | (year == 2012)
 
keep playername debut year img traf char appear inducted before1964
reshape wide img traf char, i(playername) j(year)

gen diffimg = (img2012 - img2008)
gen difftraf = (traf2012 - traf2008)

split playername, gen(names) parse(" ")
replace names2 = names2 + " " + names3 if names3 != ""
drop names3
 
corr difftraf diffimg 
local corr : di %4.3f r(rho)
corr difftraf diffimg if inducted == "Y"
local corrInduct : di %4.3f r(rho)

tw (scatter difftraf diffimg if debut<1964 & inducted == "Y", msymbol(oh) mcolor(navy) mlabel(names2)) (lfit difftraf diffimg if inducted == "Y", subtitle(correlation `corrInduct')),  xtitle("Change in Images between 2008 and 2011") ytitle("Change in Traffic Between 2008 and 2011") legend(off) xscale(range(0 8)) title (Panel A : Hall of Fame Inductees)

graph export "../tables/scatterimgtraf_a.eps", replace
shell epstopdf "../tables/scatterimgtraf_a.eps"

gen lndifftraf = ln(difftraf + 1)

tw (scatter difftraf diffimg if debut<1964, msymbol(x) mcolor(navy)) (lfit difftraf diffimg, subtitle(correlation `corr')), xtitle("Change in Images between 2008 and 2011") ytitle("Change in Traffic Between 2008 and 2011") legend(off) xscale(range(0 8)) title (Panel B : Full Baseball Sample)

graph export "../tables/scatterimgtraf_b.eps", replace
shell epstopdf "../tables/scatterimgtraf_b.eps"

//////////////////////
/////////// APPENDIX


//// LOG MODELS

//////////////////////
/// A1. Digitization
/////////////////////


clear
use ../data/dataset, replace
set matsize 10000

egen timeid = group(month year)
bysort numplayer timeid: drop if _n > 1
xtset numplayer timeid

gen lnimg = ln(img+1)
gen lnchar = ln(char+1)
gen lntraf = ln(traf+1)

est clear

eststo: qui xtreg lnimg baseball##post2008, fe cluster(numplayer)
estadd local fixed "Yes" , replace

eststo: qui xtreg lntraf baseball##post2008, fe cluster(numplayer)
estadd local fixed "Yes" , replace

eststo: qui xtreg lnchar baseball##post2008, fe cluster(numplayer)
estadd local fixed "Yes" , replace

local keepvar "_cons 1.baseball* 1.post*"
local note1 "Robust standard errors clustered at player level are reported"
local note2 "* p $<$ 0.10, ** p $<$ 0.05, *** p $<$ 0.01"

esttab using "../tables/a_digitization.tex", keep(`keepvar') order(1.baseballdummy#1.post2008 1.post2008) se ar2 nonotes star(* 0.10 ** 0.05 *** 0.01) coeflabels(1.post2008 "Post 2008" 1.baseballdummy#1.post2008 "Baseball X Post" _cons "Constant") mtitles("Ln(Images)" "Ln(Traf.)" "Ln(Text)") replace booktabs addnote("`note1'" "`note2'")  s(fixed r2_a N, label("Player FE" "adj. \$R^2\$")) width(0.75\hsize)

///////////////////////////////
//// A2. Copyright impact

clear
use ../data/dataset, replace
set matsize 10000

egen timeid = group(month year)
bysort numplayer timeid: drop if _n > 1
xtset numplayer timeid


gen lntraf = ln(traf+1)
gen lnimg = ln(img+1)
gen lnchar = ln(char+1)
 
est clear

eststo: xi: qui xtreg lnimg before##post2008 if baseball == 1, fe cluster(numplayer)
estadd local fixed "Yes" , replace

eststo: xi: qui xtreg lntraf before##post2008 if baseball == 1, fe robust cluster(numplayer)
estadd local fixed "Yes" , replace

eststo: xi: qui xtreg lnchar before##post2008 if baseball == 1, fe robust cluster(numplayer)
estadd local fixed "Yes" , replace

local note1 "Robust standard errors clustered at player level are reported"
local note2 "* p $<$ 0.10, ** p $<$ 0.05, *** p $<$ 0.01"

local keepvar "_cons 1.before1964#1.post2008 1.post*"
 
esttab using "../tables/a_baseline.tex", keep(`keepvar') order(1.before1964#1.post2008 1.post2008) se ar2 nonotes star(* 0.10 ** 0.05 *** 0.01) coeflabels(1.post2008 "Post 2008" 1.before1964#1.post2008 "`nocopyright' X Post" _cons "Constant") mtitles("Ln(Images)" "Ln(Traf)" "Ln(Text)") replace booktabs addnote("`note1'" "`note2'")  s(fixed r2_a N, label("Player FE" "adj. \$R^2\$")) width(0.75\hsize)


///////////////////////////
// A3. DDD

clear
use ../data/dataset

gen lntraf = ln(traf+1)
gen lnimg = ln(img+1)
gen lnchar = ln(char+1)

est clear

eststo: xi: qui xtreg lnimg before##post2008##baseball, fe clust(numplayer) i(numplayer)
estadd local fixed "Yes" , replace

eststo: xi: qui xtreg lntraf before##post2008##baseball, fe clust(numplayer) i(numplayer)
estadd local fixed "Yes" , replace


eststo: xi: qui xtreg lnchar before##post2008##baseball, fe clust(numplayer) i(numplayer)
estadd local fixed "Yes" , replace


local note1 "Robust standard errors clustered at player level are reported"
local note2 "* p $<$ 0.10, ** p $<$ 0.05, *** p $<$ 0.01"

 local keepvar "_cons 1.post2008 1.before1964#1.post2008 1.post2008#1.baseballdummy 1.before1964#1.post2008#1.baseballdummy"
 
esttab using "../tables/a_triplediff.tex", keep(`keepvar') order(1.before1964#1.post2008#1.baseballdummy 1.before1964#1.post2008 1.post2008#1.baseballdummy 1.post2008) se ar2 nonotes star(* 0.10 ** 0.05 *** 0.01) coeflabels(1.post2008 "Post 2008" 1.before1964#1.post2008 "`nocopyright' X Post" 1.before1964#1.post2008#1.baseballdummy "Post X Baseball X `nocopyright'" 1.post2008#1.baseballdummy "Post X Baseball" _cons "Constant") mtitles("Ln(Images)" "Ln(Traffic)" "Ln(Text)") replace booktabs addnote("`note1'" "`note2'")  s(fixed r2_a N, label("Player FE" "adj. \$R^2\$")) width(0.85\hsize)


/// PLACEBO CHARTS

//////////////////
// BASEBALL

foreach var in "appearances" "careerlength" "ageatdebut" "allstargames"{

clear
use ../data/dataset, replace
gen careerlength = substr(finalgame, -4,.)
destring careerlength, replace
replace careerlength = careerlength - debutyear
gen ageatdebut = debutyear - birthyear

keep playername baseball debut year `var'
keep if baseball == 1
reshape wide `var', i(playername) j(year)

gen diff = `var'2012

gen cutoff = 1963.5

gen before = (debut < 1964)
by baseball before, sort: egen meangrp = mean(diff)
by baseball before, sort: egen segrp = semean(diff)

gen hi = meangrp + segrp
gen lo = meangrp - segrp

by debutyear baseball, sort: egen meandiff = mean(diff)
by debutyear baseball, sort: drop if _n > 1

tabstat meandiff if baseball == 1, by(before) save
matrix stats=r(Stat1)
local meanafter_`var' =  round(stats[1,1],0.001)
matrix stats=r(Stat2)
local meanbefore_`var' =  round(stats[1,1],0.001)

  if "`var'" == "appearances"{
     local ytext = "1900"
     local yt = "Career Appearances"
     local title = "Panel A : Appearances"
     local ymax = "2000"
     local ylab = "0(500)2000"
     local leg = "off"
   }

  if "`var'" == "careerlength"{
     local yt = "Career Years Played"
     local ytext = "17.5"
     local title = "Panel B : Career Years Played"
     local ymax = "6 18"
     local ylab = "6(3)18"
     local leg = "off"
   }

  if "`var'" == "ageatdebut"{
     local yt = "Age at Debut"
     local ytext = "25"
     local title = "Panel C : Age at Debut"
     local ymax = "10 26"
     local ylab = "10(4)26"
     local leg = "order(1 2)"
   }
  if "`var'" == "allstargames"{
     local yt = "All Star Appearances"
     local ytext = "14"
     local title = "Panel D : All Star Appearances"
     local ymax = "0 15"
     local ylab = "0(3)15"
     local leg = "order(1 2)"
   }

tw (bar meandiff debutyear if debutyear < 1964, barwidth(0.75) color(gs2)) (bar meandiff debutyear if debutyear >= 1964, barwidth(0.75) color(gs8)) (line meangrp debutyear if debutyear < 1964, lcolor(gs8)) (line meangrp debutyear if debutyear >= 1964, lcolor(gs8)) if baseball==1,  xtitle("Player Debut Appearance Year") ytitle("`yt'") xsca(titlegap(3) range(1944 1984) noextend)  xline(1963.5, noextend lcolor(gs4)) xlabel(1944(4)1984)  legend(label(1 "`nocopyright' (Before 1964)") label(2 "`incopyright' (After 1964)")) legend(`leg') text(`ytext' 1950 "Mean = `meanbefore_`var''", place(e)) text(`ytext' 1970 "Mean = `meanafter_`var''", place(e)) title(`title') ysca(titlegap(2) range(`ymax')) ylabel(`ylab',nogrid)

graph export "../tables/change_`var'.eps", replace
shell epstopdf "../tables/change_`var'.eps" 

}

//////////////////
// BASKETBALL

foreach var in "minutes" "gp" "pts" "asts"{

clear
use ../data/dataset, replace


keep playername baseball debut year `var'
keep if baseball == 0
reshape wide `var', i(playername) j(year)

gen diff = `var'2012

gen cutoff = 1963.5

gen before = (debut < 1964)
by baseball before, sort: egen meangrp = mean(diff)
by baseball before, sort: egen segrp = semean(diff)

gen hi = meangrp + segrp
gen lo = meangrp - segrp

by debutyear baseball, sort: egen meandiff = mean(diff)
by debutyear baseball, sort: drop if _n > 1

tabstat meandiff if baseball == 0, by(before) save
matrix stats=r(Stat1)
local meanafter_`var' =  round(stats[1,1],0.01)
matrix stats=r(Stat2)
local meanbefore_`var' =  round(stats[1,1],0.01)

  if "`var'" == "minutes"{
     local ytext = "27000"
     local yt = "Career Appearances"
     local title = "Panel A : Career Minutes Played"
     local ymax = "30000"
     local ylab = "10000(5000)30000"
     local leg = "off"
   }

  if "`var'" == "gp"{
     local yt = "Appearances"
     local ytext = "900"
     local title = "Panel B : Appearances"
     local ymax = "100 1000"
     local ylab = "200(200)1000"
     local leg = "off"
   }

  if "`var'" == "pts"{
     local yt = "Points Scored"
     local ytext = "14000"
     local title = "Panel C : Points Scored"
     local ymax = "2000 14000"
     local ylab = "1000(4000)14000"
     local leg = "order(1 2)"
     local meanbefore_`var' = round(`meanbefore_`var'', 0.3)
     local meanafter_`var' = round(`meanafter_`var'', 0.3)

   }

  if "`var'" == "asts"{
     local yt = "Assists"
     local ytext = "3200"
     local title = "Panel D : Assists"
     local ymax = "500 3500"
     local ylab = "500(1000)3500"
     local leg = "order(1 2)"
   }


tw (bar meandiff debutyear if debutyear < 1964, barwidth(0.75) color(gs2)) (bar meandiff debutyear if debutyear >= 1964, barwidth(0.75) color(gs8)) (line meangrp debutyear if debutyear < 1964, lcolor(gs8)) (line meangrp debutyear if debutyear >= 1964, lcolor(gs8)) if baseball==0,  xtitle("Player Debut Appearance Year") ytitle("`yt'") xsca(titlegap(3) range(1944 1984) noextend)  xline(1963.5, noextend lcolor(gs4)) xlabel(1944(4)1984)  legend(label(1 "`nocopyright' (Before 1964)") label(2 "`incopyright' (After 1964)")) legend(`leg') text(`ytext' 1948 "Mean = `meanbefore_`var''", place(e)) text(`ytext' 1970 "Mean = `meanafter_`var''", place(e)) title(`title') ysca(titlegap(2) range(`ymax')) ylabel(`ylab',nogrid)

graph export "../tables/change_`var'.eps", replace
shell epstopdf "../tables/change_`var'.eps" 

}

////////////// ROBUSTNESS MISCLASSIFICATIOn

//-------------------------------------
// TABLE 4. DD for Images and Traffic for BB
//-------------------------------------

// HARDCODED BARCHART

// this code is only for demonstration
/* gen percent = (1964 - debut) / (finaly - debut) */
/* replace percent = 0 if percent <= 0  */
/* replace percent = 1 if percent >= 1 */

/* gen type = . */
/* replace type = 2 if percent == 1 */
/* replace type = 0 if percent == 0 */
/* replace type = 1 if type == . */

/* xtreg img c.percent##post2008, fe cluster(numplayer) */
/* xtreg img i.type##post2008, fe cluster(numplayer) */

/// hard code barchart
clear
gen barx = .
gen bary = .
set obs 3

replace barx = 1 if _n == 1
replace barx = 2 if _n == 2
replace barx = 3 if _n == 3

replace bary = 0.695 if _n == 1
replace bary = 0.695 + (0.559) if _n == 2
replace bary = 0.695 + (1.004) if _n == 3

tw (bar bary barx if _n == 1, color(gs10)) (bar bary barx if _n == 2, color(gs6)) (bar bary barx if _n == 3, color(gs2)) (scatter bary barx, msym(none) mlab(bary) mlabpos(11) mlabcolor(black)),  xtitle("Treatment Status") ytitle("Mean Images Added") legend(label(1 "Fully In-Copyright") label(2 "Partly In-Copyright") label(3 "Fully Out-of-Copyright") label(4 "")) xlabel(none)

graph export "../tables/robustkillerbar.eps", replace
shell epstopdf "../tables/robustkillerbar.eps"

/// ROBUST KILLER SCATTER

clear
use ../data/dataset, replace

drop if baseball == 0
destring finalyear, replace
keep playername debut finalyear year img 

reshape wide img, i(playername) j(year)

gen diff = img2012 - img2008
gen percent = (1964 - debut) / (finaly - debut)
replace percent = 0 if percent <= 0
replace percent = 1 if percent >= 1

replace percent = round(percent, 0.05)

collapse (mean) diff, by(percent)

replace percent = round(percent, 0.01)
replace diff = round(diff, 0.01)

gen percent2 = percent + 0.02

tw (bar diff percent, color(gs2) barwidth(0.03)) (scatter diff percent2, msym(none) mlab(diff) mlabpos(11) mlabcolor(black)),  xtitle("Percent Out-of-Copyright") ytitle("Mean Images Added") legend(off) 

graph export "../tables/robustkillerscatter.eps", replace
shell epstopdf "../tables/robustkillerscatter.eps"

/* HEIDI COMMENTS KILLER */

  //-----------------------------
// 3. Killer graph
//----------------------------- 

clear
use ../data/dataset, replace

drop if baseball == 0
destring finalyear, replace
keep playername debut finalyear year img 

reshape wide img, i(playername) j(year)

gen diff = img2012 - img2008
gen percent = (1964 - debut) / (finaly - debut)
replace percent = 1 if percent <= 0
replace percent = 1 if percent >= 1

gen before = (debut < 1964)

gen cutoff = 1963.5

by debutyear, sort: egen meanpct = mean(percent)
by debutyear, sort: egen meangrp = mean(diff)
by debutyear, sort: drop if _n > 1

gen meandiff = meangrp / meanpct

replace meanpct = 0.001 if debutyear>=1964
replace meanpct = meanpct * -1
replace meanpct = meanpct - 0.5

tw (bar meandiff debutyear if debutyear < 1964, barwidth(0.75) color(gs2)) (bar meandiff debutyear if debutyear >= 1964, barwidth(0.75) color(gs8)) (line meanpct debutyear, color(gs1)),  title("Change in Images for Baseball Players (Rescaled)") xtitle("Player Debut Appearance Year") ytitle("Images Added After Digitization (Rescaled)") xsca(titlegap(3) range(1944 1984) noextend) ysca(axis(1) titlegap(2) range(-0.2 2.5)) ysca(axis(1) titlegap(2) range(-1 0.1)) xline(1963.5, noextend lcolor(gs4)) xlabel(1944(4)1984) ylabel(0(0.5)5,nogrid)  text(-0.5 1948 "Percent In-Copyright", place(e)) legend(off)

legend(label(1 "`nocopyright' (Before 1964)") label(2 "`incopyright' (After 1964)")) legend(order(1 2))


graph export "../tables/bb_changeimg_rescale.eps", replace
shell epstopdf "../tables/bb_changeimg_rescale.eps" 

list debutyear meanpct

/* NOT USED */

/// ROBUSTKILLER 2

clear
use ../data/dataset, replace
set matsize 10000

keep if (year == 2008) | (year == 2012)
keep if baseball == 1

egen timeid = group(month year)
bysort numplayer timeid: drop if _n > 1
xtset numplayer timeid

tabstat img traf char if baseball == 1, save
matrix stats=r(StatTotal)
local meanimg =  round(stats[1,1],0.001)
local meantraf =  round(stats[1,2],0.001)
local meanchar =  round(stats[1,3],0.001)

gen lntraf = ln(traf+1)
gen lnimg = ln(img+1)

destring finaly, replace
gen m = (1964 - debut)
gen n = (finaly - debut)


est clear


eststo: qui xtreg img before##post2008 if baseball == 1, fe cluster(numplayer)
estadd local fixed "Yes" , replace

eststo: qui xtreg traf before##post2008 if baseball == 1, fe cluster(numplayer)
estadd local fixed "Yes" , replace

eststo: qui xtreg char before##post2008 if baseball == 1, fe cluster(numplayer)
estadd local fixed "Yes" , replace


local note1 "Robust standard errors clustered at player level are reported"
local note2 "* p $<$ 0.10, ** p $<$ 0.05, *** p $<$ 0.01"
local note3 "Mean(Images) = `meanimg', Mean(Traffic) = `meantraf', Mean(Text)=`meanchar'"

local keepvar "_cons 1.before1964#1.post2008 1.post*"
 
esttab using "../tables/baseline.tex", keep(`keepvar') order(1.before1964#1.post2008 1.post2008) se ar2 nonotes star(* 0.10 ** 0.05 *** 0.01) coeflabels(1.post2008 "Post 2008" 1.before1964#1.post2008 "`nocopyright' X Post" _cons "Constant") mtitles("Images" "Traffic" "Text") replace booktabs addnote("`note1'" "`note2'" "`note3'")  s(fixed r2_a N, label("Player FE" "adj. \$R^2\$")) width(0.75\hsize)



////////////////
ROBUSTNESS KILLER GRAPH
////////////////

robustkiller 0.999 99
robustkiller 0.9 90
robustkiller 0.8 80
robustkiller 0.7 70
robustkiller 0.6 60  
robustkiller 0.5 50  

capture program drop robustkiller
program define robustkiller

clear
use ../data/dataset, replace

local decay `1'
local decayname `2'

drop if baseball == 0
destring finalyear, replace
keep playername debut finalyear year img 

reshape wide img, i(playername) j(year)

gen r = `decay'

// set percent
gen percentafter64 = .
replace percent = 1 if debut > 1963
replace percent = 0 if final < 1964

gen overlap = (percent == .)

gen m = (1964 - debut) if overlap == 1
gen n = (finaly - debut) if overlap == 1

gen scale = (1-r^m) / (1-r^n)
replace scale = round(1 - scale, 0.01)
replace percent = 1 - scale if overlap == 1

replace overlap = (percent > 0) & (percent < 1)

gen diff = img2012 - img2008 if overlap == 0
replace diff =  (img2012 - img2008)/ (percent) if overlap == 1

by debut, sort: egen meandiff = mean(diff)
by debut, sort: drop if _n > 1

replace meandiff = 0.01 if meandiff == 0

tw (bar meandiff debutyear if debutyear < 1964, barwidth(0.75) color(gs2)) (bar meandiff debutyear if debutyear >= 1964, barwidth(0.75) color(gs8)), title("Baseball Players") xtitle("Player Debut Appearance Year") ytitle("Images Added After Digitization") xsca(titlegap(3) range(1944 1984) noextend) ysca(titlegap(2) range(-0.2 2.5)) xline(1963.5, noextend lcolor(gs4)) xlabel(1944(4)1984) ylabel(0(0.5)2.5,nogrid) text(2.5 1968 "Hazard(r) = `decayname'%", place(e)) legend(label(1 "`nocopyright' (Before 1964)") label(2 "`incopyright' (After 1964)")) legend(order(1 2))

graph export "../tables/decay_bb_changeimg_`decayname'.eps", replace
shell epstopdf "../tables/decay_bb_changeimg_`decayname'.eps"
end
  
////////////////
ROBUSTNESS KILLER GRAPH
////////////////

robustkiller 0.999 99
robustkiller 0.9 90
robustkiller 0.8 80
robustkiller 0.7 70
robustkiller 0.6 60  
robustkiller 0.5 50  

capture program drop robustkiller
program define robustkiller2

clear
use ../data/dataset, replace

local decay `1'
local decayname `2'

local decay 0.99
local decayname 99


drop if baseball == 0
destring finalyear, replace
keep playername debut finalyear year img 

reshape wide img, i(playername) j(year)

gen r = `decay'

// set percent
gen percentafter64 = .
replace percent = 1 if debut > 1963
replace percent = 0 if final < 1964

gen overlap = (percent == .)
replace overlap = 0 if (1964 - debut) >= 5

gen m = (1964 - debut) if overlap == 1
gen n = (finaly - debut) if overlap == 1

gen scale = (1-r^m) / (1-r^n)
replace scale = round(1 - scale, 0.01)
replace percent = 1 - scale if overlap == 1

replace overlap = (percent > 0) & (percent < 1)

gen diff = img2012 - img2008 if overlap == 0
replace diff =  (img2012 - img2008)/ (percent) if overlap == 1

by debut, sort: egen meandiff = mean(diff)
by debut, sort: drop if _n > 1

replace meandiff = 0.01 if meandiff == 0

tw (bar meandiff debutyear if debutyear < 1964, barwidth(0.75) color(gs2)) (bar meandiff debutyear if debutyear >= 1964, barwidth(0.75) color(gs8)), title("Baseball Players") xtitle("Player Debut Appearance Year") ytitle("Images Added After Digitization") xsca(titlegap(3) range(1944 1984) noextend) ysca(titlegap(2) range(-0.2 2.5)) xline(1963.5, noextend lcolor(gs4)) xlabel(1944(4)1984) ylabel(0(0.5)2.5,nogrid) legend(label(1 "`nocopyright' (Before 1964)") label(2 "`incopyright' (After 1964)")) legend(order(1 2))

graph export "../tables/decay_bb_changeimg_`decayname'.eps", replace
shell epstopdf "../tables/decay_bb_changeimg_`decayname'.eps"
end


///////////////////////
///// POISSON
  
clear
use ../data/dataset

gen int1 = before*post2008
gen int2 = baseball*post2008
gen int3 = before*post2008*baseball


xtset playerid year

xtreg hasimg before##post2008##baseball, fe clust(numplayer) i(playerid)

xtpoisson hasimg before##post2008##baseball, fe vce(robust)

xtpoisson img before##post2008##baseball, fe vce(robust)

xtpoisson img before##post2008##baseball, fe vce(robust)

xtpoisson img before##post2008 if baseball == 1, fe vce(robust)


xtpoisson img before##post2008##baseball, fe vce(robust)

xtnbreg img before##post2008##baseball, fe 

poisson traf before##post##baseball, robust



xtpqml img post2008 int1 if baseball == 1, fe i(playerid) cluster(playerid)

xtpqml img post2008 int1 int2 int3, fe i(playerid) cluster(playerid)


xtpqml traf post2008 int1 int2 int3, fe i(playerid) cluster(playerid)


gen lntraf = ln(traf+1)
gen lnimg = ln(img+1)
gen lnchar = ln(char+1)

egen playerid = group(playername)
xtset playerid year


xtpoisson img int1 int2 int3 post, fe vce(boot, reps(100) seed(10101))


xtpoisson img post2008 int1 if baseball == 1, fe vce(boot, reps(100) seed(10101))


xtpoisson img post2008 int1 int2 int3

xtpoisson traf post2008 if baseball == 1, fe vce(robust)

xtpoisson traf post2008 if baseball == 1, fe vce(robust)


reg img before##post2008 if baseball == 1

gen hasimg = (img > 0)

xtreg hasimg before##post2008##baseball, robust



xtpoisson img post2008 int1 if baseball == 1, fe vce(robust)



xtpoisson img before##post2008 if baseball == 1





xtreg img before##post2008 if baseball == 1, fe vce(robust)

est clear

eststo: xi: qui xtreg lnimg before##post2008##baseball, fclust(numplayer) i(numplayer)
estadd local fixed "Yes" , replace

eststo: xi: qui xtreg lntraf before##post2008##baseball, fe clust(numplayer) i(numplayer)
estadd local fixed "Yes" , replace


eststo: xi: qui xtreg lnchar before##post2008##baseball, fe clust(numplayer) i(numplayer)
estadd local fixed "Yes" , replace


local note1 "Robust standard errors clustered at player level are reported"
local note2 "* p $<$ 0.10, ** p $<$ 0.05, *** p $<$ 0.01"

 local keepvar "_cons 1.post2008 1.before1964#1.post2008 1.post2008#1.baseballdummy 1.before1964#1.post2008#1.baseballdummy"
 
esttab using "../tables/a_triplediff.tex", keep(`keepvar') order(1.before1964#1.post2008#1.baseballdummy 1.before1964#1.post2008 1.post2008#1.baseballdummy 1.post2008) se ar2 nonotes star(* 0.10 ** 0.05 *** 0.01) coeflabels(1.post2008 "Post 2008" 1.before1964#1.post2008 "`nocopyright' X Post" 1.before1964#1.post2008#1.baseballdummy "Post X Baseball X `nocopyright'" 1.post2008#1.baseballdummy "Post X Baseball" _cons "Constant") mtitles("Ln(Images)" "Ln(Traffic)" "Ln(Text)") replace booktabs addnote("`note1'" "`note2'")  s(fixed r2_a N, label("Player FE" "adj. \$R^2\$")) width(0.85\hsize)







