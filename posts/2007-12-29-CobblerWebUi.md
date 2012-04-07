---
layout: post
title: CobblerWebUi
date: 2007-12-29 00:47:43 +0900
---


[前回のエントリで書いた](http://trac.mizzy.org/public/wiki/Cobbler) Cobbler にはウェブ UI がある。その設定方法のメモ。設定方法は[ここ](https://hosted.fedoraproject.org/cobbler/wiki/OldCobblerWebUi)を参照した。Cobbler のバージョンが 0.7 以降の場合は[こっちを参照](https://hosted.fedoraproject.org/cobbler/wiki/CobblerWebInterface)。

まずは /var/lib/cobbler/settings の xmlrpc_rw_enabled を 1 に設定。

	
	xmlrpc_rw_enabled:  1
	

これを見て想像がつくと思うけど、cobblerd が XMLRPC リクエストを受け付けるようになる。

次に /etc/cobbler/auth.conf で、cobblerd の XMLRPC へのアクセスを許可するユーザ ID とパスワードを設定する。


	
	[xmlrpc_service_users]
	admin = password
	

/etc/cobbler/auth.conf が httpd ユーザから読めるようにする。

	
	$ sudo chown apache /etc/cobbler/auth.conf
	

SELinux を利用している場合はこの設定も必要らしい。（自分は SELinux は disabled にしてる。）

	
	$ sudo chcon -t httpd_sys_content_t /etc/cobbler/auth.conf
	$ sudo setsebool httpd_can_network_connect true
	

httpd で認証するユーザ名とパスワードを設定する。これは /etc/cobbler/auth.conf で設定したものと同じにする。

	
	$ sudo htdigest /var/www/cgi-bin/cobbler/.htpasswd "Cobbler WebUI Authentication" admin
	


あとは http://cobbler.example.org/cgi-bin/cobbler/webui.cgi にアクセスすれば OK。以下のスクリーンショットは Profile を表示させたところ。

[[Image(cobbler_web_ui.jpg)]]

この画面見てて気づいたんだけど、Cobbler では system の登録ができて、MAC アドレスを登録して Profile を指定しておけば、PXE ブート時にイメージ名を入力しなくても、勝手に指定された Profile のイメージでブートしてくれる。

system の登録はコマンドラインでもできる。

	
	$ sudo cobbler system add --name=test-server --mac=00:0C:29:7E:3A:8B --profile=f7-i386
	
