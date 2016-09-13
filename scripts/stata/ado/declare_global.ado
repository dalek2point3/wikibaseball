
program declare_global `1'

local home `1'

global path "`home'scripts/stata/"
global lahman "`home'rawdata/lahman/"

global basketball "`home'rawdata/basketball/"

global rawdata "`home'rawdata/"

global stash "`home'rawdata/stash/"

global tables "`home'tables/"

global cite "`home'rawdata/wiki/"

global fe "year"

ssc install carryforward

end

