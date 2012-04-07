---
layout: post
title: ScalableStorageWithOSS03
date: 2008-12-28 17:22:39 +0900
---


[wiki:ScalableStorageWithOSS02 OSS だけでスケーラブルなストレージを安価に構築する方法 #2] のつづき。今回はストレージサーバ側で GNBD によりブロックデバイスをエクスポートし、クライアント側でインポートするまでの手順を紹介します。

# ストレージクラスタ

用途的にはクラスタリングする必要はないのですが、GNBD でエクスポートする際に、[cman(Cluster Manager)](http://sources.redhat.com/cluster/cman/) を動かす必要があるため、まずは cman をインストール、設定、起動して、ストレージクラスタを構成します。

といっても、クラスタリングは本来の趣旨とははずれるので、設定は適当。

まずは storage0a と storage0b をクラスタリング。最初に storage0a で cman をインストール。

	
	$ sudo yum -y install cman
	

storage0a で ccs_tool を実行し、/etc/cluster/cluster.conf のスケルトンを作成。

	
	$ sudo /sbin/ccs_tool create storage0
	

/etc/cluster/cluster.conf を以下のように修正。

	
	<?xml version="1.0"?>
	<cluster name="storage0" config_version="1">
	    <clusternodes>
	        <clusternode name="storage0a.example.org" nodeid="1" votes="1"/>
	    </clusternodes>
	  <fencedevices/>
	  <rm>
	    <failoverdomains/>
	    <resources/>
	  </rm>
	</cluster>
	

cman を起動。

	
	$ sudo /etc/init.d/cman start
	

次に、sorage0b をクラスタに追加するべく、/etc/cluster/cluster.conf を、storage0a 上で修正。

	
	<?xml version="1.0"?>
	<cluster name="storage0" config_version="2">
	    <clusternodes>
	        <clusternode name="storage0a.example.org" nodeid="1" votes="1"/>
	        <clusternode name="storage0b.example.org" nodeid="2" votes="1"/>
	    </clusternodes>
	  <fencedevices/>
	  <rm>
	    <failoverdomains/>
	    <resources/>
	  </rm>
	</cluster>
	

config_version の値をインクリメントしておくのがポイント。ccs_tool update を実行して、設定を反映。

	
	$ sudo /sbin/ccs_tool update /etc/cluster/cluster.conf
	

次に storage0b 側で cman を起動。

	
	$ sudo yum -y install cman
	$ sudo /sbin/ccs_tool create storage0
	$ sudo /etc/init.d/cman start
	

/etc/cluster/cluster.conf は、storage0a から自動的にコピーされる。cman_tool nodes を実行すると、クラスタメンバが表示される。

	
	$ sudo /sbin/cman_tool nodes
	Node  Sts   Inc   Joined               Name
	   1   M     24   2008-10-25 04:29:59  storage0a.example.org
	   2   M      4   2008-10-25 04:23:50  storage0b.example.org
	

storage0a と storage0b のクラスタリングができたら、storage1a と storage1b を同様にクラスタリング。上記で storage0 と書かれているところを storage1 と読み替えて、同じ手順を実行。


# GNBD エクスポート

次に、storage0a, storage0b で GNBD によりブロックデバイスをエクスポート。まずは gnbd をインストール。

	
	$ sudo yum -y install gnbd
	

gnbd_serv を起動。

	
	$ sudo /sbin/gnbd_serv
	gnbd_serv: startup succeeded
	

エクスポート。storage0a では以下のように。-d で指定するデバイス名は、DRBD デバイスを指定。-e では適当なエクスポート名をつける。

	
	$ sudo /sbin/gnbd_export -d /dev/drbd0 -e gnbd0a -u0
	gnbd_export: created GNBD gnbd0a serving file /dev/drbd0
	

storage0b では以下のように、-e オプションで指定するエクスポート名を変える。-u で指定する UID は、storage0a と storage0b で同じにする必要がある。（Device-Mapper Multipath で同一デバイスと認識させるため。）

	
	$ sudo /sbin/gnbd_export -d /dev/drbd0 -e gnbd0b -u0
	gnbd_export: created GNBD gnbd0b serving file /dev/drbd0
	

-l オプションで、エクスポート状態を確認できる。

	
	$ sudo /sbin/gnbd_export -l
	Server[1] : gnbd0a
	--------------------------
	      file : /dev/drbd0
	   sectors : 2096944
	  readonly : no
	    cached : no
	   timeout : 60
	       uid : 0
	

strage1a, storage1b でも同様にエクスポートする。


# クライアントクラスタ

GNBD でインポートするクライアント側でも cman を動かす必要があるので、client0, client1 で cman を動かす。後に出てくる CLVM でも必要。注意点は、ccs_tool create で指定するクラスタ名を、ストレージクラスタで指定したものを別にすること。

	
	$ sudo /sbin/ccs_tool create client  
	

あとの手順はストレージの時と一緒。


# GNBD インポート

client0, client1 でストレージサーバからエクスポートされているデバイスをインポートする。以下の手順を、client0, client1 双方で実行。

まずは GNBD カーネルモジュールと GNBD をインストール。

	
	$ sudo yum -y install kmod-gnbd-xen gnbd
	

インポートする。

	
	$ sudo /sbin/modprobe gnbd
	$ sudo /sbin/gnbd_import -i storage0a.example.org
	$ sudo /sbin/gnbd_import -i storage0b.example.org
	$ sudo /sbin/gnbd_import -i storage1a.example.org
	$ sudo /sbin/gnbd_import -i storage1b.example.org
	

-l オプションでインポート状況を確認。

	
	$ sudo /sbin/gnbd_import -l
	Device name : gnbd0a
	----------------------
	    Minor # : 0
	 sysfs name : /block/gnbd0
	     Server : storage0a.example.org
	       Port : 14567
	      State : Close Connected Clear
	   Readonly : No
	    Sectors : 2096944
	
	Device name : gnbd0b
	----------------------
	    Minor # : 1
	 sysfs name : /block/gnbd1
	     Server : storage0b.example.org
	       Port : 14567
	      State : Close Connected Clear
	   Readonly : No
	    Sectors : 2096944
	
	Device name : gnbd1a
	----------------------
	    Minor # : 2
	 sysfs name : /block/gnbd2
	     Server : storage1a.example.org
	       Port : 14567
	      State : Close Connected Clear
	   Readonly : No
	    Sectors : 2096944
	
	Device name : gnbd1b
	----------------------
	    Minor # : 3
	 sysfs name : /block/gnbd3
	     Server : storage1b.example.org
	       Port : 14567
	      State : Close Connected Clear
	   Readonly : No
	    Sectors : 2096944
	

デバイスファイルを確認してみる。

	
	$ ls /dev/gnbd/
	gnbd0a  gnbd0b  gnbd1a  gnbd1b 
	

/dev/gnbd/gnbd0a は、/dev/gnbd0 と同じデバイス。他も同様。

# 現在の状態

ここまでセットアップした状態を図にすると、以下のようになります。GNBD により、ネットワーク越しにブロックデバイスにアクセスできるようになっています。

[[Image(http://trac.mizzy.org/public/attachment/wiki/ScalableStorageWithOSS03/storages_with_gnbd.jpg?format=raw)]]

次回は DM-MP あたりを解説予定。


# 関連エントリ

* [wiki:ScalableStorageWithOSS00 OSS だけでスケーラブルなストレージを安価に構築する方法 #0]
* [wiki:ScalableStorageWithOSS01 OSS だけでスケーラブルなストレージを安価に構築する方法 #1]
* [wiki:ScalableStorageWithOSS02 OSS だけでスケーラブルなストレージを安価に構築する方法 #2]
* [wiki:ScalableStorageWithOSS04 OSS だけでスケーラブルなストレージを安価に構築する方法 #4]
* [wiki:ScalableStorageWithOSS05 OSS だけでスケーラブルなストレージを安価に構築する方法 #5]