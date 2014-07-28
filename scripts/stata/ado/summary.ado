program summary

est clear
use ${stash}master, clear

labelvar

estpost tabstat img text bd traf debut treat, s(mean sd median min max) columns(statistics) nototal by(isbasket)

esttab using "${tables}summary.tex", cells ("mean(fmt(2) label(Mean)) sd(label(SD)) p50(label(Median)) min(label(Min)) max(label(Max))" ) coeflabels("Mean" "SD" "Median" "Min" "Max") replace nonum noobs label booktabs width(\hsize) alignment(rrrrr) varwidth(30)


end

program labelvar

label variable img "Images"
label variable text "Text"
label variable bd "Citations"
label variable traf "Traffic"

label variable lnimg "Log(Images)"
label variable lntext "Log(Text)"
label variable lnbd "Log(Citations)"
label variable lntraf "Log(Traffic)"

label variable debutyear "Debut Year"
label variable treat "1(Debut Before 1964)"

label define isbaseball_l 0 "Basketball" 1 "Baseball" 
label values isbaseball isbaseball_l

gen isbasket = !isbaseball
label define isbasket_l 1 "\textbf{Basketball}" 0 "\textbf{Baseball}" 
label values isbasket isbasket_l

end

