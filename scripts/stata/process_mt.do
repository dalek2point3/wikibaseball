program process_cite

insheet using citelines.csv, clear
drop if v1 == "NA"
unique v1

replace v1 = v1 + " " + v2 if v4 != .
replace v2 = v3 if v4 != .
tostring v4, replace
replace v3 = string(v4) if v4 != .
drop v4

rename v1 fulltext
rename v2 wikihandle
rename v3 year

drop if wikihandle == "Baseball_Digest"

// give BD bolding effect
gen bdpos = strpos(fulltext, "baseball digest")
gen text = substr(fulltext, bdpos-60, bdpos+60)


replace text = subinstr(text, "baseball digest", "<b>baseball digest</b>",.)
replace text = subinstr(text, ",","",.)
replace fulltext = subinstr(fulltext, "baseball digest", "<b>baseball digest</b>",.)
replace fulltext = subinstr(fulltext, ",", "",.)


// drop duplicate citations
bysort fulltext: drop if _n > 1

// gen id
gen id = _n

// detect year
//date=may 2002| -- also common
//october 1946 vol. 5 no. 8 issn xxx</ref> -- very common
//volume=30|issue=2|pages=8
//volume=53 - no. 9 |issn=0005-609x
//date=1996-02
//date = 2003-01-01
//204	"r tinker] ([[joe tinker]]) ''<b>baseball digest</b>'' october 1948"
// date=march-april 2005



preserve
restore

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
list date yearvar refvar simpleref 
tab done



drop if done == 0
save ${rawdata}citemaster, replace

//outsheet id text fulltext if done == 0 using tmp.csv, replace noquote comma

end

program getdate

gen year1 = regexs(1) if regexm(datevar, ".*([1-2][0-9][0-9][0-9]).*")==1

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


