from __future__ import division
import urllib
import urllib2
import xml.dom.minidom as minidom
import time
import datetime
import os.path
import re
from BeautifulSoup import BeautifulSoup 
import json


# takes a players name and a date and writes revision info in a file if it doesnt exist
def writerevinfo(playername, dateutc):

    filename = 'dumps/revdata/' + playername+"_"+str(dateutc)[:-2]+'.xml'

    if os.path.exists(filename):
        pass
    else:
        query = "http://en.wikipedia.org/w/api.php?action=query&prop=revisions&rvlimit=1&rvprop=timestamp|ids&format=xml&rvstart="+str(dateutc)[:-2]+"&titles="+playername
        print "getting " + playername + "\n------------------------\n"
        page = urllib2.urlopen(query)
        revdata = open(filename,'w+')
        revdata.write(page.read())

# this function gets revids out of downloaded files

def writeallrevinfo(playername, datestart, dateend):

    filename2 = 'dumps/revdata_long/' + playername+"_"+str(datestart)[:-2]+'.xml'
    count = 0
    cont_flag = 1
    uniqueid = str(datestart)[:-2]
    urlstring = "rvstart="+str(dateend)[:-2]

    while cont_flag>0:
        if os.path.exists(filename2):
            pass
        else:
            query = "http://en.wikipedia.org/w/api.php?action=query&prop=revisions&rvlimit=500&format=xml&rvprop=timestamp%7Cuser%7Csize%7Cflags&"+urlstring+"&rvend="+str(datestart)[:-2]+"&rvcontinue&titles="+playername

            print "\n getting " + playername  + "\n------------------------\n"
            cur_page = urllib2.urlopen(query)
            revdata = open(filename2,'w+')
            revdata.write(cur_page.read())
            revdata.close()

            
        revdata = open(filename2,'r')
        doc = minidom.parse(revdata)
        rvcont = doc.getElementsByTagName("query-continue")

        if len(rvcont)>0:
            revisions = rvcont[0].getElementsByTagName("revisions")
            rvstartid = revisions[0].getAttribute("rvstartid")
            urlstring = "rvstartid=" + str(rvstartid)
            uniqueid = rvstartid
            cont_flag = 1
            filename2 = 'dumps/revdata_long/' + playername+"_"+str(uniqueid)+'.xml'
        else:
            cont_flag = 0


    cont_flag = 1
    count = 0
    uniqueid = str(datestart)[:-2]

    while cont_flag>0:

        filename2 = 'dumps/revdata_long/' + playername+"_"+str(uniqueid)+'.xml'
        revdata = open(filename2,'r')
        doc = minidom.parse(revdata)

        count = count + len(doc.getElementsByTagName("rev"))

        rvcont = doc.getElementsByTagName("query-continue")

        if len(rvcont)>0:
            revisions = rvcont[0].getElementsByTagName("revisions")
            rvstartid = revisions[0].getAttribute("rvstartid")
            urlstring = "rvstartid=" + str(rvstartid)
            uniqueid = rvstartid
            cont_flag = 1
        else:
            cont_flag = 0

    return count


# returns the revid from a given revision file 
def parserevs(filename): 
    doc = minidom.parse(filename)
    page = doc.getElementsByTagName("page")

    title = page[0].getAttribute("title")
    pageid = page[0].getAttribute("pageid")

    #print title, pageid
    revs = doc.getElementsByTagName("rev")
    #return revid = 0 if page did not exist
    revid = 0

    for rev in revs:
        revid = rev.getAttribute("revid")
        timestamp = rev.getAttribute("timestamp")
        parentid = rev.getAttribute("parentid")
    
    #print revid, timestamp, title, pageid
    return revid

# tihs function gets information for a given revision

#TODO: takes playername and revid and returns a hash of all info
def getrevinfo(playername, revid, somedate):

    revinfo_zero = {'playername':playername, 'revid':0, 'numimages': 0, 'charsize': 0, 'traffic':0}

    filename = 'dumps/revdumps/' + playername + "_" + str(revid)+'.html'

    # fetch the file from wikipedia only if that file does not exist
    if os.path.exists(filename):
        #print "data exists. not downloading again for "+ revid
        pass
    else:
        query = "http://en.wikipedia.org/w/index.php?oldid="+str(revid)
        print query
        page = urllib2.build_opener()
        page.addheaders = [('User-agent', 'Mozilla/5.0')]
        result = page.open(query)
        revdumpdata = open(filename,'w+')
        revdumpdata.write(result.read())
        revdumpdata.close()
        
    filedata = open(filename,'r')
    content = filedata.read()
    soup = BeautifulSoup(content)

    numimages = getimginfo(soup)
    charsize = getcharsizeinfo(soup)
    traffic = gettraffic(playername, somedate)

    revinfo = {'playername':playername, 'revid':revid, 'numimages': numimages, 'charsize': charsize, 'traffic':traffic}

    if revid > 0:
        return revinfo
    else:
        return revinfo_zero

# takes the soup and counts images


# this function takes a soup object and returns number of images

# takes soup and returns number of images


def getimginfo(soup):

    #return len(soup.findAll("img","thumbimage"))
    images = soup.find(id="bodyContent").findAll("img")

    # remove duplicates
    images = list(set(images))
    imgcount = 0

    # count only those images that are greater than 75px
    for image in images:
        try:
            if int(image["width"])>75:
                imgcount = imgcount + 1
            #print "true " + str(imgcount) + " " + image["width"] 
            #print image["src"]
        except:
            pass
    
    # return number of images
    return imgcount




# takes soup and returns charactersize
def getcharsizeinfo(soup):

    #return len(soup.findAll("img","thumbimage"))
    text = str(soup.find('div', id="bodyContent"))

    # return number of characters
    return len(text)


# for playername and somedate it returns avg monthly traffic
def gettraffic(playername, somedate):

    filename = 'dumps/traffic/' + playername+"_"+somedate+'.json'

    # date like "200811"
    # fetch the file from wikipedia only if that file does not exist
    if os.path.exists(filename):
        pass
    else:
        query = "http://stats.grok.se/json/en/" + somedate +"/"+playername
        page = urllib2.urlopen(query)
        jsondata = open(filename,'w+')
        jsondata.write(page.read())
        jsondata.close()

    jsondata = open(filename,'r')
    jsonobj = json.load(jsondata)
    
    daily_views = jsonobj['daily_views']
    
    count = 0
    total = 0
    for day, views in daily_views.iteritems():
        total = views + total
        count = count + 1

    average = total/count
    average = "%.3f" % average
    return average


def writefile(f, outfile, dates):

    oldmonth = dates['oldmonth']
    oldyear = dates['oldyear']

    startmonth = dates['startmonth']
    startyear = dates['startyear']

    endmonth = dates['endmonth']
    endyear = dates['endyear']

    startdate = time.mktime((startyear, startmonth, 1, 0, 0, 0, 0, 0, 0))
    enddate = time.mktime((endyear, endmonth, 1, 0, 0, 0, 0, 0, 0))
    olddate = time.mktime((oldyear, oldmonth, 1, 0, 0, 0, 0, 0, 0))

    count = 0
    header = "playerID\tplayername\toldimg\tnewimg\toldtraffic\tnewtraffic\toldchar\tnewchar\toldrevs\tnewrevs\n"
    outfile.write(header)   
    
    for line in f:

        count = count + 1
        items =  line.strip()
        playername = items.split(",")[0].strip()
        playerID = items.split(",")[1].strip()
        playername = urllib.quote(playername)

        # this gets revision info from wikipedia if it doesnt exist
        writerevinfo(playername,startdate)
        writerevinfo(playername,enddate)
    
        # this parses the data that was got to get revids

        filename_start = "dumps/revdata/" + playername +"_"+ str(startdate)[:-2]+".xml"
        filename_end = "dumps/revdata/" + playername +"_"+ str(enddate)[:-2]+".xml"


        revid_start = parserevs(filename_start)
        revid_end = parserevs(filename_end)
    
        # print playername, revid_start, revid_end
    
        # the results part should contain the following:
        # number of images, size of text, 
        startmy = str(startyear)+str(startmonth)
        endmy = str(endyear)+str(endmonth)

        # print urllib.unquote(playername) + ", " + str(getrevinfo(playername, revid_start, startmy)) + ", " +  str(getrevinfo(playername, revid_end, endmy))
    
        revinfo_start = getrevinfo(playername, revid_start, startmy)
        revinfo_end = getrevinfo(playername, revid_end, endmy)

        newnumrevs = writeallrevinfo(playername, startdate, enddate)
        oldnumrevs = writeallrevinfo(playername, olddate, startdate)
    
        # print "["+str(count)+"]", revinfo_start
        # print "["+str(count)+"]", revinfo_end

        curline = playerID +"\t" +urllib.unquote(playername) +"\t"+ str(revinfo_start['numimages'])+"\t"+str(revinfo_end['numimages'])+"\t"+str(revinfo_start['traffic'])+"\t"+str(revinfo_end['traffic'])+"\t"+str(revinfo_start['charsize'])+"\t"+str(revinfo_end['charsize']) + "\t"+str(oldnumrevs) +"\t" + str(newnumrevs) + "\n"
    
        outfile.write(curline)
    
        print  "["+str(count)+"]"+ curline
    
        # getrevinfo(playername, revid_start)
        # getrevinfo(playername, revid_end)


####################### main program here

# parameters of program

#f = open("input/playernames.txt")
#f = open("input/playernames.temp")

#f = open("input/playernames20.temp")

# f = open("input/basketballplayernames.txt")
# outfile = open('data/basketball.txt','w')
# writefile(f,outfile)

dates = dict()

dates['oldmonth'] = 12
dates['oldyear']= 2005

dates['startmonth'] = 12
dates['startyear']= 2008

dates['endmonth'] = 12
dates['endyear']= 2011


f = open("input/baseball.txt")

month = 11

while month  < 12:
    dates['startmonth'] = month
    dates['endmonth'] = month


    print "now getting for " + str(month)
    print "+++++++++++++++++++++++++++++++++++++++++\n"

    outfile = open('data/baseball' + str(dates['startmonth']) + '.txt','w')
    writefile(f,outfile,dates)

    month = month + 1


# f = open("input/playernames6.temp")
# outfile = open('data/baseball6.temp','w')
# writefile(f,outfile)


#  guide to dumps
#
#   1. dumps/revdata/playername_utctime.xml : this contains revid for given player/time 
#   2. dumps/imagedata/revid.xml : contains a list of images for a given revid
#   3. dumps/revdumps/playername_revid.html : this contains the entire html for player/revid
#   4. dumps/traffic/playername_mmyyyy.json : this contains json data for player/month-year
#
