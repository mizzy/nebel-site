---
layout: post
title: ScalableStorageWithOSS02
date: 2008-12-28 17:22:09 +0900
---


[wiki:ScalableStorageWithOSS01 OSS だけでスケーラブルなストレージを安価に構築する方法 #1] のつづき。

# Xen インスタンスの作成

ここは詳しく解説しません。好きなように作成してください。自分は [wiki:Cobbler Cobbler]/[wiki:Koan Koan] を使ってます。インスタンスは6つ作成。

* client0, client1（ストレージをマウントするインスタンス）
* storage0a, storage0b（ストレージを構成するインスタンスセットその1）
* storage1a, storage1b（ストレージを構成するインスタンスセットその2）

全体的な構成概要については、[wiki:ScalableStorageWithOSS01 前回のエントリ] を参照してください。

# エクスポート用ブロックデバイスの作成

storage![01][ab] 上で、GNBD によりエクスポートするブロックデバイス（ディスク）を作成。

ディスクイメージを作成。テスト用なので容量とかは適当に。

	
	$ sudo dd if=/dev/null of=/var/lib/xen/images/storage0a-disk1 bs=1M count=1 seek=1024
	

/etc/xen/storage0a の disk の項目を修正して、作成したディスクイメージを追加。

	
	disk = [ "file:/var/lib/xen/images/storage0a-disk0,xvda,w", "file:/var/lib/xen/images/storage0a-disk1,xvdb,w" ] 
	

	
	$ sudo /usr/sbin/xm create storage0a
	

デバイスができていることを確認。

	
	$ dmesg|grep -B2 xvdb
	Registering block device major 202
	 xvda: xvda1 xvda2
	 xvdb: unknown partition table 
	

パーティション作成。

	
	$ sudo /sbin/parted /dev/xvdb
	(parted) mklabel gpt
	(parted) mkpart primary 0 1074
	(parted) set 1 lvm on
	(parted) quit
	

これで /dev/xvdb1 が作成される。

storage0a 上で完了したら、storage0b, storage1a, storage1b でも同様の作業をする。


# DRBD の設定

storage0a と storage0b の /dev/xvdb1 を同期するための設定を行う。

まずは必要なパッケージのインストール。(storage0a, storage0b 双方で。)

	
	$ sudo yum -y install kmod-drbd82-xen
	

kmod-drbd82-xen が kernel-xen-2.6.18-92.1.10.el5xen に依存していて、うちの環境ではこのバージョンのカーネルがインストールされた。で、/etc/grub.conf をいじって、2.6.18-92.1.10.el5xen で起動するようにして、再起動。

次に/etc/drbd.conf を設定。テストなので適当に。(storage0a, storage0b 双方で。)

	
	global {
	    usage-count no;
	}
	
	common {
	  syncer { rate 10M; }
	}
	
	resource r0 {
	
	  protocol C;
	
	  startup {
	     become-primary-on both;
	  }
	
	
	  net {
	     allow-two-primaries;
	  }
	
	  syncer {
	    rate 10M;
	  }
	
	  on storage0a.example.org {
	    device    /dev/drbd0;
	    disk      /dev/xvdb1;
	    address   192.168.10.20:7788;
	    meta-disk internal;
	  }
	
	  on storage0b.example.org {
	    device    /dev/drbd0;
	    disk      /dev/xvdb1;
	    address   192.168.10.27:7788;
	    meta-disk internal;
	  }
	
	} 
	

設定を終えたら、起動する。(storage0a, storage0b 双方で。)

	
	$ sudo /sbin/modprobe drbd minor_count=1
	$ sudo /sbin/drbdadm create-md r0
	$ sudo /sbin/drbdadm up all
	

この時点で、どっちもセカンダリになってるはず。

	
	$ cat /proc/drbd
	version: 8.2.6 (api:88/proto:86-88)
	GIT-hash: 3e69822d3bb4920a8c1bfdf7d647169eba7d2eb4 build by buildsvn@c5-x8664-build, 2008-08-07 17:50:46
	 0: cs:Connected st:Secondary/Secondary ds:Inconsistent/Inconsistent C r---
	    ns:0 nr:0 dw:0 dr:0 al:0 bm:0 lo:0 pe:0 ua:0 ap:0 oos:1048472
	

片方を primary にして、同期を開始する。(storage0a だけで実行。）

	
	$ sudo /sbin/drbdadm -- --overwrite-data-of-peer primary all
	

同期中は /proc/drbd がこんな感じになる。

	
	$ cat /proc/drbd
	version: 8.2.6 (api:88/proto:86-88)
	GIT-hash: 3e69822d3bb4920a8c1bfdf7d647169eba7d2eb4 build by buildsvn@c5-x8664-build, 2008-08-07 17:50:46
	 0: cs:SyncSource st:Primary/Secondary ds:UpToDate/Inconsistent C r---
	    ns:40436 nr:0 dw:0 dr:40436 al:0 bm:2 lo:0 pe:0 ua:0 ap:0 oos:1008036
	        [>....................] sync'ed:  4.0% (1008036/1048472)K
	        finish: 0:01:38 speed: 10,108 (10,108) K/sec
	

同期が完了するとこんな感じ。

	
	$ cat /proc/drbd
	version: 8.2.6 (api:88/proto:86-88)
	GIT-hash: 3e69822d3bb4920a8c1bfdf7d647169eba7d2eb4 build by buildsvn@c5-x8664-build, 2008-08-07 17:50:46
	 0: cs:Connected st:Primary/Secondary ds:UpToDate/UpToDate C r---
	    ns:1048472 nr:0 dw:0 dr:1048472 al:0 bm:64 lo:0 pe:0 ua:0 ap:0 oos:0
	

両方プライマリにするので、現在のセカンダリ(storage0b)で以下を実行。

	
	$ sudo /sbin/drbdadm primary r0
	

両方プライマリになる。

	
	$ cat /proc/drbd
	version: 8.2.6 (api:88/proto:86-88)
	GIT-hash: 3e69822d3bb4920a8c1bfdf7d647169eba7d2eb4 build by buildsvn@c5-x8664-build, 2008-08-07 17:50:46
	 0: cs:Connected st:Primary/Primary ds:UpToDate/UpToDate C r---
	    ns:0 nr:1048472 dw:1048472 dr:0 al:0 bm:64 lo:0 pe:0 ua:0 ap:0 oos:0
	

これで DRBD による同期は完了。sorage1a, storage1b についても同様の操作を行う。

# 現在の状態

ここまでセットアップした状態を図にすると、以下のようになります。

[[Image(http://trac.mizzy.org/public/attachment/wiki/ScalableStorageWithOSS02/storages_with_drbd.jpg?format=raw)]]

以下の [wiki:ScalableStorageWithOSS01 前回エントリの構成図] と比較してみて下さい。 

[[Image(http://trac.mizzy.org/public/attachment/wiki/ScalableStorageWithOSS01/scalable_storage.jpg?format=raw)]]

次回は GNBD によるブロックデバイスのエクスポート/インポートについて説明する予定です。

# 関連エントリ

* [wiki:ScalableStorageWithOSS00 OSS だけでスケーラブルなストレージを安価に構築する方法 #0]
* [wiki:ScalableStorageWithOSS01 OSS だけでスケーラブルなストレージを安価に構築する方法 #1]
* [wiki:ScalableStorageWithOSS03 OSS だけでスケーラブルなストレージを安価に構築する方法 #3]
* [wiki:ScalableStorageWithOSS04 OSS だけでスケーラブルなストレージを安価に構築する方法 #4]
* [wiki:ScalableStorageWithOSS05 OSS だけでスケーラブルなストレージを安価に構築する方法 #5]
