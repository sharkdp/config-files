#!/usr/bin/python
# -*- coding: utf-8 -*-
''' Simple url downloader for ATP'''
import sys
url, tmpf = sys.argv[1:3]
if sys.version_info.major < 3:
    # Python 2.7 code:
    import sys, urllib2, tempfile

    try:
        f = open(tmpf, "w")
    except IOError as e:
        print(str(e))
    else:
        data = urllib2.urlopen(url)
        f.write(data.read())
        # I should check the encoding of the url.
        f.close()
else:
    # Python3 code:
    import urllib.request, urllib.error, urllib.parse

    data = urllib.request.urlretrieve(url,tmpf)
