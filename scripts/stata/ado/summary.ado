program summary

// make summary panel A for citation data
est clear
use ${stash}citelines, clear

labelcitevar

estpost tabstat citeyear year  treat post numcites numimg numtext, s(mean sd median min max) columns(statistics)

esttab using "${tables}summary_cite.tex", cells ("mean(fmt(2) label(Mean)) sd(label(SD)) p50(label(Median)) min(fmt(0) label(Min)) max(fmt(0) label(Max))" ) coeflabels("Mean" "SD" "Median" "Min" "Max") replace nonum noobs booktabs width(\hsize) alignment(rrrrrr) varwidth(30) label


// make summary panel B for citation data

est clear
use ${stash}master, clear

labelvar
drop if isbasket == 1
drop if year < 2004

estpost tabstat debut year treat post bd img text traf quality , s(mean sd median min max) columns(statistics)

esttab using "${tables}summary.tex", cells ("mean(fmt(2) label(Mean)) sd(label(SD)) p50(label(Median)) min(fmt(0) label(Min)) max(fmt(0) label(Max))" ) coeflabels("Mean" "SD" "Median" "Min" "Max") replace nonum noobs booktabs width(\hsize) alignment(rrrrrr) varwidth(30) label

end

program labelcitevar

label variable treat "\emph{1(Out-of-Copy)}"
label variable post "\emph{1(Wikipedia-Year$>$2008)}"
label variable citeyear "\emph{Publication-Year}"
label variable year "\emph{Wikipedia-Year}"
label variable numcites "\emph{Total Citations}"
label variable numimg "\emph{Image Citations}"
label variable numtext "\emph{Text Citations}"

end

program labelvar

label variable img "\emph{Total Images}"
label variable text "\emph{Total Text}"
label variable bd "\emph{Total Citations}"
label variable traf "\emph{Average Traffic}"
label variable year "\emph{Wikipedia-Year}"

label variable lnimg "Log(Images)"
label variable lntext "Log(Text)"
label variable lnbd "Log(Citations)"
label variable lntraf "Log(Traffic)"

label variable quality "\emph{Quality Percentile}"

label variable debutyear "\emph{Player Debut-Year}"
label variable treat "\emph{1(Out-of-Copy)}"
label variable post "\emph{1(Wikipedia-Year$>$2008)}"

label define isbaseball_l 0 "Basketball" 1 "Baseball" 
label values isbaseball isbaseball_l

gen isbasket = !isbaseball
label define isbasket_l 1 "\textbf{Panel B -- Basketball}" 0 "\textbf{Panel A -- Baseball}" 
label values isbasket isbasket_l

//bysort id: replace debut = . if _n > 1
//bysort id: replace treat = . if _n > 1
//bysort id: replace quality = . if _n > 1

end

