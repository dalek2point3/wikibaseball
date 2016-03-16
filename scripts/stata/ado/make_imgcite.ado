program make_imgcite

// this gets the add date
get_adddate

insheet using ${cite}kimono_images.csv, clear
gen citeyear = regexs(1) if regexm(description, ".*([1-2][0-9][0-9][0-9]) issue.*")==1
destring citeyear, replace
manualinput

merge 1:m titlehref using ${stash}pageinfo_kimono, keep(match master) nogen
keep titlehref citeyear year
    
save ${stash}citelines_img, replace

// this gives ${stash}citelines_text


end


program get_adddate

insheet using ${cite}pageinfo_kimono.csv,clear nonames
drop if v2 == "Date/Time"
drop in 1
// sometimes the url is displaced. ugly hack.
replace v7 = v6 if v7 == ""

split v2, parse(",") gen(tmp)

gen date_add = date(tmp2,"DMY")
format date_add %td

rename v7 titlehref
bysort titlehref: drop if _n > 1

replace titlehref = subinstr(titlehref, "commons", "en",1)
replace titlehref = subinstr(titlehref, "wikimedia", "wikipedia",1)

drop tmp* v*
gen year = year(date_add)
destring year, replace    
save ${stash}pageinfo_kimono, replace


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
