---
layout: post
title: LsyncdRsyncTargetDirectory
date: 2010-01-15 18:12:39 +0900
---


[wiki:InotifyAndMakuosan inotify + makuosan でいい感じのリアルタイムミラーリング] で、lsyncd は結局は rsync を裏で呼び出してるので、差分チェックの呪縛からは逃れられない、的なことを書いてたんですが、ふと、「もしかして、inotify から rsyncを呼び出すときに、同期対象となるファイルは、指定したディレクトリ以下のもの全部ではなく、変更があったファイルがあるディレクト以下のものだけ、なんて動きをしてくれるのかな？」と気になったので、実際に試してみました。結果から先に言うと、想定通りの動きとなってます。これって常識なんですかね？以下、試した時のログ。

ログを確認するために、lsyncd をフォアグランドで起動。

	
	$ ./lsyncd --no-daemon /tmp/lsyncd localhost:/var/tmp/lsyncd
	Fri Jan 15 17:46:59 2010: command line options: syncing /tmp/lsyncd/ -> localhost:/var/tmp/lsyncd
	
	Fri Jan 15 17:46:59 2010: Starting up
	Fri Jan 15 17:46:59 2010: watching /tmp/lsyncd/
	
	Fri Jan 15 17:47:00 2010: --- Entering normal operation with [1] monitored directories ---
	

ディレクトリを作成してみる。

	
	$ mkdir /tmp/lsyncd/0
	

ログから、同期対象となってるのが、/tmp/lsyncd と、今作成した /tmp/lsyncd/0 であることがわかる。

	
	Fri Jan 15 17:47:06 2010: event CREATE:0 triggered.
	Fri Jan 15 17:47:06 2010: rsyncing /tmp/lsyncd/ --> localhost:/var/tmp/lsyncd/
	Fri Jan 15 17:47:06 2010: rsyncing /tmp/lsyncd/0/ --> localhost:/var/tmp/lsyncd/0/
	

さらにその下にディレクトリを作成。

	
	$ mkdir /tmp/lsyncd/0/1
	

同期対象となってるのが、/tmp/lsyncd/0 と、今作成した /tmp/lsyncd/0/1 であることがわかる。

	
	Fri Jan 15 17:47:48 2010: event CREATE:1 triggered.
	Fri Jan 15 17:47:48 2010: rsyncing /tmp/lsyncd/0/ --> localhost:/var/tmp/lsyncd/0/
	Fri Jan 15 17:47:48 2010: rsyncing /tmp/lsyncd/0/1/ --> localhost:/var/tmp/lsyncd/0/1/
	

さらにその下にディレクトリを作成。

	
	$ mkdir /tmp/lsyncd/0/1/2
	

同期対象となってるのが、/tmp/lsyncd/0/1 と、今作成した /tmp/lsyncd/0/1/2 であることがわかる。

	
	Fri Jan 15 17:48:26 2010: event CREATE:2 triggered.
	Fri Jan 15 17:48:26 2010: rsyncing /tmp/lsyncd/0/1/ --> localhost:/var/tmp/lsyncd/0/1/
	Fri Jan 15 17:48:26 2010: rsyncing /tmp/lsyncd/0/1/2/ --> localhost:/var/tmp/lsyncd/0/1/2/
	

/tmp/lsyncd/0/1/2 の下にファイルを作ってみる。

	
	$ touch /tmp/lsyncd/0/1/2/3.txt
	

同期対象が /tmp/lsyncd/0/1/2 だけであることがわかる。（CREATE イベントと CLOSE_WRITE イベントで2回同期してる。）

	
	Fri Jan 15 17:49:07 2010: event CREATE:3.txt triggered.
	Fri Jan 15 17:49:07 2010: rsyncing /tmp/lsyncd/0/1/2/ --> localhost:/var/tmp/lsyncd/0/1/2/
	Fri Jan 15 17:49:07 2010: event CLOSE_WRITE:3.txt triggered.
	Fri Jan 15 17:49:07 2010: rsyncing /tmp/lsyncd/0/1/2/ --> localhost:/var/tmp/lsyncd/0/1/2/
	

というわけで、やはり rsync による差分チェックはあるものの、対象ディレクトリを絞り込めるので、適切なディレクトリ構造にしていれば、rsync only よりはかなり負荷は抑えられそうな感じですね。