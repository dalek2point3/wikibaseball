#!/usr/bin/env python
import urllib2
import zipfile,os.path
from time import gmtime, strftime

""" This file contains useful functions for other programs """

__author__      = "dalek2point3"
__copyright__   = "MIT License"

def download_file(url, filename):
    f = urllib2.urlopen(url)
    data  = f.readlines()
    with open(filename,'wb') as output:
        output.writelines(data)

# copied from http://stackoverflow.com/questions/12886768/simple-way-to-unzip-file-in-python-on-all-oses
def unzip(source_filename, dest_dir):

    fh = open(source_filename, 'rb')
    z = zipfile.ZipFile(fh)
    for name in z.namelist():
        z.extract(name, dest_dir)
    fh.close()

def logmessage(message, logname, printscreen):
    
    time = datetime.datetime.now()

    if(printscreen):
        print message
        print "------------"

    with open(logname, 'a') as mylog:
        mylog.write()
        mylog.write(message + "\n")

