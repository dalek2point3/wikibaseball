#!/usr/bin/env python
import utils
import zipfile
from subprocess import call
from time import sleep

""" This file downloads all relevant data for this project """

__author__      = "dalek2point3"
__copyright__   = "MIT License"

root = "/mnt/nfs6/wikipedia.proj/wikibaseball/"

def get_sport(sport):

    global root

    utils.logmessage("Getting: " + sport, "getdata", 1)

    if sport == "baseball":
        url = "http://seanlahman.com/files/database/lahman-csv_2014-02-14.zip"
        path = root + "rawdata/lahman/"
        saveas = "lahman.zip"

    if sport == "basketball":
        url = "http://www.databasebasketball.com/databasebasketball_2009_v1.zip"
        path = root + "rawdata/basketball/"
        saveas = "basketball.zip"

    # download file
    utils.logmessage("Downloading zip file", "getdata", 1)
    utils.download_file(url, path+saveas)

    # unzip file
    utils.unzip(path+saveas, path)
    utils.logmessage("Unzipping file", "getdata", 1)

    pass

def get_revs(wikihandles, years):

    for wikihandle in wikihandles:
        for year in years:
            filename = wikihandle + "_" + str(year)

            data = utils.get_xml(wikihandle, year) 
            utils.write_xml(data, filename)

            utils.logmessage("Getting: " + filename, "getdata", 1)

        sleep(0.01)

def parse_revs(wikihandles, years):

    # wikihandles = ["Hank_Aaron"]
    # years = [2011]
    
    for wikihandle in wikihandles:
        for year in years:
            filename = wikihandle + "_" + str(year)
            [user, revid, size, content] = utils.parse_xml(filename)
            [text, img, bd] = utils.parse_wikitext(content)
            data = [wikihandle, year, user, revid, size, text, img, bd]
            print "\t".join([unicode(x).encode('utf8') for x in data])

def get_traffic(wikihandles, years):

    #wikihandles = ["Michael_Jordan","Mahmoud_Abdul-Rauf"]
    #years = [2012]

    for wikihandle in wikihandles:
        utils.logmessage("Downloading traffic for: " + wikihandle,"getdata", 1)
        for year in years:
            utils.get_traf(wikihandle, year)

    pass

def parse_traffic(wikihandles, years):
    
    for wikihandle in wikihandles:
        utils.logmessage("Parsing traffic for: " + wikihandle,"getdata", 0)
        for year in years:
            traf = utils.parse_traf(wikihandle, year)
            data = traf + [wikihandle, year]
            print "\t".join([unicode(x).encode('utf8') for x in data])

    pass


def main():

    # Setup vars

    wikihandles = utils.get_players()
    years = [2005, 2006, 2007, 2008, 2009, 2010, 2011, 2012, 2013]

    # wikihandles = ["Manny_Trillo"]
    # years = [2012]

    # Step 1: Download zip data
    # get_sport("baseball")
    # get_sport("basketball")

    # Step 2: Read wiki list and download revision files, one for each year
    # get_revs(wikihandles, years)

    # Step 3 : Parse each revision file
    # parse_revs(wikihandles, years)

    # Step 4: Get traffic data
    # get_traffic(wikihandles, years)

    # Step 5: Parse traffic data
    parse_traffic(wikihandles, years)

    pass

if __name__ == "__main__":
    main()


## overall structure

# get_sport --> gets rawdata
# stata processes and produces list of wikihandles and other associated data
# input -> bbk_master (list of wikihandles)
# get_revs --> gets yearly revs for each wikihandle
# parse_revs and write data file





