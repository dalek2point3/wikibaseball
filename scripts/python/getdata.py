#!/usr/bin/env python
import utils
import zipfile
from subprocess import call


""" This file downloads all relevant data for this project """

__author__      = "dalek2point3"
__copyright__   = "MIT License"

def get_lahman():

    url = "http://seanlahman.com/files/database/lahman-csv_2014-02-14.zip"
    path = "/mnt/nfs6/wikipedia.proj/wikibaseball/rawdata/lahman/"
    saveas = "lahman.zip"
    # utils.download_file(url, path+saveas)
    utils.unzip(path+saveas, path)

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


