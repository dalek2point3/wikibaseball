program make_textcite

process_raw

make_cite

merge_data

end

program merge_data

use ${stash}citelines_raw, clear

// this will drop about 332 citations for which years could not be identified
merge m:1 citeid using ${stash}cite_raw, keep(match) nogen

save ${stash}citelines_text, replace

end


program process_raw

// the python script searches for 4 phrases, and output is stored in separate files
// phrases are 'baseball digest', 'baseballdigest', 'baseball_digest', 'baseball%20digest'

foreach x in "" "_percent" "_nospace" "_plus"{
    insheet using ${cite}searchcites`x'.csv, clear
    di "----------"
    di "now processing `x'"
    capture confirm variable v4
    if !_rc {
        di "deleting v4"
        tostring v4, replace
        replace v1 = v1 + " " + v2 if v4 !="."
        replace v2 = v3 if v4!="."
        replace v3 = v4 if v4!="."
        drop v4
    }
    rename v1 citetext
    rename v2 wikihandle
    rename v3 year
    destring year, replace
    save ${stash}tmpcite`x', replace
}

use ${stash}tmpcite, clear
foreach x in "_percent" "_nospace" "_plus"{
    append using ${stash}tmpcite`x'
}

//drop if citetext == "NA"
bysort citetext: gen tmp = (_n==1)
bysort tmp: gen tmp2 = _n
bysort citetext: egen citeid = max(tmp*tmp2)

//bysort wikihandle year citetext: drop if _n > 1

save ${stash}citelines_raw, replace

end


// This program takes the citations file and pulls out the citeyear for each unique citation
program make_cite

use ${stash}citelines_raw, clear

drop if citetext == "NA"
bysort citetext: drop if _n > 1

foreach x in "|" ">" "=" "'" "]" "[" " "{
    replace citetext = subinstr(citetext,"`x' ","`x'",.)
    replace citetext = subinstr(citetext," `x'","`x'",.)
}
replace citetext = subinstr(citetext, ",","",.)

gen done = 0

// this loop looks for variables depending on their direct assigmnet
// for example, date=xxx, issue = yyy etc
foreach x in date issue volume year{
    di "doing `x'"
    di "---------------"
    gen `x'var = regexs(1) if regexm(citetext, ".*\|`x'=([a-z 0-9\-\.]*)\|.*")==1
    replace `x'var = regexs(1) if regexm(citetext, ".*\|`x'=([0-9\-]*).*")==1 & datevar == ""

    replace `x'var = regexs(1) if regexm(citetext, ".*\|`x'=([a-z\-a-z]+ [0-9]+)\|.*")==1
    replace `x'var = regexs(1) if regexm(citetext, ".*\|`x'=([a-z]*-[a-z]*\[\[[0-9]+\]\])\|.*")==1
    replace done = max(done,1) if `x'var != ""
}

makerefvar

// manually get citation data and store in manual_cites
// outsheet using ${stash}cite_for_manual-mar14-2016.txt if done==0, replace

// insheet using ${stash}cite_for_manual-mar14-2016-complete.txt, clear
// keep citeid manual_date
// save ${stash}manual_cites, replace

merge 1:1 citeid using ${stash}manual_cites, nogen

save ${stash}citelines_raw_tmp, replace

getdatevar

save ${stash}cite_raw, replace

end

program getdatevar

use ${stash}citelines_raw_tmp, clear

// extract years from each var
gen year1 = regexs(1) if regexm(datevar, ".*([1-2][0-9][0-9][0-9]).*")==1
gen year2 = regexs(1) if regexm(yearvar, ".*([1-2][0-9][0-9][0-9]).*")==1
gen year3 = regexs(1) if regexm(refvar, ".*([1-2][0-9][0-9][0-9]).*")==1
gen year4 = regexs(1) if regexm(issue, ".*([1-2][0-9][0-9][0-9]).*")==1
gen year5 = regexs(1) if regexm(manual_date, ".*([1-2][0-9][0-9][0-9]).*")==1

destring year1 year2 year3 year4 year5, replace

gen cnt = (year1!=.)+(year2!=.)+(year3!=.)+(year4!=.)+(year5!=.)

// drop obs for which we have no year data
drop if cnt == 0 & vol == ""

// find years that dont agree
makedisagree

gen citeyear = max(year1,year2, year3, year4,year5) if cnt == 1
replace citeyear = max(year1, year2, year3, year4,year5) if disagree == 0 & citeyear == . & cnt>1

// replace with lower year if conflict
foreach x in 1 2 3 4 5{
    if `x' < 5 {
        local y=`x'+1 
    }
    else{
        local y 1
    }
    replace citeyear = min(year`x', year`y') if year`x'!=0 & year`y'!=0 & disagree == 1
}

makevolyear

replace citeyear = volyear if citeyear == . & volyear > 0

keep citeid citeyear

end

program makerefvar

local phrase "baseball digest"
gen refvar=regexs(1) if regexm(citetext, "`phrase' ([a-z]* [1-2][0-9][0-9][0-9]) vol.*")==1

replace citetext = subinstr(citetext, "]","",.)
replace citetext = subinstr(citetext, "[","",.)
replace citetext = subinstr(citetext, "'","",.)

replace refvar=regexs(1) if regexm(citetext, "`phrase'\ ([a-z]* [1-2][0-9][0-9][0-9])")==1 & refvar == ""

replace refvar=regexs(1) if regexm(citetext, "`phrase'([a-z]* [1-2][0-9][0-9][0-9])")==1 & refvar == ""

replace refvar=regexs(1) if regexm(citetext, "`phrase'\(([a-z]* [1-2][0-9][0-9][0-9])")==1 & refvar == ""

replace refvar=regexs(1) if regexm(citetext, "`phrase' article\ ([a-z]* [1-2][0-9][0-9][0-9])")==1 & refvar == ""

replace refvar=regexs(1) if regexm(citetext, "`phrase'([a-z]*[1-2][0-9][0-9][0-9])")==1 & refvar == ""

replace refvar=regexs(1) if regexm(citetext, "\|date=([a-z0-9\-].*).*\|publisher=baseball digest")==1 & refvar == ""

replace done = max(done,1) if refvar != ""

end


program makevolyear

gen volyear = 0
replace volyear = 1995 if volume == "january 1995"
replace volume = "" if volume == "january 1995"

destring volume, replace
replace volyear = (1941+volume) if volyear == 0 & volume != .
drop if volyear > 2010

end


program makedisagree

gen disagree = 0
foreach x in 1 2 3 4 5{
    if `x' < 4 {
        local y=`x'+1 
    }
    else{
        local y 1
    }
    di "---- `x' and `y' ----"
    replace year`x'=0 if year`x'==.
    replace year`y'=0 if year`y'==.
    replace disagree = 1 if year`x'!=year`y'& cnt > 1 & year`x' !=0 & year`y'!=0
}


end


