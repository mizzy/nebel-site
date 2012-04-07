---
layout: post
title: "EXIF tag plugin"
date: 2012-03-07 00:19
comments: true
categories: 
---

I've wrote [EXIF tag plugin for Jekyll](https://github.com/mizzy/jekyll-plugins/blob/master/exif_tag.rb).

If you write text like this:

	{% raw %}{% img /images/2012/03/first_shot_orion.jpg %}{% endraw %}
	
	{% raw %}{% exif /images/2012/03/first_shot_orion.jpg %}{% endraw %}

You will see the converted result like this:

{% img /images/2012/03/first_shot_orion.jpg %}

{% exif /images/2012/03/first_shot_orion.jpg %}


