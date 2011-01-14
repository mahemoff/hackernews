#!/usr/bin/env python
#
# Copyright 2010 Paul Kinlan.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

from google.appengine.ext import webapp
from google.appengine.ext.webapp import util
from google.appengine.api import urlfetch

import re
import logging
from urlparse import urlparse
from django.utils import simplejson


title = "<title>(.+)</title>"
description = "<meta name=(\"|\')description(\"|\') content=\"([^\"\']+)"
favicon = "<link rel=\"(shortcut |apple-touch-){0,1}icon\"([^>]+)"

def parseFavIcon(baseUrl, match):
  linkTag = match.group(0)
  #find the href
  
  hrefMatch = re.search("href=(\'|\")([^\"\']+)", linkTag, re.I)
  sizesMatch = re.search("sizes=(\'|\")(\d{0,3})", linkTag, re.I)
  
  if linkTag.find("apple-touch-icon") >= 0:
    size = "128"
  else:
    size = "16"
  
  if sizesMatch:
    size = sizesMatch.group(2)
  
  href = hrefMatch.group(2)
  
  if href.find("http") == -1:
    href = baseUrl + href.lstrip("/")
    
  return (size, href)

class FetchInformationHandler(webapp.RequestHandler):
  def get(self):
    url = self.request.get("url")
    meta = {}
    
    fetcheddata = urlfetch.fetch(url, deadline = 10)
    self.response.status_code = fetcheddata.status_code
    self.response.out.write(fetcheddata.content + "<script src=\"/lib/readabilty.js\"></script>")
    
class FetchImageHandler(webapp.RequestHandler):
  def get(self):
    url = self.request.get("url")

    fetcheddata = urlfetch.fetch(url, deadline = 10)
    
    self.response.status_code = fetcheddata.status_code
    self.response.headers['Content-Type'] = fetcheddata.headers['Content-Type']
    self.response.out.write(fetcheddata.content)

def main():
  application = webapp.WSGIApplication([
    ('/api/fetch', FetchInformationHandler),
    ('/api/image', FetchImageHandler)
  ], debug=True)
  util.run_wsgi_app(application)

if __name__ == '__main__':
  main()
