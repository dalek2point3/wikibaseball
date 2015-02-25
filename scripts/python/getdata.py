#!/usr/bin/env python
import utils
import zipfile
import os
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

    global root

    for wikihandle in wikihandles:
        for year in years:

            filename = wikihandle + "_" + str(year)
            path = root + "rawdata/wiki/revdata/" + filename + ".xml"

            if os.path.exists(path):
                utils.logmessage("Not fetching again: " + filename, "getdata", 1)
            else: 
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
            
def get_bdcites(wikihandles, years):

    for wikihandle in wikihandles:
        for year in years:
            filename = wikihandle + "_" + str(year)
            [user, revid, size, content] = utils.parse_xml(filename)
            for line in utils.get_citelines(content):
                data = [line, wikihandle, year]
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

## not needed anymore
def get_revlist_all(wikihandles):

    for wikihandle in wikihandles:
        flag = utils.get_revlist(wikihandle)
        utils.logmessage("got "+str(flag)+" rows for " + wikihandle, "getdata", 1)
    pass


def geocode():

    filename = "/mnt/nfs6/wikipedia.proj/wikibaseball/rawdata/stash/ip.csv"
    outfilename = "/mnt/nfs6/wikipedia.proj/wikibaseball/rawdata/stash/ip_geo.csv"
    
    output = []
    count = 0

    with open(filename) as f:
        for line in f:
            items = line.strip().split("\t")
            ip = items[1].strip('"')

            count += 1
            data = utils.geocode_ip(ip)

            if data[0] != "NA":
                output.append(data)
                utils.logmessage(str(count) + " Got: " + str(ip) + " " + data[4], "getdata", 1)
            else:
                utils.logmessage(str(count) + " Failed: " + str(ip) + "", "getdata", 1)


    with open(outfilename, "a") as f:
        for row in output:
            line = "\t".join([unicode(x).encode('utf8') for x in row]) + "\n"
            f.write(line)
            
    # utils.geocode_ip()

    pass

def main():

    # Setup vars

    #  wikihandles = utils.get_handles()
    years = [2001, 2002, 2003, 2004, 2005, 2006, 2007, 2008, 2009, 2010, 2011, 2012, 2013]

    # wikihandles = ["Joe_Wolf", "Michael_Jordan"]
    # years = [2012]

    # Step 1: Download zip data from the interwebs
    # get_sport("baseball")
    # get_sport("basketball")

    # Step 2: Read wiki list and download revision files, one for each year
    # get_revs(wikihandles, years)

    # Step 3 : Parse each revision file
    # parse_revs(wikihandles, years)

    # Step 4: Get traffic data
    # get_traffic(wikihandles, years)

    # Step 5: Parse traffic data
    # parse_traffic(wikihandles, years)

    # Step 6: Get revision history data
    # get_revs(wikihandles)

    # extra-- never used: geocode()

    # extra stuff for revisions

    # Step 7: Get additional data for citations only from content pages
    
    # 7.1 get filenames from kimono data
    urls = utils.get_handles(filename="kimono_data.csv")
    
    # 7.2 for each url, get revdata
    # get_revs(urls, years)

    # 7.3 parse revs and split citations to a file. then manually tag each citation and use in stata
    get_bdcites(urls, years)

    # TODO: deal with images
    pass

if __name__ == "__main__":
    main()

## overall structure

# get_sport --> gets rawdata
# stata processes and produces list of wikihandles and other associated data
# input -> bbk_master (list of wikihandles)
# get_revs --> gets yearly revs for each wikihandle
# parse_revs and write data file

# for revisions: get citation data



