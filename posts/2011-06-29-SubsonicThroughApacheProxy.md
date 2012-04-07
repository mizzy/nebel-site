---
layout: post
title: SubsonicThroughApacheProxy
date: 2011-06-29 22:40:54 +0900
---


[@earlcyborg くん](http://twitter.com/#!/earlcyborg) に教えてもらった [Subsonic](http://www.subsonic.org/pages/index.jsp) がよさげなので、家の中に環境作り、Apache mod_proxy 経由でアクセスしようとしたらはまったのでメモ。

結論: ProxyPreserveHost On を入れないとはまる。

最初、

	
	<VirtualHost *>
	ServerName subsonic.mizzy.org
	ProxyPass / http://192.168.10.14:4040/
	ProxyPassReverse / http://192.168.10.14:4040/
	</VirtualHost>
	

という設定で http://subsonic.mizzy.org/ にアクセスしたら、http://192.168.10.14:4040/login.view? にリダイレクトされてしまった。Subsonic にホスト名を設定するところもなさそう。そこで、おそらく Host ヘッダに設定されたホストがリダイレクト先になるんじゃなかろうか、と仮説を立てて、以下のように設定してみた。

	
	<VirtualHost *>
	ServerName subsonic.mizzy.org
	ProxyPreserveHost On
	ProxyPass / http://192.168.10.14:4040/
	ProxyPassReverse / http://192.168.10.14:4040/
	</VirtualHost>
	

これでうまくいった。
