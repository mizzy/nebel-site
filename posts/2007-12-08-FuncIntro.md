---
layout: post
title: FuncIntro
date: 2007-12-08 01:58:14 +0900
---


[Open Tech Press](http://opentechpress.jp/developer/07/12/06/0046247.shtml) で知った、[Func](https://hosted.fedoraproject.org/projects/func/) がおもしろそうだ。

とりあえずどんなツールかを要約すると、

* 複数のサーバに対して、何らかの処理を一括でまとめて実行して結果が取得できる。たとえば、yum でパッケージをインストールとか。
* 「何らかの処理」の部分は、モジュールで拡張できる。
* 「何らかの処理」はコマンドラインから実行して単に結果を表示、ということもできるし、Python API でプログラマブルに処理することもできる。
* クライアント/サーバアーキテクチャ

これだけだと何となくわかるようでわからない。触ってみるのが一番。というわけでまずはインストール。

# インストール

[InstallAndSetupGuide](https://hosted.fedoraproject.org/projects/func/wiki/InstallAndSetupGuide) を読むと、（おそらく最近の）Fedora であれば yum 一発でインストールできるみたいだけど、手元にある CentOS 5 用のパッケージがなさそうなので、ソース RPM からパッケージをつくる。（noarch なので FC7 用でもそのまま入りそうだけど、せっかくだからつくってみる。）

まずは [FuncReleases](https://hosted.fedoraproject.org/projects/func/wiki/FuncReleases) から func-0.13-3.fc7.src.rpm をゲット。

次にソース RPM からリビルドするために必要なパッケージをインストール。

	
	$ sudo yum -y install rpm-build python-devel python-setuptools 
	

リビルドしてインストール。依存パッケージの PyOpenSSL も忘れずに。

	
	$ sudo rpmbuild --rebuild func-0.13-3.fc7.src.rpm
	$ sudo yum -y install pyOpenSSL
	$ sudo rpm -ivh /usr/src/redhat/RPMS/noarch/func-0.13-3.noarch.rpm
	

サーバを起動する。サーバは master と呼ばれるみたい。

	
	$ sudo /etc/init.d/certmaster start
	

次にクライアント側。クライアントは minion と呼ばれているようだ。インストール手順は master と同じなので省略。

クライアント側では設定ファイル /etc/func/minion.conf を修正する必要がある。といっても、certmaster で master を指定してあげるだけでとりあえず OK。

	
	# configuration for minions
	
	[main]
	log_level = DEBUG
	certmaster = server.example.org
	cert_dir = /etc/pki/func
	acl_dir = /etc/func/minion-acl.d 
	

クライアント側で常駐するデーモン funcd を起動。

	
	$ sudo /etc/init.d/funcd start   
	

master と minion の通信は SSL 証明書での認証が必要なので、master 側で証明書リクエストに対して署名を行う。（この辺りはPuppetと一緒だ。）

	
	$ sudo certmaster-ca --list
	client.example.org
	$ sudo certmaster-ca --sign client.example.org
	

これで使うための準備はできた。


# コマンド実行

master 上で func コマンドを実行する。まずは minion の一覧を表示。

	
	$ sudo func "*" list_minions
	['https://client0.example.org:51234', 'https://client1.example.org:51234']
	client0.example.org
	client1.example.org
	0
	

www ではじまる minion だけを表示。

	
	$ sudo func "www*" list_minions
	['https://www0.example.org:51234', 'https://www1.example.org:51234']
	www0.example.org
	www1.example.org
	0
	


各 minion で利用できるモジュールの一覧を表示。

	
	$ sudo func "*" call system list_modules
	on https://client0.example.org:51234 running system list_modules ()
	['command', 'copyfile', 'func_module', 'hardware', 'nagios-check', 'process', 'reboot', 'rpms', 'service', 'smart', 'snmp', 'test', 'yum']
	on https://client1.example.org:51234 running system list_modules ()
	['command', 'copyfile', 'func_module', 'hardware', 'nagios-check', 'process', 'reboot', 'rpms', 'service', 'smart', 'snmp', 'test', 'yum']
	{'client0.example.org': ['command',
	                        'copyfile',
	                        'func_module',
	                        'hardware',
	                        'nagios-check',
	                        'process',
	                        'reboot',
	                        'rpms',
	                        'service',
	                        'smart',
	                        'snmp',
	                        'test',
	                        'yum'],
	 'client1.example.org': ['command',
	                        'copyfile',
	                        'func_module',
	                        'hardware',
	                        'nagios-check',
	                        'process',
	                        'reboot',
	                        'rpms',
	                        'service',
	                        'smart',
	                        'snmp',
	                        'test',
	                        'yum']}   
	

service モジュールで使えるメソッド一覧を表示。

	
	$ sudo func "client0.example.org" call service list_methods
	on https://client0.example.org:51234 running service list_methods ()
	['status', 'reload', 'get_running', 'stop', 'start', 'inventory', 'get_enabled', 'restart', 'module_description', 'module_version', 'module_api_version', 'list_methods']
	{'client0.example.org': ['status',
	                        'reload',
	                        'get_running',
	                        'stop',
	                        'start',
	                        'inventory',
	                        'get_enabled',
	                        'restart',
	                        'module_description',
	                        'module_version',
	                        'module_api_version',
	                        'list_methods']} 
	

service モジュールの status メソッドで ntpd の起動状態を確認。以下はすべての minion で ntpd が停止してる状態での実行結果。

	
	$ sudo func "*" call service status ntpd
	on https://client0.example.org:51234 running service status (ntpd)
	3
	on https://client1.example.org:51234 running service status (ntpd)
	3
	{'client1.example.org': 3, 'client0.example.org': 3}
	

ntpd を起動。

	
	$ sudo func "*" call service start ntpd
	on https://client0.example.org:51234 running service start (ntpd)
	0
	on https://client1.example.org:51234 running service start (ntpd)
	0
	{'client1.example.org': 0, 'client0.example.org': 0}   
	

ntpd の起動状態を確認。

	
	$ sudo func "*" call service status ntpd
	on https://client0.example.org:51234 running service status (ntpd)
	0
	on https://client1.example.org:51234 running service status (ntpd)
	0
	{'client1.example.org': 0, 'client0.example.org': 0}   
	

*.example.org のみをターゲットにする。

	
	$ sudo func "*.example.org" call service status ntpd
	on https://client0.example.org:51234 running service status (ntpd)
	0
	on https://client1.example.org:51234 running service status (ntpd)
	0
	{'client1.example.org': 0, 'client0.example.org': 0}   
	

client0.example.org と client1.example.org のみをターゲットにする。

	
	$ sudo func "client0.example.org; client1.example.org" call service status ntpd
	on https://client0.example.org:51234 running service status (ntpd)
	0
	on https://client1.example.org:51234 running service status (ntpd)
	0
	{'client1.example.org': 0, 'client0.example.org': 0}   
	

ここまで実行してみれば、何となく感じは掴めると思う。

# モジュール

デフォルトで付属しているモジュールには以下のものがある。

* command
* copyfile
* func_module
* hardware
* nagios-check
* process
* reboot
* rpms
* service
* smart
* snmp
* test
* yum

[使い方はこの辺参照。](https://hosted.fedoraproject.org/projects/func/#ListofStockModules)

とりあえず

	
	$ sudo func client0.example.org system list_modules
	

で利用できるモジュールを調べて、

	
	$sudo func client0.example.org call module list_methods
	

でモジュールで使えるメソッド一覧を表示してみると、どんなモジュールがあるか、そのモジュールはどんなことができるのか、がおおよそわかるはず。

# モジュールの書き方

[ここに書かれてる。](https://hosted.fedoraproject.org/projects/func/wiki/HowToWriteAndDistributeNewModules)これで自分が好きなように機能拡張ができる。



# Python プログラムから呼び出し

[ここにサンプルがある。](https://hosted.fedoraproject.org/projects/func/wiki/PythonApiExamples)

今後は [wiki:Func こちらの Wiki ページ] に情報まとめていく予定。