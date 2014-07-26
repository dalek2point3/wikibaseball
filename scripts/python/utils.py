#!/usr/bin/env python
import urllib2
import zipfile,os.path
from time import gmtime, strftime
from xml.dom import minidom
import re

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

def get_xml(title, rvstart):

    baseurl = "http://en.wikipedia.org/w/api.php?action=query&prop=revisions"
    rvlimit = "1"
    rvprop = "timestamp|user|ids|size|content"
    
    url = baseurl + "&titles=" + title + "&rvstart=" + rvstart + "-01T00:00:00Z" + "&rvlimit=" + rvlimit + "&rvprop=" + rvprop + "&format=xml"
    page = urllib2.urlopen(url)
    return page

def write_xml(fileh, filename):

   global root
   path = root + "rawdata/wiki/revdata/" + filename + ".xml"
   print path
   data = fileh.read()

   with open(path, 'w') as f:
       print "writing"
       f.write(data)

def parse_wikitext(wikitext):

    wikitext = wikitext.lower()
    text = len(wikitext)

    formats = ['jpg','jpeg','gif','svg','tiff']
    img = 0

    for format in formats:
        img = img + len(re.findall(format,wikitext))

    bd = len(re.findall('baseball digest',wikitext)) + len(re.findall('books.google.com',wikitext))

    return [text, img, bd]

def parse_xml(filename):

   global root
   path = root + "rawdata/wiki/revdata/" + filename + ".xml"
   print path

   xml = minidom.parse(path)
   revlist = xml.getElementsByTagName('rev') 

   user = revlist[0].attributes['user'].value
   revid = revlist[0].attributes['revid'].value
   size = revlist[0].attributes['size'].value
   content =  revlist[0].childNodes[0].nodeValue

   return [user, revid, size, content]






