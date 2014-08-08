program summary

est clear
use ${stash}master, clear

labelvar

estpost tabstat img text bd traf debut treat, s(mean sd median min max n) columns(statistics) nototal by(isbasket)

esttab using "${tables}summary.tex", cells ("mean(fmt(2) label(Mean)) sd(label(SD)) p50(label(Median)) min(fmt(0) label(Min)) max(fmt(0) label(Max)) count(fmt(0) label(N))" ) coeflabels("Mean" "SD" "Median" "Min" "Max" "N") replace nonum noobs booktabs width(\hsize) alignment(rrrrrr) varwidth(30) label

end

program labelvar

label variable img "\emph{Number of Images}"
label variable text "\emph{Characters of Text}"
label variable bd "\emph{Number of Citations to Baseball Digest}"
label variable traf "\emph{Average Monthly Traffic}"

label variable lnimg "Log(Images)"
label variable lntext "Log(Text)"
label variable lnbd "Log(Citations)"
label variable lntraf "Log(Traffic)"

label variable debutyear "\emph{Debut Year}"
label variable treat "\emph{1(Debut in Out-of-Copyright year)}"


label define isbaseball_l 0 "Basketball" 1 "Baseball" 
label values isbaseball isbaseball_l

gen isbasket = !isbaseball
label define isbasket_l 1 "\textbf{Panel B -- Basketball}" 0 "\textbf{Panel A -- Baseball}" 
label values isbasket isbasket_l

bysort id: replace debut = . if _n > 1
bysort id: replace treat = . if _n > 1

end

