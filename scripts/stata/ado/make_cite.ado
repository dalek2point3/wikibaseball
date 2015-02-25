program make_cite


make_textcite
// this gives ${stash}citelines_text

make_imgcite


use ${stash}citelines_text, clear

bysort citeid: drop if _n > 1

append using ${stash}citelines_img

keep wikihandle citeyear titlehref

keep if citeyear > 1943 & citeyear < 1985



end


program make_imgcite
insheet using ${cite}kimono_images.csv, clear
gen citeyear = regexs(1) if regexm(description, ".*([1-2][0-9][0-9][0-9]) issue.*")==1
destring citeyear, replace
manualinput

insheet using ${cite}pageinfo_kimono.csv,clear nonames
drop if v2 == "Date/Time"


save ${stash}citelines_img, replace

// this gives ${stash}citelines_text


end

program manualinput

replace citeyear = 1963 if _n ==2
replace citeyear = 1971 if _n ==5
replace citeyear = 1963 if _n ==7    
replace citeyear = 1948 if _n ==8
replace citeyear = 1951 if _n ==9 

replace citeyear = 1963 if _n ==10
replace citeyear = 1959 if _n ==66
replace citeyear = 1968 if _n ==133   
replace citeyear = 1949 if _n ==151
replace citeyear = 1951 if _n ==180 

replace citeyear = 1963 if _n ==188
replace citeyear = 1963 if _n ==189
replace citeyear = 1949 if _n ==190     
replace citeyear = 1949 if _n ==191
replace citeyear = 1949 if _n ==192
drop if _n ==193
    
end
