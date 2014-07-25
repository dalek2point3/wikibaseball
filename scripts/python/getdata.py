#!/usr/bin/env python
import utils
import zipfile
from subprocess import call


""" This file downloads all relevant data for this project """

__author__      = "dalek2point3"
__copyright__   = "MIT License"

root = "/mnt/nfs6/wikipedia.proj/wikibaseball/"

def get_lahman():

    global root

    url = "http://seanlahman.com/files/database/lahman-csv_2014-02-14.zip"
    path = root + "rawdata/lahman/"
    saveas = "lahman.zip"

    # download file
    utils.logmessage("Downloading zip file", "getdata", 1)
    utils.download_file(url, path+saveas)

    # unzip file
    utils.unzip(path+saveas, path)
    utils.logmessage("Unzipping file", "getdata", 1)

    pass

def get_playerrevs():
    pass

def get_traffic():
    pass

def main():
    get_lahman()
    pass

if __name__ == "__main__":
    main()


