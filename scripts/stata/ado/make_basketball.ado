program make_basketball

make_hof

make_allstar

make_match

make_master


end

// This makes baseball data for MT
program make_mt

use ${basketball}bk_master, clear

gen displayname = namefirst + " " + namelast 
gen searchname = namefirst + "+" + namelast + "+" + " basketball"

gen link = "http://en.wikipedia.org/w/index.php?title=Special%3ASearch&profile=default&search=" + searchname + "&fulltext=Search"

outsheet playerid displayname link using ${stash}mt_input_bk.csv, replace comma

end


// This makes master baseball dataset
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

save ${basketball}bk_master, replace

end

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

