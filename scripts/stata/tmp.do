// things that i need

/* NEW

Tables
1. summary stats : Sample A and Sample B
2. compare reuse outcomes -- sample B
3. copyright on reuse -- sample A
4. copyright on reuse -- sample B (digitization, interaction, DDD)
5. copyright on traffic -- sample B
6. heterogenous effects -- sample B

Figures

1. illustration
2. killer pic using Sample A and Sample B
3. DD timeline charts using Sample A
4. images and traffic - sample B
5. hetero effects - sample B

*/



/* OLD
Tables:
    
1. summary stats
2. compare reuse outcomes
3. DD of digitization
4. DD copyright
5. DDD copyright
6. DD copyright on traffic
7. IV estimation

Figures:
1. illustration
2. killer pic
3. DD timeline charts
4. images and traffic
5. hetero effects
    
*/
use ${stash}citelines, clear

bysort citeyear: egen numimg2008 = max(numimg*(year==2008))
tabstat numimg2008, by(treat)

use ${stash}master, clear

drop if isbaseball == 0
drop if year < 2004



bysort playerid: egen img2008 = max(img*(year==2008))
gen hadpic = img2008 > 0

bysort playerid: gen tag=_n==1

tabstat img2008, by(treat)

xtreg img 1.post#1.treat i.year, fe vce(cluster playerid)

xtreg img 1.post#1.treat##1.hadpic i.year, fe vce(cluster playerid)

xtreg img 1.post#1.treat##i.img2008 i.year, fe vce(cluster playerid)

est clear
eststo: xtreg img 1.post#1.treat i.year if hadpic==0, fe vce(cluster playerid)
eststo: xtreg img 1.post#1.treat i.year if hadpic==1, fe vce(cluster playerid)
eststo: xtreg lnimg 1.post#1.treat i.year if hadpic==0, fe vce(cluster playerid)
eststo: xtreg lnimg 1.post#1.treat i.year if hadpic==1, fe vce(cluster playerid)

esttab, keep(1.post#1.treat) p star

xtreg lnimg 1.post#1.treat##i.img2008 i.year, fe vce(cluster playerid)


gen lnimg

codebook img2008 if tag == 1

gen qt = 0
replace qt = 1 if img2008 > 0 & qt < 1
replace qt = 2 if img2008 > 1 & qt < 2
replace qt = 3 if img2008 > 2 & qt < 3
tab qt if tag == 1

gen total = img + text

destring size, ignore("NA") replace 
xtreg size 1.post#1.treat i.year, fe vce(cluster playerid)

xtreg img 1.post#1.treat i.year, fe vce(cluster playerid)

xtreg img 1.post#1.treat##i.qt i.year, fe vce(cluster playerid)

xtreg bd 1.post#1.treat##i.qt i.year, fe vce(cluster playerid)




use ${stash}master, clear

drop if isbaseball == 0

bysort playerid: egen traf2008 = max(traf*(year==2008))
bysort playerid: gen tag=_n==1

codebook traf2008 if tag == 1

gen qt = 0
replace qt = 1 if traf2008 > 8.2 & qt < 1
replace qt = 2 if traf2008 > 19.56 & qt < 2
replace qt = 3 if traf2008 > 54.012 & qt < 3

gen total = img + text

xtreg img 1.post#1.treat i.year, fe vce(cluster playerid)

xtreg img 1.post#1.treat##i.qt i.year, fe vce(cluster playerid)

xtreg text 1.post#1.treat##i.qt i.year, fe vce(cluster playerid)


xtreg img 1.post

use ${stash}citelines, clear
    
use ${stash}master, clear

drop if isbaseball == 0

bysort playerid: egen imgpre = max((!post)*img)
bysort playerid: gen tag=_n==1

gen hadpic = imgpre > 0
replace imgpre = 0 if imgpre == 0
replace imgpre = 1 if imgpre == 1
replace imgpre = 2 if imgpre > 1




foreach x in 0 1 2 {
    foreach y in 1 2 3 4 {
        qui xtreg img 1.treat#1.post i.year if imgpre == `x' & quality==`y', fe vce(cluster playerid)
        mat beta=e(b)
        local coeff=beta[1,1]
        di "Imgpre: `x' | Quality: `y' | `coeff'"
    }
}

est clear
foreach x in bd img text{
    eststo: qui xtreg `x' treat##post##imgpre i.year, fe vce(cluster playerid)
}

esttab, keep(1.treat#1.post 1.treat#1.post#1.hadpic)

esttab, keep(1.treat#1.post 1.treat#1.post#1.imgpre 1.treat#1.post#2.imgpre) varwidth(30)


xtreg img treat##post##hadpic i.year, fe vce(cluster playerid)

xtreg img treat##post##hadpic i.year, fe vce(cluster playerid)

xtreg img 1.treat#1.post 1.treat#1.post#1.hadpic 1.post#1.hadpic i.year, fe vce(cluster playerid)

xtreg img 1.treat#1.post i.year if hadpic == 0, fe vce(cluster playerid)
xtreg img 1.treat#1.post i.year if hadpic == 1, fe vce(cluster playerid)

xtreg img 1.treat#1.post 1.treat#1.post#i.imgpre i.year, fe vce(cluster playerid)

xtreg img 1.treat#1.post 1.treat#1.post#1.hadpic i.year, fe vce(cluster playerid)


use ${stash}master, clear

merge m:1 year isbaseball using ${stash}gtrends
, keep(match) nogen

fvset base 2012 year
gen gt2 = gt^2
gen gt3 = gt^3
gen gt4 = gt^4

xtreg img 1.post#1.isbaseball i.year gt*, fe vce(cluster playerid)
xtreg img 1.post#1.isbaseball i.year, fe vce(cluster playerid)

// google trends data construction
insheet using ${rawdata}gtrends.csv, clear
gen year = substr(week,1,4)
destring year, replace
collapse baseball basketball, by(year)
rename baseball gt1
rename basketball gt0
reshape long gt, i(year) j(isbaseball)
drop if year > 2012
save ${stash}gtrends, replace

use ${stash}master, clear

replace post = year >=2006
drop if isbaseball ==0
drop if year > 2010

est clear
eststo: qui xtreg img 1.post#1.treat i.year, fe vce(cluster playerid)
eststo: qui xtreg text 1.post#1.treat i.year, fe vce(cluster playerid)
eststo: qui xtreg bd 1.post#1.treat i.year, fe vce(cluster playerid)
esttab, keep(1.post#1.treat) se



use ${stash}citelines, clear
fvset base 2007 year

est clear
replace post = year >=2007
eststo: qui xtreg numcite 1.post#1.treat i.year if year < 2010, fe vce(cluster citeyear)
eststo: qui xtreg numimg 1.post#1.treat i.year if year < 2010, fe vce(cluster citeyear)
eststo: qui xtreg numtext 1.post#1.treat i.year if year < 2010, fe vce(cluster citeyear)

use ${stash}master, clear
fvset base 2007 year
drop if isbaseball==0
replace post = year >=2007
esttab, keep(1.post#1.treat)
eststo: qui xtreg img 1.post#1.treat i.year if year < 2010, fe vce(cluster playerid)
eststo: qui xtreg text 1.post#1.treat i.year if year < 2010, fe vce(cluster playerid)
eststo: qui xtreg bd 1.post#1.treat i.year if year < 2010, fe vce(cluster playerid)

esttab, keep(1.post#1.treat)


xtreg numcite 1.post#1.treat i.year if year < 2009, fe vce(cluster citeyear)


replace post = year >=2007
    
replace post = year 

xtreg numcite 1.post#1.treat i.year if year < 2009, fe vce(cluster citeyear)

xtreg numimg 1.post#1.treat i.year if year < 2009, fe vce(cluster citeyear)
xtreg numtext 1.post#1.treat i.year if year < 2009, fe vce(cluster citeyear)

gen post2 = year > 2011
gen post2 = year > 2010
xtreg numimg 1.post#1.treat i.year, fe vce(cluster citeyear)
xtreg numimg 1.post2#1.treat i.year, fe vce(cluster citeyear)


bysort year: egen totalcites = total(numcites)
bysort year: drop if _n > 1
list year totalcites

tabstat numcites, by(year)
tabstat numcites, by(year)


xtset citeyear year

xtreg numtext 1.post#1.treat i.year, fe vce(cluster citeyear)

xtreg numimg 1.post#1.treat i.year, fe vce(cluster citeyear)

gen lnimg = ln(numimg+1)
gen lntext = ln(numtext+1)

xtreg lnimg 1.post#1.treat i.year, fe vce(cluster citeyear)
xtreg lntext 1.post#1.treat i.year, fe vce(cluster citeyear)


xtpoisson numtext 1.post#1.treat i.year, fe







insheet using ../python/bdcites1.csv, clear

insheet using ../python/bdcites2.csv, clear

insheet using ../python/citelines.csv, clear

drop if v1 == "NA"
unique v2

// records 4571
insheet using ../python/searchcites.csv, clear
drop if v1 == "NA"
unique v2
save ${stash}searchcites, replace

insheet using ../python/searchcites_plus.csv, clear
drop if v1 == "NA"
unique v2
append using ${stash}searchcites
bysort v1 v2 v3 v4: gen dups = _N

insheet using ../python/searchcites_percent.csv, clear
drop if v1 == "NA"
unique v2

// records 4524


use ${stash}citelines, replace

reg numcites 1.treat#1.post 1.treat 1.post, robust

xtreg numcites 1.treat#1.post 1.post, fe cluster(citeyear)

xtreg numtext 1.treat#1.post 1.post, fe cluster(citeyear)



xtreg numimg 1.treat#1.post 1.post, fe cluster(citeyear)


xtreg numcites 1.treat#1.post i.year, fe cluster(citeyear)

xtpoisson numcites 1.treat#1.post i.year, fe vce(robust)


keep if year == 2013

list citeyear numcites



insheet using ${cite}pageinfo_kimono.csv,clear nonames
drop if v2 == "Date/Time"



use ${stash}citelines_text, clear

drop if year == "Punchball"

destring year, replace

bysort citeyear year: gen numcites = _N
bysort citeyear year: drop if _n > 1

keep citeyear year numcites
drop if citeyear < 1944 | citeyear > 1984

tsset citeyear year
tsfill, full

replace numcites = 0 if numcites == .

gen treat = citeyear < 1964
gen post = year > 2008

tabstat numcites if post == 0, by(treat)
tabstat numcites if post == 1, by(treat)

gen lncites = ln(numcites+1)


xtreg numcites 1.treat#1.post i.year,fe cluster(citeyear)

xtreg lncites 1.treat#1.post i.year,fe cluster(citeyear)

xtpoisson numcites 1.treat#1.post i.post,fe vce(robust)

xtreg numcites 1.treat#1.post i.post,fe cluster(citeyear)




tabstat numcites, by(citeyear)

xtset citeyear year

xtpoisson numcites treat##post,fe cluster(citeyear)

reg numcites 1.treat##1.post, robust


xtpoisson numcites treat##post,fe vce(robust) irr

xtreg lncites treat##post,fe vce(robust)




insheet using ../../rawdata/stash/citelines.csv, clear tab

insheet using ../python/citelines.csv, clear tab





############


insheet using ${rawdata}kimono/kimono_content.csv, clear names
gen isfile = 0
save ${stash}kimono_tmp, replace

insheet using ${rawdata}kimono/kimono_images.csv, clear names
gen isfile = 1
drop imagefilesrc imagefilealt imagefiletext

append using ${stash}kimono_tmp
drop if isfile == 1

replace titlehref = subinstr(titlehref, "http://en.wikipedia.org/wiki/", "",1)

save ${stash}kimono_data, replace

outsheet using ${stash}kimono_data.csv, replace noquote nonames



// what are the issues?

1. why do player fixed effects make no difference?
2. can I use poisson?
3. 

use ${stash}master, clear

summ text bd img

drop if isb == 0

xtreg img treat##post##quality i.$fe, fe vce(robust)

reg img treat##post i.$fe i.id, vce(cluster id) fe

reg img treat##post i.$fe i.id, vce(robust)

areg img treat##post i.$fe, absorb(id)

reg img treat##post i.$fe, vce(cluster id)

xtreg img treat##post i.$fe, fe i(id) vce(robust)


gen percent = (1964 - debut) / (finaly - debut)
replace percent = 0 if percent <= 0
replace percent = 1 if percent >= 1

keep playername debut year img traf everinducted treat id numallstar percent

reshape wide img traf, i(playername) j(year)

gen diffimg = (img2013 - img2008)
gen difftraf = (traf2013 - traf2008)

bysort id: gen tag=_n==1

scatter lnd percent || lfit lnd percent

graph export "${tables}tmp.eps", replace
shell epstopdf "${tables}tmp.eps"

replace difftraf = 0 if difftraf < 0
gen lnt = ln(difftraf+1)
gen lni = ln(diffimg+1)

est clear
eststo: reg diffimg percent, robust
eststo: reg lni percent, robust
eststo: reg difftraf percent, robust
eststo: reg lnt percent, robust

esttab, keep(percent) p

bysort id: gen tag=_n==1

tab percent if tag == 1
gen exposure = 

reg 



xtreg img treat##post##quality i.$fe, fe vce(robust)

xtreg traf treat##post##quality i.$fe, fe vce(robust)

bysort id: gen tag=(_n==1)
tab qual if tag == 1

gen q1 = (quality<=2)

xtreg img treat##post##q1 i.$fe, fe vce(robust)


list img year wikih treat isbaseb if id == 692

bysort treat: tabstat img if isb==1, by(year)

keep if isb==1

replace img = img>0

xtpoisson img treat##post i.${fe} if year>2004, fe vce(robust)

xtlogit img treat##post i.${fe}, fe

logit img treat##post

reg img treat##post i.$fe i.id


bysort id: egen maximg=max(img)
unique id if maximg == 0

xtreg img treat##post i.$fe, fe vce(robust)

reg img treat##post i.$fe, vce(cluster id)

reg img treat##post i.$fe i.id, vce(cluster id)

areg img treat##post i.$fe, absorb(id) vce(cluster id)

xtreg img treat##post i.$fe, fe vce(cluster id)

reg img treat##post i.$fe, vce(cluster id)



xtreg img treat##post i.${fe} if isb==1, fe vce(robust)

xtreg img 1.treat#1.post i.${fe} if isb==1, fe vce(robust)


reg img 1.treat##1.post i.${fe} i.id if isb==1, vce(cluster id)



replace img = (img>0)

hist lnimg if img>0, freq
graph export "${tables}tmp.eps", replace


drop if isbaseball == 0

poisson img treat##post, vce(robust)

xtreg img treat##post i.year, fe vce(robust)
xtreg lnimg treat##post i.year, fe vce(robust)

bysort id: egen maximg = max(img)

xtpoisson img treat##post i.year if maximg>0 & year>2002, fe vce(robust)

xtnbreg img treat##post, fe


gen tvar = isbaseball

xtset id year

xtreg img tvar##post i.qy, fe vce(robust)

local var "img"

est clear

xtreg img 1.tvar#1.post i.${fe}, cluster(id)


eststo: xtreg `var' 1.tvar#1.post i.${fe}, cluster(id)

eststo: xtreg `var' 1.tvar#1.post i.dy, fe vce(robust)

eststo: xtreg `var' 1.tvar#1.post, fe vce(robust)

esttab, keep(1.tvar#1.post)


reg img 1.tvar#1.post 1.tvar i.${fe}, vce(cluster id)

reg img 1.tvar#1.post 1.tvar i.${fe} i.quality, vce(cluster id)



drop if isb == 0

replace treat = isbase

reg bd 1.treat 1.treat#1.post i.$fe, cluster(id)
reg img 1.treat 1.treat#1.post i.$fe, cluster(id)
reg text 1.treat 1.treat#1.post i.$fe, cluster(id)

xtreg bd 


keep if isb == 1
keep if year == 2013

est clear
estpost ttest bd img text traf, by(treat)

esttab, wide nonumber noisily cells(`"mu_1 mu_2 b(fmt(a3) nostar) p_l(fmt(2) par("{ralign @modelwidth:{txt:(}" "{txt:)}}"))"') mlabels("") collabels("in-copy mean" "out-of-copy mean" "diff" "p-val") noobs

stats(N, fmt(%18.0g) labels(`"N"')) 


mtitles("In-Copyright out-of-copy")


stats(N_1 N_2, fmt(%18.0g) labels(`"N"'))


cells(b se)


esttab est1 est2 est3 est4,c(mu_1 mu_2 t p) label


estout e(mu_1) e(mu_2) e(b) e(p_l)
esttab e(mu_1) e(mu_2) e(b) e(p_l)

estpost ttest mpg,by(foreign)



makematrix test, (e(mu_1) e(m_2)

keep if year == 2013

estpost ttest img, by(treat)

esttab

estpost ttest price mpg headroom trunk, by(foreign)

bysort id: gen tag=_n==1

sum gp if tag == 1 & isb == 1
sum cl if tag == 1 & isb == 1

sum gp if tag == 1 & isb == 0
sum pts if tag == 1 & isb == 0
sum cl if tag == 1 & isb == 0

gen cl = finaly - debuty
replace cl = lasty - debuty if isb == 0

codebook cl

sum gp if tag == 1 & isb == 1


list year img text bd traf if wikih == "Johnny_Callison"

list year img text bd traf if wikih == "Felipe_Alou"



xt

tab year if isbaseball == 0


xtreg lntraf treat##post##isbaseball i.$fe, fe vce(robust)

xtpoisson traf treat##post##isbaseball i.$fe, fe vce(robust)

xtnbreg traf treat##post##isbaseball i.$fe, fe vce(bootstrap)

xtnbreg traf treat##post##isbaseball i.$fe, fe vce(bootstrap)


xtreg lntraf treat##post##isb if tag==1, fe vce(robust)

xtpoisson traf treat##post##isb if tag==1, fe vce(robust)
xtreg lntraf treat##post##isb if tag==1, fe vce(robust)

xtpoisson traf treat##post##isbaseball i.$fe if isb==1 & tag==1, fe vce(robust)

gen tag = year==2007 | year==2013

xtnbreg traf treat##post i.$fe if isb==1 & tag==1, fe vce(bootstrap)


xtreg lntraf treat##post  i.$fe if isb==1, fe vce(robust)

fvset base 2013 year

local int 1.treat#1.post#1.isbaseball
local x1 1.treat#1.post
local x2 1.isbaseball#1.post

xtreg img `int' `x1' `x2' i.$fe, fe cluster(id)

xtreg img treat##post##isbaseball i.$fe, fe cluster(id)

unique id if overlap == 1

xtreg traf 1.treat#1.post if isb==1, fe vce(robust)

xtreg traf 1.treat#1.post i.$fe if isb==1, fe vce(robust)

xtreg traf 1.treat#1.post#1.isb 1.post#1.treat 1.post#1.isb i.$fe, fe vce(robust)














drop if isbaseball == 0

xtreg img 1.treat#1.post i.${fe}, fe vce(robust)

keep if year == 2013 | year == 2008

keep if isbase == 1

ttest img, by(treat)
ttest text, by(treat)
ttest traf, by(treat)
ttest bd, by(treat)

ttab img traf, by(treat)


xtreg avgsize post##treat i.year if isb==1, fe vce(robust)

xtreg avgsize post##isb i.year, fe vce(robust)

xtreg avgsize post##isb##treat i.year, fe vce(robust)

xtreg avgsize post##isb##treat i.year, fe vce(robust)

replace avgsize = avgsize/1024


keep if isbaseball == 1

xtpoisson numrev post##treat i.year, fe vce(robust)
xtreg numrev post##treat i.year, fe vce(robust)


xtreg lnbd post##treat##isb i.qy if year, fe vce(robust)


xtreg traf post##treat i.qy if year, fe vce(robust)

xtreg numrev post##treat i.qy if year, fe vce(robust)



xtpoisson numrev post##treat i.year, fe vce(robust)


xtreg lnnumrev post##treat i.year, fe vce(robust)


gen lnnumrev = ln(numrev+1)

use ${stash}revlist, clear

merge m:1 wikihandle using ${stash}bbk_master, keep(match) nogen

gen year = year(dofc(tstamp))
gen isreg  = regexm(user, "[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+") != 1

keep if isbaseball == 1
keep if isreg == 1

sort user tstamp
bysort user: gen firstyear = year[1]

drop if firsty > 2008

bysort user year: gen numcontrib = _N
bysort user year: drop if _n > 1

egen userid = group(user)

tsset userid year

tsfill, full

local outcomes "numcontrib"
foreach x in `outcomes'{
        replace `x' = 0 if `x' == .
}

local covars "user debutyear"

gen unitid = userid
foreach x in `covars'{
    gsort unitid year
    bysort unitid: carryforward `x', gen(tmp1)
    gsort unitid -year
    bysort unitid: carryforward tmp1, gen(tmp2)
    replace `x' = tmp2
    drop tmp1 tmp2
    di "finished `x'"
    di "---"
}

gen treat = (debutyear < 1964)
gen post = (year>2008)

gen lnnumc = ln(numcontrib+1)

xtreg lnnumc post##treat i.year, fe vce(robust)
xtreg numcontrib post##treat i.year, fe vce(robust)





tsset user year

bysort user

unique user if firsty < 2008



unique user if isreg == 1






use ${stash}master, clear

drop if isb == 0

local ln "ln"
local ln ""

est clear
eststo: qui xtreg `ln'numrev 1.treat##1.post i.year, fe vce(robust)
eststo: qui xtreg `ln'numuser 1.treat##1.post i.year, fe vce(robust)
eststo: qui xtreg `ln'numregusers 1.treat##1.post i.year, fe vce(robust)
eststo: qui xtreg `ln'numnewregion 1.treat##1.post i.year, fe vce(robust)
eststo: qui xtreg `ln'numnewregion_wiki 1.treat##1.post i.year, fe vce(robust)
esttab, keep(1.treat#1.post) p


est clear
eststo: qui xtreg `ln'numnew_page 1.treat##1.post i.year, fe vce(robust)
eststo: qui xtreg `ln'numnew_wiki 1.treat##1.post i.year, fe vce(robust)
eststo: qui xtreg `ln'numnewreg_wiki 1.treat##1.post i.year, fe vce(robust)
eststo: qui xtreg `ln'numnewreg_page 1.treat##1.post i.year, fe vce(robust)
esttab, keep(1.treat#1.post) p


est clear
eststo: qui xtreg `ln'numserious1 1.treat##1.post i.year, fe vce(robust)
eststo: qui xtreg `ln'numserious3 1.treat##1.post i.year, fe vce(robust)
eststo: qui xtreg `ln'numserious21 1.treat##1.post i.year, fe vce(robust)
eststo: qui xtreg `ln'numserious278 1.treat##1.post i.year, fe vce(robust)
eststo: qui xtreg `ln'numserious1851 1.treat##1.post i.year, fe vce(robust)
esttab est1 est2 est4 est5, keep(1.treat#1.post) p


est clear
eststo: qui xtreg `ln'numcountry 1.treat##1.post i.year, fe vce(robust)
eststo: qui xtreg `ln'numregion 1.treat##1.post i.year, fe vce(robust)
eststo: qui xtreg `ln'numtime 1.treat##1.post i.year, fe vce(robust)
esttab, keep(1.treat#1.post) p





gen numnew

xtreg lnimg 1.treat##1.post##quality i.year, fe vce(robust)

xtpoisson traf 1.treat##1.post##isb i.year if year> 2006, fe vce(robust)



xtreg numcountry treat##post##isb i.year, fe vce(robust)
xtreg lnnumcountry treat##post##isb i.year, fe vce(robust)

xtreg numtime treat##post i.year, fe vce(robust)

xtreg lnnumtime treat##post i.year, fe vce(robust)

xtreg lnnumcountry treat##post##isb i.year, fe vce(robust)

xtreg lnnumregion treat##post i.year, fe vce(robust)





use ${stash}revlist, clear

outsheet tstamp lat lon city countryn using ${stash}ip_geo_map.csv if cityname !="", replace


bysort user: gen tmp = _n

outsheet revid user using ${stash}ip.csv if isreg == 0 & tmp == 1, replace

use ${stash}master, clear

local vars "numrev numuser numreguser numnew_wiki numnew_pagenumnewreg_wiki numnewreg_page" 

drop if isb == 0

local vars "18 39 112 324 791"

est clear
foreach x in `vars'{
    eststo: qui xtreg numserious`x' treat##post i.year, fe vce(robust)
}

local vars "user reguser new_wiki new_page newreg_wiki newreg_page"

est clear
foreach x in `vars'{
    eststo: qui xtreg num`x' treat##post i.year, fe vce(robust)
}


esttab est1 est2 est3, keep(1.treat#1.post) p
esttab est4 est5 est6, keep(1.treat#1.post) p


use ${stash}rev, clear




drop if isb == 0

egen pid = group(id year)

xtreg img treat##post i.year, fe vce(robust)



xtreg traf treat##post##isb i.year, fe vce(cluster id)

xtreg traf treat##post##isb i.year, fe vce(cluster id)

xtpoisson traf treat##post##isb i.year, fe vce(robust)

xtreg traf treat##post##isb i.year, fe vce(robust)



xtreg lntraf treat##post##isb i.year, fe vce(cluster id)



xtreg lntraf treat##post i.year, fe vce(cluster id)


xtpoisson traf treat##post i.year if year > 2006, fe vce(robust)

xtpoisson traf treat##post i.year if year > 2006, fe vce(robust)

xtpoisson traf treat##post i.year if year > 2006, fe vce(robust)





list isb id year img bd if id == 372

unique id if img > 0 & isb == 1
unique id if img > 0 & isb == 0

codebook id if img > 0 & isb == 1

gen treat2 = (debut < 1962)

xtreg img post##isbaseball##treat i.year, fe vce(cluster id)

xtreg img post##isbaseball##treat i.year, fe vce(cluster id)



// digitization
drop if 
local treatvar treat
est clear
foreach x in img text bd{
    eststo: qui xtpoisson `x' 1.`treatvar'#1.post i.year, fe vce(robust)
    qui estadd local fixed "Yes"
    qui estadd local sstt "Yes"
}

esttab, keep(1.`treatvar'#1.post) p









drop if isbaseball == 0

gen sstt = 

gen sst = 
    
xtreg img treat##post, fe vce(cluster id)

xtreg img 1.treat#1.post i.year, fe vce(cluster id)

xtreg img 1.treat#1.post i.sstt, fe vce(cluster id)

xtreg img treat##post i.sstt, fe vce(cluster id)


xtreg img isbaseball##post, fe vce(cluster id)

xtreg img isbaseball##post i.year, fe vce(cluster id)

xtreg i isbaseball##post i.year, fe vce(cluster id)


xtreg img isbaseball##post##treat i.dy, fe vce(cluster id)

xtpoisson text isbaseball##post##treat i.year, fe vce(robust)

xtpoisson img isbaseball##post##treat i.dy, fe vce(robust)



gen decade = round(debutyear, 10)
egen dy = group(decade year)









list img text bd year if wikihandle == "Yogi_Berra"

use ${stash}master, clear

local var text
local time year
drop if isb == 0

collapse (mean) mean=`var' (semean) se=`var' , by(`time' treat)

** replace mean = ln(mean*100000)

local varlabel "txt"
sort `time' treat
label variable mean "`varlabel'"

tw (connected mean `time' if treat == 0, symbol(X) ) (connected mean `time' if treat == 1, msize(small)), legend(order(2 "Before 1964" 1 "After 1964" )) xtitle("Year") title("`varlabel'") xline(2008)

graph export ${tables}meanline_`var'.eps, replace
shell epstopdf ${tables}meanline_`var'.eps

use ${stash}master, clear

egen sstt = group(year treat isbaseball)

drop if debut < 1944 & debut > 1984

bysort id:gen tmp=(_n==1)
drop if text == 0
drop if year == 2013

keep if year == 2008 | year == 2012

// impact of digitization
est clear
eststo: qui xtreg lnimg 1.post#1.isb i.sstt, fe cluster(id)
eststo: qui xtreg lntext 1.post#1.isb i.sstt, fe cluster(id)
eststo: qui xtreg lnbd 1.post#1.isb i.sstt, fe cluster(id)
esttab, keep(1.post#1.isbaseball) p

// impact of copyright on baseball
est clear
eststo: qui xtreg lnimg 1.post#1.treat i.sstt if isb==1, fe cluster(id)
eststo: qui xtreg lntext 1.post#1.treat i.sstt if isb==1, fe cluster(id)
eststo: qui xtreg lnbd 1.post#1.treat i.sstt if isb==1, fe cluster(id)
esttab, keep(1.post#1.treat) p


// impact of copyright on baseball
est clear
eststo: qui xtpoisson img 1.post#1.treat i.sstt if isb==1, fe vce(robust)
eststo: qui xtpoisson text 1.post#1.treat i.sstt if isb==1, fe  vce(robust)
eststo: qui xtpoisson bd 1.post#1.treat i.sstt if isb==1, fe  vce(robust)
esttab, keep(1.post#1.treat) p

gen img2 = img*img

xtpoisson img2 1.post#1.treat i.sstt if isb==1, fe vce(robust)




// impact of copyright on basketball (placebo)
est clear
eststo: qui xtreg lnimg 1.post#1.treat i.year if isb==0, fe cluster(id)
eststo: qui xtreg lntext 1.post#1.treat i.year if isb==0, fe cluster(id)
eststo: qui xtreg lnbd 1.post#1.treat i.year if isb==0, fe cluster(id)
esttab, keep(1.post#1.treat) p





est clear

eststo: qui xtpoisson img 1.post#1.treat#1.isb 1.post#1.isb 1.post#1.treat i.year, fe vce(robust)

eststo: qui xtpoisson text 1.post#1.treat#1.isb 1.post#1.isb 1.post#1.treat i.year, fe vce(robust)

eststo: qui xtpoisson bd 1.post#1.treat#1.isb 1.post#1.isb 1.post#1.treat i.year, fe vce(robust)

esttab, keep(1.post#1.treat#1.isbaseball) p

est clear

eststo: qui xtreg lnimg 1.post#1.treat#1.isb 1.post#1.isb 1.post#1.treat i.year, fe vce(robust)

eststo: qui xtreg lntext 1.post#1.treat#1.isb 1.post#1.isb 1.post#1.treat i.year, fe vce(robust)

eststo: qui xtreg lnbd bd 1.post#1.treat#1.isb 1.post#1.isb 1.post#1.treat i.year, fe vce(robust)

esttab, keep(1.post#1.treat#1.isbaseball) p


xtreg lnimg 1.post#1.treat#1.isb i.sstt, fe vce(robust)






unique id if isb==1
