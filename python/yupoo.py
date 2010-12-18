#!/usr/bin/env python
# coding: utf-8
 
import urllib2, md5, webbrowser, mimetools, mimetypes, os, sys
from xml.dom import minidom
 
photo_args = {
    "title" : "",
    "description" : "",
    "tags" : "脚本上传",
    "album_id" : "",
    "group_id" : "",
    # 访问权限，1-开放 0-加密,
    # 如果指定为0，请指定is_family,is_friend,is_contact,如果不指定，默认均为1
    "is_public" : "1",
    "is_contact" : "0",
    "is_friend" : "0",
    "is_family" : "0"
}
 
class YupooAPI:
    base = "http://www.yupoo.com/api/"
    rest = base + "rest/"
    auth = base + "auth/"
    upload = base + "upload/"
 
    # methods
    checkToken = "yupoo.auth.checkToken"
 
    # args
    token = "auth_token"
    key = "api_key"
    sign = "api_sig"
    frob = "frob"
    perms = "perms"
 
    def __init__(self):
        pass
 
class Yupoo:
    api_key = "6fa518578b2c4639c7613cb9e92667d1"
    shared_secret = "dye5qp5zbrnmjddp"
    base_addr = "http://www.yupoo.com/api/"
    upload_addr = base_addr + "upload/"
    rest_addr = base_addr + "rest/"
    auth_addr = base_addr + "auth/"
    session_frob = None
    session_token = None
    
    def __init__(self):
        api = YupooAPI()
 
    def calSign(self, data):
        keys = data.keys()
        keys.sort()
        s = ""
        for k in keys:
            s += (k + data[k])
        s = self.shared_secret + "api_key" + self.api_key + s
        return md5.new(s).hexdigest()
 
    def genUrl(self, data, addr = base_addr):
        url = addr
        url += "?"
        l = []
        for part in data.keys():
            l.append(part + "=" + data[part])
        return url + '&'.join(l)
 
    def checkXml(self, xml, key):
        dom = minidom.parseString(xml)
        l = dom.getElementsByTagName(key)
        if len(l) == 0:
            return
        return l
 
    def getFrob(self):
        method = "yupoo.auth.getFrob"
        data = {}
        data["method"] = method
        data["api_sig"] = self.calSign(data)
        data["api_key"] = self.api_key
        
        url = self.genUrl(data, addr = self.rest_addr)
        xml = urllib2.urlopen(url).read()
        frob = self.checkXml(xml, "frob")
        if frob:
            self.session_frob = frob.pop().firstChild.nodeValue.encode("ascii")
 
    def checkToken(self):
        data = {}
        data["method"] = self.api.checkToken
        data["auth_token"] = self.session_token
        data["api_sig"] = self.calSign(data)
        data["api_key"] = self.api_key
        url = self.genUrl(data, addr = self.rest_addr)
        xml = urllib2.urlopen(url).read()
        token = self.checkXml(xml, "token")
        if token:
            return True
        
    def getToken(self):
        method = "yupoo.auth.getToken"
        data = {}
        data["method"] = method
        data["frob"] = self.session_frob
        data["api_sig"] = self.calSign(data)
        data["api_key"] = self.api_key
 
        url = self.genUrl(data, addr = self.rest_addr + "debug/")
        xml = urllib2.urlopen(url).read()
        token = self.checkXml(xml, "token")
        if token:
            self.session_token = token.pop().firstChild.nodeValue.encode("ascii")
        else:
            print "cannot get token"
            sys.exit(1)
 
    def auth_access(self):
        acc_addr = "http://www.yupoo.com/services/auth/"
        data = {}
        data["perms"] = "write"
        data["frob"] = self.session_frob
        data["api_sig"] = self.calSign(data)
        data["api_key"] = self.api_key
        
        url = self.genUrl(data, addr = acc_addr)
        return url
 
    def build_request(self, theurl, fields, files, txheaders=None):
        """
        Given the fields to set and the files to encode it returns a fully formed urllib2.Request object.
        You can optionally pass in additional headers to encode into the opject. (Content-type and Content-length will be overridden if they are set).
        fields is a sequence of (name, value) elements for regular form fields - or a dictionary.
        files is a sequence of (name, filename, value) elements for data to be uploaded as files.    
        """
        content_type, body = self.encode_multipart_formdata(fields, files)
        if not txheaders: txheaders = {}
        txheaders['Content-type'] = content_type
        txheaders['Content-length'] = str(len(body))
 
        return urllib2.Request(theurl, body, txheaders)     
 
    def encode_multipart_formdata(self,fields, files, BOUNDARY = '-----'+mimetools.choose_boundary()+'-----'):
        """ Encodes fields and files for uploading.
        fields is a sequence of (name, value) elements for regular form fields - or a dictionary.
        files is a sequence of (name, filename, value) elements for data to be uploaded as files.
        Return (content_type, body) ready for urllib2.Request instance
        You can optionally pass in a boundary string to use or we'll let mimetools provide one.
        """    
        CRLF = "\r\n"
        L = []
        if isinstance(fields, dict):
            fields = fields.items()
        for (key, value) in fields:   
            L.append('--' + BOUNDARY)
            L.append('Content-Disposition: form-data; name="%s"' % key)
            L.append('')
            L.append(value)
        for (key, filename, value) in files:
            filetype = mimetypes.guess_type(filename)[0] or 'application/octet-stream'
            L.append('--' + BOUNDARY)
            L.append('Content-Disposition: form-data; name="%s"; filename="%s"' % (key, filename))
            L.append('Content-Type: %s' % filetype)
            L.append('')
            L.append(value)
        L.append('--' + BOUNDARY + '--')
        L.append('')
        body = CRLF.join(L)
        content_type = 'multipart/form-data; boundary=%s' % BOUNDARY        # XXX what if no files are encoded
        return content_type, body
    
    def photo_upload(self, image):
        upload_addr = "http://www.yupoo.com/api/upload/"
        photo = ('photo', os.path.basename(image), open(image, 'rb').read())
        data = dict([i for i in photo_args.items() if i[1] != ""])
        data = photo_args.copy()
        for key in data.keys():
            if data[key] == "":
                data.pop(key)
        data["frob"] = self.session_frob
        data["auth_token"] = self.session_token
        data["api_sig"] = self.calSign(data)
        data["api_key"] = self.api_key
        url = self.build_request(upload_addr, data, (photo,))
        xml = urllib2.urlopen(url).read()
        res = self.checkXml(xml, "photo")
        if res != None:
            print "ok"
 
def main():
    if len(sys.argv) < 2:
        print "please use \"%s <image file>\"" % sys.argv[0]
        sys.exit(0)
    api = YupooAPI()
    yupoo = Yupoo()
    print "Getting frob... ",
    sys.stdout.flush()
    yupoo.getFrob()
    print "done"
    url = yupoo.auth_access()
    webbrowser.open(url)
    raw_input("press enter to continue after login")
    print "Getting token... ",
    sys.stdout.flush()
    yupoo.getToken()
    print "done"
    print "Uploading... ",
    sys.stdout.flush()
    yupoo.photo_upload(sys.argv[1])
 
if __name__ == "__main__":
    main()
