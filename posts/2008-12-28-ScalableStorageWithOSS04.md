---
layout: post
title: ScalableStorageWithOSS04
date: 2008-12-28 17:23:16 +0900
---


[wiki:ScalableStorageWithOSS03 OSS だけでスケーラブルなストレージを安価に構築する方法 #3] のつづき。今回は Device-Mapper Multipath をつかって、DRBD によりミラーされている2つのブロックデバイスを、仮想的にひとつに見えるようにします。

まずは client0 と client1 に device-mapper-multipath がインストールされていなければ、インストール。

	
	$ sudo yum -y install device-mapper-multipath
	

/etc/multipath.conf を修正。デフォルトでは blacklist の devnode に * が指定されていて、すべてのデバイスに対して無効になっているので、blacklist をコメントアウト。

	
	# Blacklist all devices by default. Remove this to enable multipathing
	# on the default devices.
	#blacklist {
	#        devnode "*"
	#}
	

multipathd を restart。

	
	$ sudo /etc/init.d/multipathd restart
	

multipath -l で確認。

	
	$ sudo /sbin/multipath -l
	mpath1 (1) dm-1 GNBD,GNBD
	[size=1024M][features=0][hwhandler=0]
	\_ round-robin 0 [prio=0][active]
	 \_ #:#:#:# gnbd2 252:2 [active][undef]
	 \_ #:#:#:# gnbd3 252:3 [active][undef]
	mpath0 (0) dm-0 GNBD,GNBD
	[size=1024M][features=0][hwhandler=0]
	\_ round-robin 0 [prio=0][active]
	 \_ #:#:#:# gnbd0 252:0 [active][undef]
	 \_ #:#:#:# gnbd1 252:1 [active][undef]  
	

gnbd0 と gnbd1 が /dev/mapper/mpath0 として見え、gnbd2 と gnbd3 が /dev/mapper/mpath1 として見える。

この状態で、/dev/mapper/mpath0 へ書き込みが発生すると、gnbd0 か gnbd1 のどちらかに書き込まれ、DRBD によりもう一方にミラーされる、という状態ができあがり。図にすると以下のような状態。/dev/mapper/mpath0 から読み込んだ場合にも、gnbd0 か gnbd1 のどちらかから読み込むことになるが、DRBD によりミラーされているので、どちらを読みに行っても OK。



[[Image(http://trac.mizzy.org/public/attachment/wiki/ScalableStorageWithOSS04/storages_with_dmmp.jpg?format=raw)]]


次回は /dev/mapper/mpath0 と /dev/mapper/mpath1 を物理ボリュームとして、 CLVM によりひとつの論理ボリュームを構成し、論理ボリュームのメタデータを client0 と client1 間で共有する方法について解説します。

# 関連エントリ

* [wiki:ScalableStorageWithOSS00 OSS だけでスケーラブルなストレージを安価に構築する方法 #0]
* [wiki:ScalableStorageWithOSS01 OSS だけでスケーラブルなストレージを安価に構築する方法 #1]
* [wiki:ScalableStorageWithOSS02 OSS だけでスケーラブルなストレージを安価に構築する方法 #2]
* [wiki:ScalableStorageWithOSS03 OSS だけでスケーラブルなストレージを安価に構築する方法 #3]
* [wiki:ScalableStorageWithOSS05 OSS だけでスケーラブルなストレージを安価に構築する方法 #5]