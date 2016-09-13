// produce summary statistics table

program summary

// Panel 1 : Sample A
est clear
use ${stash}citelines, clear

labelcitevar

estpost tabstat citeyear year  treat post numcites numimg numtext, s(mean sd median min max) columns(statistics)

esttab using "${tables}summary_cite.tex", cells ("mean(fmt(2) label(Mean)) sd(label(SD)) p50(label(Median)) min(fmt(0) label(Min)) max(fmt(0) label(Max))" ) coeflabels("Mean" "SD" "Median" "Min" "Max") replace nonum noobs booktabs width(\hsize) alignment(rrrrrr) varwidth(30) label

// Panel 2 : Sample B

est clear
use ${stash}master, clear

labelvar

drop if isbaseball == 0
drop if year < 2004

estpost tabstat debut year treat post bd img text traf quality, s(mean sd median min max) columns(statistics)

esttab using "${tables}summary.tex", cells ("mean(fmt(2) label(Mean)) sd(label(SD)) p50(label(Median)) min(fmt(0) label(Min)) max(fmt(0) label(Max))" ) coeflabels("Mean" "SD" "Median" "Min" "Max") replace nonum noobs booktabs width(\hsize) alignment(rrrrrr) varwidth(30) label

end

///////////////////
// helper programs

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
label variable quality "\emph{Quality Percentile}"
label variable debutyear "\emph{Player Debut-Year}"
label variable treat "\emph{1(Out-of-Copy)}"
label variable post "\emph{1(Wikipedia-Year$>$2008)}"

end

