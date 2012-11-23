# Nebel-site - A static site template for nebel

This is a site template and utilities for [nebel](https://github.com/mizzy/nebel).

## How to set up

Clone this repository, move to its dirctory and execute bundle install.

```
$ git clone git://github.com/mizzy/nebel-site.git
$ cd nebel-site
$ bundle install
```

## Create and edit site template files

 * layouts/post.html
   * This is a template file for each entry. Please edit this.
 * layouts/atom.xml
   * This is a template file for an atom feed. Please edit this.
 * layouts/archive.html
   * This is a template file for archive. Please edit this.
 * static/
   * This is a directory for static files.You can put any files, like css, javascript, images and so on.
   * You can make any sub directories in this directory.

## Create a post file

Create a post file in posts directory.File name should be ended with ".md" or ".markdown".

The content of the post file is like this.

```
---
title: Entry title
date: 2012-04-24 18:15:59 +0900
---

Entry body.You can write anything with Markdown syntax.


```

## Execute nebel command

```
$ bundle exec nebel
```

This command process post files and put generated files in public directory.

Also this command copies all files in static directory to public directory.

## Options

You can customize default behaviour of nebel with some of the options.

```
$ bin/nebel --help
Usage: nebel [options]
    -b, --base-url [PATH]            Serve website from a given base URL        (default '/blog')
    -a, --archive                    Generate archive pages                     (default '/archive')
        --no-clean-dir               Doesn't remove files in public dir
    -h, --help                       Show this message
```

### ~/.nebelrc

Hey Bonus! You can automatically pass the options with `~/.nebelrc` like as below.

```
--base-url / --no-clean-dir --archive
```

## See contents with the test server

Execute this command and you can see generated contents with http://localhost:5000/


```
$ bundle exec nebel-server
```

## Publish your contents

Upload files in public directories to any servers you like.



## Utilities

Some utilities are included.

You can create a post file and open it with an editor easily like this.

```
$ thor post:create entry-title
```

This command generate a post file something like posts/2012-04-24-entry-title.markdown and its content is like this.

```
---
title: entry-title
date: 2012-04-24 19:25:34 +0900
---

```


With bundle exec guard, nebel command is executed automatically if files are changed.
If your enviroment is ready for guard-livereload, the browser page is reloaded automatically.


```
$ bundle exec guard
```


thor server:start runs following things.

 * Runs nebel-server
 * Opens http://localhost:5000/ with your browser
 * Executes bundle exec guard

```
$ thor server:start
```
