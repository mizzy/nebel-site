---
layout: post
title: HowDotCloudLazyCopyImplementsCopyOnWrite
date: 2011-07-17 23:44:34 +0900
---


[dotcloud/lazycopy](https://github.com/dotcloud/lazycopy) is a copy-on-write version of cp.It's based on [aufs](http://aufs.sourceforge.net/).

Scientific Linux 5 has aufs rpm on its base repo.So I tried aufs and lazycopy on SL5.CentOS and SL6 don't have aufs rpm.

I created source directories and files in them first.

	
	# mkdir /tmp/source0
	# mkdir /tmp/source1
	# mkdir /tmp/source2
	# echo source0 > /tmp/source0/0
	# echo source1 > /tmp/source1/1
	# echo source2 > /tmp/source2/2
	

And copied these directories to /tmp/dest with lazycopy command.

	
	# lazycopy /tmp/source0 /tmp/source1 /tmp/source2 /tmp/dest
	['/tmp/source0', '/tmp/source1', '/tmp/source2'] -> /tmp/dest
	

Confirmed that three files wiere there and the content of one of the files.

	
	# ls /tmp/dest/
	0  1  2
	# cat /tmp/dest/0
	source0
	

Changed the content of /tmp/dest/0 and confirmed that /tmp/source0/0 was not changed.

	
	# echo dest > /tmp/dest/0 
	# cat /tmp/dest/0 
	dest
	# cat /tmp/source0/0 
	source0
	

Lazycopy implements copy-on-write by mounting directories with aufs like this.

	
	# mount
	...
	none on /tmp/dest type aufs (rw,br:/tmp/dest/.aufs/0=rw:/tmp/source0=ro:/tmp/source1=ro:/tmp/source2=ro)
	

Lazycopy creates .aufs/0 directory in the destination directory if it doesn't exist and mounts it with rw mode as one of the aufs branch.Other source directories are mounted with ro mode, so files in these directories will not be changed.

Changed files and newly created files are saved under /tmp/dest/.aufs/0 directory.So you can see the directory structures like this after unmounting /tmp/dest.

	
	# touch /tmp/dest/3
	# umount /tmp/dest
	# tree -a /tmp/dest
	/tmp/dest
	`-- .aufs
	    `-- 0
	        |-- .wh..wh..tmp
	        |-- .wh..wh.aufs
	        |-- .wh..wh.plnk
	        |-- 0
	        `-- 3
	

So if you unmount /tmp/dest directory and run lazycopy with same options again, you can see the changed files and created files again.
