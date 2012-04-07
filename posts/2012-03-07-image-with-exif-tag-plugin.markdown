---
layout: post
title: "Image with EXIF tag plugin"
date: 2012-03-07 23:38
comments: true
categories: 
---

I've modified [Image tag plugin](https://github.com/imathis/octopress/blob/master/plugins/image_tag.rb) into [Image with EXIF tag plugin](https://github.com/mizzy/jekyll-plugins/blob/master/image_with_exif_tag.rb) based on [the idea of mattn-san's comment](/blog/2012/03/07/exif-tag-plugin). (Thanks, mattn-san!)

If you write text like this:

	{% raw %}{% img_with_exif /images/2012/03/first_shot_orion.jpg %}{% endraw %}

You will see the converted result like this:

{% img_with_exif /images/2012/03/first_shot_orion.jpg %}

The title and alt attribute have EXIF data of thie image file.
