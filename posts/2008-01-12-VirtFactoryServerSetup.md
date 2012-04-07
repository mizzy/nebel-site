---
layout: post
title: VirtFactoryServerSetup
date: 2008-01-12 15:41:17 +0900
---


[前回紹介した](http://trac.mizzy.org/public/wiki/VirtFactory) Virt-Factory について、まずはサーバ側のインストールと設定手順を解説します。[yappo さんと hirose31 さんに wktk されてしまった](http://b.hatena.ne.jp/entry/http://trac.mizzy.org/public/wiki/VirtFactory)ので、もう後には引けません。

おおまかな手順は [本家サイトのドキュメント](http://virt-factory.et.redhat.com/vf-install-setup.php) の通りなのですが、ここの通りやってもうまくいかないので、試してみたい方は以下の手順を参考にしてください。

なお、本家から提供されているパッケージが Fedora 7 用のものしかないため、楽をするために Fedora 7 で検証しています。また、現時点での Virt-Factory のバージョンは 0.0.4 です。

# SELinux と iptables をオフに

とりあえず検証目的なので、こいつらはオフにしときます。手順は省略。


# yum リポジトリの設定

virt-factory.et.redhat.com のリポジトリを見に行くようにする。

	
	$ sudo wget http://virt-factory.et.redhat.com/download/repo/virt-factory.repo --output-document=/etc/yum.repos.d/virt-factory.repo
	

virt-factory.repo の内容が間違ってるので、以下のように修正。

	
	#!diff
	--- /etc/yum.repos.d/virt-factory.repo.orig      2007-12-29 21:14:22.000000000 +0900
	+++ /etc/yum.repos.d/virt-factory.repo   2007-12-29 21:14:55.000000000 +0900
	@@ -1,11 +1,11 @@
	 [virt-factory-fedora]
	 name=Virt-factory packages
	-baseurl=http://virt-factory.et.redhat.com/download/repo/fc$releasever/stable/$arch/
	+baseurl=http://virt-factory.et.redhat.com/download/repo/f$releasever/stable/i386/
	 enabled=1
	 gpgcheck=0
	
	 [virt-factory-srpms]
	 name=Virt-factory src packages
	-baseurl=http://virt-factory.et.redhat.com/download/repo/fc$releasever/stable/srpms
	+baseurl=http://virt-factory.et.redhat.com/download/repo/f$releasever/stable/srpms
	 enabled=0
	 gpgcheck=0   
	

$arch の部分は Fedora 7 32bit だと i686 になってしまうが、リポジトリのディレクトリは i386 なので、修正が必要。64bit だと $arch 部分はそのままでいいかも。

# 必要なパッケージのインストール


普通に virt-factory-server パッケージを yum で入れると、依存関係で cobbler と koan が一緒にインストールされるのですが、updates にある cobbler 0.6.4 と koan 0.6.3 がインストールされてしまって、virt-factory-server が正常に動きません。なので、virt-factory.et.redhat.com にある 0.6.2 を明示的にインストールしてやります。

	
	$ sudo yum install cobbler-0.6.2-1.fc7  koan-0.6.2-1.fc7
	

次に、Virt-Factory サーバ本体である virt-factory-server パッケージをインストールします。また、依存関係にはないものの、python-setuptools も必要なので一緒に入れておきます。

	
	$ sudo yum install virt-factory-server python-setuptools
	


# PostgreSQL の初期化

Virt-Factory はデータベースとして PostgreSQL を利用しています。（MySQL への対応予定もあるらしい。）以下のコマンドを実行して、Virt-Factory から PostgreSQL が利用できる状態にします。

	
	$ sudo /etc/init.d/postgresql initdb    
	$ sudo vf_fix_db_auth
	

# デーモンの起動

Puppet を利用してるので、とりあえず Puppet サーバを起動しておきます。（が、この段階では起動しなくても問題ないです。）

	
	$ sudo /sbin/chkconfig puppetmaster on 
	$ sudo /etc/init.d/puppetmaster start
	

次に qpidd を起動します。これは必ず起動しておく必要があります。qpidd は、Virt-Factory のクライアント/サーバ間でのメッセージングのために利用されています。

	
	$ sudo /sbin/chkconfig qpidd on
	$ sudo /etc/init.d/qpidd start 
	

最後に virt-factory-server を起動します。

	
	$ sudo /sbin/chkconfig virt-factory-server on
	$ sudo /etc/init.d/virt-factory-server start
	

初回は起動時はデータベースとかテーブルを自動で作ってくれます。


# vf_server import の実行

vf_server import により、以下の内容が実行されます。

* /etc/virt-factory/settings の repos セクションに基づく yum リポジトリミラーの作成
* /etc/virt-factory/settings の mirrors セクションに基づくディストリビューションミラーの作成
* プロファイルの作成

ただし、プロファイルは cobbler import で作成されるものと一緒で、Virt-Factory に適したものではないため、捨ててしまって構いません。

まず、/etc/virt-factory/settings を2箇所いじります。mirrors のところは元は FC-7 になってるのですが、F-7 にしておく必要があります。

address は Virt-Factory サーバの IP アドレスを指定します。今回の import とは直接関係しませんが、どのみち変える必要があるので変えておきます。

	
	mirrors:
	    F-7: [ 'rsync://ftp.jaist.ac.jp/pub/Linux/Fedora/releases/7/Fedora/i386/os/', '']
	this_server:
	    address: '192.168.25.134'
	

または、iso ファイルをダウンロードしてきて、

	
	$ sudo mkdir /mnt/dvdiso
	$ sudo mount -t iso9660 -o loop F-7-i386-DVD.iso /mnt/dvdiso
	

とマウントして、/etc/virt-factory/settings には

	
	mirrors:
	    F-7: [ '/mnt/dvdiso', '']
	

と設定してもいいです。検証で何度もやる場合には、iso イメージを持ってきておいた方が早いですね。

Virt-Factory でインストールするディストリビューションが Fedora 7 以外の場合には、repos セクションや mirrors セクションを適切に修正する必要があります。

設定ができたら、以下のコマンドを実行します。

	
	$ sudo vf_server import
	

cobbler report で結果を確認できます。distro, repo, profile が登録されていることが確認できます。

	
	$ sudo cobbler report
	distro          : F-7-i386
	kernel          : /var/www/cobbler/ks_mirror/F-7/images/pxeboot/vmlinuz
	initrd          : /var/www/cobbler/ks_mirror/F-7/images/pxeboot/initrd.img
	kernel options  : {}
	architecture    : x86
	ks metadata     : {'tree': 'http://@@server@@/cblr/links/F-7-i386'}
	breed           : redhat
	
	distro          : F-7-xen-i386
	kernel          : /var/www/cobbler/ks_mirror/F-7/images/xen/vmlinuz
	initrd          : /var/www/cobbler/ks_mirror/F-7/images/xen/initrd.img
	kernel options  : {}
	architecture    : x86
	ks metadata     : {'tree': 'http://@@server@@/cblr/links/F-7-xen-i386'}
	breed           : redhat
	
	repo             : F-7-i386-core-lite
	mirror           : http://download.fedora.redhat.com/pub/fedora/linux/releases/7/Everything/i386/os/
	keep updated     : True
	local filename   : F-7-i386-core-lite
	rpm list         : ['m2crypto', 'python-simplejson']
	createrepo_flags : -c cache
	
	repo             : F-7-i386-updates-lite
	mirror           : http://download.fedora.redhat.com/pub/fedora/linux/updates/7/i386/
	keep updated     : True
	local filename   : F-7-i386-updates-lite
	rpm list         : ['cobbler', 'koan', 'python-cheetah', 'yum-utils', 'puppet',
	'facter']
	createrepo_flags : -c cache
	
	repo             : F-7-i386-vf_repo
	mirror           : http://virt-factory.et.redhat.com/download/repo/f7/stable/i386/
	keep updated     : True
	local filename   : F-7-i386-vf_repo
	rpm list         :
	createrepo_flags : -c cache
	
	repo             : F-7-x86_64-core-lite
	mirror           : http://download.fedora.redhat.com/pub/fedora/linux/releases/7/Everything/x86_64/os/
	keep updated     : True
	local filename   : F-7-x86_64-core-lite
	rpm list         : ['m2crypto', 'python-simplejson']
	createrepo_flags : -c cache
	
	repo             : F-7-x86_64-vf_repo
	mirror           : http://virt-factory.et.redhat.com/download/repo/f7/stable/x86_64/
	keep updated     : True
	local filename   : F-7-x86_64-vf_repo
	rpm list         :
	createrepo_flags : -c cache
	
	profile         : F-7-i386
	distro          : F-7-i386
	kickstart       : /etc/cobbler/kickstart_fc6.ks
	kernel options  : {}
	ks metadata     : {}
	virt file size  : 5
	virt ram        : 512
	virt type       : auto
	virt path       :
	repos           : []
	
	profile         : F-7-xen-i386
	distro          : F-7-xen-i386
	kickstart       : /etc/cobbler/kickstart_fc6.ks
	kernel options  : {}
	ks metadata     : {}
	virt file size  : 5
	virt ram        : 512
	virt type       : auto
	virt path       :
	repos           : [] 
	

# サンプルプロファイルのインポート

virt-factory.et.redhat.com にサンプルプロファイルがあるので、こいつをインポートしてみます。

	
	$ sudo rpm -Uvh http://virt-factory.et.redhat.com/download/profiles/vf-profile-Container-1-2.fc7.noarch.rpm
	$ sudo rpm -Uvh http://virt-factory.et.redhat.com/download/profiles/vf-profile-Test1-1.234-2.fc7.noarch.rpm
	$ sudo vf_import
	

cobbler report を実行すると、以下の4つのプロファイルが登録されていることが確認できます。

	
	profile         : Container::F-7-i386
	distro          : F-7-i386
	kickstart       : /var/lib/virt-factory/kick-fc6.ks
	kernel options  : {}
	ks metadata     : {'server_name': '192.168.10.14', 'node_bare_packages': 'libvirt\npython-virtinst\nqemu\nkvm\n', 'cryptpw': '$1$mF86/UHC$WvcIcX2t6crBz2onWxyac.', 'server_param': '--server=http://192.168.10.14:5150', 'node_common_packages': 'koan\npuppet\nvirt-factory-nodes\nvirt-factory-register\nqemu\nkvm\n', 'network_param': '--allow-bridge-config', 'extra_post_magic': '/sbin/chkconfig 345 qemu on\n', 'node_virt_packages': '', 'token_param': '--profile=Container::F-7-i386'}
	virt file size  : 0
	virt ram        : 0
	virt type       : qemu
	virt path       :
	repos           : ['F-7-i386-updates-lite', 'F-7-i386-core-lite', 'F-7-i386-vf_repo']
	
	profile         : Container::F-7-xen-i386
	distro          : F-7-xen-i386
	kickstart       : /var/lib/virt-factory/kick-fc6.ks
	kernel options  : {}
	ks metadata     : {'server_name': '192.168.10.14', 'node_bare_packages': 'libvirt\npython-virtinst\nxend\n', 'cryptpw': '$1$mF86/UHC$WvcIcX2t6crBz2onWxyac.', 'server_param': '--server=http://192.168.10.14:5150', 'node_common_packages': 'koan\npuppet\nvirt-factory-nodes\nvirt-factory-register\nxen\nkernel-xen\n', 'network_param': '--allow-bridge-config', 'extra_post_magic': _, 'node_virt_packages': _, 'token_param': '--profile=Container::F-7-xen-i386'}
	virt file size  : 0
	virt ram        : 0
	virt type       : xenpv
	virt path       :
	repos           : ['F-7-i386-updates-lite', 'F-7-i386-core-lite', 'F-7-i386-vf_repo'] 
	
	profile         : Test1::F-7-i386
	distro          : F-7-i386
	kickstart       : /var/lib/virt-factory/kick-fc6.ks
	kernel options  : {}
	ks metadata     : {'server_name': '192.168.10.14', 'node_bare_packages': _, 'cryptpw': '$1$mF86/UHC$WvcIcX2t6crBz2onWxyac.', 'server_param': '--server=http://192.168.10.14:5150', 'node_common_packages': 'koan\npuppet\nvirt-factory-nodes\nvirt-factory-register\nqemu\nkvm\n', 'network_param': '', 'node_virt_packages': _, 'token_param': '--profile=Test1::F-7-i386'}
	virt file size  : 5
	virt ram        : 512
	virt type       : qemu
	virt path       :
	repos           : ['F-7-i386-updates-lite', 'F-7-i386-core-lite', 'F-7-i386-vf_repo']
	
	profile         : Test1::F-7-xen-i386
	distro          : F-7-xen-i386
	kickstart       : /var/lib/virt-factory/kick-fc6.ks
	kernel options  : {}
	ks metadata     : {'server_name': '192.168.10.14', 'node_bare_packages': _, 'cryptpw': '$1$mF86/UHC$WvcIcX2t6crBz2onWxyac.', 'server_param': '--server=http://192.168.10.14:5150', 'node_common_packages': 'koan\npuppet\nvirt-factory-nodes\nvirt-factory-register\nxen\nkernel-xen\n', 'network_param': '', 'node_virt_packages': _, 'token_param': '--profile=Test1::F-7-xen-i386'}
	virt file size  : 5
	virt ram        : 512
	virt type       : xenpv
	virt path       :
	repos           : ['F-7-i386-updates-lite', 'F-7-i386-core-lite', 'F-7-i386-vf_repo']
	

cobbler import した時のプロファイルと違って、ks_metadata に koan, pupppet, virt-factory-nodes, virt-factory-register など、Virt-Factory クライアントとして必要なパッケージが含まれていたり、キックスタートファイル（/var/lib/virt-factory/kick-fc6.ks ）の %post セクションで、Virt-Factory クライアントとして必要な処理が実行されています。


# Web UI のインストール、設定、起動

virt-factory-wui パッケージをインストールするのですが、そのままインストールすると、rubygem-rails-2.0.1-1.fc7 がインストールされてしまい、動作しません。なので、明示的に rubygem-rails-1.2.3-1.fc7 をインストールします。

	
	$ sudo yum install rubygem-rails-1.2.3-1.fc7
	

その後 virt-factory-wui パッケージをインストールします。

	
	$ sudo yum install virt-factory-wui
	

デフォルトでは 127.0.0.1 でリッスンするようになっているので、他のマシンからアクセスする場合には、/etc/init.d/virt-factory-wui を書き換えます。

	
	#!diff
	--- /etc/init.d/virt-factory-wui.orig       2007-12-30 02:41:06.000000000 +0900
	+++ /etc/init.d/virt-factory-wui    2007-12-30 02:41:23.000000000 +0900
	@@ -10,7 +10,7 @@
	 VIRTFACTORY_DIR=/usr/share/virt-factory-wui
	 MONGREL_LOG=/var/log/virt-factory-wui/mongrel.log
	 MONGREL_PID=/var/run/virt-factory-wui/mongrel.pid
	-ADDR=127.0.0.1
	+ADDR=0.0.0.0
	 RAILS_ENVIRONMENT=production
	 USER=virtfact
	 GROUP=virtfact
	

起動します。

	
	$ sudo /sbin/chkconfig virt-factory-wui on
	$ sudo /etc/init.d/virt-factory-wui start  
	

css ファイルへのパスがおかしいので、/usr/share/virt-factory-wui/app/views/layouts/virt-factory-layout.rhtml を修正します。

	
	#!diff
	--- /usr/share/virt-factory-wui/app/views/layouts/virt-factory-layout.rhtml.ori2007-12-30 02:44:24.000000000 +0900
	+++ /usr/share/virt-factory-wui/app/views/layouts/virt-factory-layout.rhtml    2007-12-30 02:44:40.000000000 +0900
	@@ -7,7 +7,7 @@
	      <!-- dynamically filled in page title -->
	      <title>virt-factory: <%= @page_title %></title>
	
	-     <link rel="stylesheet" href="<%= ActionController::AbstractRequest.relative_url_root %>/style.css" type="text/css" />
	+     <link rel="stylesheet" href="/style.css" type="text/css" />
	
	   </head>
	

3000番 ポートにアクセスして、admin, fedora でログインします。

# virt-factory-ampm のインストール

virt-factory-ampm は、Virt-Factory のコマンドラインクライアントで、リモートホスト上に仮想マシンを作成したり、仮想マシンの起動/停止を行ったり、といったことができます。

	
	$ sudo yum install virt-factory-ampm 
	

このままだと ampm コマンドを実行する度に no config file found と言われてうざいので、空の .ampm_config を作成しておきます。

	
	$ touch ~/.ampm_config
	

help を見ると、どんなことができるかがざっとわかります。

	
	$ ampm --help
	global options
	         --help, -h
	         --verbose, -v
	         --server <server url>
	         --username <username>
	         --passowrd <password>
	valid modes include:
	         pause, create, list, start, add, shutdown, query, unpause, delete
	pause:
	        Pause a guest
	        ampm pause guest_name [--guest_id] <guest_id>
	create:
	        Create a new guest
	        --help, -h
	        --verbose, -v
	        --host <hostname>           the  host to run the guest on
	        --profile <profilename>     the profile to create the guest with
	list:
	        List information about virt-factory
	        valid sub modes are hosts, guests, status, profiles, tasks, users
	                 hosts      list machines capabable of running guests
	                 guests     list virtulized guests
	                 status     list status of virtulized guests
	                 profiles   list profiles available for creating guests or hosts
	                 tasks      list tasks that are queued
	                 users      list users
	start:
	        Start up a guest
	        ampm start guest_name [--guest_id] <guest_id>
	add:
	         Add a new user to virt-factory
	         --username <username>
	         --password <password>
	         --first <first_name
	         --middle <middle_name>
	         --last <last_name>
	         --email <email address>
	         --description <desription>
	shutdown:
	        Shutdown a guest
	        ampm shutdown guest_name [--guest_id] <guest_id>
	query:
	        Query a guest for more info about what host or profile a guest is running
	        --help, -h
	        --verbose, -v
	        --host <host>     which host a guest is running on
	        --profile <profile>          which profile a guest is running
	unpause:
	        Unpause a guest
	        ampm unpause guest_name [--guest_id] <guest_id>
	delete:
	        Delete a task, profile, or user
	         --help, -h
	         --verbose, -v
	         --task_id <task_id>            delete a task from the task queue
	         --user_id <user_id>            delete a user
	


~~次回はクライアント側のインストールと設定手順について解説予定です。~~[解説アップしました](http://trac.mizzy.org/public/wiki/VirtFactoryClientSetup)。
