---
layout: post
title: "Web-to-mobi - A script for converting web sites to mobipocket format"
date: 2012-01-09 03:46
comments: true
categories: 
---

I've written a script to convert [Getting Real](http://gettingreal.37signals.com/toc.php) into mobipocket format.

But the kindle edition of Getting Real is sold at amazon.com, publishing this script may be illegal.

So I've re-written this script like [this](https://github.com/mizzy/web-to-mobi) following the advice from [@otsune](https://twitter.com/#!/otsune)-san.

This script gets JSON data about a web site from STDIN and converts web data to mobipcoket format.

JSON data format is like this.

    {
         "title"    : "Getting Real",
         "author"   : "37signals",
         "chapters" : [
             {
                 "title"     : "Introduction",
                  "sections" : [
                      {
                          "title" : "What is Getting Real?",
                          "uri"   : "http://gettingreal.37signals.com/ch01_What_is_Getting_Real.php"
                      },
                      {
                          "title" : "About 37signals",
                          "uri"   : "http://gettingreal.37signals.com/ch01_About_37signals.php"
                      },
                  ]
            }
         ],
         "content_xpath" : "//div[@class=\"content\"]",
         "exclude_xpath" : "//div[@class=\"next\"]"
    }


This is the image of showing the converted file on Kindle Previewer.

{% img /images/2012/01/getting_real.png Getting Real on Kindle %}