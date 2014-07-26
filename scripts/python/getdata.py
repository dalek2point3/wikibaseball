#!/usr/bin/env python
import utils
import zipfile
from subprocess import call


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

def get_revs():

    wikihandle = "Michael_Jordan"
    date = "2013-12"
    filename = wikihandle + "_" + date

    data = utils.get_xml(wikihandle, date) 
    utils.write_xml(data, filename)
    
    pass

def parse_revs():
    
    wikihandle = "Michael_Jordan"
    date = "2013-12"
    filename = wikihandle + "_" + date

    [user, revid, size, content] = utils.parse_xml(filename)
    [text, img, bd] = utils.parse_wikitext(content)

    data = [user, revid, size, text, img, bd]
    print data


def get_traffic():
    pass

def main():

    # get_sport("baseball")
    # get_sport("basketball")
    # get_playerrevs()
    parse_revs()

    pass

if __name__ == "__main__":
    main()


## overall structure

# get_sport --> gets rawdata
# stata processes and produces list of wikihandles and other associated data
# input -> bbk_master (list of wikihandles)
# get_revs --> gets yearly revs for each wikihandle
# parse_revs and write data file





