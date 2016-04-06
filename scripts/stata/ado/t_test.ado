program t_test

// sample A t_test

use ${stash}citelines, clear

keep if year == 2012
labelcitevar

est clear
gen tmp = !treat
estpost ttest numcite numimg numtext, by(tmp)

esttab, wide nonumber cells(`"mu_1(fmt(a3)) mu_2(fmt(a3)) b(fmt(a3) nostar) p(fmt(2) par("{ralign @modelwidth:{txt:(}" "{txt:)}}"))"') mlabels("") collabels("out-of-copy mean" "in-copy mean" "diff" "p-val") noobs replace  noisily

esttab using "${tables}ttest_cite.tex", wide nonumber cells("mu_1(fmt(a3)) mu_2(fmt(a3)) b(fmt(a3) nostar) p(fmt(2))") collabels("\textbf{(1)out-of-copy $\bar{y}$}" "\textbf{(2)in-copy $\bar{y}$}" "\textbf{(3)diff}" "\textbf{(4)p-val}") noobs replace booktabs label


// sample B t_test
use ${stash}master, clear

//local flag `1'
// keep just baseball
keep if isb == 1
keep if year == 2012

labelvar

est clear
gen tmp = !treat
estpost ttest bd img text traf, by(tmp)

esttab, wide nonumber cells(`"mu_1(fmt(a3)) mu_2(fmt(a3)) b(fmt(a3) nostar) p(fmt(2) par("{ralign @modelwidth:{txt:(}" "{txt:)}}"))"') mlabels("") collabels("out-of-copy mean" "in-copy mean" "diff" "p-val") noobs replace  noisily

esttab using "${tables}ttest_baseball.tex", wide nonumber cells("mu_1(fmt(a3)) mu_2(fmt(a3)) b(fmt(a3) nostar) p(fmt(2))") collabels("\textbf{(1)out-of-copy $\bar{y}$}" "\textbf{(2)in-copy $\bar{y}$}" "\textbf{(3)diff}" "\textbf{(4)p-val}") noobs replace booktabs label

end


program labelcitevar

label variable citeyear "\emph{Year of Issue Publication (Issue-Year)}"
label variable year "\emph{Calendar Year (Year)}"
label variable numcites "\emph{Total Citations}"
label variable numimg "\emph{Citations for Image Reuse}"
label variable numtext "\emph{Citations in Text}"

end


program labelvar


label variable img "\emph{Number of Images}"
label variable text "\emph{Number of Words of Text}"
label variable bd "\emph{Number of Citations to Baseball Digest}"
label variable traf "\emph{Average Monthly Traffic}"

end
