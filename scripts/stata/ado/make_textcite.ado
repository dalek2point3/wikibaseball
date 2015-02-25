program make_textcite

process_raw

make_cite_text_master

merge_data

end

program merge_data

use ${stash}citelines_raw, clear

merge m:1 citeid using ${rawdata}cites_text

// for some 400 unique citations could not detect year, drop
drop if fulltext!="NA" & _m < 3
drop _merge

save ${stash}citelines_text, replace

end


program process_raw

insheet using ${cite}citelines.csv, clear

replace v1 = v1 + " " + v2 if v4 != .
replace v2 = v3 if v4 != .
tostring v4, replace
//replace v3 = string(v4) if v4 != .
drop v4

rename v1 fulltext
rename v2 wikihandle
rename v3 year

// gen id
egen citeid = group(fulltext)

drop if wikihandle == "Baseball_Digest"

save ${stash}citelines_raw, replace

end

program make_cite_text_master

use ${stash}citelines_raw, clear

drop if fulltext == "NA"

// give BD bolding effect
gen bdpos = strpos(fulltext, "baseball digest")
gen text = substr(fulltext, bdpos-60, bdpos+60)

replace text = subinstr(text, "baseball digest", "<b>baseball digest</b>",.)
replace text = subinstr(text, ",","",.)
replace fulltext = subinstr(fulltext, "baseball digest", "<b>baseball digest</b>",.)
replace fulltext = subinstr(fulltext, ",", "",.)


// drop duplicate citations
bysort fulltext: drop if _n > 1


foreach x in "|" ">" "=" "'" "]" "[" " "{
    replace text = subinstr(text,"`x' ","`x'",.)
    replace text = subinstr(text," `x'","`x'",.)
}

foreach x in date issue volume year{
    di "doing `x'"
    di "---------------"
    gen `x'var = regexs(1) if regexm(text, ".*\|`x'=([a-z 0-9\-\.]*)\|.*")==1
    replace `x'var = regexs(1) if regexm(text, ".*\|`x'=([0-9\-]*).*")==1 & datevar == ""

    replace `x'var = regexs(1) if regexm(text, ".*\|`x'=([a-z\-a-z]+ [0-9]+)\|.*")==1
    replace `x'var = regexs(1) if regexm(text, ".*\|`x'=([a-z]*-[a-z]*\[\[[0-9]+\]\])\|.*")==1
}


gen refvar = regexs(1) if regexm(text, ".*>([a-z]* [1-2][0-9][0-9][0-9]) vol.*")==1
replace refvar = regexs(1) if regexm(text, ".*>([a-z]* [1-2][0-9][0-9][0-9]) issn*")==1 & refvar == ""

makesimpleref

//// date var

gen done = 0
gen num = 0
foreach x in date volume issue yearvar refvar simplerefvar{
    replace done = max(done, `x'!="")
    replace num = num + 1 if `x' != ""
}

drop if done == 0
save ${filedata}cite_tmp, replace

getdatevar

save ${rawdata}cites_text, replace


end


program getdatevar

use ${filedata}cite_tmp, replace


// extract years from each var
gen year1 = regexs(1) if regexm(datevar, ".*([1-2][0-9][0-9][0-9]).*")==1
gen year2 = regexs(1) if regexm(yearvar, ".*([1-2][0-9][0-9][0-9]).*")==1
gen year3 = regexs(1) if regexm(refvar, ".*([1-2][0-9][0-9][0-9]).*")==1
gen year4 = regexs(1) if regexm(simplerefvar, ".*([1-2][0-9][0-9][0-9]).*")==1
gen year5 = regexs(1) if regexm(issue, ".*([1-2][0-9][0-9][0-9]).*")==1

destring year1 year2 year3 year4 year5, replace

gen cnt = (year1!=.)+(year2!=.)+(year3!=.)+(year4!=.)+(year5!=.)

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


program makesimpleref

gen simplerefvar = ""
replace simplerefvar = regexs(1) if regexm(text, ".*>\]\]''([a-z]+ [1-2][0-9][0-9][0-9]).*")==1 & simplerefvar == ""

replace simplerefvar = regexs(1) if regexm(text, ".*>''([a-z]+ [1-2][0-9][0-9][0-9]).*")==1 & simplerefvar == ""

replace simplerefvar = regexs(1) if regexm(text, ".*>''([a-z]+[1-2][0-9][0-9][0-9]).*")==1 & simplerefvar == ""

replace simpleref = regexs(1) if regexm(text, ".*b>([a-z]+ [0-9]+).*")==1 & simpleref == ""

replace simplerefvar = regexs(1) if regexm(text, ".*>\]\]''([a-z]+[1-2][0-9][0-9][0-9]).*")==1 & simplerefvar == ""

replace simplerefvar = regexs(1) if regexm(text, ".*>article ([a-z]+ [1-2][0-9][0-9][0-9]).*")==1 & simplerefvar == ""

replace simplerefvar = regexs(1) if regexm(text, ".*>daily \- ([a-z]+ [1-2][0-9][0-9][0-9]).*")==1 & simplerefvar == ""

replace simplerefvar = regexs(1) if regexm(text, ".*>daily[ ]+([a-z]+ [1-2][0-9][0-9][0-9]).*")==1 & simplerefvar == ""


replace simplerefvar = regexs(1) if regexm(text, ".*>\]\]([a-z]+ [1-2][0-9][0-9][0-9]).*")==1 & simplerefvar == ""

replace simplerefvar = regexs(1) if regexm(text, ".*>''\(([a-z]+ [1-2][0-9][0-9][0-9]).*")==1 & simplerefvar == ""

replace simplerefvar = regexs(1) if regexm(text, ".*>''.*([a-z]+ [1-2][0-9][0-9][0-9]).*")==1 & simplerefvar == ""

replace simplerefvar = regexs(1) if regexm(text, ".*digest</b>([a-z \.]+ [1-2][0-9][0-9][0-9]).*")==1 & simplerefvar == ""

end


