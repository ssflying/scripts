#!/usr/bin/python
 
# Writen by Stephane Graber <stgraber@stgraber.org>
# Last modification : Sat Dec 02 23:24:40 CET 2006
 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#                            
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
 
# Modified by Sashi:
# Modified default pastebin as ArchLinux's pastebin
# Added pastebin.com
# Added dpaste.com
# Removed stgraber.org's pastebin as it is not working
 
import urllib, os, sys, re
defaultPB="http://archlinux.pastebin.com" #Default pastebin
version="0.7" #Version number to show in the usage
 
#Return the parameters depending of the pastebin used
def getParameters(website,content,user,version):
    "Return the parameters array for the selected pastebin"
    params={}
    
    if website == "http://archlinux.pastebin.com":
        params['poster']=user
        params['code2']=content
        params['parent_pid']="" #For reply, "" means homepage (new thread)
        params['format']="text" #The format, for syntax hilighting
        params['paste']="Send" 
        params['remember']="0" #Do you want a cookie ?
        params['expiry']="f" #The expiration, f = forever
        params['regexp']="None"
    elif website == "http://pastebin.ca":
        params['name']=user
        params['content']=content
        params['type']="1" #The expiration, 1 = raw
        params['save']="0" #Do you want a cookie ?
        params['s']="Submit Post"
        params['regexp']='">http://pastebin.ca/(.*)</a></p><p>'   
    elif re.search("http://.*\.pastebin\.com", website):
        params['poster']=user
        params['code2']=content
        params['parent_pid']="" #For reply, "" means homepage (new thread)
        params['format']="text" #The format, for syntax hilighting
        params['paste']="Send" 
        params['remember']="0" #Do you want a cookie ?
        params['expiry']="f" #The expiration, f = forever
        params['regexp']="None"
    elif website == "http://pastebin.com":
        params['poster']=user
        params['code2']=content
        params['parent_pid']="" #For reply, "" means homepage (new thread)
        params['format']="text" #The format, for syntax hilighting
        params['paste']="Send" 
        params['remember']="0" #Do you want a cookie ?
        params['expiry']="f" #The expiration, f = forever
        params['regexp']="None"
    elif website == "http://dpaste.com":
        params['content']=content
        params['language']=""
        params['title']="title"
        params['poster']=user
        params['submit']="Paste it"
        params['regexp']="None"
    else:
        sys.exit("Unknown website, please post a request for this pastebin to be added ("+website+")")
        
    return params
 
#Check if a filename is passed as an argument, otherwise show the usages
try:
    filename=sys.argv[1]
except:
    sys.exit("usage: "+sys.argv[0]+" [filename|-] [URL]\n\nDefault pastebin: "+defaultPB+"\nVersion: "+version)
    
#If - is specified as a filename read from stdin, otherwise load the specified file.
if filename == "-":
    content=sys.stdin.read()
else:
    try:
        f=open(filename)
        content=f.read()
        f.close()        
    except:
        sys.exit("Unable to read from: "+filename)
 
#Check if an extra pastebin is pasted as an argument otherwise use the default Pastebin
try:
    website=sys.argv[2]
except:
    website=defaultPB
 
user=os.environ.get('USER') #Get the current username from the environment
params=getParameters(website,content,user,version) #Get the parameters array
reLink=params['regexp'] #Extract the regexp
params['regexp']=None #Remove the regexp from what will be sent
params=urllib.urlencode(params) #Convert to a format usable with the HTML POST
 
page=urllib.urlopen(website+'/',params) #Send the informations and be redirected to the final page
 
try:
    if reLink != "None": #Check if we have to apply a regexp
        print website+"/"+re.split(reLink, page.read())[1] #Print the result of the Regexp
    else:
        print page.url #Get the final page and show the url
except:
    sys.exit("Unable to read or parse the result page, it could be a server timeout or a change server side, try with another pastebin.")
