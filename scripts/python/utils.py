#!/usr/bin/env python
import urllib2
import zipfile,os.path
from time import gmtime, strftime

""" This file contains useful functions for other programs """

__author__      = "dalek2point3"
__copyright__   = "MIT License"

root = "/mnt/nfs6/wikipedia.proj/wikibaseball/"

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
    
    global root
    time = strftime("%Y-%m-%d %H:%M:%S", gmtime())
    path = root + "scripts/python/logs/"

    if(printscreen):
        print time + ": " + message
        print "------------"

    with open(path + logname + ".log", 'a') as mylog:
        mylog.write(time + "\n")
        mylog.write(message + "\n")
        mylog.write("-------------------------\n\n")



