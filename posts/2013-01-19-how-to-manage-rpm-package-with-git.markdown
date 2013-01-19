---
title: How to manage RPM packages with Git
date: 2013-01-19 17:52:35 +0900
---

Now I manage RPM packages like [this repo](https://github.com/paperboy-sqale/sqale-yum). I put source and binary packages in this repo.But this way has these problems.

 * Binary packages' size is too big.It takes long time to git clone, push, pull and so on.
 * I cannot see the history of each file in the packages.
   * It's not very meaningful to use Git.

I'd like to change like this.

 * Put the requisite minumum files to see the hisotory of each file.
   * Not put binary packages.(Source packages are OK if needed.)
 * Build packages with files managed with Git.

And I made the prototype of this idea like this.

[mizzy/how-to-manage-rpm-packages-with-git](https://github.com/mizzy/how-to-manage-rpm-packages-with-git)

The file/directory strucure in this repo is like this.

```
|-- build.rb
|-- ffmpeg
|   |-- ffmpeg-github-0.8.2.spec
|   |-- libavformat-muxer.paperboy.patch
|   |-- libx264-superfast_firstpass.ffpreset
|   `-- libx264-veryfast_firstpass.ffpreset
|-- memcached
|   |-- memcached-1.4.15-1.el6.src.rpm
|   `-- memcached.spec
`-- ngx_openresty
    `-- ngx_openresty.spec
```

Build rb is the package build script, and others are directories for each package.Which files should be managed is vary from package to package, so I arrange several patterns.

----

## Pattern 1: ngx_openresty


With [this pattern](https://github.com/mizzy/how-to-manage-rpm-packages-with-git/tree/master/ngx_openresty), all I have to manage is spec file.In this spec file,

```
Source0: http://agentzh.org/misc/nginx/ngx_openresty-%{version}.tar.gz
```

You can see this line.Build.rb gets this file, pust under ~/rpmbuild/SOURCES and build source and binary packages.This is the simplest pattern.

----

## Pattern2: ffpmeg

[This pattern](https://github.com/mizzy/how-to-manage-rpm-packages-with-git/tree/master/ffmpeg) has a spec file, patch files and other files.If you need original patches and manage patch files with Git, this pattern is suitable.

```
Source: http://www.ffmpeg.org/releases/ffmpeg-%{version}.tar.bz2
```

Build.rb get this source file in spec, put this source, patches and other files under ~/rpmbuild/SOURCE and build source and binary packages.


----

## Pattern 3: memcached

With [this pattern](https://github.com/mizzy/how-to-manage-rpm-packages-with-git/tree/master/memcached), You'd like to change the build options of the existence source package, but the sources in spec file is like this.

```
Source0:        http://memcached.googlecode.com/files/%{name}-%{version}.tar.gz
Source1:        memcached.sysv
```
So you can't get the memcached.sysv through the network.But this file is included in the existence source package and you don't need to manage it with Git.

In this case, it's easy to put the existence source package under the Gir repo.


----

With any of these patterns, you can see the history of each file, total file size in the repo is minimum and all files needed to build package are found in the repo.


----

## Package Building and Deploying

My final goal is, git clone these files, build packages with the script [like this](https://github.com/mizzy/how-to-manage-rpm-packages-with-git/blob/master/build.rb) and deploy the packages to yum servers automatically.

----

## Other featuer

Also I'd like to write git url as source in the spec file like this.


```
Source: git://github.com/torvalds/linux.git, ref: dfdeb
```

Build script will clone source files from this git url, build tar ball from these and build package.This idea is inspired by [Bundler](http://gembundler.com/).

