
<<<<<<< HEAD
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

=======
program declare_global

global path "/mnt/nfs6/wikipedia.proj/wikibaseball/scripts/stata/"
global lahman "/mnt/nfs6/wikipedia.proj/wikibaseball/rawdata/lahman/"

global basketball "/mnt/nfs6/wikipedia.proj/wikibaseball/rawdata/basketball/"

global rawdata "/mnt/nfs6/wikipedia.proj/wikibaseball/rawdata/"

global stash "/mnt/nfs6/wikipedia.proj/wikibaseball/rawdata/stash/"

global tables "/mnt/nfs6/wikipedia.proj/wikibaseball/scripts/stata/tables/"

global revlist "/mnt/nfs6/wikipedia.proj/wikibaseball/rawdata/wiki/revlist/"

global cite "/mnt/nfs6/wikipedia.proj/wikibaseball/rawdata/wiki/cite/"

global fe "year"

>>>>>>> 5cb8b96e4d01968e78d3274c1a7f003e6a5352f5
end

