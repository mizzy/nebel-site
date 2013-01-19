---
layout: post
title: "Rakuten tag plugin for Jekyll"
date: 2012-03-04 22:37
comments: true
categories: 
---

I've wrote [Rakuten tag plugin for Jekyll](https://github.com/mizzy/jekyll-plugins/blob/master/rakuten_tag.rb).

This is inspired by [Amazon Plugin for Octopress](http://zanshin.net/2011/08/24/amazon-plugin-for-octopress/).

You can use this plugin like this.

	{% raw %}{{ "nikondirect:10000641" | rakuten_large_image }}{% endraw %}

{{ "nikondirect:10000641" | rakuten_large_image }}

	{% raw %}{{ "nikondirect:10000641" | rakuten_medium_image }}{% endraw %}

{{ "nikondirect:10000641" | rakuten_medium_image }}

	{% raw %}{{ "nikondirect:10000641" | rakuten_small_image }}{% endraw %}

{{ "nikondirect:10000641" | rakuten_small_image }}

	{% raw %}{{ "nikondirect:10000641" | rakuten_link }}{% endraw %}

{{ "nikondirect:10000641" | rakuten_link }}
