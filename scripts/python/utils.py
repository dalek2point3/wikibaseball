#!/usr/bin/env python
import urllib2, urllib
import zipfile,os.path
from time import gmtime, strftime, time
from xml.dom import minidom
import re
import json
import time
import requests
from ipinfodb import API

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
    
    url = baseurl + "&titles=" + title + "&rvstart=" + str(rvstart) + "-12-01T00:00:00Z" + "&rvlimit=" + rvlimit + "&rvprop=" + rvprop + "&format=xml"
    page = urllib2.urlopen(url)
    return page

def write_xml(fileh, filename):

   global root
   path = root + "rawdata/wiki/revdata/" + filename + ".xml"
   data = fileh.read()

   with open(path, 'w') as f:
       f.write(data)

def parse_wikitext(wikitext):

    wikitext = wikitext.lower()
    text = len(wikitext)

    formats = ['jpg','jpeg','gif','svg','tiff','png']
    img = 0

    for format in formats:
        img = img + len(re.findall(format,wikitext))

    # bd = len(re.findall('baseball digest',wikitext)) + len(re.findall('books.google.com',wikitext))
    bd = len(re.findall('baseball digest',wikitext)) + len(re.findall('baseball+digest',wikitext)) 
    # bd = len(re.findall('baseball digest',wikitext))
    # bd = 0

    return [text, img, bd]

def get_players(filename="wikilist.csv"):
    global root
    filename = root + "rawdata/stash/" + filename 
    wikihandles = []
    with open(filename) as f:
        for line in f:
            tokens = line.strip().split("\t")
            wikihandles.append(tokens[0])

    return wikihandles

def parse_xml(filename):

   global root
   path = root + "rawdata/wiki/revdata/" + filename + ".xml"

   xml = minidom.parse(path)
   revlist = xml.getElementsByTagName('rev') 

   try:
       user = revlist[0].attributes['user'].value
   except IndexError:
       user = "NA"

   try:
       revid = revlist[0].attributes['revid'].value
   except IndexError:
       revid = "NA"

   try:
       size = revlist[0].attributes['size'].value
   except IndexError:
       size = "NA"

   try:
       content =  revlist[0].childNodes[0].nodeValue
   except IndexError: 
       content = ""

   return [user, revid, size, content]

def get_traf(playername, year):

    global root
    path = root + "rawdata/wiki/traf/"

    for month in range(1,13):
        month = "%0.2d" % (month) 
        somedate = str(year)+str(month)
        filename = path + playername+"_"+somedate+'.json'

        if os.path.exists(filename):
            pass
        else:
            query = "http://stats.grok.se/json/en/" + somedate +"/"+playername
            page = urllib2.urlopen(query)
            jsondata = open(filename,'w+')
            jsondata.write(page.read())
            jsondata.close()


def parse_traf(playername, year):

    global root
    path = root + "rawdata/wiki/traf/"
    traf = []

    for month in range(1,13):

        month = "%0.2d" % (month) 
        somedate = str(year)+str(month)
        filename = path + playername+"_"+somedate+'.json'

        jsondata = open(filename,'r')
        jsonobj = json.load(jsondata)
        daily_views = jsonobj['daily_views']

        count = 0
        total = 0

        for day, views in daily_views.iteritems():
            total = views + total
            count = count + 1

        if count !=0:
            avgtraf = total/float(count)
            avgtraf = "%.3f" % avgtraf
        else:
            avgtraf = 0

        traf.append(avgtraf)

    return traf

def get_revlist(title):

    global root
    path = root + "rawdata/wiki/revlist/"

    lang = "en"
    url = "http://%s.wikipedia.org/w/api.php" % (lang)
    filename = path + title + ".csv"
    count = 0

    params = {
      "format": "json",
      "action": "query",
      "titles": urllib.unquote(title),
      "prop": "revisions",
      "rvprop": "user|userid|timestamp|size",
      "rvlimit": "max",
      "redirects": "",
      "continue": ""
    }

    if os.path.exists(filename):
        print "passed " +  filename
        pass

    else:
        while True:

            r = requests.get(url, params=params).json()

            pages = r["query"]["pages"]
            
            with open(filename, "a") as f:
                for page in pages:
                    rows = []
                    revisions = r["query"]["pages"][page]["revisions"]
                    for rev in revisions:
                        try:
                            data = [rev["timestamp"], rev["userid"],rev["user"],rev["size"], title]
                        except KeyError:
                            break
                        line = "\t".join([unicode(x).encode('utf8') for x in data]) + "\n"
                        f.write(line)
                        count += 1

            if "continue" in r:
                params.update(r["continue"])
            else:
                break

    return count

def geocode_ip(ip):

    KEY = '7ca913d39b8b4f4e82c222e35372c450966e8187e61d32b7a664e385a7b39e05'
    IP = '209.85.195.83'
    IP = str(ip)

    ipinfodb_api = API(KEY)
    data_dict = ipinfodb_api.GetCity(IP)
    
    if data_dict['statusCode'] == "OK":
        data = [data_dict['countryCode'], data_dict['cityName'],  data_dict['zipCode'], data_dict['longitude'], data_dict['countryName'], data_dict['latitude'], data_dict['timeZone'], data_dict['ipAddress'], data_dict['regionName']]
    else:
        data = ["NA"]

    # data_dict = ipinfodb_api.GetCountry(IP)
    # print data_dict

    return data
