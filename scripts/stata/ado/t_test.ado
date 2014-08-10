program t_test

use ${stash}master, clear

local flag `1'

keep if isb == `flag'
keep if year == 2013

labelvar

est clear
gen tmp = !treat
estpost ttest bd img text traf, by(tmp)

esttab, wide nonumber cells(`"mu_1(fmt(a3)) mu_2(fmt(a3)) b(fmt(a3) nostar) p(fmt(2) par("{ralign @modelwidth:{txt:(}" "{txt:)}}"))"') mlabels("") collabels("out-of-copy mean" "in-copy mean" "diff" "p-val") noobs replace 

esttab using "${tables}ttest_`flag'.tex", wide nonumber cells("mu_1(fmt(a3)) mu_2(fmt(a3)) b(fmt(a3) nostar) p(fmt(2))") collabels("\textbf{out-of-copy mean}" "\textbf{in-copy mean}" "\textbf{diff}" "\textbf{p-val}") noobs replace booktabs label

end

program labelvar

label variable img "\emph{Number of Images}"
label variable text "\emph{Number of Words of Text}"
label variable bd "\emph{Number of Citations to Baseball Digest}"
label variable traf "\emph{Average Monthly Traffic}"

end
