// make dataset for basketball players (used only in appendix)

program make_basketball

// 1. send data out for manual processing
// make_mt

// 2. calculate total minutes played
make_careermins

// 3. read data from manual processing
read_mt

// 4. make master basketball data
make_master

end


//////////////////////////////
// Programs Library Follows //
//////////////////////////////


// 1. send data for manual processing
program make_mt

use ${basketball}bk_master, clear

gen displayname = namefirst + " " + namelast 
gen searchname = namefirst + "+" + namelast + "+" + " basketball"

gen link = "http://en.wikipedia.org/w/index.php?title=Special%3ASearch&profile=default&search=" + searchname + "&fulltext=Search"

outsheet playerid displayname link using ${stash}mt_input_bk.csv, replace comma

end

// 2. make career minutes data
program make_careermins

insheet using ${basketball}player_career.csv, clear
keep ilk firstname lastname gp minutes* pts asts reb turnover

// this data is at player-league level.
local vars "gp minutes pts reb asts turnover"
foreach x in `vars'{
    bysort ilk: egen tmp = total(`x')
    replace `x' = tmp
    drop tmp
}

bysort ilk: drop if _n>1

gsort- minutes
gen minutesrank = _n

save ${stash}bk_tmp, replace

end

//// MT section

// 3. manually processed data
program read_mt

insheet using ${basketball}mt_bk_output.csv, clear

gen wikihandle = subinstr(answer, "http://en.wikipedia.org/wiki/","",.)
keep inputp inputdisp wikihandle

gen tmp = subinstr(inputd, " ","_",.)
fix_errors

rename inputplayerid playerid
keep wikihandle playerid

save ${basketball}mt_bk_output, replace

end

// 4. make basketball master file
program make_master

insheet using ${basketball}players.csv, clear

replace college = college + ", " + birthdate if v12 != ""
replace birthdate = v12 if v12 != ""
drop v12

merge 1:1 ilkid using ${stash}bk_tmp, keep(match) nogen

gen birthyear = substr(birthdate,1,4)
rename firstseason debutyear
rename lastseason lastyear

rename ilkid playerid

keep playerid firstname lastname debutyear lastyear birthyear minutesrank minutes gp asts pts reb 

rename firstname namefirst
rename lastname namelast

gen playername = namefirst + " " + namelast

// generate file for amazon to get me data on
drop if debutyear < 1940
drop if debutyear > 1990

drop if minutesrank > 1000

merge 1:1 playerid using ${basketball}mt_bk_output, nogen

drop if birthyear == "NULL"
replace playerid = lower(playerid)

destring, replace

save ${basketball}bk_master, replace

end



// helper program
program fix_errors

replace wiki = tmp if inputd == "Slater Martin"
replace wiki = tmp if inputd == "Tom Meschery"
replace wiki = tmp if wiki == "Micheal_Williams"
replace wiki = tmp if inputd == "Michael Cage"
replace wiki = tmp if inputd == "Alvin Robertson"
replace wiki = tmp if inputd == "Magic Johnson"
replace wiki = tmp if inputd == "Michael Jordan"
replace wiki = tmp if inputd == "Phil Jordon"

replace wiki = "George_L._Johnson" if inputd == "George L. Johnson"

replace wiki = "Wayne_Cooper_(basketball)" if inputd == "Wayne Cooper"

replace wiki = "Micheal_Ray_Richardson" if inputd == "Micheal Ray Richardson"

replace wiki = "Eddie_Johnson_(basketball,_born_1955)" if inputd == "Eddie Johnson"
replace wiki = "Eddie_A._Johnson" if inputd == "Eddie A. Johnson"

replace wiki = "Mike_Brown_(basketball,_born_1963)" if inputd == "Mike Brown"

replace wiki = "Mahmoud_Abdul-Rauf" if wiki == "Mahmud"
replace wiki = "Jan_van_Breda_Kolff" if inputd == "Jan Vanbredakolff"
replace wiki = "Norm_Van_Lier" if inputd == "Norm Vanlier"
replace wiki = "Danny_Vranes" if inputd == "Danny Vranes"
replace wiki = "Dick_Barnett" if inputd == "Dick Barnett"
replace wiki = "Walt_Wesley" if inputd == "Walt Wesley"
replace wiki = "Trooper_Washington" if inputd == "Trooper Washington"

end
