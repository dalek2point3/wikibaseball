<<<<<<< HEAD
// this program prepares the baseball dataset
program make_baseball

// 1. gets hall of fame nominated players
make_hof

// 2. gets allstar players
make_allstar

// 3. create file matching playerids to wikihandle
read_mt

// 4. create appearances file
make_appearance

// 5. make the baseball master file
make_master

end


//////////////////////////////
// Programs Library Follows //
//////////////////////////////

// 1. Keeps playerids nominates for Hall of Fame
=======
program make_baseball

make_hof

make_allstar

**make_match

read_mt

make_master


end

// This makes master baseball dataset
program make_master

insheet using ${lahman}Master.csv, clear

merge 1:1 playerid using ${lahman}hof, keep(match) nogen

// there are players who were hall of fame, but not all star
merge 1:1 playerid using ${lahman}allstar, keep(match master) nogen

// appearances
merge 1:1 playerid using ${lahman}appearances, keep(match master) 

gen debutyear = substr(debut, 1,4)
gen finalyear = substr(finalgame, 1,4)

keep playerid birthyear debutyear finalyear deathyear name* everinducted *hof* numallstar firstallstar gp

destring, replace

gen playername = namefirst + " " + namelast

// this deletes and old player that we dont care about anyway
bysort playername: drop if _n > 1

// generate file for amazon to get me data on
drop if debutyear < 1940
drop if debutyear > 2000

merge 1:1 playerid using ${lahman}mt_bb_output, nogen

save ${lahman}bb_master, replace

end


program make_match

insheet using ${rawdata}match_wiki.csv, clear names
keep if sport == "Baseball"
drop  if wikiname == "None"

save ${rawdata}match_wiki, replace

end

// This Makes Hall of Fame
>>>>>>> 5cb8b96e4d01968e78d3274c1a7f003e6a5352f5
program make_hof

insheet using ${lahman}HallOfFame.csv, clear
bysort playerid: egen everinducted = max(inducted=="Y")
bysort playerid: gen num_hof_nominations = _N
sort playerid yearid
bysort playerid: gen hof_year_elected = yearid[_N]*everinducted
replace hof_year_elected = -1 if hof_year_elected == 0

bysort playerid: gen hof_year_first = yearid[1]

<<<<<<< HEAD
=======
// TODO : calculate margin
>>>>>>> 5cb8b96e4d01968e78d3274c1a7f003e6a5352f5
bysort playerid: drop if _n > 1
keep playerid everinducted num_hof hof_year*

save ${lahman}hof, replace

end
<<<<<<< HEAD
    
// 2. gets allstar files
=======

// This Makes Allstar
>>>>>>> 5cb8b96e4d01968e78d3274c1a7f003e6a5352f5
program make_allstar

insheet using ${lahman}AllstarFull.csv, clear
bysort playerid: gen numallstar = _N
sort playerid yearid
bysort playerid: gen firstallstar = yearid[1]
bysort playerid: drop if _n > 1
keep playerid numallstar firstallstar
save ${lahman}allstar, replace

end

<<<<<<< HEAD
// 3. gets manual coded input matching playernames with wikipedia handle
program read_mt

insheet using ${lahman}mt_bb_output.csv, clear

gen wikihandle = subinstr(answer, "http://en.wikipedia.org/wiki/","",.)
keep inputp inputdisp wikihandle

gen tmp = word(inputd,1) + "_" + word(inputd,2)

//this manually fixes errors in matching wikihandles to playerids
fix_errors

rename inputplayerid playerid
keep wikihandle playerid

save ${lahman}mt_bb_output, replace

end

// 4. make appearances file

=======
>>>>>>> 5cb8b96e4d01968e78d3274c1a7f003e6a5352f5
program make_appearance

insheet using ${lahman}Appearances.csv, clear

bysort playerid: egen gp = total(g_all)
bysort playerid: drop if _n > 1
keep playerid gp

save ${lahman}appearances, replace

end

<<<<<<< HEAD
// 5. make baseball master file
program make_master

insheet using ${lahman}Master.csv, clear

// keep only hall of fame matches
merge 1:1 playerid using ${lahman}hof, keep(match) nogen

// there are players who were hall of fame, but not all star
merge 1:1 playerid using ${lahman}allstar, keep(match master) nogen

// appearances
merge 1:1 playerid using ${lahman}appearances, keep(match master) 

gen debutyear = substr(debut, 1,4)
gen finalyear = substr(finalgame, 1,4)

keep playerid birthyear debutyear finalyear deathyear name* everinducted *hof* numallstar firstallstar gp

destring, replace

gen playername = namefirst + " " + namelast

// this deletes and old player that we dont care about 
bysort playername: drop if _n > 1

// keep only relevant files
drop if debutyear < 1940
drop if debutyear > 2000

// merge in handles from manual coding
merge 1:1 playerid using ${lahman}mt_bb_output, nogen

save ${lahman}bb_master, replace

end


// helper program
=======









////////////// MT
///////////////////////
program read_mt

insheet using ${lahman}mt_bb_output.csv, clear

gen wikihandle = subinstr(answer, "http://en.wikipedia.org/wiki/","",.)
keep inputp inputdisp wikihandle

gen tmp = word(inputd,1) + "_" + word(inputd,2)
list tmp wiki if tmp != wikihandle

fix_errors

rename inputplayerid playerid
keep wikihandle playerid

save ${lahman}mt_bb_output, replace

end

>>>>>>> 5cb8b96e4d01968e78d3274c1a7f003e6a5352f5
program fix_errors

replace wikihandle = tmp if tmp == "Sonny_Jackson"
replace wikihandle = tmp if tmp == "Bill_Bruton"
replace wikihandle = tmp if tmp == "Terry_Kennedy"
replace wikihandle = "Bill_Lee_(left-handed_pitcher)" if inputp == "leebi03"

replace wikihandle = tmp if tmp == "Todd_Jones"
replace wikihandle = tmp if tmp == "Mel_Stottlemyre"
replace wikihandle = "Mike_Jackson_(right-handed_pitcher)" if tmp == "Michael_Jackson"
replace wikihandle = tmp if tmp == "Gil_Hodges"
replace wikihandle = "Tony_Pe%C3%B1a" if tmp == "Tony_Pena"
replace wikihandle = tmp if tmp == "Bob_Porterfield"
replace wikihandle = tmp if tmp == "Milt_Pappas"
replace wikihandle = "Willie_Horton_(baseball)" if tmp == "Willie_Horton"
replace wikihandle = tmp if tmp == "Hank_Edwards"
replace wikihandle = tmp if tmp == "Cecil_Cooper"
replace wikihandle = tmp if tmp == "Chris_Short"
replace wikihandle = tmp if tmp == "Clint_Courtney"
replace wikihandle = tmp if tmp == "Danny_Jackson"
replace wikihandle = tmp if tmp == "Davey_Lopes"
replace wikihandle = tmp if tmp == "Del_Rice"
replace wikihandle = tmp if tmp == "Juan_Pizarro"

replace wikihandle = "Andy_Van_Slyke" if tmp == "Andy_Van"
replace wikihandle = tmp if tmp == "Fred_Gladding"
replace wikihandle = tmp if tmp == "Todd_Zeile"
replace wikihandle = tmp if tmp == "Walker_Cooper"
replace wikihandle = tmp if tmp == "Carlos_May"
replace wikihandle = tmp if tmp == "Roberto_Alomar"

end

<<<<<<< HEAD
=======
// This makes baseball data for MT
program make_mt

use ${lahman}bb_master, clear

gen displayname = namefirst + " " + namelast + " " + namegiven
gen searchname = namefirst + "+" + namelast + "+" + namegiven + " baseball"

gen link = "http://en.wikipedia.org/w/index.php?title=Special%3ASearch&profile=default&search=" + searchname + "&fulltext=Search"

outsheet playerid displayname link using ${stash}mt_input_bb.csv, replace comma

end

>>>>>>> 5cb8b96e4d01968e78d3274c1a7f003e6a5352f5

