---
layout: post
title: ModRuidTestAgain
date: 2011-06-25 12:30:43 +0900
---


3,4年ぐらい前に、[wiki:ModSuid2AndModRuidAndLinuxCapability  mod_suid2 とか mod_ruid とか Linux ケーパビリティとか] で、mod_ruid の setuid/setgid は、プロセス単位なのか、それともスレッド単位なのか、という実験をして、スレッド単位で setuid/setgid する、という結果が得られたんですが、Linux kernel 2.4 というだいぶ古い環境での実験だったので、比較的最近の環境で実験してみた。

OS はこんな感じ。

	
	$ uname -a
	Linux h026.southpark 2.6.18-164.el5 #1 SMP Thu Sep 3 03:28:30 EDT 2009 x86_64 x86_64 x86_64 GNU/Linux
	$ cat /etc/redhat-release
	CentOS release 5.4 (Final)
	

httpd のバージョン。

	
	$ rpm -q httpd
	httpd-2.2.3-45.el5.centos.1
	


ps でプロセス/スレッドが見やすいように /etc/httpd/conf/httpd.conf をいじる。

	
	<IfModule worker.c>
	StartServers        1
	MaxClients          1
	MinSpareThreads     1
	MaxSpareThreads     1
	ThreadsPerChild     1
	MaxRequestsPerChild  0
	</IfModule>
	

/etc/sysconfig/httpd の以下の行を有効にして worker mpm で動かす。

	
	HTTPD=/usr/sbin/httpd.worker
	

mod_ruid は処理が終わるとすぐに元のユーザに戻してしまうので、戻らないようにコメントアウト。

	
	#!diff
	diff --git a/mod_ruid.c b/mod_ruid.c
	index 5294d32..deed59b 100644
	--- a/mod_ruid.c
	+++ b/mod_ruid.c
	@@ -269,9 +269,9 @@ static int ruid_suidback (request_rec * r)
	        }
	        cap_free(cap);
	 
	-       setgroups(0,NULL);
	-       setgid(unixd_config.group_id);
	-       setuid(unixd_config.user_id);
	+       //setgroups(0,NULL);
	+       //setgid(unixd_config.group_id);
	+       //setuid(unixd_config.user_id);
	 
	        cap=cap_get_proc();
	        capval[0]=CAP_SETUID;
	

apxs でビルド＆インストール。

	
	$ sudo /usr/sbin/apxs -a -i -l cap -c mod_ruid.c
	

/etc/init.d/httpd restart して、プロセスとスレッドの UID を確認。下3つは PID が同じなので、スレッドだと判断できる。UID はすべて apache。

	
	$ ps -eLf
	UID        PID  PPID   LWP  C NLWP STIME TTY          TIME CMD
	root     13005     1 13005  0    1 23:29 ?        00:00:00 /usr/sbin/httpd.worker
	apache   13011 13005 13011  0    3 23:29 ?        00:00:00 /usr/sbin/httpd.worker
	apache   13011 13005 13013  0    3 23:29 ?        00:00:00 /usr/sbin/httpd.worker
	apache   13011 13005 13014  0    3 23:29 ?        00:00:00 /usr/sbin/httpd.worker
	

ここで httpd へアクセスし、再度 ps で確認。

	
	UID        PID  PPID   LWP  C NLWP STIME TTY          TIME CMD
	root     13005     1 13005  0    1 23:29 ?        00:00:00 /usr/sbin/httpd.worker
	apache   13011 13005 13011  0    3 23:29 ?        00:00:00 /usr/sbin/httpd.worker
	100      13011 13005 13013  0    3 23:29 ?        00:00:00 /usr/sbin/httpd.worker
	apache   13011 13005 13014  0    3 23:29 ?        00:00:00 /usr/sbin/httpd.worker
	

スレッドのひとつだけ UID が 100 になってる。これは mod_ruid.c に以下のようにデフォルトが定義されているから。

	
	#!c
	#define SUID_DEFAULT_UID        100
	#define SUID_DEFAULT_GID        100
	

というわけで、スレッド単位で setuid/setgid される、ということには変わりありませんでした、という結果に。
