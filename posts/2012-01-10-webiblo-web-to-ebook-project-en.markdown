---
layout: post
title: "Webiblo - web to ebook project"
date: 2012-01-10 20:17
comments: true
categories: 
---

I've started the project [webiblo](https://github.com/mizzy/webiblo).This is the improved fork of [web-to-mobi](https://github.com/mizzy/web-to-mobi).

This project includes the script to convert web sites into  ebook format(currently mobipocket only) data from given JSON data and gathering the JSON data for web sites.

Currently, you can generate mobipocket format data with the URI of JSON data like this:

    $ webiblo.pl http://mizzy.org/webiblo/data/Getting_Real.json

Or with JSON data through STDIN.

    $ cat data.json | webiblo.pl

This script needs [KindleGen](http://www.amazon.com/gp/feature.html?docId=1000234621).

JSON data is like this:

    {
        "title"       : "Structure and Interpretation of Computer Programs",
        "authors"     : [
            "Harold Abelson",
            "Gerald Jay Sussman",
            "Julie Sussman"
        ],
        "cover_image"   : "http://mitpress.mit.edu/sicp/full-text/book/cover.jpg",
        "content_xpath" : "//div[@class=\"content\"]", # Optional
        "exclude_xpath" : "//div[@class=\"navigation\"]", # Optional
        "chapters" : [
            {
                "title" : "Foreword",
                "uri"   : "http://mitpress.mit.edu/sicp/full-text/book/book-Z-H-5.html#%_chap_Temp_2"
            },
            {
                "title" : "1  Building Abstractions with Procedures",
                "uri"  : "http://mitpress.mit.edu/sicp/full-text/book/book-Z-H-9.html#%_chap_1",
                "sections" : [
                    "title" : "1.1  The Elements of Programming",
                    "uri"   : "http://mitpress.mit.edu/sicp/full-text/book/book-Z-H-10.html#%_sec_1.1"
                    "subsections" : [
                        {
                            "title" : "1.1.1  Expressions",
                            "uri"   : "http://mitpress.mit.edu/sicp/full-text/book/book-Z-H-10.html#%_sec_1.1.1"
                        },
                    ]
                ]
            }
        ]
    }

Overview of the JSON data is following:

 * Book data
   * Title
   * Authors
   * Cover Image
   * XPath that represents the content part (Optional)
   * XPath that represents the uneeded part of the content (Optional)
   * Chapters
     * Title of the chapter
     * URI of the chapter page
     * Sections
       * Title of the secion
       * URI of the section page
       * Subsections
         * Title of the subsection
         * URI of the subsection page

There are two JSON data for [Getting Real](http://gettingreal.37signals.com/toc.php)  and [SICP](http://mitpress.mit.edu/sicp/full-text/book/book.html) on [my web site(http://mizzy.org/webiblo/) .

JSON data are put on the [gh-pages branch](https://github.com/mizzy/webiblo/tree/gh-pages).Pull requests are welcome.
