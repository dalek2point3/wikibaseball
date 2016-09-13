<<<<<<< HEAD
// create t_test table comparing in-copy and out-of-copy

program t_test

// 1. Sample A
=======
program t_test

// sample A t_test
>>>>>>> 5cb8b96e4d01968e78d3274c1a7f003e6a5352f5

use ${stash}citelines, clear

keep if year == 2012
labelcitevar

est clear
gen tmp = !treat
estpost ttest numcite numimg numtext, by(tmp)

esttab, wide nonumber cells(`"mu_1(fmt(a3)) mu_2(fmt(a3)) b(fmt(a3) nostar) p(fmt(2) par("{ralign @modelwidth:{txt:(}" "{txt:)}}"))"') mlabels("") collabels("out-of-copy mean" "in-copy mean" "diff" "p-val") noobs replace  noisily

esttab using "${tables}ttest_cite.tex", wide nonumber cells("mu_1(fmt(a3)) mu_2(fmt(a3)) b(fmt(a3) nostar) p(fmt(2))") collabels("\textbf{(1)out-of-copy $\bar{y}$}" "\textbf{(2)in-copy $\bar{y}$}" "\textbf{(3)diff}" "\textbf{(4)p-val}") noobs replace booktabs label


<<<<<<< HEAD
// 2. Sample B

use ${stash}master, clear

keep if isbaseball == 1
=======
// sample B t_test
use ${stash}master, clear

//local flag `1'
// keep just baseball
keep if isb == 1
>>>>>>> 5cb8b96e4d01968e78d3274c1a7f003e6a5352f5
keep if year == 2012

labelvar

est clear
gen tmp = !treat
estpost ttest bd img text traf, by(tmp)

esttab, wide nonumber cells(`"mu_1(fmt(a3)) mu_2(fmt(a3)) b(fmt(a3) nostar) p(fmt(2) par("{ralign @modelwidth:{txt:(}" "{txt:)}}"))"') mlabels("") collabels("out-of-copy mean" "in-copy mean" "diff" "p-val") noobs replace  noisily

esttab using "${tables}ttest_baseball.tex", wide nonumber cells("mu_1(fmt(a3)) mu_2(fmt(a3)) b(fmt(a3) nostar) p(fmt(2))") collabels("\textbf{(1)out-of-copy $\bar{y}$}" "\textbf{(2)in-copy $\bar{y}$}" "\textbf{(3)diff}" "\textbf{(4)p-val}") noobs replace booktabs label
<<<<<<< HEAD
end

// helper programs
=======

end


>>>>>>> 5cb8b96e4d01968e78d3274c1a7f003e6a5352f5

program labelcitevar

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

end
