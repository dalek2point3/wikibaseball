program summary

// make summary panel A for citation data
est clear
use ${stash}citelines, clear

labelcitevar

estpost tabstat citeyear year numcites numimg numtext, s(mean sd median min max) columns(statistics)

esttab using "${tables}summary_cite.tex", cells ("mean(fmt(2) label(Mean)) sd(label(SD)) p50(label(Median)) min(fmt(0) label(Min)) max(fmt(0) label(Max))" ) coeflabels("Mean" "SD" "Median" "Min" "Max") replace nonum noobs booktabs width(\hsize) alignment(rrrrrr) varwidth(30) label


// make summary panel B for citation data

est clear
use ${stash}master, clear

labelvar
drop if isbasket == 1

estpost tabstat img text bd traf year post debut quality treat, s(mean sd median min max n) columns(statistics)

esttab using "${tables}summary.tex", cells ("mean(fmt(2) label(Mean)) sd(label(SD)) p50(label(Median)) min(fmt(0) label(Min)) max(fmt(0) label(Max)) count(fmt(0) label(N))" ) coeflabels("Mean" "SD" "Median" "Min" "Max" "N") replace nonum noobs booktabs width(\hsize) alignment(rrrrrr) varwidth(30) label

end

program labelcitevar

label variable citeyear "\emph{Year of Issue Publication (Issue-Year)}"
label variable year "\emph{Calendar Year (Year)}"
label variable numcites "\emph{Total Citations}"
label variable numimg "\emph{Citations for Image Reuse}"
label variable numtext "\emph{Citations in Text}"

end

program labelvar

label variable img "\emph{Number of images}"
label variable text "\emph{Number of words of text}"
label variable bd "\emph{Number of citations to Baseball Digest}"
label variable traf "\emph{Average monthly traffic}"
label variable year "\emph{Year of Wikipedia page version}"

label variable lnimg "Log(Images)"
label variable lntext "Log(Text)"
label variable lnbd "Log(Citations)"
label variable lntraf "Log(Traffic)"

label variable quality "\emph{Quality Percentile}"

label variable debutyear "\emph{Debut Year}"
label variable treat "\emph{1(Debut in Out-of-Copyright year)}"

label variable post "\emph{1(Year$>$2008)}"

label define isbaseball_l 0 "Basketball" 1 "Baseball" 
label values isbaseball isbaseball_l

gen isbasket = !isbaseball
label define isbasket_l 1 "\textbf{Panel B -- Basketball}" 0 "\textbf{Panel A -- Baseball}" 
label values isbasket isbasket_l

bysort id: replace debut = . if _n > 1
bysort id: replace treat = . if _n > 1
bysort id: replace quality = . if _n > 1

end

